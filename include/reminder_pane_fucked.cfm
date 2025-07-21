<cfset dbug = "N">
<cfparam name="zquery" default="">
<cfset unchecked_style = "mdi mdi-checkbox-blank-outline font-24 me-2">
<cfset checked_style = "mdi mdi-checkbox-marked-outline font-24 me-2">
<cfparam name="hide_completed_check" default="">
<cfparam name="hide_completed" default="N">

<cfif hide_completed EQ "Y">
  <cfset hide_completed_check = "checked">
</cfif>

<cfoutput>
  <div class="d-flex justify-content-start mb-3">
    <label class="me-3"><input type="checkbox" class="status-filter" value="completed"> Completed</label>
    <label class="me-3"><input type="checkbox" class="status-filter" value="skipped"> Skipped</label>
    <label class="me-3"><input type="checkbox" class="status-filter" value="upcoming" checked> Upcoming</label>
    <label><input type="checkbox" class="status-filter" value="pending" checked> Pending</label>
  </div>
</cfoutput>

<div id="tab-relationship-view">
  <cfloop query="sysActive">
    <cfset showstatus = LCase(sysActive.sustatus) EQ "active" ? "pending" : LCase(sysActive.sustatus)>
    <cfinclude template="/include/qry/notsactive_510_1.cfm">

    <cfoutput>
      <div class="row mb-2">
        <div class="col-md-12">
          <h4>
            #sysActive.systemName#
            <a href="##" data-bs-toggle="modal" data-bs-target="#actionsysactive.suid#-modal" title="Click for details">
              <i class="fe-info font-14 ms-2"></i>
            </a>
            <cfif sysActive.sustatus EQ "Completed">
              <span class="badge bg-warning rounded-pill ms-2">Completed</span>
            </cfif>
            <a href="DeleteModal.cfm?rpgid=40&recid=#sysActive.suid#&t4=1" data-bs-toggle="modal" data-bs-target="##remoteDeleteForm#sysActive.suid#" title="Delete System">
              <i class="fe-trash-2 ms-2"></i>
            </a>
          </h4>
        </div>
      </div>
    </cfoutput>

    <cfif notsActive.recordcount EQ 0>
      <p class="ps-4 text-muted">No action items to show!</p>
    </cfif>

    <cfif notsActive.recordcount NEQ 0>
      <cfloop query="notsActive">
        <cfoutput>
          <div class="reminder #LCase(notsActive.notstatus)# ps-4 mb-3">
            <!--- Completion link --->
            <cfif notsActive.notstatus EQ "Pending" OR notsActive.notstatus EQ "Upcoming">
              <a href="/include/complete_not.cfm?notid=#notsActive.notid#&notstatus=Completed&hide_completed=#hide_completed#">
            </cfif>

            <!--- Icon --->
            <i class="mdi mdi-checkbox-#notsActive.checktype#-outline font-24 me-2" style="color:##notsActive.status_color"></i>

            <cfif notsActive.notstatus EQ "Pending" OR notsActive.notstatus EQ "Upcoming">
              </a>
            </cfif>

            <!--- Description --->
            #notsActive.delstart# #notsActive.actiondetails# #notsActive.delend#

            <!--- Due/Complete Date --->
            <cfif len(notsActive.notEndDate)>
              (#notsActive.notstatus# #this.formatDate(notsActive.notEndDate)#)
            <cfelse>
              (Due Date #this.formatDate(notsActive.notstartdate)#)
            </cfif>

            <!--- Past due badge --->
            <cfif notsActive.ispastdue EQ "1">
              <span class="badge bg-danger-soft ms-2">Past Due</span>
            </cfif>

            <!--- Modal trigger --->
            <a href="##" data-bs-toggle="modal" data-bs-target="#notsActive.actionid#-modal" title="Click for details">
              <i class="fe-info font-14 ms-2"></i>
            </a>

            <!--- Skip link --->
            <cfif notsActive.notstatus EQ "Pending" OR notsActive.notstatus EQ "Upcoming">
              <a href="/include/complete_not.cfm?notid=#notsActive.notid#&notstatus=Skipped&hide_completed=#hide_completed#" title="Skip reminder">
                <span class="badge bg-primary ms-3">x Skip</span>
              </a>
            </cfif>
          </div>
        </cfoutput>
      </cfloop>
    </cfif>
  </cfloop>
</div>

<!--- JavaScript filter logic --->
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
    const hasMatch = activeStatuses.some(status => reminder.classList.contains(status));
    reminder.style.display = hasMatch ? "" : "none";
  });
}
</script>

<cfset script_name_include = "/include/#ListLast(GetCurrentTemplatePath(), " \ ")#">
