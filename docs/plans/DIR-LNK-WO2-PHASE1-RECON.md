# DIR-LNK-WO-2 — Phase 1 Recon (Schema & Audit Gap Analysis, READ-ONLY)

**Binding:** project TAO-MCD-P1 · series DIR-LNK-WO-1..12 · repo `kevinlawrenceking/dev-subdomain` · root `C:\Users\kevin\TAO\dev-subdomain` · branch `dev`.
**Binding spec:** `docs/plans/TAO_Master_Contact_Linking_Revised_Technical_Specification.md` (MD5 `078d926d…`; governs over any summary). Citations = `spec §N`.
**Mode:** READ-ONLY recon. **No migration authoring, no DDL, no prod writes** (item 3). WO-2 apply itself is HELD pending architect approval of this Phase 1.
**Depends on:** DIR-LNK-WO1-RECON.md (`b28ea134`). Labels: CONFIRMED / INFERRED.

## Missing inputs flagged (not fabricated)
- **R-A1/R-A2** amendment to WO-1 recon: the defining "prior corrected relay" was not received → **1a HALTED**, WO-1 recon unchanged; this WO-2 recon rests on the binding spec + live schema, not WO-1 prose, so it stands regardless, but any R-A1/R-A2 change to WO-1 conclusions should be reconciled here.
- **Full Plan Lock document:** not attached; proceeding on spec-governs + the item-2/item-4 frame.
- **Nine approved action classes:** the Lock approved 9 of the spec §16 thirteen; the enumerated 9 were not provided → audit `action_type` domain is presented as the spec's 13 with the **approved-9 flagged pending** (§A below). No guess.

## Scope guardrails (item 4, in force)
WO-2 = **additive schema + audit + correction structures only**. NO contactitems changes; NO view work (that is WO-5); NO survivorship / per-field-ownership / private-override architecture (spec §5.1, S-4); **prod DDL belongs to WO-12 alone**; dev-apply only, and only after architect approval.

---

## MN. Migration-Numbering Check (CONFIRMED)
- Forward migrations present: `V3_0` … **`V3_10`** (11 files; each with paired `_ROLLBACK.sql`).
- **`V3_11` = burned number.** Never committed to any ref (`git log --all --diff-filter=A -- database/migrations/V3_11*` = empty); never applied to any DB (WO-1 Part B abandoned — imdbid key dead / prod 0 nm-format); evidence: `2026-07-09-dir-wo2-gate0-recon-proof-bundle.md:71` and `-relay-v2-proof-bundle.md:86` ("V3_11 abandoned + dropped, git 12c6c4a6/189700e8"). No `V3_11*` file in tree.
- **Verdict:** V3_11 is technically free (never committed/applied) but is **documented as abandoned** → to avoid record ambiguity, WO-2's first migration should be **`V3_12`** (and `V3_13`, `V3_14`… if multiple objects). Reusing V3_11 is not recommended without an explicit "burned-and-reclaimed" note. **Proposed next number: V3_12.**

---

## Gap Analysis (spec-exhaustive; floor = minimum-verify, not the ceiling)
Columns: spec anchor · dev state · prod state (schema/aggregate class) · gap · proposed structural change · index/constraint impact · rollback · required-now vs deferred.

