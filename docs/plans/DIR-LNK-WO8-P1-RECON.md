# DIR-LNK-WO-8 — P1 RECON (read-only)

**Work order:** DIR-LNK-WO-8 (master auto-sync for linked contacts).
**Branch:** dev · **Project:** TAO-MCD-P1 · **Spec MD5:** 078d926d.
**P0a binding:** repo root `C:\Users\kevin\TAO\dev-subdomain`, branch dev, clean tree, origin/dev HEAD `05b20a16` (WO-7 close). PASS.
**Status:** P1 read-only recon COMPLETE. **STOP for operator** (P2 design memo + rulings open only after this).
**Method:** static code read (services/, include/, ajax/, sched/) + read-only DB probe against `new_development` (channel per `reference_mysql_db_channel`; SELECT/SHOW whitelist; two probe scripts in scratchpad).

---

## 0. Headline (read this first)

Two evidence-backed findings reshape the WO before any trigger is chosen:

1. **Master data is STATIC, seed-imported reference data.** There is **zero** application write path to `co_contacts` / `co_locations` / `companies` anywhere in TAO. It was populated once by a hand-run prod→dev SQL copy; there is no editor UI. **Ongoing-sync value is low today** — an event/scheduled sync would be reacting to changes that can currently only arrive via an out-of-band DB reseed. This is exactly the Section 7 sequencing note, now proven. The spec's §9.4 "preferred event-driven" architecture has nothing to hook.

2. **The first-run backfill (Q6) as framed does not fit the data.** Of 16 linked contacts, only **3** carry a full WO-7 snapshot (all three `_src='master'`), and **all 3 are already current** — the sync is a no-op on them. The other **13** are legacy/bridge/partial links whose email/phone (and half their company) fields are **`_src='user'`** and carry stale or user-typed values that diverge from the master. WO-8's core guard — *never write a field whose `_src='user'`* — means **drift among the fields WO-8 may touch is exactly zero** (0 company / 0 email / 0 phone drift). A silent `_src='master'`-guarded sync therefore has **nothing to backfill today**, and it **cannot** bring the 13 bridge links current without overwriting user-owned values (which would need the WO-7 preservation pass, i.e. a re-link, not a silent sync). **Q10 needs an operator ruling on what "backfill" means here** (§7 below).

Everything else (derivation soundness, audit substrate, scheduler reachability, read-path) is clean and ready. Details follow per P1 item.

---

## P1a — Master-data volatility: **STATIC imported reference data**

- Regex sweep `(INSERT INTO|REPLACE INTO|UPDATE|DELETE FROM) (co_contacts|co_locations|companies)` across every `.cfm`/`.cfc` → **no matches**. Every live reference is a `SELECT`.
- Read-only consumers only: `MasterDirectoryService.cfc` (search/resolve/validate — hint states it "Never writes" master tables), `include/master_link_preview.cfm:50-52`, `include/contact_info.cfm:659-670`.
- Population was a **manual bulk copy**: `docs/plans/evidence/2026-07-07-seed-dev-master-tables.sql` (`INSERT INTO new_development.co_locations SELECT * FROM actorsbusinessoffice.co_locations`, same for co_contacts; header notes prod 25,200 persons / 12,617 offices / 10,740 companies). Operator-run, not an app feature.
- **No "Book"/master editor UI** anywhere (admin/, tools/, scripts/ grep empty). `sched/import-contacts.cfm` imports into *user* contacts, not master tables.
- Schema corroborates scraped/imported origin: `co_contacts` carries `imdbid, starmeter, page_url, image_url, name_url`; `co_locations` carries `page_url, page_title, current_time` — IMDbPro-scrape artifacts, not hand-maintained columns.
- **Sizing:** co_contacts **25,200**, co_locations **12,617**, companies **10,740** (dev == prod per the seed header).

**Conclusion:** master data is not actively edited in TAO. Future volatility would arrive via (a) a re-import/reseed, or (b) the not-yet-built DIR-CRUD master-edit funnel — both out-of-band today. This is the pivotal input to the trigger choice (P2b/Q8) and to the honest-v1 sequencing (§7).

---

## P1b — Change markers on the master tables: **none usable for all three fields**

| Table | Timestamp column | `ON UPDATE`? | Usable as edit marker? |
|---|---|---|---|
| `co_contacts` | `timestamp` (DEFAULT CURRENT_TIMESTAMP, DEFAULT_GENERATED) | **No** | No — insert-time only |
| `co_locations` | `timestamp` (DEFAULT CURRENT_TIMESTAMP, DEFAULT_GENERATED) | **No** | No — insert-time only |
| `companies` | `coUpdateDate` (timestamp) | **Yes** (`on update CURRENT_TIMESTAMP`) | Partial — company name only |

