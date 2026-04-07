<!---
    P11 Step 2: Add Your Representation
    Quick-add agent, manager, or publicist contacts.
--->
<cfset userid = session.userid>

<!--- Check for existing rep team contacts (for re-entry pre-fill) --->
<cfquery name="qExistingReps" datasource="#application.datasource#">
    SELECT cd.contactid, cd.contactFullName, cd.contactTitle,
           (SELECT ci.valuetext FROM contactitems ci
            WHERE ci.contactid = cd.contactid AND ci.valueCategory = 'Email'
              AND ci.primary_yn = 'Y' AND ci.itemStatus = 'Active' LIMIT 1) AS repEmail,
           (SELECT ci.valuetext FROM contactitems ci
            WHERE ci.contactid = cd.contactid AND ci.valueCategory = 'Phone'
              AND ci.primary_yn = 'Y' AND ci.itemStatus = 'Active' LIMIT 1) AS repPhone,
           (SELECT ci.valueCompany FROM contactitems ci
            WHERE ci.contactid = cd.contactid AND ci.valueCategory = 'Company'
              AND ci.itemStatus = 'Active' LIMIT 1) AS repCompany
    FROM contactdetails cd
    INNER JOIN contactitems ci2 ON ci2.contactid = cd.contactid
        AND ci2.valueCategory = 'Tag' AND ci2.valueType = 'Tags'
        AND ci2.valuetext = 'My Rep Team' AND ci2.itemStatus = 'Active'
    WHERE cd.userid = <cfqueryparam value="#userid#" cfsqltype="cf_sql_integer" />
      AND cd.contactStatus = 'Active'
    GROUP BY cd.contactid
    ORDER BY cd.contactFullName
</cfquery>

<cfoutput>

<!--- Tutorial --->
<div class="wizard-tutorial-toggle collapsed" data-bs-toggle="collapse" data-bs-target="##tutorial2">
    <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="6 9 12 15 18 9"/></svg>
    Why add representation?
</div>
<div class="collapse" id="tutorial2">
    <div class="wizard-tutorial">
        Your agent, manager, and publicist are key contacts you'll interact with regularly. Adding them now means TAO can help you track communications and set up relationship reminders for them.
    </div>
</div>

<h3>Who represents you?</h3>
<p class="step-subtitle">Add your agent, manager, or publicist. You can add more later.</p>

<div id="rep-cards">
    <cfif qExistingReps.recordCount>
        <!--- Pre-fill existing reps --->
        <cfloop query="qExistingReps">
            <div class="rep-card" data-existing-id="#qExistingReps.contactid#">
                <button type="button" class="rep-remove" title="Remove">&times;</button>
                <div class="row g-2">
                    <div class="col-12 mb-2">
                        <div class="rep-role-group btn-group btn-group-sm" role="group">
                            <input type="radio" class="btn-check" name="role_#currentRow#" value="Agent" id="role_#currentRow#_a" #qExistingReps.contactTitle EQ 'Agent' ? 'checked' : ''#>
                            <label class="btn btn-outline-primary" for="role_#currentRow#_a">Agent</label>
                            <input type="radio" class="btn-check" name="role_#currentRow#" value="Manager" id="role_#currentRow#_m" #qExistingReps.contactTitle EQ 'Manager' ? 'checked' : ''#>
                            <label class="btn btn-outline-primary" for="role_#currentRow#_m">Manager</label>
                            <input type="radio" class="btn-check" name="role_#currentRow#" value="Publicist" id="role_#currentRow#_p" #qExistingReps.contactTitle EQ 'Publicist' ? 'checked' : ''#>
                            <label class="btn btn-outline-primary" for="role_#currentRow#_p">Publicist</label>
                        </div>
                    </div>
                    <div class="col-md-6">
                        <input type="text" class="form-control form-control-sm" placeholder="Full name" value="#encodeForHTMLAttribute(qExistingReps.contactFullName)#" data-field="name" />
                    </div>
                    <div class="col-md-6">
                        <input type="text" class="form-control form-control-sm" placeholder="Company / Agency" value="#encodeForHTMLAttribute(len(qExistingReps.repCompany) ? qExistingReps.repCompany : '')#" data-field="company" />
                    </div>
                    <div class="col-md-6">
                        <input type="tel" class="form-control form-control-sm" placeholder="Phone" value="#encodeForHTMLAttribute(len(qExistingReps.repPhone) ? qExistingReps.repPhone : '')#" data-field="phone" />
                    </div>
                    <div class="col-md-6">
                        <input type="email" class="form-control form-control-sm" placeholder="Email" value="#encodeForHTMLAttribute(len(qExistingReps.repEmail) ? qExistingReps.repEmail : '')#" data-field="email" />
                    </div>
                </div>
            </div>
        </cfloop>
    <cfelse>
        <!--- Default: one empty card --->
        <div class="rep-card">
            <button type="button" class="rep-remove" title="Remove" style="display:none;">&times;</button>
            <div class="row g-2">
                <div class="col-12 mb-2">
                    <div class="rep-role-group btn-group btn-group-sm" role="group">
                        <input type="radio" class="btn-check" name="role_1" value="Agent" id="role_1_a" checked>
                        <label class="btn btn-outline-primary" for="role_1_a">Agent</label>
                        <input type="radio" class="btn-check" name="role_1" value="Manager" id="role_1_m">
                        <label class="btn btn-outline-primary" for="role_1_m">Manager</label>
                        <input type="radio" class="btn-check" name="role_1" value="Publicist" id="role_1_p">
                        <label class="btn btn-outline-primary" for="role_1_p">Publicist</label>
                    </div>
                </div>
                <div class="col-md-6">
                    <input type="text" class="form-control form-control-sm" placeholder="Full name" data-field="name" />
                </div>
                <div class="col-md-6">
                    <input type="text" class="form-control form-control-sm" placeholder="Company / Agency" data-field="company" />
                </div>
                <div class="col-md-6">
                    <input type="tel" class="form-control form-control-sm" placeholder="Phone" data-field="phone" />
                </div>
                <div class="col-md-6">
                    <input type="email" class="form-control form-control-sm" placeholder="Email" data-field="email" />
                </div>
            </div>
        </div>
    </cfif>