### G-1. Master-link AUDIT structure — **REQUIRED NOW**
- **spec:** §16 (audit history; 13 conceptual reasons), §9.3 (material change audit), §22 (operational visibility).
- **dev/prod:** `master_audit_tbl` **absent both schemas** (CONFIRMED, information_schema). Existing logs — `updatelog_tbl`, `contact_merge_log`, `ticketslog_tbl`, `error_tickets`/`tickets` (ErrorService) — are merge/update/error logs; **none carries the master-link action taxonomy or old/new-value + actor + reason fields** → spec §16 "otherwise create a dedicated history structure" applies.
- **gap:** no durable, queryable audit for link/backfill/sync/correction/unlink; today only 2 `cflog file="master_link"` lines (`MasterDirectoryService.cfc:221,307`).
- **proposed structural change:** new `master_audit_tbl` (append-only) — conceptual columns per spec §16: `auditID` PK auto_inc, `contactID`, `master_co_contact_id`, `action_type`, `field_name` (nullable), `old_value`, `new_value`, `actor_userid`, `action_timestamp` DATETIME, `reason`, `source_context`, `related_correction_id` (nullable), `related_sync_run_id` (nullable), `idempotency_key`. Follow house `_tbl` convention; a read view is optional (audit is append-only; defer view to WO-5-class if any list surface needs it).
- **`action_type` domain (spec §16 = 13; Lock approved 9 — ENUMERATION PENDING):** `BACKFILL_FROM_CONTACTITEM, LINK_CREATED, PRELINK_VALUE_PRESERVED, MASTER_SNAPSHOT_POPULATED, MASTER_AUTO_UPDATE, CORRECTION_SUBMITTED, CORRECTION_APPROVED, CORRECTION_REJECTED, BAD_MATCH_REMOVED, MASTER_RELINKED, PRELINK_VALUE_RESTORED, PRIMARY_FIELD_CLEARED_AFTER_UNLINK, ADMIN_REPAIR`. **Store `action_type` as `varchar` (not a DB `enum`) so the approved-9 vs spec-13 question is validated in the service layer, not baked into DDL** — this de-risks the missing enumeration and avoids a schema change if the set is later revised. (If the architect wants a hard DB constraint, supply the 9.)
- **index/constraint:** `KEY(contactID)`, `KEY(master_co_contact_id)`, `KEY(action_type)`, `KEY(action_timestamp)`; **UNIQUE(`idempotency_key`)** for spec §17 audit-dedup. InnoDB, DATETIME (house convention, not TIMESTAMP).
- **rollback:** `DROP TABLE master_audit_tbl` (empty at creation → clean); idempotent guarded create (`information_schema` check).
- **required-now:** YES (all later WOs write to it).

### G-2. CORRECTION-REQUEST table — **REQUIRED NOW**
- **spec:** §8.3 (fields), §10.2 (statuses), §10.5 (dedup).
- **dev/prod:** **no correction/request table exists** (CONFIRMED). OQ-2.
- **gap:** WO-9 correction workflow has no store.
- **proposed structural change:** new `master_correction_requests_tbl` — `correctionID` PK, `contactID`, `master_co_contact_id`, `field_name`, `current_master_value`, `suggested_value`, `explanation`, `requesting_userid`, `request_timestamp` DATETIME, `status`, `reviewer_userid` (nullable), `resolution` (nullable), `resolution_timestamp` (nullable). `status` domain per §10.2: Pending/Approved/Rejected/Needs clarification/Superseded/Withdrawn (varchar + service validation, same rationale as G-1).
- **index/constraint:** `KEY(master_co_contact_id, field_name)`, `KEY(status)`; **dedup (spec §10.5):** UNIQUE on (`master_co_contact_id`,`field_name`,`normalized_suggested_value`,`status='Pending'`) — MySQL has no partial unique index, so implement as UNIQUE(`master_co_contact_id`,`field_name`,`normalized_suggested_value`,`dedup_guard`) where `dedup_guard` mirrors the active-guard pattern already used on `fusystemusers_tbl` (role-doc: `uq_active_enrollment` active_guard) — i.e. a generated/maintained column that frees on non-Pending. **Flag:** confirm this pattern at WO-2 authoring; store a `normalized_suggested_value` column fed by the shared normalizer (§18).
- **rollback:** `DROP TABLE` (empty → clean).
- **required-now:** YES (schema must exist before WO-9; harmless to create early).

