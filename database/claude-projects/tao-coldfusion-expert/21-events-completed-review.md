# sched/events_completed.cfm Review

Generated: 2026-04-18
File: `sched/events_completed.cfm` (639 lines after annotation; ~441 lines of code)
Runs: nightly via ColdFusion scheduler
Owner question: "It cleans up issues with the events table. What does it do end-to-end, and which pieces could move to real-time?"

---

## 1. What this job actually does

Despite the filename, this script performs **four** distinct maintenance jobs, only one of which is about events.

| Job | Target | What it does |
|-----|--------|--------------|
| A | `funotifications` | Flips `notstatus` from `Future` -> `Active` once `notstartdate` has passed |
| B | `taousers_tbl`    | Soft-deletes (`isdeleted = 1`) users whose `thrivecart.canceldate` has passed and whose `userstatus = 'cancelled'` |
| C | `events` + `fusystemusers` + `funotifications` + `notifications` | Auto-completes past-due Active events, enrolls each tagged contact in the Follow-Up (systemid 1) or Industry Follow-Up (systemid 2) system, seeds the first action notification, completes any existing Target systems (5, 6), and writes a UI bell notification |
| D | `contactdetails` | Backfills `contactmeetingdate` and `contactMeetingloc` from the oldest completed event per contact, **only where the fields are NULL** |

All four jobs are the **only** real-time-independent authors for their respective state changes. See section 4 for redundancy analysis.

---

## 2. Execution flow (end-to-end)

```
remote_load.cfm               -- pulls dsn / rev / suffix from application scope
|
+-- JOB A: funotifications Future -> Active
|     [future]    SELECT  (audit, debug only -- result unused)
|     [activefix] SELECT  (audit, debug only -- result unused)
|     [upactive]  UPDATE  funotifications SET notstatus='Active'
|                         WHERE notstartdate < today AND notstatus='Future'
|
+-- JOB B: cancelled user soft-delete
|     [c] SELECT taousers JOIN thrivecart
|         WHERE userstatus='cancelled' AND canceldate < SYSDATE()
|     [s] UPDATE taousers_tbl SET isdeleted=1 WHERE userid IN (...)
|
+-- JOB C: driver + batch preload + per-event transaction loop
|     [events]              SELECT events WHERE eventstatus='Active' AND eventstop < CURDATE()
|     -- WO-4.1 preloads (outside loop) --
|     [allFollowups]        UNION of systemid=1 and systemid=2 follow-up candidates
|     [allEnrollments]      all active fusystemusers for batch users
|                           -> enrollmentSets{ "userid|contactid" -> "systemid,systemid,..." }
|     [allSystemInfo]       all fusystems (builds systemInfoMap -- UNUSED)
|     [allActionSchedules]  all (system, user) first-action rows
|                           -> actionScheduleMap{ "systemid|userid" -> {actionid, actionDaysNo, isUnique, uniquename} }
|     allowedUniqueColumns  whitelist for dynamic uniqueness-check column
|
|     FOR EACH event:
|       <cftransaction>
|         [fu] QoQ filter of allFollowups by this eventid
|
|         FOR EACH follow-up contact in fu:
|           check enrollmentSets; skip if already enrolled (or in Target 3/4 when target is 1/2)
|           IF not enrolled:
|             [addSystem]             INSERT fuSystemUsers                 -> NewSUID
|             update enrollmentSets in memory (not rolled back on tx fail)
|             [CompleteTargetSystems] UPDATE fusystemusers SET sustatus='Completed' WHERE systemid IN (5,6)
|             [Insert]                INSERT notifications (UI bell)
|             look up actionScheduleMap[systemid|userid]
|             IF isUnique=1:
|               whitelist-check uniquename -> SELECT contactdetails.<col>='Y' -> maybe skip
|             compute notstartdate = suStartDate + actionDaysNo
|             IF notstartdate <= suStartDate:
|               [addNotification] INSERT funotifications (no explicit status -> DB default)
|             ELSE:
|               [addNotification] INSERT funotifications (notstatus='Pending')
|         END FOR
|
|         [update] UPDATE events SET eventstatus='Completed' WHERE eventid=?
|       </cftransaction>
|     END FOR
|
+-- JOB D: contactdetails backfill (own cftransaction, WO-4.4)
      [uppdate_when]  UPDATE contactdetails cd
                       JOIN (SELECT contactid, MIN(eventstop) FROM eventcontactsxref JOIN events
                             WHERE eventstatus='Completed' AND eventstop<CURDATE()
                             GROUP BY contactid) sub ON cd.contactid=sub.contactid
                       SET cd.contactmeetingdate = sub.oldest WHERE cd.contactmeetingdate IS NULL
      [uppdate_where] Same shape, writes contactMeetingloc from eventtitle
```

