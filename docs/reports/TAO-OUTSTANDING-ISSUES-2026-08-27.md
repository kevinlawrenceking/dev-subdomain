# TAO — Outstanding Issues Report

**Prepared for:** Claude Project review / work-order assignment
**Prepared by:** Claude Code (dev-subdomain session)
**Date:** 2026-08-27
**Repo:** `C:\Users\kevin\TAO\dev-subdomain`  |  **Branch:** `dev`
**HEAD:** `862e7a28`  |  **origin/dev:** `862e7a28`  (in sync — all committed work is pushed)

---

## How to read this

Each item below is a **candidate work order (WO)**. Fields:

- **State** — one of `UNCOMMITTED` / `OPEN-BLOCKER` / `BACKLOG` / `CLOSED`.
- **Owner-gate** — who must act next: **Operator** (server/deploy/decision) or **CC** (Claude Code can proceed on approval).
- **Priority** — P0 (customer-facing/live) → P3 (hygiene).

Nothing in this report has been deployed to prod beyond what is already recorded as deployed. No prod data was mutated in producing it.

---

## 0. Executive summary

| # | Item | State | Priority | Owner-gate |
|---|------|-------|----------|-----------|
| A1 | Master Directory **prod-gate** fix (uncommitted) | UNCOMMITTED | **P1** | CC (needs commit auth) |
| A2 | `remote_aud` **new_toneid typo** fix (uncommitted) | UNCOMMITTED | **P1** | CC (needs commit auth) |
| A3 | 3 untracked working-tree files (dispose) | UNCOMMITTED | P3 | CC/Operator |
| B1 | Prod **outbound mail delivery** outage | OPEN-BLOCKER | **P0** | Operator (server) |
| B2 | **DIR-LNK WO-8** P5 acceptance stalled | OPEN-BLOCKER | **P1** | Operator (deploy+test) |
| C1 | Admin-auth hardening (`session.isAdmin` dead gate) | BACKLOG | P2 | CC |
| C2 | Auditions perf — Tier-1 index not applied | BACKLOG | P2 | Operator (apply) |
| C3 | WO-9 correction hooks | BACKLOG | P3 | CC |
| C4 | WO-11 soft-delete-unlink | BACKLOG | P3 | CC |
| C5 | WO-12 audit retention + `.git` deny | BACKLOG | P3 | Operator/CC |
| C6 | Nonexistent-MDI-class audit; N-1 comment fold | BACKLOG | P3 | CC |
| — | Setup-link expired regression | **CLOSED** | — | — |

Two items are genuinely live: **B1 (mail delivery)** is untriaged and customer-affecting; **B2 (WO-8 P5)** is code-complete but its sweep is still unproven. The two uncommitted code fixes (**A1/A2**) are real and should be captured before they are lost.

---

## A. Uncommitted working-tree work

> These are sitting in the working tree with no commit. They are legitimate fixes, not scratch. They need a decision: commit (with authorization) or discard.

### A1 — Master Directory "Book" UI prod-gate  `P1`  `UNCOMMITTED`

- **File:** `include/contact_info.cfm` (+15 / −1)
- **What it does:** Introduces `masterBookEnabled = ( ListFirst(cgi.server_name, ".") NEQ "app" )` and wraps (a) the on-read `syncLinkedContact` hook and (b) the entire `#masterLinkWrap#` Book UI block in `<cfif masterBookEnabled>`. Effect: the Master Directory Book UI renders on dev/UAT but **not** on prod (`app`).
- **Why it exists (root cause captured in the diff comment, dated 2026-08-13):** `contact_info.cfm` is deployed to prod, but its two dependencies are **not**:
  - `/include/master_link_preview.cfm` returns 404 on prod → clicking a match loaded a 404 into the modal (the error users reported). No `error_tickets` row because a 404 never reaches the CF error handler.
  - `master_audit_tbl` does not exist in `actorsbusinessoffice` (dev-only) → link-confirm could not write its audit row.
