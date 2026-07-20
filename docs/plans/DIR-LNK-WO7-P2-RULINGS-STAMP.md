# DIR-LNK-WO-7 — P2 APPROVAL + RULINGS OF RECORD (OPERATOR STAMP)

> Committed verbatim beside DIR-LNK-WO7-P2-DESIGN.md as the rulings of record. Operator: Kevin, 2026-07-18.

---

DIR-LNK-WO-7 — P2 APPROVAL + RULINGS + P3 GO (OPERATOR STAMP)
Kevin, 2026-07-18. Commit verbatim (docs-class) beside the P2 memo as
the rulings of record, then open P3.

P2 MEMO: APPROVED, with two architect refinements folded in:
  R-A OFFICE PICKER 6+ CASE: NO preselection. The confirm button stays
      disabled until the user picks an office. Deterministic defaults
      apply only to the 2-5 card case where every option is visible.
  R-B Q5 RESTORE PRECEDENCE: on unlink-restore, take the value from the
      preserved item if it still exists and is active (it may have been
      edited while linked and is then the better value); fall back to
      the audit row's old_value if the item was deleted; blank if
      neither. Consume the item on restore and audit the consumption.

RULINGS OF RECORD:
1. NAME BRANCH: (ii) DROP the name picker. contactFullName_src is NOT
   created; no V3_13 migration in WO-7; names remain user-owned. The
   photo picker stays (contactPhoto_src exists). Registered as a future
   candidate requiring analysis of the cdSoundex/merge duplicate-
   detection interaction before it is reconsidered.
2. Q4 BLANK-OFFICE: follow the spec 7.5 default — the managed field
   mirrors the master including blank. The modal must disclose the
   blank before confirm and the user's value is preserved as an item.
   No escalation.
3. Q5 PRESERVED-ITEM LIFECYCLE: consumed on restore, per R-B.
4. Q6 EXISTING LINKS: defer the 14-link backfill to WO-8. WO-7 does not
   re-snapshot existing links; a user relink through the new flow
   snapshots that contact as a side effect, which is acceptable.
5. Q7 CHOICE PERSISTENCE: photo choice is set at link and revisitable
   at relink only. No separate panel control in WO-7.
6. OFFICE-AS-MASTER-SOURCE: RATIFIED as architecture of record on D-21
   evidence (companies.coPhone/coEmail 0% populated) plus the existing
   code path. The spec's silence is closed by this ruling; carry it
   into the WO-8 sync design.

P3 GO: authoring opens per lock Section 4. Scope = the memo as approved
plus R-A and R-B, minus the name picker per ruling 1. Order of work:
bridge disable, then service-layer link/unlink/relink with audit
writes, then the preview modal and confirm endpoint. Staging as two
commits (service, then UI) is approved if it makes line review cleaner.
Deliver diffs + file list for line review, then STOP. No commit until
commit-approved; no push; no deploy.

---

## RULINGS AS BINDING ON P3 (CC restatement, for authoring)
- **Name picker DROPPED** (ruling 1): no `contactFullName_src`, no V3_13, **zero DDL in WO-7**. Photo picker STAYS.
- **Q4** = §7.5 default (mirror master incl. blank); modal discloses blank; user value preserved as item; no escalation.
- **R-A** = 6+ office case has NO preselection; confirm disabled until an office is chosen; deterministic default (address1-non-blank, tie MIN(colocid)) applies to the 2–5 card case only.
- **R-B / Q5** = unlink-restore precedence: (1) active preserved item value if it still exists, else (2) audit `old_value`, else (3) blank; consume the item on restore; audit the consumption.
- **Q6** = no existing-link backfill in WO-7 (relink side-effect snapshot is acceptable).
- **Q7** = photo choice at link, revisitable at relink only.
- **Office-as-master-source** RATIFIED (D-21).

*END — DIR-LNK-WO7-P2-RULINGS-STAMP.md*
