# Master Contact Directory (TAO-MCD-P1) — STATUS & SCOPE

**Purpose:** single current-state anchor for the program. Keeps work on target and scope.
This is the STATUS reference; `master-contact-directory-phase1.md` remains the design/plan
of record (but is a stale DRAFT that predates execution — read this for what is actually true).

**As of:** 2026-07-13 · **Program:** TAO Master Contact Directory, Phase 1 ·
**Repo binding:** project TAO-MCD-P1 · repo `kevinlawrenceking/dev-subdomain` ·
root `C:/Users/kevin/TAO/dev-subdomain` · branch `dev`.

---

## 1. One-line status

WO-1 schema is applied on both schemas (prod backfill pending D-a). DIR-WO-2 (master-link UI)
is **ACCEPTED (PASS)** and live on **dev** at pin `5946ea4f`. Program is **HOLDING at DG-1**:
DG-3 (human QA, Jodie) and DG-4 (prod-write authorization) are the remaining gates before any
prod deploy of DIR-WO-2. No prod code yet; no unauthorized pushes.

## 2. State at a glance

| Item | State |
|---|---|
| WO-1 V3_7 (12 cols + 3 idx), V3_8 (44-col INVOKER view), V3_9 (3 master FKs) | **APPLIED** dev + prod |
| WO-1 V3_10 Part A (denorm contactCompany/Phone/Email backfill) | **APPLIED dev only**; prod pending **D-a** |
| WO-1 Part B (master linkage backfill) | **ABANDONED** (imdbid key dead); linkage moved to the UI |
| DIR-WO-2 master-link UI (services + `/ajax/master/*` + contact_info control) | **ACCEPTED**, deployed **dev** at `5946ea4f` |
| DIR-WO-2 acceptance suite A1-A10 + A3b + A6b | **PASS** — product 23/23 (one harness timing artifact, N-1) |
| DG-1 prod aggregate | **DONE** (prod untouched; V3_10 not applied) |
| DG-3 Jodie human QA · DG-4 prod-write auth | **PENDING** (operator/architect owned) |
| DIR-WO-2 on prod | **NOT deployed** (dev-only) |

## 3. Environments, channels, constraints

- MySQL. Prod schema `actorsbusinessoffice` (dsn `abo`); dev `new_development` (dsn `abod`);
  env resolved by hostname (`app`→prod, else→dev/uat). CF app names env-scoped (TAO_PROD/DEV/UAT).
- **CC DB channel:** read-only python + pymysql as `kingk436` to `www.theactorsoffice.com:3306`
  (no mysql CLI, no DB MCP). Writes only when a work order explicitly authorizes them. Prod reads
  restricted to aggregate / information_schema / SHOW unless a WO widens scope.
- **Deploy mechanism:** operator Hostek git-update (D-13; the R-8 FTP path was withdrawn).
  **Auto-deploy is CLOSED.** No pushes without named authorization.
- **Commit policy:** docs/evidence commits are pre-authorized when declared + isolated; **code
  commits require explicit "commit approved" + named push auth.** Two docs commits are currently
  local/unpushed (`768d00ac` runbook v2, `f5bd4641` acceptance bundle; dev ahead of origin/dev by 2).
- **Gates are evidence-first, zero fabrication.** CC pauses only for
  blocker/decision/destructive/cost/security/deploy. Work orders carry a BINDING header CC verifies.

## 4. DIR-WO-2 — what shipped (dev)

- **Endpoints** (`/ajax/master/`, auth + CSRF via `ajax/Application.cfc`):
  `search.cfm` (GET typeahead), `locations.cfm` (GET offices for a coid), `link.cfm` (POST),
  `unlink.cfm` (POST). Build tags `master-*-2026-07-09-v1`.
- **Service:** `services/MasterDirectoryService.cfc` orchestrates; `ContactService` stays the
  **sole** `contactdetails` writer; `ContactItemService.createCompanyItem` writes the canonical
  Company item. Never writes phone/email (PD-L1).
