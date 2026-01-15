<!---
TAO Relationship System Repair Runner
=====================================
IMPORTANT: Run against test database (new_development) first!

Access: /scripts/relationship_system/repair_relationship_system.cfm

Parameters:
  dryRun (default: Y) - Set to N to apply fixes
  fixA (default: N) - Fix orphaned notifications
  fixB (default: N) - Create missing actionusers
  fixC (default: N) - Fix multiple active pending per suid
  fixD (default: N) - Reschedule stuck systems
  fixE (default: N) - Deduplicate system enrollments
  fixH (default: N) - Fix consistency issues

Security: Restrict to admin users in production
--->
<cfparam name="dsn" default="reach" />
<cfparam name="dryRun" default="Y" />
<cfparam name="fixA" default="N" />
<cfparam name="fixB" default="N" />
<cfparam name="fixC" default="N" />
<cfparam name="fixD" default="N" />
<cfparam name="fixE" default="N" />
<cfparam name="fixH" default="N" />
<cfparam name="applyAll" default="N" />

<!--- If applyAll is set, enable all fixes --->
<cfif applyAll EQ "Y">
    <cfset fixA = "Y" />
    <cfset fixB = "Y" />
    <cfset fixC = "Y" />
    <cfset fixD = "Y" />
    <cfset fixE = "Y" />
    <cfset fixH = "Y" />
</cfif>

<!--- Initialize logging --->
<cfset repairLog = [] />
<cfset startTime = GetTickCount() />

<cffunction name="logAction" output="false" returntype="void">
    <cfargument name="category" type="string" required="true" />
    <cfargument name="action" type="string" required="true" />
    <cfargument name="details" type="string" required="false" default="" />
    <cfargument name="affectedIds" type="string" required="false" default="" />
    <cfargument name="isDryRun" type="boolean" required="false" default="true" />

    <cfset var logEntry = {
        "timestamp": DateTimeFormat(Now(), "yyyy-mm-dd HH:nn:ss"),
        "category": arguments.category,
        "action": arguments.action,
        "details": arguments.details,
        "affectedIds": arguments.affectedIds,
        "mode": arguments.isDryRun ? "DRY-RUN" : "APPLIED"
    } />
    <cfset ArrayAppend(repairLog, logEntry) />
</cffunction>

