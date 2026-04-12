<cfcomponent displayname="RelationshipService" hint="Centralized service for TAO Relationship System - handles notification scheduling, completion, and system lifecycle">

    <!---
    ==========================================================================
    TAO Relationship Service
    ==========================================================================
    PURPOSE: Consolidate all relationship system logic into one place to:
    - Prevent duplicate notification scheduling
    - Ensure consistent completion workflows
    - Properly handle maintenance auto-start
    - Provide structured logging for debugging

    USAGE:
    <cfset relationshipService = createObject("component", "services.RelationshipService") />
    <cfset result = relationshipService.completeNotification(notid=123, status="Completed", userid=1) />

    RULES ENFORCED:
    1. Only ONE notification per suid can have notstartdate set at a time
    2. Recurring actions create new notifications after completion
    3. Non-recurring actions schedule the next pending notification
    4. When all actions complete, system status changes to Completed
    5. Follow-Up completion triggers Maintenance auto-start (if none exists)
    ==========================================================================
    --->

    <!--- Enable structured logging --->
    <cfset variables.enableLogging = true />
    <cfset variables.logFile = "relationship_system" />

    <!---
    ==========================================================================
    completeNotification
    ==========================================================================
    Main entry point for completing a notification. Handles:
    - Status update
    - Uniqueness flag updates
    - Recurring notification creation
    - Next notification scheduling
    - System completion
    - Maintenance auto-start
    --->
    <cffunction name="completeNotification" access="public" returntype="struct" output="false"
        hint="Complete or skip a notification and handle all downstream effects">

        <cfargument name="notid" type="numeric" required="true" hint="Notification ID to complete" />
        <cfargument name="status" type="string" required="true" hint="New status: Completed or Skipped" />
        <cfargument name="userid" type="numeric" required="true" hint="User ID performing the action" />
        <cfargument name="currentDate" type="date" required="false" default="#Now()#" hint="Date to use for calculations (defaults to now)" />

        <cfset var result = {
            "success": false,
            "message": "",
            "data": {
                "notid": arguments.notid,
                "status": arguments.status,
                "newNotificationId": 0,
                "systemCompleted": false,
                "maintenanceStarted": false,
                "maintenanceSuid": 0
            }
        } />

        <cfset var notification = {} />
        <cfset var nextNotification = {} />

        <!--- Validate status --->
        <cfif NOT ListFindNoCase("Completed,Skipped", arguments.status)>
            <cfset result.message = "Invalid status. Must be Completed or Skipped." />
            <cfset logAction("completeNotification", "ERROR", "Invalid status: " & arguments.status, arguments) />
            <cfreturn result />
        </cfif>

        <cftry>
            <cftransaction>
                <!--- Step 1: Get notification details --->
                <cfset notification = getNotificationDetails(arguments.notid) />

                <cfif notification.recordCount EQ 0>
                    <cfset result.message = "Notification not found: " & arguments.notid />
                    <cfset logAction("completeNotification", "ERROR", "Notification not found", arguments) />
                    <cfreturn result />
                </cfif>

                <cfset var suid = notification.suid />
                <cfset var contactid = notification.contactid />
                <cfset var actionid = notification.actionid />
                <cfset var actionDaysRecurring = notification.actionDaysRecurring />
                <cfset var isUnique = notification.isUnique />
                <cfset var uniquename = notification.uniquename />
                <cfset var systemscope = notification.systemscope />
                <cfset var systemtype = notification.systemtype />
                <cfset var contactname = notification.contactname />
                <cfset var formattedDate = DateFormat(arguments.currentDate, "yyyy-mm-dd") />

                <!--- Step 2: Update notification status --->
                <cfquery name="updateNotification">
                    UPDATE funotifications
                    SET notstatus = <cfqueryparam value="#arguments.status#" cfsqltype="CF_SQL_VARCHAR">,
                        notenddate = <cfqueryparam value="#formattedDate#" cfsqltype="CF_SQL_DATE">
                    WHERE notid = <cfqueryparam value="#arguments.notid#" cfsqltype="CF_SQL_INTEGER">
                </cfquery>