### G-3. Single-active-link enforcement / idempotency — **REVISED (likely NO new constraint)**
- **spec:** §17 (idempotent link; no partial state; no duplicate preserved items).
- **dev state:** the link IS a set of columns on `contactdetails_tbl`, which is **one row per contact** (PK `contactID`) → a contact **structurally cannot hold two active links**. So a separate "single-active-link uniqueness constraint" is **unnecessary** (WO-1's mention re-scoped).
- **gap:** the real idempotency needs are (a) audit dedup — covered by G-1 `idempotency_key`; (b) correction dedup — covered by G-2; (c) link operation atomicity/idempotency — that is **WO-7 transaction logic, not schema**.
- **proposed change:** none required now; **DEFERRED** (re-confirm at WO-7). Optional `master_linked` boolean status flag (§5) — see G-4.
- **rollback / required-now:** n/a / deferred.

### G-4. Link-status flag + master-version stamp (spec §5) — **DEFERRED (optional)**
- **dev:** no dedicated link-status column; status derivable from `master_co_contact_id IS NOT NULL` (CONFIRMED). No master-version/modified stamp; `master_last_sync` exists.
- **gap:** minor; a `master_link_status` enum or `master_version` int would only aid sync (WO-8) staleness (N-1).
- **proposed change:** OPTIONAL `master_version`/`master_modified` on the master person or a sync-cursor — **DEFERRED to WO-8 design** (only add if WO-8 proves it needed for stale-write guards; §9.4). Link-status flag: DEFERRED (inference suffices).
- **required-now:** NO.

### G-5. Office pointer for PC-1 phone/email — **ALREADY PRESENT (no change)**
- **spec:** §7.4 snapshot; PC-1 ruling (office-level phone/email).
- **dev:** `contactdetails_tbl.company_location_id` (col 40) + FK `fk_cd_company_location→co_locations.colocid` already exist (CONFIRMED, WO-1 §1.1/1.2). `co_locations.phone/email` are the source.
- **gap:** none structurally. Residual DATA check (not schema): office phone/email population in `co_locations` (quantify at WO-3 for §7.5 blank-master exposure).
- **required-now:** NO schema change.

### G-6. Normalization support (spec §18) — **CODE, not schema (note)**
- Centralized normalizer (phone digits, email lower/trim, company stable-ID/whitespace) is a **service** used by backfill/link/preserve/dedup/sync/correction/cleanup. Not a WO-2 schema object, but WO-2's correction dedup (G-2 `normalized_suggested_value`) depends on it → **build the normalizer as a shared CFC at WO-2/WO-3**; only the persisted `normalized_*` columns are schema. Flag for the plan.

---

## Existing-mechanism assessment (spec §16 "use existing if it fully supports")
`updatelog_tbl` (generic field-change log) and `contact_merge_log` are the closest existing patterns, but neither models the master-link action taxonomy, actor+reason, or correction/sync linkage → **dedicated `master_audit_tbl` is required** (spec §16 "otherwise"). Mirror the house `_tbl` + (optional) view + idempotency-guard conventions already used by `fusystemusers_tbl`.

## Required-now vs deferred (summary)
- **Required now (WO-2 apply, dev, on approval):** G-1 audit table, G-2 correction table (+ their indexes/guards), the shared normalizer scaffold for G-2's normalized column.
- **Deferred:** G-3 (no constraint; re-confirm WO-7), G-4 (link-status/version → WO-8 if proven), G-5 (already present), view/read surfaces (WO-5).

## Register notes (item 4) satisfied
Nine approved action classes → G-1 (enumeration pending; varchar de-risks). No contactitems changes. No view work (WO-5). No survivorship/private-override (S-4). Prod DDL = WO-12 only. Migration numbering = V3_12 next (V3_11 burned).

## STOP — Phase 1 recon delivered
Read-only. No migration authored, no DDL, no prod writes. WO-3/WO-4 held per the Lock. **Awaiting architect approval of Phase 1 + the three flagged inputs (R-A1/R-A2, Plan Lock text, the enumerated nine action classes) before WO-2 migration authoring.**
