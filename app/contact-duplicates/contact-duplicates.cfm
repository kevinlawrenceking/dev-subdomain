<!---
    PURPOSE: Contact duplicate detection and management interface
    AUTHOR: Kevin King
    DATE: 2025-08-07
    PARAMETERS: userid (from session)
    DEPENDENCIES: ContactDuplicateService, Bootstrap 5, jQuery, DataTables
--->

<cfparam name="duplicateType" default="name" />
<cfparam name="action" default="list" />

<!--- Initialize service --->
<cfset duplicateService = createObject("component", "services.ContactDuplicateService") />

<!--- Handle actions --->
<cfif action eq "merge" and isDefined('form.primaryContactId') and isDefined('form.duplicateContactId')>
    <cfset mergeResult = duplicateService.mergeContacts(
        primaryContactId = form.primaryContactId,
        duplicateContactId = form.duplicateContactId,
        mergeData = form.mergeData,
        userid = userid
    ) />
    
    <cfif mergeResult.success>
        <cfset showAlert = {type: "success", message: "Contacts merged successfully!"} />
    <cfelse>
        <cfset showAlert = {type: "danger", message: mergeResult.message} />
    </cfif>
</cfif>

<!--- Get duplicate data based on type --->
<cfif duplicateType eq "name">
    <cfset duplicates = duplicateService.findDuplicatesByName(userid) />
    <cfset pageTitle = "Duplicate Contacts by Name" />
<cfelse>
    <cfset duplicates = duplicateService.findDuplicatesByEmail(userid) />
    <cfset pageTitle = "Duplicate Contacts by Email" />
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

<!--- Alert Messages --->
<cfif isDefined('showAlert')>
    <div class="alert alert-<cfoutput>#showAlert.type#</cfoutput> alert-dismissible fade show" role="alert">
        <cfoutput>#showAlert.message#</cfoutput>
        <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
    </div>
</cfif>

<!--- Navigation Tabs --->
<div class="card">
    <div class="card-body">
        <ul class="nav nav-pills navtab-bg nav-justified mb-3" role="tablist">
            <li class="nav-item">
                <a href="?duplicateType=name" class="nav-link<cfif duplicateType eq 'name'> active</cfif>">
                    Duplicates by Name
                </a>
            </li>
            <li class="nav-item">
                <a href="?duplicateType=email" class="nav-link<cfif duplicateType eq 'email'> active</cfif>">
                    Duplicates by Email
                </a>
            </li>
        </ul>

        <!--- Duplicates Table --->
        <cfif duplicates.recordcount gt 0>
            <div class="table-responsive">
                <table id="duplicatesTable" class="table table-striped table-bordered dt-responsive nowrap w-100">
                    <thead>
                        <tr>
                            <cfif duplicateType eq "name">
                                <th>First Name</th>
                                <th>Last Name</th>
                            <cfelse>
                                <th>Email Address</th>
                                <th>Contact Names</th>
                            </cfif>
                            <th>Duplicate Count</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <cfloop query="duplicates">
                            <tr>
                                <cfif duplicateType eq "name">
                                    <td><cfoutput>#contactfirst#</cfoutput></td>
                                    <td><cfoutput>#contactlast#</cfoutput></td>
                                <cfelse>
                                    <td><cfoutput>#email#</cfoutput></td>
                                    <td><cfoutput>#replace(contact_names, '|', '<br>', 'all')#</cfoutput></td>
                                </cfif>
                                <td><span class="badge bg-warning"><cfoutput>#duplicate_count#</cfoutput></span></td>
                                <td>
                                    <button type="button" class="btn btn-primary btn-sm" 
                                            onclick="showMergeModal('<cfoutput>#contact_ids#</cfoutput>', '<cfoutput>#duplicateType#</cfoutput>')">
                                        <i class="fe-shuffle"></i> Merge
                                    </button>
                                </td>
                            </tr>
                        </cfloop>
                    </tbody>
                </table>
            </div>
        <cfelse>
            <div class="text-center py-5">
                <i class="fe-users text-muted" style="font-size: 48px;"></i>
                <h5 class="text-muted mt-3">No Duplicates Found</h5>
                <p class="text-muted">
                    <cfif duplicateType eq "name">
                        No contacts with matching names were found.
                    <cfelse>
                        No contacts with matching email addresses were found.
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
                <h4 class="modal-title" id="mergeModalTitle">Merge Duplicate Contacts</h4>
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

<!--- JavaScript --->
<script>
document.addEventListener("DOMContentLoaded", function() {
    // Initialize DataTable
    if (document.getElementById('duplicatesTable')) {
        $('#duplicatesTable').DataTable({
            responsive: true,
            pageLength: 25,
            order: [[2, 'desc']], // Sort by duplicate count
            columnDefs: [
                { orderable: false, targets: -1 } // Disable sorting for actions column
            ]
        });
    }
});

function showMergeModal(contactIds, duplicateType) {
    const modal = new bootstrap.Modal(document.getElementById('mergeModal'));
    
    // Load merge interface
    $('#mergeContent').load('/include/merge_contacts_interface.cfm', {
        contactIds: contactIds,
        duplicateType: duplicateType,
        userid: <cfoutput>#userid#</cfoutput>
    }, function() {
        modal.show();
    });
}
</script>

<style>
.contact-card {
    border: 2px solid #e3e6f0;
    transition: border-color 0.3s;
}

.contact-card.selected {
    border-color: #4e73df;
    background-color: #f8f9fc;
}

.field-comparison {
    border-left: 3px solid #4e73df;
    padding-left: 15px;
    margin-bottom: 15px;
}

.field-value {
    padding: 8px 12px;
    border-radius: 4px;
    margin: 5px 0;
    cursor: pointer;
    transition: background-color 0.3s;
}

.field-value:hover {
    background-color: #e3e6f0;
}

.field-value.selected {
    background-color: #4e73df;
    color: white;
}

.empty-value {
    color: #6c757d;
    font-style: italic;
}
</style>