Performance posture is good today: WO-4.1 collapsed per-contact SELECTs into pre-loaded maps, and WO-4.4 isolated the bulk backfill from the event-by-event transaction.

---

## 3. What depends on this job (downstream impact if it stops running)

| Consumer | Dependency | Failure mode if job stops |
|----------|------------|---------------------------|
| Notification dropdown / badge (`NotificationStatusService.cfc`, services/NotificationStatusService.cfc:36-37, 86-87) | Reads `notstatus='Future'` at query time; relies on Job A having flipped due rows to `Active` | Due reminders become invisible; users miss follow-ups |
| Calendar / dashboard "past events" filter | Assumes `eventstatus='Completed'` once `eventstop` is in the past | Past events linger as "Active"; filters/reports misrender |
| Relationship system workflows | Follow-up actions kick off only when Job C inserts fusystemusers + funotifications | Meetings never convert to follow-up reminders |
| `/ipn-handler.cfm` cancellations | Webhook writes `thrivecart_tbl` but does NOT soft-delete the user; Job B is what retires the account | Cancelled users stay fully active until the cron runs |
| Analytics on `contactdetails.contactmeetingdate` | Job D is the only source today | Field stays NULL for contacts who met via an event that was not manually set |

---

## 4. Redundancy check: is any of this also wired real-time?

Verified via codebase search. None of the four jobs has a real-time counterpart today.

- **Event completion (Job C)**. No UI handler, AJAX endpoint, or service method sets `eventstatus='Completed'`. `ajax/calendar-event-update.cfm` updates start/stop times only. `services/EventService.cfc` references the status in a comment but has no setter. The scheduled file `sched/events_completed_wo_system.cfm` is a variant that runs for already-completed events without a system -- it is not a real-time path.
- **Follow-up enrollment (Job C)**. `services/SystemUserService.cfc` has `INSfusystemusers_*` helpers (lines 108, 131, 218, 407), but they are only invoked from `/include/qry/addSystem*.cfm` fragments. Those fragments have no traced upstream caller in ajax/ or the UI event-completion path.
- **Contactdetails backfill (Job D)**. No real-time writer for `contactmeetingdate` / `contactMeetingloc`.
- **Cancelled user soft-delete (Job B)**. `/ipn-handler.cfm` exists and writes `thrivecart_tbl`, but does not touch `taousers_tbl.isdeleted`. `/ipn-cancelled.cfm` is a debug email logger.
- **Notification Future->Active flip (Job A)**. UI code reads `notstatus` directly; nothing recomputes on read.

---

## 5. Known gaps in the current implementation

