/**
 * IcsService.cfc
 *
 * TAO-CAL-01: single, safe path for per-user ICS calendar generation.
 * Replaces the two legacy generators (include/icsmaker.cfm, sched/icsmaker.cfm).
 *
 * Design:
 *   - Single public method generateUserIcs(userid) — synchronous, one user only.
 *   - Callers decide sync vs async (see EventService.fireIcsRegen).
 *   - Never rethrows. All failures are logged to ics_service and swallowed so that
 *     an ICS glitch cannot take down the page or a business transaction.
 *   - Application-scoped singleton; safe to call from detached threads and from
 *     scheduled tasks because it reads no session/request scope.
 *
 * Known-good logic ported from include/icsmaker.cfm with P0/P1/P2 fixes:
 *   - P0: stable UID "tao-event-{eventID}@theactorsoffice.com" (was CreateUUID every run).
 *   - P0: utcHourOffset defaults to 0 on lookup miss (was "Gregorian").
 *   - P0: events with no eventStart are skipped + logged, not cfabort.
 *   - P1: LEFT JOIN eventtypes with COALESCE so unknown/renamed types don't drop the
 *         entire user's calendar. TODO(TAO-CAL-02): persist per-event color/type copy.
 *   - P2: caller is explicit — no more page-load regen side effect.
 *
 * @author TAO Development
 * @created 2026-04-18
 */
