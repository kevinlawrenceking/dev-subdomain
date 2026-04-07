<!---
    P11 Step 6: My Links
    Pre-populated link rows from sitelinks_user_tbl (bootstrapped during setup).
    User fills in URLs for their casting profiles and social media.
--->
<cfset userid = session.userid>

<!--- Fetch existing site links for this user --->
<cfquery name="qLinks" datasource="#application.datasource#">
    SELECT sl.id, sl.sitename, sl.siteurl, sl.siteicon, sl.iscustom,
           st.sitetypename
    FROM sitelinks_user_tbl sl
    LEFT JOIN sitetypes_user st ON st.sitetypeid = sl.sitetypeid AND st.userid = sl.userid
    WHERE sl.userid = <cfqueryparam value="#userid#" cfsqltype="cf_sql_integer" />
      AND sl.isdeleted = 0
    ORDER BY sl.iscustom ASC, sl.sitename ASC
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
        <cfloop query="qLinks">
            <div class="link-row" data-link-id="#qLinks.id#">
                <div class="link-icon">
                    <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M10 13a5 5 0 0 0 7.54.54l3-3a5 5 0 0 0-7.07-7.07l-1.72 1.71"/><path d="M14 11a5 5 0 0 0-7.54-.54l-3 3a5 5 0 0 0 7.07 7.07l1.71-1.71"/></svg>
                </div>
                <div class="link-name">#encodeForHTML(qLinks.sitename)#</div>
                <input type="url" class="form-control form-control-sm"
                       placeholder="https://..."
                       value="#encodeForHTMLAttribute(len(qLinks.siteurl) ? qLinks.siteurl : '')#"
                       data-field="url" />
            </div>
        </cfloop>
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

    // Existing pre-populated links
    $('##links-list .link-row').each(function() {
        var $r = $(this);
        var url = $r.find('[data-field="url"]').val().trim();
        existingLinks.push({
            sitelinkId: $r.data('link-id'),
            siteurl: url
        });
    });

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