<cfif structKeyExists(request,"perfSvcQueryCount")><cfset request.perfSvcQueryCount++></cfif>

                <cfset logAction("completeNotification", "UPDATE", "Marked notification " & arguments.notid & " as " & arguments.status, {
                    "notid": arguments.notid,
                    "status": arguments.status,
                    "suid": suid
                }) />

                <!--- Step 3: If unique action and completed, update contact --->
                <cfif arguments.status EQ "Completed" AND isUnique EQ 1 AND Len(Trim(uniquename))>
                    <cfquery name="updateContactUnique">
                        UPDATE contactdetails
                        SET #uniquename# = 'Y'
                        WHERE contactid = <cfqueryparam value="#contactid#" cfsqltype="CF_SQL_INTEGER">
                    </cfquery>
<cfif structKeyExists(request,"perfSvcQueryCount")><cfset request.perfSvcQueryCount++></cfif>

                    <cfset logAction("completeNotification", "UPDATE", "Set uniqueness flag " & uniquename & " for contact " & contactid, {
                        "contactid": contactid,
                        "uniquename": uniquename
                    }) />
                </cfif>

                <!--- Step 4: Handle recurring action --->
                <cfif Val(actionDaysRecurring) GT 0>
                    <cfset var newStartDate = DateAdd("d", actionDaysRecurring, arguments.currentDate) />
                    <cfset var newStartDateFormatted = DateFormat(newStartDate, "yyyy-mm-dd") />

                    <cfquery name="insertRecurring" result="insertResult">
                        INSERT INTO funotifications (actionid, userid, suid, notstartdate, notstatus)
                        VALUES (
                            <cfqueryparam value="#actionid#" cfsqltype="CF_SQL_INTEGER">,
                            <cfqueryparam value="#arguments.userid#" cfsqltype="CF_SQL_INTEGER">,
                            <cfqueryparam value="#suid#" cfsqltype="CF_SQL_INTEGER">,
                            <cfqueryparam value="#newStartDateFormatted#" cfsqltype="CF_SQL_DATE">,
                            <cfqueryparam value="Pending" cfsqltype="CF_SQL_VARCHAR">
                        )
                    </cfquery>
<cfif structKeyExists(request,"perfSvcQueryCount")><cfset request.perfSvcQueryCount++></cfif>

                    <cfset result.data.newNotificationId = insertResult.generatedKey />
                    <cfset logAction("completeNotification", "INSERT", "Created recurring notification", {
                        "newNotid": insertResult.generatedKey,
                        "suid": suid,
                        "actionid": actionid,
                        "notstartdate": newStartDateFormatted
                    }) />
                <cfelse>
                    <!--- Step 5: Schedule next pending notification --->
                    <cfset nextNotification = getNextPendingNotification(suid) />

                    <cfif nextNotification.recordCount GT 0>
                        <!--- Calculate new start date --->
                        <cfset var nextActionDaysNo = nextNotification.actionDaysNo />
                        <cfset var newStartDate = DateAdd("d", Val(nextActionDaysNo), arguments.currentDate) />
                        <cfset var newStartDateFormatted = DateFormat(newStartDate, "yyyy-mm-dd") />

                        <cfquery name="scheduleNext">
                            UPDATE funotifications
                            SET notstartdate = <cfqueryparam value="#newStartDateFormatted#" cfsqltype="CF_SQL_DATE">,
                                notstatus = 'Pending'
                            WHERE notid = <cfqueryparam value="#nextNotification.notid#" cfsqltype="CF_SQL_INTEGER">
                        </cfquery>