- **Host-test pattern:** matches the house convention (`include/import-auditions.cfm:296`); prod hostname first-token is `app`.
- **Proposed WO:** Commit this as a standalone hotfix (it is defensive and prod-safe — it only *hides* an incomplete feature). Tag it as the prod-gate that WO-8 promotion must later *remove* (comment already says "Remove this gate as part of the WO-8 prod promotion, not before").
- **Owner-gate:** CC can commit on a **"commit approved"** + named push authorization. This is arguably the highest-value uncommitted change because it corresponds to a live prod error users hit.
- **Acceptance:** on prod (`app`), contact panel shows no Book chip/modal; on dev, Book UI + on-read sync unchanged.

### A2 — `remote_aud_project_update2` variable-name typo fix  `P1`  `UNCOMMITTED`

- **File:** `include/remote_aud_project_update2.cfm` (+2 / −2)
- **What it does:** `<cfset new_tone_id = old_toneid />` → `<cfset new_toneid = old_toneid />`. The rest of the page reads `new_toneid`; the misspelled `new_tone_id` left `new_toneid` undefined on the non-Custom tone branch.
- **Impact if unfixed:** on the `Custom is ""` branch, downstream references to `new_toneid` would throw "variable is undefined" (compounded by TAO's implicit-scope-search being disabled — see `reference_implicit_scope_search_disabled`), or silently fall through to a cfparam default. This is a real defect on the audition project-update path.
- **Proposed WO:** Fold into a small "remote audition update" correctness commit. Verify the surrounding branch (the second hunk also drops trailing whitespace only).
- **Owner-gate:** CC, on commit auth. Trivial diff; low risk.
- **Acceptance:** submit an audition project update with a non-custom tone → no undefined-variable error; `new_toneid` carries `old_toneid`.

### A3 — Untracked working-tree files (disposition)  `P3`  `UNCOMMITTED`

| File | Size | Likely origin | Recommended disposition |
|------|------|---------------|------------------------|
| `include/contact_info_PROD.cfm` | 72 KB | Prod snapshot captured 2026-08-13 for the Book-gate diff | **Do not commit** — it's a prod copy for comparison. Move to `docs/plans/evidence/` or delete. Never let it shadow the real page. |
| `setup.zip` | 30 KB | Deployment bundle for the setup fix (`862e7a28`) | **Do not commit** — build artifact. Add to `.gitignore` or delete. |
| `docs/reports/SETUP-RECON-REPORT.md` | 18 KB | Setup regression recon writeup | **Commit** (docs/evidence are pre-authorized when isolated) or keep local — reviewer's call. |

- **Owner-gate:** CC can propose the `.gitignore` + move; deletion of `setup.zip`/`contact_info_PROD.cfm` should be confirmed since CC did not create them.

---

## B. Open operational blockers

### B1 — Prod outbound mail delivery outage  `P0`  `OPEN-BLOCKER`  (Owner: **Operator / server-side**)

- **Symptom:** The 7 real ThriveCart webhook rows from 2026-08-09..08-16 (tc ids **3876, 3877, 3878, 3881, 3882, 3883, 3884**) all sit at status `Emailed`, but **none of the BCC copies arrived** at `kevinking7135@gmail.com` (every welcome send BCCs it — `sched/thrivecart_process.cfm:134`).
- **Fault is below the CFML:** `thrivecart_process.cfm` catches a cfmail failure at `:177` → `<cfcontinue/>` at `:183`, which **skips** the status update. A row can only reach `Emailed` if cfmail returned without throwing — i.e. CF accepted it into the spool. **`Emailed` = queued, never delivered.** Delivery is a later background thread.
- **Where to look (server-side; CC has no prod filesystem access):**
  - `<cf_root>/cfusion/Mail/undelivr` — files here = relay rejected; headers name the reason.
  - `<cf_root>/cfusion/Mail/spool` — large = mail service stopped/backed up.
  - `<cf_root>/cfusion/logs/mail.log`.
  - CF build: ColdFusion Server 2021,0,21,330451.
- **Prime suspect:** envelope sender `support@theactorsoffice.com` rejected by the relay. A sibling address is already known-bad — `ipn-cancelled.cfm:84` records "kevin@theactorsoffice.com is SMTP-rejected (Invalid Addresses)".
- **Safe end-to-end prober (zero customer exposure):** `app/admin-users/ajax/create-test-setup.cfm` is prod-enabled (`allowedDsns = "abo,abod"`). It writes an `IsDemo=1`, `status='Pending'` row with cloned product codes; `thrivecart_process.cfm:62-110` redirects that send to the admin's own address with a `[TEST]` subject prefix, through the **same** cfmail call and CF Admin default mail server. A `[TEST]` email landing = transport proven.
  - **CAVEAT:** `sched/standalone_email_test.cfm` is **not** a valid prober — it hardcodes `server="127.0.0.1" port="25"`, bypassing the CF Admin default server the welcome email uses. (It is also an unauthenticated GET that sends mail — standing security finding.)
- **2026-08-27 status note:** Kevin confirms real buyers now complete setup end-to-end ("thrivecart is fixed"), but scoped that **"regardless of the BCC/mail-log question."** Buyers getting in does **not** prove mail delivery recovered. This item stays open until BCC delivery (or a `[TEST]` landing) is actually observed.
- **Blocks:** resend of tc **3881/3882/3883/3884**. Staged SQL (snapshot + guarded reset + rollback) was prepared but deliberately NOT run. Note `thrivecart_process.cfm:56-60` **rotates the UUID on every run**, so any reset must snapshot `status`+`UUID` first to stay reversible.
- **Proposed WO:** (1) Operator runs the `[TEST]` prober and reports landing/no-landing + checks `undelivr`/`mail.log`. (2) If sender-rejection confirmed, fix the envelope sender / relay auth. (3) Only then run the guarded resend for the 4 stranded rows.

### B2 — DIR-LNK WO-8 P5 acceptance stalled  `P1`  `OPEN-BLOCKER`  (Owner: **Operator / deploy + test**)

- **Where it stands:** WO-8 (master auto-sync) is **code-complete and pushed**. Commit chain: Stage1 `51ef9338` → Stage2 `7e586e21` → Stage3 `5287f3e5` → runbook `24dedabd` → endpoint rename `9d76d2e3`, all now under HEAD `862e7a28`. `origin/dev` carries all of it.
- **What's blocking:** P5 acceptance attempt-1 failed on the deployed dev build with **"Re-sync failed."** Two relayed defect premises were **refuted** by CC evidence:
  - *Casing bug* — WITHDRAWN. `git log -S` proves camelCase `isDeleted` never existed in `MasterDirectoryService.cfc`; the sweep read lowercase `isdeleted` since birth. MySQL column identifiers are case-insensitive, so casing cannot throw "Unknown column" here.
  - *Hyphen-unservable endpoint* — RETRACTED. `link-confirm.cfm` (same dir, hyphenated) is POSTed live and passed WO-7.
- **Most likely real cause:** a **deploy/build gap** — the endpoint was not served from a complete deployed build. The actual sweep is therefore **still untested**.
- **Endpoint:** renamed to `ajax/master/resyncall.cfm` (all-lowercase house convention) in `9d76d2e3`; all 7 path refs repointed. `MasterDirectoryService.cfc:871` calls the sweep `resyncAllLinked` (function not renamed — 2 operation log-labels at `:913/919` intentionally left).
- **Admin gate (N-3):** the endpoint gates on DB `taousers.userRole IN (Admin, Administrator)`, **not** `session.isAdmin` (which is never set — see C1).
- **Next action (Operator):** pull dev to `862e7a28`, **cache clear / restart**, re-run P5 **from Test 1** (the earlier 193→193 zero-write run was on a pre-WO-8 build and is discarded). If it throws again, pull the **top `error_tickets` row** (`errorMessage` + `tagContext`) — do **not** re-guess.
- **Note on coverage:** the derive-or-skip SKIP/MIRROR arms are **unexercised by live data** (all 8 `_src=master` company rows are already COMPARE-resolved; 0 dangling). P5 must use the **constructed fixtures** in runbook `24dedabd` to exercise those arms.
- **Related:** A1's prod-gate must be **removed** as part of WO-8 prod promotion — but only after P5 passes on dev and both prod dependencies (`master_link_preview.cfm`, `master_audit_tbl`) are promoted.

---

## C. Registered backlog (not urgent, ready to schedule)

### C1 — Admin-auth hardening: dead `session.isAdmin` gate  `P2`  `BACKLOG`  (Owner: CC)
~7 endpoints gate on `session.isAdmin`, which is **never set anywhere** in the app → those endpoints are latently permanent-403. Migrate them to the DB `taousers.userRole` / `admin-guard.cfm` pattern (the same pattern WO-8's resync endpoint already uses correctly). Standalone hardening pass.

### C2 — Auditions performance: Tier-1 index not applied  `P2`  `BACKLOG`  (Owner: Operator to apply)
Auditions slowness root-caused (2026-07-09) to a wrong-leading-column xref index. Tier-1 index migration is **written but not applied**. Also pending: Trusted Cache prod toggle, query-cache, `getAuditions` rewrite. See `project_auditions_perf_wo`.

### C3 — WO-9 correction hooks  `P3`  `BACKLOG`  (Owner: CC)
Master-directory correction hooks; specimen: Ben Pollack "and Seth Yanklewitz" (name-suffix contamination).

### C4 — WO-11 soft-delete-unlink  `P3`  `BACKLOG`  (Owner: CC)
Register: soft-delete of a contact should unlink its master pointer. Depends on in-place relink UI (MASTER_RELINKED audit path is dormant — never fired).

### C5 — WO-12 audit retention + `.git` deny  `P3`  `BACKLOG`  (Owner: Operator/CC)
`master_audit_tbl` is now correctness-critical (link-epoch = MAX(auditID) folded into idempotency key — **no prune/renumber**). WO-12 = define a retention policy that preserves that invariant. Also D-24: `.git` directory web-deny still open.

### C6 — Cosmetic / comment debt  `P3`  `BACKLOG`  (Owner: CC)
- Nonexistent-MDI-class audit (`mdi-office-building-outline` was a non-existent class; corrected to `mdi-briefcase-outline` — sweep for other nonexistent MDI classes).
- N-1: fold "update if managed set changes" comment into the next touch of the kept=3 footer line.

---

## D. Closed (for the record — do not reopen)

### D1 — Setup-link "expired" regression  `CLOSED 2026-08-27`
Real ThriveCart buyers were dead in `/setup/` since ~2026-04 (`setup2.cfm:38` hard-gated on `thrivecart.customerid`, NULL on real webhook rows; `taousers.customerid` actually holds `thrivecart.id`). Fix `862e7a28` dropped the gate, re-keyed the soft-delete/INSERT to the PK, and added a POST-side single-use guard. **PUSHED + deployed + verified on prod (2026-08-17); Kevin confirmed real buyers now complete setup end-to-end live (2026-08-27).** Done. Full recon: `docs/reports/SETUP-RECON-REPORT.md`.

---

## E. Recommended work-order sequencing

1. **B1 (mail delivery, P0)** — operator runs `[TEST]` prober + checks `undelivr`/`mail.log`. Nothing else about ThriveCart onboarding is trustworthy until transport is proven.
2. **A1 + A2 (uncommitted fixes, P1)** — capture both before they're lost; A1 corresponds to a live prod error.
3. **B2 (WO-8 P5, P1)** — operator does a clean deploy of `862e7a28` + restart, re-runs P5 from Test 1 with constructed fixtures.
4. **A3** — dispose of the 3 untracked files; add `setup.zip` + `*_PROD.cfm` to `.gitignore`.
5. **C1 (admin-auth, P2)** then **C2 (auditions index, P2)**.
6. **C3–C6** as capacity allows.

---

## F. Verification hooks for the reviewer

- `git rev-parse HEAD` = `862e7a28`; `git ls-remote origin dev` = `862e7a28` (confirm before trusting any relayed SHA — stale-relay has bitten this thread 3×).
- `git status -s` shows the A1/A2 modifications and A3 untracked files.
- Memory ledger backing this report: `project_prod_mail_delivery_outage`, `project_dir_lnk_series`, `project_setup_link_expired_regression`, `project_auditions_perf_wo`, `feedback_commit_authorization`, `feedback_push_go_instrument`.
- **Authorization reminders:** code commits require "commit approved" + a named push; pushes require a standalone PUSH GO instrument naming the range+set (SR-1). Docs/evidence commits are pre-authorized when declared + isolated.
