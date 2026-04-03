<cfsilent>
<!--- Run DB fixes for Tested-Bug tickets: #2191 (views) + #2161 (charDescription) --->
<cfinclude template="/database/admin-guard.cfm">
<cfset datasource = "abo">
</cfsilent>
<!DOCTYPE html>
<html>
<head><title>Bug Fixes 2026-04-02</title></head>
<body style="font-family: Arial, sans-serif; padding: 20px;">
<h2>Bug Fixes - 2026-04-02</h2>
<p>Datasource: <strong><cfoutput>#datasource#</cfoutput></strong></p>

<cfscript>
errors = [];

// ============================================================
// FIX #2191: Rebuild relationship system filter views
// The views had wrong systemtype strings:
//   'Targeting' -> 'Targeted List'
//   'Follow-Up' -> 'Follow Up'
//   'Maintenance' -> 'Maintenance List'
// ============================================================
writeOutput("<h3>Fix ##2191: Rebuild Relationship System Views</h3>");

try {
    queryExecute("
        CREATE OR REPLACE VIEW contacts_ss_target AS
        SELECT DISTINCT cs.*
        FROM contacts_ss cs
        INNER JOIN fusystemusers su
            ON su.contactid = cs.contactid AND su.userid = cs.userid
        INNER JOIN fusystems s
            ON s.systemID = su.systemID
        WHERE s.systemtype = 'Targeted List'
          AND su.suStatus = 'Active'
    ", {}, { datasource: datasource });
    writeOutput("<p style='color:green;'>contacts_ss_target - rebuilt (systemtype = 'Targeted List')</p>");
} catch (any e) {
    arrayAppend(errors, "contacts_ss_target: " & e.message);
    writeOutput("<p style='color:red;'>contacts_ss_target FAILED: " & e.message & "</p>");
}

try {
    queryExecute("
        CREATE OR REPLACE VIEW contacts_ss_followup AS
        SELECT DISTINCT cs.*
        FROM contacts_ss cs
        INNER JOIN fusystemusers su
            ON su.contactid = cs.contactid AND su.userid = cs.userid
        INNER JOIN fusystems s
            ON s.systemID = su.systemID
        WHERE s.systemtype = 'Follow Up'
          AND su.suStatus = 'Active'
    ", {}, { datasource: datasource });
    writeOutput("<p style='color:green;'>contacts_ss_followup - rebuilt (systemtype = 'Follow Up')</p>");
} catch (any e) {
    arrayAppend(errors, "contacts_ss_followup: " & e.message);
    writeOutput("<p style='color:red;'>contacts_ss_followup FAILED: " & e.message & "</p>");
}

try {
    queryExecute("
        CREATE OR REPLACE VIEW contacts_ss_maint AS
        SELECT DISTINCT cs.*
        FROM contacts_ss cs
        INNER JOIN fusystemusers su
            ON su.contactid = cs.contactid AND su.userid = cs.userid
        INNER JOIN fusystems s
            ON s.systemID = su.systemID
        WHERE s.systemtype = 'Maintenance List'
          AND su.suStatus = 'Active'
    ", {}, { datasource: datasource });
    writeOutput("<p style='color:green;'>contacts_ss_maint - rebuilt (systemtype = 'Maintenance List')</p>");
} catch (any e) {
    arrayAppend(errors, "contacts_ss_maint: " & e.message);
    writeOutput("<p style='color:red;'>contacts_ss_maint FAILED: " & e.message & "</p>");
}

// Verify view counts
try {
    qVerify = queryExecute("
        SELECT 'contacts_ss_target' AS view_name, COUNT(*) AS cnt FROM contacts_ss_target
        UNION ALL
        SELECT 'contacts_ss_followup', COUNT(*) FROM contacts_ss_followup
        UNION ALL
        SELECT 'contacts_ss_maint', COUNT(*) FROM contacts_ss_maint
    ", {}, { datasource: datasource });
    writeOutput("<table border='1' cellpadding='6' cellspacing='0'><tr><th>View</th><th>Row Count</th></tr>");
    for (row in qVerify) {
        writeOutput("<tr><td>" & row.view_name & "</td><td>" & row.cnt & "</td></tr>");
    }
    writeOutput("</table>");
} catch (any e) {
    writeOutput("<p style='color:orange;'>Could not verify view counts: " & e.message & "</p>");
}

// ============================================================
// FIX #2161: Expand charDescription columns from VARCHAR(500) to TEXT
// ============================================================
writeOutput("<h3>Fix ##2161: Expand charDescription Columns</h3>");

// Check current column types first
try {
    qBefore = queryExecute("
        SELECT TABLE_NAME, COLUMN_NAME, DATA_TYPE, CHARACTER_MAXIMUM_LENGTH
        FROM INFORMATION_SCHEMA.COLUMNS
        WHERE COLUMN_NAME = 'charDescription'
        AND TABLE_NAME IN ('audroles', 'auditionsimport')
    ", {}, { datasource: datasource });
    writeOutput("<p><strong>Before:</strong></p><table border='1' cellpadding='6' cellspacing='0'><tr><th>Table</th><th>Type</th><th>Max Length</th></tr>");
    for (row in qBefore) {
        writeOutput("<tr><td>" & row.TABLE_NAME & "</td><td>" & row.DATA_TYPE & "</td><td>" & row.CHARACTER_MAXIMUM_LENGTH & "</td></tr>");
    }
    writeOutput("</table>");
} catch (any e) {
    writeOutput("<p style='color:orange;'>Could not check column types: " & e.message & "</p>");
}

try {
    queryExecute("ALTER TABLE audroles MODIFY COLUMN charDescription TEXT NULL", {}, { datasource: datasource });
    writeOutput("<p style='color:green;'>audroles.charDescription -> TEXT</p>");
} catch (any e) {
    arrayAppend(errors, "audroles ALTER: " & e.message);
    writeOutput("<p style='color:red;'>audroles ALTER FAILED: " & e.message & "</p>");
}

try {
    queryExecute("ALTER TABLE auditionsimport MODIFY COLUMN charDescription TEXT NULL", {}, { datasource: datasource });
    writeOutput("<p style='color:green;'>auditionsimport.charDescription -> TEXT</p>");
} catch (any e) {
    arrayAppend(errors, "auditionsimport ALTER: " & e.message);
    writeOutput("<p style='color:red;'>auditionsimport ALTER FAILED: " & e.message & "</p>");
}

// Verify after
try {
    qAfter = queryExecute("
        SELECT TABLE_NAME, COLUMN_NAME, DATA_TYPE, CHARACTER_MAXIMUM_LENGTH
        FROM INFORMATION_SCHEMA.COLUMNS
        WHERE COLUMN_NAME = 'charDescription'
        AND TABLE_NAME IN ('audroles', 'auditionsimport')
    ", {}, { datasource: datasource });
    writeOutput("<p><strong>After:</strong></p><table border='1' cellpadding='6' cellspacing='0'><tr><th>Table</th><th>Type</th><th>Max Length</th></tr>");
    for (row in qAfter) {
        color = (row.DATA_TYPE eq "text") ? "background:##d4edda;" : "background:##f8d7da;";
        writeOutput("<tr style='" & color & "'><td>" & row.TABLE_NAME & "</td><td>" & row.DATA_TYPE & "</td><td>" & row.CHARACTER_MAXIMUM_LENGTH & "</td></tr>");
    }
    writeOutput("</table>");
} catch (any e) {
    writeOutput("<p style='color:orange;'>Could not verify: " & e.message & "</p>");
}

// ============================================================
// SUMMARY
// ============================================================
writeOutput("<h3>Summary</h3>");
if (arrayLen(errors) eq 0) {
    writeOutput("<p style='color:green; font-size:16px;'>All fixes applied successfully.</p>");
} else {
    writeOutput("<p style='color:red; font-size:16px;'>" & arrayLen(errors) & " error(s):</p><ul>");
    for (err in errors) {
        writeOutput("<li style='color:red;'>" & err & "</li>");
    }
    writeOutput("</ul>");
}
</cfscript>

<p style="margin-top:20px;"><a href="/app/admin-support/">Back to Tickets</a></p>
</body>
</html>