<cfif structKeyExists(request,"perfSvcQueryCount")><cfset request.perfSvcQueryCount++></cfif>

                        <cfset logAction("completeNotification", "UPDATE", "Scheduled next notification", {
                            "nextNotid": nextNotification.notid,
                            "suid": suid,
                            "notstartdate": newStartDateFormatted
                        }) />
                    <cfelse>
                        <!--- Step 6: No more notifications - complete the system --->
                        <cfquery name="completeSystem">
                            UPDATE fusystemusers
                            SET sustatus = 'Completed',
                                suenddate = <cfqueryparam value="#formattedDate#" cfsqltype="CF_SQL_DATE">
                            WHERE suid = <cfqueryparam value="#suid#" cfsqltype="CF_SQL_INTEGER">
                        </cfquery>
<cfif structKeyExists(request,"perfSvcQueryCount")><cfset request.perfSvcQueryCount++></cfif>

                        <cfset result.data.systemCompleted = true />
                        <cfset logAction("completeNotification", "UPDATE", "System completed", {
                            "suid": suid
                        }) />

                        <!--- Step 7: Check for maintenance auto-start --->
                        <cfif systemtype EQ "Follow Up">
                            <cfset var maintenanceResult = startMaintenanceIfNeeded(
                                contactid = contactid,
                                userid = arguments.userid,
                                systemscope = systemscope,
                                contactname = contactname,
                                currentDate = arguments.currentDate
                            ) />

                            <cfif maintenanceResult.started>
                                <cfset result.data.maintenanceStarted = true />
                                <cfset result.data.maintenanceSuid = maintenanceResult.suid />
                            </cfif>
                        </cfif>
                    </cfif>
                </cfif>

            </cftransaction>

            <cfset result.success = true />
            <cfset result.message = "Notification " & arguments.notid & " marked as " & arguments.status />

            <cfcatch type="any">
                <cfset result.success = false />
                <cfset result.message = "Error: " & cfcatch.message />
                <cfset logAction("completeNotification", "ERROR", cfcatch.message & " - " & cfcatch.detail, arguments) />
            </cfcatch>
        </cftry>

        <cfreturn result />
    </cffunction>

    <!---
    ==========================================================================
    startSystemForContact
    ==========================================================================
    Starts a relationship system for a contact. Creates fusystemusers record
    and schedules the first notification.
    --->
    <cffunction name="startSystemForContact" access="public" returntype="struct" output="false"
        hint="Start a relationship system for a contact">

        <cfargument name="systemid" type="numeric" required="true" />
        <cfargument name="contactid" type="numeric" required="true" />
        <cfargument name="userid" type="numeric" required="true" />
        <cfargument name="startDate" type="date" required="false" default="#Now()#" />
        <cfargument name="notes" type="string" required="false" default="" />

        <cfset var result = {
            "success": false,
            "message": "",
            "data": {
                "suid": 0,
                "notificationsCreated": 0
            }
        } />

        <cftry>
            <cftransaction>
                <!--- Check if already enrolled — inside transaction with FOR UPDATE to prevent races --->
                <cfquery name="checkExisting">
                    SELECT suid
                    FROM fusystemusers_tbl
                    WHERE contactid = <cfqueryparam value="#arguments.contactid#" cfsqltype="CF_SQL_INTEGER">
                      AND systemid = <cfqueryparam value="#arguments.systemid#" cfsqltype="CF_SQL_INTEGER">
                      AND userid = <cfqueryparam value="#arguments.userid#" cfsqltype="CF_SQL_INTEGER">
                      AND sustatus = 'Active'
                      AND isdeleted = 0
                    FOR UPDATE
                </cfquery>
