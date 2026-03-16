<cftransaction>

    <!--- Debug variable - set to "Y" to show debug information --->
    <cfparam name="dbug" default="N" />
    <cfset dbug="Y" />


    <cfif dbug eq "Y">
        <cfoutput>
            <div style="background-color: ##f0f0f0; padding: 10px; margin: 5px; border: 1px solid ##ccc;">
                <strong>DEBUG: Starting events_completed.cfm</strong><br>
                Current Date/Time: #now()#<br>
                Process Start Time: #timeFormat(now(), "HH:mm:ss")#
            </div>
        </cfoutput>
    </cfif>

    <CFINCLUDE template="remote_load.cfm" />

    <cfset todayDate = dateFormat(now(), 'yyyy-MM-dd') />

    <cfquery datasource="#dsn#" result="result" name="future">
        SELECT * FROM funotifications
        WHERE notstartdate > <cfqueryparam cfsqltype="cf_sql_date" value="#todayDate#" />
        AND notstatus <> <cfqueryparam cfsqltype="cf_sql_varchar" value="Future" />
    </cfquery>

    <cfif dbug eq "Y">
        <cfoutput>
            <div style="background-color: ##e6f3ff; padding: 10px; margin: 5px; border: 1px solid ##ccc;">
                <strong>DEBUG: Future notifications query</strong><br>
                Records found: #future.recordCount#
            </div>
        </cfoutput>
    </cfif>

    <cfquery datasource="#dsn#" result="result" name="activefix">
        SELECT * FROM funotifications
        WHERE notstartdate < <cfqueryparam cfsqltype="cf_sql_date" value="#todayDate#" />
        AND notstatus = <cfqueryparam cfsqltype="cf_sql_varchar" value="Future" />
    </cfquery>

        <cfif dbug eq "Y">
            <cfoutput>
                <div style="background-color: ##e6f3ff; padding: 10px; margin: 5px; border: 1px solid ##ccc;">
                    <strong>DEBUG: Active fix query</strong><br>
                    Records found: #activefix.recordCount#
                </div>
            </cfoutput>
        </cfif>

            <cfquery datasource="#dsn#" result="result" name="upactive">
                UPDATE funotifications
                SET notstatus = 'Active'
                WHERE notstartdate < <cfqueryparam cfsqltype="cf_sql_date" value="#todayDate#" />
                AND notstatus = <cfqueryparam cfsqltype="cf_sql_varchar" value="Future" />
            </cfquery>

                    <cfquery datasource="#dsn#" result="result" name="c">
                        SELECT u.userid, u.recordname, t.canceldate
                        FROM taousers u
                        INNER JOIN thrivecart t ON u.customerid = t.id
                        WHERE u.userstatus = 'cancelled'
                        AND t.canceldate < SYSDATE()
                    </cfquery>

                            <!--- WO-4.1: Batch update cancelled users (was per-row UPDATE loop) --->
                            <cfif c.recordcount GT 0>
                                <cfset cancelledUserIds = valueList(c.userid) />
                                <cfquery datasource="#dsn#" result="result" name="s">
                                    UPDATE taousers_tbl SET isdeleted = 1
                                    WHERE userid IN (<cfqueryparam cfsqltype="cf_sql_integer" value="#cancelledUserIds#" list="true" />)
                                </cfquery>
                            </cfif>

            <cfquery datasource="#dsn#" result="result" name="events">
                SELECT e.eventid, e.eventtitle, e.eventstop, u.recordname, u.userid
                FROM events e
                INNER JOIN taousers u ON e.userid = u.userid
                WHERE e.eventstatus = 'Active' AND e.eventstop < CURDATE()
                ORDER BY e.eventstop
            </cfquery>

                <cfif dbug eq "Y">
                    <cfoutput>
                        <div style="background-color: ##fff2e6; padding: 10px; margin: 5px; border: 1px solid ##ccc;">
                            <strong>DEBUG: Events to process</strong><br>
                            Events found: #events.recordCount#<br>
                            <cfif events.recordCount gt 0>
                                Events:
                                <cfloop query="events">
                                    #events.eventid# (#events.eventtitle#)
                                    <cfif events.currentRow lt events.recordCount>, </cfif>
                                </cfloop>
                            </cfif>
                        </div>
                    </cfoutput>
                </cfif>

    <!--- WO-4.1: Pre-load all reference data in batch before event loop --->
    <cfif events.recordcount GT 0>
        <cfset eventIdList = valueList(events.eventid) />
        <cfset userIdList = valueList(events.userid) />

        <!--- Batch-load all follow-up contacts for ALL events (was per-event UNION query) --->
        <cfquery datasource="#dsn#" name="allFollowups">
            SELECT DISTINCT x.eventid, i.contactid, d.recordname, 1 AS new_systemid
            FROM contactitems i
            INNER JOIN tags_user tu ON tu.tagname = i.valuetext
            INNER JOIN eventcontactsxref x ON x.contactid = i.contactid
            INNER JOIN events e ON e.eventid = x.eventid
            INNER JOIN eventtypes_user eu ON eu.eventtypename = e.eventtypename
            INNER JOIN contactdetails d ON d.contactid = i.contactid
            INNER JOIN taousers u ON u.userid = e.userid
            WHERE i.itemstatus = 'Active'
            AND tu.tagtype = 'C'
            AND i.valuecategory = 'tag'
            AND eu.eventtypename NOT IN ('Rehearsal')
            AND x.eventid IN (<cfqueryparam cfsqltype="cf_sql_integer" value="#eventIdList#" list="true" />)
            AND tu.userid = e.userid
            AND eu.userid = e.userid
            UNION
            SELECT DISTINCT x.eventid, i.contactid, d.recordname, 2 AS new_systemid
            FROM contactitems i
            INNER JOIN tags_user tu ON tu.tagname = i.valuetext
            INNER JOIN eventcontactsxref x ON x.contactid = i.contactid
            INNER JOIN events e ON e.eventid = x.eventid
            INNER JOIN eventtypes_user eu ON eu.eventtypename = e.eventtypename
            INNER JOIN contactdetails d ON d.contactid = i.contactid
            INNER JOIN taousers u ON u.userid = e.userid
            WHERE i.itemstatus = 'Active'
            AND tu.tagtype = 'I'
            AND i.valuecategory = 'tag'
            AND eu.eventtypename NOT IN ('Rehearsal','CD Workshop')
            AND x.eventid IN (<cfqueryparam cfsqltype="cf_sql_integer" value="#eventIdList#" list="true" />)
            AND tu.userid = e.userid
            AND eu.userid = e.userid
        </cfquery>

        <!--- Pre-load all active system enrollments for these users (replaces per-contact find_fu query) --->
        <cfquery datasource="#dsn#" name="allEnrollments">
            SELECT su.suid, su.userid, su.contactid, s.systemid
            FROM fusystems s
            INNER JOIN fusystemusers su ON su.systemID = s.systemid
            WHERE su.suStatus = 'Active'
            AND su.userid IN (<cfqueryparam cfsqltype="cf_sql_integer" value="#userIdList#" list="true" />)
        </cfquery>
        <cfset enrollmentSets = structNew() />
        <cfloop query="allEnrollments">
            <cfset eKey = allEnrollments.userid & "|" & allEnrollments.contactid />
            <cfif NOT structKeyExists(enrollmentSets, eKey)>
                <cfset enrollmentSets[eKey] = "" />
            </cfif>
            <cfset enrollmentSets[eKey] = listAppend(enrollmentSets[eKey], allEnrollments.systemid) />
        </cfloop>

        <!--- Pre-load system definitions (replaces per-contact sudetails query) --->
        <cfquery datasource="#dsn#" name="allSystemInfo">
            SELECT systemid, systemName, systemType, systemScope, systemDescript, systemTriggerNote
            FROM fusystems
        </cfquery>
        <cfset systemInfoMap = structNew() />
        <cfloop query="allSystemInfo">
            <cfset systemInfoMap[allSystemInfo.systemid] = allSystemInfo.systemName />
        </cfloop>

        <!--- Pre-load action schedules per system per user (replaces per-contact addDaysNo query) --->
        <cfquery datasource="#dsn#" name="allActionSchedules">
            SELECT
            s.systemID, s.systemName, s.SystemType, s.SystemScope, s.SystemDescript, s.SystemTriggerNote,
            a.actionID, a.actionNo, a.actionDetails, a.actionTitle, a.navToURL,
            au.actionDaysNo, au.actionDaysRecurring,
            a.actionNotes, a.actionInfo, a.IsUnique, a.uniquename,
            au.userid
            FROM fusystems s
            INNER JOIN fuactions a ON s.systemid = a.systemid
            INNER JOIN actionusers au ON au.actionid = a.actionid
            WHERE au.userid IN (<cfqueryparam cfsqltype="cf_sql_integer" value="#userIdList#" list="true" />)
            AND au.actionDaysNo IS NOT NULL
            AND a.actionID IS NOT NULL
            ORDER BY a.actionNo
        </cfquery>
        <!--- Build map: key = systemid|userid, value = first action struct --->
        <cfset actionScheduleMap = structNew() />
        <cfloop query="allActionSchedules">
            <cfset schedKey = allActionSchedules.systemid & "|" & allActionSchedules.userid />
            <cfif NOT structKeyExists(actionScheduleMap, schedKey)>
                <cfset actionScheduleMap[schedKey] = {
                    actionid = allActionSchedules.actionid,
                    actionDaysNo = allActionSchedules.actionDaysNo,
                    isUnique = allActionSchedules.IsUnique,
                    uniquename = allActionSchedules.uniquename
                } />
            </cfif>
        </cfloop>

        <!--- Allowed column names for uniqueness check (whitelist for dynamic column) --->
        <cfset allowedUniqueColumns = "isEmailed,isInvited,isMailed,isFollowedUp,isScheduled,isConnected,isMet,isThankYouSent" />
    </cfif>

                    <cfloop query="events">

                        <cfif dbug eq "Y">
                            <cfoutput>
                                <div style="background-color: ##f0fff0; padding: 10px; margin: 5px; border: 1px solid ##90EE90;">
                                    <strong>DEBUG: Processing Event #events.currentRow# of #events.recordCount#</strong><br>
                                    Event ID: #events.eventid#<br>
                                    Event Title: #events.eventtitle#<br>
                                    Event Stop: #events.eventstop#<br>
                                    User: #events.recordname# (ID: #events.userid#)
                                </div>
                            </cfoutput>
                        </cfif>

                        <cfset new_eventid = events.eventid />
                        <cfset new_userid = events.userid />
                        <cfset new_eventtitle = events.eventtitle />
                        <cfset new_eventstop = events.eventstop />

                                        <!--- WO-4.1: Filter pre-loaded followups for this event (was per-event UNION query) --->
                                        <cfquery dbtype="query" name="fu">
                                            SELECT contactid, recordname, new_systemid
                                            FROM allFollowups
                                            WHERE eventid = #val(new_eventid)#
                                        </cfquery>

                                        <cfif dbug eq "Y">
                                            <cfoutput>
                                                <div style="background-color: ##ffe6f2; padding: 10px; margin: 5px; border: 1px solid ##ffb3d9;">
                                                    <strong>DEBUG: Follow-up contacts found</strong><br>
                                                    Contacts for Event #new_eventid#: #fu.recordCount# contacts
                                                </div>
                                            </cfoutput>
                                        </cfif>

                                        <cfloop query="fu">
                                            <cfset new_contactid = fu.contactid />
                                            <cfset new_contactname = fu.recordname />
                                            <cfset new_systemid = fu.new_systemid />

                                            <cfif dbug eq "Y">
                                                <cfoutput>
                                                    <div style="background-color: ##f0f8ff; padding: 5px; margin: 5px; border: 1px solid ##87ceeb;">
                                                        <strong>DEBUG: Processing Contact #fu.currentRow#</strong><br>
                                                        Contact: #new_contactname# (ID: #new_contactid#)<br>
                                                        System ID: #new_systemid#
                                                    </div>
                                                </cfoutput>
                                            </cfif>

                                            <!--- WO-4.1: Enrollment check via pre-loaded map (was per-contact SELECT) --->
                                            <cfset enrollKey = new_userid & "|" & new_contactid />
                                            <cfset enrolledSystems = "" />
                                            <cfif structKeyExists(enrollmentSets, enrollKey)>
                                                <cfset enrolledSystems = enrollmentSets[enrollKey] />
                                            </cfif>
                                            <cfset alreadyEnrolled = false />
                                            <cfif listFind(enrolledSystems, new_systemid)>
                                                <cfset alreadyEnrolled = true />
                                            <cfelseif (new_systemid EQ 1 OR new_systemid EQ 2) AND (listFind(enrolledSystems, 3) OR listFind(enrolledSystems, 4))>
                                                <cfset alreadyEnrolled = true />
                                            </cfif>

