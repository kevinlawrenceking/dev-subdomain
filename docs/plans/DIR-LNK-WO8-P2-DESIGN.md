# DIR-LNK-WO-8 — P2 DESIGN MEMO + RULINGS SHEET

**Work order:** DIR-LNK-WO-8 (master auto-sync for linked contacts).
**Branch:** dev · **Project:** TAO-MCD-P1 · **Spec MD5:** 078d926d.
**Predecessors of record:** P0b lock `3c2dd63b`, P1 recon `1b944cd8` (ACCEPTED). origin/dev = `05b20a16`.
**Status:** P2 design authored per lock P2a-e + the P1-ACCEPT relay (5 items). **STOP for operator** — P3 authoring is gated on explicit approval of this memo **and** the Q8-Q13 rulings sheet (§8). No code, no DDL, no push in this phase.
**Scope reminder (Section 2a):** WO-8 writes only the three copied columns — `contactCompany`, `contactEmail`, `contactPhone` — and only where the paired `_src='master'`. It never writes `_src='user'`, never touches pointers/`contactitems`/photo/address/IMDB.

---

## 1. Ratified inputs folded in (from the P1-ACCEPT relay)

- **Trigger (Q8):** v1 = **(i) lazy-on-read + (ii) on-demand admin re-sync**. Models (iii) scheduled and (iv) change-driven are **DEFERRED** until DIR-CRUD makes master editing real and audited. No scheduler, no `request.svc` shim, no change stream in v1. *(Recon: the shim already exists anyway — `sched/Application.cfc` — so a future (iii) is a thin caller, not new infrastructure.)*
- **Backfill (Q10):** first-run backfill is **scoped to `_src='master'` only** — sweep ALL linked contacts, write only where `_src='master'`, value-comparison, idempotent, no-op where correct. **No silent promotion** of bridge links.
- **Bridge-link migration (separate, registered):** the 13 bridge-era links are brought current by routing them through **WO-7's preservation-aware relink flow** (preserve displaced values as Additional info + audit), **not** by this sweep. Until that runs, the 13 remain **INTERIM** — functional and displaying their values, not gold-badged, not truly master-sourced. Accepted and honest. Kin to WO-11 bridge-residue work.

---

## 2. Sync engine design (lock P2a)

### 2.1 The operation
For one linked contact: **re-derive** the master snapshot from the *stored* `master_co_contact_id` + `company_location_id` → **compare** field-by-field to the stored columns → **UPDATE only the differing fields, only where `_src='master'`** → **audit** each written field as `MASTER_AUTO_UPDATE`. Server-internal; no client input; the caller supplies only `contactid`+`userid` (from session/context), every master value is re-derived server-side. Value-comparison change detection (never a timestamp — sidesteps N-1).

### 2.2 Derivation reuse (resolves F-1) — the authoritative re-derivation
The derivation is exactly confirmLink's (`MasterDirectoryService.cfc:293-325`):
- **company** ← `co_contacts.coid` (the master person's *authoritative* company id, `cc.coid`) → `companies.coName`. **Not** the stored `master_coid` (which the panel's `qMasterLink` joins on for display and which can go stale — see §7 pointer note).
- **email / phone** ← `co_locations` for the stored `company_location_id`, validated to belong to the derived company (`WHERE colocid = ? AND coid = cc.coid`), reading `co_locations.phone` / `.email` (D-21).