<cfif structKeyExists(request,"perfSvcQueryCount")><cfset request.perfSvcQueryCount++></cfif>

                <cfif checkExisting.recordCount GT 0>
                    <cfset result.message = "Contact already enrolled in this system" />
                    <cfset result.data.suid = checkExisting.suid />
                    <cfreturn result />
                </cfif>

                <!--- Create system enrollment --->
                <cfset var formattedDate = DateFormat(arguments.startDate, "yyyy-mm-dd") />

                <cfquery name="insertSystem" result="insertResult">
                    INSERT INTO fusystemusers (systemid, contactid, userid, sustartdate, sustatus, sunotes)
                    VALUES (
                        <cfqueryparam value="#arguments.systemid#" cfsqltype="CF_SQL_INTEGER">,
                        <cfqueryparam value="#arguments.contactid#" cfsqltype="CF_SQL_INTEGER">,
                        <cfqueryparam value="#arguments.userid#" cfsqltype="CF_SQL_INTEGER">,
                        <cfqueryparam value="#formattedDate#" cfsqltype="CF_SQL_DATE">,
                        'Active',
                        <cfqueryparam value="#arguments.notes#" cfsqltype="CF_SQL_VARCHAR" null="#NOT Len(Trim(arguments.notes))#">
                    )
                </cfquery>
<cfif structKeyExists(request,"perfSvcQueryCount")><cfset request.perfSvcQueryCount++></cfif>

                <cfset var newSuid = insertResult.generatedKey />
                <cfset result.data.suid = newSuid />

                <cfset logAction("startSystemForContact", "INSERT", "Created system enrollment", {
                    "suid": newSuid,
                    "systemid": arguments.systemid,
                    "contactid": arguments.contactid,
                    "userid": arguments.userid
                }) />

                <!--- Get actions for this system --->
                <cfquery name="getActions">
                    SELECT
                        a.actionid,
                        COALESCE(au.actiondaysno, a.actiondaysno) AS actiondaysno,
                        a.isunique,
                        a.uniquename
                    FROM fuactions a
                    LEFT JOIN actionusers au ON au.actionid = a.actionid AND au.userid = <cfqueryparam value="#arguments.userid#" cfsqltype="CF_SQL_INTEGER">
                    WHERE a.systemid = <cfqueryparam value="#arguments.systemid#" cfsqltype="CF_SQL_INTEGER">
                      AND (au.isdeleted = 0 OR au.isdeleted IS NULL)
                    ORDER BY a.actionno
                </cfquery>
<cfif structKeyExists(request,"perfSvcQueryCount")><cfset request.perfSvcQueryCount++></cfif>

                <cfset var notificationsCreated = 0 />
                <cfset var firstActionScheduled = false />

                <cfloop query="getActions">
                    <!--- Check uniqueness --->
                    <cfset var shouldAdd = true />

                    <cfif getActions.isunique EQ 1 AND Len(Trim(getActions.uniquename))>
                        <cfquery name="checkUnique">
                            SELECT contactid
                            FROM contactdetails
                            WHERE contactid = <cfqueryparam value="#arguments.contactid#" cfsqltype="CF_SQL_INTEGER">
                              AND #getActions.uniquename# = 'Y'
                        </cfquery>
<cfif structKeyExists(request,"perfSvcQueryCount")><cfset request.perfSvcQueryCount++></cfif>
                        <cfif checkUnique.recordCount GT 0>
                            <cfset shouldAdd = false />
                        </cfif>
                    </cfif>

                    <cfif shouldAdd>
                        <!--- Calculate start date - only first action gets a date --->
                        <cfset var notStartDate = "" />
                        <cfif NOT firstActionScheduled>
                            <cfset notStartDate = DateFormat(DateAdd("d", Val(getActions.actiondaysno), arguments.startDate), "yyyy-mm-dd") />
                            <cfset firstActionScheduled = true />
                        </cfif>

                        <cfquery name="insertNotification">
                            INSERT INTO funotifications (actionid, userid, suid, notstartdate, notstatus)
                            VALUES (
                                <cfqueryparam value="#getActions.actionid#" cfsqltype="CF_SQL_INTEGER">,
                                <cfqueryparam value="#arguments.userid#" cfsqltype="CF_SQL_INTEGER">,
                                <cfqueryparam value="#newSuid#" cfsqltype="CF_SQL_INTEGER">,
                                <cfif Len(notStartDate)>
                                    <cfqueryparam value="#notStartDate#" cfsqltype="CF_SQL_DATE">
                                <cfelse>
                                    NULL
                                </cfif>,
                                'Pending'
                            )
                        </cfquery>
