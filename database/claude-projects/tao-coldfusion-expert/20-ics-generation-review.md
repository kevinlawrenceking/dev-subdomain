# ICS Generation Architecture Review

Generated: 2026-04-18
Owner question: when should the per-user `.ics` file be regenerated? Current scheme is overkill and has been source of prod errors.

---

## 1. What the ICS feed is for

TAO lets actors "subscribe" their Apple / Google / Outlook calendar to a TAO-generated `.ics` feed so their TAO events (appointments + auditions) show up in their personal calendar app.

- On `/app/calendar-appoint/` (the in-app calendar page) there is a **Subscribe** button (top right).
- Click → modal renders `#session.userCalendarUrl#` (e.g. `https://app.theactorsoffice.com/media-abo/calendar/JaneDoe.ics`).
- The actor copies that URL into Apple/Google/Outlook as a subscribed calendar.
- Their calendar client polls that URL on its own cadence (Apple default ~1h, Google ~12h typical) and updates.

The TAO web UI itself does **not** consume the ICS file. The in-app calendar renders from `ajax/calendar-events.cfm` → JSON → FullCalendar v6. So the `.ics` file only matters for **external subscribers**.

---

## 2. Current architecture (as-is)

Two near-identical copies of the ICS generator exist:

| File | Triggered by | Scope |
|------|--------------|-------|
| `include/icsmaker.cfm` | `cfinclude` from `include/qry/calendar-appoint.cfm:3` on every calendar page view | Writes the current user's `.ics` |
| `sched/icsmaker.cfm` | Scheduled task every 10 minutes | Loops **all** `taousers` and rewrites every user's `.ics` |

### Page-view call chain
```
GET /app/calendar-appoint/
  → app/calendar-appoint/index.cfm
  → /include/core.cfm
  → /include/pgload.cfm (line 5)
  → /include/fetchPageService.cfm   (resolves pgFilename = "calendar-appoint.cfm")
  → /include/qry/calendar-appoint.cfm   (dynamic include, pgload.cfm:52)
  → /include/icsmaker.cfm              (static include, qry/calendar-appoint.cfm:3)
```

### File output path
```
C:\home\theactorsoffice.com\media-#dsn#\calendar\#calendarname#.ics
```
Served statically from `https://{host}.theactorsoffice.com/media-{dsn}/calendar/{calendarname}.ics` (not through CF).

### ICS content
- `BEGIN:VCALENDAR` wrapper with `PRODID`, `VERSION:2.0`, `X-WR-CALNAME`, `X-WR-TIMEZONE`.
- One `VEVENT` per row from `events` where `userid = ?` and `eventStart IS NOT NULL` and `eventStop IS NOT NULL` and `eventstatus = 'Active'` and `isdeleted = 0`.
- Each event: `UID`, `SUMMARY`, `DESCRIPTION`, `LOCATION`, `DTSTART`, `DTEND`, `DTSTAMP`.

---

## 3. Why this is overkill

### 3a. The page-load regen accomplishes nothing for the page viewer
The calendar page does not read the file it just wrote. FullCalendar renders from JSON. The page-load regen is strictly for the benefit of **external subscribers**, who poll on their own clock (hourly at best). Forcing a regen the moment someone opens the page does not make subscribers see changes any sooner -- their next poll is still minutes to hours away.

### 3b. The 10-minute cron regenerates identical bytes for most users
Assume N active users. Every 10 minutes the scheduled task:
- Selects every row from `taousers` (no filter by "has recent event change").
- For each, runs the event query and rewrites the file.
- 99% of those users have not touched an event since the last cycle.

At 500 users, that's `500 * 6 * 24 = 72,000 file writes per day`, ~99% of which produce byte-identical output. Plus 72,000 query round-trips.

### 3c. The cadence mismatches subscriber poll intervals
- Apple Calendar subscribed feeds poll roughly every 1 hour (user-configurable).
- Google Calendar refreshes subscribed `.ics` feeds on an opaque schedule, typically every 8--24 hours.
- Outlook desktop: 1--24 hours depending on version.

Regenerating every 10 minutes gives subscribers no visible benefit 5 out of 6 cycles.

### 3d. The 10-minute cron is the blast radius for NULL-data bugs
The recent prod errors (ERR-2E65C49D, ERR-51FE4DE0) originated here:
- Any single user with a NULL `eventStartTime` or `eventStopTime` caused the whole cron run to throw (prior to the recent COALESCE fix).
- Because the cron runs without a session, it also had to fall back through multiple `session.userSharePath` defaults (see `sched/icsmaker.cfm:7-14`).
- Because it loops all users, one bad row poisons the entire pass for everyone.

