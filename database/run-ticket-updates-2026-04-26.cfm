<cfsilent>
<!--- Update recently-resolved tickets to Implemented status on abo (prod) --->
<cfinclude template="/database/admin-guard.cfm">
<cfset datasource = "abo">
</cfsilent>
<!DOCTYPE html>
<html>
<head><title>Ticket Updates 2026-04-26</title></head>
<body style="font-family: Arial, sans-serif; padding: 20px;">
<h2>Update Recently-Resolved Tickets - 2026-04-26</h2>
<p>Datasource: <strong><cfoutput>#datasource#</cfoutput></strong></p>

<cfscript>
successCount = 0;
errors = [];

// Tickets that were resolved in code but not closed.
// Each entry: id, desc, response (paste-block appended to ticketResponse),
// status (target ticketStatus), setCompleted (true/false to stamp ticketCompletedDate=NOW())
tickets = [
    {
        id: 2187,
        desc: "Import relationships - notes size truncation removed",
        status: "Implemented",
        setCompleted: true,
        response: "Removed LEFT(trim(...), 2000) and 250-char truncations on note insert/update paths. Updated noteslog.noteDetails to TEXT (V3_5 migration). Added warning feedback so users are notified if a note could not be saved during import. Files: NoteService.cfc (7 functions), InsertNote_4_1.cfm, InsertNote_169_1.cfm, InsertNote_171_1.cfm, InsertNote_173_1.cfm, InsertNote_308_22.cfm, updatenote_175_1.cfm, updatenote_177_1.cfm, updatenote_179_1.cfm. Notes now store full text without truncation."
    },
    {
        id: 2303,
        desc: "Relationships - ability to add custom unions",
        status: "Implemented",
        setCompleted: true,
        response: "Custom unions can be added/edited via the admin enum dashboard. The audunions table is registered in admin_enums (enum_group='audition', display_name='Unions') and is fully editable from /include/admin-enum-dashboard.cfm with add/edit/soft-delete and per-row inline editing. Files: services/AdminEnumService.cfc, services/AuditionUnionService.cfc, sql/admin_enums_create.sql, include/admin-enum-dashboard.cfm, app/assets/js/admin-enum.js."
    },
    {
        id: 2304,
        desc: "Newsletter setting - active toggle now reflects immediately",
        status: "Implemented",
        setCompleted: true,
        response: "Root cause: newsletter active flag was updating in the database but the cached session value was stale, so the UI continued to show the old state until the session expired. Fix: app/myaccount/update_newsletter.cfm now sets session.bustUserCache=true after the update, forcing the user-cache to refresh on the next request so the active flag reflects immediately. Commit: f2b0578a."
    },
    {
        id: 2390,
        desc: "Auditions - confetti animation when status set to Booked",
        status: "Implemented",
        setCompleted: true,
        response: "Added canvas-confetti integration to the audition detail page. When a user marks an audition as Booked, include/booked.cfm appends ?booked=1 to the redirect URL; include/audition.cfm detects the flag and runs a 1.5-second confetti animation, then cleans the parameter from history so refresh does not re-fire. Assets: share/assets/confetti.js, app/assets/js/confetti.js. Commit: 9eeb523b."
    },
    {
        id: 2393,
        desc: "User start/end time validation - end cannot be before start",
        status: "Implemented",
        setCompleted: true,
        response: "Added client + server validation so users cannot set their preference end time before (or equal to) their start time. Client: validatePrefTimes() in include/account_info.cfm blocks the form submit and shows a per-field error. Server: include/update_cal.cfm rejects invalid time pairs and returns an error. Commit: 9eeb523b."
    },
    {
        id: 2394,
        desc: "User screen admin bug - account tabs / async loading",
        status: "Implemented",
        setCompleted: true,
        response: "Fixed multiple defects in the admin user screen: (1) loadBilling and loadTeam now resolve userid correctly when invoked async, (2) account_tabs.js migrated to /app/assets and updated for Bootstrap 5 tab events using a native listener instead of jQuery, (3) async tab loading with error handling so a failure on one tab does not break the page, (4) added app-scope drift guard for the default avatar URL in loadTeam. Commits: f8a40892, 07614c11, c475ff38, 5a0ec6a2, b6013873."
    }
];

for (t in tickets) {
    try {
        // Build the appended block. Match the existing convention from
        // run-ticket-updates-2026-04-02.cfm: blank-line separator + dated tag.
        appendBlock = chr(10) & chr(10) & "[IMPLEMENTED 2026-04-26] " & t.response;

        if (t.setCompleted) {
            queryExecute(
                "UPDATE tickets
                 SET ticketResponse = CONCAT(COALESCE(ticketResponse, ''), :comment),
                     ticketStatus = :status,
                     ticketCompletedDate = NOW()
                 WHERE ticketid = :tid",
                {
                    comment: { value: appendBlock, cfsqltype: "cf_sql_longvarchar" },
                    status:  { value: t.status, cfsqltype: "cf_sql_varchar" },
                    tid:     { value: t.id, cfsqltype: "cf_sql_integer" }
                },
                { datasource: datasource }
            );
        } else {
            queryExecute(
                "UPDATE tickets
                 SET ticketResponse = CONCAT(COALESCE(ticketResponse, ''), :comment),
                     ticketStatus = :status
                 WHERE ticketid = :tid",
                {
                    comment: { value: appendBlock, cfsqltype: "cf_sql_longvarchar" },
                    status:  { value: t.status, cfsqltype: "cf_sql_varchar" },
                    tid:     { value: t.id, cfsqltype: "cf_sql_integer" }
                },
                { datasource: datasource }
            );
        }
        successCount++;
        writeOutput("<p style='color:green;'>##" & t.id & " - " & t.desc & " -> " & t.status & "</p>");
    } catch (any e) {
        arrayAppend(errors, "##" & t.id & ": " & e.message);
        writeOutput("<p style='color:red;'>##" & t.id & " FAILED: " & e.message & "</p>");
    }
}

writeOutput("<h3>Results: " & successCount & " / " & arrayLen(tickets) & " updated</h3>");

if (arrayLen(errors) gt 0) {
    writeOutput("<ul>");
    for (err in errors) { writeOutput("<li style='color:red;'>" & err & "</li>"); }
    writeOutput("</ul>");
}

// Verification
qVerify = queryExecute(
    "SELECT ticketid, ticketStatus, ticketCompletedDate, RIGHT(ticketResponse, 140) AS tail
     FROM tickets
     WHERE ticketid IN (2187, 2303, 2304, 2390, 2393, 2394)
     ORDER BY ticketid",
    {},
    { datasource: datasource }
);
writeOutput("<h3>Verification</h3><table border='1' cellpadding='6' cellspacing='0'><tr><th>Ticket</th><th>Status</th><th>Completed</th><th>Response Tail</th></tr>");
for (row in qVerify) {
    color = (row.ticketStatus eq "Implemented") ? "background:##cce5ff;" : "background:##f8d7da;";
    writeOutput("<tr style='" & color & "'><td>##" & row.ticketid & "</td><td>" & row.ticketStatus & "</td><td>" & row.ticketCompletedDate & "</td><td><small>" & htmlEditFormat(row.tail) & "</small></td></tr>");
}
writeOutput("</table>");
</cfscript>

<p style="margin-top:20px;"><a href="/app/admin-support/">Back to Tickets</a></p>
</body>
</html>