<cfif NOT alreadyEnrolled>

                                                <cfif dbug eq "Y">
                                                    <cfoutput>
                                                        <div style="background-color: ##ffffe0; padding: 5px; margin: 5px; border: 1px solid ##ffd700;">
                                                            <strong>DEBUG: Creating new follow-up system</strong><br>
                                                            No existing system found for contact #new_contactname# (ID: #new_contactid#)<br>
                                                            System ID: #new_systemid#
                                                        </div>
                                                    </cfoutput>
                                                </cfif>

                                                <cfset suStartDate = DateFormat(new_eventstop, 'yyyy-mm-dd') />
                                                <cfset currentStartDate = DateFormat(new_eventstop, 'yyyy-mm-dd') />

                                                <cfquery datasource="#dsn#" name="addSystem" result="result">
                                                    INSERT INTO fuSystemUsers (systemID, contactID, userID, suStartDate)
                                                    VALUES (
                                                        <cfqueryparam cfsqltype="cf_sql_integer" value="#new_systemid#" />,
                                                        <cfqueryparam cfsqltype="cf_sql_integer" value="#new_contactid#" />,
                                                        <cfqueryparam cfsqltype="cf_sql_integer" value="#new_userid#" />,
                                                        <cfqueryparam cfsqltype="cf_sql_date" value="#suStartDate#" />
                                                    )
                                                </cfquery>

                                                <cfset NewSUID = numberformat(result.generatedkey) />

                                                <!--- Update enrollment map so subsequent contacts in this batch see this enrollment --->
                                                <cfif NOT structKeyExists(enrollmentSets, enrollKey)>
                                                    <cfset enrollmentSets[enrollKey] = "" />
                                                </cfif>
                                                <cfset enrollmentSets[enrollKey] = listAppend(enrollmentSets[enrollKey], new_systemid) />

                                                    <cfquery datasource="#dsn#" result="result" name="CompleteTargetSystems">
                                                        UPDATE fusystemusers SET sustatus = 'Completed'
                                                        WHERE userid = <cfqueryparam cfsqltype="cf_sql_integer" value="#new_userid#" />
                                                        AND systemid IN (<cfqueryparam cfsqltype="cf_sql_integer" value="5,6" list="true" />)
                                                        AND contactid = <cfqueryparam cfsqltype="cf_sql_integer" value="#new_contactid#" />
                                                    </cfquery>

                                                    <cfquery datasource="#dsn#" name="Insert" result="result">
                                                        INSERT INTO `notifications`
                                                        (`subtitle`, `userid`, `notifUrl`, `notifTitle`, `notifType`, `contactid`, `read`)
                                                        VALUES (
                                                            <cfqueryparam cfsqltype="cf_sql_varchar" value="Appointment completed. Follow-Up with #new_contactname#" />,
                                                            <cfqueryparam cfsqltype="cf_sql_integer" value="#new_userid#" />,
                                                            <cfqueryparam cfsqltype="cf_sql_varchar" value="/app/contact/?contactid=#new_contactid#&t4=1" />,
                                                            <cfqueryparam cfsqltype="cf_sql_varchar" value="Follow-Up System Created!" />,
                                                            <cfqueryparam cfsqltype="cf_sql_varchar" value="System Added" />,
                                                            <cfqueryparam cfsqltype="cf_sql_integer" value="#new_contactid#" />,
                                                            <cfqueryparam cfsqltype="cf_sql_integer" value="0" />
                                                        )
                                                    </cfquery>

                                                    <cfset Newnotification = result.generatedkey />

                                                        <!--- WO-4.1: Action schedule from pre-loaded map (was per-contact SELECT with 3-way JOIN) --->
                                                        <cfset schedKey = new_systemid & "|" & new_userid />
                                                        <cfif structKeyExists(actionScheduleMap, schedKey)>
                                                            <cfset actionSched = actionScheduleMap[schedKey] />

