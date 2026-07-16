# DIR-LNK-WO-6 — P2 DESIGN MEMO + RULINGS GATE. STOP.

**Binding (verified this session):** project TAO master-linking (DIR-LNK) · repo
`kevinlawrenceking/dev-subdomain` · root `C:\Users\kevin\TAO\dev-subdomain` · branch `dev` ·
HEAD `fcd8d393` (P1 recon) · `origin/dev a4b68bad` (WO-6 P0/P1 local/unpushed). Binding spec MD5
`078d926d`. Plan Lock = `DIR-LNK-WO6-PLANLOCK.md` @ `7f354b55` (the P0 lock). Recon of record =
`DIR-LNK-WO6-P1-RECON.md` @ `fcd8d393`.
**Mode:** docs-class design memo. No code, no DDL/DML, no push. **Authorization = P2 only (A-2); P3
authoring is gated on explicit operator approval of THIS memo + the Q1/P2e rulings below.**

---

## 0. ADJUDICATIONS OF RECORD (carried from the P1-ACCEPTED relay)
- **2a create-path:** WO1-RECON §3 stands — `create()` `allowedFields` excludes p/e/c; D-22 narrative
  intact.
- **2b §4b evidence refinement ACCEPTED:** on the current schema the view-insert is functional
  (`is_updatable=YES`; rows land in `contactdetails_tbl`). Defect class = **house-rule violation**
  (writes must target `_tbl`) **+ fragility** (a future non-updatable redefinition turns these into hard
  errors). The historical "silent wizard failure" attribution is **UNVERIFIED-HISTORICAL** — not
  retro-explained; re-verify when wizard paths are next touched.
- **2c merge link-blind:** Q1a = orphaned pointer on the soft-deleted discard; Q1b = silent link loss.
  Both real; both are operator rulings at this gate (spec silent, P0d §1f).
- **2d auth-layer binding:** the new primary write endpoint lives in the **/ajax enforced layer**. Every
  write-capable `/include` path in the inventory carries a **pre-existing-exposure flag** in the matrix
  (§P2a) — reported, not fixed, unless it becomes a WO-6 surface.
- **2e column widths** `contactPhone(100)/contactEmail(150)/contactCompany(255)` pinned as P5d oversize
  targets.

---

## P2a — ENFORCEMENT MATRIX (authoritative P5 negative-test list)
Rows are every surface that can reach p/e/c. "2c-conformant" = single conditional UPDATE keyed on
`contactID + userid + master_co_contact_id IS NULL`, row-count verified, zero-row = reject-no-write.
Layers per recon §3a: `/ajax` = auth+CSRF ENFORCED; `/include` = **no login gate, conditional CSRF**;
`/app` = login gate + CSRF.

