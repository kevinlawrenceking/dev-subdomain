# DIR-LNK-WO-2 — Phase 4 Proof Bundle (Dev Apply Verification)

**Date:** 2026-07-14
**Binding:** project TAO-MCD-P1 · series DIR-LNK-WO-1..12 · repo `kevinlawrenceking/dev-subdomain` · root `C:\Users\kevin\TAO\dev-subdomain` · branch `dev`.
**Binding spec:** `docs/plans/TAO_Master_Contact_Linking_Revised_Technical_Specification.md` (MD5 `078d926d…`; governs).
**Scope:** DIR-LNK-WO-2 = **additive schema + audit + correction structures only**, **dev-apply only**. Prod DDL belongs to WO-12 alone (spec/Lock guardrail). This bundle proves the dev apply; it makes **no prod-parity claim**.
**Migration under proof:** `V3_12__master_directory_wo2_audit_correction.sql` (+ two-stage rollback), committed `1efce776`.
**Depends on:** `docs/plans/DIR-LNK-WO2-PHASE1-RECON.md` (`cca0f663`); WO-1 recon (`b28ea134`).

---

## 0. Executive result

**PASS.** Both WO-2 base tables were applied to `new_development` only; live read-channel verification confirms the deployed structure conforms in full to the reviewed DDL (`1efce776`). Re-run idempotency, the full rollback→recreate cycle, and the correction-dedup guard were all exercised on dev and proved empirically. `actorsbusinessoffice` (prod) carries **zero** WO-2 objects — the dev-only delta is intact, awaiting WO-12. No prod writes occurred; the verification channel is read-only.

| # | Acceptance criterion (derived from runbook steps 3–6 + migration verification block + WO-2 scope guardrail) | Result | Evidence |
|---|---|---|---|
| AC-1 | Both base tables exist on `new_development` (structure verification, step 3) | **PASS** | §3, probe L7–12 |
| AC-2 | Deployed DDL conforms verbatim to reviewed migration `1efce776` | **PASS** | §2 / §4, probe L14–43, L58–83 |
| AC-3 | All indexes + unique constraints present as specified | **PASS** | §5, probe L48–56, L88–98 |
| AC-4 | `active_guard` STORED generated column defined per spec (PENDING/NEEDS_CLARIFICATION → 1 ELSE NULL) | **PASS** | §5, probe L76, L100–102 |
| AC-5 | Forward migration is replay-safe (re-run = no-op, `IF NOT EXISTS`, step 4) | **PASS** | §6 (operator Run 2: Note 1050 ×2, 0 errors) |
| AC-6 | Two-stage rollback proven loss-free, then forward recreate proven (step 5) | **PASS** | §7 (precheck 0/0 → destructive drop → COUNT 0 → recreate → COUNT 2) |
| AC-7 | Correction dedup constraint empirically enforced (2nd identical active insert → 1062, step 6) | **PASS** | §8 (Exec 2 → SQL 1062 on `UQ_mcr_active_dedup`) |
| AC-8 | Dev-only delta: prod has zero WO-2 objects; no dev↔prod parity claimed | **PASS** | §9, probe L104–110 |
| AC-9 | Append-only/lifecycle tables land empty (zero data rows) | **PASS** | §10, probe L45–46, L85–86 (both COUNT=0) |
| AC-10 | Prod verification channel read-only; no prod DDL/DML | **PASS** | §9, probe L112 ("all statements were SELECT/SHOW/USE only") |

No criterion is FAIL or partial.

---

## 1. Files under proof

| File | MD5 | Committed |
|---|---|---|
| `database/migrations/V3_12__master_directory_wo2_audit_correction.sql` | `526a38f32fcb025575c70340b64a7e08` | `1efce776` |
| `database/migrations/V3_12__master_directory_wo2_audit_correction_ROLLBACK.sql` | `d99c18537addfb1780253db466415da6` | `1efce776` |
| `database/migrations/V3_12__master_directory_wo2_audit_correction_ROLLBACK_DESTRUCTIVE.sql` | `c56e74e10d98f78f51f56c812a52e284` | `1efce776` |
| `docs/plans/evidence/2026-07-14-dir-lnk-wo2-phase4-live-probe-output.txt` | (this bundle) | (committed with this bundle) |

Working-tree integrity: `git diff -- database/migrations/` is **empty** and the three V3_12 files show **no diff vs committed `1efce776`** — settles operator paste item 5: the tracked migration files are unmodified; the "comment-strip" happened only in the HeidiSQL query buffer, never in the repo file. Working tree on `database/migrations/` is **clean**.

---

## 2. BEFORE / AFTER schema

