<!---
    ============================================================================
    sched/events_completed.cfm
    ============================================================================
    Scheduled maintenance task. Runs nightly (via CF scheduler) to perform four
    cleanup jobs against the events / notifications / users tables:

        JOB A  -- funotifications: flip notstatus 'Future' -> 'Active' when
                  notstartdate has passed. UI (NotificationStatusService) reads
                  this flag directly, so without this flip due notifications stay
                  hidden.
        JOB B  -- taousers_tbl: soft-delete (isdeleted = 1) users whose
                  thrivecart cancellation date has passed. No real-time
                  equivalent -- ipn-handler.cfm does NOT do this today.
        JOB C  -- events: auto-complete any events where eventstop < today and
                  still 'Active'. For each completed event, enroll each tagged
                  contact into the Follow-Up (systemid 1) or Industry Follow-Up
                  (systemid 2) system, seed the first funotifications action,
                  insert a UI notifications row, and complete any existing
                  Target systems (5, 6) for that contact. This is the ONLY code
                  path that completes events or enrolls follow-ups post-event.
        JOB D  -- contactdetails: backfill contactmeetingdate / contactmeetingloc
                  from the oldest completed event per contact, where those
                  fields are NULL. Pure legacy-data repair.

    Debug mode: pass ?dbug=Y to see inline diagnostic panels for each step.
    Performance: WO-4.1 moved per-event / per-contact queries into pre-loaded
    maps before the event loop. WO-4.4 split the final backfill into its own
    cftransaction. See 21-events-completed-review.md for the full review and
    the real-time migration plan.
    ============================================================================
