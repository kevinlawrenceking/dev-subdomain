<cfparam name="url.showInactive" default="0">
<cfparam name="url.contactid" default="0">
<cfparam name="url.HIDE_COMPLETED" default="0">

<cfset currentid     = url.contactid>
<cfset showInactive  = url.showInactive>
<cfset hideCompleted = url.HIDE_COMPLETED>

<!--- DEBUG --->
<cfoutput>
<div style="border:1px solid #ccc; padding:10px; margin:10px 0;">
  <strong>DEBUG INPUTS</strong><br>
  currentid: #currentid#<br>
  sessionUserId: #session.userid#<br>
  hideCompleted: #hideCompleted#<br>
</div>
</cfoutput>

<!--- Get active systems for this contact/user --->
<cfset systemUserService = createObject("component", "services.SystemUserService")>
<cfset sysActive = systemUserService.SELfusystemusers_24758(
    currentid = currentid,
    sessionUserId = session.userid,
    hideCompleted = hideCompleted
)>

<cfoutput>
<!--- Reminder Rows: output only <tr> rows, NOT the <tbody> wrapper --->
<cfloop query="sysActive">
  <cfinclude template="/include/qry/notsActive_510_1.cfm" />
  <cfloop query="notsActive">
    <cfif notsActive.notstatus eq "Upcoming">
      <cfcontinue>
    </cfif>

    <!--- Filtering --->
    <cfif (
      (notsActive.notstatus eq "Completed" AND hideCompleted eq "1") OR
      ((notsActive.notstatus eq "Completed" OR notsActive.notstatus eq "Skipped") AND showInactive eq "0")
    )>
      <!--- Skip --->
      <cfcontinue>
    </cfif>

    <!--- Render one row --->
  <cfset rowClass = "">
<cfif notsActive.notstatus eq "Skipped">
  <cfset rowClass = "skipped-row">
</cfif>

<tr id="not_#notsActive.notid#" class="#rowClass#">

      <td>
        <a href="##" data-bs-toggle="modal" data-bs-target="##action#notsActive.notid#-modal" title="Click for details">
          <i class="fe-info font-14 mr-1"></i>
        </a>
        #notsActive.delstart# #notsActive.actiondetails# #notsActive.delend#
      </td>
      <td>#this.formatDate(notsActive.notstartdate)#</td>
      <td><cfif notsActive.notstatus eq 'Pending'>Pending<cfelse>#notsActive.notstatus#</cfif></td>
      <td>
        <cfif notsActive.notstatus eq 'Pending'>
          <input type="checkbox" class="completeReminder" data-id="#notsActive.notid#">
          <button class="btn btn-sm btn-link text-danger skipReminder" data-id="#notsActive.notid#">X</button>
        </cfif>
      </td>
    </tr>
  </cfloop>
</cfloop>

<!--- Modal Definitions --->
<div id="modalContainer">
<cfloop query="sysActive">
  <cfinclude template="/include/qry/notsActive_510_1.cfm" />
  <cfloop query="notsActive">
    <cfif notsActive.notstatus eq "Upcoming">
      <cfcontinue>
    </cfif>

    <cfif (
      (notsActive.notstatus eq "Completed" AND hideCompleted eq "1") OR
      ((notsActive.notstatus eq "Completed" OR notsActive.notstatus eq "Skipped") AND showInactive eq "0")
    )>
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