<cfset add_action = "Y" />

                                                        <cfset new_actionid = actionSched.actionid />
                                                        <cfset actiondaysno = numberformat(actionSched.actionDaysNo) />
                                                        <cfif actionSched.isunique is "1">

                                                            <!--- Uniqueness check: validate column name before dynamic SQL --->
                                                            <cfif len(trim(actionSched.uniquename)) AND listFindNoCase(allowedUniqueColumns, trim(actionSched.uniquename))>
<cfquery datasource="#dsn#" result="result" name="checkUnique">
                                                                SELECT d.contactid FROM contactdetails d
                                                                WHERE d.#trim(actionSched.uniquename)# = 'Y'
                                                                AND d.contactid = <cfqueryparam cfsqltype="cf_sql_integer" value="#new_contactid#" />
                                                                LIMIT 1
                                                            </cfquery>

<cfif checkUnique.recordcount is "1">
                                                                <cfset add_action = "N" />
                                                            </cfif>
                                                            <cfelse>
                                                                <cflog file="events_completed" text="BLOCKED: invalid uniquename column '#htmlEditFormat(actionSched.uniquename)#' for actionid #new_actionid#" />
                                                            </cfif>

                                                        </cfif>

                                                        <cfif add_action is "Y">

                                                            <cfif actiondaysno is "">
                                                                <cfset actiondaysno = 0 />
                                                            </cfif>

                                                            <cfset notstartdate = dateAdd('d', actionDaysNo, currentstartdate) />

                                                            <cfif notstartdate LTE currentstartdate>

