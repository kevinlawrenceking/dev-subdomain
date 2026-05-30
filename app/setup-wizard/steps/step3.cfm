<!---
    P11 Step 3: Add Contacts (manual quick-add only).
    Bulk import removed from setup 2026-05-30; it now lives on the post-setup
    Contacts page. Save path: ajax/setup-wizard/save-step3.cfm.
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
        Contacts are the foundation of your network in TAO. Add a few key people manually here. Don't worry about getting everyone in now -- you can always add more later.
    </div>
</div>

<h3>Add a few industry contacts</h3>
<p class="step-subtitle">
    You already have <strong>#qCount.cnt#</strong> contact(s).
    Add a few key people below.
</p>

<!--- Manual quick-add panel (bulk import lives on the Contacts page, post-setup) --->
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

<!--- Bulk import is available from the Contacts page after setup. --->
<p class="text-muted mt-3" style="font-size:13px;">
    Have a spreadsheet or phone contacts to bring in? You'll be able to bulk-import them from the Contacts page once setup is finished.
</p>

<script>
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