<!DOCTYPE html>
<html>
<head>
    <title>TAO Relationship System Repair Runner</title>
    <style>
        body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; margin: 20px; }
        h1 { color: #333; border-bottom: 2px solid #dc3545; padding-bottom: 10px; }
        h2 { color: #555; margin-top: 30px; }
        .dry-run { background: #fff3cd; border: 1px solid #ffc107; padding: 15px; margin: 20px 0; border-radius: 5px; }
        .applied { background: #d4edda; border: 1px solid #28a745; padding: 15px; margin: 20px 0; border-radius: 5px; }
        .warning { background: #f8d7da; border: 1px solid #dc3545; padding: 15px; margin: 20px 0; border-radius: 5px; }
        table { border-collapse: collapse; margin: 10px 0; width: 100%; max-width: 1200px; }
        th, td { border: 1px solid #ddd; padding: 8px 12px; text-align: left; }
        th { background: #f5f5f5; font-weight: 600; }
        tr:nth-child(even) { background: #fafafa; }
        .log-entry { font-family: monospace; font-size: 12px; margin: 2px 0; }
        .mode-dryrun { color: #856404; }
        .mode-applied { color: #155724; }
        pre { background: #f5f5f5; padding: 10px; overflow-x: auto; font-size: 12px; }
        .toggle-form { background: #f8f9fa; padding: 15px; margin: 20px 0; border-radius: 5px; }
        .toggle-form label { display: block; margin: 5px 0; }
        .btn { padding: 10px 20px; margin: 5px; cursor: pointer; border: none; border-radius: 4px; }
        .btn-primary { background: #007bff; color: white; }
        .btn-danger { background: #dc3545; color: white; }
        .btn-secondary { background: #6c757d; color: white; }
    </style>
</head>
<body>

<h1>TAO Relationship System - Repair Runner</h1>

<cfif dryRun EQ "Y">
    <div class="dry-run">
        <strong>DRY-RUN MODE:</strong> No changes will be made. Review the proposed fixes below.
    </div>
<cfelse>
    <div class="warning">
        <strong>LIVE MODE:</strong> Changes WILL be applied to the database!
    </div>
</cfif>

<p>Database: <cfoutput>#dsn#</cfoutput> | Time: <cfoutput>#DateTimeFormat(Now(), "yyyy-mm-dd HH:nn:ss")#</cfoutput></p>

<!--- Control Form --->
<div class="toggle-form">
    <form method="GET">
        <h3>Fix Controls</h3>
        <label><input type="checkbox" name="fixA" value="Y" <cfif fixA EQ "Y">checked</cfif>> Fix A: Soft-delete orphaned notifications</label>
        <label><input type="checkbox" name="fixB" value="Y" <cfif fixB EQ "Y">checked</cfif>> Fix B: Create missing actionusers rows</label>
        <label><input type="checkbox" name="fixC" value="Y" <cfif fixC EQ "Y">checked</cfif>> Fix C: Fix multiple active pending per suid</label>
        <label><input type="checkbox" name="fixD" value="Y" <cfif fixD EQ "Y">checked</cfif>> Fix D: Reschedule stuck systems</label>
        <label><input type="checkbox" name="fixE" value="Y" <cfif fixE EQ "Y">checked</cfif>> Fix E: Deduplicate system enrollments</label>
        <label><input type="checkbox" name="fixH" value="Y" <cfif fixH EQ "Y">checked</cfif>> Fix H: Fix consistency issues</label>
        <br>
        <label><input type="checkbox" name="dryRun" value="Y" <cfif dryRun EQ "Y">checked</cfif>> <strong>Dry Run Mode</strong> (uncheck to apply)</label>
        <br><br>
        <button type="submit" class="btn btn-primary">Run Selected Fixes</button>
        <a href="?dryRun=Y&applyAll=Y" class="btn btn-secondary">Preview All Fixes</a>
    </form>
</div>

<!--- ===================================================================== --->
<!--- FIX A: Orphaned Notifications --->
<!--- ===================================================================== --->
<cfif fixA EQ "Y">
    <h2>Fix A: Orphaned Notifications</h2>

    <!--- A1: Missing suid --->
    <cfquery name="orphanedSuid" datasource="#dsn#">
        SELECT n.notid, n.suid, n.userid, n.actionid, n.notstatus
        FROM funotifications n
        LEFT JOIN fusystemusers su ON su.suid = n.suid
        WHERE su.suid IS NULL
          AND n.isdeleted = 0
        LIMIT 100
    </cfquery>

    <p><strong>A1: Notifications with missing suid:</strong> <cfoutput>#orphanedSuid.recordCount#</cfoutput> found</p>

    <cfif orphanedSuid.recordCount GT 0>
        <cfset orphanedIds = ValueList(orphanedSuid.notid) />
        <cfset logAction("A1", "soft-delete orphaned notifications (missing suid)", "Count: " & orphanedSuid.recordCount, orphanedIds, dryRun EQ "Y") />

        <cfif dryRun EQ "N">
            <cfquery datasource="#dsn#">
                UPDATE funotifications
                SET isdeleted = 1
                WHERE notid IN (<cfqueryparam value="#orphanedIds#" cfsqltype="CF_SQL_INTEGER" list="true">)
            </cfquery>
            <p class="mode-applied">Applied: Soft-deleted #orphanedSuid.recordCount# orphaned notifications</p>
        <cfelse>
            <p class="mode-dryrun">Would soft-delete notifications: <cfoutput>#orphanedIds#</cfoutput></p>
        </cfif>
    </cfif>

    <!--- A2: Missing actionid --->
    <cfquery name="orphanedActionid" datasource="#dsn#">
        SELECT n.notid, n.actionid
        FROM funotifications n
        LEFT JOIN fuactions a ON a.actionid = n.actionid
        WHERE a.actionid IS NULL
          AND n.isdeleted = 0
        LIMIT 100
    </cfquery>

    <p><strong>A2: Notifications with missing actionid:</strong> <cfoutput>#orphanedActionid.recordCount#</cfoutput> found</p>

    <cfif orphanedActionid.recordCount GT 0>
        <cfset orphanedIds = ValueList(orphanedActionid.notid) />
        <cfset logAction("A2", "soft-delete orphaned notifications (missing actionid)", "Count: " & orphanedActionid.recordCount, orphanedIds, dryRun EQ "Y") />

        <cfif dryRun EQ "N">
            <cfquery datasource="#dsn#">
                UPDATE funotifications
                SET isdeleted = 1
                WHERE notid IN (<cfqueryparam value="#orphanedIds#" cfsqltype="CF_SQL_INTEGER" list="true">)
            </cfquery>
            <p class="mode-applied">Applied: Soft-deleted #orphanedActionid.recordCount# orphaned notifications</p>
        <cfelse>
            <p class="mode-dryrun">Would soft-delete notifications: <cfoutput>#orphanedIds#</cfoutput></p>
        </cfif>
    </cfif>
</cfif>

<!--- ===================================================================== --->
<!--- FIX B: Missing ActionUsers --->
<!--- ===================================================================== --->
<cfif fixB EQ "Y">
    <h2>Fix B: Create Missing ActionUsers Rows</h2>

    <cfquery name="missingActionUsers" datasource="#dsn#">
        SELECT u.userid, a.actionid, a.actiondaysno, a.actiondaysrecurring
        FROM taousers u
        CROSS JOIN fuactions a
        LEFT JOIN actionusers au ON au.userid = u.userid AND au.actionid = a.actionid
        WHERE au.id IS NULL
          AND u.userstatus = 'Active'
        LIMIT 500
    </cfquery>

    <p><strong>Missing actionusers rows:</strong> <cfoutput>#missingActionUsers.recordCount#</cfoutput> found</p>

    <cfif missingActionUsers.recordCount GT 0>
        <cfset logAction("B1", "create missing actionusers", "Count: " & missingActionUsers.recordCount, "", dryRun EQ "Y") />

        <cfif dryRun EQ "N">
            <cfset insertCount = 0 />
            <cfloop query="missingActionUsers">
                <cfquery datasource="#dsn#">
                    INSERT INTO actionusers (actionid, userid, actiondaysno, actiondaysrecurring, isdeleted)
                    VALUES (
                        <cfqueryparam value="#missingActionUsers.actionid#" cfsqltype="CF_SQL_INTEGER">,
                        <cfqueryparam value="#missingActionUsers.userid#" cfsqltype="CF_SQL_INTEGER">,
                        <cfqueryparam value="#missingActionUsers.actiondaysno#" cfsqltype="CF_SQL_INTEGER" null="#NOT Len(missingActionUsers.actiondaysno)#">,
                        <cfqueryparam value="#missingActionUsers.actiondaysrecurring#" cfsqltype="CF_SQL_INTEGER" null="#NOT Len(missingActionUsers.actiondaysrecurring)#">,
                        0
                    )
                </cfquery>
                <cfset insertCount = insertCount + 1 />
            </cfloop>
            <p class="mode-applied">Applied: Created <cfoutput>#insertCount#</cfoutput> actionusers rows</p>
        <cfelse>
            <p class="mode-dryrun">Would create <cfoutput>#missingActionUsers.recordCount#</cfoutput> actionusers rows</p>
            <cfoutput query="missingActionUsers" maxrows="10">
                <div class="log-entry">- userid: #userid#, actionid: #actionid#</div>
            </cfoutput>
            <cfif missingActionUsers.recordCount GT 10>
                <p>... and <cfoutput>#missingActionUsers.recordCount - 10#</cfoutput> more</p>
            </cfif>
        </cfif>
    </cfif>
</cfif>

<!--- ===================================================================== --->
<!--- FIX C: Multiple Active Pending Per SUID --->
<!--- ===================================================================== --->
<cfif fixC EQ "Y">
    <h2>Fix C: Multiple Active Pending Per SUID</h2>

    <!--- Find suids with multiple pending notifications that have dates --->
    <cfquery name="multiPendingSuids" datasource="#dsn#">
        SELECT suid
        FROM funotifications
        WHERE notstatus = 'Pending'
          AND notstartdate IS NOT NULL
          AND isdeleted = 0
        GROUP BY suid
        HAVING COUNT(*) > 1
    </cfquery>

    <p><strong>SUIds with multiple active pending:</strong> <cfoutput>#multiPendingSuids.recordCount#</cfoutput> found</p>

    <cfif multiPendingSuids.recordCount GT 0>
        <cfset fixedCount = 0 />

        <cfloop query="multiPendingSuids">
            <!--- For each suid, keep only the earliest dated pending notification --->
            <cfquery name="pendingForSuid" datasource="#dsn#">
                SELECT notid, notstartdate
                FROM funotifications
                WHERE suid = <cfqueryparam value="#multiPendingSuids.suid#" cfsqltype="CF_SQL_INTEGER">
                  AND notstatus = 'Pending'
                  AND notstartdate IS NOT NULL
                  AND isdeleted = 0
                ORDER BY notstartdate ASC
            </cfquery>

            <cfif pendingForSuid.recordCount GT 1>
                <!--- Get the first one (to keep) and the rest (to null their dates) --->
                <cfset keepId = pendingForSuid.notid[1] />
                <cfset nullIds = [] />
                <cfloop from="2" to="#pendingForSuid.recordCount#" index="i">
                    <cfset ArrayAppend(nullIds, pendingForSuid.notid[i]) />
                </cfloop>
                <cfset nullIdList = ArrayToList(nullIds) />

                <cfset logAction("C1", "null notstartdate on duplicate pending", "suid: " & multiPendingSuids.suid & ", keeping notid: " & keepId, nullIdList, dryRun EQ "Y") />

                <cfif dryRun EQ "N">
                    <cfquery datasource="#dsn#">
                        UPDATE funotifications
                        SET notstartdate = NULL
                        WHERE notid IN (<cfqueryparam value="#nullIdList#" cfsqltype="CF_SQL_INTEGER" list="true">)
                    </cfquery>
                    <cfset fixedCount = fixedCount + ArrayLen(nullIds) />
                <cfelse>
                    <p class="mode-dryrun log-entry">suid <cfoutput>#multiPendingSuids.suid#</cfoutput>: Would keep notid <cfoutput>#keepId#</cfoutput>, null dates on: <cfoutput>#nullIdList#</cfoutput></p>
                </cfif>
            </cfif>
        </cfloop>

        <cfif dryRun EQ "N">
            <p class="mode-applied">Applied: Fixed <cfoutput>#fixedCount#</cfoutput> duplicate pending notifications</p>
        </cfif>
    </cfif>
</cfif>

<!--- ===================================================================== --->
<!--- FIX D: Stuck Systems --->
<!--- ===================================================================== --->
<cfif fixD EQ "Y">
    <h2>Fix D: Reschedule Stuck Systems</h2>

    <!--- D2: Systems with pending notification that has NULL notstartdate --->
    <cfquery name="stuckNullDate" datasource="#dsn#">
        SELECT
            su.suid,
            su.contactid,
            su.userid,
            su.sustartdate,
            n.notid,
            n.actionid,
            COALESCE(au.actiondaysno, a.actiondaysno, 0) AS actiondaysno
        FROM fusystemusers su
        INNER JOIN funotifications n ON n.suid = su.suid
        INNER JOIN fuactions a ON a.actionid = n.actionid
        LEFT JOIN actionusers au ON au.actionid = n.actionid AND au.userid = su.userid
        WHERE su.sustatus = 'Active'
          AND su.isdeleted = 0
          AND n.notstatus = 'Pending'
          AND n.notstartdate IS NULL
          AND n.isdeleted = 0
          AND NOT EXISTS (
              SELECT 1 FROM funotifications n2
              WHERE n2.suid = su.suid
                AND n2.notstatus = 'Pending'
                AND n2.notstartdate IS NOT NULL
                AND n2.isdeleted = 0
          )
        ORDER BY su.suid, n.notid
        LIMIT 100
    </cfquery>

    <p><strong>Stuck notifications with NULL notstartdate:</strong> <cfoutput>#stuckNullDate.recordCount#</cfoutput> found</p>

    <cfif stuckNullDate.recordCount GT 0>
        <cfset fixedCount = 0 />
        <cfset processedSuids = "" />

        <cfloop query="stuckNullDate">
            <!--- Only process first notification per suid --->
            <cfif NOT ListFind(processedSuids, stuckNullDate.suid)>
                <cfset processedSuids = ListAppend(processedSuids, stuckNullDate.suid) />

                <!--- Calculate the notstartdate based on sustartdate + actiondaysno --->
                <cfset calculatedDate = DateAdd("d", stuckNullDate.actiondaysno, stuckNullDate.sustartdate) />
                <!--- If calculated date is in past, use today --->
                <cfif calculatedDate LT Now()>
                    <cfset calculatedDate = Now() />
                </cfif>
                <cfset formattedDate = DateFormat(calculatedDate, "yyyy-mm-dd") />

                <cfset logAction("D2", "set notstartdate on stuck notification", "notid: " & stuckNullDate.notid & ", date: " & formattedDate, stuckNullDate.notid, dryRun EQ "Y") />

                <cfif dryRun EQ "N">
                    <cfquery datasource="#dsn#">
                        UPDATE funotifications
                        SET notstartdate = <cfqueryparam value="#formattedDate#" cfsqltype="CF_SQL_DATE">
                        WHERE notid = <cfqueryparam value="#stuckNullDate.notid#" cfsqltype="CF_SQL_INTEGER">
                    </cfquery>
                    <cfset fixedCount = fixedCount + 1 />
                <cfelse>
                    <p class="mode-dryrun log-entry">notid <cfoutput>#stuckNullDate.notid#</cfoutput> (suid <cfoutput>#stuckNullDate.suid#</cfoutput>): Would set notstartdate to <cfoutput>#formattedDate#</cfoutput></p>
                </cfif>
            </cfif>
        </cfloop>

        <cfif dryRun EQ "N">
            <p class="mode-applied">Applied: Scheduled <cfoutput>#fixedCount#</cfoutput> stuck notifications</p>
        </cfif>
    </cfif>
</cfif>

<!--- ===================================================================== --->
<!--- FIX E: Duplicate System Enrollments --->
<!--- ===================================================================== --->
<cfif fixE EQ "Y">
    <h2>Fix E: Deduplicate System Enrollments</h2>

    <!--- Find duplicate active enrollments --->
    <cfquery name="duplicateEnrollments" datasource="#dsn#">
        SELECT
            su.suid,
            su.userid,
            su.contactid,
            su.systemid,
            su.sustartdate,
            ROW_NUMBER() OVER (
                PARTITION BY su.userid, su.contactid, su.systemid
                ORDER BY su.sustartdate DESC, su.suid DESC
            ) AS row_num
        FROM fusystemusers su
        WHERE su.sustatus = 'Active'
          AND su.isdeleted = 0
          AND (su.userid, su.contactid, su.systemid) IN (
              SELECT userid, contactid, systemid
              FROM fusystemusers
              WHERE sustatus = 'Active'
                AND isdeleted = 0
              GROUP BY userid, contactid, systemid
              HAVING COUNT(*) > 1
          )
        ORDER BY su.userid, su.contactid, su.systemid, row_num
    </cfquery>

    <p><strong>Duplicate enrollment entries:</strong> <cfoutput>#duplicateEnrollments.recordCount#</cfoutput> found</p>

    <cfif duplicateEnrollments.recordCount GT 0>
        <!--- Collect IDs to mark as completed (all except row_num = 1) --->
        <cfset completeIds = [] />
        <cfloop query="duplicateEnrollments">
            <cfif duplicateEnrollments.row_num GT 1>
                <cfset ArrayAppend(completeIds, duplicateEnrollments.suid) />
            </cfif>
        </cfloop>

        <cfif ArrayLen(completeIds) GT 0>
            <cfset completeIdList = ArrayToList(completeIds) />
            <cfset logAction("E1", "mark duplicate enrollments as Completed", "Count: " & ArrayLen(completeIds), completeIdList, dryRun EQ "Y") />

            <cfif dryRun EQ "N">
                <cfquery datasource="#dsn#">
                    UPDATE fusystemusers
                    SET sustatus = 'Completed',
                        sunotes = CONCAT(COALESCE(sunotes, ''), ' [Deduplicated by repair script ', NOW(), ']')
                    WHERE suid IN (<cfqueryparam value="#completeIdList#" cfsqltype="CF_SQL_INTEGER" list="true">)
                </cfquery>
                <p class="mode-applied">Applied: Marked <cfoutput>#ArrayLen(completeIds)#</cfoutput> duplicate enrollments as Completed</p>
            <cfelse>
                <p class="mode-dryrun">Would mark as Completed: <cfoutput>#completeIdList#</cfoutput></p>
            </cfif>
        </cfif>
    </cfif>
</cfif>

<!--- ===================================================================== --->
<!--- FIX H: Consistency Issues --->
<!--- ===================================================================== --->
<cfif fixH EQ "Y">
    <h2>Fix H: Consistency Issues</h2>

    <!--- H1: Completed systems with pending notifications --->
    <cfquery name="completedWithPending" datasource="#dsn#">
        SELECT DISTINCT su.suid
        FROM fusystemusers su
        INNER JOIN funotifications n ON n.suid = su.suid
        WHERE su.sustatus = 'Completed'
          AND n.notstatus = 'Pending'
          AND n.isdeleted = 0
          AND su.isdeleted = 0
        LIMIT 100
    </cfquery>

    <p><strong>H1: Completed systems with pending notifications:</strong> <cfoutput>#completedWithPending.recordCount#</cfoutput> found</p>

    <cfif completedWithPending.recordCount GT 0>
        <cfset suidList = ValueList(completedWithPending.suid) />
        <cfset logAction("H1", "mark pending notifications as Skipped for completed systems", "Count: " & completedWithPending.recordCount, suidList, dryRun EQ "Y") />

        <cfif dryRun EQ "N">
            <cfquery datasource="#dsn#">
                UPDATE funotifications
                SET notstatus = 'Skipped',
                    notenddate = CURDATE()
                WHERE suid IN (<cfqueryparam value="#suidList#" cfsqltype="CF_SQL_INTEGER" list="true">)
                  AND notstatus = 'Pending'
                  AND isdeleted = 0
            </cfquery>
            <p class="mode-applied">Applied: Marked pending notifications as Skipped for completed systems</p>
        <cfelse>
            <p class="mode-dryrun">Would mark pending notifications as Skipped for suids: <cfoutput>#suidList#</cfoutput></p>
        </cfif>
    </cfif>

    <!--- H2: Pending notifications with enddate --->
    <cfquery name="pendingWithEnddate" datasource="#dsn#">
        SELECT notid
        FROM funotifications
        WHERE notstatus = 'Pending'
          AND notenddate IS NOT NULL
          AND isdeleted = 0
        LIMIT 100
    </cfquery>

    <p><strong>H2: Pending notifications with enddate set:</strong> <cfoutput>#pendingWithEnddate.recordCount#</cfoutput> found</p>

    <cfif pendingWithEnddate.recordCount GT 0>
        <cfset notidList = ValueList(pendingWithEnddate.notid) />
        <cfset logAction("H2", "clear enddate on pending notifications", "Count: " & pendingWithEnddate.recordCount, notidList, dryRun EQ "Y") />

        <cfif dryRun EQ "N">
            <cfquery datasource="#dsn#">
                UPDATE funotifications
                SET notenddate = NULL
                WHERE notid IN (<cfqueryparam value="#notidList#" cfsqltype="CF_SQL_INTEGER" list="true">)
            </cfquery>
            <p class="mode-applied">Applied: Cleared enddate on <cfoutput>#pendingWithEnddate.recordCount#</cfoutput> pending notifications</p>
        <cfelse>
            <p class="mode-dryrun">Would clear enddate on notifications: <cfoutput>#notidList#</cfoutput></p>
        </cfif>
    </cfif>
</cfif>

<!--- ===================================================================== --->
<!--- Repair Log Summary --->
<!--- ===================================================================== --->
<cfset endTime = GetTickCount() />
<cfset executionTime = endTime - startTime />

<h2>Repair Log</h2>
<p>Execution time: <cfoutput>#executionTime#</cfoutput> ms | Actions logged: <cfoutput>#ArrayLen(repairLog)#</cfoutput></p>

<cfif ArrayLen(repairLog) GT 0>
    <table>
        <thead>
            <tr>
                <th>Timestamp</th>
                <th>Category</th>
                <th>Action</th>
                <th>Details</th>
                <th>Mode</th>
            </tr>
        </thead>
        <tbody>
            <cfoutput>
            <cfloop array="#repairLog#" index="entry">
                <tr>
                    <td>#entry.timestamp#</td>
                    <td>#entry.category#</td>
                    <td>#entry.action#</td>
                    <td>#entry.details#</td>
                    <td class="#entry.mode EQ 'DRY-RUN' ? 'mode-dryrun' : 'mode-applied'#">#entry.mode#</td>
                </tr>
            </cfloop>
            </cfoutput>
        </tbody>
    </table>
<cfelse>
    <p>No actions taken. Select fixes to run above.</p>
</cfif>

<h2>JSON Log (for programmatic use)</h2>
<pre><cfoutput>#SerializeJSON(repairLog)#</cfoutput></pre>

<hr>
<p>
    <a href="run_audit.cfm">Run Audit</a> |
    <a href="repair_relationship_system.cfm">Reset Form</a> |
    <a href="/admin/relationship_system_health.cfm">Admin Dashboard</a>
</p>

</body>
</html>
