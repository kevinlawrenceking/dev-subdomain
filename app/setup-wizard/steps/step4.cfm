<!---
    P11 Step 4: Add Auditions (manual quick-add only).
    Bulk import removed from setup 2026-05-30; audition import lives on the
    post-setup Auditions page.
    Audition module is universally enabled (TECH-DEBT: isauditionmodule gating removed 2026-04).
    TECH-DEBT: save-step4 inlines INSERT to avoid cookie.userid in INSaudprojects(). Main app still uses cookie path.
--->
<cfset userid = session.userid>

<!--- Audition category picklist. Wizard shows 7 categories; value is the
      "Other" subcategory's audsubcatid so one field captures both category
      (derivable via JOIN) and a valid, generic subcategory. audcatid comes
      along so the UI can cascade role types (category-scoped) off the choice. --->
<cfquery name="qCatOptions" datasource="#application.datasource#">
    SELECT s.audsubcatid, c.audcatid, c.audcatname
    FROM audcategories c
    INNER JOIN audsubcategories s ON s.audcatid = c.audcatid
    WHERE s.audSubCatName = <cfqueryparam value="Other" cfsqltype="cf_sql_varchar" />
    ORDER BY c.audcatname
</cfquery>

<!--- Role types for every category shown above. audroletypes is category-scoped
      (audroletypes.audcatid), so the UI filters this list by the selected
      category to populate the (now required) Role type dropdown. --->
<cfquery name="qRoleTypes" datasource="#application.datasource#">
    SELECT rt.audroletypeid, rt.audroletype, rt.audcatid
    FROM audroletypes rt
    WHERE rt.isDeleted = 0
      AND rt.audcatid IN (
          SELECT c.audcatid
          FROM audcategories c
          INNER JOIN audsubcategories s ON s.audcatid = c.audcatid
          WHERE s.audSubCatName = <cfqueryparam value="Other" cfsqltype="cf_sql_varchar" />
      )
    ORDER BY rt.audcatid, rt.audroletype
</cfquery>

<cfoutput>

<!--- Tutorial --->
<div class="wizard-tutorial-toggle collapsed" data-bs-toggle="collapse" data-bs-target="##tutorial4">
    <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="6 9 12 15 18 9"/></svg>
    Why track auditions?
</div>
<div class="collapse" id="tutorial4">
    <div class="wizard-tutorial">
        Tracking auditions helps you see patterns in your career -- which casting directors call you back, what types of roles you book, and how your audition frequency changes over time.
    </div>
</div>

<h3>Log a few recent auditions</h3>
<p class="step-subtitle">Add a few auditions you've had recently.</p>

<!--- Manual quick-add (bulk import lives on the Auditions page, post-setup).
      Role and Role type are required for each audition; Role type cascades from
      the selected Category (role types are category-scoped). --->
<div class="panel-manual">
        <div id="manual-auditions">
            <div class="audition-entry border rounded p-3 mb-2">
                <div class="row g-2">
                    <div class="col-md-6">
                        <input type="text" class="form-control form-control-sm" placeholder="Project name" data-field="projectName" />
                    </div>
                    <div class="col-md-6">
                        <select class="form-select form-select-sm" data-field="audsubcatid">
                            <option value="">-- Category --</option>
                            <cfloop query="qCatOptions">
                                <option value="#qCatOptions.audsubcatid#">#encodeForHTML(qCatOptions.audcatname)#</option>
                            </cfloop>
                        </select>
                    </div>
                    <div class="col-md-6">
                        <input type="text" class="form-control form-control-sm" placeholder="Role / character *" data-field="roleName" />
                    </div>
                    <div class="col-md-6">
                        <select class="form-select form-select-sm" data-field="audroletypeid" disabled>
                            <option value="">-- Select category first --</option>
                        </select>
                    </div>
                    <div class="col-md-6">
                        <input type="text" class="form-control form-control-sm" placeholder="Casting director" data-field="castingDirector" />
                    </div>
                    <div class="col-md-6">
                        <input type="date" class="form-control form-control-sm" data-field="audDate" />
                    </div>
                    <div class="col-12">
                        <textarea class="form-control form-control-sm" placeholder="Notes (optional)" data-field="notes" rows="2" maxlength="500"></textarea>
                    </div>
                </div>
            </div>
        </div>
        <a href="javascript:void(0)" id="add-audition-entry" class="text-primary mt-1 d-inline-block" style="font-size:14px;">
            + Add another audition
        </a>
    </div>

    <p class="text-muted mt-3" style="font-size:13px;">
        Have a stack of auditions to bring in? You'll be able to bulk-import them from the Auditions page once setup is finished.
    </p>

