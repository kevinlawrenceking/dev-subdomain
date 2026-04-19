<!---
    ============================================================================
    sched/ics-reconcile-nightly.cfm
    ============================================================================
    TAO-CAL-01 Phase B nightly ICS reconcile.

    PURPOSE: net for users whose event-driven regen was skipped (hook missing,
    thread failed, file deleted, new user). Missing-file sweep only -- does
    NOT reprocess users whose .ics already exists. (Content reconciliation is
    deferred to TAO-CAL-02 when per-event type/color is persisted.)

    Run: once per day, 03:00 local, via ColdFusion scheduled task.
    See sched/README_SCHEDTASK.md for scheduler setup.
    ============================================================================
--->
<cfsetting requesttimeout="600" />

<cfparam name="dbug" default="N" />

<cfset startTick = getTickCount() />
<cfset scanned    = 0 />
<cfset regenerated = 0 />
<cfset skipped    = 0 />
<cfset failed     = 0 />

<cftry>
    <cfset var calDir = application.baseMediaPath & "\calendar" />
    <cfif NOT directoryExists(calDir)>
        <cfset directoryCreate(calDir, true) />
    </cfif>

    <cfquery name="qUsers" datasource="#application.dsn#">
        SELECT u.userid,
               REPLACE(REPLACE(u.recordname, ' ', ''), '-', '') AS calendarName
        FROM taousers u
        WHERE u.isdeleted = 0
          AND EXISTS (
              SELECT 1
              FROM events_tbl e
              WHERE e.userid    = u.userid
                AND e.isdeleted = 0
          )
    </cfquery>

    <cfloop query="qUsers">
        <cfset scanned++ />

        <cfif NOT len(qUsers.calendarName)>
            <cfset skipped++ />
            <cfcontinue />
        </cfif>

        <cfset var icsPath = calDir & "\" & qUsers.calendarName & ".ics" />

        <cfif fileExists(icsPath)>
            <cfset skipped++ />
            <cfcontinue />
        </cfif>

        <cftry>
            <cfset var ok = request.svc("IcsService").generateUserIcs(qUsers.userid) />
            <cfif ok>
                <cfset regenerated++ />
            <cfelse>
                <cfset failed++ />
            </cfif>
            <cfcatch type="any">
                <cfset failed++ />
                <cflog file="ics_service" type="error"
                       text="reconcile: userid=#qUsers.userid# msg=#left(cfcatch.message,300)#" />
            </cfcatch>
        </cftry>
    </cfloop>

    <cfset var elapsed = getTickCount() - startTick />
    <cflog file="ics_service" type="information"
           text="reconcile done scanned=#scanned# regenerated=#regenerated# skipped=#skipped# failed=#failed# elapsed_ms=#elapsed#" />

    <cfif dbug eq "Y">
        <cfoutput>
            <div style="background-color: ##e6ffe6; padding: 10px; margin: 5px; border: 1px solid ##93c47d;">
                <strong>ICS Reconcile complete</strong><br>
                Scanned: #scanned#<br>
                Regenerated (missing file): #regenerated#<br>
                Skipped (already present or no calendar name): #skipped#<br>
                Failed: #failed#<br>
                Elapsed: #elapsed# ms
            </div>
        </cfoutput>
    </cfif>

    <cfcatch type="any">
        <cflog file="ics_service" type="error"
               text="reconcile fatal: #left(cfcatch.message,500)#" />
        <cfif dbug eq "Y">
            <cfoutput>
                <div style="background-color: ##ffe6e6; padding: 10px; margin: 5px; border: 1px solid ##e06666;">
                    <strong>ICS Reconcile FAILED:</strong> #htmlEditFormat(cfcatch.message)#
                </div>
            </cfoutput>
        </cfif>
    </cfcatch>
</cftry>
