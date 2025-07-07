<cfsetting showdebugoutput="false">
<cfcontent type="text/html; charset=utf-8">

<cfparam name="url.contactid" default="0">
<cfparam name="url.showInactive" default="0">
<cfparam name="url.HIDE_COMPLETED" default="0">

<cfset currentid = val(url.contactid)>
<cfset showInactive = val(url.showInactive)>
<cfset hideCompleted = url.HIDE_COMPLETED>
<cfset host = ListFirst(cgi.server_name, ".")>
<cfset dsn = iif(host EQ "app", "abo", "abod")>

<!--- Determine sessionUserId and sysActiveSuid --->
<cfif structKeyExists(session, "user_id")>
  <cfset sessionUserId = session.user_id>
<cfelse>
  <cfquery name="findUser" datasource="#dsn#">
    SELECT userid FROM contactdetails WHERE contactid = <cfqueryparam value="#currentid#" cfsqltype="cf_sql_integer">
  </cfquery>
  <cfif findUser.recordCount>
    <cfset sessionUserId = findUser.userid>
  <cfelse>
    <cfoutput><h2>Unauthorized</h2><p>No user found for contact ID #currentid#.</p></cfoutput>
    <cfabort>
  </cfif>
</cfif>

<cfquery name="getSu" datasource="#dsn#">
  SELECT suid
  FROM fusystemusers
  WHERE contactid = <cfqueryparam value="#currentid#" cfsqltype="cf_sql_integer">
    AND userid = <cfqueryparam value="#sessionUserId#" cfsqltype="cf_sql_integer">
    AND sustatus = 'Active'
</cfquery>

<cfif getSu.recordCount>
  <cfset sysActiveSuid = getSu.suid>
<cfelse>
  <cfoutput><h2>No Active System User</h2><p>No active fusystemusers record found.</p></cfoutput>
  <cfabort>
</cfif>

<!--- MAIN QUERY --->
<cfquery name="qReminders" datasource="#dsn#">
  SELECT
    n.notID,
    n.actionID,
    n.userID,
    n.suID,
    n.notStartDate,
    n.notStatus,
    n.ispastdue,

    a.actionTitle,
    a.actionDetails,
    a.actionInfo,

    ns.status_color

  FROM funotifications n
  INNER JOIN fusystemusers f ON f.suID = n.suID
  INNER JOIN fuactions a ON a.actionID = n.actionID
  INNER JOIN notstatuses ns ON ns.notstatus = n.notStatus

  WHERE f.contactID = <cfqueryparam value="#currentid#" cfsqltype="cf_sql_integer">
    AND f.suID = <cfqueryparam value="#sysActiveSuid#" cfsqltype="cf_sql_integer">
    AND n.notStartDate IS NOT NULL
    AND n.notStartDate <= <cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">
    <cfif hideCompleted EQ "1">
      AND n.notStatus NOT IN ('Completed', 'Skipped')
    <cfelseif showInactive EQ 0>
      AND n.notStatus = 'Pending'
    </cfif>

  ORDER BY 
    FIELD(n.notStatus, 'Pending', 'Completed', 'Skipped'),
    n.notStartDate
</cfquery>

<!--- OUTPUT TABLE ROWS --->
<cfoutput query="qReminders">
  <tr id="not_#notID#" class="#iif(notStatus EQ 'Skipped', 'skipped-row', '')#">
    <td>
      <a href="##" data-bs-toggle="modal" data-bs-target="##action#notID#-modal" title="Click for details">
        <i class="fe-info font-14 mr-1"></i>
      </a>
      #actionDetails#
    </td>
    <td>#dateformat(notStartDate, "mm/dd/yyyy")#</td>
    <td>#notStatus#</td>
    <td>
      <input type="checkbox" class="completeReminder" data-id="#notID#">
      <button class="btn btn-sm btn-link text-danger skipReminder" data-id="#notID#">X</button>
    </td>
  </tr>
</cfoutput>

<!--- OUTPUT MODALS --->
<div id="modalContainer">
  <cfoutput query="qReminders">
    <div id="action#notID#-modal" class="modal fade" tabindex="-1" role="dialog" aria-hidden="true">
      <div class="modal-dialog">
        <div class="modal-content">
          <div class="modal-header">
            <h4 class="modal-title">#actionTitle#</h4>
            <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
          </div>
          <div class="modal-body">
            <h5>#actionDetails#</h5>
            <p>#actionInfo#</p>
          </div>
        </div>
      </div>
    </div>
  </cfoutput>
</div>