| # | Severity | Issue | Location |
|---|----------|-------|----------|
| 1 | Low     | `future` query result is selected but never read outside the `dbug=Y` panel. Dead work on every run. | lines 59-64 |
| 2 | Low     | `activefix` query selected but never read outside the `dbug=Y` panel. The downstream UPDATE could drop the SELECT entirely. | lines 81-85 |
| 3 | Low     | `allSystemInfo` -> `systemInfoMap` built but never consulted. Remove or start using it for notification subjects. | lines 180-197 |
| 4 | Medium  | In-memory `enrollmentSets` is mutated mid-transaction (line ~345) and **not unwound if the `cftransaction` rolls back**. If a later event's contact shares a key with a rolled-back enrollment, this run will incorrectly believe the contact is enrolled and skip the insert. Next run will recover. | line 345 |
| 5 | Medium  | No error handler. A raised exception inside the loop aborts the entire run -- subsequent events remain Active until tomorrow. Consider wrapping each event in `<cftry>` with a `cflog` entry, letting the run continue. | loop at line 242 |
| 6 | Medium  | No audit log / run summary. Hard to answer "did the cron run last night? how many events did it complete?" after the fact. | whole file |
| 7 | Low     | No authorization check at the top of the page. If the URL is reachable externally, anyone can trigger a full cleanup pass. Confirm it is blocked at the web-server or CF-admin level. | top of file |
| 8 | Low     | `uppdate_when` / `uppdate_where` -- typo'd query names. Cosmetic. | lines 511, 527 |
| 9 | Low     | Empty `<cfelse>` branch on the `alreadyEnrolled` guard. No-op; remove for clarity. | line ~460 |
| 10 | Low     | `SYSDATE()` on line 104 vs `CURDATE()` used elsewhere. `SYSDATE()` includes time; if a canceldate is midnight today it will be caught; functionally fine but inconsistent. | line 104 |
| 11 | Medium  | JOB D `uppdate_where` selects `e.eventtitle` alongside `MIN(e.eventstop)` while grouping only by `contactid`. The title is taken from an **arbitrary** row in the group, not the oldest event, so `contactMeetingloc` can be backfilled from the wrong event (and the query may be rejected outright under `ONLY_FULL_GROUP_BY`). Pre-existing; deliberately left unchanged by the 2026-05-16 perf pass to keep that change behavior-neutral. Needs a correctness fix (correlated subquery, or a window function picking the row at `MIN(eventstop)`). | JOB D `uppdate_where` |

None of these are currently breaking production, but #4-#6 and #11 are the ones to fix first (#4-#6 reliability, #11 data correctness).

---

### Update 2026-05-16: performance remediation applied

The "performance posture is good" note in section 2 no longer held -- the job was exceeding `requesttimeout=600`.

**ROOT CAUSE -- established by live prod measurement 2026-05-17 (`actorsbusinessoffice`, MySQL 8.0.41):**

The cause is **not** SQL cost, table size, missing indexes, or the JOB A `SELECT *`. Every relevant table is tiny and fully indexed in prod, and the data the "expensive" queries touch is trivial:

| Signal | Prod value | Implication |
|---|---|---|
| funotifications_tbl rows | 81,207 (5.5 MB) | sub-second even on a full scan |
| events_tbl rows | 5,327 (2.5 MB) | trivial |
| eventcontactsxref_tbl rows | 6,841 | trivial |
| all 3 "missing" indexes | **present in prod** | index hypothesis dead |
| JOB A rows to flip | **0** | JOB A does nothing |
| JOB A `SELECT *` set | **65 rows** | the "fix" was hygiene, not the cause |
| **JOB C backlog (Active, past-due)** | **952 events, all >7 days old** | **the actual problem** |

The real cause: the cron times out, so it completes few/no events, so past-due Active events **accumulate** (now 952). Each event runs a `cftransaction` with an inner per-contact loop of ~4-5 sequential round-trip queries (`addSystem`, `CompleteTargetSystems`, `notifications` insert, `checkUnique`, `addNotification`), plus per-event begin/commit. Against a **remote** MySQL (`46.31.66.114`), 952 events ≈ 10,000+ sequential network round trips + 952 remote InnoDB commits. This is **latency-bound chattiness amplified by a self-reinforcing backlog**, and it lands right at the 600 s wall. Without per-event isolation, one failing event in the 952 aborts the whole run and completes nothing -- the spiral that built the 952.

**What the applied code changes are actually worth, re-judged against this:**

- **Per-event `cftry` isolation -- the real fix.** Breaks the spiral: a bad event no longer wastes the whole 600 s; the run drains what it can.
- **`?maxEvents` backlog cap -- default corrected 1500 -> 300 (2026-05-17).** The original 1500 exceeded the 952 backlog and so would **not engage**; 300 is below it, so each run now makes bounded forward progress and drains oldest-first. 300 is a conservative estimate -- calibrate from the new `END` cflog `elapsedSec`/`eventsProcessed`. For the initial catch-up, drain in chunks with `?maxEvents=200` over successive runs. Once the 952 is cleared, daily volume is tiny and the job finishes fast even over remote latency.
- **Run-summary `cflog` -- the critical instrument.** It is how drain progress and per-run cost get measured. Deploy this first.
- JOB A `SELECT *`→`COUNT(*)` and JOB D bounding: harmless hygiene, **not** the cause (65 rows / tiny tables). Keep, but do not credit them with fixing the timeout.

