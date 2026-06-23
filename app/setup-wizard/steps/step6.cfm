<!---
    P11 Step 6: My Links
    TEMPORARILY shown as an informational page (request 2026-06-11).
    The functional links editor is preserved below, disabled via <cfif false>
    (hidden, NOT deleted). To restore: change the <cfif false> to <cfif true>
    and remove the informational panel + wizardCollectStepData override below.
--->
<cfset userid = session.userid>

<!--- Informational placeholder shown while the Links editor is hidden. --->
<cfoutput>
<h3>Your casting profiles and links</h3>
<p class="step-subtitle">Almost done.</p>
<div class="wizard-tutorial" style="margin-top:8px;">
    You'll be able to add your casting profiles and social media links after setup is
    complete -- they'll live on your dashboard, ready to fill in whenever you like.
    Nothing to do here for now; just click <strong>Finish Setup</strong> below to continue.
</div>
</cfoutput>

<script>
// Links step is informational for now -- nothing to collect; Next advances cleanly.
window.wizardCollectStepData = function() {
    return { existingLinks: '[]', customLinks: '[]' };
};
</script>

<!--- ============================================================
      HIDDEN (not deleted): original My Links editor. Flip the cfif
      below to true to restore it (and remove the panel/script above).
      ============================================================ --->
<cfif false>
<!--- Fetch existing site links for this user --->
<cfquery name="qLinks" datasource="#application.datasource#">
    SELECT sl.id, sl.sitename, sl.siteurl, sl.siteicon, sl.iscustom,
           st.sitetypename
    FROM sitelinks_user_tbl sl
    LEFT JOIN sitetypes_user st ON st.sitetypeid = sl.sitetypeid AND st.userid = sl.userid
    WHERE sl.userid = <cfqueryparam value="#userid#" cfsqltype="cf_sql_integer" />
      AND sl.isdeleted = 0
    ORDER BY st.sitetypename ASC, sl.iscustom ASC, sl.sitename ASC
</cfquery>

<cfoutput>

<!--- Tutorial --->
<div class="wizard-tutorial-toggle collapsed" data-bs-toggle="collapse" data-bs-target="##tutorial6">
    <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="6 9 12 15 18 9"/></svg>
    Why add links?
</div>
<div class="collapse" id="tutorial6">
    <div class="wizard-tutorial">
        My Links gives you quick access to your casting profiles and social media. Fill in the URLs now so they're always one click away from your dashboard.
    </div>
</div>

<h3>Your casting profiles and links</h3>
<p class="step-subtitle">Fill in the URLs for your profiles. These will appear on your dashboard for quick access.</p>

<div id="links-list">
    <cfif qLinks.recordCount>
        <cfset lastType = "">
        <cfloop query="qLinks">
            <cfif len(qLinks.sitetypename) AND qLinks.sitetypename NEQ lastType>
                <cfif len(lastType)></div></cfif>
                <h6 class="link-type-heading text-muted mt-3 mb-1">#encodeForHTML(qLinks.sitetypename)#</h6>
                <cfif qLinks.sitetypename EQ "Casting Profiles">
                    <p class="text-muted mb-2" style="font-size:13px;">Add profile URLs for casting platforms you actively use.</p>
                <cfelseif qLinks.sitetypename EQ "Social Media">
                    <p class="text-muted mb-2" style="font-size:13px;">Optional -- these appear on your dashboard for quick access.</p>
                </cfif>
                <div class="link-type-group">
                <cfset lastType = qLinks.sitetypename>
            </cfif>

            <div class="link-row #NOT len(qLinks.siteurl) ? 'link-disabled' : ''#" data-link-id="#qLinks.id#">
                <div class="form-check form-switch me-2" style="min-width:40px;">
                    <input class="form-check-input link-toggle" type="checkbox"
                           #len(qLinks.siteurl) ? 'checked' : ''# />
                </div>
                <div class="link-icon">
                    <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M10 13a5 5 0 0 0 7.54.54l3-3a5 5 0 0 0-7.07-7.07l-1.72 1.71"/><path d="M14 11a5 5 0 0 0-7.54-.54l-3 3a5 5 0 0 0 7.07 7.07l1.71-1.71"/></svg>
                </div>
                <div class="link-name">#encodeForHTML(qLinks.sitename)#</div>
                <input type="url" class="form-control form-control-sm"
                       placeholder="https://..."
                       value="#encodeForHTMLAttribute(len(qLinks.siteurl) ? qLinks.siteurl : '')#"
                       data-field="url"
                       #NOT len(qLinks.siteurl) ? 'disabled' : ''# />
            </div>
        </cfloop>
        <cfif len(lastType)></div></cfif>
    <cfelse>
        <p class="text-muted">No link templates found. Links will be available after setup completes.</p>
    </cfif>
</div>

<!--- Custom link add --->
<div class="mt-3" id="custom-links">
    <!--- Custom links go here --->
</div>
<a href="javascript:void(0)" id="add-custom-link" class="text-primary mt-2 d-inline-block" style="font-size:14px;">
    <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="me-1"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="16"/><line x1="8" y1="12" x2="16" y2="12"/></svg>
    Add custom link
</a>

<script>
// Toggle enable/disable URL input
$(document).on('change', '.link-toggle', function() {
    var $row = $(this).closest('.link-row');
    var enabled = $(this).is(':checked');
    $row.find('input[data-field="url"]').prop('disabled', !enabled);
    $row.toggleClass('link-disabled', !enabled);
});

$('##add-custom-link').on('click', function() {
    var html =
        '<div class="link-row custom-link-row">' +
        '<div class="link-icon">' +
        '<svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M10 13a5 5 0 0 0 7.54.54l3-3a5 5 0 0 0-7.07-7.07l-1.72 1.71"/><path d="M14 11a5 5 0 0 0-7.54-.54l-3 3a5 5 0 0 0 7.07 7.07l1.71-1.71"/></svg>' +
        '</div>' +
        '<input type="text" class="form-control form-control-sm" placeholder="Link name" data-field="name" style="max-width:140px;" />' +
        '<input type="url" class="form-control form-control-sm" placeholder="https://..." data-field="url" />' +
        '<button type="button" class="btn-remove-row" title="Remove">&times;</button>' +
        '</div>';
    $('##custom-links').append(html);
});

$(document).on('click', '.custom-link-row .btn-remove-row', function() {
    $(this).closest('.custom-link-row').remove();
});

window.wizardCollectStepData = function() {
    var existingLinks = [];
    var customLinks = [];

    // Existing pre-populated links (respect toggle state)
    $('##links-list .link-row').each(function() {
        var $r = $(this);
        var linkId = $r.data('link-id');
        var enabled = $r.find('.link-toggle').is(':checked');
        var url = enabled ? $r.find('[data-field="url"]').val().trim() : '';
        console.log('Link:', linkId, 'enabled:', enabled, 'url:', url);
        existingLinks.push({
            sitelinkId: linkId,
            siteurl: url
        });
    });
    console.log('Collected links:', JSON.stringify(existingLinks));

    // Custom links
    $('##custom-links .custom-link-row').each(function() {
        var $r = $(this);
        var name = $r.find('[data-field="name"]').val().trim();
        var url = $r.find('[data-field="url"]').val().trim();
        if (name && url) {
            customLinks.push({ sitename: name, siteurl: url });
        }
    });

    return {
        existingLinks: JSON.stringify(existingLinks),
        customLinks: JSON.stringify(customLinks)
    };
};
</script>

</cfoutput>
</cfif>
