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

<div class="wizard-two-panel">

    <!--- Import panel --->
    <div class="panel-import">
        <h6 class="text-muted mb-2">Import from file</h6>
        <div class="wizard-dropzone" id="import-dropzone">
            <svg xmlns="http://www.w3.org/2000/svg" width="40" height="40" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"><path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"/><polyline points="17 8 12 3 7 8"/><line x1="12" y1="3" x2="12" y2="15"/></svg>
            <div>Drag and drop a file here, or click to browse</div>
            <div class="file-types">
                <span class="file-type-badge">CSV</span>
                <span class="file-type-badge">XLS</span>
                <span class="file-type-badge">XLSX</span>
                <span class="file-type-badge">VCF</span>
            </div>
            <input type="file" id="import-file-input" accept=".csv,.xls,.xlsx,.vcf" style="display:none;" />
        </div>
        <p class="text-muted mt-2" style="font-size:12px;">
            Opens the full import wizard in a popup window.
        </p>
    </div>

    <!--- Divider --->
    <div class="panel-divider">or</div>

    <!--- Manual quick-add panel --->
    <div class="panel-manual">
        <h6 class="text-muted mb-2">Add manually</h6>
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

</div>

<script>
// Import dropzone click
$('##import-dropzone').on('click', function() {
    $('##import-file-input').trigger('click');
});

// Drag and drop
$('##import-dropzone').on('dragover', function(e) {
    e.preventDefault();
    $(this).addClass('dragover');
}).on('dragleave drop', function(e) {
    e.preventDefault();
    $(this).removeClass('dragover');
});

$('##import-dropzone').on('drop', function(e) {
    var files = e.originalEvent.dataTransfer.files;
    if (files.length) handleImportFile(files[0]);
});

$('##import-file-input').on('change', function() {
    if (this.files.length) handleImportFile(this.files[0]);
});

function handleImportFile(file) {
    // TECH-DEBT: Opens import-contacts-v3 in a new window instead of a modal
    // because the import flow has its own complex state machine.
    // In the Go/Flutter rewrite, this should be a proper modal or inline flow.
    taoToast('Opening import wizard...', 'info');
    var importUrl = '/app/contacts/?action=import';
    window.open(importUrl, 'tao_import', 'width=900,height=700,scrollbars=yes');
}

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