**BEFORE (Phase-1 recon, read-only, `cca0f663`):** both `master_audit_tbl` and `master_correction_requests_tbl` were **absent from both schemas** (`information_schema` confirmed — recon G-1 / G-2). No correction/request store existed; the only master-link trace was two `cflog file="master_link"` lines in `MasterDirectoryService.cfc`.

**AFTER (this apply, `new_development` only):** both base tables exist with the reviewed structure; both are empty of production data.

| Object | Before (dev) | Before (prod) | After (dev) | After (prod) |
|---|---|---|---|---|
| `master_audit_tbl` | absent | absent | **present**, 0 rows | **absent** (WO-12) |
| `master_correction_requests_tbl` | absent | absent | **present**, 0 rows | **absent** (WO-12) |

The prod column is unchanged by design — WO-2 is dev-apply only.

---

## 3. Structure verification (runbook step 3)

Live read channel, connection identity `kingk436@%` · MySQL `8.0.41` · `2026-07-14 11:20:28` (probe L2–3).

```
===== DEV: table presence (expect 2) =====
2

===== DEV: table metadata (engine / collation / rows / auto_inc) =====
master_audit_tbl               | InnoDB | utf8mb4_unicode_ci | 0 |
master_correction_requests_tbl | InnoDB | utf8mb4_unicode_ci | 0 | 3
```

Both tables InnoDB / `utf8mb4_unicode_ci` (house convention), 0 rows. `information_schema` table count = **2** — matches the migration's own verification block (expect 2). The `AUTO_INCREMENT=3` residue on the correction table is explained and dispositioned in §10/§11 (benign; counter monotonicity from the guard test, not live data).

---

## 4. Verbatim DDL (as deployed on dev — SHOW CREATE)

The live `SHOW CREATE TABLE` output (probe L14–43 and L58–83) is reproduced verbatim below. It matches `V3_12__…sql` (`1efce776`, MD5 `526a38f3…`) field-for-field: column set, widths, `DATETIME(3)` ms precision, `varchar(500)` value columns, the `active_guard` STORED expression, and every key.

**master_audit_tbl:**
```sql
CREATE TABLE `master_audit_tbl` (
  `auditID` bigint NOT NULL AUTO_INCREMENT,
  `contactID` int NOT NULL,
  `actor_userid` int DEFAULT NULL,
  `actor_type` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL,
  `master_co_contact_id` int DEFAULT NULL,
  `master_coid` int DEFAULT NULL,
  `company_location_id` int DEFAULT NULL,
  `action_type` varchar(40) COLLATE utf8mb4_unicode_ci NOT NULL,
  `field_name` varchar(40) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `old_value` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `new_value` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `previous_source` varchar(10) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `new_source` varchar(10) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `correction_request_id` int DEFAULT NULL,
  `run_id` varchar(64) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `idempotency_key` varchar(191) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `reason` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `metadata` json DEFAULT NULL,
  `created_at` datetime(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  PRIMARY KEY (`auditID`),
  UNIQUE KEY `UQ_master_audit_idem` (`idempotency_key`),
  KEY `IX_master_audit_contact` (`contactID`),
  KEY `IX_master_audit_master_person` (`master_co_contact_id`),
  KEY `IX_master_audit_action` (`action_type`),
  KEY `IX_master_audit_created` (`created_at`),
  KEY `IX_master_audit_correction` (`correction_request_id`),
  KEY `IX_master_audit_run` (`run_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
