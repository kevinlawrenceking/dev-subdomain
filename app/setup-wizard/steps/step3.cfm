<!---
    P11 Step 3: Import or Add Contacts
    Two paths: import from file (modal) or manual quick-add.
--->
<cfset userid = session.userid>

<!--- Get current contact count for this user --->
<cfquery name="qCount" datasource="#application.datasource#">
    SELECT COUNT(*) AS cnt
    FROM contactdetails
    WHERE userid = <cfqueryparam value="#userid#" cfsqltype="cf_sql_integer" />
      AND contactStatus = 'Active'
      AND user_yn = 'N'
</cfquery>

<cfoutput>

<!--- Tutorial --->
<div class="wizard-tutorial-toggle collapsed" data-bs-toggle="collapse" data-bs-target="##tutorial3">
    <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="6 9 12 15 18 9"/></svg>
    Why add contacts?
</div>
<div class="collapse" id="tutorial3">
    <div class="wizard-tutorial">
        Contacts are the foundation of your network in TAO. You can import a spreadsheet of existing contacts or add a few key people manually. Don't worry about getting everyone in now -- you can always import more later.
    </div>
</div>

<h3>Add a few industry contacts</h3>
<p class="step-subtitle">
    You already have <strong>#qCount.cnt#</strong> contact(s).
    Add more below or import from a file.
</p>

<!--- Mode toggle --->
<div class="wizard-mode-toggle btn-group btn-group-sm mb-3" role="group">
    <input type="radio" class="btn-check" name="contactMode" id="mode-manual" value="manual" checked>
    <label class="btn btn-outline-primary" for="mode-manual">Add Manually</label>
    <input type="radio" class="btn-check" name="contactMode" id="mode-upload" value="upload">
    <label class="btn btn-outline-primary" for="mode-upload">Import from File</label>
</div>

<!--- Manual quick-add panel --->
<div id="panel-manual" class="wizard-panel-content">
    <div id="manual-contacts">
        <div class="quick-add-row">
            <input type="text" class="form-control form-control-sm" placeholder="Full name" data-field="name" style="flex:2" />
            <select class="form-select form-select-sm" data-field="tag" style="flex:1.5">
                <option value="">-- Role --</option>
                <option value="Casting Director">Casting Director</option>
                <option value="Producer">Producer</option>
                <option value="Director">Director</option>
                <option value="Writer">Writer</option>
                <option value="Showrunner">Showrunner</option>
                <option value="Other">Other</option>
            </select>
            <input type="text" class="form-control form-control-sm" placeholder="Email or phone" data-field="emailOrPhone" style="flex:1.5" />
            <input type="text" class="form-control form-control-sm" placeholder="Company" data-field="company" style="flex:1" />
            <button type="button" class="btn-remove-row" title="Remove">&times;</button>
        </div>
        <div class="quick-add-row">
            <input type="text" class="form-control form-control-sm" placeholder="Full name" data-field="name" style="flex:2" />
            <select class="form-select form-select-sm" data-field="tag" style="flex:1.5">
                <option value="">-- Role --</option>
                <option value="Casting Director">Casting Director</option>
                <option value="Producer">Producer</option>
                <option value="Director">Director</option>
                <option value="Writer">Writer</option>
                <option value="Showrunner">Showrunner</option>
                <option value="Other">Other</option>
            </select>
            <input type="text" class="form-control form-control-sm" placeholder="Email or phone" data-field="emailOrPhone" style="flex:1.5" />
            <input type="text" class="form-control form-control-sm" placeholder="Company" data-field="company" style="flex:1" />
            <button type="button" class="btn-remove-row" title="Remove">&times;</button>
        </div>
        <div class="quick-add-row">
            <input type="text" class="form-control form-control-sm" placeholder="Full name" data-field="name" style="flex:2" />
            <select class="form-select form-select-sm" data-field="tag" style="flex:1.5">
                <option value="">-- Role --</option>
                <option value="Casting Director">Casting Director</option>
                <option value="Producer">Producer</option>
                <option value="Director">Director</option>
                <option value="Writer">Writer</option>
                <option value="Showrunner">Showrunner</option>
                <option value="Other">Other</option>
            </select>
            <input type="text" class="form-control form-control-sm" placeholder="Email or phone" data-field="emailOrPhone" style="flex:1.5" />
            <input type="text" class="form-control form-control-sm" placeholder="Company" data-field="company" style="flex:1" />
            <button type="button" class="btn-remove-row" title="Remove">&times;</button>
        </div>
    </div>
    <a href="javascript:void(0)" id="add-contact-row" class="text-primary mt-1 d-inline-block" style="font-size:14px;">
        + Add another contact
    </a>
    <span class="text-muted ms-2" style="font-size:12px;">(max 10)</span>
