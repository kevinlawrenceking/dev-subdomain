# WO-DUPES-R1 — Revision Plan (R-4 dropdown unions · R-5A normalizer / reason / fixture)

**Binding:** TAO / `dev-subdomain` / branch `dev` / repo `kevinlawrenceking/dev-subdomain`
**Date:** 2026-07-06 · **Author:** CC · **Basis:** `2026-07-06-retro-proof-bundle-conformance-audit.md`
**Status:** R-4 implemented (proof below, uncommitted, awaiting Kevin proof-bundle review);
R-5A-1/2 planned + gated on DEV-PROOF-RUNBOOK acceptance (consolidated with Item-1);
R-5A-3 fixture authored now (evidence-only, in the operator packet).

---

## Ground truth established this session (recon, not guessed)

The audition-list filter (`services/AuditionProjectService.cfc`, `filterAuditions` ~:1533-1543):

```
sel_repid    -> p.audprojectid IN (SELECT audprojectid FROM audroles
                                    WHERE contactid = :sel_repid AND isDeleted = 0)
sel_sourceid -> AND r.submitsiteid = :sel_sourceid          (r = audroles alias)
```

Consequences that drive the design:
1. **The dropdown's in-use arm must mirror the filter's table (`audroles`).** The pre-Ticket-4
   arms read `audcontacts_auditions_xref` (reps) and `audsources.audsourceid` (sources) — a
   **different id-space** from what the filter now matches. Reusing them verbatim would list
   values that return **zero** auditions when selected. Rejected.
2. **`audsubmitsites_user.submitsiteid` is a per-user key** (synced from global `audsubmitsites`
   by `submitsitename`, fresh auto-increment PK — `SetupProvisioningService.syncAudSubmitSites`).
   So both source arms live in the **same per-user `submitsiteid` space** → the UNION is coherent.
   "Legacy in-use source absent from the active list" (proof case 4) = a submit site that is
   soft-deleted (or name-blanked) in `audsubmitsites_user` yet still referenced by an old
   `audroles` row.
3. `audroles.contactid` is the rep on the role (casting director is a separate join, `c`), so
   dropping the tag filter in arm B surfaces **linked-but-untagged reps** without pulling CDs.

**Residual assumption (dev-verify, not provable from code):** `audroles.submitsiteid` references
the per-user `audsubmitsites_user.submitsiteid` keyspace. Verification SQL is in the operator packet.

---

## R-4-1 — `SELauditionReps` = UNION(tag arm, in-use arm)

**IMPLEMENTED** — `services/AuditionProjectService.cfc:243-293`.
- Arm A (unchanged Ticket-4 behavior): team-tagged contacts (`My Team,Agent,Manager,Publicist`).
- Arm B (restored in-use half, **tag-agnostic**): `audroles.contactid` for the user's audition
  roles, joined to `contactdetails` for `recordname`. Mirrors the filter table.
- `UNION` (dedup), `DISTINCT` each arm, userid-scoped both arms, `ORDER BY repname` outside.

## R-4-2 — `SELauditionSources` = UNION(master arm, in-use arm)

**IMPLEMENTED** — `services/AuditionProjectService.cfc:294-342`.
- Arm A (unchanged HEAD behavior): active `audsubmitsites_user`, `submitsitename <> ''`.
- Arm B (restored in-use half): distinct `audroles.submitsiteid` for the user's auditions, name
  `LEFT JOIN`ed from `audsubmitsites_user` (per user), falling back to `(site #<id>)` when the row
  is gone/blank — so a soft-deleted-but-in-use site still lists. Mirrors the filter table.
- `submitsitename <> ''` preserved on arm A; `UNION`; `ORDER BY name` outside.

## R-4-3 — filter/dropdown tag-set parity (VERIFY)

The Reps dropdown emits `audroles.contactid` (arm B) and the tag set `My Team,Agent,Manager,Publicist`
(arm A). The list filter (`:1533-1539`) matches `audroles.contactid` — **no tag set is applied in the
filter at all**, so there is no tag-set to drift against for reps: every rep the dropdown lists is
selectable and returns rows. The Sources dropdown emits `audroles.submitsiteid`; the filter matches
`audroles.submitsiteid` (`:1541-1543`) — **identical column, no drift.** Statement satisfied;
confirm live on the dev visit.

---

## R-5A — gated on DEV-PROOF-RUNBOOK acceptance (consolidate with Item-1, one WO, `ContactDuplicateService.cfc`)

- **R-5A-1 — single shared normalizer.** Blast-radius recon: `DuplicateMatcherService.normalizeName`
  (`services/DuplicateMatcherService.cfc:51`) is called at 10+ create-time sites
  (`:517, :598-599, :609, :619, :849, :993, :1073-1074, …`) and does trim+collapse+lcase only.
  Dedupe `cdNormalizeName` (`ContactDuplicateService.cfc:199-205`) already does the recommended
  **punctuation-stripping** (`[^a-z0-9 ]`). **Plan:** extract the punctuation-stripping normalizer to
  a location callable by BOTH services (add `normalizeNameStrict()` to `DuplicateMatcherService` or a
  shared util); dedupe adopts it **now**; create-time adoption is a registered **one-line follow-up**
  (flipping 10+ call sites changes create-time match sensitivity broadly — not folded in silently).
- **R-5A-2 — textual match_reason.** Add `match_reason='name'` alongside `match_score`
  (`ContactDuplicateService.cfc:~185`), surfaced per row in the dedupe UI.
- **R-5A-3 — DEV FIXTURE false-pair proof.** Authored now (evidence-only, proves the CURRENT matcher
  at HEAD — does not wait for R-5A code). See operator packet. The two false pairs not named in code
  comments: **Nancy Nayor / Nike Imoru** and **Scott Wojcik / SJ Hodges**.
- **R-5A/email — DECIDED:** name-only stands; email dimension is a registered follow-up
  (post-shared-normalizer), carrying the shared-office-email hazard note; name-gate must not apply
  to email pairs when it lands.

---

## Sequencing & holds

- R-4-* — independent file (`AuditionProjectService.cfc`); implemented; **implement → proof → STOP**.
  Commit authorization is Kevin's at proof-bundle review.
- R-5A-1/2 — consolidated with Item-1 into one WO/session on `ContactDuplicateService.cfc`, gated on
  DEV-PROOF-RUNBOOK acceptance. Prod deploy of `ContactDuplicateService.cfc` held meanwhile.
- R-5A-3 — evidence-only, rides Kevin's single dev visit (operator packet).
