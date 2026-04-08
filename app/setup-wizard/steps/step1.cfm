<!---
    P11 Step 1: Welcome and Account Info
    Loaded as HTML fragment by load-step.cfm.
    Pre-fills from taousers + contactdetails (self-contact).
--->
<cfset userid = session.userid>

<!--- Fetch user profile --->
<cfquery name="qProfile" datasource="#application.datasource#" maxrows="1">
    SELECT u.userFirstName, u.userLastName, u.userEmail, u.tzid, u.dateFormatID, u.avatarName
    FROM taousers u
    WHERE u.userid = <cfqueryparam value="#userid#" cfsqltype="cf_sql_integer" />
</cfquery>

<!--- Fetch self-contact for nickname/pronouns/phone --->
<cfquery name="qSelf" datasource="#application.datasource#" maxrows="1">
    SELECT contactid, contactNickname, contactPronoun
    FROM contactdetails
    WHERE userid = <cfqueryparam value="#userid#" cfsqltype="cf_sql_integer" />
      AND user_yn = 'Y'
</cfquery>

<cfset selfContactId = qSelf.recordCount ? qSelf.contactid : 0>

<!--- Fetch primary phone from self-contact --->
<cfset selfPhone = "">
<cfif selfContactId>
    <cfquery name="qPhone" datasource="#application.datasource#" maxrows="1">
        SELECT valuetext
        FROM contactitems
        WHERE contactid = <cfqueryparam value="#selfContactId#" cfsqltype="cf_sql_integer" />
          AND valueCategory = 'Phone'
          AND primary_yn = 'Y'
          AND itemStatus = 'Active'
    </cfquery>
    <cfif qPhone.recordCount>
        <cfset selfPhone = qPhone.valuetext>
    </cfif>
</cfif>

<!--- Timezones picklist --->
<cfquery name="qTimezones" datasource="#application.datasource#">
    SELECT tzid, tzname FROM timezones ORDER BY tzname
</cfquery>

<!--- Date formats picklist --->
<cfquery name="qDateFormats" datasource="#application.datasource#">
    SELECT id AS dateFormatID, formatexample AS dateformatExample FROM dateformats ORDER BY id
</cfquery>

<cfset avatarUrl = "/media-" & application.dsn & "/users/" & userid & "/avatar.jpg">

<cfoutput>

<!--- Tutorial panel (collapsed by default) --->
<div class="wizard-tutorial-toggle collapsed" data-bs-toggle="collapse" data-bs-target="##tutorial1">
    <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="6 9 12 15 18 9"/></svg>
    What is this step?
</div>
<div class="collapse" id="tutorial1">
    <div class="wizard-tutorial">
        Welcome to The Actors Office! TAO helps you manage industry contacts, track auditions, and stay on top of your relationships. This wizard will help you set up the basics -- you can skip any step and come back later.
    </div>
</div>

<h3>Welcome! Let's confirm your info.</h3>
<p class="step-subtitle">These fields are pre-filled from your registration. Update anything that needs changing.</p>

