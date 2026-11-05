# Events backlog recovery plan (2026-10-17) - FOR REVIEW, NOTHING EXECUTED

Owner: Kevin King. Prepared by Claude Code. Every step needs Kevin's explicit approval.
Code: `sched/events_completed.cfm` (uncommitted, working tree). Tests:
`tests/regression/test_events_completed.py`.

## 1. What is wrong (verified 2026-10-17, read-only on prod)

- JOB C (complete past-due events, enroll tagged contacts in Follow-Up systems 1/2, seed the
  first reminder) has completed **nothing since the event that ended 2025-08-21** (newest
  `eventstatus='Completed'` stop date). error_tickets has recorded a `RequestTimedOut` at the
  `allFollowups` CFQUERY every night since 2026-04-11 (199 rows). Earlier failures were not
  captured.
- Deployed version: PROVISIONAL. Prod frames `events_completed.cfm:287` (CFQUERY) and `:244`
  line up with HEAD / `fc7e4a78` / `a56f51e1`, but matching line numbers do not establish file
  identity. Confirm with the SHA-256 of the prod file before relying on it.
- Root cause (EXPLAIN on prod, real 300-event batch): the optimizer starts at a full scan of
  `eventtypes_user_tbl`. It walks every event of every user and joins `contactitems` on tag
  text alone, across all users, and applies the batch's eventid list last. It estimates 4.5
  rows per tag text; real counts are up to 14,129 ("Casting Director"). The batch itself is
  only 356 xref rows / 282 contacts / 41 users.
- JOB A and JOB B run before JOB C and autocommit, so they are not affected by the timeout.
  JOB D (meeting-date backfill) and the ICS regen run after JOB C, so they never ran.
- Side finding (not changed): JOB A flips `funotifications.notstatus` 'Future' -> 'Active', but
  prod has no 'Future' or 'Active' rows (Pending 36,931 / Completed 7,651 / Skipped 1,652;
  column default 'Pending'). JOB A is a no-op today. That needs a separate decision.

## 2. The fix (local only)

1. `allFollowups`: same tables, predicates and output. `STRAIGHT_JOIN` drives from the batch's
   events (PRIMARY range): xref (one hash join over 8,160 rows), each contact's own tag items
   (`idx_contactitems`), the owner's tags (`idx_tags_user`), then event types (one hash join).
   Old and new return identical rows on the synthetic fixture (test passes).
2. **Explicit write gate** (added after review): JOB C writes and JOB D + ICS run only when the
   request carries `?enableWrites=1`. Without it JOB C is count-only and reports
   `eligibleEvents`, `wouldEnroll`, `wouldBellNotifications`, `wouldRemindersMax` (upper bound:
   the isUnique check is per-contact) and `wouldSkipAlreadyEnrolled`, with status
   `jobc_count_only`. JOB A and JOB B keep their current nightly behavior. Enabling writes is a
   deliberate edit of the scheduled-task URL, made only after the counts are reviewed. The
   14-day `staleDays` cutoff stays as a second limit; on its own it does NOT guarantee that
   nothing is processed (any event that ends in the window becomes eligible).
   `?includeStale=1` lifts the cutoff for an approved, supervised run.
3. **Time budget**: no new event starts after `?timeBudgetSec` (default 420, clamp 30-540).
   Unstarted events stay Active for the next run (`budgetStopped` is in the log and JSON).
4. **Idempotency guards**: see section 3.

Optional, not required by the new plan (not written): an index on
`eventcontactsxref_tbl(eventID, IsDeleted, contactID)` would replace the 8,160-row hash join
with lookups.

## 3. Idempotency definitions