```

**master_correction_requests_tbl:**
```sql
CREATE TABLE `master_correction_requests_tbl` (
  `correctionID` int NOT NULL AUTO_INCREMENT,
  `contactID` int NOT NULL,
  `master_co_contact_id` int NOT NULL,
  `field_name` varchar(40) COLLATE utf8mb4_unicode_ci NOT NULL,
  `current_master_value` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `suggested_value` varchar(500) COLLATE utf8mb4_unicode_ci NOT NULL,
  `normalized_suggested_value` varchar(500) COLLATE utf8mb4_unicode_ci NOT NULL,
  `explanation` varchar(1000) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `requesting_userid` int NOT NULL,
  `request_timestamp` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `status` varchar(24) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'PENDING',
  `reviewer_userid` int DEFAULT NULL,
  `resolution_notes` varchar(1000) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `resolved_timestamp` datetime DEFAULT NULL,
  `applied_timestamp` datetime DEFAULT NULL,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `active_guard` tinyint GENERATED ALWAYS AS ((case when (`status` in (_utf8mb4'PENDING',_utf8mb4'NEEDS_CLARIFICATION')) then 1 else NULL end)) STORED,
  PRIMARY KEY (`correctionID`),
  UNIQUE KEY `UQ_mcr_active_dedup` (`master_co_contact_id`,`field_name`,`normalized_suggested_value`,`active_guard`),
  KEY `IX_mcr_master_field` (`master_co_contact_id`,`field_name`),
  KEY `IX_mcr_status` (`status`),
  KEY `IX_mcr_contact` (`contactID`),
  KEY `IX_mcr_requester` (`requesting_userid`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
```

---

## 5. Index / constraint evidence (runbook step 3, `information_schema.statistics`)

**master_audit_tbl** — 6 secondary indexes + PK + idempotency unique (probe L48–56):

```
IX_master_audit_action        | action_type
IX_master_audit_contact       | contactID
IX_master_audit_correction    | correction_request_id  (nullable)
IX_master_audit_created       | created_at
IX_master_audit_master_person | master_co_contact_id   (nullable)
IX_master_audit_run           | run_id                 (nullable)
PRIMARY                       | auditID
UQ_master_audit_idem          | idempotency_key        (UNIQUE; NULL-distinct → dedup only when key supplied)
```

**master_correction_requests_tbl** — 4 secondary indexes + PK + 4-column active-dedup unique (probe L88–98):

```
IX_mcr_contact       | contactID
IX_mcr_master_field  | master_co_contact_id, field_name   (composite, seq 1..2)
IX_mcr_requester     | requesting_userid
IX_mcr_status        | status
PRIMARY              | correctionID
UQ_mcr_active_dedup  | master_co_contact_id, field_name, normalized_suggested_value, active_guard  (composite, seq 1..4)
```

**active_guard generated column** (probe L100–102) — deployed expression matches the reviewed DDL exactly, and mirrors the established `fusystemusers_tbl.active_guard` house pattern:

```
master_correction_requests_tbl | active_guard | tinyint |
  (case when (`status` in (_utf8mb4'PENDING',_utf8mb4'NEEDS_CLARIFICATION')) then 1 else NULL end) | STORED GENERATED
```

The guard resolves to `1` while a request is active and to `NULL` on any terminal status; because MySQL treats `NULL` as distinct in a unique index, terminal requests fall out of `UQ_mcr_active_dedup` and never collide — exactly the spec §10.5 dedup semantics.

---

## 6. Re-run idempotency proof (runbook step 4)

Operator forward-apply **Run 1** (full commented file from `1efce776`): parsed as 3 statements, `Duration 0.438 sec`, `Affected rows: 0` (DDL), no errors.

Operator forward-apply **Run 2** (re-ran believing Run 1 failed):
```
Note 1050  Table 'master_audit_tbl' already exists
Note 1050  Table 'master_correction_requests_tbl' already exists
2 queries, 0.140 sec
```
`CREATE TABLE IF NOT EXISTS` no-op'd cleanly — replay-safe, no residue (NN#5). Runbook step 4 satisfied; this doubled as an **unplanned idempotency proof**. (The parallel worry that comments broke Run 1 parsing is separately laid to rest in §7 step 5e, where the original commented file re-created cleanly.)

---

## 7. Rollback-cycle proof (runbook step 5, dev-only; destructive drop authorized for this test by the runbook)

| Step | Action | Result |
|---|---|---|
| 5a | Stage-1 precheck via `…_ROLLBACK.sql` (zero DDL) | `master_audit_rows = 0`, `correction_request_rows = 0` → **loss-free window confirmed** |
| 5c | `…_ROLLBACK_DESTRUCTIVE.sql` executed | both `DROP TABLE` ran, `0.219 sec`, no errors |
| 5d | `information_schema` COUNT | **0** → drop proven |
| 5e | Forward file re-run (original **commented** version) | clean create, zero warnings → also settles the Run-1 comment-parsing doubt (comments were never the problem) |
| 5f | `information_schema` COUNT | **2** → recreate proven |

The two-stage rollback contract held: Stage 1 is precheck-only, Stage 2 is the guarded destructive drop, and both counts were 0 before the drop — the documented loss-free condition. The full **drop → recreate** cycle is reversible and clean.

---

## 8. Correction-dedup guard proof (runbook step 6 — four separate executions)

| Exec | Statement | Result |
|---|---|---|
| 1 | INSERT (active PENDING correction row) | `Affected rows: 1` |
| 2 | IDENTICAL INSERT | **SQL Error (1062): Duplicate entry `'1-contactPhone-555test-1'` for key `master_correction_requests_tbl.UQ_mcr_active_dedup`** → `Affected rows: 0` |
| 3 | DELETE the test row | `Affected rows: 1` (exactly one — secondary proof the duplicate never landed) |
| 4 | COUNT | **0** (test row removed; table clean) |

**The dedup constraint is empirically proven.** The 1062 key value `'1-contactPhone-555test-1'` exposes the composite anatomy directly: `master_co_contact_id=1` · `field_name=contactPhone` · `normalized_suggested_value=555test` · `active_guard=1`. A second active request for the same (master, field, normalized value) is rejected at the database, satisfying spec §10.5. Exec 3 affecting exactly one row independently confirms the rejected insert never persisted.

---

## 9. Dev-vs-prod structure comparison + EXPLICIT dev-only delta + prod read-only confirmation

```
########## SCHEMA: actorsbusinessoffice (PROD -- read-only, no apply) ##########
===== PROD: table presence (expect 0 -- dev-only delta) =====
0
===== PROD: any name match (expect 0 rows) =====
(0 rows)
PROBE COMPLETE -- all statements were SELECT/SHOW/USE only (read-only channel).
```

| Object | `new_development` (dev) | `actorsbusinessoffice` (prod) |
|---|---|---|
| `master_audit_tbl` | present (0 rows) | **absent** |
| `master_correction_requests_tbl` | present (0 rows) | **absent** |

**EXPLICIT dev-only delta:** the two new base tables exist on `new_development` **only**. Prod carries zero WO-2 objects and zero name matches. **No dev↔prod parity is claimed or implied** — prod DDL is reserved for **WO-12** alone (spec/Lock guardrail). The delta is intentional and is the expected end-state of WO-2.

**Prod-read-only confirmation:** every statement issued against prod (and dev) in the verification probe was `SELECT`/`SHOW`/`USE` only; the channel is the standing read-only path (`kingk436@%`). No prod DDL or DML occurred at any point in WO-2.

---

## 10. Test results summary (incl. guard proof) + data-state

- **Structure (step 3):** table count 2; both InnoDB/`utf8mb4_unicode_ci`; DDL conforms verbatim (§3–5). **PASS.**
- **Idempotency (step 4):** re-run = `Note 1050` ×2, 0 errors (§6). **PASS.**
- **Rollback cycle (step 5):** precheck 0/0 → destructive drop (COUNT 0) → recreate (COUNT 2) (§7). **PASS.**
- **Dedup guard (step 6):** identical active insert → 1062 on `UQ_mcr_active_dedup`; net-zero rows after cleanup (§8). **PASS.**
- **Data-state (AC-9):** both tables report `COUNT(*) = 0` live (probe L45–46, L85–86). No production data landed. **PASS.**

---

## 11. Remaining risks / notes

1. **`AUTO_INCREMENT=3` residue on `master_correction_requests_tbl` (benign).** The counter advanced during the step-6 guard test (and the incident-6 batched net-zero row); InnoDB does not roll the counter back on `DELETE`, and a duplicate-key failure can also consume a value. Live `COUNT(*) = 0` — **no data-integrity impact**; only the next `correctionID` starts at 3 on dev. This is expected MySQL behavior and is not carried to prod (WO-12 creates prod fresh).
2. **Session incidents, no effect (operator paste item 6).** (a) One stray paste of chat text into the query window → SQL Error 1064, 0 of 24 queries executed — nothing ran. (b) The first step-6 attempt was batched (no 1062 attempted); it inserted and deleted one row (net zero) and was re-run correctly as the four separate executions in §8. Neither incident altered the proven end-state.
3. **`action_type` / `status` vocabularies are VARCHAR, not DB ENUM (by design).** The DB does not enforce the governed vocabularies; runtime services and approved migration/backfill scripts must use the header constants. This de-risks the still-pending "approved-9 of spec-13 action classes" enumeration — no schema change is needed if the set is revised. Enforcement is a **service-layer** responsibility (deferred to the WO writing audit rows).
4. **No triggers, no FKs, no views (scope, by architect ruling).** Audit writes are explicit and testable via the service layer; append-only history may outlive deleted referents (nullable reference IDs are historical context, not live FKs). Any read/list surface over the audit table is WO-5-class, deferred.
5. **Prod remains untouched.** WO-12 is the only authorized path to prod DDL. This bundle asserts nothing about prod beyond "the two objects are absent there."

---

## 12. PASS/FAIL disposition

**All acceptance criteria PASS (AC-1 … AC-10, §0 table). No FAIL, no partial.** DIR-LNK-WO-2 dev apply is verified complete and conforming on `new_development`; prod is correctly untouched pending WO-12.

**STOP** per the standing relay: bundle assembled and committed docs-class; SHA and the complete final push set (grouped by class) are reported alongside this bundle. No push, no prod action taken.
