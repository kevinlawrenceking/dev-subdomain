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
    SELECT tzid, tzname, tz_iana FROM timezones ORDER BY tzname
</cfquery>

<!--- Date formats picklist --->
<cfquery name="qDateFormats" datasource="#application.datasource#">
    SELECT id AS dateFormatID, formatexample AS dateformatExample FROM dateformats ORDER BY id
</cfquery>

<!--- Resolve Pacific tzid for default --->
<cfset pacificTzId = 0>
<cfloop query="qTimezones">
    <cfif findNoCase("Pacific Standard Time", qTimezones.tzname)>
        <cfset pacificTzId = qTimezones.tzid>
        <cfbreak>
    </cfif>
</cfloop>
<cfset currentTzId = val(qProfile.tzid) GT 0 ? val(qProfile.tzid) : pacificTzId>
<cflog file="TAO_setup_wizard" text="Pacific TZ lookup: pacificTzId=#pacificTzId#, qProfile.tzid=#val(qProfile.tzid)#, currentTzId=#currentTzId#">

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
            <input type="email" class="form-control" name="email"
                   value="#encodeForHTMLAttribute(qProfile.userEmail)#"
                   required data-parsley-type="email" />
            <!--- TECH-DEBT: No email verification flow yet. Change takes effect immediately. --->
            <div class="form-text text-muted" style="font-size:12px;">Changing your email updates your login credentials.</div>
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
            <cfset usTimezones = "Eastern Standard Time,Central Standard Time,Mountain Standard Time,Pacific Standard Time,Alaskan Standard Time,US Mountain Standard Time,Hawaiian Standard Time,Alaska Standard Time">
            <select class="form-select" name="timezoneId" required>
                <cfif currentTzId EQ 0>
                    <option value="" selected>-- Select your timezone --</option>
                </cfif>
                <optgroup label="United States">
                    <cfloop query="qTimezones">
                        <cfif listFindNoCase(usTimezones, qTimezones.tzname)>
                            <option value="#qTimezones.tzid#"
                                    data-iana="#encodeForHTMLAttribute(len(qTimezones.tz_iana) ? qTimezones.tz_iana : '')#"
                                    #currentTzId EQ qTimezones.tzid ? 'selected' : ''#>
                                #encodeForHTML(qTimezones.tzname)#
                            </option>
                        </cfif>
                    </cfloop>
                </optgroup>
                <optgroup label="All Timezones">
                    <cfloop query="qTimezones">
                        <cfif NOT listFindNoCase(usTimezones, qTimezones.tzname)>
                            <option value="#qTimezones.tzid#"
                                    data-iana="#encodeForHTMLAttribute(len(qTimezones.tz_iana) ? qTimezones.tz_iana : '')#"
                                    #currentTzId EQ qTimezones.tzid ? 'selected' : ''#>
                                #encodeForHTML(qTimezones.tzname)#
                            </option>
                        </cfif>
                    </cfloop>
                </optgroup>
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

<!--- Crop modal --->
<div class="modal fade" id="cropModal" tabindex="-1">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title">Crop Photo</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body text-center">
                <div id="crop-viewport"></div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-outline-secondary btn-sm" data-bs-dismiss="modal">Cancel</button>
                <button type="button" class="btn btn-primary btn-sm" id="crop-save">Save Photo</button>
            </div>
        </div>
    </div>
</div>

<script>
// Pronoun custom toggle
$('##pronouns-select').on('change', function() {
    var show = $(this).val() === 'Custom';
    $('##pronoun-custom-wrap').toggle(show);
    if (!show) $('input[name="pronounCustom"]').val('');
});

// Avatar upload with Croppie
var uploadCrop;

$('##avatar-file').on('change', function() {
    var file = this.files[0];
    if (!file) return;
    if (file.size > 5 * 1024 * 1024) {
        taoToast('Image must be under 5MB', 'warning');
        $(this).val('');
        return;
    }

    var reader = new FileReader();
    reader.onload = function(e) {
        if (uploadCrop) {
            uploadCrop.croppie('destroy');
        }
        uploadCrop = $('##crop-viewport').croppie({
            viewport: { width: 200, height: 200, type: 'circle' },
            boundary: { width: 300, height: 300 },
            enableExif: true
        });
        uploadCrop.croppie('bind', { url: e.target.result });
        var cropModal = new bootstrap.Modal(document.getElementById('cropModal'));
        cropModal.show();
    };
    reader.readAsDataURL(file);
    $(this).val('');
});

$('##crop-save').on('click', function() {
    if (!uploadCrop) return;
    var $btn = $(this);
    $btn.prop('disabled', true).text('Saving...');

    uploadCrop.croppie('result', {
        type: 'blob',
        size: { width: 300, height: 300 },
        format: 'jpeg',
        quality: 0.85
    }).then(function(blob) {
        var fd = new FormData();
        fd.append('avatar', blob, 'avatar.jpg');
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
                    var avatarPath = '/media-' + TAO_WIZARD.mediaPath + '/users/' + TAO_WIZARD.userId + '/avatar.jpg';
                    $('##avatar-preview').attr('src', avatarPath + '?t=' + Date.now());
                    taoToast('Photo uploaded');
                } else {
                    taoToast(r.message || 'Upload failed', 'error');
                }
            },
            error: function() { taoToast('Upload failed', 'error'); }
        });
        bootstrap.Modal.getInstance(document.getElementById('cropModal')).hide();
    }).always(function() {
        $btn.prop('disabled', false).text('Save Photo');
    });
});

// Browser timezone detection via IANA mapping
(function() {
    try {
        var tz = Intl.DateTimeFormat().resolvedOptions().timeZone;
        if (!tz) return;
        var $sel = $('select[name="timezoneId"]');
        var currentVal = parseInt($sel.val(), 10);
        if (currentVal === 0 || currentVal === #pacificTzId#) {
            var $match = $sel.find('option[data-iana="' + tz + '"]');
            if ($match.length) {
                $sel.val($match.val());
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