- **UI:** master-link control + badge in `include/contact_info.cfm` (`#masterLinkWrap`).
- **Locked product decisions (architect rulings):**
  - PD-L1 — link never writes phone/email.
  - PD-L2 — link upserts a `contactitems` Company row in the same `cftransaction`.
  - PD-L3 — unlink clears fields where `_src='master'` and resets `_src='user'`.
  - PD-L4 — re-link refreshes `_src='master'` fields, fills blanks, never touches `_src='user'`.
  - PD-L5 — existing contacts only; create-form deferred.
  - F-2 — `master_coid` derived solely from the master person row and only when the companies row
    exists (client `coid` ignored); `company_location_id` accepted only if the office belongs to
    that company (else NULL). F-3 — re-link to a no-company master clears the stale master snapshot
    and soft-deletes the stale master item (R-1 match-guard).

## 5. Acceptance (2026-07-11/12, dev, R-7 CONFIRMED)

Runbook v2 (`768d00ac`); bundle (`f5bd4641`, `docs/plans/evidence/2026-07-11-dir-wo2-acceptance-bundle.md`).
22/23 harness check-groups PASS; **product behavior PASS on all 23 cases.** The single non-pass is a
harness timing artifact (**N-1**: `master_last_sync` is 1-second-resolution DATETIME; A5 and A5b ran
in the same second, so a strictly-greater assertion saw equal values — not a defect). Verified: link
creates snapshot + Company item; user-typed company preserved on link; unlink clears + soft-deletes
via match-guard; wrong-company office rejected to NULL; master rename propagates on re-link; ownership
returns generic "Contact not found."; missing CSRF → HTTP 403; idempotent re-link/unlink.

Root-cause note for history: the first run failed on stale deployed services (new `/ajax/master/*`
files were live but modified `ContactService`/`ContactItemService` were not) — **D-17** deploy-
verification gap. Resolved by operator cache-clear/redeploy; re-run passed.

## 6. Deploy gates

| Gate | Meaning | Status |
|---|---|---|
| DG-1 | Prod aggregate baseline (2 SELECTs on `actorsbusinessoffice.contactdetails_tbl`) | **DONE** — 72062 rows; all denorm cols + all master pointers = 0; `_src` 100% `user`. Prod untouched; confirms V3_10 not applied. |
| DG-3 | Human QA (Jodie) in dev browser | **PENDING** — operator-run; implementer does not QA its own UI |
| DG-4 | Prod-write authorization | **PENDING** — arrives separately after branch-content ruling |

R-6 dev credential handling is **CLOSED**: temp creds staged→used→rotated back to originals
(hashes byte-match backup); backup file deleted.

## 7. Open decisions & next steps (architect-owned)

1. **D-a** — apply V3_10 Part A denorm backfill to prod? (DG-1 aggregate is the input.)
2. **Prod path for DIR-WO-2** — sequence DG-3 → issue DG-4 → push + operator deploy of the WO-2
   code to prod (currently dev-only, and dev↔prod view drift D-11 must be honored).
3. **DIR-WO-2.1 polish scope** — master-link control font/size/placement rework (CC recommends:
   larger trigger with icon/affordance, raise last-sync from 0.72rem, left-align person·company);
   **UI-3** blank-company placeholder in search results.
4. **DIR-WO-3 recon** — D-14, N-1, and D-18 are prerequisites; D-15 (orphaned-pointer noop leaves
   stale `_src='master'`) deferred here.
5. **Owed, non-blocking** — six-file verbatim for the WO-1 closure verdict
   (`docs/plans/evidence/2026-07-09-dir-wo2-gate0-sixfile-verbatim.txt`).

## 8. Register (defects / open questions / notes)