<cfif structKeyExists(request,"perfSvcQueryCount")><cfset request.perfSvcQueryCount++></cfif>

                        <cfset notificationsCreated = notificationsCreated + 1 />
                    </cfif>
                </cfloop>

                <cfset result.data.notificationsCreated = notificationsCreated />
            </cftransaction>

            <cfset result.success = true />
            <cfset result.message = "System started with " & notificationsCreated & " notifications" />

            <cfset logAction("startSystemForContact", "COMPLETE", result.message, result.data) />

            <cfcatch type="any">
                <cfset result.success = false />
                <cfset result.message = "Error: " & cfcatch.message />
                <cfset logAction("startSystemForContact", "ERROR", cfcatch.message, arguments) />
            </cfcatch>
        </cftry>

        <cfreturn result />
    </cffunction>

    <!---
    ==========================================================================
    startMaintenanceIfNeeded
    ==========================================================================
    Checks if a maintenance system exists for contact, creates one if not.
    Called after Follow-Up system completion.
    --->
    <cffunction name="startMaintenanceIfNeeded" access="public" returntype="struct" output="false"
        hint="Start maintenance system if one doesn't exist for contact">

        <cfargument name="contactid" type="numeric" required="true" />
        <cfargument name="userid" type="numeric" required="true" />
        <cfargument name="systemscope" type="string" required="true" />
        <cfargument name="contactname" type="string" required="false" default="" />
        <cfargument name="currentDate" type="date" required="false" default="#Now()#" />

        <cfset var result = {
            "started": false,
            "suid": 0,
            "message": ""
        } />

        <cftry>
            <!--- Check for existing ACTIVE maintenance system --->
            <cfquery name="checkMaintenance">
                SELECT su.suid
                FROM fusystemusers su
                INNER JOIN fusystems s ON s.systemid = su.systemid
                WHERE su.contactid = <cfqueryparam value="#arguments.contactid#" cfsqltype="CF_SQL_INTEGER">
                  AND su.userid = <cfqueryparam value="#arguments.userid#" cfsqltype="CF_SQL_INTEGER">
                  AND s.systemtype = 'Maintenance List'
                  AND su.sustatus = 'Active'
                  AND su.isdeleted = 0
            </cfquery>
<cfif structKeyExists(request,"perfSvcQueryCount")><cfset request.perfSvcQueryCount++></cfif>

            <cfif checkMaintenance.recordCount GT 0>
                <cfset result.message = "Maintenance system already exists" />
                <cfset result.suid = checkMaintenance.suid />
                <cfreturn result />
            </cfif>

            <!--- Find the matching maintenance system --->
            <cfquery name="findMaintenanceSystem">
                SELECT systemid
                FROM fusystems
                WHERE systemtype = 'Maintenance List'
                  AND systemscope = <cfqueryparam value="#arguments.systemscope#" cfsqltype="CF_SQL_VARCHAR">
                LIMIT 1
            </cfquery>