Email and phone derive from `co_locations` (**no** update marker); company from `companies` (has one). No version/rowversion column exists. **Value-comparison is the only detector that covers all three fields.** This also independently sidesteps the registered N-1 one-second-granularity trap (WO-8 never consults a timestamp to decide "changed"). Confirmed — matches the lock's Section 2c premise.

---

## P1c — Scheduler: **the shim already exists (lock assumption refuted)**

- No `cfschedule` tags anywhere. Scheduling is external: CF-Admin tasks hit `/sched/*.cfm` (`sched/README_SCHEDTASK.md:9,34-36`; nightly exemplar `sched/ics-reconcile-nightly.cfm`; ~140 batch files in `sched/`).
- **A scheduled context reaches the service layer today, no shim to build.** `sched/Application.cfc:2-8` overrides `onRequestStart` to call `initServiceFactory()` first; `:11-16` admits localhost/same-server (the scheduler) without a session. The inherited `app/Application.cfc:249-267` defines `request.svc = function(name){...}` (extracted precisely so `sched/` can invoke it directly). **Working precedent:** `sched/admin-calendar-cleanup.cfm:124` already calls `request.svc("EventService").fireIcsRegen(...)`.
- Datasource: services use bare-cfquery default (`abod`/dev); `sched/Application.cfc:14,24` sets it.

**Conclusion:** the lock's "request.svc scheduler shim registered as a known gap — must WO-8 build it?" is **answered: it is already built.** Model (iii) scheduled is therefore *viable without new infrastructure* — but its *value* is low while master data is static (P1a). Whether CF-Admin scheduling is enabled on the Hostek **dev** box (prod uses it per the README) is the only open sub-question, and it only matters if the operator elects (iii).

---

## P1d — DIR-CRUD dependency: **funnel not built; no hard dependency**

- No `MasterCrudService`, no `E10`, no `ajax/master/` endpoint writes to the master tables. `ajax/master/` = `search.cfm`, `locations.cfm` (reads), `link-confirm.cfm`, `unlink.cfm` (contact-side writes), `link.cfm` (RETIRED, guarded rejection).
- The audit substrate is **pre-provisioned for WO-8**: `MasterAuditService.cfc:12` reserves `MASTER_AUTO_UPDATE` (+ `CORRECTION_*`, `BAD_MATCH_REMOVED`, `ADMIN_REPAIR`) but **no caller emits them** — grep finds `MASTER_AUTO_UPDATE` only in the vocabulary string. WO-8 is the first activator.

**Conclusion:** value-comparison sync consumes **no** change stream, so it has **no hard dependency on DIR-CRUD**. (iv) change-driven is not viable now (no funnel to emit events). **Sequencing implication for the operator:** WO-8 can proceed now as backfill + on-demand/on-read, independent of DIR-CRUD; a change-driven trigger only becomes worthwhile once DIR-CRUD makes master editing real and audited.

---

## P1e — The linked set: **16 contacts; only 3 are full snapshots; drift = 0 within scope**

`SELECT COUNT(*) ... master_co_contact_id IS NOT NULL AND (isdeleted=0 OR NULL)` → **16** linked.

Per-field `_src` breakdown (of the 16):

| Field | `_src='master'` | `_src='user'` | other |
|---|---|---|---|
| contactCompany | **8** | 8 | 0 |
| contactEmail | **3** | 13 | 0 |
| contactPhone | **3** | 13 | 0 |

(`_src` is `ENUM NOT NULL DEFAULT 'user'` — never NULL; the "other" bucket is 0 by construction.)

- **3 full WO-7 snapshots** (all three `_src='master'`): **131252** (Cut Entertainment Group), **132142** (Frontline Management), **132247** (Caviar Content). All three stored values equal their live derivation → **sync no-op** (natural fixtures for acceptance criterion b).
- **13 legacy/bridge/partial links**: pointer set, but email/phone `_src='user'` (and 8 of them company `_src='user'`), carrying stale or user-typed/test values (e.g. 128621 stored company "Acme Company" vs master "New Regency Productions"; 131080 "Sydney to the Max" vs "Apatow Productions"; 132437 "Acme" vs "INVAR Studios"). These are the "bridge-era" links — but their divergent fields are **user-owned**, so WO-8's guard forbids touching them.
- The 5 rows that are company-`master` but email/phone-`user` (131075, 131171, 131949, 132097, 132436) look like **legacy `linkContactToMaster`** links: that path writes only `contactCompany` (`_src='master'`) and never phone/email (PD-L1), leaving them `_src='user'`.
- **Anomaly check:** 0 rows with any `_src='master'` and a NULL `master_co_contact_id` — no orphaned managed provenance. Global `_src='master'` counts (all active contacts) = company 8 / email 3 / phone 3, i.e. **identical** to the linked-set counts (every managed field has a live link).