| # | Surface / endpoint | Layer | CSRF | Writes | Unlinked | Linked | Section-2c |
|---|---|---|---|---|---|---|---|
| 1 | **NEW** `ajax/contact/update-primary.cfm` (phone/email/company) → **NEW** `ContactService.updatePrimary()` | /ajax | enforced | `contactdetails_tbl` cols + `_src='user'` | **EDIT ALLOWED** | **REJECT** (0 rows) | **YES — built to spec** |
| 2 | **NEW/EXTENDED** create-path primary population (`ContactService.create()` + add-form/wizard callers) | /ajax + /include | mixed | `contactdetails_tbl` p/e/c on create | **POPULATE** (new contacts are unlinked) | n/a (link happens post-create) | N/A (create = unlinked by construction) |
| 3 | Item edit `include/remoteUpdateCUpdate.cfm` → `UPDcontactitems_24178` | /include | none effective | `contactitems` only | ALLOWED | **ALLOWED** (items always editable; §8.2) | N/A (cannot reach columns) — **FLAG: pre-existing auth/CSRF exposure, no userid predicate** |
| 4 | Item add `include/remoteAddCAdd.cfm` → `INScontactitems_24043` | /include | none effective | `contactitems` only | ALLOWED | **ALLOWED** | N/A — **FLAG: pre-existing exposure** |
| 5 | Name/meeting/pronoun edit `include/remoteUpdateNameUpdate.cfm` → `ContactService.update()` | /include | none effective | `contactdetails` cols (name-class only; passes no p/e/c keys) | ALLOWED | ALLOWED | N/A (no p/e/c keys) — **FLAG: shares the unguarded `update()`; must never be handed p/e/c keys** |
| 6 | `ContactService.update()` (the trusted writer) | service | n/a | contactCompany + pointers | — | — | **TRUSTED INTERNAL bypass** (Section 2c-allowed); driver = MasterDirectoryService only; **no client bypass parameter** |
| 7 | Master link/unlink `ajax/master/{link,unlink}.cfm` → MasterDirectoryService | /ajax | enforced | cols via `update()` + one bridge item | — | master-managed writes (expected) | trusted path (bridge live until WO-7) |
| 8 | Merge `app/contact-duplicates/index.cfm` → `mergeContacts` | /app | enforced | items + non-primary cols; **never p/e/c cols** | ALLOWED | link-blind (Q1a/Q1b) | **GUARD to add iff Q1b rules BLOCK** (reject shape, zero writes) |
| 9 | Import V2/V3 finalize (`/ajax/import*`) | /ajax | enforced/self | items only | items only | items only | primary adoption **DEFERRED** (§P2d) |

**P5 negative tests derive from rows 1, 6, 8:** linked-reject on 1 (phone+email+company, contact
`132419`); tenant-isolation on 1 (foreign contactID); bypass-spoof on 1/6 (inject a system/actor flag
→ must not disable the SQL predicate); oversize on 1 (100/150/255). Rows 3-5 are exercised positively
(item edit on linked moves only item panes) and their auth exposure is **reported** (flag), not fixed.

---

## P2b — WRITE-PATH DESIGN

### (i) User primary EDIT (contact page) — the core WO-6 endpoint
New `/ajax/contact/update-primary.cfm` → new `ContactService.updatePrimary(contactid, userid, field,
value)` (or a 3-field struct). Single guarded statement, no read-then-update:
```
UPDATE contactdetails_tbl
SET    <field> = <cfqueryparam ...>, <field>_src = 'user'
WHERE  contactid = <cfqueryparam userid=int>
  AND  userid    = <cfqueryparam int>
  AND  master_co_contact_id IS NULL
```
Then `qResult.recordCount` (or `cfquery result.recordCount`) must equal 1; **0 → reject**
(`{success:false, message:...}`), write nothing (no column, no `_src`, no item, no log, no audit).
`field` is server-whitelisted to `{contactPhone, contactEmail, contactCompany}` (no dynamic column from
client). Endpoint = house `{success, message, data}`, CSRF per `/ajax` convention, idempotent (same
value re-submitted → 1 row, same state).

### (ii) Reject shape + message copy (spec-grounded)
`{ success:false, message:"This contact is linked to the TAO Master Directory. Its primary phone,
email, and company are managed by the directory and can't be edited here — use 'Suggest a correction'
to propose a change.", data:{} }` (grounds: spec §8.1 read-only, §8.3 correction path). Tenant/oversize
rejects return their own messages; all reject paths write nothing.

### (iii) Oversize handling — clean reject, never truncate
Server-side length check **before** the UPDATE against the pinned widths (phone 100 / email 150 /
company 255). Over limit → `{success:false, message:"<Field> exceeds the N-character limit."}`, no
write. (Belt-and-suspenders: `cfsqltype` + width; MySQL `STRICT` also errors rather than truncates, but
we reject explicitly for a clean message.)

### (iv) CREATE-path primary population (D-22 closure) — two options, actual diff sizes
The task: `create()` currently `INSERT INTO contactdetails` (VIEW) at `ContactService.cfc:57` with
`allowedFields :21-39` excluding p/e/c. Two ways to let create populate primaries:

