<cfset dbug="N" />
<cfparam name="form.filter_completed" default="0">
<cfparam name="form.filter_skipped" default="0">
<cfparam name="form.filter_upcoming" default="1">
<cfparam name="form.filter_pending" default="1">
<!--- Set default parameters --->
<cfparam name="zquery" default="">
<cfset unchecked_style="mdi mdi-checkbox-blank-outline font-24 mr-1">
<cfset checked_style="mdi mdi-checkbox-marked-outline font-24 mr-1">
<cfparam name="hide_completed_check" default="">
<cfparam name="hide_completed" default="N">

<!--- Check if completed items should be hidden --->
<cfif #hide_completed# EQ "Y">
  <cfset hide_completed_check = "checked">
</cfif>

<cfoutput>
  <div class="d-flex justify-content-between">
    <div class="float-left">
      <!--- Filter checkboxes --->
      <label><input type="checkbox" class="status-filter" value="completed" checked> Completed</label>
      <label><input type="checkbox" class="status-filter" value="skipped" checked> Skipped</label>
      <label><input type="checkbox" class="status-filter" value="upcoming" checked> Upcoming</label>
      <label><input type="checkbox" class="status-filter" value="pending" checked> Pending</label>
    </div>
  </div>
</cfoutput>

<div id="tab-relationship-view" style="flex: 1 1 auto;">
  <!--- Loop through active systems --->
  <cfloop query="sysActive">

    <cfif #LCase(sysActive.sustatus)# EQ "active">
      <cfset showstatus = "pending">
    <cfelse>
      <cfset showstatus = "#LCase(sysActive.sustatus)#">
    </cfif>

    <cfinclude template="/include/qry/notsactive_510_1.cfm">

    <cfoutput>
      <div class="row">
        <div class="col-md-12">
          <h4>
            #sysActive.systemName#
            <a href="" title="click for details" data-bs-toggle="modal" data-bs-target="##action#sysActive.suid#-modal">
              <i class="fe-info font-14 mr-1"></i>
            </a>
            <cfif #sysActive.sustatus# EQ "Completed">
              <span class="badge bg-warning rounded-pill">Completed</span>
            </cfif>
            <a title="Delete System" href="DeleteModal.cfm?rpgid=40&recid=#sysActive.suid#&t4=1" data-bs-toggle="modal" data-bs-target="##remoteDeleteForm#sysActive.suid#">
              <i class="fe-trash-2"></i>
            </a>
          </h4>
        </div>
      </div>
    </cfoutput>

    <!--- No active items --->
    <cfif #notsActive.recordcount# EQ 0>
      <p>No action items to show!</p>
    </cfif>

    <!--- Loop through active notifications --->
    <cfif #notsActive.recordcount# NEQ 0>
      <div class="row">
        <cfloop query="notsActive">
          <cfoutput>
            <div class="col-md-12 reminder #LCase(notsActive.notstatus)#" style="padding-bottom:10px; margin-left:30px;">
              <cfif notsActive.notstatus EQ "Pending" OR notsActive.notstatus EQ "Upcoming">
                <a href="/include/complete_not.cfm?notid=#notsActive.notid#&notstatus=Completed&hide_completed=#hide_completed#">
              </cfif>

              <i class="mdi mdi-checkbox-#notsActive.checktype#-outline font-24 mr-1" style="vertical-align: middle; color:###notsActive.status_color#"></i>

              <cfif notsActive.notstatus EQ "Pending" OR notsActive.notstatus EQ "Upcoming">
                </a>
              </cfif>

              #notsActive.delstart# #notsActive.actiondetails# #notsActive.delend#

              <cfif len(notsActive.notEndDate)>
                (#notsActive.notstatus# #this.formatDate(notsActive.notEndDate)#)
              <cfelse>
                (Due Date #this.formatDate(notsActive.notstartdate)#)
              </cfif>

              <cfif notsActive.ispastdue EQ 1>
                <span class="badge badge-soft-danger">Past Due</span>
              </cfif>

              <a href="" title="Click for details" data-bs-toggle="modal" data-bs-target="##action#notsActive.actionid#-modal">
                <i class="fe-info font-14 mr-1"></i>
              </a>

              <cfif notsActive.notstatus EQ "Pending" OR notsActive.notstatus EQ "Upcoming">
                <a href="/include/complete_not.cfm?notid=#notsActive.notid#&notstatus=Skipped&hide_completed=#hide_completed#" title="Skip reminder">
                  <span class="badge badge-blue" style="margin-left:10px">x Skip</span>
                </a>
              </cfif>
            </div>
          </cfoutput>
        </cfloop>
      </div>
    </cfif>
  </cfloop>
</div>

<script>
document.addEventListener("DOMContentLoaded", function () {
  document.querySelectorAll(".status-filter").forEach(cb => {
    cb.addEventListener("change", filterReminders);
  });
  filterReminders();
});

function filterReminders() {
  const activeStatuses = Array.from(document.querySelectorAll(".status-filter:checked")).map(cb => cb.value);
  document.querySelectorAll(".reminder").forEach(reminder => {
    const classes = reminder.className.split(" ");
    reminder.style.display = classes.some(c => activeStatuses.includes(c)) ? '' : 'none';
  });
}
</script>

<cfset script_name_include="/include/#ListLast(GetCurrentTemplatePath(), " \ ")#">