| ID | Summary | Status |
|---|---|---|
| D-1 | Inert `#companySearch` autocomplete binding (`remoteAddName.cfm:185` + twins) | open, low |
| D-2 | `CompanyLookup.cfc` exists; prior recon "absent" was wrong; dead lowercase twin | info |
| D-3 | WO-1 runbook/manifest read as current though superseded | registered |
| D-4 | "P1–P6" pre-flight register does not exist on disk | WO-premise defect |
| D-5 | `INScontactitems_24052` writes company into VALUETEXT (invisible to readers) | open, med |
| D-6 | No `primary_yn` maintenance for Company items anywhere | open, med |
| D-7 | `contact_info.cfm` company `.on('change')` binds an element absent at bind time | open, low |
| D-8 | No canonical DIR-WO register file | open |
| D-9 | No mysql CLI/MCP channel | **resolved** (pymysql read channel ratified, OQ-5) |
| D-10 | PD-L2 vs prior recon doc "snapshot only" conflict | PD-L2 governs |
| D-11 | Dev↔prod view drift (`contacts_ss_target/followup/maint`, `sharez`) | open, med — honor before prod read-path work |
| D-12 | Prod-apply proof files were untracked | **closed** (committed) |
| D-13 | Deploy mechanism = Hostek git-update (R-8 FTP withdrawn) | ruling |
| D-14 | DIR-WO-3 recon prerequisite (definition architect-owned) | carried |
| D-15 | Orphaned-pointer unlink noop leaves stale `_src='master'` (FK SET NULL orphan) | deferred → DIR-WO-3 |
| D-16 | Acceptance artifacts were never persisted | **closed** (runbook v2 `768d00ac`) |
| D-17 | Deploy-verification gap (404→401 smoke only proves NEW-file liveness) | registered |
| D-18 | Duplicate master-directory person rows (e.g. `co_contacts` 4020/4032) | → DIR-WO-2.1 / DIR-WO-3 recon |
| UI-3 | Blank-company placeholder in search results | → DIR-WO-2.1 polish |
| N-1 | `master_last_sync` 1-second granularity | informational → DIR-WO-3 recon input |
| OQ-1..6 | Plan-Lock-v1 open questions | **resolved** (namespace `/ajax/master/`; unlink match-guard; default-office picker; channel ratified; prod COUNT → DG-1) |

## 9. Scope boundaries

**In (Phase 1):** master directory search/link/populate; keep user edits un-clobbered; denormalize
hot contact fields onto `contactdetails_tbl`; the master-link UI control.
**Out:** Phase 2 scraper freshness; bulk/interactive linkage backfill of existing contacts
(candidate **DIR-WO-3**, must route through `MasterDirectoryService.linkContactToMaster`); the
create-form link path (PD-L5 deferred); photo/IMDb population (excluded, zero DDL this WO).

## 10. Key technical facts (do not relearn the hard way)

- `taousers`, `contactdetails`, `contactitems` are **VIEWS**; DDL/writes target the `_tbl` base
  tables. `recordname` is a VIRTUAL GENERATED column — never insert/update it.
- Login auth = salted SHA-512 `Hash(password & passwordSalt,"SHA-512")` on `taousers_tbl`.
  CSRF token generated `app/Application.cfc:398`, exposed via `<meta name=csrf-token>` (core.cfm),
  sent as `X-CSRF-Token`.
- Acceptance fixtures: contacts 90835(uid1)/102009(uid10)/128597(uid12)/128621(uid17).
  Master selection: M1 = co_contacts id 1 / coid 6342 "New Regency Productions" (colocid 150);
  M0 = id 40 (coid 0, no company); X1 = colocid 1 (wrong-company probe).

## 11. Evidence index

- `docs/plans/master-contact-directory-phase1.md` — Phase-1 design/plan of record (stale DRAFT).
- `docs/plans/evidence/2026-07-09-dir-wo2-gate0-recon-proof-bundle.md` / `-relay-v2-proof-bundle.md` — Gate 0 recon.
- `docs/plans/evidence/2026-07-11-dir-wo2-acceptance-runbook-v2.md` — ratified acceptance runbook (`768d00ac`).
- `docs/plans/evidence/2026-07-11-dir-wo2-acceptance-bundle.md` — PASS bundle (`f5bd4641`).
- `docs/plans/evidence/2026-07-07..08-wo1-*.md` — WO-1 schema apply proofs (dev + prod).
- `docs/plans/evidence/2026-07-09-dir-wo2-gate0-sixfile-verbatim.txt` — six-file verbatim (WO-1 closure).
