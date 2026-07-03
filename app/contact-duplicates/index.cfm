<!---
    PURPOSE: Contact duplicate detection + merge management UI (per user).
    AUTHOR:  Kevin King
    DATE:    2026-06-25
    ACCESS:  /app/contact-duplicates/  (any logged-in user; scoped to their own contacts)
    PATTERN: Self-contained page (same approach as /app/admin-analytics/) -- renders
             its own shell + assets instead of the core.cfm / pgpages registry, so it
             works without a DB page-registry row.
    DEPENDENCIES: services.ContactDuplicateService, Bootstrap 5, jQuery, DataTables.
--->
<cfif NOT structKeyExists(session, "userid")>
    <cflocation url="/loginform.cfm" addtoken="false">
</cfif>
<cfset userid = session.userid />

<cfparam name="duplicateType" default="full" />
<cfparam name="action"        default="list" />

<cfset duplicateService = createObject("component", "services.ContactDuplicateService").init() />

<!--- Handle merge submit. The merge form carries a csrfToken field validated by /app/Application.cfc. --->
<!--- Reference form.* explicitly: this server has implicit scope search disabled,
      so unscoped "action" would resolve to the cfparam default, not the posted value. --->
<cfif structKeyExists(form, "action") AND form.action EQ "merge"
      AND structKeyExists(form, "primaryContactId") AND structKeyExists(form, "duplicateContactId")>
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
        <cfset session.cd_flash = { type: "success", message: "Contacts merged successfully. (merge ##" & mergeResult.mergeid & ")" } />
    <cfelse>
        <cfset session.cd_flash = { type: "danger", message: mergeResult.message } />
    </cfif>
    <!--- Post/Redirect/Get: redirect to a clean GET URL so a refresh cannot re-submit the merge --->
    <cflocation url="/app/contact-duplicates/" addtoken="false" />
</cfif>

<!--- Handle "Not a match" dismissal (ticket 5B). Same PRG + CSRF pattern as merge.
      Reference form.* explicitly (implicit scope search is disabled on this server). --->
<cfif structKeyExists(form, "action") AND form.action EQ "dismiss"
      AND structKeyExists(form, "id_a") AND structKeyExists(form, "id_b")>
    <cfset dismissResult = duplicateService.dismissDuplicatePair(
        userid     = userid,
        contactIdA = val(form.id_a),
        contactIdB = val(form.id_b)
    ) />
    <cfif dismissResult.success>
        <cfset session.cd_flash = { type: "success", message: "Removed from the list. These two contacts will not be compared again." } />
    <cfelse>
        <cfset session.cd_flash = { type: "danger", message: dismissResult.message } />
    </cfif>
    <cflocation url="/app/contact-duplicates/" addtoken="false" />
</cfif>

<!--- One-time flash message from a prior merge (set just before the PRG redirect) --->
<cfif structKeyExists(session, "cd_flash")>
    <cfset showAlert = session.cd_flash />
    <cfset structDelete(session, "cd_flash") />
</cfif>

<!--- Full-duplicates tab hidden 2026-06-25 (users had no action to take on it).
      findFullDuplicates() is retained in the service; to re-enable, restore the
      nav tabs below and the duplicateType branch here. --->