**Index migration `2026-05-16_events_completed_perf_indexes.sql` -- DO NOT SHIP expecting effect.** Confirmed a **no-op on both dev and prod** (all three indexes already exist in both). A real bug in it was fixed (it targeted the `eventcontactsxref` view instead of `eventcontactsxref_tbl`), but its remediation value is zero. Recommend discarding it, or keeping only as a documented idempotent guard. `verify-indexes.sql` is a *recommendations* doc, not live state -- trusting it produced the wrong initial diagnosis.

**The durable structural fix (follow-up, larger):** eliminate the per-row chattiness -- batch the inner-loop writes (multi-row INSERT, set-based `CompleteTargetSystems`), or move the whole job server-side / co-locate the cron with the DB to kill the network round-trip tax. The current changes drain and stabilize; they do not remove the O(events × contacts) round-trip design.

Other open follow-ups:
- Redundant indexes in **both** dev and prod (`idx_funotifications_notstatus`, `idx_funotifications_notstartdate` on funotifications_tbl) add write overhead on a table this job hammers -- candidate for a cleanup migration like `2026-04-03_drop_redundant_single_column_indexes.sql`.
- Issue #11 (JOB D `eventtitle` nondeterminism).
- Investigate *why* the backlog first formed (initial timeout trigger): event volume spike, a poison event, or an earlier deploy.

---

## 6. Real-time migration analysis

The question: "can any of this maintenance be controlled real-time?" Taken job by job, with a recommendation and the tradeoff for each.

### Job A -- Future -> Active notstatus flip -- STRONG candidate

**Why it exists.** UI reads `notstatus='Future'` directly, so a due notification is hidden until this nightly flip runs.

**Real-time options (pick one):**
1. **Eliminate the state entirely.** Make `NotificationStatusService` filter on `notstartdate <= NOW()` directly. Stop writing `'Future'` as a distinct state; every pending notification is `Active` with a start date. Simpler data model, no lag, no cron step.
2. **Computed/virtual column or view.** Add a generated column `isDue = notstartdate <= NOW()` or a `v_funotifications` view that projects the derived state. UI reads from the view.
3. **MySQL event scheduler.** A tiny DB-level job that runs the same UPDATE every minute. Removes UI lag to <= 1 minute without changing app code.

**Recommendation:** option 1 (eliminate). `Future` is redundant with `notstartdate`. The only thing it buys us is a cheap index hit, which option 2/3 can preserve without a cron.

**Risk:** any report or dashboard that counts rows by `notstatus='Future'` needs to switch to the date comparison. Audit needed.

### Job B -- Cancelled user soft-delete -- STRONG candidate

**Why it exists.** Thrivecart webhook does not propagate cancellations to `taousers_tbl.isdeleted`.

**Real-time option.** Extend `/ipn-handler.cfm` (or add a new webhook handler for the cancellation event) to set `taousers_tbl.isdeleted = 1` when the inbound event signals cancellation **and** the stored `canceldate` is in the past; for future-dated cancellations, schedule via a small due-date check on login.

**Recommendation:** move it. The nightly pass can then become a safety net that runs weekly instead of daily.

**Risk:** IPN handlers can receive duplicate or out-of-order events. Guard on `userstatus='cancelled' AND canceldate IS NOT NULL AND canceldate <= NOW()` and make the UPDATE idempotent (it already is).

### Job C -- Event completion + follow-up enrollment -- MEDIUM candidate, high value

**Why it exists today.** Events transition from Active to Completed only by time passing; nothing in the UI fires when that happens.

