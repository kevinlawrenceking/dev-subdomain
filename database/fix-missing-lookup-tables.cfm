<cfsilent>
<cfinclude template="/database/admin-guard.cfm">
<cfset datasource = application.dsn>
<cfset schema = application.information_schema>
</cfsilent>
<!DOCTYPE html>
<html>
<head><title>Fix Missing Lookup Tables + isDeleted</title></head>
<body style="font-family:monospace;padding:20px;">
<h2>Fix Missing Lookup Tables + NULL isDeleted (DSN: <cfoutput>#datasource#</cfoutput>)</h2>

<cfscript>
// ============================================================
// 1. Check ALL tables referenced by audition role/project/event queries
// ============================================================
tablesToCheck = [
    // Core tables
    "audprojects", "audroles", "events_tbl",
    // Shared lookup tables
    "audroletypes", "auddialects", "audsources", "audcontracttypes",
    "audtones", "audnetworks", "audunions", "audsubcategories", "audcategories",
    "audtypes", "audsteps", "audpaycycles", "incometypes", "regions", "audplatforms", "countries",
    // User-specific lookup tables (used in main page queries)
    "audsubmitsites_user", "auddialects_user", "audopencalloptions_user",
    "audtones_user", "audnetworks_user", "audplatforms_user",
    // Views
    "contactdetails", "events"
];

writeOutput("<h3>1. Table/View existence check</h3>");
writeOutput("<table border='1' cellpadding='4' cellspacing='0'>");
writeOutput("<tr><th>Table/View</th><th>Status</th></tr>");

missing = [];
for (tbl in tablesToCheck) {
    qCheck = queryExecute(
        "SELECT COUNT(*) AS cnt FROM information_schema.tables
         WHERE table_schema = :schema AND LOWER(table_name) = LOWER(:tbl)",
        {
            schema: { value: schema, cfsqltype: "cf_sql_varchar" },
            tbl: { value: tbl, cfsqltype: "cf_sql_varchar" }
        },
        { datasource: datasource }
    );

    // Also check views
    qView = queryExecute(
        "SELECT COUNT(*) AS cnt FROM information_schema.views
         WHERE table_schema = :schema AND LOWER(table_name) = LOWER(:tbl)",
        {
            schema: { value: schema, cfsqltype: "cf_sql_varchar" },
            tbl: { value: tbl, cfsqltype: "cf_sql_varchar" }
        },
        { datasource: datasource }
    );

    exists = (qCheck.cnt gt 0) or (qView.cnt gt 0);
    isView = qView.cnt gt 0;
    bg = exists ? "background:##d4edda;" : "background:##f8d7da;";
    label = exists ? (isView ? "EXISTS (VIEW)" : "EXISTS (TABLE)") : "MISSING";
    writeOutput("<tr style='" & bg & "'><td>" & tbl & "</td><td>" & label & "</td></tr>");
    if (!exists) arrayAppend(missing, tbl);
}
writeOutput("</table>");

// ============================================================
// 2. Create missing tables
// ============================================================
if (arrayLen(missing) gt 0) {
    writeOutput("<h3>2. Creating missing tables (" & arrayLen(missing) & " missing)</h3>");

    for (tbl in missing) {
        try {
            switch (tbl) {
                case "audpaycycles":
                    queryExecute("
                        CREATE TABLE IF NOT EXISTS audpaycycles (
                            paycycleid INT AUTO_INCREMENT PRIMARY KEY,
                            paycyclename VARCHAR(100) NOT NULL,
                            isDeleted TINYINT DEFAULT 0
                        ) ENGINE=InnoDB
                    ", {}, { datasource: datasource });
                    break;

                case "incometypes":
                    queryExecute("
                        CREATE TABLE IF NOT EXISTS incometypes (
                            incometypeid INT AUTO_INCREMENT PRIMARY KEY,
                            incometype VARCHAR(100) NOT NULL,
                            isDeleted TINYINT DEFAULT 0
                        ) ENGINE=InnoDB
                    ", {}, { datasource: datasource });
                    break;

                case "audsubmitsites_user":
                    queryExecute("
                        CREATE TABLE IF NOT EXISTS audsubmitsites_user (
                            submitsiteid INT AUTO_INCREMENT PRIMARY KEY,
                            submitsitename VARCHAR(200) NOT NULL,
                            userid INT NULL,
                            isDeleted TINYINT DEFAULT 0
                        ) ENGINE=InnoDB
                    ", {}, { datasource: datasource });
                    break;

                case "auddialects_user":
                    // Check if auddialects_user_tbl exists (VIEW pattern)
                    qTbl = queryExecute(
                        "SELECT COUNT(*) AS cnt FROM information_schema.tables
                         WHERE table_schema = :schema AND table_name = 'auddialects_user_tbl'",
                        { schema: { value: schema, cfsqltype: "cf_sql_varchar" } },
                        { datasource: datasource }
                    );
                    if (qTbl.cnt gt 0) {
                        queryExecute("
                            CREATE OR REPLACE VIEW auddialects_user AS
                            SELECT * FROM auddialects_user_tbl WHERE isDeleted = 0
                        ", {}, { datasource: datasource });
                    } else {
                        queryExecute("
                            CREATE TABLE IF NOT EXISTS auddialects_user (
                                auddialectid INT AUTO_INCREMENT PRIMARY KEY,
                                auddialect VARCHAR(100) NOT NULL,
                                audcatid INT NULL,
                                userid INT NULL,
                                isDeleted TINYINT DEFAULT 0
                            ) ENGINE=InnoDB
                        ", {}, { datasource: datasource });
                    }
                    break;

                case "audopencalloptions_user":
                    queryExecute("
                        CREATE TABLE IF NOT EXISTS audopencalloptions_user (
                            opencallid INT AUTO_INCREMENT PRIMARY KEY,
                            opencallname VARCHAR(200) NOT NULL,
                            userid INT NULL,
                            isDeleted TINYINT DEFAULT 0
                        ) ENGINE=InnoDB
                    ", {}, { datasource: datasource });
                    break;

                case "audtones_user":
                    queryExecute("
                        CREATE TABLE IF NOT EXISTS audtones_user (
                            toneid INT AUTO_INCREMENT PRIMARY KEY,
                            tone VARCHAR(100) NOT NULL,
                            userid INT NULL,
                            isDeleted TINYINT DEFAULT 0
                        ) ENGINE=InnoDB
                    ", {}, { datasource: datasource });
                    break;

                case "audnetworks_user":
                    // Check if audnetworks_user_tbl exists (VIEW pattern)
                    qTbl2 = queryExecute(
                        "SELECT COUNT(*) AS cnt FROM information_schema.tables
                         WHERE table_schema = :schema AND table_name = 'audnetworks_user_tbl'",
                        { schema: { value: schema, cfsqltype: "cf_sql_varchar" } },
                        { datasource: datasource }
                    );
                    if (qTbl2.cnt gt 0) {
                        queryExecute("
                            CREATE OR REPLACE VIEW audnetworks_user AS
                            SELECT * FROM audnetworks_user_tbl WHERE isDeleted = 0
                        ", {}, { datasource: datasource });
                    } else {
                        queryExecute("
                            CREATE TABLE IF NOT EXISTS audnetworks_user (
                                networkid INT AUTO_INCREMENT PRIMARY KEY,
                                network VARCHAR(200) NOT NULL,
                                audcatid INT NULL,
                                userid INT NULL,
                                isDeleted TINYINT DEFAULT 0
                            ) ENGINE=InnoDB
                        ", {}, { datasource: datasource });
                    }
                    break;

                case "audplatforms_user":
                    queryExecute("
                        CREATE TABLE IF NOT EXISTS audplatforms_user (
                            audplatformid INT AUTO_INCREMENT PRIMARY KEY,
                            audplatformname VARCHAR(200) NOT NULL,
                            userid INT NULL,
                            isDeleted TINYINT DEFAULT 0
                        ) ENGINE=InnoDB
                    ", {}, { datasource: datasource });
                    break;

                case "regions":
                    queryExecute("
                        CREATE TABLE IF NOT EXISTS regions (
                            region_id INT AUTO_INCREMENT PRIMARY KEY,
                            regionname VARCHAR(100) NOT NULL,
                            countryid INT NULL,
                            isDeleted TINYINT DEFAULT 0
                        ) ENGINE=InnoDB
                    ", {}, { datasource: datasource });
                    break;

                default:
                    writeOutput("<p style='color:orange;'>" & tbl & " - no CREATE script (core table - should already exist)</p>");
                    continue;
            }
            writeOutput("<p style='color:green;'>Created: " & tbl & "</p>");
        } catch (any e) {
            writeOutput("<p style='color:red;'>Error creating " & tbl & ": " & e.message & "</p>");
        }
    }
} else {
    writeOutput("<h3>2. All tables/views exist</h3>");
}

// ============================================================
// 3. Fix NULL isDeleted in events_tbl (imported records)
// ============================================================
writeOutput("<h3>3. Fix NULL isDeleted in events_tbl</h3>");
qNullCheck = queryExecute(
    "SELECT COUNT(*) AS cnt FROM events_tbl WHERE isDeleted IS NULL",
    {}, { datasource: datasource }
);
writeOutput("<p>Records with NULL isDeleted: " & qNullCheck.cnt & "</p>");

if (qNullCheck.cnt gt 0) {
    queryExecute(
        "UPDATE events_tbl SET isDeleted = 0 WHERE isDeleted IS NULL",
        {}, { datasource: datasource }
    );
    writeOutput("<p style='color:green;'>Fixed " & qNullCheck.cnt & " rows: SET isDeleted = 0</p>");
} else {
    writeOutput("<p style='color:green;'>No NULL isDeleted values - all good</p>");
}

// ============================================================
// 4. Verify DETaudroles_24090 (role edit modal query)
// ============================================================
writeOutput("<h3>4. Verify DETaudroles_24090 (role edit modal)</h3>");
// Get the audroleid for audprojectid=873
qRoleId = queryExecute(
    "SELECT audroleid FROM audroles WHERE audprojectid = 873 LIMIT 1",
    {}, { datasource: datasource }
);
if (qRoleId.recordCount) {
    rid = qRoleId.audroleid;
    writeOutput("<p>audroleid for project 873: " & rid & "</p>");
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
            WHERE r.audroleid = :rid
        ", { rid: { value: rid, cfsqltype: "cf_sql_integer" } }, { datasource: datasource });

        if (qRole.recordCount eq 0) {
            writeOutput("<p style='color:red;'>RETURNED 0 ROWS</p>");
        } else {
            writeOutput("<p style='color:green;'>OK - " & qRole.recordCount & " row(s)</p>");
        }
    } catch (any e) {
        writeOutput("<p style='color:red;'>STILL FAILING: " & e.message & "</p><pre>" & htmlEditFormat(e.detail) & "</pre>");
    }
} else {
    writeOutput("<p style='color:red;'>No audroles row found for audprojectid=873</p>");
}

// ============================================================
// 5. Verify SELaudprojects_24097 (appointment edit modal query)
// ============================================================
writeOutput("<h3>5. Verify SELaudprojects_24097 (appointment edit modal)</h3>");
// Get eventid for this project
qEvtId = queryExecute(
    "SELECT e.eventid FROM events_tbl e
     INNER JOIN audroles r ON r.audroleid = e.audroleid
     WHERE r.audprojectid = 873 AND e.isDeleted = 0
     LIMIT 1",
    {}, { datasource: datasource }
);
if (qEvtId.recordCount) {
    eid = qEvtId.eventid;
    writeOutput("<p>eventid for project 873: " & eid & "</p>");
    try {
        qAud = queryExecute("
            SELECT ad.eventid, a4.audroleid, a.projName, ad.eventStart
            FROM audprojects a
            INNER JOIN audroles a4 ON (a.audprojectID = a4.audprojectID)
            INNER JOIN events_tbl ad ON (ad.audroleid = a4.audroleid)
            WHERE ad.eventid = :eid
        ", { eid: { value: eid, cfsqltype: "cf_sql_integer" } }, { datasource: datasource });
        writeOutput("<p style='color:green;'>OK - " & qAud.recordCount & " row(s)</p>");
    } catch (any e) {
        writeOutput("<p style='color:red;'>FAILED: " & e.message & "</p>");
    }
} else {
    writeOutput("<p style='color:red;'>No events found for audprojectid=873 (isDeleted=0)</p>");
}

// ============================================================
// 6. Verify DETaudroles_24544 (role details main page)
// ============================================================
writeOutput("<h3>6. Verify DETaudroles_24544 (main page role query)</h3>");
if (qRoleId.recordCount) {
    try {
        qRole2 = queryExecute("
            SELECT
                r.audroleid, r.audprojectid, r.audRoleName,
                b.submitsitename, rt.audroletype,
                di.auddialect, s.audsource, i.incometype,
                c.recordname AS contactname, p.paycyclename,
                o.opencallname
            FROM audroles r
            LEFT JOIN audsubmitsites_user b ON r.submitsiteid = b.submitsiteid
            LEFT JOIN audroletypes rt ON r.audRoleTypeID = rt.audroletypeid
            LEFT JOIN auddialects_user di ON r.audDialectID = di.auddialectid
            LEFT JOIN audsources s ON r.audsourceid = s.audsourceid
            LEFT JOIN incometypes i ON i.incometypeid = r.incometypeid
            LEFT JOIN contactdetails c ON c.contactid = r.contactid
            LEFT JOIN audpaycycles p ON p.paycycleid = r.paycycleid
            LEFT JOIN audopencalloptions_user o ON o.opencallid = r.opencallid
            WHERE r.audroleid = :rid
        ", { rid: { value: qRoleId.audroleid, cfsqltype: "cf_sql_integer" } }, { datasource: datasource });
        writeOutput("<p style='color:green;'>OK - " & qRole2.recordCount & " row(s)</p>");
    } catch (any e) {
        writeOutput("<p style='color:red;'>FAILED: " & e.message & "</p><pre>" & htmlEditFormat(e.detail) & "</pre>");
    }
}

// ============================================================
// 7. Verify SELevents_24546 (events list via VIEW)
// ============================================================
writeOutput("<h3>7. Verify SELevents_24546 (events list via VIEW)</h3>");
if (qRoleId.recordCount) {
    try {
        qEvts = queryExecute("
            SELECT a.eventid, a.eventStart, a.eventstarttime, p.projname
            FROM events a
            LEFT JOIN audroles r ON r.audroleid = a.audroleid
            LEFT JOIN audprojects p ON p.audprojectID = r.audprojectID
            WHERE a.isdeleted = 0 AND p.isdeleted = 0 AND r.isdeleted = 0
            AND r.audroleid = :rid
            ORDER BY a.eventStart
        ", { rid: { value: qRoleId.audroleid, cfsqltype: "cf_sql_integer" } }, { datasource: datasource });
        writeOutput("<p style='color:green;'>OK - " & qEvts.recordCount & " event(s)</p>");
    } catch (any e) {
        writeOutput("<p style='color:red;'>FAILED: " & e.message & "</p><pre>" & htmlEditFormat(e.detail) & "</pre>");
    }
}

// ============================================================
// 8. Simulate APPOINTMENT modal load chain (remoteaudupdateform.cfm)
//    Step-by-step with try/catch to find exact failure point
// ============================================================
writeOutput("<h3>8. Appointment modal simulation (audprojectid=873, eventid from DB)</h3>");

// Get the eventid dynamically
if (qEvtId.recordCount) {
    testEventId = qEvtId.eventid;
} else {
    testEventId = 0;
}
testUserId = 30;

// Step 8a: MeetingDurationService.SELdurations()
try {
    svc = createObject("component", "services.MeetingDurationService");
    qDur = svc.SELdurations();
    writeOutput("<p style='color:green;'>8a. SELdurations() - OK (" & qDur.recordCount & " rows)</p>");
} catch (any e) {
    writeOutput("<p style='color:red;'>8a. SELdurations() - FAILED: " & e.message & "</p>");
}

// Step 8b: LocationService.getCountries() and getRegions()
try {
    locSvc = createObject("component", "services.LocationService");
    qCountries = locSvc.getCountries();
    qRegions = locSvc.getRegions();
    writeOutput("<p style='color:green;'>8b. LocationService - OK (countries=" & qCountries.recordCount & ", regions=" & qRegions.recordCount & ")</p>");
} catch (any e) {
    writeOutput("<p style='color:red;'>8b. LocationService - FAILED: " & e.message & "</p>");
}

// Step 8c: UserService.getUserById()
try {
    userSvc = createObject("component", "services.UserService");
    userData = userSvc.getUserById(testUserId);
    calStartTime = userData.calStarttime;
    calEndTime = userData.calendtime;
    writeOutput("<p style='color:green;'>8c. UserService.getUserById(" & testUserId & ") - OK (calStartTime=" & calStartTime & ", calEndTime=" & calEndTime & ")</p>");
} catch (any e) {
    writeOutput("<p style='color:red;'>8c. UserService.getUserById() - FAILED: " & e.message & "</p>");
}

// Step 8d: AuditionPlatformUserService.SELaudplatforms_user_24582()
try {
    apuSvc = createObject("component", "services.AuditionPlatformUserService");
    qAPU = apuSvc.SELaudplatforms_user_24582(new_userid=testUserId);
    writeOutput("<p style='color:green;'>8d. SELaudplatforms_user_24582(userid=" & testUserId & ") - OK (" & qAPU.recordCount & " rows)</p>");
} catch (any e) {
    writeOutput("<p style='color:red;'>8d. SELaudplatforms_user_24582() - FAILED: " & e.message & "<br>" & e.detail & "</p>");
}

// Step 8e: DETaudprojects_24089 (project details for appointment modal)
try {
    projSvc = createObject("component", "services.AuditionProjectService");
    qProjDet = projSvc.DETaudprojects_24089(audprojectID=873);
    modalAudroleid = qProjDet.recordCount ? val(qProjDet.audroleid) : 0;
    writeOutput("<p style='color:green;'>8e. DETaudprojects_24089(873) - OK (" & qProjDet.recordCount & " rows, audroleid=" & modalAudroleid & ")</p>");
} catch (any e) {
    writeOutput("<p style='color:red;'>8e. DETaudprojects_24089(873) - FAILED: " & e.message & "<br>" & e.detail & "</p>");
}

// Step 8f: DETaudroles_24090 (role details for appointment modal)
if (modalAudroleid gt 0) {
    try {
        roleSvc = createObject("component", "services.AuditionRoleService");
        qRoleDet = roleSvc.DETaudroles_24090(audroleid=modalAudroleid);
        writeOutput("<p style='color:green;'>8f. DETaudroles_24090(" & modalAudroleid & ") - OK (" & qRoleDet.recordCount & " rows)</p>");
    } catch (any e) {
        writeOutput("<p style='color:red;'>8f. DETaudroles_24090(" & modalAudroleid & ") - FAILED: " & e.message & "<br>" & e.detail & "</p>");
    }
} else {
    writeOutput("<p style='color:orange;'>8f. Skipped - no audroleid</p>");
}

// Step 8g: DETevents_24675 (location details)
try {
    evtSvc = createObject("component", "services.EventService");
    qLocDet = evtSvc.DETevents_24675(audprojectid=873);
    writeOutput("<p style='color:green;'>8g. DETevents_24675(873) - OK (" & qLocDet.recordCount & " rows)</p>");
    if (qLocDet.recordCount eq 0) {
        writeOutput("<p style='color:orange;'>&nbsp;&nbsp;&nbsp;0 rows is OK - imported event has NULL eventlocation, defaults will be used</p>");
    }
} catch (any e) {
    writeOutput("<p style='color:red;'>8g. DETevents_24675(873) - FAILED: " & e.message & "<br>" & e.detail & "</p>");
}

// Step 8h: SELaudprojects_24097 (aud_det - the main appointment detail query)
if (testEventId gt 0) {
    try {
        qAudDet = projSvc.SELaudprojects_24097(eventid=testEventId);
        writeOutput("<p style='color:green;'>8h. SELaudprojects_24097(eventid=" & testEventId & ") - OK (" & qAudDet.recordCount & " rows)</p>");
        if (qAudDet.recordCount gt 0) {
            // Show key fields and their NULL status
            fields = "audstepid,audtypeid,eventStart,eventStartTime,audplatformid,audcatid,audsubcatid,parkingdetails,audlocation,region_id,countryid,new_durhours";
            for (f in listToArray(fields)) {
                fv = isNull(qAudDet[f][1]) ? "NULL" : toString(qAudDet[f][1]);
                fc = (fv eq "NULL" or fv eq "") ? "color:orange;" : "color:green;";
                writeOutput("<p style='" & fc & "'>&nbsp;&nbsp;&nbsp;" & f & " = " & (len(fv) ? fv : "(empty)") & "</p>");
            }
        }
    } catch (any e) {
        writeOutput("<p style='color:red;'>8h. SELaudprojects_24097(eventid=" & testEventId & ") - FAILED: " & e.message & "<br>" & e.detail & "</p>");
    }
} else {
    writeOutput("<p style='color:red;'>8h. Skipped - no eventid found</p>");
}

// Step 8i: AuditionTypeService.getAudtypes() (dropdown population)
try {
    atSvc = createObject("component", "services.AuditionTypeService");
    qAudTypes = atSvc.getAudtypes(0);
    writeOutput("<p style='color:green;'>8i. AuditionTypeService.getAudtypes(0) - OK (" & qAudTypes.recordCount & " rows)</p>");
} catch (any e) {
    writeOutput("<p style='color:red;'>8i. AuditionTypeService.getAudtypes() - FAILED: " & e.message & "<br>" & e.detail & "</p>");
}

// Step 8j: AuditionStepService.SELaudsteps_24083()
try {
    asSvc = createObject("component", "services.AuditionStepService");
    qSteps = asSvc.SELaudsteps_24083(isDeleted=false);
    writeOutput("<p style='color:green;'>8j. SELaudsteps_24083() - OK (" & qSteps.recordCount & " rows)</p>");
} catch (any e) {
    writeOutput("<p style='color:red;'>8j. SELaudsteps_24083() - FAILED: " & e.message & "<br>" & e.detail & "</p>");
}

// Step 8k: audplatforms table (generic dropdown)
try {
    qPlat = queryExecute("
        SELECT a.audplatformid as ID, a.audplatform as NAME
        FROM audplatforms a WHERE a.isDeleted is false ORDER BY a.audplatform
    ", {}, { datasource: datasource });
    writeOutput("<p style='color:green;'>8k. audplatforms table query - OK (" & qPlat.recordCount & " rows)</p>");
} catch (any e) {
    writeOutput("<p style='color:red;'>8k. audplatforms table query - FAILED: " & e.message & "<br>" & e.detail & "</p>");
}

// Step 8l: MeetingDurationService.SELmtgdurations (findd)
try {
    qFindd = svc.SELmtgdurations(new_durhours=1);
    writeOutput("<p style='color:green;'>8l. SELmtgdurations(1) - OK (" & qFindd.recordCount & " rows)</p>");
} catch (any e) {
    writeOutput("<p style='color:red;'>8l. SELmtgdurations() - FAILED: " & e.message & "<br>" & e.detail & "</p>");
}

// ============================================================
// 9. Simulate ROLE modal load chain (roleupdateform.cfm -> audition.cfm)
// ============================================================
writeOutput("<h3>9. Role modal simulation (audprojectid=873)</h3>");

// Step 9a: DETaudprojects_24543 (main page project query)
try {
    qProjMain = projSvc.DETaudprojects_24543(audprojectID=873);
    mainAudroleid = qProjMain.recordCount ? val(qProjMain.audroleid) : 0;
    writeOutput("<p style='color:green;'>9a. DETaudprojects_24543(873) - OK (" & qProjMain.recordCount & " rows, audroleid=" & mainAudroleid & ")</p>");
} catch (any e) {
    writeOutput("<p style='color:red;'>9a. DETaudprojects_24543(873) - FAILED: " & e.message & "<br>" & e.detail & "</p>");
}

// Step 9b: DETaudroles_24544 (main page role query, also used by role modal)
if (mainAudroleid gt 0) {
    try {
        qRoleMain = roleSvc.DETaudroles_24544(audroleid=mainAudroleid);
        writeOutput("<p style='color:green;'>9b. DETaudroles_24544(" & mainAudroleid & ") - OK (" & qRoleMain.recordCount & " rows)</p>");
    } catch (any e) {
        writeOutput("<p style='color:red;'>9b. DETaudroles_24544(" & mainAudroleid & ") - FAILED: " & e.message & "<br>" & e.detail & "</p>");
    }
} else {
    writeOutput("<p style='color:orange;'>9b. Skipped - no audroleid from 9a</p>");
}

// Step 9c: SELevents_24546 (events list for role)
if (mainAudroleid gt 0) {
    try {
        qEvtList = evtSvc.SELevents_24546(audroleid=mainAudroleid);
        writeOutput("<p style='color:green;'>9c. SELevents_24546(" & mainAudroleid & ") - OK (" & qEvtList.recordCount & " events)</p>");
    } catch (any e) {
        writeOutput("<p style='color:red;'>9c. SELevents_24546(" & mainAudroleid & ") - FAILED: " & e.message & "<br>" & e.detail & "</p>");
    }
} else {
    writeOutput("<p style='color:orange;'>9c. Skipped</p>");
}

// Step 9d: SELevents_24547 (no-booking events)
if (mainAudroleid gt 0) {
    try {
        qEvtNB = evtSvc.SELevents_24547(audroleid=mainAudroleid);
        writeOutput("<p style='color:green;'>9d. SELevents_24547(" & mainAudroleid & ") - OK (" & qEvtNB.recordCount & " rows)</p>");
    } catch (any e) {
        writeOutput("<p style='color:red;'>9d. SELevents_24547(" & mainAudroleid & ") - FAILED: " & e.message & "<br>" & e.detail & "</p>");
    }
} else {
    writeOutput("<p style='color:orange;'>9d. Skipped</p>");
}

// Step 9e: EventContactsXRefService.eventaudsync()
try {
    xrefSvc = createObject("component", "services.EventContactsXRefService");
    xrefSvc.eventaudsync(873);
    writeOutput("<p style='color:green;'>9e. eventaudsync(873) - OK</p>");
} catch (any e) {
    writeOutput("<p style='color:red;'>9e. eventaudsync(873) - FAILED: " & e.message & "<br>" & e.detail & "</p>");
}

// Step 9f: SELaudprojects_24550 (cdcheck)
try {
    qCdCheck = projSvc.SELaudprojects_24550(audprojectID=873);
    writeOutput("<p style='color:green;'>9f. SELaudprojects_24550(873) cdcheck - OK (" & qCdCheck.recordCount & " rows, contactid=" & (qCdCheck.recordCount ? qCdCheck.contactid : "N/A") & ")</p>");
} catch (any e) {
    writeOutput("<p style='color:red;'>9f. SELaudprojects_24550(873) - FAILED: " & e.message & "<br>" & e.detail & "</p>");
}

writeOutput("<hr><p><strong>Done.</strong> If all checks are green, reload <a href='/app/audition/?audprojectid=873'>/app/audition/?audprojectid=873</a> and try editing appointment and role.</p>");
writeOutput("<p>Any RED items above indicate the exact failure point that needs fixing.</p>");
</cfscript>

</body>
</html>
