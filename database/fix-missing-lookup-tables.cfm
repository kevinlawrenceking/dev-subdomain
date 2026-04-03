<cfsilent>
<cfinclude template="/database/admin-guard.cfm">
<cfset datasource = application.dsn>
<cfset schema = application.information_schema>
</cfsilent>
<!DOCTYPE html>
<html>
<head><title>Fix Missing Lookup Tables</title></head>
<body style="font-family:monospace;padding:20px;">
<h2>Check and Fix Missing Lookup Tables (DSN: <cfoutput>#datasource#</cfoutput>)</h2>

<cfscript>
// Tables referenced by audition role/project queries
tablesToCheck = [
    "audpaycycles",
    "incometypes",
    "audroletypes",
    "auddialects",
    "audsources",
    "audcontracttypes",
    "audtones",
    "audtones_user",
    "audnetworks",
    "audnetworks_user",
    "audunions",
    "audsubcategories",
    "audcategories",
    "audtypes",
    "audsteps",
    "audplatforms",
    "submitsites",
    "opencalls",
    "paycycles"
];

writeOutput("<h3>1. Table existence check</h3>");
writeOutput("<table border='1' cellpadding='4' cellspacing='0'>");
writeOutput("<tr><th>Table</th><th>Status</th></tr>");

missing = [];
for (tbl in tablesToCheck) {
    qCheck = queryExecute(
        "SELECT COUNT(*) AS cnt FROM information_schema.tables
         WHERE table_schema = :schema AND table_name = :tbl",
        {
            schema: { value: schema, cfsqltype: "cf_sql_varchar" },
            tbl: { value: tbl, cfsqltype: "cf_sql_varchar" }
        },
        { datasource: datasource }
    );
    exists = qCheck.cnt gt 0;
    bg = exists ? "background:##d4edda;" : "background:##f8d7da;";
    writeOutput("<tr style='" & bg & "'><td>" & tbl & "</td><td>" & (exists ? "EXISTS" : "MISSING") & "</td></tr>");
    if (!exists) arrayAppend(missing, tbl);
}
writeOutput("</table>");

// Create missing tables
if (arrayLen(missing) gt 0) {
    writeOutput("<h3>2. Creating missing tables</h3>");

    for (tbl in missing) {
        try {
            switch (tbl) {
                case "audpaycycles":
                    queryExecute("
                        CREATE TABLE audpaycycles (
                            paycycleid INT AUTO_INCREMENT PRIMARY KEY,
                            paycyclename VARCHAR(100) NOT NULL,
                            isDeleted TINYINT DEFAULT 0
                        ) ENGINE=InnoDB
                    ", {}, { datasource: datasource });
                    break;

                case "incometypes":
                    queryExecute("
                        CREATE TABLE incometypes (
                            incometypeid INT AUTO_INCREMENT PRIMARY KEY,
                            incometype VARCHAR(100) NOT NULL,
                            isDeleted TINYINT DEFAULT 0
                        ) ENGINE=InnoDB
                    ", {}, { datasource: datasource });
                    break;

                case "submitsites":
                    queryExecute("
                        CREATE TABLE submitsites (
                            submitsiteid INT AUTO_INCREMENT PRIMARY KEY,
                            submitsitename VARCHAR(200) NOT NULL,
                            isDeleted TINYINT DEFAULT 0
                        ) ENGINE=InnoDB
                    ", {}, { datasource: datasource });
                    break;

                case "opencalls":
                    queryExecute("
                        CREATE TABLE opencalls (
                            opencallid INT AUTO_INCREMENT PRIMARY KEY,
                            opencallname VARCHAR(200) NOT NULL,
                            isDeleted TINYINT DEFAULT 0
                        ) ENGINE=InnoDB
                    ", {}, { datasource: datasource });
                    break;

                case "paycycles":
                    queryExecute("
                        CREATE TABLE paycycles (
                            paycycleid INT AUTO_INCREMENT PRIMARY KEY,
                            paycyclename VARCHAR(100) NOT NULL,
                            isDeleted TINYINT DEFAULT 0
                        ) ENGINE=InnoDB
                    ", {}, { datasource: datasource });
                    break;

                default:
                    writeOutput("<p style='color:orange;'>" & tbl & " - no CREATE script defined, skipping</p>");
                    continue;
            }
            writeOutput("<p style='color:green;'>Created: " & tbl & "</p>");
        } catch (any e) {
            writeOutput("<p style='color:red;'>Error creating " & tbl & ": " & e.message & "</p>");
        }
    }
} else {
    writeOutput("<h3>2. No missing tables - all exist</h3>");
}

// 3. Verify DETaudroles_24090 query with audroleid=822
writeOutput("<h3>3. Verify DETaudroles_24090 (audroleid=822)</h3>");
try {
    qRole = queryExecute("
        SELECT
            r.audroleid, r.audprojectid, r.auddialectid, r.audRoleName,
            r.charDescription, r.holdStartDate, r.holdEndDate,
            rt.audroletype, r.audroletypeid, di.auddialect,
            s.audsource, r.audsourceid, r.contactid, r.payrate, r.netincome, r.buyout,
            i.incometype, r.iscallback, r.isredirect, r.ispin, r.isbooked,
            c.recordname AS contactname, p.paycycleid, p.paycyclename
        FROM audroles r
        LEFT OUTER JOIN audroletypes rt ON (r.audRoleTypeID = rt.audroletypeid)
        LEFT OUTER JOIN auddialects di ON (r.audDialectID = di.auddialectid)
        LEFT OUTER JOIN audsources s ON (r.audsourceid = s.audsourceid)
        LEFT OUTER JOIN incometypes i ON i.incometypeid = r.incometypeid
        LEFT OUTER JOIN contactdetails c ON c.contactid = r.contactid
        LEFT OUTER JOIN audpaycycles p ON p.paycycleid = r.paycycleid
        WHERE r.audroleid = 822
    ", {}, { datasource: datasource });

    if (qRole.recordCount eq 0) {
        writeOutput("<p style='color:red;'>RETURNED 0 ROWS</p>");
    } else {
        writeOutput("<p style='color:green;'>OK - " & qRole.recordCount & " row(s)</p>");
        writeOutput("<table border='1' cellpadding='4' cellspacing='0'>");
        cols = listToArray(qRole.columnList);
        for (c in cols) {
            v = isNull(qRole[c][1]) ? "<em style='color:orange;'>NULL</em>" : htmlEditFormat(toString(qRole[c][1]));
            writeOutput("<tr><td><strong>" & c & "</strong></td><td>" & v & "</td></tr>");
        }
        writeOutput("</table>");
    }
} catch (any e) {
    writeOutput("<p style='color:red;'>STILL FAILING: " & e.message & "</p><pre>" & htmlEditFormat(e.detail) & "</pre>");
}

// 4. Test the full remoteaudupdateform query chain
writeOutput("<h3>4. Verify SELaudprojects_24097 (eventid=1574)</h3>");
try {
    qAudDet = queryExecute("
        SELECT ad.eventid, a4.audroleid, a.projName, ad.eventStart, ad.eventStartTime,
            a4.audRoleName, a4.charDescription, ad.audstepid, ad.audtypeid, ad.audlocation
        FROM audprojects a
        INNER JOIN audroles a4 ON (a.audprojectID = a4.audprojectID)
        INNER JOIN events_tbl ad ON (ad.audroleid = a4.audroleid)
        WHERE ad.eventid = 1574
    ", {}, { datasource: datasource });
    writeOutput("<p style='color:green;'>OK - " & qAudDet.recordCount & " row(s)</p>");
} catch (any e) {
    writeOutput("<p style='color:red;'>FAILED: " & e.message & "</p>");
}
</cfscript>

<p style="margin-top:20px;"><a href="/database/diag-audition-873.cfm">Re-run full diagnostic</a></p>
</body>
</html>
