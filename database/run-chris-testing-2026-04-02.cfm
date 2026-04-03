<cfsilent>
<!--- Run Chris Ansoff testing results from 2026-04-02 --->
<cfinclude template="/database/admin-guard.cfm">
<cfset datasource = "abo">
</cfsilent>
<!DOCTYPE html>
<html>
<head><title>Chris Testing Results 2026-04-02</title></head>
<body style="font-family: Arial, sans-serif; padding: 20px;">
<h2>Chris Ansoff Testing Results - 2026-04-02</h2>
<p>Datasource: <strong><cfoutput>#datasource#</cfoutput></strong></p>

<cfscript>
successCount = 0;
bugCount = 0;
featureCount = 0;
errors = [];

// ============================================================
// TESTED - SUCCESS
// ============================================================
successTickets = [
    { id: 2184, comment: "Testing success" },
    { id: 2140, comment: "Testing success" },
    { id: 1655, comment: "This was in a future release but testing success" },
    { id: 1617, comment: "Testing success" },
    { id: 1630, comment: "Testing success" },
    { id: 1634, comment: "Testing success" },
    { id: 1653, comment: "Testing success" },
    { id: 1633, comment: "Testing success" },
    { id: 1652, comment: "Testing success" },
    { id: 1631, comment: "This was in a future release but testing success" },
    { id: 1656, comment: "Testing success" },
    { id: 2173, comment: "This was a time when one was not able download the import template - fixed." },
    { id: 2190, comment: "GPT misunderstood this ticket - it was a bug with import but is working now" },
    { id: 1569, comment: "Don't think this is an issue anymore" }
];

for (t in successTickets) {
    try {
        queryExecute(
            "UPDATE tickets
             SET ticketResponse = CONCAT(COALESCE(ticketResponse, ''),
                    :comment),
                 ticketStatus = 'Tested - Success'
             WHERE ticketid = :tid",
            {
                comment: { value: chr(10) & chr(10) & "[TESTED 2026-04-02 Chris Ansoff] " & t.comment, cfsqltype: "cf_sql_longvarchar" },
                tid: { value: t.id, cfsqltype: "cf_sql_integer" }
            },
            { datasource: datasource }
        );
        successCount++;
    } catch (any e) {
        arrayAppend(errors, "##" & t.id & " (Success): " & e.message);
    }
}

// ============================================================
// TESTED - BUG
// ============================================================
bugTickets = [
    { id: 1615, comment: "Well these fall under all the login issues that have happened. Closed them but not sure if the login issues are fixed." },
    { id: 1646, comment: "Well these fall under all the login issues that have happened. Closed them but not sure if the login issues are fixed." },
    { id: 2191, comment: "Well the first issue is fixed but if one changes a relationship system from Targeted to Follow-up, the relationship does not show up when Follow-up list is selected on Relationships: All." },
    { id: 2192, comment: "This worked yesterday but today does not work." },
    { id: 2161, comment: "Long texts still getting cut off - GPT said partially resolved" },
    { id: 1675, comment: "Need someone with macbook to test this using Safari" },
    { id: 1614, comment: "This does not feel critical - moved to later release" }
];

for (t in bugTickets) {
    try {
        queryExecute(
            "UPDATE tickets
             SET ticketResponse = CONCAT(COALESCE(ticketResponse, ''),
                    :comment),
                 ticketStatus = 'Tested - Bug'
             WHERE ticketid = :tid",
            {
                comment: { value: chr(10) & chr(10) & "[TESTED 2026-04-02 Chris Ansoff] " & t.comment, cfsqltype: "cf_sql_longvarchar" },
                tid: { value: t.id, cfsqltype: "cf_sql_integer" }
            },
            { datasource: datasource }
        );
        bugCount++;
    } catch (any e) {
        arrayAppend(errors, "##" & t.id & " (Bug): " & e.message);
    }
}

// ============================================================
// FEATURE REQUESTS - Append comment only, no status change
// ============================================================
featureTickets = [
    { id: 1623, comment: "Already in a future release" },
    { id: 1725, comment: "Already in a future release" },
    { id: 1839, comment: "Already in a future release" },
    { id: 1780, comment: "Already in a future release" },
    { id: 1636, comment: "Already in a future release" }
];

for (t in featureTickets) {
    try {
        queryExecute(
            "UPDATE tickets
             SET ticketResponse = CONCAT(COALESCE(ticketResponse, ''),
                    :comment)
             WHERE ticketid = :tid",
            {
                comment: { value: chr(10) & chr(10) & "[TESTED 2026-04-02 Chris Ansoff] " & t.comment, cfsqltype: "cf_sql_longvarchar" },
                tid: { value: t.id, cfsqltype: "cf_sql_integer" }
            },
            { datasource: datasource }
        );
        featureCount++;
    } catch (any e) {
        arrayAppend(errors, "##" & t.id & " (Feature): " & e.message);
    }
}

// ============================================================
// RESULTS
// ============================================================
writeOutput("<h3>Results</h3>");
writeOutput("<table border='1' cellpadding='8' cellspacing='0'>");
writeOutput("<tr><td>Tested - Success</td><td><strong>" & successCount & " / " & arrayLen(successTickets) & "</strong></td></tr>");
writeOutput("<tr><td>Tested - Bug</td><td><strong>" & bugCount & " / " & arrayLen(bugTickets) & "</strong></td></tr>");
writeOutput("<tr><td>Feature Requests (comment only)</td><td><strong>" & featureCount & " / " & arrayLen(featureTickets) & "</strong></td></tr>");
writeOutput("<tr><td><strong>Total</strong></td><td><strong>" & (successCount + bugCount + featureCount) & " / " & (arrayLen(successTickets) + arrayLen(bugTickets) + arrayLen(featureTickets)) & "</strong></td></tr>");
writeOutput("</table>");

if (arrayLen(errors) gt 0) {
    writeOutput("<h3 style='color:red;'>Errors</h3><ul>");
    for (err in errors) {
        writeOutput("<li style='color:red;'>" & err & "</li>");
    }
    writeOutput("</ul>");
} else {
    writeOutput("<p style='color:green;'>All updates completed successfully.</p>");
}

// Verification query
writeOutput("<h3>Verification</h3>");
allIds = "2184,2140,1655,1617,1630,1634,1653,1633,1652,1631,1656,2173,2190,1569,1615,1646,2191,2192,2161,1675,1614,1623,1725,1839,1780,1636";
qVerify = queryExecute(
    "SELECT ticketid, ticketStatus, RIGHT(ticketResponse, 120) AS lastResponse
     FROM tickets
     WHERE ticketid IN (#allIds#)
     ORDER BY ticketid",
    {},
    { datasource: datasource }
);

writeOutput("<table border='1' cellpadding='6' cellspacing='0'>");
writeOutput("<tr><th>Ticket</th><th>Status</th><th>Last Response (tail)</th></tr>");
for (row in qVerify) {
    color = "";
    if (row.ticketStatus eq "Tested - Success") color = "background:##d4edda;";
    else if (row.ticketStatus eq "Tested - Bug") color = "background:##f8d7da;";
    writeOutput("<tr style='" & color & "'><td>##" & row.ticketid & "</td><td>" & row.ticketStatus & "</td><td><small>" & htmlEditFormat(row.lastResponse) & "</small></td></tr>");
}
writeOutput("</table>");
</cfscript>

<p style="margin-top:20px;"><a href="/app/admin-support/">Back to Tickets</a></p>
</body>
</html>
