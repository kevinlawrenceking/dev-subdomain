<cfsilent>
<!--- Apply fixes for Tested-Bug tickets from Chris's 2026-04-02 review --->
<cfinclude template="/database/admin-guard.cfm">
<cfset datasource = application.dsn>
</cfsilent>
<!DOCTYPE html>
<html>
<head><title>Tested-Bug Fixes 2026-04-02</title></head>
<body style="font-family: Arial, sans-serif; padding: 20px;">
<h2>Apply Tested-Bug Fixes - 2026-04-02</h2>
<p>Datasource: <strong><cfoutput>#datasource#</cfoutput></strong></p>

<cfscript>
results = [];
errors = [];

// ============================================================
// FIX #2191 - Rebuild relationship system filter views
// Root cause: views filter on wrong systemtype values
// ============================================================
try {
    queryExecute("
        CREATE OR REPLACE VIEW contacts_ss_target AS
        SELECT DISTINCT cs.*
        FROM contacts_ss cs
        INNER JOIN fusystemusers su
            ON su.contactid = cs.contactid
            AND su.userid = cs.userid
        INNER JOIN fusystems s
            ON s.systemID = su.systemID
        WHERE s.systemtype = 'Targeted List'
          AND su.suStatus = 'Active'
    ", {}, { datasource: datasource });

    queryExecute("
        CREATE OR REPLACE VIEW contacts_ss_followup AS
        SELECT DISTINCT cs.*
        FROM contacts_ss cs
        INNER JOIN fusystemusers su
            ON su.contactid = cs.contactid
            AND su.userid = cs.userid
        INNER JOIN fusystems s
            ON s.systemID = su.systemID
        WHERE s.systemtype = 'Follow Up'
          AND su.suStatus = 'Active'
    ", {}, { datasource: datasource });

    queryExecute("
        CREATE OR REPLACE VIEW contacts_ss_maint AS
        SELECT DISTINCT cs.*
        FROM contacts_ss cs
        INNER JOIN fusystemusers su
            ON su.contactid = cs.contactid
            AND su.userid = cs.userid
        INNER JOIN fusystems s
            ON s.systemID = su.systemID
        WHERE s.systemtype = 'Maintenance List'
          AND su.suStatus = 'Active'
    ", {}, { datasource: datasource });

    // Verify
    qTarget = queryExecute("SELECT COUNT(*) AS cnt FROM contacts_ss_target", {}, { datasource: datasource });
    qFollowup = queryExecute("SELECT COUNT(*) AS cnt FROM contacts_ss_followup", {}, { datasource: datasource });
    qMaint = queryExecute("SELECT COUNT(*) AS cnt FROM contacts_ss_maint", {}, { datasource: datasource });

    arrayAppend(results, {
        ticket: "##2191",
        desc: "Rebuild relationship filter views (target/followup/maint)",
        status: "OK",
        detail: "Views rebuilt. Rows: target=#qTarget.cnt#, followup=#qFollowup.cnt#, maint=#qMaint.cnt#"
    });
} catch (any e) {
    arrayAppend(errors, { ticket: "##2191", error: e.message });
}

// ============================================================
// FIX #2161 - ALTER charDescription columns to TEXT
// Root cause: columns are still VARCHAR, truncating long text
// ============================================================
try {
    // Check current type first
    qBefore = queryExecute("
        SELECT TABLE_NAME, COLUMN_NAME, DATA_TYPE, CHARACTER_MAXIMUM_LENGTH
        FROM INFORMATION_SCHEMA.COLUMNS
        WHERE COLUMN_NAME = 'charDescription'
        AND TABLE_NAME IN ('audroles', 'auditionsimport')
        AND TABLE_SCHEMA = :schema
    ", { schema: { value: application.information_schema, cfsqltype: "cf_sql_varchar" } },
    { datasource: datasource });

    queryExecute("ALTER TABLE audroles MODIFY COLUMN charDescription TEXT NULL", {}, { datasource: datasource });
    queryExecute("ALTER TABLE auditionsimport MODIFY COLUMN charDescription TEXT NULL", {}, { datasource: datasource });

    // Verify
    qAfter = queryExecute("
        SELECT TABLE_NAME, DATA_TYPE, CHARACTER_MAXIMUM_LENGTH
        FROM INFORMATION_SCHEMA.COLUMNS
        WHERE COLUMN_NAME = 'charDescription'
        AND TABLE_NAME IN ('audroles', 'auditionsimport')
        AND TABLE_SCHEMA = :schema
    ", { schema: { value: application.information_schema, cfsqltype: "cf_sql_varchar" } },
    { datasource: datasource });

    detail = "";
    for (row in qAfter) {
        detail &= row.TABLE_NAME & "=" & row.DATA_TYPE & " ";
    }

    arrayAppend(results, {
        ticket: "##2161",
        desc: "ALTER charDescription to TEXT on audroles and auditionsimport",
        status: "OK",
        detail: "Columns now: " & detail
    });
} catch (any e) {
    arrayAppend(errors, { ticket: "##2161", error: e.message });
}

// ============================================================
// FIX #2192 - Code fix already applied (NotificationService.cfc)
// Removed unused INNER JOIN contactdetails from GetNotificationByID
// Added AJAX error handling in reminder_pane.cfm
// Just update the ticket status here.
// ============================================================
arrayAppend(results, {
    ticket: "##2192",
    desc: "Remove unused contactdetails INNER JOIN from GetNotificationByID + AJAX error handling",
    status: "CODE FIX",
    detail: "NotificationService.cfc: removed INNER JOIN contactdetails (view filters soft-deletes, no columns used). reminder_pane.cfm: added error response check."
});

// ============================================================
// FIX #1615/#1646 - Code fix already applied (setup/Application.cfc)
// Session scope unified to TAO_{env}, SameSite changed to Lax
// ============================================================
arrayAppend(results, {
    ticket: "##1615/##1646",
    desc: "Login session scope fix already in code",
    status: "CODE FIX",
    detail: "setup/Application.cfc: this.name unified to TAO_{env} (was Setup_{env}). SameSite=Lax. Auth gate removed for UUID pages."
});

// ============================================================
// #1675 - Code fix already applied (CSS image-orientation)
// Needs macbook/Safari to verify
// ============================================================
arrayAppend(results, {
    ticket: "##1675",
    desc: "Safari EXIF orientation CSS fix in code",
    status: "NEEDS DEVICE",
    detail: "image-orientation: from-image applied in tao-components.css, image-upload.cfm, image-upload-contact.cfm. Requires macbook with Safari to verify."
});

// ============================================================
// #1614 - Deferred by Chris to later release
// ============================================================
arrayAppend(results, {
    ticket: "##1614",
    desc: "iPhone 14 Pro Max blank screen - deferred",
    status: "DEFERRED",
    detail: "Chris: 'This does not feel critical - moved to later release.' Requires physical device."
});

// ============================================================
// UPDATE TICKET STATUSES
// Tickets with code/DB fixes applied -> Implemented
// Tickets needing device testing -> leave as Tested - Bug
// Ticket deferred -> leave as Tested - Bug
// ============================================================
implementedTickets = [
    { id: 2191, comment: "View rebuild applied. contacts_ss_target, contacts_ss_followup, contacts_ss_maint recreated with correct systemtype values." },
    { id: 2192, comment: "Removed unused INNER JOIN contactdetails from GetNotificationByID (contactdetails is a VIEW filtering soft-deletes - no columns were used but the INNER JOIN silently killed the query for deleted contacts). Added AJAX error handling in reminder_pane.cfm." },
    { id: 2161, comment: "ALTER TABLE audroles and auditionsimport: charDescription changed from VARCHAR to TEXT. ColdFusion code already used CF_SQL_LONGVARCHAR." },
    { id: 1615, comment: "Login fix confirmed in code. setup/Application.cfc unified session scope to TAO_{env} (was Setup_{env}), SameSite=Lax, removed blanket 403 auth gate. Applied in commit ef6c155a." },
    { id: 1646, comment: "Login fix confirmed in code. Same as ##1615 - setup/Application.cfc session scope fix." }
];

for (t in implementedTickets) {
    try {
        queryExecute(
            "UPDATE tickets
             SET ticketResponse = CONCAT(COALESCE(ticketResponse, ''), :comment),
                 ticketStatus = 'Implemented'
             WHERE ticketid = :tid",
            {
                comment: { value: chr(10) & chr(10) & "[IMPLEMENTED 2026-04-02] " & t.comment, cfsqltype: "cf_sql_longvarchar" },
                tid: { value: t.id, cfsqltype: "cf_sql_integer" }
            },
            { datasource: datasource }
        );
    } catch (any e) {
        arrayAppend(errors, { ticket: "##" & t.id & " status update", error: e.message });
    }
}

// ============================================================
// OUTPUT RESULTS
// ============================================================
writeOutput("<h3>Fix Results</h3>");
writeOutput("<table border='1' cellpadding='8' cellspacing='0' style='border-collapse:collapse;'>");
writeOutput("<tr style='background:##333;color:##fff;'><th>Ticket</th><th>Fix</th><th>Status</th><th>Detail</th></tr>");
for (r in results) {
    bg = "";
    if (r.status eq "OK") bg = "background:##d4edda;";
    else if (r.status eq "CODE FIX") bg = "background:##cce5ff;";
    else if (r.status eq "NEEDS DEVICE") bg = "background:##fff3cd;";
    else if (r.status eq "DEFERRED") bg = "background:##e2e3e5;";
    writeOutput("<tr style='" & bg & "'><td>" & r.ticket & "</td><td>" & r.desc & "</td><td><strong>" & r.status & "</strong></td><td><small>" & r.detail & "</small></td></tr>");
}
writeOutput("</table>");

if (arrayLen(errors) gt 0) {
    writeOutput("<h3 style='color:red;'>Errors</h3><ul>");
    for (err in errors) {
        writeOutput("<li style='color:red;'>" & err.ticket & ": " & err.error & "</li>");
    }
    writeOutput("</ul>");
}

// Verification: show updated ticket statuses
writeOutput("<h3>Ticket Status Verification</h3>");
qVerify = queryExecute(
    "SELECT ticketid, ticketStatus, RIGHT(ticketResponse, 150) AS lastResponse
     FROM tickets
     WHERE ticketid IN (2191, 2192, 2161, 1615, 1646, 1675, 1614)
     ORDER BY ticketid",
    {},
    { datasource: datasource }
);

writeOutput("<table border='1' cellpadding='6' cellspacing='0' style='border-collapse:collapse;'>");
writeOutput("<tr style='background:##333;color:##fff;'><th>Ticket</th><th>Status</th><th>Last Response (tail)</th></tr>");
for (row in qVerify) {
    bg = "";
    if (row.ticketStatus eq "Implemented") bg = "background:##cce5ff;";
    else if (row.ticketStatus eq "Tested - Bug") bg = "background:##f8d7da;";
    else if (row.ticketStatus eq "Tested - Success") bg = "background:##d4edda;";
    writeOutput("<tr style='" & bg & "'><td>##" & row.ticketid & "</td><td>" & row.ticketStatus & "</td><td><small>" & htmlEditFormat(row.lastResponse) & "</small></td></tr>");
}
writeOutput("</table>");
</cfscript>

<p style="margin-top:20px;"><a href="/app/admin-support/">Back to Tickets</a></p>
</body>
</html>