<cfif structKeyExists(request,"perfSvcQueryCount")><cfset request.perfSvcQueryCount++></cfif>

            <cfif findMaintenanceSystem.recordCount EQ 0>
                <cfset result.message = "No maintenance system found for scope: " & arguments.systemscope />
                <cfreturn result />
            </cfif>

            <!--- Start the maintenance system --->
            <cfset var startResult = startSystemForContact(
                systemid = findMaintenanceSystem.systemid,
                contactid = arguments.contactid,
                userid = arguments.userid,
                startDate = arguments.currentDate,
                notes = "Auto-started after Follow-Up completion"
            ) />

            <cfif startResult.success>
                <cfset result.started = true />
                <cfset result.suid = startResult.data.suid />
                <cfset result.message = "Maintenance system started" />

                <!--- Create user notification about the new maintenance system --->
                <cfquery name="insertUserNotification">
                    INSERT INTO notifications (subtitle, userid, notifUrl, notifTitle, notifType, contactid, `read`)
                    VALUES (
                        <cfqueryparam value="Maintenance system created for #arguments.contactname#" cfsqltype="CF_SQL_VARCHAR">,
                        <cfqueryparam value="#arguments.userid#" cfsqltype="CF_SQL_INTEGER">,
                        <cfqueryparam value="/app/contact/?contactid=#arguments.contactid#&t4=1" cfsqltype="CF_SQL_VARCHAR">,
                        'Maintenance System Created!',
                        'System Added',
                        <cfqueryparam value="#arguments.contactid#" cfsqltype="CF_SQL_INTEGER">,
                        0
                    )
                </cfquery>
<cfif structKeyExists(request,"perfSvcQueryCount")><cfset request.perfSvcQueryCount++></cfif>

                <cfset logAction("startMaintenanceIfNeeded", "INSERT", "Auto-started maintenance system", {
                    "contactid": arguments.contactid,
                    "suid": result.suid
                }) />
            <cfelse>
                <cfset result.message = startResult.message />
            </cfif>

            <cfcatch type="any">
                <cfset result.message = "Error: " & cfcatch.message />
                <cfset logAction("startMaintenanceIfNeeded", "ERROR", cfcatch.message, arguments) />
            </cfcatch>
        </cftry>

        <cfreturn result />
    </cffunction>

    <!---
    ==========================================================================
    Private Helper Functions
    ==========================================================================
    --->

    <cffunction name="getNotificationDetails" access="private" returntype="query" output="false">
        <cfargument name="notid" type="numeric" required="true" />

        <cfquery name="notificationDetails">
            SELECT
                n.notid,
                n.actionid,
                n.suid,
                n.userid,
                n.notstatus,
                n.notstartdate,
                su.contactid,
                su.systemid,
                s.systemtype,
                s.systemscope,
                COALESCE(au.actiondaysrecurring, a.actiondaysrecurring, 0) AS actionDaysRecurring,
                a.isunique,
                a.uniquename,
                cd.recordname AS contactname
            FROM funotifications n
            INNER JOIN fusystemusers su ON su.suid = n.suid
            INNER JOIN fusystems s ON s.systemid = su.systemid
            INNER JOIN fuactions a ON a.actionid = n.actionid
            LEFT JOIN actionusers au ON au.actionid = n.actionid AND au.userid = n.userid
            LEFT JOIN contactdetails cd ON cd.contactid = su.contactid AND cd.userid = su.userid
            WHERE n.notid = <cfqueryparam value="#arguments.notid#" cfsqltype="CF_SQL_INTEGER">
        </cfquery>
<cfif structKeyExists(request,"perfSvcQueryCount")><cfset request.perfSvcQueryCount++></cfif>

        <cfreturn notificationDetails />
    </cffunction>

    <cffunction name="getNextPendingNotification" access="private" returntype="query" output="false"
        hint="Get the next pending notification for a suid that doesn't have a start date yet">
        <cfargument name="suid" type="numeric" required="true" />

        <cfquery name="nextPending">
            SELECT
                n.notid,
                n.actionid,
                COALESCE(au.actiondaysno, a.actiondaysno, 0) AS actionDaysNo
            FROM funotifications n
            INNER JOIN fusystemusers su ON su.suid = n.suid
            INNER JOIN fuactions a ON a.actionid = n.actionid
            LEFT JOIN actionusers au ON au.actionid = n.actionid AND au.userid = su.userid
            WHERE n.suid = <cfqueryparam value="#arguments.suid#" cfsqltype="CF_SQL_INTEGER">
              AND n.notstatus = 'Pending'
              AND n.notstartdate IS NULL
              AND n.isdeleted = 0
            ORDER BY a.actionno, n.notid
            LIMIT 1
        </cfquery>