--->
<cfsetting requesttimeout="600" />

    <cfparam name="dbug" default="N" />


    <cfif dbug eq "Y">
        <cfoutput>
            <div style="background-color: ##f0f0f0; padding: 10px; margin: 5px; border: 1px solid ##ccc;">
                <strong>DEBUG: Starting events_completed.cfm</strong><br>
                Current Date/Time: #now()#<br>
                Process Start Time: #timeFormat(now(), "HH:mm:ss")#
            </div>
        </cfoutput>
    </cfif>

    <!--- remote_load.cfm pulls dsn / rev / suffix from application scope --->
    <CFINCLUDE template="remote_load.cfm" />

    <cfset todayDate = dateFormat(now(), 'yyyy-MM-dd') />

    <!---
        JOB A -- notstatus repair (part 1 of 2)
        Audit select: future-dated notifications whose status is NOT 'Future'.
        NOTE: query result is used only for the debug panel; it drives no
        update. Candidate for removal. Kept for visibility today.
    --->
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

    <!---
        JOB A -- notstatus repair (part 2 of 2)
        Audit select: past-dated notifications still sitting in 'Future'.
        Same note as `future` above -- result is only read for the debug panel.
        The actual state change happens in the UPDATE below.
    --->
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

            <!---
                JOB A -- the actual state change.
                Flip past-due notifications from 'Future' to 'Active' in one
                statement. NotificationStatusService reads notstatus directly,
                so this flip is what makes due reminders visible in the UI.
            --->
            <cfquery datasource="#dsn#" result="result" name="upactive">
                UPDATE funotifications
                SET notstatus = 'Active'
                WHERE notstartdate < <cfqueryparam cfsqltype="cf_sql_date" value="#todayDate#" />
                AND notstatus = <cfqueryparam cfsqltype="cf_sql_varchar" value="Future" />
            </cfquery>

                    <!---
                        JOB B -- cancelled user soft-delete.
                        `taousers` is a VIEW filtered to isdeleted = 0 over
                        `taousers_tbl`; SELECT comes from the view so we only
                        see still-active rows. Candidates: userstatus is
                        'cancelled' and the thrivecart record's canceldate has
                        already passed. SYSDATE() resolves on the DB server.
                    --->
                    <cfquery datasource="#dsn#" result="result" name="c">
                        SELECT u.userid, u.recordname, t.canceldate
                        FROM taousers u
                        INNER JOIN thrivecart t ON u.customerid = t.id
                        WHERE u.userstatus = 'cancelled'
                        AND t.canceldate < SYSDATE()
                    </cfquery>

                            <!---
                                WO-4.1: Batch update cancelled users
                                (was a per-row UPDATE loop). Writes go to the
                                base table `taousers_tbl`; the view `taousers`
                                will then filter these users out on subsequent
                                reads.
                            --->
                            <cfif c.recordcount GT 0>
                                <cfset cancelledUserIds = valueList(c.userid) />
                                <cfquery datasource="#dsn#" result="result" name="s">
                                    UPDATE taousers_tbl SET isdeleted = 1
                                    WHERE userid IN (<cfqueryparam cfsqltype="cf_sql_integer" value="#cancelledUserIds#" list="true" />)
                                </cfquery>
                            </cfif>

            <!---
                JOB C -- driver query: past-due Active events.
                Anything whose stop date is before today and is still 'Active'
                needs to be completed and its tagged contacts enrolled in
                follow-up. Joined through the `taousers` view so we skip events
                owned by already-soft-deleted users.
            --->
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

    <!---
        WO-4.1: Pre-load all reference data in batch before the event loop.
        Prior version issued multiple queries per-event and per-contact. Now
        we fetch everything once into query-of-query-friendly resultsets and
        in-memory struct maps, then filter inside the loop.
    --->
    <cfif events.recordcount GT 0>
        <cfset eventIdList = valueList(events.eventid) />
        <cfset userIdList = valueList(events.userid) />

        <!---
            allFollowups -- every contact that should receive a follow-up
            system enrollment across every event in this batch. Two UNION
            arms:
              new_systemid = 1  (Follow-Up / 'C'-type tags, excludes Rehearsal)
              new_systemid = 2  (Industry Follow-Up / 'I'-type tags, excludes
                                 Rehearsal and CD Workshop)
            Filtered later by eventid via a query-of-queries.
        --->

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

        <!---
            allEnrollments -- every active fusystemusers row for this batch's
            users. Collapsed into `enrollmentSets` keyed by userid|contactid,
            value is a CSV list of systemids. Replaces the per-contact
            `find_fu` SELECT in the old version.
        --->
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

        <!---
            Pre-load system definitions. Historical: this replaced a per-contact
            `sudetails` SELECT. The resulting `systemInfoMap` is currently unused
            downstream -- kept for parity with the older flow and in case the
            system name is needed for a future notification subject line.
        --->
        <cfquery datasource="#dsn#" name="allSystemInfo">
            SELECT systemid, systemName, systemType, systemScope, systemDescript, systemTriggerNote
            FROM fusystems
        </cfquery>
        <cfset systemInfoMap = structNew() />
        <cfloop query="allSystemInfo">
            <cfset systemInfoMap[allSystemInfo.systemid] = allSystemInfo.systemName />
        </cfloop>

        <!---
            allActionSchedules -- the full action roster per (system, user),
            collapsed into `actionScheduleMap` keyed by systemid|userid with
            the FIRST action (ordered by actionNo) only. That first action is
            what seeds the new funotifications row below. Uniqueness check
            uses actionSched.isUnique + actionSched.uniquename.
        --->

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

        <!---
            Dynamic-column guard for the uniqueness check below. The column
            name comes from fuactions.uniquename (data-driven); without a
            whitelist this would be a SQL injection vector. Any value not in
            this list is rejected and logged.
        --->
        <cfset allowedUniqueColumns = "isEmailed,isInvited,isMailed,isFollowedUp,isScheduled,isConnected,isMet,isThankYouSent" />
    </cfif>

                    <!---
                        JOB C -- main event loop.
                        One cftransaction per event: all enrollment inserts and
                        the final event-completion UPDATE either all succeed or
                        all roll back together. Note: the in-memory
                        `enrollmentSets` struct is mutated inside the
                        transaction and is NOT rewound on rollback -- see
                        review doc section "Known gaps" for the implication.
                    --->
                    <!--- TAO-CAL-01: gather distinct userids whose events we complete
                         so we can regenerate their ICS files once the batch finishes. --->
                    <cfset affectedIcsUserIds = {} />

                    <cfloop query="events">
                    <cftransaction>

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

                                            <!---
                                                WO-4.1: Enrollment check via pre-loaded map
                                                (was per-contact SELECT). Skip enrollment if:
                                                  - the contact is already enrolled in the
                                                    target system (1 or 2), OR
                                                  - target is Follow-Up (1) or Industry
                                                    Follow-Up (2) and the contact is already
                                                    in the higher-priority Target systems
                                                    (3 or 4) -- Target supersedes Follow-Up.
                                            --->
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

                                                <!--- Enrollment start date = the event's stop date. --->
                                                <cfset suStartDate = DateFormat(new_eventstop, 'yyyy-mm-dd') />
                                                <cfset currentStartDate = DateFormat(new_eventstop, 'yyyy-mm-dd') />

                                                <!---
                                                    Enroll this contact into the follow-up
                                                    system. Captures the generated suid for
                                                    the child funotifications insert below.
                                                --->
                                                <cfquery datasource="#dsn#" name="addSystem" result="result">
                                                    INSERT INTO fuSystemUsers (systemID, contactID, userID, suStartDate, sustatus)
                                                    VALUES (
                                                        <cfqueryparam cfsqltype="cf_sql_integer" value="#new_systemid#" />,
                                                        <cfqueryparam cfsqltype="cf_sql_integer" value="#new_contactid#" />,
                                                        <cfqueryparam cfsqltype="cf_sql_integer" value="#new_userid#" />,
                                                        <cfqueryparam cfsqltype="cf_sql_date" value="#suStartDate#" />,
                                                        'Active'
                                                    )
                                                </cfquery>

                                                <cfset NewSUID = numberformat(result.generatedkey) />

                                                <!---
                                                    Update the in-memory enrollment map so a
                                                    later contact in this same batch sees
                                                    the just-created enrollment and does not
                                                    double-enroll.
                                                    CAVEAT: not unwound on rollback -- see
                                                    review doc "Known gaps".
                                                --->
                                                <cfif NOT structKeyExists(enrollmentSets, enrollKey)>
                                                    <cfset enrollmentSets[enrollKey] = "" />
                                                </cfif>
                                                <cfset enrollmentSets[enrollKey] = listAppend(enrollmentSets[enrollKey], new_systemid) />

                                                    <!---
                                                        Target systems (5 = Target, 6 = Industry
                                                        Target) are considered "resolved" once
                                                        a meeting has occurred; close them out
                                                        for this contact.
                                                    --->
                                                    <cfquery datasource="#dsn#" result="result" name="CompleteTargetSystems">
                                                        UPDATE fusystemusers SET sustatus = 'Completed'
                                                        WHERE userid = <cfqueryparam cfsqltype="cf_sql_integer" value="#new_userid#" />
                                                        AND systemid IN (<cfqueryparam cfsqltype="cf_sql_integer" value="5,6" list="true" />)
                                                        AND contactid = <cfqueryparam cfsqltype="cf_sql_integer" value="#new_contactid#" />
                                                    </cfquery>

                                                    <!---
                                                        UI-facing bell notification announcing
                                                        the new follow-up system. Rendered by
                                                        the notifications dropdown / badge.
                                                    --->
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

                                                        <!---
                                                            WO-4.1: Action schedule from
                                                            pre-loaded map (was per-contact
                                                            SELECT with 3-way JOIN).
                                                            Seeds the FIRST action of the
                                                            follow-up system as a pending
                                                            funotifications row.
                                                        --->
                                                        <cfset schedKey = new_systemid & "|" & new_userid />
                                                        <cfif structKeyExists(actionScheduleMap, schedKey)>
                                                            <cfset actionSched = actionScheduleMap[schedKey] />

