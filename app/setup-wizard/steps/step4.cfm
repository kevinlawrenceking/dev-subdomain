<!---
    P11 Step 4: Import or Add Auditions
    Audition module is universally enabled (TECH-DEBT: isauditionmodule gating removed 2026-04).
    TECH-DEBT: save-step4 inlines INSERT to avoid cookie.userid in INSaudprojects(). Main app still uses cookie path.
--->
<cfset userid = session.userid>

<!--- Audition media-type picklist (global reference table, excludes Headshot per Auditions UI convention). --->
<cfquery name="qMediaTypes" datasource="#application.datasource#">
    SELECT mediatypeid, mediatype
    FROM audmediatypes
    WHERE isDeleted = 0
      AND mediatype <> 'Headshot'
    ORDER BY mediatype
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
<p class="step-subtitle">Add auditions you've had recently, or import from a spreadsheet.</p>

<div class="wizard-two-panel">

    <!--- Import panel --->
    <div class="panel-import">
        <h6 class="text-muted mb-2">Import from file</h6>
        <div class="wizard-dropzone" id="aud-import-dropzone" style="opacity:0.6;cursor:default;">
            <svg xmlns="http://www.w3.org/2000/svg" width="40" height="40" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"><path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"/><polyline points="17 8 12 3 7 8"/><line x1="12" y1="3" x2="12" y2="15"/></svg>
            <div>Coming soon</div>
            <div class="text-muted" style="font-size:12px;">Import auditions from the Auditions page after setup.</div>
        </div>
    </div>

    <div class="panel-divider">or</div>

    <!--- Manual quick-add --->
    <div class="panel-manual">
        <h6 class="text-muted mb-2">Add manually</h6>
        <div id="manual-auditions">
            <div class="audition-entry border rounded p-3 mb-2">
                <div class="row g-2">
                    <div class="col-md-6">
                        <input type="text" class="form-control form-control-sm" placeholder="Project name" data-field="projectName" />
                    </div>
                    <div class="col-md-6">
                        <select class="form-select form-select-sm" data-field="mediaType">
                            <option value="">-- Media type --</option>
                            <cfloop query="qMediaTypes">
                                <option value="#qMediaTypes.mediatypeid#">#encodeForHTML(qMediaTypes.mediatype)#</option>
                            </cfloop>
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

</div>

<script>
// Pre-build media type options for dynamic rows
var mediaTypeOptions = '<option value="">-- Media type --</option>' +
    <cfloop query="qMediaTypes">'<option value="#qMediaTypes.mediatypeid#">#encodeForJavaScript(qMediaTypes.mediatype)#</option>' +
    </cfloop>'';

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
        '<div class="col-md-6"><select class="form-select form-select-sm" data-field="mediaType">' + mediaTypeOptions + '</select></div>' +
        '<div class="col-md-6"><input type="text" class="form-control form-control-sm" placeholder="Casting director" data-field="castingDirector" /></div>' +
        '<div class="col-md-6"><input type="date" class="form-control form-control-sm" data-field="audDate" /></div>' +
        '<div class="col-12"><textarea class="form-control form-control-sm" placeholder="Notes (optional)" data-field="notes" rows="2" maxlength="500"></textarea></div>' +
        '</div></div>';
    $('##manual-auditions').append(html);
});

window.wizardCollectStepData = function() {
    var auditions = [];
    $('##manual-auditions .audition-entry').each(function() {
        var $e = $(this);
        var name = $e.find('[data-field="projectName"]').val().trim();
        if (!name) return;
        auditions.push({
            projectName: name,
            mediaTypeId: $e.find('[data-field="mediaType"]').val(),
            castingDirector: $e.find('[data-field="castingDirector"]').val().trim(),
            audDate: $e.find('[data-field="audDate"]').val(),
            notes: $e.find('[data-field="notes"]').val().trim()
        });
    });
    return { auditions: JSON.stringify(auditions) };
};
</script>

</cfoutput>