<cfquery datasource="#dsn#" name="addNotification" result="result">
                                                                    INSERT INTO funotifications (actionid, userid, suID, notstartdate)
                                                                    VALUES (
                                                                        <cfqueryparam cfsqltype="cf_sql_integer" value="#new_actionid#" />,
                                                                        <cfqueryparam cfsqltype="cf_sql_integer" value="#new_userid#" />,
                                                                        <cfqueryparam cfsqltype="cf_sql_integer" value="#NewSuid#" />,
                                                                        <cfqueryparam cfsqltype="cf_sql_date" value="#DateFormat(notstartdate,'yyyy-mm-dd')#" />
                                                                    )
                                                                </cfquery>

                                                                <cfelse>

                                                                    <cfquery datasource="#dsn#" name="addNotification" result="result">
                                                                        INSERT INTO funotifications (actionid, userid, suID, notstartdate, notstatus)
                                                                        VALUES (
                                                                            <cfqueryparam cfsqltype="cf_sql_integer" value="#new_actionid#" />,
                                                                            <cfqueryparam cfsqltype="cf_sql_integer" value="#new_userid#" />,
                                                                            <cfqueryparam cfsqltype="cf_sql_integer" value="#NewSuid#" />,
                                                                            <cfqueryparam cfsqltype="cf_sql_date" value="#DateFormat(notstartdate,'yyyy-mm-dd')#" />,
                                                                            <cfqueryparam cfsqltype="cf_sql_varchar" value="Pending" />
                                                                        )
                                                                    </cfquery>

                                                            </cfif>

                                                        </cfif>

                                                        </cfif><!--- end actionScheduleMap check --->

                                                        <cfelse>