- **Option A — fix create() in place (RECOMMENDED).** (1) swap target `contactdetails` →
  `contactdetails_tbl` at `:57` (**1 line**); (2) add `contactPhone/contactEmail/contactCompany` +
  `contactPhone_src/contactEmail_src/contactCompany_src` to `allowedFields :21-39` (**~6 lines**); (3)
  wire the single primary value captured at create in the add-form/wizard callers to pass those keys
  (caller-side, per surface). **Net service diff ≈ 7 lines**, and it **resolves the house-rule violation
  (2b) in the same touch** for every create() caller (wizard steps 2/3/4). Risk: low — the view is 1:1
  updatable (recon §2), so `_tbl` is where rows already land; behavior is identical except doctrine-correct.
- **Option B — route around.** Leave create() untouched; add `ContactService.setPrimaryOnCreate(contactid,
  userid, {p,e,c})` doing a guarded `_tbl` UPDATE, called right after `create()` in the create callers.
  **New method ≈ 20 lines** + caller wiring; **does NOT fix** the view-write violation (create() still
  writes the VIEW). Larger and leaves the doctrinal debt.

**Memo decision (on evidence): Option A.** Smaller net change, and it discharges the 2b house-rule
violation for the wizard create path at the same time. Scope guard: WO-6 touches only `create()` +
the create callers it needs; the other view-insert creators (V3 `:1557`, inline creators recon §3i) are
**out of WO-6** and remain as-is (their own hygiene WO). New create contacts are unlinked by
construction, so no linked-guard is needed on the create path (matrix row 2).

### (v) Trusted-path integrity
`ContactService.update()` stays the master/link writer (matrix row 6). WO-6 adds **no** client-facing
route into `update()` for p/e/c; the user edit path is the new `updatePrimary()` with the hard-coded
`master_co_contact_id IS NULL` predicate. No system flag / actor-type / bypass token is read from the
client anywhere (Section 2c).

---

## P2c — UI SPEC (contact page)
- **Primary fields block** inserted at `contact_info.cfm:686-722` (recon §5b), replacing the
  item-derived company loop with an editable-vs-read-only p/e/c block:
  - **Unlinked:** three editable fields (phone/email/company); inline save → endpoint (i); per-field
    validation errors; `_src='user'`.
  - **Linked:** three read-only values + master badge **"Managed by the TAO Master Directory"** (spec
    §8.1), reusing the DIR-WO-2 shell already at `:705`; **last-sync line** (UI-2) relocated from
    `:710-712`; **"Suggest a correction"** link (spec §8.3, points to WO-9 — link only, no workflow in
    WO-6). Extend `qMasterLink` SELECT (`:692-693`) to include `contactPhone/contactEmail` (currently
    company-only) so the read-only block can render all three from columns.
- **"Additional information" reframe:** the `contact_pane.cfm` item loops (company `:67-83`, phone
  `:103-113`, email `:115-122`) become the "Additional information" section (spec §4.5/§8.2); reframe
  the "Contact details" tab label `contact_info.cfm:1084` and/or add a heading atop the item grid.
  Items remain add/edit/soft-delete on **any** contact, linked or unlinked (matrix rows 3-4).
- **UI-1/2/3 disposition — all IN** (confirmed confined to the `:686-722` block, lock §6): UI-1 enlarge
  the primary edit affordance (vs the small `mdi-square-edit-outline`); UI-2 last-sync line (reuse
  `:710-712`); UI-3 blank-company placeholder (fills the `:686-688` empty-state gap).

---