**Drift summary (only `_src='master'` fields — WO-8's writable scope):**

| orphan (no master person) | company drift | email drift | phone drift | email blank-office | phone blank-office |
|---|---|---|---|---|---|
| 0 | **0** | **0** | **0** | 0 | 0 |

**Every field WO-8 may write is already current.** The first-run backfill, scoped to `_src='master'`, is a total no-op against today's data.

---

## P1f — Derivation proof: **sound for all 16; no orphans**

`master_co_contact_id` + `company_location_id` re-derive all three columns for every linked contact:
- company ← `co_contacts ⋈ companies.coName`; email/phone ← `co_locations` (by `colocid` AND `coid`).
- **All 16** resolve a live master person (`cc.id IS NOT NULL` = 1 for every row) — **0 orphans**.
- For every `_src='master'` field, stored value == derived value (drift table above, all zeros) — the derivation reproduces the stored value exactly.
- Edge: 102009 (master 40, `company_location_id` NULL) derives blank company/email/phone (no office; master person's company row absent) — consistent, and its fields are `_src='user'` NULL anyway.

**Conclusion:** the derivation is sufficient and faithful. No stored-value-without-live-source finding. The re-derive/compare engine will behave predictably.

---

## P1g — Read-path surface: **one panel anchor; list via view**

- **Contact detail panel** — `include/contact_info.cfm`: `qMasterLink` at `:656-658` already selects `contactCompany/_src`, `contactPhone/_src`, `contactEmail/_src`, **and `master_last_sync`**; `:686` computes `masterIsSynced`; `:834-836` renders the three primary rows. **This is the single natural on-read hook (i) anchor** — it already loads everything a sync needs.
- **Link preview modal** — `include/master_link_preview.cfm` (renders current vs master).
- **Service getter** — `ContactService.cfc:113-118`.
- **Company-column reader** — `include/qry/find_new_Company_115_6.cfm:10-14` (WO-7 S-2 repoint).
- **List/search:** `contacts_ss.cfm` / `ContactSSService.cfc` do **not name** the three columns — BUT `contacts_ss` is a `SELECT *` **view** (WO-7 criterion k proved linked values surface there immediately), so **stored-column staleness is visible in the list via the view** even though the `.cfm` doesn't render them explicitly. Exports: none read these columns.

**Bearing on the trigger:** an on-read (i) hook attaches cleanly at one place (the panel), but because the list surfaces the stored column through the view, a purely on-read sync leaves the **list** row stale until the panel is opened — which strengthens the case for pairing (i) with (ii) an on-demand admin re-sync (matches the architect lean).

---

## Cross-cutting findings for the P2 design (carry into the memo)

- **F-1 (reuse is the derivation, not the writer).** `ContactService.writeLinkSnapshot` (`:395-412`) stamps **all three** `_src='master'` *unconditionally* and rewrites the master pointers + `master_linked_date`. Reusing it verbatim for sync would **stomp** any `_src='user'` field back to master — violating WO-8's core guard. **WO-8 must reuse the derivation (`qMaster` + `qLoc` from `MasterDirectoryService`) and write through a NEW per-field, `_src='master'`-guarded conditional UPDATE** (compare-then-write, only the differing fields, only where `_src='master'`). Section 2b's "writeLinkSnapshot run again" is imprecise on this point — the memo should state the guarded-writer design explicitly.
- **F-2 (audit key needs an event discriminator — the S-9 lesson).** `MasterAuditService.record()` INSERT-IGNOREs on `idempotency_key` and returns 0 silently on a collision (post-Fix-1b). A `MASTER_AUTO_UPDATE` key built only from `contactid+field` would silently drop the audit row on a second genuine change. The key must carry a discriminator — the natural choices are the audit epoch (`MAX(auditID)`, as confirmLink/unlink do) and/or the `run_id` column (present, unused) and/or the new value. Design at P2a; do not repeat S-9.
- **F-3 (epoch integrity — criterion g).** The link/unlink epoch is pre-mutation `COALESCE(MAX(auditID),0)` per contact. `MASTER_AUTO_UPDATE` rows only **raise** `MAX(auditID)` monotonically, so a subsequent link/unlink reads a strictly higher epoch — no collision, no regression. Baseline `MAX(auditID)=216`, 193 rows. The new high-volume writer does not disturb the epoch mechanism, but P5 (g) must prove it with a relink+double-unlink regression after sync writes.
- **F-4 (blank-resolves is demonstrable but needs a built fixture).** 2,870/12,617 offices have blank phone, 4,422 blank email — the Q12 case is realistic. But **no current linked contact sits on a blank-office `_src='master'` field** (blank-office drift = 0). Criterion (c) at P5 will require constructing a fixture: link to a blank-email office (Q4 mirror → email NULL `_src='master'`), populate that office's email, then sync fills it.
- **F-5 (material vs non-material).** Value-comparison (byte/trim/case) does not distinguish §9.3 material from non-material changes; it writes+audits any real difference. Spec §9.3 says non-material "may synchronize silently" — WO-8 auditing them too is *safe* (more audit, never less). The memo should state WO-8 audits every write uniformly and does not implement a material/non-material classifier (no requirement to).

---

## Spec extraction (P0d) — governing anchors, verbatim

- **§7.5 (blank mirror) — governs Q9.** "The expected default is that linked primary fields mirror the master, including blank master fields. Any exception to this rule requires an explicit product escalation." → **Q9 option (a) mirror-and-audit IS the spec default; option (b) keep-and-flip-to-`user` is the exception requiring product escalation.** §7.5 also (`:367`) requires CC to "identify whether blanking the primary field creates downstream usability issues" — the hook the operator may use to *invoke* the escalation. Architect lean (a) aligns with the default.
- **§9.1 (governing rule).** "When the master changes: Linked user-contact snapshots update automatically. No user acceptance is required. Additional `contactitems` remain untouched. Changes are logged." → sync is automatic + silent + audited; no modal. Confirms Q12 and the "no user acceptance" posture.
- **§9.2 (scope).** "At minimum: Primary phone, email, company. ... Do not expand synchronization beyond approved scope without escalation." → exactly the three columns. Name is **not** synced (WO-7 dropped the name picker; `contactFullName_src` absent) → **Q13 non-sync of photo/address/IMDB ratified**, and name stays user-owned.
- **§9.3 (material/non-material).** material = "Different phone digits / email / company identity / **Field becoming blank** / **Field becoming populated**" → "synchronize automatically ... should create an audit or activity record." Directly authorizes Q12 (becoming populated) and Q9 (becoming blank) as audited auto-syncs.
- **§9.4 (mechanism) — governs Q8.** "Claude Project should require recon and recommend the safest mechanism ... Preferred architecture: Immediate/event-driven update for affected linked contacts + Scheduled reconciliation to repair missed events." → the spec *prefers* event+scheduled, **but explicitly conditions the choice on recon + "safest mechanism."** Given P1a (static data) + P1d (no funnel), the safest mechanism today is backfill + on-demand + on-read; event/scheduled are deferred until master editing is real. The recon *is* the escalation §9.4 asks for.
- **§9.5 (visibility).** "Routine master updates should not require modal approval. ... Avoid noisy email notifications." → optional passive "Updated from Master Directory" indicator only.
- **§17 (concurrency).** "Master synchronization must use stale-write guards. A user adding an additional item must not be lost during synchronization. Retry operations must be idempotent. ... avoid duplicate audit events for the same idempotency key." → the guarded conditional UPDATE (keyed contactid+userid+isdeleted) is the stale-write guard; `contactitems` are never touched by sync (F-1 writer only touches the three columns); F-2 satisfies the idempotency-key rule.
- **§8.3 / §10 (correction).** the "Suggest a correction" path (WO-9) is the user's recourse for a value they believe wrong — relevant if Q9 picks (a) and a user wants a silently-blanked field restored.

**Silences routed to P2 operator rulings:** the material/non-material *silent* distinction (§9.3) — WO-8 audits uniformly (F-5); the Q9 populated→blank choice (§7.5 defaults to (a) but invites escalation); the Q8 mechanism (§9.4 defers to this recon).

---

## What P1 did NOT do (scope discipline)

Read-only only: no DDL, no DML, no writes, no fixtures, no commits beyond this docs deliverable + the P0b lock. Prod untouched (probe hit `new_development` only, SELECT/SHOW whitelist). No trigger chosen, no engine authored — those are P2 (design/rulings) and P3 (authoring), each gated.

---

## STOP — P1 gate

Recon complete and evidence-cited. **The two headline findings (static master data; the bridge-backfill/`_src='user'` tension) should be in front of the operator before P2 rulings.** On operator direction, P2 produces `DIR-LNK-WO8-P2-DESIGN.md` (sync-engine + guarded-writer design per F-1/F-2, trigger recommendation against this recon, first-run-backfill redefinition, and the Q8–Q13 rulings sheet), then STOPs again for approval before any P3 authoring.
