<cfsilent>
<cfinclude template="/database/admin-guard.cfm">
<cfset datasource = application.dsn>

<!---
    Diagnostic + fix for user 1065 (Thomas DiNardo).
    Symptom: cannot select a time in audition appointment add/update.

    Usage:
      /database/diag-user-1065.cfm                     -> read-only diagnostic
      /database/diag-user-1065.cfm?fix=calendar        -> repair NULL calstarttime / calendtime
      /database/diag-user-1065.cfm?fix=setup           -> re-run user_setup_core.cfm for user 1065
      /database/diag-user-1065.cfm?fix=all             -> both fixes, in order
--->

<cfparam name="url.uid"   default="1065" />
<cfparam name="url.fix"   default="" />

<cfset targetUserId = val(url.uid) />
<cfif targetUserId lte 0>
    <cfabort showerror="Invalid uid parameter" />
</cfif>

<cfset defaultCalStart = "09:00:00" />
<cfset defaultCalEnd   = "17:00:00" />

<!---
    Tables populated at user setup (see sched/user_setup_core.cfm).
    Each row: master table -> user table, value column, optional category column.
--->
<cfset enumChecks = [
    { master="auddialects",        userTbl="auddialects_user",     valCol="auddialect",      catCol="audcatid"  },
    { master="audgenres",          userTbl="audgenres_user",       valCol="audgenre",        catCol="audcatid"  },
    { master="audnetworks",        userTbl="audnetworks_user",     valCol="network",         catCol="audcatid"  },
    { master="audopencalloptions", userTbl="audopencalloptions_user", valCol="opencallname", catCol=""          },
    { master="audplatforms",       userTbl="audplatforms_user",    valCol="audplatform",     catCol=""          },
    { master="audtones",           userTbl="audtones_user",        valCol="tone",            catCol="audcatid"  },
    { master="eventtypes",         userTbl="eventtypes_user",      valCol="eventTypeName",   catCol=""          },
    { master="genderpronouns",     userTbl="genderpronouns_users", valCol="genderpronoun",   catCol=""          },
    { master="itemtypes",          userTbl="itemtypes_user",       valCol="valuetype",       catCol=""          },
    { master="tags",               userTbl="tags_user",            valCol="tagname",         catCol=""          },
    { master="sitetypes_master",   userTbl="sitetypes_user",       valCol="sitetypename",    catCol=""          },
    { master="audsubmitsites",     userTbl="audsubmitsites_user",  valCol="submitsitename",  catCol=""          },
    { master="audquestions_default", userTbl="audquestions_user",  valCol="qorder",          catCol=""          },
    { master="pgpanels_master",    userTbl="pgpanels_user",        valCol="pnFilename",      catCol=""          }
] />
</cfsilent>
<!DOCTYPE html>
<html>
<head>
<title>Diag user <cfoutput>#targetUserId#</cfoutput></title>
<style>
  body { font-family: monospace; padding: 20px; font-size: 13px; }
  h2, h3 { margin-bottom: 6px; }
  table { border-collapse: collapse; margin: 8px 0 16px; }
  th, td { border: 1px solid #ccc; padding: 4px 8px; text-align: left; vertical-align: top; }
  th { background: #eee; }
  .ok   { background: #d4edda; }
  .warn { background: #fff3cd; }
  .err  { background: #f8d7da; }
  .muted { color: #888; }
  .btn { display: inline-block; padding: 6px 12px; margin-right: 8px;
         background: #2563eb; color: white; text-decoration: none; border-radius: 4px; }
  .btn-warn { background: #d97706; }
  .btn-danger { background: #b91c1c; }
  pre { background: #f5f5f5; padding: 6px; overflow-x: auto; }
</style>
</head>
<body>

<cfoutput>
<h2>Diagnostic: user #targetUserId# (DSN: #datasource#)</h2>
</cfoutput>

<!--- ============================================================
     1. User record snapshot
============================================================ --->
<h3>1. User record</h3>
<cfquery name="qUser" datasource="#datasource#">
    SELECT userid, userFirstName, userLastName, userEmail, userRole, userstatus,
           isSetup, setup_step, setup_completed_at,
           isAudition, isAuditionModule, IsBetaTester, IsDeleted,
           contactid, avatarname, tzid, defRows, defCountry, defState,
           calstarttime, calendtime, calSlotDuration, viewtypeid
    FROM taousers_tbl
    WHERE userid = <cfqueryparam value="#targetUserId#" cfsqltype="cf_sql_integer">
</cfquery>

<cfif qUser.recordCount EQ 0>
    <p class="err">No taousers_tbl row for userid=<cfoutput>#targetUserId#</cfoutput>. Aborting.</p>
    </body></html>
    <cfabort />
</cfif>

<cfset needsCalendarFix = (NOT len(trim(qUser.calstarttime))) OR (NOT len(trim(qUser.calendtime))) />
<cfset recordComplete   = (trim(qUser.userstatus) EQ "Active") AND (val(qUser.setup_step) GTE 7) />

<table>
<cfoutput>
    <tr><th>userid</th><td>#qUser.userid#</td></tr>
    <tr><th>name</th><td>#qUser.userFirstName# #qUser.userLastName#</td></tr>
    <tr><th>email</th><td>#qUser.userEmail#</td></tr>
    <tr><th>role</th><td>#qUser.userRole#</td></tr>
    <tr class="#(trim(qUser.userstatus) EQ 'Active') ? 'ok' : 'warn'#">
        <th>userstatus</th><td>[#qUser.userstatus#]</td></tr>
    <tr class="#val(qUser.setup_step) GTE 7 ? 'ok' : 'warn'#">
        <th>setup_step</th><td>#qUser.setup_step# (7 = completed)</td></tr>
    <tr><th>setup_completed_at</th>
        <td>#(len(qUser.setup_completed_at) ? qUser.setup_completed_at : '<span class=""muted"">NULL</span>')#</td></tr>
    <tr><th>isSetup</th><td>#qUser.isSetup#</td></tr>
    <tr><th>isAudition</th><td>#qUser.isAudition#</td></tr>
    <tr><th>isAuditionModule</th><td>#qUser.isAuditionModule#</td></tr>
    <tr><th>IsDeleted</th><td>#qUser.IsDeleted#</td></tr>
    <tr><th>contactid</th><td>#qUser.contactid#</td></tr>
    <tr><th>tzid</th><td>#qUser.tzid#</td></tr>
    <tr class="#len(trim(qUser.calstarttime)) ? 'ok' : 'err'#">
        <th>calstarttime</th>
        <td>#(len(trim(qUser.calstarttime)) ? qUser.calstarttime : '<strong>NULL / EMPTY &larr; breaks the time dropdown</strong>')#</td></tr>
    <tr class="#len(trim(qUser.calendtime)) ? 'ok' : 'err'#">
        <th>calendtime</th>
        <td>#(len(trim(qUser.calendtime)) ? qUser.calendtime : '<strong>NULL / EMPTY &larr; breaks the time dropdown</strong>')#</td></tr>
    <tr><th>record complete?</th>
        <td class="#recordComplete ? 'ok' : 'warn'#">#recordComplete ? 'YES (Active + setup_step >= 7)' : 'NO'#</td></tr>
</cfoutput>
</table>

<!--- ============================================================
     2. Enum coverage (master vs user tables)
============================================================ --->
<h3>2. Enum coverage for user <cfoutput>#targetUserId#</cfoutput></h3>
<p class="muted">Counts master rows vs. this user's rows. A gap means user_setup_core.cfm did not populate them.</p>

<table>
<tr><th>master table</th><th>user table</th><th>master count</th><th>user count</th><th>gap</th></tr>
<cfset totalGap = 0 />
<cfloop array="#enumChecks#" index="chk">
    <cftry>
        <!--- Master count (apply isdeleted=0 where that column exists) --->
        <cfquery name="qMaster" datasource="#datasource#">
            SELECT COUNT(*) AS cnt FROM #chk.master#
            <cfif chk.master NEQ "audopencalloptions"
                  AND chk.master NEQ "eventtypes"
                  AND chk.master NEQ "tags"
                  AND chk.master NEQ "audsubmitsites"
                  AND chk.master NEQ "genderpronouns"
                  AND chk.master NEQ "pgpanels_master">
                WHERE isdeleted = 0
            </cfif>
        </cfquery>

        <cfquery name="qUserCnt" datasource="#datasource#">
            SELECT COUNT(*) AS cnt FROM #chk.userTbl#
            WHERE userid = <cfqueryparam value="#targetUserId#" cfsqltype="cf_sql_integer">
        </cfquery>

        <cfset gap = qMaster.cnt - qUserCnt.cnt />
        <cfif gap LT 0><cfset gap = 0 /></cfif>
        <cfset totalGap += gap />
        <cfset rowClass = (gap EQ 0) ? "ok" : "warn" />

        <cfoutput>
            <tr class="#rowClass#">
                <td>#chk.master#</td>
                <td>#chk.userTbl#</td>
                <td>#qMaster.cnt#</td>
                <td>#qUserCnt.cnt#</td>
                <td>#gap#</td>
            </tr>
        </cfoutput>
        <cfcatch>
            <cfoutput>
                <tr class="err">
                    <td>#chk.master#</td>
                    <td>#chk.userTbl#</td>
                    <td colspan="3">ERROR: #htmlEditFormat(cfcatch.message)#</td>
                </tr>
            </cfoutput>
        </cfcatch>
    </cftry>
</cfloop>
</table>

<cfoutput>
<p>Total enum gap: <strong>#totalGap#</strong></p>
</cfoutput>

<!--- ============================================================
     3. Actions
============================================================ --->
<h3>3. Actions</h3>

<cfif url.fix EQ "">
    <p>Read-only mode. Apply fixes:</p>
    <cfoutput>
        <cfif needsCalendarFix>
            <a class="btn btn-warn"
               href="?uid=#targetUserId#&fix=calendar">Fix calstarttime / calendtime (defaults #defaultCalStart# &ndash; #defaultCalEnd#)</a>
        </cfif>
        <cfif totalGap GT 0>
            <a class="btn btn-warn"
               href="?uid=#targetUserId#&fix=setup">Re-run user_setup_core.cfm for user #targetUserId#</a>
        </cfif>
        <cfif needsCalendarFix OR totalGap GT 0>
            <a class="btn btn-danger"
               href="?uid=#targetUserId#&fix=all">Fix everything (calendar + setup)</a>
        </cfif>
        <cfif NOT needsCalendarFix AND totalGap EQ 0>
            <p class="ok" style="padding:6px;">No fixes needed. User record looks healthy.</p>
        </cfif>
    </cfoutput>

<cfelse>
    <!--- ---------- Apply fixes ---------- --->
    <cfset doCalendar = (url.fix EQ "calendar" OR url.fix EQ "all") />
    <cfset doSetup    = (url.fix EQ "setup"    OR url.fix EQ "all") />

    <!--- 3a. Calendar default fix --->
    <cfif doCalendar>
        <h4>3a. Fixing calstarttime / calendtime</h4>
        <cftry>
            <cfquery datasource="#datasource#" result="rFix">
                UPDATE taousers_tbl
                SET
                    calstarttime = CASE
                        WHEN calstarttime IS NULL OR calstarttime = ''
                        THEN <cfqueryparam value="#defaultCalStart#" cfsqltype="cf_sql_time">
                        ELSE calstarttime
                    END,
                    calendtime = CASE
                        WHEN calendtime IS NULL OR calendtime = ''
                        THEN <cfqueryparam value="#defaultCalEnd#" cfsqltype="cf_sql_time">
                        ELSE calendtime
                    END
                WHERE userid = <cfqueryparam value="#targetUserId#" cfsqltype="cf_sql_integer">
            </cfquery>
            <cflog file="tao_diag_user_#targetUserId#" type="information"
                   text="Calendar fix applied by admin userid=#session.userid# for target=#targetUserId#" />
            <cfoutput>
                <p class="ok" style="padding:6px;">Calendar defaults applied. Rows affected: #rFix.recordCount#</p>
            </cfoutput>
            <cfcatch>
                <p class="err" style="padding:6px;">
                    Calendar fix FAILED: <cfoutput>#htmlEditFormat(cfcatch.message)#</cfoutput>
                </p>
            </cfcatch>
        </cftry>
    </cfif>

    <!--- 3b. Re-run user setup core --->
    <cfif doSetup>
        <h4>3b. Running user_setup_core.cfm for userid <cfoutput>#targetUserId#</cfoutput></h4>
        <pre>
<cftry>
    <cfset select_userid = targetUserId />
    <cfset dbug = "Y" />
    <cfset dbugz = "N" />
    <cfset select_contactid = 0 />
    <cfset select_user = 0 />
    <cfinclude template="/sched/user_setup_core.cfm" />
<cfcatch>
    <cfoutput>
        <span style="color:##b91c1c;">
            user_setup_core.cfm threw: #htmlEditFormat(cfcatch.message)#
            #htmlEditFormat(cfcatch.detail)#
        </span>
    </cfoutput>
</cfcatch>
</cftry>
        </pre>
        <cflog file="tao_diag_user_#targetUserId#" type="information"
               text="user_setup_core.cfm re-run by admin userid=#session.userid# for target=#targetUserId#" />
    </cfif>

    <!--- Bust UserService session cache so the affected user sees the change on next request --->
    <cfset session.bustUserCache = true />

    <cfoutput>
        <p><a class="btn" href="?uid=#targetUserId#">Re-run diagnostic</a></p>
    </cfoutput>
</cfif>

<hr />
<p class="muted">
    Next step after fix: have Thomas reload the audition page. The user service caches
    profile data per session; <code>session.bustUserCache = true</code> only busts the
    admin's session. Thomas's session will refresh the cache on his next login or when
    his profile is updated (update_cal already sets bustUserCache).
</p>

</body>
</html>