<cfset add_action = "Y" />

                                                        <cfset new_actionid = actionSched.actionid />
                                                        <cfset actiondaysno = numberformat(actionSched.actionDaysNo) />
                                                        <cfif actionSched.isunique is "1">

                                                            <!---
                                                                Uniqueness check. isUnique = 1
                                                                means the action should not be
                                                                re-fired if a specific flag
                                                                column on contactdetails is
                                                                already 'Y' (e.g. isThankYouSent
                                                                already set -> don't schedule
                                                                another thank-you reminder).
                                                                Column name is data-driven from
                                                                fuactions.uniquename and MUST be
                                                                in `allowedUniqueColumns` -- any
                                                                other value is a SQL-injection
                                                                attempt and is logged + skipped.
                                                            --->
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

                                                            <!---
                                                                Compute the notification due
                                                                date = enrollment start + the
                                                                action's delay in days. The
                                                                branch below splits on whether
                                                                that date is in the past:
                                                                  past/today -> insert WITHOUT
                                                                    explicit notstatus so the
                                                                    DB default applies (becomes
                                                                    immediately visible).
                                                                  future     -> insert with
                                                                    notstatus='Pending' so it
                                                                    waits until JOB A (above)
                                                                    flips it on the due date.
                                                            --->
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

                                        <!---
                                            Final step in this event's transaction: mark
                                            the event itself completed. If any prior step
                                            in the cftransaction threw, this UPDATE rolls
                                            back with the rest and the event is retried on
                                            the next run.
                                        --->
                                        <cfquery datasource="#dsn#" result="result" name="update">
                                            UPDATE events
                                            SET eventstatus = 'Completed'
                                            WHERE eventid = <cfqueryparam value="#new_eventid#" cfsqltype="cf_sql_integer" />
                                        </cfquery>

                                        <!--- TAO-CAL-01: remember userid for post-batch ICS regen. --->
                                        <cfif isNumeric(new_userid) AND new_userid GT 0>
                                            <cfset affectedIcsUserIds[new_userid] = true />
                                        </cfif>

                                    </cftransaction>
                                    </cfloop>

<!---
    JOB D -- contactdetails backfill (WO-4.4: own transaction).
    Fills contactmeetingdate / contactmeetingloc ONLY where they are NULL,
    using the OLDEST completed event linked to each contact via
    eventcontactsxref. "Oldest" is intentional -- the field represents
    the first time the actor met the contact, not the most recent.
    Runs once, globally, after every event has been processed.
--->
<cftransaction>
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

<!--- TAO-CAL-01: fire one ICS regen per affected user. Wrapped so a hook
     failure can never disrupt the completion batch. --->
<cftry>
    <cfloop collection="#affectedIcsUserIds#" item="icsUid">
        <cfset request.svc("EventService").fireIcsRegen(icsUid)>
    </cfloop>
    <cfcatch type="any">
        <cflog file="ics_service" type="error"
               text="events_completed ics regen hook fail: #left(cfcatch.message,300)#" />
    </cfcatch>
</cftry>

<cfif dbug eq "Y">
    <cfoutput>
        <div style="background-color: ##d4edda; padding: 10px; margin: 5px; border: 1px solid ##c3e6cb;">
            <strong>DEBUG: Process completed successfully</strong><br>
            End Time: #timeFormat(now(), "HH:mm:ss")#<br>
            Total events processed: #events.recordCount#<br>
        </div>
    </cfoutput>
</cfif>