## P2d — IMPORT / MERGE PRIMARY ADOPTION (recommendation, DEFER)
Both importers write p/e/c **as items only** today (recon §3f); merge never touches primary columns
(recon §7). **Recommendation: DEFER go-forward primary adoption to a named follow-on (WO-6B, or ride
WO-7).** Rationale + counts of record: importers are the **highest-volume** creation surface (prod
active items Phone 52,326 / Email 44,810 / Company 27,945; dev 952/647/712 — WO1-RECON §5A), so adoption
is a real but separable body keyed per-importer (V2 `:1200/1357/1379`, V3 `:1557/1871/1889/1906`), each
needing its own "designate a primary at import" rule + dedupe interaction. Folding it into WO-6 would
balloon scope and the P5 fixture surface. Until adopted, newly **imported/merged** unlinked contacts
carry blank primary columns (same D-22 class the WO-6 manual create-path closes for add-form/wizard) —
a documented, bounded gap, not a regression. Exact per-importer diff sizing = the follow-on's P1.

---

## P2e — EDIT-LOGGING RULING REQUESTED (A-6; operator rules)
Recon §6: primary-column edits are **not** logged today, and the neighboring contact-detail modals
(`remoteUpdateCUpdate`, `remoteUpdateNameUpdate`) are **also** unlogged — only the generic RPG path
writes `updatelog`. So there is no existing hook to reuse.
- **(i) from-scratch logging on the new endpoint:** add one `UpdateLogService.INSupdatelog(...)` call in
  `updatePrimary()` (read old value inside the same guarded write; decide a `compid`/`recordname`
  convention for contactdetails ~3, confirm `pgcomps`). Small, self-contained; but makes primary edits
  the **only** logged contact-detail edit — inconsistent with its neighbors.
- **(ii) accept-unlogged, consistent with neighboring modals, + a backlog item** for a coherent logging
  pass across ALL contact modals (name/item/primary) in a later WO. Equally clean mechanically; keeps
  the surface consistent.
- **Architect lean = (ii).** Operator rules; no silent default.

---

## P2f — Q1 RULINGS REQUESTED (spec SILENT on all five — P0d §1f; operator rules on facts)
- **Q1a — merge, discard is linked.** Fact (recon §7): the discard's `master_co_contact_id` stays set on
  the soft-deleted row; nothing transfers to keep; no `master_audit_tbl` row; master-sourced Company
  items repoint onto keep (spec rule-4 tension). **Options:** transfer link to keep, or drop with an
  audit trail. Architect input (lock §6): genuinely operator's (two defensible answers).
- **Q1b — merge, both linked to different masters.** Fact (recon §7): merge proceeds blind; keep retains
  master A, discard's master B silently buried, keep inherits discard's master-shaped Company item; no
  warning/audit/prompt. **Architect lean = BLOCK the merge, require deliberate unlink first** —
  implementable as one guard in the `:489-501` pre-flight reading both `master_co_contact_id` values,
  zero writes on reject (Section 2c reject shape). **WO-6 implements this guard iff Q1b rules BLOCK.**
- **Q1c — merge vs a linked KEEP.** Master-managed primaries untouchable; discard's differing values
  preserved as non-primary items (PC-1); PD-1 value-union applies to items only. (Today primaries are
  untouched by merge only by accident of the `applyMergedFields` whitelist, not by guard — recon §7.)
  Implementation lands in merge's owning pass; ruling captured now.
- **Q1d — import rows targeting a linked contact's p/e/c.** Divert to non-primary items + flag in the
  import summary; never write master-managed primaries; WO-9 corrections are the sanctioned change path.
  Lands in the importer's owning pass; ruling captured now.
- **Q1e — unlinked go-forward (= D-22).** Create/edit paths write primaries directly; items additional.
  This IS spec-answered (§2 rules 7-8, §13.1) and is WO-6's core scope (matrix rows 1-2).

**WO-6 build scope = enforcement (rows 1-2) + Q1e + the merge GUARD iff Q1b=BLOCK.** Q1a/Q1c/Q1d
implementations land in their owning WOs (7-9); rulings are captured here so those WOs inherit them.

---

## P2g — STOP
P3 authoring begins only on explicit operator approval of this memo + the P2e ruling + the Q1a-e
rulings (lock A-2). Unchanged holds: no DDL, no DML (outside P5 fixtures), no audit-table writes, no
push without a named PUSH GO. **STOP for architect review.**