<script>
// Pre-build category options for dynamic rows. Value is audsubcatid ("Other"
// subcategory); visible label is the category name.
var categoryOptions = '<option value="">-- Category --</option>' +
    <cfloop query="qCatOptions">'<option value="#qCatOptions.audsubcatid#">#encodeForJavaScript(qCatOptions.audcatname)#</option>' +
    </cfloop>'';

// audsubcatid -> audcatid, so a chosen Category maps to its role-type set.
var subcatToCat = {};
<cfloop query="qCatOptions">subcatToCat['#qCatOptions.audsubcatid#'] = '#qCatOptions.audcatid#';
</cfloop>

// audcatid -> [{id, name}] role types (category-scoped).
var roleTypesByCat = {};
function _addRoleType(cat, id, name) {
    (roleTypesByCat[cat] = roleTypesByCat[cat] || []).push({ id: id, name: name });
}
<cfloop query="qRoleTypes">_addRoleType('#qRoleTypes.audcatid#', '#qRoleTypes.audroletypeid#', '#encodeForJavaScript(qRoleTypes.audroletype)#');
</cfloop>

function _escapeHtml(s) {
    return $('<div>').text(s == null ? '' : String(s)).html();
}

// Build the <option> list for the Role type dropdown of a given category.
function buildRoleTypeOptions(audcatid) {
    var opts = '<option value="">-- Role type * --</option>';
    var list = roleTypesByCat[audcatid] || [];
    for (var i = 0; i < list.length; i++) {
        opts += '<option value="' + list[i].id + '">' + _escapeHtml(list[i].name) + '</option>';
    }
    return opts;
}

// Cascade: when Category changes, repopulate that entry's Role type dropdown.
$('##manual-auditions').on('change', '[data-field="audsubcatid"]', function() {
    var $rt = $(this).closest('.audition-entry').find('[data-field="audroletypeid"]');
    var cat = subcatToCat[$(this).val()];
    $rt.removeClass('is-invalid');
    if (cat) {
        $rt.html(buildRoleTypeOptions(cat)).prop('disabled', false);
    } else {
        $rt.html('<option value="">-- Select category first --</option>').prop('disabled', true);
    }
});

$('##add-audition-entry').on('click', function() {
    var entries = $('##manual-auditions .audition-entry');
    if (entries.length >= 5) {
        taoToast('Maximum 5 auditions in this step', 'warning');
        return;
    }
    var html =
        '<div class="audition-entry border rounded p-3 mb-2">' +
        '<div class="row g-2">' +
        '<div class="col-md-6"><input type="text" class="form-control form-control-sm" placeholder="Project name" data-field="projectName" /></div>' +
        '<div class="col-md-6"><select class="form-select form-select-sm" data-field="audsubcatid">' + categoryOptions + '</select></div>' +
        '<div class="col-md-6"><input type="text" class="form-control form-control-sm" placeholder="Role / character *" data-field="roleName" /></div>' +
        '<div class="col-md-6"><select class="form-select form-select-sm" data-field="audroletypeid" disabled><option value="">-- Select category first --</option></select></div>' +
        '<div class="col-md-6"><input type="text" class="form-control form-control-sm" placeholder="Casting director" data-field="castingDirector" /></div>' +
        '<div class="col-md-6"><input type="date" class="form-control form-control-sm" data-field="audDate" /></div>' +
        '<div class="col-12"><textarea class="form-control form-control-sm" placeholder="Notes (optional)" data-field="notes" rows="2" maxlength="500"></textarea></div>' +
        '</div></div>';
    $('##manual-auditions').append(html);
});

window.wizardCollectStepData = function() {
    var auditions = [];
    var invalid = false;
    $('##manual-auditions .audition-entry').each(function() {
        var $e = $(this);
        var name = $e.find('[data-field="projectName"]').val().trim();
        // Blank rows (no project name) are skipped — the step stays optional.
        if (!name) return;

        var $role = $e.find('[data-field="roleName"]');
        var $roleType = $e.find('[data-field="audroletypeid"]');
        var roleName = $role.val().trim();
        var roleTypeId = $roleType.val();

        // Role and Role type are required once a project name is entered.
        $role.removeClass('is-invalid');
        $roleType.removeClass('is-invalid');
        if (!roleName) { $role.addClass('is-invalid'); invalid = true; }
        if (!roleTypeId) { $roleType.addClass('is-invalid'); invalid = true; }

        auditions.push({
            projectName: name,
            roleName: roleName,
            audroletypeid: roleTypeId,
            audsubcatid: $e.find('[data-field="audsubcatid"]').val(),
            castingDirector: $e.find('[data-field="castingDirector"]').val().trim(),
            audDate: $e.find('[data-field="audDate"]').val(),
            notes: $e.find('[data-field="notes"]').val().trim()
        });
    });
    if (invalid) {
        taoToast('Role and Role type are required for each audition', 'warning');
        return null; // block Next
    }
    return { auditions: JSON.stringify(auditions) };
};
</script>

</cfoutput>