</div>

<!--- Import panel --->
<div id="panel-upload" class="wizard-panel-content" style="display:none;">
    <div class="wizard-dropzone" id="import-dropzone">
        <svg xmlns="http://www.w3.org/2000/svg" width="40" height="40" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"><path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"/><polyline points="17 8 12 3 7 8"/><line x1="12" y1="3" x2="12" y2="15"/></svg>
        <div>Click to open the import wizard</div>
        <div class="file-types">
            <span class="file-type-badge">CSV</span>
            <span class="file-type-badge">XLS</span>
            <span class="file-type-badge">XLSX</span>
            <span class="file-type-badge">VCF</span>
        </div>
    </div>
    <p class="text-muted mt-2" style="font-size:12px;">
        Opens the full import wizard where you can map columns, review duplicates, and finalize your import.
    </p>
</div>

<!--- Import modal (iframe) --->
<div class="modal fade" id="importModal" tabindex="-1">
    <div class="modal-dialog modal-xl modal-dialog-scrollable" style="max-width:95vw; height:90vh;">
        <div class="modal-content" style="height:90vh;">
            <div class="modal-header py-2">
                <h6 class="modal-title">Import Contacts</h6>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body p-0">
                <iframe id="import-iframe" src="" style="width:100%; height:100%; border:none;"></iframe>
            </div>
        </div>
    </div>
</div>

<script>
// Mode toggle
$('input[name="contactMode"]').on('change', function() {
    var mode = $(this).val();
    $('##panel-upload').toggle(mode === 'upload');
    $('##panel-manual').toggle(mode === 'manual');
});

// Import dropzone -> open modal iframe
$('##import-dropzone').on('click', function() {
    $('##import-iframe').attr('src', '/include/import-contacts-v3.cfm?embedded=1');
    var modal = new bootstrap.Modal(document.getElementById('importModal'));
    modal.show();
});

$('##importModal').on('hidden.bs.modal', function() {
    $('##import-iframe').attr('src', '');
    // MIGRATE: In Go/Flutter, replace with a proper callback from the import flow
});

// Add manual contact row
$('##add-contact-row').on('click', function() {
    var rows = $('##manual-contacts .quick-add-row');
    if (rows.length >= 10) {
        taoToast('Maximum 10 manual contacts per step', 'warning');
        return;
    }
    var html =
        '<div class="quick-add-row">' +
        '<input type="text" class="form-control form-control-sm" placeholder="Full name" data-field="name" style="flex:2" />' +
        '<select class="form-select form-select-sm" data-field="tag" style="flex:1.5">' +
        '<option value="">-- Role --</option>' +
        '<option value="Casting Director">Casting Director</option>' +
        '<option value="Producer">Producer</option>' +
        '<option value="Director">Director</option>' +
        '<option value="Writer">Writer</option>' +
        '<option value="Showrunner">Showrunner</option>' +
        '<option value="Other">Other</option>' +
        '</select>' +
        '<input type="text" class="form-control form-control-sm" placeholder="Email or phone" data-field="emailOrPhone" style="flex:1.5" />' +
        '<input type="text" class="form-control form-control-sm" placeholder="Company" data-field="company" style="flex:1" />' +
        '<button type="button" class="btn-remove-row" title="Remove">&times;</button>' +
        '</div>';
    $('##manual-contacts').append(html);
});

$(document).on('click', '.btn-remove-row', function() {
    var rows = $('##manual-contacts .quick-add-row');
    if (rows.length > 1) $(this).closest('.quick-add-row').remove();
});

window.wizardCollectStepData = function() {
    var contacts = [];
    $('##manual-contacts .quick-add-row').each(function() {
        var $r = $(this);
        var name = $r.find('[data-field="name"]').val().trim();
        if (!name) return;
        contacts.push({
            name: name,
            tag: $r.find('[data-field="tag"]').val(),
            emailOrPhone: $r.find('[data-field="emailOrPhone"]').val().trim(),
            company: $r.find('[data-field="company"]').val().trim()
        });
    });
    return { contacts: JSON.stringify(contacts) };
};
</script>

</cfoutput>
