<cfsetting showdebugoutput="false">
<cfcontent type="text/html; charset=utf-8">

<cfparam name="url.contactid" default="0">
<cfparam name="url.showInactive" default="0">
<cfparam name="url.HIDE_COMPLETED" default="0">

<!--- Infer DSN from host --->
<cfset host = ListFirst(cgi.server_name, ".")>
<cfset dsn = (host EQ "app") ? "abo" : "abod">

<!--- Normalize Inputs --->
<cfset currentid = val(url.contactid)>
<cfset showInactive = val(url.showInactive)>
<cfset hideCompleted = val(url.HIDE_COMPLETED)>
<cfset sessionUserId = 0>

<!--- Get sessionUserId from session or fallback --->
<cfif structKeyExists(session, "user_id")>
  <cfset sessionUserId = session.user_id>
<cfelse>
  <cfquery name="findUser" datasource="#dsn#">
    SELECT userid FROM contactdetails 
    WHERE contactid = <cfqueryparam value="#currentid#" cfsqltype="cf_sql_integer">
  </cfquery>
  <cfif findUser.recordCount>
    <cfset sessionUserId = findUser.userid>
  <cfelse>
    <cfoutput><h2>Unauthorized</h2><p>No user associated with contact ID #currentid#.</p></cfoutput>
    <cfabort>
  </cfif>
</cfif>

<!--- Execute main query --->
<cftry>
  <cfquery name="qReminders" datasource="#dsn#">
    SELECT 
      n.id AS reminder_id,
      n.notStatus AS reminder_status,
      n.notstartdate AS not_date,
      a.name AS action_name,
      a.description AS action_description,
      a.title AS action_title
    FROM notifications n
    INNER JOIN fuactions a ON a.id = n.action_id
    WHERE n.contact_id = <cfqueryparam value="#currentid#" cfsqltype="cf_sql_integer">
      AND n.user_id = <cfqueryparam value="#sessionUserId#" cfsqltype="cf_sql_integer">
      AND (
        <cfif showInactive EQ 1>
          n.notStatus IN ('Pending', 'Skipped', 'Completed')
        <cfelse>
          n.notStatus = 'Pending'
        </cfif>
      )
      <cfif hideCompleted EQ 1>
        AND n.notStatus != 'Completed'
      </cfif>
      AND n.notstartdate <= GETDATE()
    ORDER BY n.notstartdate ASC
  </cfquery>
<cfcatch type="any">
  <cfoutput>
    <h2>Query Error</h2>
    <pre>#cfcatch.message#</pre>
    <pre>#cfcatch.detail#</pre>
    <pre>#cfcatch.queryError#</pre>
  </cfoutput>
  <cfabort>
</cfcatch>
</cftry>

<!--- Output Table Rows --->
<cfoutput query="qReminders">
  <tr id="not_#reminder_id#" class="#iif(reminder_status EQ 'Skipped', 'skipped-row', '')#">
    <td>
      <a href="##" data-bs-toggle="modal" data-bs-target="##action#reminder_id#-modal" title="Click for details">
        <i class="fe-info font-14 mr-1"></i>
      </a>
      #action_name#
    </td>
    <td>#dateFormat(not_date, "mm/dd/yyyy")#</td>
    <td>#reminder_status#</td>
    <td>
      <input type="checkbox" class="completeReminder" data-id="#reminder_id#">
      <button class="btn btn-sm btn-link text-danger skipReminder" data-id="#reminder_id#">X</button>
    </td>
  </tr>
</cfoutput>

<!--- Modal Container --->
<div id="modalContainer">
  <cfoutput query="qReminders">
    <div id="action#reminder_id#-modal" class="modal fade" tabindex="-1" role="dialog" aria-hidden="true">
      <div class="modal-dialog">
        <div class="modal-content">
          <div class="modal-header">
            <h4 class="modal-title">#action_title#</h4>
            <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
          </div>
          <div class="modal-body">
            <h5>#action_name#</h5>
            <p>#action_description#</p>
          </div>
        </div>
      </div>
    </div>
  </cfoutput>
</div>