</div>

<div class="mt-2">
    <a href="javascript:void(0)" id="add-rep-card" class="text-primary" style="font-size:14px;">
        + Add another
    </a>
    <span class="text-muted ms-2" style="font-size:12px;">(max 5)</span>
</div>

<script>
var repCounter = #max(qExistingReps.recordCount, 1)#;

$('##add-rep-card').on('click', function() {
    var cards = $('##rep-cards .rep-card');
    if (cards.length >= 5) {
        taoToast('Maximum 5 representatives', 'warning');
        return;
    }
    repCounter++;
    var html =
        '<div class="rep-card">' +
        '<button type="button" class="rep-remove" title="Remove">&times;</button>' +
        '<div class="row g-2">' +
        '<div class="col-12 mb-2">' +
        '<div class="rep-role-group btn-group btn-group-sm" role="group">' +
        '<input type="radio" class="btn-check" name="role_' + repCounter + '" value="Agent" id="role_' + repCounter + '_a" checked>' +
        '<label class="btn btn-outline-primary" for="role_' + repCounter + '_a">Agent</label>' +
        '<input type="radio" class="btn-check" name="role_' + repCounter + '" value="Manager" id="role_' + repCounter + '_m">' +
        '<label class="btn btn-outline-primary" for="role_' + repCounter + '_m">Manager</label>' +
        '<input type="radio" class="btn-check" name="role_' + repCounter + '" value="Publicist" id="role_' + repCounter + '_p">' +
        '<label class="btn btn-outline-primary" for="role_' + repCounter + '_p">Publicist</label>' +
        '</div></div>' +
        '<div class="col-md-6"><input type="text" class="form-control form-control-sm" placeholder="Full name" data-field="name" /></div>' +
        '<div class="col-md-6"><input type="text" class="form-control form-control-sm" placeholder="Company / Agency" data-field="company" /></div>' +
        '<div class="col-md-6"><input type="tel" class="form-control form-control-sm" placeholder="Phone" data-field="phone" /></div>' +
        '<div class="col-md-6"><input type="email" class="form-control form-control-sm" placeholder="Email" data-field="email" /></div>' +
        '</div></div>';
    $('##rep-cards').append(html);
    updateRemoveButtons();
});

$(document).on('click', '.rep-remove', function() {
    $(this).closest('.rep-card').remove();
    updateRemoveButtons();
});

function updateRemoveButtons() {
    var cards = $('##rep-cards .rep-card');
    cards.find('.rep-remove').toggle(cards.length > 1);
}

window.wizardCollectStepData = function() {
    var reps = [];
    $('##rep-cards .rep-card').each(function() {
        var $c = $(this);
        var name = $c.find('[data-field="name"]').val().trim();
        if (!name) return; // skip empty
        reps.push({
            role: $c.find('.btn-check:checked').val() || 'Agent',
            name: name,
            company: $c.find('[data-field="company"]').val().trim(),
            phone: $c.find('[data-field="phone"]').val().trim(),
            email: $c.find('[data-field="email"]').val().trim()
        });
    });
    return { reps: JSON.stringify(reps) };
};
</script>

</cfoutput>