Running this less often (or not at all) shrinks the failure surface dramatically.

---

## 4. Bugs visible in the current code (independent of scheduling question)

These should be reviewed regardless of which regeneration strategy we pick. Line numbers are in `include/icsmaker.cfm` (the `sched/` copy has the same bugs plus SQL injection risk on `target_userid`).

1. **`include/icsmaker.cfm:66` -- wrong user scoping.** The outer loop is over `taousers`, but the inner event query uses `e.userid = session.userid`, not the looped `U.userid` or `new_userid`. When called with `target_userid = 0` inside a session, this writes the **session user's events into every user's ICS file**. This is almost certainly wrong. (The `sched/` copy uses `new_userid` on line 66, which is correct, but has no cfqueryparam.)
2. **`sched/icsmaker.cfm:34` and `:66` -- SQL injection.** `target_userid` and `new_userid` interpolated into SQL without `cfqueryparam`. These are internal, but if the scheduled task is ever triggered with URL params, it's an injection vector.
3. **`CreateUUID()` for every VEVENT `UID` on line 243.** iCalendar UIDs must be stable per event across regenerations -- otherwise subscribers see duplicate events, lose dismissed-alarm state, and get duplicate notifications on every poll. Use `"tao-event-" & e.eventID & "@theactorsoffice.com"` instead.
4. **`cfparam name="utcHourOffset" default="Gregorian"` on line 107.** Copy-paste bug -- default should be `0`.
5. **`cfset UTCHourOffset=3` on line 96.** Overwritten 25 lines later; dead code.
6. **Timezone handling is DST-blind.** Line 247-248 does `DateAdd('h', utcHourOffset, timestart)` then appends `Z` (UTC). A fixed hour offset ignores DST transitions -- an event scheduled for 10am PST in January will render at the wrong UTC in July. Either emit proper `VTIMEZONE` blocks with floating local time, or use CF's `DateConvert("local2utc", ...)` which is DST-aware.
7. **No `VTIMEZONE` block.** Clients infer timezone from the `Z` suffix only, combined with the fixed offset -- already broken per point 6.
8. **No CRLF line folding per RFC 5545.** Long `DESCRIPTION`/`LOCATION` lines >75 octets should be folded. Not catastrophic; most clients tolerate it.
9. **No `METHOD:PUBLISH`.** Most subscribe flows work without it, but Outlook is pickier.
10. **`INNER JOIN eventtypes` on string `eventtypename` rather than on `id`.** Slow and fragile to rename.
11. **Two files, same logic.** Maintenance tax; the recent COALESCE fix had to be duplicated.

---

## 5. When *should* the ICS file be regenerated?

The file is stale only when the user's event set has actually changed. Sources of change:

| Event mutation | Code path |
|----------------|-----------|
| Appointment add | `include/appoint-add.cfm`, `ajax/appoint-*` |
| Appointment update | `include/appoint-update*` (eventid update) |
| Appointment delete | `include/appoint-delete.cfm` |
| Audition role add | `include/audition-add.cfm` |
| Audition role update | `include/remote_aud_project_update.cfm`, role update forms |
| Audition role delete | `include/remoteDeleteFormAud*` |
| Event type rename | `include/updateeventtypeupdate.cfm` (affects display color only) |
| Bulk event import | (if any) |

Regenerating on these mutations is the only cadence that matters.

---

## 6. Proposed options

### Option A -- Event-driven regeneration (recommended)

On every event write (add/update/delete), synchronously regenerate the `.ics` for that one user. Remove the page-load include entirely. Reduce the 10-minute cron to a nightly safety-net sweep (or delete it).

**Pros**
- File is always current within seconds of the change.
- Zero wasted writes.
- One user's bad data never blocks another user.
- Eliminates the large-surface cron that produced the recent NPE incidents.

**Cons**
- Have to instrument every event-write path (maybe ~8 files).
- Requires refactoring `icsmaker.cfm` into a function (`generateUserIcs(userid)`) so the write paths can invoke it without the page-load wrapper.

**Subscribe button behavior**
- Also regenerate on Subscribe click as a safety net (one-shot, user-triggered). Harmless if file is already fresh.

### Option B -- Lazy generation at request time

Replace the static `/media-{dsn}/calendar/{name}.ics` URL with a CFM endpoint (`/calendar/{userid-or-hash}.ics`). Generate on each GET, stream the response, no disk writes.

