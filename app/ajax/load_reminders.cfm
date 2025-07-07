<cfcontent type="text/html; charset=utf-8">
<cfsetting showdebugoutput="false">

 

<cfparam name="url.showInactive" default="0">
<cfparam name="url.contactid" default="0">
<cfparam name="url.HIDE_COMPLETED" default="0">

<cfset currentid = url.contactid>
<cfset showInactive = url.showInactive>
<cfset hideCompleted = url.HIDE_COMPLETED>
<cfset sessionUserId = session.userid>

<!--- Load relevant system-user associations --->
<cfset systemUserService = createObject("component", "services.SystemUserService")>
<cfset sysActive = systemUserService.SELfusystemusers_24758(
    currentid = currentid,
    sessionUserId = sessionUserId,
    hideCompleted = hideCompleted
)>

<cfoutput>
<!--- Debug --->
<div style="border:1px solid ##ccc; padding:10px; margin:10px 0;">
  <strong>DEBUG INPUTS</strong><br>
  currentid: #currentid#<br>
  sessionUserId: #sessionUserId#<br>
  hideCompleted: #hideCompleted#<br>
</div>

<!--- Reminder Table Rows --->
<tbody id="reminderRows">
<cfloop query="sysActive">
  <cfinclude template="/include/qry/notsActive_510_1.cfm" />
  <cfloop query="notsActive">

    <!--- Skip if status is "Upcoming" --->
    <cfif notsActive.notstatus eq "Upcoming">
      <cfcontinue>
    </cfif>

    <!--- Hide Skipped/Completed if showInactive is off --->
    <cfif (notsActive.notstatus eq "Skipped" OR notsActive.notstatus eq "Completed") AND showInactive eq 0>
      <cfcontinue>
    </cfif>

    <!--- Hide Completed if HIDE_COMPLETED is on --->
    <cfif hideCompleted eq 1 AND notsActive.notstatus eq "Completed">
      <cfcontinue>
    </cfif>

    <tr id="not_#notsActive.notid#" class="<cfif notsActive.notstatus eq 'Skipped'>skipped-row</cfif>">
      <td>
        <a href="##" data-bs-toggle="modal" data-bs-target="##action#notsActive.notid#-modal" title="Click for details">
          <i class="fe-info font-14 mr-1"></i>
        </a>
        #notsActive.actiondetails#
      </td>
      <td>#dateFormat(notsActive.notstartdate, "mm/dd/yyyy")#</td>
      <td>#notsActive.notstatus#</td>
      <td>
        <cfif notsActive.notstatus eq "Pending">
          <input type="checkbox" class="completeReminder" data-id="#notsActive.notid#">
          <button class="btn btn-sm btn-link text-danger skipReminder" data-id="#notsActive.notid#">X</button>
        </cfif>
      </td>
    </tr>
  </cfloop>
</cfloop>
</tbody>

<!--- Modal Definitions --->
<div id="modalContainer">
<cfloop query="sysActive">
  <cfinclude template="/include/qry/notsActive_510_1.cfm" />
  <cfloop query="notsActive">

    <!--- Same filter logic as above --->
    <cfif notsActive.notstatus eq "Upcoming">
      <cfcontinue>
    </cfif>

    <cfif (notsActive.notstatus eq "Skipped" OR notsActive.notstatus eq "Completed") AND showInactive eq 0>
      <cfcontinue>
    </cfif>

    <cfif hideCompleted eq 1 AND notsActive.notstatus eq "Completed">
      <cfcontinue>
    </cfif>

    <div id="action#notsActive.notid#-modal" class="modal fade" tabindex="-1" role="dialog" aria-hidden="true">
      <div class="modal-dialog">
        <div class="modal-content">
          <div class="modal-header">
            <h4 class="modal-title">#notsActive.actiontitle#</h4>
            <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
          </div>
          <div class="modal-body">
            <h5>#notsActive.actiondetails#</h5>
            <p>#notsActive.actionInfo#</p>
          </div>
        </div>
      </div>
    </div>

  </cfloop>
</cfloop>
</div>
</cfoutput>
