# TAO-CAL-01 — ICS Calendar Generation Stabilization

**Workspace:** TAO (The Actors Office)
**Repo:** TAO ColdFusion/MySQL codebase (outside TMZ-Watch monorepo)
**Governance:** No WO number, no KB delta, no Notion updates. TAO is standalone.

---

## Context

Two generator files produce the external `.ics` subscription feed: `include/icsmaker.cfm` (static include from `include/qry/calendar-appoint.cfm:3`, fires on every calendar page view) and `sched/icsmaker.cfm` (scheduled task every 10 minutes, loops all `taousers`). Both are buggy and both do the same job. The cron's blast radius — one bad row poisons the whole pass — caused prod incidents ERR-2E65C49D and ERR-51FE4DE0. The in-app calendar does not consume these files (FullCalendar renders from `ajax/calendar-events.cfm` → JSON); the `.ics` is exclusively for external subscribers (Apple/Google/Outlook).

**Goal of TAO-CAL-01:** eliminate the blast radius, remove wasteful regeneration, collapse duplicate generators into one service, and fix P0/P1 correctness bugs. DST/VTIMEZONE, RRULE, URL security, and richer LOCATION data are deliberately deferred to TAO-CAL-02 and TAO-CAL-03.

## Reference Document

The approved strategic analysis document is attached to this conversation ("ICS Calendar Generation — Strategic Analysis"). Treat Sections 3 (TAO-CAL-01 scope), 4 (refresh strategy), 5 (cfthread pattern), 6 (bug inventory), and 7 (recon items) as authoritative.

## Skills Check

Check for any TAO-specific skill files in the TAO repo (`.agents/skills/` or equivalent). If no TAO skills directory exists, proceed. Standard TMZ-Watch monorepo skills do not apply — this is ColdFusion/MySQL on Hostek VPS.

---

## Scope — IN