<cfset duplicateType = "possible" />
<cfset duplicates = duplicateService.findPossibleDuplicates(userid) />
<cfset pageHeading = "Possible duplicate contacts" />

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Duplicate Contacts | TAO</title>
    <link href="/app/assets/css/bootstrap.css" rel="stylesheet">
    <link href="/app/assets/css/icons.min.css" rel="stylesheet">
    <link href="/app/assets/css/app.min.css" rel="stylesheet">
    <link href="/app/assets/css/datatables.min.css" rel="stylesheet">
    <cfif structKeyExists(session, "csrfToken")>
        <cfoutput><meta name="csrf-token" content="#session.csrfToken#"></cfoutput>
    </cfif>
    <style>
        .cd-banner { background-color: #406e8e; padding: 12px 20px; }
        .cd-banner-inner { display:flex; align-items:center; justify-content:space-between; }
        .cd-logo { height: 28px; }
        .cd-content { padding: 20px; }
        .contact-card { border: 2px solid #e3e6f0; transition: border-color 0.2s; }
        .contact-card.is-primary   { border-color: #4e73df; background-color: #f8f9fc; }
        .contact-card.is-duplicate { border-color: #e74a3b; background-color: #fff5f5; }
        .field-comparison { border-left: 3px solid #4e73df; padding-left: 15px; margin-bottom: 15px; }
        .field-value { padding: 8px 12px; border-radius: 4px; margin: 5px 0; cursor: pointer; transition: background-color 0.2s; }
        .field-value:hover { background-color: #e3e6f0; }
        .field-value.selected { background-color: #4e73df; color: white; }
        .empty-value { color: #6c757d; font-style: italic; }
    </style>
</head>
<body>

<div class="cd-banner">
    <div class="cd-banner-inner">
        <img src="/app/assets/images/logo-light.png" class="cd-logo" alt="The Actor's Office">
        <a href="/app/" class="btn btn-light btn-sm">Return to Dashboard</a>
    </div>
</div>

<div class="container-fluid cd-content">

    <div class="row align-items-end mb-3">
        <div class="col">
            <h1 class="h4 mb-1"><cfoutput>#encodeForHtml(pageHeading)#</cfoutput></h1>
            <p class="text-muted mb-0">Duplicates are scoped to your own contacts.</p>
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
<!--- Tabs hidden 2026-06-25: showing Possible duplicates only. Restore to bring back Full.
            <ul class="nav nav-pills nav-justified mb-3" role="tablist">
                <li class="nav-item">
                    <a href="?duplicateType=full" class="nav-link<cfif duplicateType EQ 'full'> active</cfif>">Full duplicates</a>
                </li>
                <li class="nav-item">
                    <a href="?duplicateType=possible" class="nav-link<cfif duplicateType EQ 'possible'> active</cfif>">Possible duplicates</a>
                </li>
            </ul>
            --->

            <cfif duplicates.recordCount GT 0>
                <div class="table-responsive">
                    <table id="duplicatesTable" class="table table-striped table-bordered nowrap w-100">
                        <thead>
                            <tr>
                                <cfif duplicateType EQ "possible">
                                    <th>Contact A</th><th>Contact B</th><th>Action</th>
                                <cfelse>
                                    <th>Match type</th><th>Matched value</th><th>Contacts</th><th>Count</th><th>Action</th>
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
                                            <!--- Ticket 5B: dismiss a wrong pairing so it never returns to the list --->
                                            <form method="post" action="/app/contact-duplicates/" style="display:inline"
                                                  onsubmit="return confirm('Mark these two as NOT a match? They will be removed from this list and not compared again.');">
                                                <cfif structKeyExists(session, "csrfToken")>
                                                    <input type="hidden" name="csrfToken" value="#session.csrfToken#" />
                                                </cfif>
                                                <input type="hidden" name="action" value="dismiss" />
                                                <input type="hidden" name="id_a" value="#id_a#" />
                                                <input type="hidden" name="id_b" value="#id_b#" />
                                                <button type="submit" class="btn btn-outline-secondary btn-sm">
                                                    <i class="fe-x-circle"></i> Not a match
                                                </button>
                                            </form>
                                        </td>
                                    <cfelse>
                                        <td><span class="badge bg-info">#encodeForHtml(match_type)#</span></td>
                                        <td>#encodeForHtml(match_key)#</td>
                                        <td>#replace(encodeForHtml(names), ' | ', '<br>', 'all')#</td>
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
                    <i class="fe-users text-muted" style="font-size:48px;"></i>
                    <h5 class="text-muted mt-3">No duplicates found</h5>
                    <p class="text-muted">
                        <cfif duplicateType EQ "possible">No contacts with similar names were found.
                        <cfelse>No contacts share an email, phone, or exact name.</cfif>
                    </p>
                </div>
            </cfif>
        </div>
    </div>
</div>

<!--- Merge modal --->
<div id="mergeModal" class="modal fade" tabindex="-1" role="dialog" aria-hidden="true">
    <div class="modal-dialog modal-xl">
        <div class="modal-content">
            <div class="modal-header">
                <h4 class="modal-title">Merge duplicate contacts</h4>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body">
                <div id="mergeContent">
                    <div class="text-center">
                        <div class="spinner-border text-primary" role="status"><span class="visually-hidden">Loading...</span></div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<script src="/app/assets/js/jquery-3.6.0.min.js"></script>
<script src="/app/assets/js/datatables.min.js"></script>
<script src="/app/assets/js/bootstrap.bundle.js"></script>
<script>
// Send CSRF header on AJAX (the merge modal is loaded by GET, but keep this for safety)
(function(){
    var meta = document.querySelector('meta[name="csrf-token"]');
    if (meta && typeof jQuery !== 'undefined') {
        jQuery.ajaxSetup({ beforeSend: function(xhr, s){ if (s.type && s.type !== 'GET') xhr.setRequestHeader('X-CSRF-Token', meta.getAttribute('content')); } });
    }
})();

$(function(){
    if (document.getElementById('duplicatesTable') && $.fn.DataTable) {
        $('#duplicatesTable').DataTable({ pageLength: 25, order: [], columnDefs: [{ orderable: false, targets: -1 }] });
    }
});

function showMergeModal(contactIds) {
    var modal = new bootstrap.Modal(document.getElementById('mergeModal'));
    // GET load so the include's inline <script> executes (jQuery .load runs scripts) and no CSRF is needed
    $('#mergeContent').load('/include/merge_contacts_interface.cfm?contactIds=' + encodeURIComponent(contactIds), function(){
        modal.show();
    });
}
</script>
</body>
</html>