<form id="step1-form" data-parsley-validate>

    <!--- Avatar upload --->
    <div class="avatar-upload-area">
        <img src="#avatarUrl#?t=#getTickCount()#" alt="Profile photo" class="avatar-preview" id="avatar-preview"
             onerror="this.src='/media-#application.dsn#/images/default-avatar.png'" />
        <div>
            <label class="btn btn-outline-secondary btn-sm mb-1">
                Upload Photo
                <input type="file" id="avatar-file" accept="image/jpeg,image/png" style="display:none;" />
            </label>
            <div class="text-muted" style="font-size:12px;">JPEG or PNG, max 5MB</div>
        </div>
    </div>

    <div class="row g-3">
        <div class="col-md-6">
            <label class="form-label">First Name <span class="text-danger">*</span></label>
            <input type="text" class="form-control" name="firstName" value="#encodeForHTMLAttribute(qProfile.userFirstName)#"
                   required data-parsley-minlength="1" />
        </div>
        <div class="col-md-6">
            <label class="form-label">Last Name <span class="text-danger">*</span></label>
            <input type="text" class="form-control" name="lastName" value="#encodeForHTMLAttribute(qProfile.userLastName)#"
                   required data-parsley-minlength="1" />
        </div>
    </div>

    <div class="row g-3 mt-1">
        <div class="col-md-6">
            <label class="form-label">Email</label>
            <input type="email" class="form-control" value="#encodeForHTMLAttribute(qProfile.userEmail)#" disabled />
        </div>
        <div class="col-md-6">
            <label class="form-label">Nickname</label>
            <input type="text" class="form-control" name="nickname"
                   value="#encodeForHTMLAttribute(qSelf.recordCount ? qSelf.contactNickname : '')#"
                   maxlength="100" />
        </div>
    </div>

    <div class="row g-3 mt-1">
        <div class="col-md-6">
            <label class="form-label">Pronouns</label>
            <select class="form-select" name="pronouns" id="pronouns-select">
                <cfset currentPronoun = qSelf.recordCount ? qSelf.contactPronoun : "">
                <option value="">-- Select --</option>
                <option value="He/Him" #currentPronoun EQ "He/Him" ? 'selected' : ''#>He/Him</option>
                <option value="She/Her" #currentPronoun EQ "She/Her" ? 'selected' : ''#>She/Her</option>
                <option value="They/Them" #currentPronoun EQ "They/Them" ? 'selected' : ''#>They/Them</option>
                <option value="Custom" #(len(currentPronoun) AND NOT listFindNoCase("He/Him,She/Her,They/Them", currentPronoun)) ? 'selected' : ''#>Custom</option>
            </select>
        </div>
        <div class="col-md-6" id="pronoun-custom-wrap"
             style="display:#(len(currentPronoun) AND NOT listFindNoCase("He/Him,She/Her,They/Them,", currentPronoun)) ? 'block' : 'none'#;">
            <label class="form-label">Custom Pronouns</label>
            <input type="text" class="form-control" name="pronounCustom"
                   value="#(len(currentPronoun) AND NOT listFindNoCase("He/Him,She/Her,They/Them", currentPronoun)) ? encodeForHTMLAttribute(currentPronoun) : ''#"
                   maxlength="50" />
        </div>
    </div>

    <div class="row g-3 mt-1">
        <div class="col-md-6">
            <label class="form-label">Primary Phone</label>
            <input type="tel" class="form-control" name="phone"
                   value="#encodeForHTMLAttribute(selfPhone)#" />
        </div>
    </div>

    <div class="row g-3 mt-1">
        <div class="col-md-6">
            <label class="form-label">Timezone <span class="text-danger">*</span></label>
            <select class="form-select" name="timezoneId" required>
                <cfloop query="qTimezones">
                    <option value="#qTimezones.tzid#" #val(qProfile.tzid) EQ qTimezones.tzid ? 'selected' : ''#>
                        #encodeForHTML(qTimezones.tzname)#
                    </option>
                </cfloop>
            </select>
        </div>
        <div class="col-md-6">
            <label class="form-label">Date Format <span class="text-danger">*</span></label>
            <select class="form-select" name="dateFormatId" required>
                <cfloop query="qDateFormats">
                    <option value="#qDateFormats.dateFormatID#" #val(qProfile.dateFormatID) EQ qDateFormats.dateFormatID ? 'selected' : ''#>
                        #encodeForHTML(qDateFormats.dateformatExample)#
                    </option>
                </cfloop>
            </select>
        </div>
    </div>

</form>

<script>
// Pronoun custom toggle
$('##pronouns-select').on('change', function() {
    var show = $(this).val() === 'Custom';
    $('##pronoun-custom-wrap').toggle(show);
    if (!show) $('input[name="pronounCustom"]').val('');
});

// Avatar upload
$('##avatar-file').on('change', function() {
    var file = this.files[0];
    if (!file) return;
    if (file.size > 5 * 1024 * 1024) {
        taoToast('Image must be under 5MB', 'warning');
        return;
    }
    var fd = new FormData();
    fd.append('avatar', file);
    var csrf = document.querySelector('meta[name="csrf-token"]');
    $.ajax({
        url: '/ajax/setup-wizard/upload-avatar.cfm',
        type: 'POST',
        data: fd,
        processData: false,
        contentType: false,
        headers: csrf ? { 'X-CSRF-Token': csrf.getAttribute('content') } : {},
        dataType: 'json',
        success: function(r) {
            if (r.success) {
                $('##avatar-preview').attr('src', r.avatarUrl + '?t=' + Date.now());
                taoToast('Photo uploaded');
            } else {
                taoToast(r.message || 'Upload failed', 'error');
            }
        },
        error: function() { taoToast('Upload failed', 'error'); }
    });
});

// Browser timezone detection
(function() {
    try {
        var tz = Intl.DateTimeFormat().resolvedOptions().timeZone;
        if (tz) {
            var $sel = $('select[name="timezoneId"]');
            // Only auto-select if current value is a default/empty
            var opt = $sel.find('option').filter(function() {
                return $(this).text().trim() === tz;
            });
            if (opt.length && !$sel.val()) {
                $sel.val(opt.val());
            }
        }
    } catch(e) {}
})();

// Collect data for wizard controller
window.wizardCollectStepData = function() {
    var $form = $('##step1-form');
    if ($form.parsley && !$form.parsley().isValid()) {
        $form.parsley().validate();
        return null;
    }
    var data = {};
    $form.serializeArray().forEach(function(f) { data[f.name] = f.value; });
    // Resolve pronoun value
    if (data.pronouns === 'Custom') {
        data.pronouns = data.pronounCustom || 'Custom';
    }
    return data;
};
</script>

</cfoutput>