**Real-time options:**
1. **Event-completion service.** Create `EventService.complete(eventId)` that encapsulates: mark completed, load tagged contacts, enroll in systems 1/2 (respecting Target 3/4 precedence), insert `fusystemusers`, `funotifications`, `notifications`, complete Target 5/6, update contactdetails meeting date/loc (Job D responsibility -- see below). Call from:
   - A "Mark Completed" button in the calendar / event modal (manual path).
   - A low-frequency cron (e.g. every 15 min) or the MySQL event scheduler for automatic time-based completion.
   - Any future webhook that signals an event happened.
2. **Database trigger + queue.** On `events.eventstatus` flipping to `Completed`, a trigger enqueues a row in a processing table and a CF process drains it. Heavier; not justified here.

**Recommendation:** option 1. The payoff is that users who mark an event complete immediately see the follow-up system created instead of waiting until tomorrow. Keep the nightly cron as a safety net that picks up any events missed by the real-time path.

**Risks / complexity:**
- The logic is not trivial: tag-driven enrollment (C vs I tags, eventtype exclusions), Target-supersedes-Follow-Up, uniqueness with whitelisted columns. Moving it to a service first (without changing behavior) is the right intermediate step -- then add callers.
- Transactional boundary: the service method must own the `cftransaction` so manual and cron callers get the same guarantees.
- The in-memory enrollment-set optimization (batch-level dedupe) does not translate directly to a per-event service call; single-event calls can rely on the live DB state with no material perf hit.

### Job D -- contactdetails meeting-date/loc backfill -- WEAK candidate

**Why it exists.** Historical: older rows were written without these fields. The job refills them only when NULL.

**Real-time option.** When an event is created (or completed -- pick one; creation is cleaner since the field describes "when first met"), write `contactmeetingdate` / `contactMeetingloc` on the linked contactdetails row if currently NULL. Natural home: `EventService.create()` / `EventService.complete()`.

**Recommendation:** fold into Job C's real-time service, and let the nightly backfill wind down as the NULL population approaches zero. Eventually delete the job.

**Risk:** minimal -- the backfill is already idempotent (`WHERE contactmeetingdate IS NULL`), so running both in parallel is safe.

---

## 7. Recommended roadmap

Sequenced so each step is independently shippable and reversible.

1. **Clean up dead code inside the current cron** (issues #1-#3, #9 above). One small PR; reduces noise for future readers.
2. **Add a run-summary `cflog`** (issue #6) so we can audit cadence and volumes before we start moving logic out.
3. **Extract `EventService.complete(eventId)`** with the current logic intact. No behavior change; the cron starts calling the service for each event. This makes every later move a single-caller refactor.
4. **Wire `/ipn-handler.cfm` to call a `UserService.cancel(userId)`** that runs Job B's logic for a single user. Flip the nightly Job B to a weekly safety net.
5. **Add a "Mark completed" real-time path** that calls `EventService.complete`. Users see follow-up systems appear immediately. Cron remains as catch-all.
6. **Eliminate the `Future` notstatus state** in favor of date-based filtering in `NotificationStatusService`. Remove Jobs A part 1 and the UPDATE. Ship after the reporting audit in section 6.
7. **Move contactmeetingdate/loc writes into `EventService.create`** and reduce Job D to a monthly cleanup.

Each step ends with the cron still functioning; if any move misbehaves in prod, revert the caller without touching the scheduled job.

---

## 8. Verification checklist (for any change to this file)

- [ ] Run `?dbug=Y` against dev and confirm all four job panels render and report non-zero only where expected.
- [ ] Confirm `funotifications` row counts by `notstatus` before/after on a dev snapshot with past-dated `Future` rows.
- [ ] Confirm one completed event in dev produces exactly one `fusystemusers` row per tagged contact, one matching `funotifications` row, one `notifications` row, and completes any prior systemid 5/6 enrollments for that contact.
- [ ] Confirm `contactdetails.contactmeetingdate` / `contactMeetingloc` get set only where previously NULL.
- [ ] `cflog` spot-check: search the CF logs for `events_completed` entries to confirm the run happened and volumes look sane.
- [ ] For any real-time migration: dual-run the cron in safety-net mode for at least one week and confirm it finds zero work to do.
