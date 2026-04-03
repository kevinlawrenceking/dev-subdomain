<cfsilent>
<!--- Update fixed Tested-Bug tickets to Implemented status on abo --->
<cfinclude template="/database/admin-guard.cfm">
<cfset datasource = "abo">
</cfsilent>
<!DOCTYPE html>
<html>
<head><title>Ticket Updates 2026-04-02</title></head>
<body style="font-family: Arial, sans-serif; padding: 20px;">
<h2>Update Fixed Tickets to Implemented - 2026-04-02</h2>
<p>Datasource: <strong><cfoutput>#datasource#</cfoutput></strong></p>

<cfscript>
successCount = 0;
errors = [];

tickets = [
    {
        id: 2191,
        desc: "Relationship views rebuilt with correct systemtype values",
        response: "Rebuilt contacts_ss_target, contacts_ss_followup, and contacts_ss_maint views with correct systemtype filter values (Targeted List, Follow Up, Maintenance List). Switching a relationship from Targeted to Follow-up now correctly shows the contact in the Follow-up filtered list."
    },
    {
        id: 2192,
        desc: "Reminder completion transaction error handling",
        response: "Added try-catch around the completion transaction in complete_not_ajax.cfm. Previously, if any downstream query in the transaction failed, the entire transaction rolled back silently but the endpoint still returned success:true, making the reminder reappear on refresh. Now returns success:false with error message so the UI does not falsely remove the reminder."
    },
    {
        id: 2161,
        desc: "charDescription column expanded from VARCHAR(500) to TEXT",
        response: "Altered audroles.charDescription and auditionsimport.charDescription from VARCHAR(500) to TEXT (65,535 chars). The ColdFusion code was already using cf_sql_longvarchar with no maxlength, so the only truncation point was the database column size."
    },
    {
        id: 1615,
        desc: "Login blank Whoops screens - addtoken fix",
        response: "Fixed login redirect in login/login2.cfm: changed addtoken=true to addtoken=false and removed userid from query string. The addtoken=true was injecting a ColdFusion session token from an unauthenticated context, which could cause CSRF validation failures or blank error screens on the post-login landing page."
    },
    {
        id: 1646,
        desc: "Login wrong redirect - addtoken fix",
        response: "Same fix as ##1615 - login redirect in login/login2.cfm changed addtoken=true to addtoken=false and removed userid from query string. This eliminates the stale token that could cause wrong-page redirects after authentication."
    }
];

for (t in tickets) {
    try {
        queryExecute(
            "UPDATE tickets
             SET ticketResponse = CONCAT(COALESCE(ticketResponse, ''), :comment),
                 ticketStatus = 'Implemented'
             WHERE ticketid = :tid",
            {
                comment: { value: chr(10) & chr(10) & "[IMPLEMENTED 2026-04-02] " & t.response, cfsqltype: "cf_sql_longvarchar" },
                tid: { value: t.id, cfsqltype: "cf_sql_integer" }
            },
            { datasource: datasource }
        );
        successCount++;
        writeOutput("<p style='color:green;'>##" & t.id & " - " & t.desc & " -> Implemented</p>");
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
    "SELECT ticketid, ticketStatus, RIGHT(ticketResponse, 100) AS tail
     FROM tickets
     WHERE ticketid IN (2191, 2192, 2161, 1615, 1646)
     ORDER BY ticketid",
    {},
    { datasource: datasource }
);
writeOutput("<h3>Verification</h3><table border='1' cellpadding='6' cellspacing='0'><tr><th>Ticket</th><th>Status</th><th>Response Tail</th></tr>");
for (row in qVerify) {
    color = (row.ticketStatus eq "Implemented") ? "background:##cce5ff;" : "background:##f8d7da;";
    writeOutput("<tr style='" & color & "'><td>##" & row.ticketid & "</td><td>" & row.ticketStatus & "</td><td><small>" & htmlEditFormat(row.tail) & "</small></td></tr>");
}
writeOutput("</table>");
</cfscript>

<p style="margin-top:20px;"><a href="/app/admin-support/">Back to Tickets</a></p>
</body>
</html>
