<cfsilent>
<cfinclude template="/database/admin-guard.cfm">
<cfset datasource = application.dsn>
<cfset pid = 873>
</cfsilent>
<!DOCTYPE html>
<html>
<head><title>Diag: audprojectid #<cfoutput>#pid#</cfoutput></title></head>
<body style="font-family:monospace;padding:20px;">
<h2>Diagnostic: audprojectid=<cfoutput>#pid#</cfoutput> (DSN: <cfoutput>#datasource#</cfoutput>)</h2>

<cfscript>
// 1) audprojects
qProj = queryExecute("
    SELECT * FROM audprojects WHERE audprojectid = :pid
", { pid: { value: pid, cfsqltype: "cf_sql_integer" } }, { datasource: datasource });

writeOutput("<h3>1. audprojects</h3>");
if (qProj.recordCount eq 0) {
    writeOutput("<p style='color:red;'>NO ROW FOUND</p>");
} else {
    writeOutput("<table border='1' cellpadding='4' cellspacing='0'>");
    cols = listToArray(qProj.columnList);
    for (c in cols) {
        v = isNull(qProj[c][1]) ? "<em style='color:orange;'>NULL</em>" : htmlEditFormat(toString(qProj[c][1]));
        bg = isNull(qProj[c][1]) ? "background:##fff3cd;" : "";
        writeOutput("<tr style='" & bg & "'><td><strong>" & c & "</strong></td><td>" & v & "</td></tr>");
    }
    writeOutput("</table>");
}

// 2) audroles
qRoles = queryExecute("
    SELECT * FROM audroles WHERE audprojectid = :pid
", { pid: { value: pid, cfsqltype: "cf_sql_integer" } }, { datasource: datasource });

writeOutput("<h3>2. audroles (linked to project)</h3>");
if (qRoles.recordCount eq 0) {
    writeOutput("<p style='color:red;'>NO ROLES FOUND</p>");
} else {
    writeOutput("<table border='1' cellpadding='4' cellspacing='0'><tr>");
    cols = listToArray(qRoles.columnList);
    for (c in cols) writeOutput("<th>" & c & "</th>");
    writeOutput("</tr>");
    for (row in qRoles) {
        writeOutput("<tr>");
        for (c in cols) {
            v = isNull(row[c]) ? "<em style='color:orange;'>NULL</em>" : htmlEditFormat(toString(row[c]));
            bg = isNull(row[c]) ? "background:##fff3cd;" : "";
            writeOutput("<td style='" & bg & "'>" & v & "</td>");
        }
        writeOutput("</tr>");
    }
    writeOutput("</table>");
}

// 3) events_tbl (via audroles)
qEvents = queryExecute("
    SELECT e.*
    FROM events_tbl e
    INNER JOIN audroles r ON r.audroleid = e.audroleid
    WHERE r.audprojectid = :pid
", { pid: { value: pid, cfsqltype: "cf_sql_integer" } }, { datasource: datasource });

writeOutput("<h3>3. events_tbl (via audroles)</h3>");
if (qEvents.recordCount eq 0) {
    writeOutput("<p style='color:red;'>NO EVENTS FOUND</p>");
} else {
    writeOutput("<table border='1' cellpadding='4' cellspacing='0'><tr>");
    cols = listToArray(qEvents.columnList);
    for (c in cols) writeOutput("<th style='font-size:11px;'>" & c & "</th>");
    writeOutput("</tr>");
    for (row in qEvents) {
        writeOutput("<tr>");
        for (c in cols) {
            v = isNull(row[c]) ? "<em style='color:orange;'>NULL</em>" : htmlEditFormat(toString(row[c]));
            bg = isNull(row[c]) ? "background:##fff3cd;" : "";
            if (c eq "ISDELETED" and (isNull(row[c]) or row[c] neq 0)) bg = "background:##f8d7da;";
            writeOutput("<td style='font-size:11px;" & bg & "'>" & v & "</td>");
        }
        writeOutput("</tr>");
    }
    writeOutput("</table>");
}

// 4) Check events VIEW vs events_tbl
writeOutput("<h3>4. events VIEW visibility check</h3>");
qViewCheck = queryExecute("
    SELECT 'events_tbl' AS source, COUNT(*) AS cnt
    FROM events_tbl e
    INNER JOIN audroles r ON r.audroleid = e.audroleid
    WHERE r.audprojectid = :pid
    UNION ALL
    SELECT 'events (view)' AS source, COUNT(*) AS cnt
    FROM events e
    INNER JOIN audroles r ON r.audroleid = e.audroleid
    WHERE r.audprojectid = :pid
", { pid: { value: pid, cfsqltype: "cf_sql_integer" } }, { datasource: datasource });
writeOutput("<table border='1' cellpadding='4' cellspacing='0'>");
for (row in qViewCheck) {
    bg = (row.source eq "events (view)" and row.cnt eq 0) ? "background:##f8d7da;" : "background:##d4edda;";
    writeOutput("<tr style='" & bg & "'><td>" & row.source & "</td><td>" & row.cnt & " rows</td></tr>");
}
writeOutput("</table>");

// 5) Run the exact modal queries
writeOutput("<h3>5. DETaudprojects_24089 (project detail query)</h3>");
try {
    qDet = queryExecute("
        SELECT proj.audprojectID, r.audroleid, proj.projName, proj.projDescription,
            cat.audCatName, cat.audcatid, subcat.audSubCatName, subcat.audsubcatid,
            proj.contactid, ct.contracttype, ton.tone, net.network, un.unionName,
            c.recordname AS castingFullName, r.payrate, r.buyout
        FROM audprojects proj
        INNER JOIN audroles r ON r.audprojectid = proj.audprojectid
        LEFT OUTER JOIN audcontracttypes ct ON proj.contractTypeID = ct.contracttypeid
        LEFT OUTER JOIN audsubcategories subcat ON proj.audSubCatID = subcat.audSubCatId
        LEFT OUTER JOIN audcategories cat ON subcat.audCatId = cat.audCatId
        LEFT OUTER JOIN audtones ton ON proj.toneID = ton.toneid
        LEFT OUTER JOIN audnetworks net ON proj.networkID = net.networkid
        LEFT OUTER JOIN contactdetails c ON c.contactid = proj.contactid
        LEFT OUTER JOIN audunions un ON proj.unionID = un.unionID
        WHERE proj.audprojectID = :pid
    ", { pid: { value: pid, cfsqltype: "cf_sql_integer" } }, { datasource: datasource });
    writeOutput("<p style='color:green;'>OK - " & qDet.recordCount & " row(s). audroleid=" & (qDet.recordCount ? qDet.audroleid : "N/A") & "</p>");
} catch (any e) {
    writeOutput("<p style='color:red;'>ERROR: " & e.message & "</p>");
}

// 6) SELaudprojects_24097 (audition detail query used by edit modal)
writeOutput("<h3>6. SELaudprojects_24097 (edit audition modal query, eventid=1574)</h3>");
try {
    qAudDet = queryExecute("
        SELECT ad.eventid, a4.audroleid, a.projName, a.projDescription,
            a4.payrate, a4.buyout, ad.eventStartTime, ad.eventStopTime, ad.eventStart,
            a1.network, a2.audSubCatName, a3.unionName, a2.audsubcatid,
            ad.audlocid, a4.audRoleName, a4.charDescription, a4.holdStartDate, a4.holdEndDate,
            a5.audroletype, a6.auddialect, c.audcatid, t.audtypeid,
            ad.workwithcoach, ad.audstepid, ad.audlocation, ad.parkingdetails,
            ad.audroleid AS event_audroleid, ad.audplatformid, ad.trackmileage,
            t.audtype, step.audstep, t.islocation,
            ad.audbooktypeid, ad.eventLocation, ad.audlocadd1, ad.audzip,
            ad.audlocadd2, ad.audcity, ad.region_id, r.countryid
        FROM audprojects a
        LEFT OUTER JOIN audnetworks a1 ON (a.networkID = a1.networkid)
        LEFT OUTER JOIN audsubcategories a2 ON (a.audSubCatID = a2.audSubCatId)
        LEFT OUTER JOIN audcategories c ON c.audcatid = a2.audcatid
        LEFT OUTER JOIN audunions a3 ON (a.unionID = a3.unionID)
        INNER JOIN audroles a4 ON (a.audprojectID = a4.audprojectID)
        INNER JOIN events_tbl ad ON (ad.audroleid = a4.audroleid)
        LEFT OUTER JOIN audsteps step ON step.audstepid = ad.audstepid
        LEFT OUTER JOIN audroletypes a5 ON (a4.audRoleTypeID = a5.audroletypeid)
        LEFT OUTER JOIN auddialects a6 ON (a4.audDialectID = a6.auddialectid)
        LEFT JOIN audtypes t ON t.audtypeid = ad.audtypeid
        LEFT OUTER JOIN regions r ON r.region_id = ad.region_id
        WHERE ad.eventid = 1574
    ", {}, { datasource: datasource });
    if (qAudDet.recordCount eq 0) {
        writeOutput("<p style='color:red;'>RETURNED 0 ROWS - this is why the modal fails</p>");
    } else {
        writeOutput("<p style='color:green;'>OK - " & qAudDet.recordCount & " row(s)</p>");
        writeOutput("<table border='1' cellpadding='4' cellspacing='0'>");
        cols = listToArray(qAudDet.columnList);
        for (c in cols) {
            v = isNull(qAudDet[c][1]) ? "<em style='color:orange;'>NULL</em>" : htmlEditFormat(toString(qAudDet[c][1]));
            bg = isNull(qAudDet[c][1]) ? "background:##fff3cd;" : "";
            writeOutput("<tr style='" & bg & "'><td><strong>" & c & "</strong></td><td>" & v & "</td></tr>");
        }
        writeOutput("</table>");
    }
} catch (any e) {
    writeOutput("<p style='color:red;'>ERROR: " & e.message & "<br>" & e.detail & "</p>");
}

// 7) roleDetails query (DETaudroles_24090)
writeOutput("<h3>7. Role details query (DETaudroles_24090)</h3>");
if (qDet.recordCount and len(qDet.audroleid)) {
    try {
        qRole = queryExecute("
            SELECT r.audroleid, r.audprojectid, r.auddialectid, r.audRoleName,
                r.charDescription, r.holdStartDate, r.holdEndDate,
                rt.audroletype, rt.audroletypeid, d.auddialect,
                s.audsource, s.audsourceid, r.contactid, r.payrate, r.netincome, r.buyout,
                r.incometype, r.iscallback, r.isredirect, r.ispin, r.isbooked,
                r.opencallid, c.recordname AS contactname,
                r.paycycleid, pc.paycyclename,
                r.submitsiteid, ss.submitsitename,
                oc.opencallname
            FROM audroles r
            LEFT JOIN audroletypes rt ON rt.audroletypeid = r.audroletypeid
            LEFT JOIN auddialects d ON d.auddialectid = r.auddialectid
            LEFT JOIN audsources s ON s.audsourceid = r.audsourceid
            LEFT JOIN contactdetails c ON c.contactid = r.contactid
            LEFT JOIN paycycles pc ON pc.paycycleid = r.paycycleid
            LEFT JOIN submitsites ss ON ss.submitsiteid = r.submitsiteid
            LEFT JOIN opencalls oc ON oc.opencallid = r.opencallid
            WHERE r.audroleid = :rid
        ", { rid: { value: qDet.audroleid, cfsqltype: "cf_sql_integer" } }, { datasource: datasource });
        if (qRole.recordCount eq 0) {
            writeOutput("<p style='color:red;'>RETURNED 0 ROWS</p>");
        } else {
            writeOutput("<p style='color:green;'>OK - " & qRole.recordCount & " row(s)</p>");
            writeOutput("<table border='1' cellpadding='4' cellspacing='0'>");
            cols = listToArray(qRole.columnList);
            for (c in cols) {
                v = isNull(qRole[c][1]) ? "<em style='color:orange;'>NULL</em>" : htmlEditFormat(toString(qRole[c][1]));
                bg = isNull(qRole[c][1]) ? "background:##fff3cd;" : "";
                writeOutput("<tr style='" & bg & "'><td><strong>" & c & "</strong></td><td>" & v & "</td></tr>");
            }
            writeOutput("</table>");
        }
    } catch (any e) {
        writeOutput("<p style='color:red;'>ERROR: " & e.message & "<br>" & e.detail & "</p>");
    }
} else {
    writeOutput("<p style='color:orange;'>Skipped - no audroleid from project query</p>");
}

// 8) Check for missing lookup tables
writeOutput("<h3>8. Lookup table check</h3>");
lookups = [
    { name: "audroletypes", col: "audroletypeid", val: 1, label: "audRoleTypeID=1 (from import)" },
    { name: "audsteps", col: "audstepid", val: 1, label: "audStepID=1 (from import)" },
    { name: "audtypes", col: "audtypeid", val: 1, label: "audTypeID=1 (In-Person)" },
    { name: "audtypes", col: "audtypeid", val: 2, label: "audTypeID=2 (Self-Tape)" }
];
writeOutput("<table border='1' cellpadding='4' cellspacing='0'>");
for (lk in lookups) {
    qLk = queryExecute("SELECT COUNT(*) AS cnt FROM #lk.name# WHERE #lk.col# = :v",
        { v: { value: lk.val, cfsqltype: "cf_sql_integer" } }, { datasource: datasource });
    bg = qLk.cnt eq 0 ? "background:##f8d7da;" : "background:##d4edda;";
    writeOutput("<tr style='" & bg & "'><td>" & lk.label & "</td><td>" & (qLk.cnt ? "EXISTS" : "MISSING") & "</td></tr>");
}
writeOutput("</table>");
</cfscript>

</body>
</html>