<cfif structKeyExists(request,"perfSvcQueryCount")><cfset request.perfSvcQueryCount++></cfif>

        <cfreturn nextPending />
    </cffunction>

    <cffunction name="logAction" access="private" returntype="void" output="false"
        hint="Log relationship system actions for debugging">
        <cfargument name="method" type="string" required="true" />
        <cfargument name="action" type="string" required="true" />
        <cfargument name="message" type="string" required="true" />
        <cfargument name="data" type="any" required="false" default="" />

        <cfif variables.enableLogging>
            <cfset var logMessage = "[" & arguments.method & "] " & arguments.action & ": " & arguments.message />
            <cfif IsStruct(arguments.data) OR IsArray(arguments.data)>
                <cfset logMessage = logMessage & " | Data: " & SerializeJSON(arguments.data) />
            <cfelseif Len(Trim(arguments.data))>
                <cfset logMessage = logMessage & " | Data: " & arguments.data />
            </cfif>

            <cflog file="#variables.logFile#" type="information" text="#logMessage#" />
        </cfif>
    </cffunction>

    <!---
    ==========================================================================
    Utility Functions for Admin/Audit
    ==========================================================================
    --->

    <cffunction name="getSystemHealth" access="public" returntype="struct" output="false"
        hint="Get health metrics for the relationship system">

        <cfset var health = {
            "activeSystems": 0,
            "pendingNotifications": 0,
            "overdueNotifications": 0,
            "stuckSystems": 0,
            "duplicateEnrollments": 0
        } />

        <cfquery name="qActiveSystems">
            SELECT COUNT(*) AS cnt FROM fusystemusers WHERE sustatus = 'Active' AND isdeleted = 0
        </cfquery>
<cfif structKeyExists(request,"perfSvcQueryCount")><cfset request.perfSvcQueryCount++></cfif>
        <cfset health.activeSystems = qActiveSystems.cnt />

        <cfquery name="qPending">
            SELECT COUNT(*) AS cnt FROM funotifications
            WHERE notstatus = 'Pending' AND isdeleted = 0 AND notstartdate IS NOT NULL
        </cfquery>
<cfif structKeyExists(request,"perfSvcQueryCount")><cfset request.perfSvcQueryCount++></cfif>
        <cfset health.pendingNotifications = qPending.cnt />

        <cfquery name="qOverdue">
            SELECT COUNT(*) AS cnt FROM funotifications
            WHERE notstatus = 'Pending' AND isdeleted = 0
              AND notstartdate IS NOT NULL
              AND notstartdate < CURDATE()
        </cfquery>
<cfif structKeyExists(request,"perfSvcQueryCount")><cfset request.perfSvcQueryCount++></cfif>
        <cfset health.overdueNotifications = qOverdue.cnt />

        <cfquery name="qStuck">
            SELECT COUNT(*) AS cnt
            FROM fusystemusers su
            LEFT JOIN funotifications n ON n.suid = su.suid AND n.notstatus = 'Pending' AND n.isdeleted = 0
            WHERE su.sustatus = 'Active' AND su.isdeleted = 0 AND n.notid IS NULL
        </cfquery>
<cfif structKeyExists(request,"perfSvcQueryCount")><cfset request.perfSvcQueryCount++></cfif>
        <cfset health.stuckSystems = qStuck.cnt />

        <cfquery name="qDuplicates">
            SELECT COUNT(*) AS cnt
            FROM (
                SELECT userid, contactid, systemid
                FROM fusystemusers
                WHERE sustatus = 'Active' AND isdeleted = 0
                GROUP BY userid, contactid, systemid
                HAVING COUNT(*) > 1
            ) t
        </cfquery>
<cfif structKeyExists(request,"perfSvcQueryCount")><cfset request.perfSvcQueryCount++></cfif>
        <cfset health.duplicateEnrollments = qDuplicates.cnt />

        <cfreturn health />
    </cffunction>

</cfcomponent>
