<cfsilent>
<cfinclude template="/database/admin-guard.cfm">
<cfset datasource = application.dsn>
<cfset pid = 873>
<cfset rid = 822>
<cfset eid = 1574>
</cfsilent>
<!DOCTYPE html>
<html>
<head><title>Diag v2: audprojectid=<cfoutput>#pid#</cfoutput></title></head>
<body style="font-family:monospace;padding:20px;">
<h2>Diagnostic v2 - Exact Service Queries (DSN: <cfoutput>#datasource#</cfoutput>)</h2>

<cfscript>
// 1) Check all tables referenced by the three modal queries
writeOutput("<h3>1. Table existence check</h3>");
tables = [
    "audprojects", "audroles", "events_tbl", "events",
    "audroletypes", "auddialects", "auddialects_user", "audsources",
    "incometypes", "contactdetails", "audpaycycles",
    "audsubmitsites_user", "audopencalloptions_user",
    "audsubcategories", "audcategories",
    "audcontracttypes", "audtones", "audtones_user",
    "audnetworks", "audnetworks_user", "audunions",
    "audsteps", "audtypes", "audplatforms_user",
    "regions", "paycycles"
];
writeOutput("<table border='1' cellpadding='4' cellspacing='0'>");
for (tbl in tables) {
    try {
        qCheck = queryExecute("SELECT 1 FROM #tbl# LIMIT 1", {}, { datasource: datasource });
        writeOutput("<tr style='background:##d4edda;'><td>" & tbl & "</td><td>EXISTS</td></tr>");
    } catch (any e) {
        writeOutput("<tr style='background:##f8d7da;'><td><strong>" & tbl & "</strong></td><td>MISSING - " & e.message & "</td></tr>");
    }
}
writeOutput("</table>");

// 2) Run EXACT service: DETaudroles_24090 (roleDetails for modal)
writeOutput("<h3>2. DETaudroles_24090 (role details - modal query, audroleid=" & rid & ")</h3>");
try {
    roleService = createObject("component", "services.AuditionRoleService");
    qRole = roleService.DETaudroles_24090(audroleid = rid);
    writeOutput("<p style='color:green;'>OK - " & qRole.recordCount & " row(s)</p>");
    if (qRole.recordCount) {
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
    writeOutput("<p style='color:red;'>ERROR: " & e.message & "</p><pre>" & htmlEditFormat(e.detail) & "</pre>");
}

// 3) Run EXACT service: DETaudroles_24544 (role details - main page query)
writeOutput("<h3>3. DETaudroles_24544 (role details - main page, audroleid=" & rid & ")</h3>");
try {
    qRole2 = roleService.DETaudroles_24544(audroleid = rid);
    writeOutput("<p style='color:green;'>OK - " & qRole2.recordCount & " row(s)</p>");
} catch (any e) {
    writeOutput("<p style='color:red;'>ERROR: " & e.message & "</p><pre>" & htmlEditFormat(e.detail) & "</pre>");
}

// 4) Run EXACT service: SELaudprojects_24097 (audition edit modal)
writeOutput("<h3>4. SELaudprojects_24097 (edit audition modal, eventid=" & eid & ")</h3>");
try {
    projService = createObject("component", "services.AuditionProjectService");
    qAud = projService.SELaudprojects_24097(eventid = eid);
    writeOutput("<p style='color:green;'>OK - " & qAud.recordCount & " row(s)</p>");
} catch (any e) {
    writeOutput("<p style='color:red;'>ERROR: " & e.message & "</p><pre>" & htmlEditFormat(e.detail) & "</pre>");
}

// 5) Simulate the full remoteaudupdateform.cfm flow
writeOutput("<h3>5. Simulate remoteaudupdateform.cfm load chain</h3>");

// Step A: projectDetails_221_1
writeOutput("<p><strong>Step A: DETaudprojects_24089(audprojectID=" & pid & ")</strong></p>");
try {
    qProjDet = projService.DETaudprojects_24089(audprojectID = pid);
    writeOutput("<p style='color:green;'>OK - audroleid=" & qProjDet.audroleid & "</p>");
    simRoleid = qProjDet.audroleid;
} catch (any e) {
    writeOutput("<p style='color:red;'>FAILED: " & e.message & "</p>");
    simRoleid = 0;
}

// Step B: roleDetails_221_2
if (simRoleid gt 0) {
    writeOutput("<p><strong>Step B: DETaudroles_24090(audroleid=" & simRoleid & ")</strong></p>");
    try {
        qSimRole = roleService.DETaudroles_24090(audroleid = simRoleid);
        writeOutput("<p style='color:green;'>OK - " & qSimRole.recordCount & " row(s)</p>");
    } catch (any e) {
        writeOutput("<p style='color:red;'>FAILED: " & e.message & "</p><pre>" & htmlEditFormat(e.detail) & "</pre>");
    }
}

// Step C: aud_det_221_9
writeOutput("<p><strong>Step C: SELaudprojects_24097(eventid=" & eid & ")</strong></p>");
try {
    qSimAud = projService.SELaudprojects_24097(eventid = eid);
    writeOutput("<p style='color:green;'>OK - " & qSimAud.recordCount & " row(s)</p>");
} catch (any e) {
    writeOutput("<p style='color:red;'>FAILED: " & e.message & "</p><pre>" & htmlEditFormat(e.detail) & "</pre>");
}

// 6) Check audition.cfm main page query chain
writeOutput("<h3>6. audition.cfm main page chain</h3>");
writeOutput("<p><strong>DETaudprojects_24543(audprojectID=" & pid & ")</strong></p>");
try {
    qMain = projService.DETaudprojects_24543(audprojectID = pid);
    writeOutput("<p style='color:green;'>OK - " & qMain.recordCount & " row(s)</p>");
    if (qMain.recordCount) {
        mainRoleid = qMain.audroleid;
        writeOutput("<p><strong>DETaudroles_24544(audroleid=" & mainRoleid & ")</strong></p>");
        try {
            qMainRole = roleService.DETaudroles_24544(audroleid = mainRoleid);
            writeOutput("<p style='color:green;'>OK - " & qMainRole.recordCount & " row(s)</p>");
        } catch (any e) {
            writeOutput("<p style='color:red;'>FAILED: " & e.message & "</p><pre>" & htmlEditFormat(e.detail) & "</pre>");
        }

        // Events query
        writeOutput("<p><strong>SELevents_24546(audroleid=" & mainRoleid & ")</strong></p>");
        try {
            eventService = createObject("component", "services.EventService");
            qEvts = eventService.SELevents_24546(audroleid = mainRoleid);
            writeOutput("<p style='color:green;'>OK - " & qEvts.recordCount & " event(s)</p>");
        } catch (any e) {
            writeOutput("<p style='color:red;'>FAILED: " & e.message & "</p><pre>" & htmlEditFormat(e.detail) & "</pre>");
        }
    }
} catch (any e) {
    writeOutput("<p style='color:red;'>FAILED: " & e.message & "</p><pre>" & htmlEditFormat(e.detail) & "</pre>");
}
</cfscript>

</body>
</html>