1. Extract a single `services/IcsService.cfc` with `generateUserIcs(numeric userid)`. This becomes the only code path that writes `.ics` files.
2. Remove the page-load include from `include/qry/calendar-appoint.cfm:3`.
3. Delete the 10-minute scheduled-task trigger (confirm admin location in Phase A; do not delete until location is confirmed).
4. Replace with a nightly reconcile at 3am (missing-file sweep only for CAL-01; `lastModified` delta sweep is CAL-02 scope).
5. Add event-mutation hooks in each confirmed CRUD path (appointments, auditions, event-type renames). Wrap every hook in `cfthread` per Section 5 pattern.
6. Regenerate on Subscribe click: AJAX endpoint → synchronous `IcsService.generateUserIcs()` → modal opens with URL. Refresh `session.userCalendarUrl` here too (it's set at login only today).
7. **P0 fixes** (correctness / security):
   - `include/icsmaker.cfm:66` — change `session.userid` to `u.userid` in the event query (the outer loop variable).
   - `sched/icsmaker.cfm:34, 66` — wrap `target_userid` and `new_userid` in `cfqueryparam`.
   - Stable `UID:` per event — use `tao-event-{eventID}@theactorsoffice.com`, not `CreateUUID()`. (Current code causes subscribers to see every regen as "all events deleted, all recreated.")
8. **P1 fixes** (correctness, visible to subscribers):
   - `cfparam utcHourOffset default="Gregorian"` → `default=0` (copy-paste bug; value must be numeric).
   - Replace `cfabort` on missing start date with `cflog` + `cfcontinue` (current behavior kills the entire cron run on one bad row).
   - Change INNER JOIN to eventtypes → LEFT JOIN + `COALESCE(eventtypecolor, '#808080')` (current behavior silently drops events with orphaned eventtype).
9. **P2 cleanup** (cruft / maintainability):
   - Remove dead `UTCHourOffset=3` assignment.
   - Remove unused `cfparam` declarations: DATESTART, DATEEND, TIMESTART, TIMEEND, DTSTAMP.
   - Remove dead `starthours_h → starthours` replace (`%k` never produces `h`).
   - Resolve the two divergent calendar-name computations to one (prefer the SQL version).
   - Remove `cfoutput` wrappers that contain only `cfset`.
   - Source `calendar_path` from `application.baseMediaPath`, not hardcoded `C:\home\theactorsoffice.com\media-#dsn#\calendar\`.
   - Wrap generation in try/catch; `cflog` both success and failure to a dedicated log file (e.g., `ics_service`).
10. Delete both legacy generator files (`include/icsmaker.cfm`, `sched/icsmaker.cfm`) **only after** the service is proven working in Phase C. For rollback safety, leave them on disk but unwired until proof passes.

## Scope — OUT (deferred)

- VTIMEZONE / proper DST handling → TAO-CAL-02
- RRULE generation from `dow` / `endRecur` → TAO-CAL-02
- `events_tbl.lastModified` column → TAO-CAL-02
- LOCATION enrichment (audition address fields, parkingDetails, contact join) → TAO-CAL-02
- SEQUENCE, CRLF line folding, METHOD:PUBLISH, LAST-MODIFIED, SUMMARY/LOCATION escaping → TAO-CAL-02
- Subscription URL security (random token) → TAO-CAL-03

---

## Phase A — Recon (READ-ONLY)

Produce a recon report answering:

**A1.** Enumerate all event-mutation paths. Run:
```
grep -r "INSERT INTO events" --include="*.cfm"
grep -r "UPDATE events" --include="*.cfm"
grep -r "DELETE FROM events" --include="*.cfm"
grep -r "INSERT INTO auditions" --include="*.cfm"
grep -r "UPDATE auditions" --include="*.cfm"
grep -r "DELETE FROM auditions" --include="*.cfm"
grep -r "UPDATE eventtypes" --include="*.cfm"
```
List every file + line number. Confirm the ~8 CRUD paths CC identified earlier are complete.

**A2.** Check whether an `EventService.cfc` or similar surface already exists that wraps event CRUD. If yes, the hook can be registered once in that service instead of scattered across N files.
```
find . -name "EventService.cfc" -o -name "AppointmentService.cfc" -o -name "AuditionService.cfc"
grep -rl "services.events" --include="*.cfm"
```

**A3.** Confirm the scheduled-task configuration location. Check in order:
- Lucee/ACF admin scheduled tasks UI (note the path to admin and the exact task name)
- Any `sched/`-triggered cron via OS crontab or Windows Task Scheduler
- Application.cfc or similar for programmatic scheduling
Report which mechanism runs the 10-minute trigger and exactly how to disable it.

**A4.** Confirm `session.userCalendarUrl` usage. It's set at `Application.cfc:344-345` on login only. Find every read:
```
grep -rn "userCalendarUrl" --include="*.cfm" --include="*.cfc"
```
Report all read sites. Confirm whether the Subscribe button modal is the only consumer (expected) or whether other pages depend on it.

Additionally report:
- Confirmed path of `services/` directory (or closest equivalent) where `IcsService.cfc` should live
- Confirmed ColdFusion engine + version (Lucee vs ACF, which version — affects `cfthread` semantics)
- Whether `application.baseMediaPath` is already defined and what it resolves to

**DONE_TOKEN:** `TAO-CAL-01_PHASE_A_COMPLETE`

**STOP GATE** — Do not begin Phase B until Kevin explicitly approves the recon output. If A1 surfaces significantly more than ~8 mutation paths, or A2 reveals an existing service we should hook into, the implementation plan may need adjustment before proceeding.

---

## Phase B — Implementation

Only begin after explicit approval of Phase A recon.

1. Create `services/IcsService.cfc` with `generateUserIcs(numeric userid)`. Port the known-good parts of the existing generators. Apply every P0/P1/P2 fix from Scope items 7/8/9.
2. Stable UID format: `tao-event-{eventID}@theactorsoffice.com`.
3. Apply the `cfthread` wrapper pattern exactly as shown in Section 5 of the analysis doc:
   ```
   <cfthread name="icsRegen_#createUUID()#"
             userid="#session.userid#"
             action="run">
       <cftry>
           <cfset application.services.ics.generateUserIcs(attributes.userid)>
       <cfcatch type="any">
           <cflog file="ics_errors"
                  text="ICS regen failed for user #attributes.userid#: #cfcatch.message#">
       </cfcatch>
       </cftry>
   </cfthread>
   ```
   Pass `userid` via `attributes`, unique thread name with `CreateUUID()` suffix, always wrap in try/catch, never read session scope inside the thread body.
4. Insert the `cfthread` hook after each successful commit in every CRUD path identified in A1.
5. Subscribe AJAX endpoint: synchronous call to `IcsService.generateUserIcs(session.userid)`, then recompute and update `session.userCalendarUrl`, return the URL to the modal.
6. Remove the page-load include at `include/qry/calendar-appoint.cfm:3`.
7. Disable the 10-minute scheduled task via the mechanism identified in A3. Create a new scheduled task firing at 3am daily that invokes a reconcile script. Reconcile script logic:
   ```
   <!--- Missing-file sweep only for CAL-01 (lastModified delta is CAL-02) --->
   SELECT userid, firstName, lastName FROM taousers WHERE active = 1
   ```
   For each user, check `application.baseMediaPath & "/calendar/" & firstName & lastName & ".ics"`. If missing, call `IcsService.generateUserIcs(userid)`. `cflog` the count of regenerated files.
8. Leave both legacy generators on disk but unwired (do not delete yet). This is the rollback path if anything goes wrong in Phase C or post-deploy.

**DONE_TOKEN:** `TAO-CAL-01_PHASE_B_COMPLETE`

---

## Phase C — Proof Bundle

Verify each AC below against actual file contents. Include in the proof bundle:

- File-and-line citations (read each changed file, quote the actual changed lines)
- Output of the recon greps from Phase A showing hook insertion points, with matching cfthread insertion confirmed in each file
- A diff summary (`git diff --stat` if available, or equivalent file list)
- Confirmation that both legacy generator files still exist on disk (rollback safety)
- Confirmation that `include/qry/calendar-appoint.cfm:3` no longer includes the legacy generator
- Confirmation that the 10-min task is disabled and the 3am task is registered (admin UI screenshot or config export)
- `cflog` output from a smoke test: manually trigger an event save in dev, confirm the cfthread fires and `ics_service` log shows success
- Sample generated `.ics` file content showing stable UID (`tao-event-123@theactorsoffice.com` format)

**DONE_TOKEN:** `TAO-CAL-01_PROOF_BUNDLE_COMPLETE`

---

## Acceptance Criteria

1. `services/IcsService.cfc` exists with `generateUserIcs(numeric userid)` and is the only code path that writes `.ics` files (besides the legacy files, which remain on disk but unwired).
2. `include/qry/calendar-appoint.cfm:3` no longer includes `include/icsmaker.cfm`.
3. The 10-minute scheduled task is disabled. A 3am daily reconcile task is registered that runs missing-file sweep only.
4. Every event-mutation CRUD path identified in A1 has a `cfthread`-wrapped `IcsService.generateUserIcs()` call after the commit.
5. Subscribe button AJAX flow regenerates the `.ics` synchronously and refreshes `session.userCalendarUrl`.
6. All P0 fixes applied: `session.userid` → `u.userid` at the outer loop; `cfqueryparam` on `target_userid` and `new_userid`; UID format `tao-event-{eventID}@theactorsoffice.com`.
7. All P1 fixes applied: `utcHourOffset` default is numeric 0; `cfabort` replaced with `cflog`+`cfcontinue`; LEFT JOIN + COALESCE on eventtypes.
8. All P2 cleanup applied: dead assignments removed, unused cfparams removed, `calendar_path` sourced from `application.baseMediaPath`, try/catch + `cflog` around generation, single calendar-name computation used throughout.
9. Both legacy generator files (`include/icsmaker.cfm`, `sched/icsmaker.cfm`) still exist on disk (unwired, for rollback).
10. Smoke test passes: save an event in dev → cfthread fires → `ics_service` log shows success → `.ics` file on disk contains the new event with stable UID.

## Rollback Plan

If anything in Phase C fails or a post-deploy issue emerges: re-enable the 10-minute scheduled task, re-add the include line at `include/qry/calendar-appoint.cfm:3`. Both legacy files are still on disk, so rollback is pure configuration.

---

**Run this in Claude Code against the TAO ColdFusion codebase. After Phase A completes and emits the DONE_TOKEN, paste the recon output back here in this Release Gatekeeper conversation. Do not begin Phase B until I explicitly approve. After Phase B emits its DONE_TOKEN, paste the implementation summary. After Phase C emits its DONE_TOKEN, paste the full proof bundle.**

---

## IT Manager Summary (for Kevin)

The external calendar subscription feed that Apple/Google/Outlook users sync to — the `.ics` file — is currently produced by two separate pieces of code that both have bugs and overlap. One runs every 10 minutes across every user in the system; one bad record stops all of them from updating. That's what caused the recent two production errors. The other one runs every single time anyone opens the calendar page, which is thousands of wasted regenerations a day.

This work order collapses the two generators into one service, has it regenerate only when something actually changes (a new appointment, an updated audition, a Subscribe button click), and adds a nightly safety-net pass at 3am to catch anything missed. The result: ~99% less server work, no more system-wide cascade failures when one user has a bad record, and subscribers see updates just as fast as before because Apple and Google only poll hourly anyway.

A handful of real bugs get fixed in the same pass — wrong variable scoping that could leak one user's events into another's feed, missing parameter binding that was technically SQL-injectable, and unstable event IDs that made every subscriber treat every refresh as "delete everything and re-add it," which was causing duplicate alarm notifications.

What's intentionally not in this work order: daylight-saving-time correctness, recurring events showing up as repeating series (they currently show once), and the subscription URL security (the `.ics` filename is predictable from a user's first+last name). Those are queued as TAO-CAL-02 and TAO-CAL-03 to ship after this stabilization settles.

Rollback is trivial: both original files stay on disk, unwired. If anything goes sideways, re-enabling the scheduled task and one include line restores the old behavior.