</cfif>

                                        </cfloop>

                                        <cfquery datasource="#dsn#" result="result" name="update">
                                            UPDATE events
                                            SET eventstatus = 'Completed'
                                            WHERE eventid = <cfqueryparam value="#new_eventid#" cfsqltype="cf_sql_integer" />
                                        </cfquery>

                                    </cfloop>

<!--- WO-4.4: Moved inside transaction (was outside, risking partial contact updates) --->
<cfquery datasource="#dsn#" result="result" name="uppdate_when">
UPDATE contactdetails cd
INNER JOIN (
  SELECT x.contactid, MIN(e.eventstop) AS oldest_new_contactmeetingdate
  FROM eventcontactsxref x
  INNER JOIN events e ON e.eventid = x.eventid
  WHERE e.eventstatus = 'Completed' AND e.eventstop < CURDATE()
  GROUP BY x.contactid
) sub ON cd.contactid = sub.contactid
SET cd.contactmeetingdate = sub.oldest_new_contactmeetingdate
WHERE cd.contactmeetingdate IS NULL;
</cfquery>

<cfquery datasource="#dsn#" result="result" name="uppdate_where">
UPDATE contactdetails cd
INNER JOIN (
  SELECT x.contactid, e.eventtitle AS oldest_new_contactMeetingLoc, MIN(e.eventstop) AS oldest_new_contactmeetingdate
  FROM eventcontactsxref x
  INNER JOIN events e ON e.eventid = x.eventid
  WHERE e.eventstatus = 'Completed' AND e.eventstop < CURDATE()
  GROUP BY x.contactid
) sub ON cd.contactid = sub.contactid
SET cd.contactMeetingloc = sub.oldest_new_contactMeetingLoc
WHERE cd.contactMeetingloc IS NULL;
</cfquery>

</cftransaction>

<cfif dbug eq "Y">
    <cfoutput>
        <div style="background-color: ##d4edda; padding: 10px; margin: 5px; border: 1px solid ##c3e6cb;">
            <strong>DEBUG: Process completed successfully</strong><br>
            End Time: #timeFormat(now(), "HH:mm:ss")#<br>
            Total events processed: #events.recordCount#<br>
        </div>
    </cfoutput>
</cfif>
