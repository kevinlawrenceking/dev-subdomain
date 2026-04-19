# Review Prompt: sched/events_completed.cfm

Paste the block below into the TAO ColdFusion Expert Claude project to get a senior-CF review of the work. The prompt is self-contained; it names the files to read, the review scope, and the format it should return in.

---

## Prompt to paste

You are the TAO ColdFusion Expert. I need a rigorous review of a scheduled-task audit I just finished.

**Files to read first (in this order):**
1. `sched/events_completed.cfm` -- the scheduled task. I just added section-level CFML comments describing each block. Read the whole file; verify my annotations match what the code actually does.
2. `database/claude-projects/tao-coldfusion-expert/21-events-completed-review.md` -- my review doc: process walkthrough, downstream-consumer table, redundancy check vs real-time paths, 10 known gaps, per-job real-time migration analysis, and a 7-step roadmap.
3. `sched/events_completed_wo_system.cfm` -- older sibling variant. Useful to cross-check the enrollment logic I described in the review.
4. `sched/remote_load.cfm` -- the include used at the top of events_completed.cfm.
5. `services/NotificationStatusService.cfc` -- UI consumer of `funotifications.notstatus`; my claim is that the UI depends on the nightly `Future -> Active` flip.
6. `/ipn-handler.cfm` and `/ipn-cancelled.cfm` -- my claim is that neither soft-deletes users, so the scheduled job is the sole path for cancelled-user cleanup.

**What I want you to do**

Perform a full review in four passes and return the results as a single markdown doc.

**Pass 1 -- Annotation accuracy.** For each CFML comment block I added to `sched/events_completed.cfm`, check whether the description matches the code directly below it. Flag any mismatch, over-simplification, or factual error. Quote the offending comment and the correct interpretation. If every annotation is correct, say so explicitly (do not pad).

**Pass 2 -- Process documentation.** Read section 2 ("Execution flow") of `21-events-completed-review.md`. Verify the order of operations, the query names, the in-memory map shapes (`enrollmentSets`, `actionScheduleMap`, `systemInfoMap`), the enrollment-skip rules (systemid 1/2 superseded by 3/4), and the uniqueness-check whitelist flow. Report any omission or inversion.

**Pass 3 -- Known gaps.** Section 5 of the review lists 10 issues with a severity rating. For each:
- Confirm or challenge the severity.
- Name any gap I missed. Especially look for: auth/CSRF exposure on a scheduled URL, transaction isolation issues when two runs overlap, missing indexes implied by the preload queries (`allFollowups`, `allEnrollments`, `allActionSchedules`), unsafe `dsn` interpolation risk, `cfqueryparam` coverage, and any dead write (e.g. the `DB default` branch on `funotifications.notstatus` -- does the table actually have a safe default?).
- For gap #4 (in-memory `enrollmentSets` not unwound on rollback), work a concrete failure scenario end-to-end and tell me whether the current retry-on-next-run behavior is genuinely safe or whether a run can leave behind orphan rows.

**Pass 4 -- Real-time migration plan.** Section 6 proposes migrating each job to real-time. For each of the four jobs:
- Agree / disagree with the recommendation and say why.
- Identify any consumer I missed (reports, dashboards, other cron jobs) that would break if the proposed change shipped.
- For Job C specifically (`EventService.complete(eventId)` extraction), sketch the function signature, its transactional boundary, the callers it would need on day 1, and the minimum test plan before wiring the UI button.
- For Job A (eliminate the `Future` notstatus state), grep-audit the codebase for every other place `notstatus = 'Future'` is referenced and list each with file/line. The migration cannot ship until all of those are accounted for.

**Non-negotiables for your review**
- Cite file paths and line numbers for every claim. No paraphrase without a reference.
- MySQL, not SQL Server. If I slipped into the wrong dialect in my doc, flag it.
- Verify `cfqueryparam` usage in any code you recommend changing.
- Respect the soft-delete view/`_tbl` pattern: `taousers` is a view over `taousers_tbl`; the scheduled task already handles this correctly -- confirm I described it correctly in the review.
- Do not rewrite the review doc. Return a separate review-of-the-review doc with a clear verdict per pass and a numbered list of required fixes ranked by severity.

**Output format**

```
# Review of events_completed.cfm audit

## Verdict
One of: APPROVE / APPROVE WITH FIXES / REJECT + one-sentence reason.

## Pass 1 -- Annotation accuracy
- [line range] finding
- ...

## Pass 2 -- Process documentation
- finding
- ...

## Pass 3 -- Known gaps
### Severity adjustments
- ...
### Gaps I missed
- ...
### Deep dive on gap #4
- scenario, outcome, recommendation

## Pass 4 -- Real-time migration plan
### Job A
### Job B
### Job C (with function sketch + callers + test plan)
### Job D
### Cross-cutting consumers at risk

## Required fixes before shipping the review
1. (P0) ...
2. (P1) ...
3. (P2) ...
```

If you cannot read a referenced file, stop and say which one; do not hallucinate its contents.