**Pros**
- Always current. No files on disk to get out of sync.
- No cron, no page-load include.
- ETag / Last-Modified lets subscribers skip the body when nothing changed.

**Cons**
- More CPU per subscriber poll (~hourly per user). For N=500 actors that's ~500 CPU bursts/hour, each small.
- Changes the URL contract -- existing subscribers need to migrate or the old static file needs a redirect.
- Slightly more complex: need proper auth-by-URL-token (so the URL itself proves identity, since there's no session on a feed poll).

### Option C -- Dirty-flag cron (incremental)

Keep the cron, but only regenerate users with `ics_dirty = 1`. Set the flag on every event write; clear it after a successful regen.

**Pros**
- Smallest diff from today's architecture.
- Cron cadence is decoupled from file freshness.

**Cons**
- Still writes a file slightly after the real change (up to cron interval late).
- Still requires instrumenting every event-write path (to set the flag) -- same work as Option A.
- Keeps the cron as a failure surface.

Given that Option A and Option C cost the same to instrument (every event-write path is touched either way) and Option A is always-correct, Option A dominates Option C.

---

## 7. Recommendation

1. **Adopt Option A.** Delete the page-load regen. Delete the 10-minute cron (or reduce to a nightly reconcile at 3am that rebuilds any files missing from disk).
2. **Extract `icsmaker.cfm` into a CFC function**, e.g. `services/IcsService.cfc::generateUserIcs(userid)`. Single implementation; no code duplication between page and sched.
3. **Wire mutation hooks.** In every appointment/audition add/update/delete code path, call `application.services.ics.generateUserIcs(session.userid)` after commit. Do it in a `cfthread` so the write path doesn't block on disk I/O.
4. **Regenerate on Subscribe click** as a user-triggered safety net. Small AJAX call → regenerate → then open modal.
5. **Fix the bugs in Section 4** while the file is already being touched, especially: stable `UID`s (#3), remove `session.userid` in the inner query (#1), and fix the `"Gregorian"` default (#4).
6. **Defer DST-correct timezone handling** to a follow-up unless we see wrong-hour reports -- it is a bigger rewrite.

---

## 8. Open questions for review

1. **Do any subscribers depend on the 10-minute cadence?** If a user changes an event on the web and then immediately checks their Apple Calendar, do they expect it to appear in <10 min? (Apple Calendar's own poll is >10 min anyway, so probably no.)
2. **Are the two copies (`include/icsmaker.cfm` vs `sched/icsmaker.cfm`) ever meaningfully different, or is the duplication purely historical?** If historical, collapse to one function.
3. **Is `session.userCalendarUrl` already correct for every user or does it get rebuilt on login only?** (Application.cfc:344-345 sets it on login -- so users who haven't re-logged may have a stale URL. Worth verifying.)
4. **Should audition events be in the feed?** Current query only filters by `userid`, so it includes all event types. Confirm that's intentional (actors typically want auditions in their personal calendar).
5. **Is the `/media-{dsn}/calendar/` path web-accessible with no auth?** If yes, the `.ics` URL is effectively public-by-obscurity (anyone with the user's `calendarname` -- which is just `FirstnameLastname` with punctuation stripped -- can pull it). Consider URL tokens (HMAC-signed) for Option B, or at least randomizing the filename.
6. **How many active users today?** That determines the cost delta of removing the cron.

---

## 9. Files this proposal would touch

Implementation scope if we adopt Option A + bug fixes:

- **New**: `services/IcsService.cfc` (generateUserIcs function, called from mutation paths)
- **Modified to call service**: `include/appoint-add.cfm`, `include/appoint-update.cfm` (and its variants), `include/appoint-delete.cfm`, `include/audition-add.cfm`, `include/remote_aud_project_update.cfm`, `include/remoteDeleteFormAud*.cfm`, `include/roleupdateform*.cfm`, plus ajax equivalents.
- **Modified**: `include/qry/calendar-appoint.cfm` (remove the `cfinclude icsmaker` line)
- **New AJAX endpoint**: `ajax/ics-regenerate.cfm` (triggered by Subscribe click)
- **Modified**: `include/calendarModalSubscription.cfm` (trigger the AJAX call on modal open)
- **Scheduled-task console**: remove/repurpose the 10-minute trigger for `sched/icsmaker.cfm`
- **Delete or leave as nightly**: `sched/icsmaker.cfm`, `include/icsmaker.cfm` (once service extraction is complete)

Rough effort: half a day for the service + hooks, plus one day of QA against subscribed Apple/Google/Outlook clients.
