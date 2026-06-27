<!---
    PURPOSE: Contact duplicate detection + merge management UI (per user).
    AUTHOR:  Kevin King
    DATE:    2025-08-07
    REWRITE: 2026-06-25 - rebuilt on verified schema via ContactDuplicateService.
             FULL tab  = exact email / phone / name groups.
             POSSIBLE tab = SOUNDEX near-name pairs (review bucket).
    PARAMETERS: duplicateType (full|possible), action (list|merge)
    DEPENDENCIES: services.ContactDuplicateService, Bootstrap 5, jQuery, DataTables
--->

<cfparam name="duplicateType" default="full" />
<cfparam name="action"        default="list" />
<cfset userid = session.userid />

<cfset duplicateService = createObject("component", "services.ContactDuplicateService").init() />

<!--- Handle merge submit (CSRF is enforced globally by /app/Application.cfc) --->
<cfif action EQ "merge" AND structKeyExists(form, "primaryContactId") AND structKeyExists(form, "duplicateContactId")>
    <!--- ColdFusion does NOT auto-nest "mergeData[field]" form fields, so rebuild the struct by hand --->
    <cfset mergeData = {} />
    <cfloop collection="#form#" item="fkey">
        <cfif reFindNoCase("^mergeData\[.+\]$", fkey)>
            <cfset fname = reReplaceNoCase(fkey, "^mergeData\[(.*)\]$", "\1") />
            <cfif len(fname) AND fname NEQ fkey>
                <cfset mergeData[fname] = form[fkey] />
            </cfif>
        </cfif>
    </cfloop>
    <cfset mergeResult = duplicateService.mergeContacts(
        primaryContactId   = val(form.primaryContactId),
        duplicateContactId = val(form.duplicateContactId),
        mergeData          = mergeData,
        userid             = userid
    ) />
    <cfif mergeResult.success>
        <cfset showAlert = { type: "success", message: "Contacts merged successfully. (merge ##" & mergeResult.mergeid & ")" } />
    <cfelse>
        <cfset showAlert = { type: "danger", message: mergeResult.message } />
    </cfif>
</cfif>

<!--- Load report data --->
<cfif duplicateType EQ "possible">
    <cfset duplicates = duplicateService.findPossibleDuplicates(userid) />
    <cfset pageTitle  = "Possible Duplicate Contacts (similar names)" />
<cfelse>
    <cfset duplicateType = "full" />
    <cfset duplicates = duplicateService.findFullDuplicates(userid) />
    <cfset pageTitle  = "Full Duplicate Contacts (same email / phone / name)" />
</cfif>

<!--- Page Header --->
<div class="row">
    <div class="col-12">
        <div class="page-title-box">
            <div class="page-title-right">
                <ol class="breadcrumb m-0">
                    <li class="breadcrumb-item"><a href="/app/dashboard/">Dashboard</a></li>
                    <li class="breadcrumb-item"><a href="/app/contacts/">Contacts</a></li>
                    <li class="breadcrumb-item active">Duplicate Management</li>
                </ol>
            </div>
            <h4 class="page-title"><cfoutput>#pageTitle#</cfoutput></h4>
        </div>
    </div>
</div>

<cfif isDefined("showAlert")>
    <cfoutput>
    <div class="alert alert-#showAlert.type# alert-dismissible fade show" role="alert">
        #encodeForHtml(showAlert.message)#
        <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
    </div>
    </cfoutput>
</cfif>