| Operation | Rule | Guard |
| --- | --- | --- |
| Event completion | An event moves Active -> Completed at most once. A re-run is a no-op. | `UPDATE ... WHERE eventid=? AND eventstatus='Active'` (new). One cftransaction per event: if any step fails, the event stays Active and nothing from it persists. |
| Follow-up enrollment | At most one Active `fusystemusers` row per (userid, contactID, systemID). A Follow-Up (1/2) is not added when an Active Target (3/4) exists. | DB: `uq_active_enrollment` UNIQUE(userid, contactID, systemID, active_guard) - verified on prod and dev. Code: snapshot map + new per-candidate DB re-check (`enrolledNow`), so a stale map no longer turns into a duplicate-key rollback that retries the event every night. |
| Reminder seeding (`funotifications`) | Only created as a child of an enrollment inserted in the same transaction (keyed by the new suID). | Follows from the enrollment guard. `funotifications` has no contactid; it links via suID. |
| Bell notification (`notifications`) | One per new enrollment. | Same as above. |
| Target close-out (systems 5/6) | Status UPDATE. | Naturally idempotent. |
| Concurrency | One run at a time. | Existing `cflock name="sched_events_completed"` (3s, no throw). |

Gap: not deduplicated across separate events. The same contact on two events in one batch is
handled by the map; a later run is handled by the DB re-check.

## 4. Backlog (prod, 2026-10-17, live users, past-due, still Active)

| Age of eventstop | Events | Users |
| --- | --- | --- |
| 0-14 days | 0 | 0 |
| 15-60 days | 198 | 13 |
| 61-180 days | 189 | 18 |
| 181-365 days | 532 | 46 |
| > 365 days | 417 | 43 |

There are 1,956 xref rows, of which 58 point at deleted or missing contacts (excluded
automatically: the contactdetails view filters IsDeleted). No events belong to users with
`userstatus='cancelled'`.

## 5. Decisions Kevin must make (pick one per row)

| # | Question | Options |
| --- | --- | --- |
| D1 | Which old events get follow-ups at all? | (a) none: mark >N days Completed with no enrollment; (b) only 15-60 days; (c) all |
| D2 | Start date for drained enrollments and reminders | (a) the event's stop date, as today (reminders arrive already past due, which floods the bell and dashboard); (b) today, staggered by `actionDaysNo` |
| D3 | Bell notifications for drained events | (a) suppress; (b) one summary per user; (c) one per contact, as today |
| D4 | Should the nightly default `staleDays` stay at 14? | |

D1(a) and D2(b) need small additions to the job (a "complete-only" mode and a "start today"
mode). These have NOT been written; they would be written only after the decision.

## 6. Recovery procedure (after approval, dev first)

1. Deploy the fix to dev. Run `?dryrun=1&includeStale=1&batchSize=50` and check `elapsedSec`
   and `followupCandidates`.
2. Prod dry run: `?dryrun=1` (nightly mode), then `?dryrun=1&includeStale=1&batchSize=50`.
   No writes in either. Record the JSON.
3. Capture a baseline before any write run:
   ```sql
   SELECT MAX(suID) FROM fusystemusers_tbl;
   SELECT MAX(notID) FROM funotifications_tbl;
   SELECT MAX(id) FROM notifications;
   SELECT COUNT(*) FROM events_tbl WHERE eventStatus='Active' AND eventStop < CURDATE();
   ```
4. Supervised batches: `?includeStale=1&batchSize=25&timeBudgetSec=300`, oldest band only as
   D1 allows. After each batch, compare the counts below. **Stop** if eventsFailed > 0, if
   enrollments per event exceed 10, or on any duplicate-key error in the CF log.
   ```sql
   SELECT COUNT(*) FROM fusystemusers_tbl WHERE suID > :base_suid;
   SELECT COUNT(*) FROM funotifications_tbl WHERE notID > :base_notid;
   SELECT userid, contactID, systemID, COUNT(*) FROM fusystemusers
     WHERE sustatus='Active' GROUP BY 1,2,3 HAVING COUNT(*) > 1;  -- must be empty
   ```
5. The job checkpoints itself: each event commits alone, and unprocessed events stay Active.
   Resume = run again.

## 7. Rollback

- Code: restore the previous `sched/events_completed.cfm` (HEAD) on the server.
- Data from a supervised run: every row created has an id above the baseline captured in step
  3. Reverse in one transaction:
  1. Soft-delete those `funotifications_tbl` and `fusystemusers_tbl` rows (`IsDeleted=1`).
  2. Delete those `notifications` rows.
  3. Set events back to Active where they were completed in the run window.

  That window needs the event ids from the CF log. The job does not record them today, so
  per-event logging should be added before any write run. Systems 5/6 closed out during the run
  cannot be told apart from earlier close-outs without the same log.
