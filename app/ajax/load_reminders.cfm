<cfparam name="url.showInactive" default="0">
<cfparam name="currentid" default="0">
<cfparam name="HIDE_COMPLETED" default="0">
<cfif isdefined('contactid')>
<cfset currentid = contactid />
</cfif>
<cfset showInactive = url.showInactive>

<!--- Retrieve active systems for this contact/user --->
<cfinclude template="/include/qry/sysActive_537_1.cfm" />

<cfoutput>
<tbody id="reminderRows">
  <cfloop query="sysActive">
    <cfinclude template="/include/qry/notsActive_510_1.cfm" />
    <cfloop query="notsActive">
      <cfif notsActive.notstatus eq "Upcoming">
        <cfcontinue>
      </cfif>
      <cfif notsActive.notstatus eq "Pending" OR showInactive eq "1">
        <cfif (notsActive.notstatus eq "Completed" OR notsActive.notstatus eq "Skipped") AND showInactive eq "0">
          <cfcontinue>
        </cfif>
        <tr id="not_#notsActive.notid#" class="#iif(notsActive.notstatus eq 'Skipped','skipped-row','')#">
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
      </cfif>
    </cfloop>
  </cfloop>
</tbody>

<div id="modalContainer">
  <cfloop query="sysActive">
    <cfinclude template="/include/qry/notsActive_510_1.cfm" />
    <cfloop query="notsActive">
      <cfif notsActive.notstatus eq "Upcoming">
        <cfcontinue>
      </cfif>
      <cfif notsActive.notstatus eq "Pending" OR showInactive eq "1">
        <cfif (notsActive.notstatus eq "Completed" OR notsActive.notstatus eq "Skipped") AND showInactive eq "0">
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
      </cfif>
    </cfloop>
  </cfloop>
</div>
</cfoutput>