<div class="card">
    <div class="card-body">
        <ul class="nav nav-pills navtab-bg nav-justified mb-3" role="tablist">
            <li class="nav-item">
                <a href="?duplicateType=full" class="nav-link<cfif duplicateType EQ 'full'> active</cfif>">
                    Full duplicates
                </a>
            </li>
            <li class="nav-item">
                <a href="?duplicateType=possible" class="nav-link<cfif duplicateType EQ 'possible'> active</cfif>">
                    Possible duplicates
                </a>
            </li>
        </ul>

        <cfif duplicates.recordCount GT 0>
            <div class="table-responsive">
                <table id="duplicatesTable" class="table table-striped table-bordered dt-responsive nowrap w-100">
                    <thead>
                        <tr>
                            <cfif duplicateType EQ "possible">
                                <th>Contact A</th>
                                <th>Contact B</th>
                                <th>Action</th>
                            <cfelse>
                                <th>Match type</th>
                                <th>Matched value</th>
                                <th>Contacts</th>
                                <th>Count</th>
                                <th>Action</th>
                            </cfif>
                        </tr>
                    </thead>
                    <tbody>
                        <cfoutput query="duplicates">
                            <tr>
                                <cfif duplicateType EQ "possible">
                                    <td>#encodeForHtml(name_a)# <span class="text-muted">(###id_a#)</span></td>
                                    <td>#encodeForHtml(name_b)# <span class="text-muted">(###id_b#)</span></td>
                                    <td>
                                        <button type="button" class="btn btn-primary btn-sm"
                                                onclick="showMergeModal('#id_a#,#id_b#')">
                                            <i class="fe-shuffle"></i> Review &amp; Merge
                                        </button>
                                    </td>
                                <cfelse>
                                    <td><span class="badge bg-info">#encodeForHtml(match_type)#</span></td>
                                    <td>#encodeForHtml(match_key)#</td>
                                    <td>#encodeForHtml(replace(names, ' | ', '<br>', 'all'))#</td>
                                    <td><span class="badge bg-warning">#dupe_count#</span></td>
                                    <td>
                                        <button type="button" class="btn btn-primary btn-sm"
                                                onclick="showMergeModal('#encodeForJavaScript(contact_ids)#')">
                                            <i class="fe-shuffle"></i> Review &amp; Merge
                                        </button>
                                    </td>
                                </cfif>
                            </tr>
                        </cfoutput>
                    </tbody>
                </table>
            </div>
        <cfelse>
            <div class="text-center py-5">
                <i class="fe-users text-muted" style="font-size: 48px;"></i>
                <h5 class="text-muted mt-3">No duplicates found</h5>
                <p class="text-muted">
                    <cfif duplicateType EQ "possible">
                        No contacts with similar names were found.
                    <cfelse>
                        No contacts share an email, phone, or exact name.
                    </cfif>
                </p>
            </div>
        </cfif>
    </div>
</div>

<!--- Merge Modal --->
<div id="mergeModal" class="modal fade" tabindex="-1" role="dialog" aria-labelledby="mergeModalTitle" aria-hidden="true">
    <div class="modal-dialog modal-xl">
        <div class="modal-content">
            <div class="modal-header">
                <h4 class="modal-title" id="mergeModalTitle">Merge duplicate contacts</h4>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body">
                <div id="mergeContent">
                    <div class="text-center">
                        <div class="spinner-border text-primary" role="status">
                            <span class="visually-hidden">Loading...</span>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<script>
document.addEventListener("DOMContentLoaded", function() {
    if (document.getElementById('duplicatesTable')) {
        $('#duplicatesTable').DataTable({
            pageLength: 25,
            order: [],
            columnDefs: [{ orderable: false, targets: -1 }]
        });
    }
});

function showMergeModal(contactIds) {
    const modal = new bootstrap.Modal(document.getElementById('mergeModal'));
    $('#mergeContent').load('/include/merge_contacts_interface.cfm', {
        contactIds: contactIds
    }, function() {
        modal.show();
    });
}
</script>

<style>
.contact-card { border: 2px solid #e3e6f0; transition: border-color 0.3s; }
.contact-card.is-primary   { border-color: #4e73df; background-color: #f8f9fc; }
.contact-card.is-duplicate { border-color: #e74a3b; background-color: #fff5f5; }
.field-comparison { border-left: 3px solid #4e73df; padding-left: 15px; margin-bottom: 15px; }
.field-value { padding: 8px 12px; border-radius: 4px; margin: 5px 0; cursor: pointer; transition: background-color 0.3s; }
.field-value:hover { background-color: #e3e6f0; }
.field-value.selected { background-color: #4e73df; color: white; }
.empty-value { color: #6c757d; font-style: italic; }
</style>