**Recommendation:** extract this into a shared read-only helper `MasterDirectoryService.deriveMasterValues(masterCoContactId, colocid) → {found, coName, newCoid, colocResolved, offPhone, offEmail}` and refactor `confirmLink` to call it — a *pure extraction*, no behavior change, staged as its own reviewable step so line-review can confirm confirmLink stays byte-equivalent. (Alternative: duplicate the two queries in the sync method to leave the closed WO-7 path untouched; DRY vs. zero-regression-risk — architect's call at P3. The memo recommends the shared helper: the lock explicitly wants derivation reuse, and one derivation prevents the two paths ever diverging.)

### 2.3 The **derive-or-skip safety rule** (central; prevents reseed-transient data loss)
A field is synced **only when its master source resolves**. This is the guard that keeps a transient reseed gap from erasing real data:
- **Master person not resolvable** (`cc.id` gone) → **skip all three** (no write, log a warning; candidate for the WO-10 bad-match/orphan register). Never blank on a missing person.
- **Company not resolvable** (`cc.coid` → no `companies` row) → **skip company** (do not blank it); email/phone handled independently.
- **Office not resolvable** (stored `company_location_id` has no valid `co_locations` row under the derived company) → **skip email/phone** (do not blank them). A stale pointer after a reseed must not masquerade as "the office lost its phone."
- **Source resolves but the field is genuinely empty** → **that is a real blank** → mirror per Q9 (populated→blank) / fill per Q12 (blank→populated). This is the *only* path to a blanking write.

Consequence: **Q9's blast radius is narrowed to a genuine resolved-blank** — sync never blanks because a lookup failed, only because the Book truly holds no value there.

### 2.4 Comparator semantics
Per field, `changed = (_src='master') AND differs(stored, derived)` where `differs` is **TRIM + NULL-safe (NULL == '' == blank) + collation case-insensitive** (`utf8mb4_unicode_ci`, matching WO-7 L-3 `compareNoCase`). Therefore:
- **case-only** and **whitespace-only** master changes are treated as **non-material** and **not** synced (spec §9.3 "may synchronize silently" → we choose silent-and-skip to avoid churn; matches WO-7 L-3).
- any other difference — different digits, different email/domain, punctuation/format change, **blank↔populated** — is **material**, synced, and audited. No material/non-material classifier is built (F-5): WO-8 writes+audits uniformly on any material diff.

### 2.5 Enforcement shape (resolves the writer; §17 stale-write guard)
`writeLinkSnapshot` is **not** reusable verbatim — it stamps all three `_src='master'` unconditionally and rewrites pointers, which would **stomp** a `_src='user'` field. WO-8 uses a **new guarded conditional UPDATE** (design sketch; final SQL at P3):

```sql
UPDATE contactdetails_tbl
SET   /* only the fields CF found changed, each self-guarded on _src at write time */
      contactPhone   = CASE WHEN contactPhone_src='master'   THEN :dPhone   ELSE contactPhone   END,
      contactEmail   = CASE WHEN contactEmail_src='master'   THEN :dEmail   ELSE contactEmail   END,
      contactCompany = CASE WHEN contactCompany_src='master' THEN :dCompany ELSE contactCompany END,
      master_last_sync = now()                      /* last-touch record; bumped ONLY on a real write */
WHERE contactid = :cid AND userid = :uid AND isdeleted = 0
  AND master_co_contact_id = :derivedFromMaster     /* stale-write guard: unlink/relink since read -> 0 rows */
  AND ( /* row matches only if >=1 managed field still genuinely needs writing */
        (contactPhone_src='master'   AND NOT (TRIM(COALESCE(contactPhone,''))   <=> TRIM(COALESCE(:dPhone,''))))
     OR (contactEmail_src='master'   AND NOT (TRIM(COALESCE(contactEmail,''))   <=> TRIM(COALESCE(:dEmail,''))))
     OR (contactCompany_src='master' AND NOT (TRIM(COALESCE(contactCompany,'')) <=> TRIM(COALESCE(:dCompany,''))))
      )
```

Properties:
- **True no-op when current:** CF computes the diff set from a pre-read; if empty, the method returns `{noop:true}` and **runs no SQL write at all** (zero writes, zero audit — acceptance b). The `WHERE` OR is a second line of defense (a concurrent writer having fixed the drift → 0 rows → no audit).
- **Per-field `_src='master'` guard:** the `CASE` re-checks provenance at write time; a `_src='user'` field is never overwritten even under a race.
- **`master_last_sync`** bumps only when the row matches (a real write) — the last-touch record, **not** the change discriminator (Section 2c).
- **Write target** = `contactdetails_tbl` (base table); reads via the `contactdetails` view/`_tbl` as confirmLink does.
- **Only fields CF flagged** appear in the `SET` (the sketch shows all three for clarity; P3 builds the SET from the diff set).

**Concurrency note (honest):** CF drives the per-field audit set from the pre-read. Under two *simultaneous* panel loads of the *same* contact mid-drift, a narrow race can produce a spurious/`old==new` audit row — never data corruption (the UPDATE is value-idempotent, and epoch-in-key dedups identical concurrent writes, §2.6). Given static master data (drift only appears post-reseed), this window is near-nonexistent in v1. If the architect wants an *exact* audit trail under concurrency, the hardening is a `SELECT ... FOR UPDATE` transactional compare (row-lock → compute → UPDATE → audit); recommended only if warranted, since it adds a row lock to the hot on-read path and departs from WO-7's "no read-then-write" ethos.

### 2.6 Transaction + audit mapping (resolves F-2 — the S-9 lesson)
One `cftransaction` wraps the guarded UPDATE + the per-field audit writes; rollback on writer failure or a lost race (0 rows).

Per changed field, `MasterAuditService.record(action_type="MASTER_AUTO_UPDATE", field_name=…, old_value=<stored>, new_value=<derived>, previous_source="master", new_source="master", master_co_contact_id, master_coid, company_location_id, run_id=<syncRunId>, idempotency_key=…)`.

- **Idempotency key carries an event discriminator** (or a legitimate repeat-change silently drops its audit row — S-9): `"WO8:<cid>:AUTOSYNC:e<epoch>:<field>"`, where `epoch = pre-mutation COALESCE(MAX(auditID),0)` for the contact — the *same* mechanism confirmLink/unlinkMaster already use. Concurrent double-sync of one drift (same pre-read epoch) → identical keys → INSERT IGNORE dedups; a later genuine change reads a strictly higher epoch (the first sync's rows raised `MAX(auditID)`) → fresh keys → every real change audits. Three fields in one sync share the epoch, distinguished by `field`.
- **`run_id`** is populated (the column exists, unused) → satisfies spec §16 "Related synchronization run" and §22 proof-of-sync: on-read uses a per-request id; the admin sweep uses one id for the whole run.
- Governed vocabulary only (`MASTER_AUTO_UPDATE` already in V3_12 + `MasterAuditService.governedActions()`), per-field granularity, `old_value`/`new_value` recorded. **No schema change.**

### 2.7 No DDL
Recon proved no gap: `MASTER_AUTO_UPDATE` is governed, `run_id`/`idempotency_key`/value columns exist, `_src` are `ENUM NOT NULL DEFAULT 'user'`. WO-8 needs **no migration** (Section 5 hold point satisfied). If P3 authoring surfaces a genuine gap it is raised at the STOP as a separate migration decision, never assumed.

---

## 3. Trigger design (lock P2b)

**The engine is trigger-agnostic.** The unit of work is the service method `syncLinkedContact(contactid, userid)` (§2). v1 ships **two thin callers**; future rungs (iii)/(iv) add callers only, no rework.

### 3.1 (i) Lazy on-read — the contact detail panel
- **Anchor:** `include/contact_info.cfm`. Call `syncLinkedContact(currentid, session.userid)` **before the `qMasterLink` query at :654**, so the panel's existing query returns freshly-synced columns and renders them at :834-836 with **no restructuring** of the render path. The method self-guards on link state (no-ops if `master_co_contact_id` is NULL), so the call is unconditional at panel load.
- **Cost on the unchanged path:** the method's own reads = `qOwn` + `deriveMasterValues` (qMaster + qLoc) = **3 indexed point-lookups + in-CF compares, zero writes**. Negligible at panel-load frequency. *(Not piggybacked on `qMasterLink`: that query derives company via the stored `master_coid`, not the authoritative `cc.coid`, and does not validate the office-belongs-to-company — so it cannot supply the authoritative compare. A future perf refinement could align `qMasterLink` to the authoritative derivation and fold the compare in; out of v1 scope.)*
- **Safety:** the write is conditional, idempotent, server-internal, value-gated — it refreshes *master-managed* fields to their authoritative values (never mutates user data), so a side-effecting write during a GET render is acceptable here. It uses the new guarded writer, **not** `updatePrimary` — so it cannot trip the WO-6 read-only enforcement, and it does not alter the "Managed by the TAO Master Directory" display logic (acceptance h: no visible latency, no WO-6/panel regression).

### 3.2 (ii) On-demand admin re-sync — the sweep
- An **admin-only** action that sweeps **all** linked contacts (`master_co_contact_id IS NOT NULL AND isdeleted=0`), calling `syncLinkedContact` for each, scoped `_src='master'`, under **one `run_id`**.
- **Endpoint contract:** a new admin-guarded POST endpoint (e.g. `ajax/master/resync-all.cfm`) returning the standard `{success, message, data:{scanned, changed, contactsWritten, runId}}`; CSRF-protected and admin-authorized exactly as other admin POSTs (exact gate confirmed at P3). Because the engine is a service method, the same sweep is later invokable from a `/sched/*.cfm` page if (iii) is ever adopted — no re-authoring.
- **This is the operator's "apply the reseed to linked contacts" button** — the natural companion to the manual prod→dev master reseed that P1a identified as the only way master values change today.

### 3.3 Read-surface coverage (per recon P1g)

| Surface | Reads the 3 columns? | Sync coverage in v1 |
|---|---|---|
| Contact detail panel (`contact_info.cfm`) | Yes (`qMasterLink`) | **(i) on-read** — always fresh on view |
| List / search (`contacts_ss` **view**, `SELECT *`) | Yes, via the view | **(ii) admin sweep** brings the whole set current; **no per-row on-read sync** (N syncs per list render rejected on cost). List rows for un-viewed contacts stay as fresh as the last panel-view or sweep. |
| Exports | No (P1g) | Nothing to cover |

The (i)+(ii) pair covers every surface that renders the columns: (i) keeps individual panels honest; (ii) brings the list/whole-set current on demand (and after a reseed). This is the deliberate lazy tradeoff the lock accepts.

---

## 4. First-run backfill (lock P2c)

The **(ii) admin re-sync action doubles as the backfill runner** — the same sweep, scoped `_src='master'`, value-comparison, idempotent. Per Q10:
- **Sweeps ALL linked contacts**, writes only where `_src='master'` and a field genuinely differs.
- **No-op today:** P1 proved drift among `_src='master'` fields = 0, so the first run writes **zero rows and zero audit** against the current dataset — the honest, correct outcome (the 3 full-snapshot links are already current; the 13 bridge links have `_src='user'` fields the sweep must not touch).
- **Genuine value:** after a master reseed that changes values, the same sweep writes exactly the drift and audits it under one `run_id`.
- The 13 bridge links are **not** brought current here (item 3) — they await the preservation-aware relink.

---

## 5. Epoch integrity (lock P2d; resolves F-3)

Confirmed **unaffected** by the new writer:
- The link/unlink epoch = pre-mutation `COALESCE(MAX(auditID),0)` **per contact**. `MASTER_AUTO_UPDATE` rows only **raise** `MAX(auditID)` monotonically, so a subsequent link/unlink reads a strictly-higher, still-unique epoch — no collision, no regression.
- Even under interleaving, each epoch is read from **committed** pre-mutation state and `INSERT IGNORE` dedups on the **committed** unique index (WO-7 V-2) — safe.
- Within one sync, the three `MASTER_AUTO_UPDATE` rows share the pre-mutation epoch, distinguished by `field` — no intra-sync collision.
- **Volume:** v1 sync volume is low (static data → 0 writes today; writes only post-reseed). Even at high volume, monotonic-raise is collision-safe by construction. The genuine downstream pressure is **`master_audit_tbl` growth/retention** — already registered: no prune/renumber or S-7 resurrects; carry to WO-12.
- **P5 (g)** proves it empirically: a relink + double-unlink regression **after** WO-8 sync writes.

---

## 6. UI scope (kept minimal)

- **Required:** the (ii) admin re-sync trigger (button/endpoint).
- **Optional, recommend DEFER unless trivial:** a passive "Updated from the Book" / "last synchronized" indicator on the panel (spec §9.5). `master_last_sync` is already read by `qMasterLink`, so a small badge is cheap — but note it is only a clean signal for WO-8-touched rows (legacy rows carry old bridge stamps). Defer to keep v1 tight.
- **`masterIsSynced` / D-23:** `contact_info.cfm:686` computes `masterIsSynced` as a **company-provenance proxy** (`contactCompany_src='master'`), and D-23 (:676-686) explicitly names **WO-8** as its revisit point. Because the 13 bridge links stay INTERIM in v1 (item 3), an *accurate* "fully master-managed" badge would be `(all three _src='master')` — but flipping the predicate would visibly demote the 8 company-only legacy links. **Recommend: leave `masterIsSynced` unchanged in v1** (it is a display predicate, outside the sync-engine scope); the accurate-synced badge pairs naturally with the bridge-link migration (item 3), not the sync engine.
- **Panel title-subline** (`co_contacts.jobtitle_type` query widen, WO-7 fix-batch #5, `contact_info.cfm:803-804`): a separate small enhancement. **Recommend re-defer** unless it proves trivial while the admin-resync UI is being built — it is unrelated to sync and should not widen WO-8's blast radius.

---

## 7. Carry-ins reconciled

- **`company_location_id` is the join key** — used for the office (email/phone) derivation. ✓
- **`contactPhoto_src` never stomped** — sync operates on `contactCompany/Email/Phone` only; it never reads or writes `contactPhoto_src` or the photo. Satisfied trivially. ✓
- **Pointer staleness (new, register):** WO-8 v1 syncs the three **value** columns only; it does **not** refresh the `master_coid` / `company_location_id` **pointers**. If a future reseed changes a master person's company or office identity, the pointers can go stale relative to the synced values (and the derive-or-skip rule §2.3 will *skip* rather than blank the affected fields). Pointer refresh belongs to the relink/migration path (item 3), not value-sync. Register.
- **13 bridge links INTERIM** — routed to preservation-aware relink (item 3). Not this sweep.
- **`master_audit_tbl` correctness-critical** — WO-8 respects it (epoch untouched, §5); growth → WO-12 retention.
- **F-1..F-5** from recon: F-1 resolved (§2.2/§2.5 guarded writer), F-2 resolved (§2.6 epoch-in-key + run_id), F-3 resolved (§5), F-4 (Q12 needs a built fixture at P5), F-5 (no material/non-material classifier; §2.4).

---

## 8. RULINGS SHEET (STOP here — operator rules; P3 opens only on approval of this memo + these rulings)

| Q | Question | Disposition sought |
|---|---|---|
| **Q8** | Trigger mechanism | **RATIFIED (relay item 1):** (i) lazy-on-read + (ii) on-demand admin re-sync; (iii)/(iv) deferred. Confirm. |
| **Q9** | Populated → blank (the silent, potentially-destructive one) | **OPERATOR'S CALL.** See the three options + consequences below. Architect lean **(a)**, but flagged because sync is silent. |
| **Q10** | First-run scope | **RATIFIED (relay item 2):** sweep ALL linked, write only where `_src='master'`, no-op where correct. Confirm. |
| **Q11** | Cadence | **N/A** under (i)+(ii) — no scheduled model in v1. |
| **Q12** | Blank-resolves (office gains email/phone → linked contact's blank field fills) | **YES — headline feature.** Falls out of the same code path (a genuine resolved-blank→populated diff). Requires a *built* fixture at P5 (F-4: no linked contact sits on a blank-office master field today). Confirm. |
| **Q13** | Photo / address / IMDB non-sync | **RATIFY.** Live-rendered from co_locations/co_contacts/image URL, never copied → nothing to propagate (spec §9.2 scope = the three fields; name stays user-owned). Confirm. |

### Q9 — the one with teeth (decide explicitly)
When the Book *had* a value for a managed field (`_src='master'`) and the value is later **genuinely removed** (source resolves, field now empty — per the derive-or-skip rule §2.3, this is a *real* blank, not a lookup failure):

- **(a) Mirror-and-audit** *(spec default, architect lean).* Set the field blank, keep `_src='master'`, audit `MASTER_AUTO_UPDATE` old→NULL. **Pro:** consistent with §7.5 ("linked primary fields mirror the master, including blank master fields") and the ratified Q4 link-time rule; keeping a value the Book no longer vouches for contradicts "managed by the Book." **Con:** sync is **silent** — no modal (unlike link time) discloses the blanking; a working number the user *sees* on the panel would vanish with no notice. **Recourse:** WO-9 "Suggest a correction."
- **(b) Keep-and-flip-to-`user`** *(the §7.5 "exception requiring product escalation").* Keep the last-known value, flip the field to `_src='user'`, audit the provenance change. **Pro:** never silently erases a value the user relies on. **Con:** the field becomes a private override of a master-managed primary — precisely what §10.1 says the correction workflow exists to *avoid*; and it is a documented exception to §7.5 that requires explicit product escalation.
- **(c) Keep-as-`master`, flag stale** *(middle).* Keep the value, mark it stale for the UI, audit. **Pro:** no data loss, no false provenance flip. **Con:** stores a value the Book contradicts; needs a stale-flag column/'_stale' convention (a schema/UI addition — no longer no-DDL) and a UI treatment; heavier than v1 warrants.

**Architect lean: (a)**, *narrowed* by the derive-or-skip rule so it only fires on a genuine resolved-blank (not a reseed-transient lookup gap), with WO-9 as the recourse. But this is the operator's call precisely because it is silent and potentially-destructive. **Note on blast radius:** under static master data, populated→blank only occurs on a reseed that removes a value — rare in v1 — but the rule must be set now because it is encoded in the writer.

### Q9 RULING OF RECORD (operator, 2026-07-27): **(a) MIRROR-AND-AUDIT**
A managed field whose master source **genuinely resolves to blank** is mirrored to blank and the old value recorded in `master_audit_tbl` (`MASTER_AUTO_UPDATE`, old→NULL); **WO-9 "suggest a correction" is the user's recourse**. Rejected: **(b)** keep+flip-to-`user` (creates the private master-override §10.1 forbids and shows, under a "managed by the Book" badge, a value the Book no longer holds — a quiet UI lie); **(c)** keep+flag-stale (needs a stale column, breaks no-DDL, for a state that essentially never occurs against static master data).

**BINDING PRECONDITION (load-bearing):** Q9=(a) is correct **because derive-or-skip (§2.3) is in place** — derive-or-skip narrows the blank to a *real, deliberate, near-nonexistent* case with an audit trail, so mirror-and-audit never fires on a resolution failure. **No future refactor may drop derive-or-skip without reopening Q9.** The two are a unit: `syncLinkedContact` must not blank a field unless its master source *resolved* and was *genuinely empty*.

---

## 9. Hold points / what P2 did NOT do

Design only. No code authored, no DDL, no DML, no fixtures, no push. Prod untouched. `origin/dev` unchanged at `05b20a16`; this memo commits docs-class, local only, awaiting the STOP. Section 5 hold points intact: no DDL (recon proved none needed), audit via the service layer using the governed `MASTER_AUTO_UPDATE` vocabulary, zero triggers.

## 10. STOP — P2 gate

On operator approval of this memo **and** the Q8-Q13 rulings (especially **Q9**), P3 authors the code per the standards in lock P3 (cfqueryparam; the guarded conditional UPDATE keyed contactid+userid with the per-field `_src='master'` guard; server-internal derivation via the shared helper; transaction + per-field `MASTER_AUTO_UPDATE` audit with epoch-in-key; value-comparison idempotency; the derive-or-skip safety rule; no view DDL; no schema change; the two thin trigger callers), delivered as diffs + file list for line review, then STOP. Suggested P3 staging for clean line-review: **(1)** pure extraction of `deriveMasterValues` (confirmLink byte-equivalent) → **(2)** `syncLinkedContact` service method + guarded writer + audit → **(3)** the (i) panel hook → **(4)** the (ii) admin sweep endpoint.