component displayname="IcsService" output="false" {

    variables.PRODID   = "TheActorsOffice";
    variables.CALNAME  = "TAO Calendar";
    variables.CALSCALE = "Gregorian";
    variables.CRLF     = chr(13) & chr(10);

    public boolean function generateUserIcs(required numeric userid) {
        try {
            var dsn = application.dsn;

            var qUser = queryExecute(
                "SELECT userid,
                        REPLACE(REPLACE(recordname, ' ', ''), '-', '') AS calendarName,
                        recordname, userFirstName, userLastName, userEmail, tzid
                 FROM taousers
                 WHERE userid = :userid",
                { userid: { value: arguments.userid, cfsqltype: "cf_sql_integer" } },
                { datasource: dsn }
            );

            if (qUser.recordCount EQ 0) {
                writeLog(file="ics_service", type="warning",
                    text="generateUserIcs skipped: userid=" & arguments.userid & " not found");
                return false;
            }

            var calendarName = trim(qUser.calendarName);
            if (NOT len(calendarName)) {
                writeLog(file="ics_service", type="warning",
                    text="generateUserIcs skipped: userid=" & arguments.userid & " empty calendarName");
                return false;
            }

            var tzid = len(qUser.tzid) ? qUser.tzid : "America/Los_Angeles";

            var qTz = queryExecute(
                "SELECT utchouroffset FROM timezones WHERE tzid = :tzid",
                { tzid: { value: tzid, cfsqltype: "cf_sql_varchar" } },
                { datasource: dsn }
            );
            var utcHourOffset = 0;
            if (qTz.recordCount GT 0 AND isNumeric(qTz.utchouroffset)) {
                utcHourOffset = qTz.utchouroffset;
            }

            // TODO(TAO-CAL-02): persist per-event type/color snapshot on events_tbl so the
            // ICS does not depend on an eventtypes row still existing at regen time.
            var qEvents = queryExecute(
                "SELECT e.eventID,
                        e.eventTitle,
                        e.eventDescription,
                        e.eventLocation,
                        e.eventStart,
                        e.eventStop,
                        e.eventStartTime,
                        e.eventStopTime,
                        e.eventTypeName,
                        DATE_FORMAT(COALESCE(e.eventStartTime, '09:00:00'), '%k') AS starthours_h,
                        DATE_FORMAT(COALESCE(e.eventStopTime, '17:00:00'), '%k')  AS stophours_h,
                        COALESCE(t.eventtypecolor, '##808080') AS eventtypecolor
                 FROM events e
                 LEFT JOIN eventtypes t ON t.eventtypename = e.eventTypeName
                 WHERE e.userid = :userid
                   AND e.eventStart IS NOT NULL
                   AND e.eventStop  IS NOT NULL
                   AND e.eventstatus = 'Active'
                   AND e.isdeleted   = 0",
                { userid: { value: arguments.userid, cfsqltype: "cf_sql_integer" } },
                { datasource: dsn }
            );

            var ics = "BEGIN:VCALENDAR" & variables.CRLF
                    & "PRODID:" & variables.PRODID & variables.CRLF
                    & "VERSION:2.0" & variables.CRLF
                    & "CALSCALE:" & variables.CALSCALE & variables.CRLF
                    & "X-WR-CALNAME:" & variables.CALNAME & variables.CRLF
                    & "X-WR-TIMEZONE:" & tzid & variables.CRLF;

            var written = 0;
            var skipped = 0;

            for (var ev in qEvents) {
                // P0: skip rows we cannot serialize instead of cfabort
                if (NOT isDate(ev.eventStart)) {
                    skipped++;
                    writeLog(file="ics_service", type="warning",
                        text="skip event eventID=" & ev.eventID
                           & " userid=" & arguments.userid
                           & " reason=no eventStart");
                    continue;
                }

                var initialStart = ev.eventStart;
                var initialEnd   = isDate(ev.eventStop) ? ev.eventStop : ev.eventStart;

                var timeStart = len(ev.eventStartTime) ? ev.eventStartTime : "12:00:00";
                var timeEnd   = len(ev.eventStopTime)  ? ev.eventStopTime  : "13:00:00";

                var startHours = val(reReplace(ev.starthours_h, "[^0-9\-]", "", "all"));
                var stopHours  = val(reReplace(ev.stophours_h,  "[^0-9\-]", "", "all"));
                var finalStart = startHours + utcHourOffset;
                var finalStop  = stopHours  + utcHourOffset;

                var dateStart = initialStart;
                if (finalStart GTE 24) {
                    dateStart = dateAdd("d",  1, initialStart);
                } else if (finalStart LTE 0) {
                    dateStart = dateAdd("d", -1, initialStart);
                }

                var dateEnd = initialEnd;
                if (finalStop GTE 24) {
                    dateEnd = dateAdd("d",  1, initialEnd);
                } else if (finalStop LTE 0) {
                    dateEnd = dateAdd("d", -1, initialEnd);
                }

                var description = icsEscape(ev.eventDescription);
                var location    = icsEscape(ev.eventLocation);

                ics &= "BEGIN:VEVENT" & variables.CRLF;
                // P0: stable UID so calendar clients update in place instead of duplicating.
                ics &= "UID:tao-event-" & ev.eventID & "@theactorsoffice.com" & variables.CRLF;
                ics &= "SUMMARY:" & ev.eventTitle & variables.CRLF;
                ics &= "DESCRIPTION:" & description & variables.CRLF;
                ics &= "LOCATION:" & location & variables.CRLF;
                ics &= "DTSTART:"
                     & dateFormat(dateStart, "yyyymmdd") & "T"
                     & timeFormat(dateAdd("h", utcHourOffset, timeStart), "HHmmss") & "Z"
                     & variables.CRLF;
                ics &= "DTEND:"
                     & dateFormat(dateEnd, "yyyymmdd") & "T"
                     & timeFormat(dateAdd("h", utcHourOffset, timeEnd), "HHmmss") & "Z"
                     & variables.CRLF;
                ics &= "DTSTAMP:"
                     & dateFormat(now(), "yyyymmdd") & "T"
                     & timeFormat(now(), "HHmmss") & "Z"
                     & variables.CRLF;
                ics &= "END:VEVENT" & variables.CRLF;
                written++;
            }

            ics &= "END:VCALENDAR";

            var calendarDir  = application.baseMediaPath & "\calendar";
            var calendarPath = calendarDir & "\" & calendarName & ".ics";

            if (NOT directoryExists(calendarDir)) {
                // ACF 2021 rejects the second (createPath) arg here; default is createPath=true anyway.
                directoryCreate(calendarDir);
            }

            fileWrite(calendarPath, trim(ics));

            writeLog(file="ics_service", type="information",
                text="ok userid=" & arguments.userid
                   & " events=" & written
                   & " skipped=" & skipped
                   & " path=" & calendarPath);

            return true;

        } catch (any e) {
            writeLog(file="ics_service", type="error",
                text="fail userid=" & arguments.userid
                   & " msg=" & left(e.message, 300)
                   & " detail=" & left(e.detail ?: "", 300));
            return false;
        }
    }

    private string function icsEscape(any value) {
        if (isNull(arguments.value) OR NOT len(arguments.value)) return "";
        var s = arguments.value;
        s = replace(s, chr(13), "\n", "all");
        s = replace(s, chr(10), "\n", "all");
        s = replace(s, ",",     "\,", "all");
        return s;
    }

}
