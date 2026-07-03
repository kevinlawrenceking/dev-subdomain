<!---
    PURPOSE: Contact merge interface - pick the contact to KEEP (primary) and the
             contact to MERGE & REMOVE (duplicate), then resolve field conflicts.
    AUTHOR:  Kevin King
    DATE:    2025-08-07
    REWRITE: 2026-06-25 - verified columns (contactFullName/recordname); supports
             groups of 2+ (merge is pairwise; merge two, list refreshes, repeat).
    PARAMETERS: contactIds (csv), userid (session)
    DEPENDENCIES: services.ContactDuplicateService
--->

<cfset contactIds = "" />
<cfif structKeyExists(url, "contactIds")>
    <cfset contactIds = url.contactIds />
<cfelseif structKeyExists(form, "contactIds")>
    <cfset contactIds = form.contactIds />
</cfif>
<cfset userid = session.userid />

<cfset duplicateService = createObject("component", "services.ContactDuplicateService").init() />
<cfset contactDetails = duplicateService.getContactDetails(contactIds, userid) />
<cfset contactItems   = duplicateService.getContactItems(contactIds, userid) />

<cfif contactDetails.recordCount LT 2>
    <div class="alert alert-warning">
        <i class="fe-alert-triangle"></i>
        Not enough contacts found for merging (they may already be merged). Please refresh and try again.
    </div>
    <cfabort />
</cfif>

<!--- Group items by contact and category for display. Company/Address are shown
      too (ticket 1) so the user can see they are preserved: the merge repoints all
      of the removed contact's items - including Company and Address - onto the kept
      contact. Company's display value lives in valueCompany, not valuetext. --->
<cfset itemsByContact = {} />
<cfloop query="contactItems">
    <cfif not structKeyExists(itemsByContact, contactItems.contactid)>
        <cfset itemsByContact[contactItems.contactid] = { "Email": [], "Phone": [], "Company": [], "Address": [] } />
    </cfif>
    <cfif structKeyExists(itemsByContact[contactItems.contactid], contactItems.valueCategory)>
        <cfif contactItems.valueCategory EQ "Company">
            <cfif len(trim(contactItems.valueCompany))>
                <cfset arrayAppend(itemsByContact[contactItems.contactid]["Company"], contactItems.valueCompany) />
            </cfif>
        <cfelseif len(trim(contactItems.valuetext))>
            <cfset arrayAppend(itemsByContact[contactItems.contactid][contactItems.valueCategory], contactItems.valuetext) />
        </cfif>
    </cfif>
</cfloop>

<form id="mergeForm" method="post" action="/app/contact-duplicates/">
    <cfoutput>
        <cfif structKeyExists(session, "csrfToken")>
            <input type="hidden" name="csrfToken" value="#session.csrfToken#" />
        </cfif>
    </cfoutput>
    <input type="hidden" name="action" value="merge" />
    <input type="hidden" name="duplicateType" value="full" />

    <div class="alert alert-info py-2">
        <i class="fe-info"></i>
        Choose which contact to <strong>keep</strong> and which one to <strong>merge in &amp; remove</strong>.
        All emails, phones, notes, events, auditions and reminders from the removed contact move to the kept one.
        Merging more than two? Merge a pair, then repeat.
    </div>

    <!--- Step 1: choose primary + duplicate --->
    <div class="merge-step" id="step1">
        <div class="table-responsive">
            <table class="table table-bordered align-middle">
                <thead>
                    <tr>
                        <th class="text-center" style="width:90px;">Keep</th>
                        <th class="text-center" style="width:120px;">Merge &amp; remove</th>
                        <th>Contact</th>
                    </tr>
                </thead>
                <tbody>
                    <cfoutput query="contactDetails">
                        <tr>
                            <td class="text-center">
                                <input class="form-check-input" type="radio" name="primaryContactId"
                                       value="#contactDetails.contactid#" onchange="onRoleChange()" />
                            </td>
                            <td class="text-center">
                                <input class="form-check-input" type="radio" name="duplicateContactId"
                                       value="#contactDetails.contactid#" onchange="onRoleChange()" />
                            </td>
                            <td>
                                <div class="contact-card card" id="card_#contactDetails.contactid#">
                                    <div class="card-body py-2">
                                        <h6 class="mb-1">#encodeForHtml(contactDetails.contactFullName)#</h6>
                                        <cfif len(trim(contactDetails.recordname)) AND contactDetails.recordname NEQ contactDetails.contactFullName>
                                            <div class="text-muted small">aka #encodeForHtml(contactDetails.recordname)#</div>
                                        </cfif>
                                        <div class="text-muted small">Created: #dateFormat(contactDetails.contactCreationDate, 'mm/dd/yyyy')#</div>
                                        <cfif structKeyExists(itemsByContact, contactDetails.contactid)>
                                            <cfloop array="#itemsByContact[contactDetails.contactid]['Email']#" index="em">
                                                <div class="small"><i class="fe-mail"></i> #encodeForHtml(em)#</div>
                                            </cfloop>
                                            <cfloop array="#itemsByContact[contactDetails.contactid]['Phone']#" index="ph">
                                                <div class="small"><i class="fe-phone"></i> #encodeForHtml(ph)#</div>
                                            </cfloop>
                                            <cfloop array="#itemsByContact[contactDetails.contactid]['Company']#" index="co">
                                                <div class="small"><i class="fe-briefcase"></i> #encodeForHtml(co)#</div>
                                            </cfloop>
                                            <cfloop array="#itemsByContact[contactDetails.contactid]['Address']#" index="ad">
                                                <div class="small"><i class="fe-map-pin"></i> #encodeForHtml(ad)#</div>
                                            </cfloop>
                                        </cfif>
                                    </div>
                                </div>
                            </td>
                        </tr>
                    </cfoutput>
                </tbody>
            </table>
        </div>

        <div class="text-end mt-3">
            <button type="button" class="btn btn-primary" onclick="goToStep(2)" disabled id="step1Next">
                Next: choose field values <i class="fe-arrow-right"></i>
            </button>
        </div>
    </div>

    <!--- Step 2: resolve field conflicts --->
    <div class="merge-step d-none" id="step2">
        <p class="text-muted mb-3">For each differing field, pick the value to keep on the surviving contact:</p>
        <div id="fieldComparisons"></div>
        <div class="d-flex justify-content-between mt-4">
            <button type="button" class="btn btn-secondary" onclick="goToStep(1)"><i class="fe-arrow-left"></i> Back</button>
            <button type="button" class="btn btn-success" onclick="submitMerge()"><i class="fe-shuffle"></i> Complete merge</button>
        </div>
    </div>
</form>

<script>
<!--- var (not const/let): this fragment is re-loaded via $.load each time the modal
      opens; jQuery evals it in global scope, and const cannot be redeclared. --->
var contactData = [
    <cfoutput query="contactDetails">
    {
        contactid:          #contactDetails.contactid#,
        contactFullName:    "#jsStringFormat(contactDetails.contactFullName)#",
        contacttitle:       "#jsStringFormat(contactDetails.contacttitle)#",
        contactNickname:    "#jsStringFormat(contactDetails.contactNickname)#",
        contactPronoun:     "#jsStringFormat(contactDetails.contactPronoun)#",
        contactBirthday:    "<cfif isDate(contactDetails.contactBirthday)>#dateFormat(contactDetails.contactBirthday,'yyyy-mm-dd')#</cfif>",
        contactMeetingDate: "<cfif isDate(contactDetails.contactMeetingDate)>#dateFormat(contactDetails.contactMeetingDate,'yyyy-mm-dd')#</cfif>",
        contactMeetingLoc:  "#jsStringFormat(contactDetails.contactMeetingLoc)#",
        refer_contact_id:   "#jsStringFormat(contactDetails.refer_contact_id)#",
        newsletter_yn:      "#jsStringFormat(contactDetails.newsletter_yn)#",
        googlealert_yn:     "#jsStringFormat(contactDetails.googlealert_yn)#",
        socialmedia_yn:     "#jsStringFormat(contactDetails.socialmedia_yn)#"
    }<cfif contactDetails.currentRow LT contactDetails.recordCount>,</cfif>
    </cfoutput>
];

var FIELDS = [
    {key: 'contactFullName',    label: 'Full name'},
    {key: 'contacttitle',       label: 'Title'},
    {key: 'contactNickname',    label: 'Nickname'},
    {key: 'contactPronoun',     label: 'Pronoun'},
    {key: 'contactBirthday',    label: 'Birthday'},
    {key: 'contactMeetingDate', label: 'Meeting date'},
    {key: 'contactMeetingLoc',  label: 'Meeting location'},
    {key: 'newsletter_yn',      label: 'Newsletter'},
    {key: 'googlealert_yn',     label: 'Google alert'},
    {key: 'socialmedia_yn',     label: 'Social media'}
];

function selectedPrimary()   { const el = document.querySelector('input[name="primaryContactId"]:checked');   return el ? el.value : null; }
function selectedDuplicate()  { const el = document.querySelector('input[name="duplicateContactId"]:checked'); return el ? el.value : null; }

function onRoleChange() {
    const p = selectedPrimary(), d = selectedDuplicate();
    // Highlight cards
    document.querySelectorAll('.contact-card').forEach(c => c.classList.remove('is-primary','is-duplicate'));
    if (p) document.getElementById('card_' + p).classList.add('is-primary');
    if (d) document.getElementById('card_' + d).classList.add('is-duplicate');
    // Enable next only when both chosen and different
    const ok = p && d && p !== d;
    document.getElementById('step1Next').disabled = !ok;
    if (p && d && p === d) {
        document.getElementById('step1Next').disabled = true;
    }
}

function goToStep(n) {
    if (n === 2) {
        if (selectedPrimary() === selectedDuplicate()) { alert('Keep and Merge must be two different contacts.'); return; }
        buildFieldComparisons();
    }
    document.querySelectorAll('.merge-step').forEach(s => s.classList.add('d-none'));
    document.getElementById('step' + n).classList.remove('d-none');
}

function buildFieldComparisons() {
    const primary   = contactData.find(c => c.contactid == selectedPrimary());
    const duplicate = contactData.find(c => c.contactid == selectedDuplicate());
    let html = '';
    FIELDS.forEach(f => {
        const pv = primary[f.key]   || '';
        const dv = duplicate[f.key] || '';
        if (pv !== dv) {
            // Default to the KEEP contact's value, but when Keep is EMPTY fall back
            // to the Removed contact's value. Previously the hidden field always
            // defaulted to the (possibly empty) Keep value, so the duplicate's
            // birthday / meeting date / etc. were dropped instead of merged in
            // (ticket 1). The user can still click either side to override.
            const fillFromRemoved = (pv === '' && dv !== '');
            const defaultVal = fillFromRemoved ? dv : pv;
            html += `
                <div class="field-comparison">
                    <h6>${f.label}</h6>
                    <div class="row">
                        <div class="col-md-6">
                            <div class="field-value ${fillFromRemoved ? '' : 'selected'} ${pv ? '' : 'empty-value'}"
                                 onclick="pickValue('${f.key}', this)" data-val="${encodeURIComponent(pv)}">
                                <strong class="fv-label"></strong><br>${pv || '<em>No value</em>'}
                            </div>
                        </div>
                        <div class="col-md-6">
                            <div class="field-value ${fillFromRemoved ? 'selected' : ''} ${dv ? '' : 'empty-value'}"
                                 onclick="pickValue('${f.key}', this)" data-val="${encodeURIComponent(dv)}">
                                <strong class="fv-label"></strong><br>${dv || '<em>No value</em>'}
                            </div>
                        </div>
                    </div>
                    <input type="hidden" name="mergeData[${f.key}]" value="${defaultVal}" />
                </div>`;
        } else {
            html += `<input type="hidden" name="mergeData[${f.key}]" value="${pv}" />`;
        }
    });
    if (!html.includes('field-comparison')) {
        html = '<div class="alert alert-info"><i class="fe-info"></i> No conflicting field values. Nothing to choose.</div>' + html;
    }
    document.getElementById('fieldComparisons').innerHTML = html;
    // Render the selection-state label on modal open. The label is a pure function
    // of the .selected class (the same state that drives the highlight and the
    // hidden input), so it is correct for both the keep-side default and the
    // removed-side fallback default without any parallel state.
    document.querySelectorAll('#fieldComparisons .field-value').forEach(applyFieldLabel);
}

// Selected card reads "Keep:", the other reads "Discard:". Derived solely from
// .selected so label + highlight + hidden field can never disagree.
function applyFieldLabel(el) {
    const lbl = el.querySelector('.fv-label');
    if (lbl) lbl.textContent = el.classList.contains('selected') ? 'Keep:' : 'Discard:';
}

function pickValue(key, el) {
    const pair = el.parentElement.parentElement;
    pair.querySelectorAll('.field-value').forEach(v => v.classList.remove('selected'));
    el.classList.add('selected');
    pair.querySelectorAll('.field-value').forEach(applyFieldLabel);
    const input = document.querySelector(`input[name="mergeData[${key}]"]`);
    if (input) input.value = decodeURIComponent(el.getAttribute('data-val'));
}

function submitMerge() {
    const p = selectedPrimary(), d = selectedDuplicate();
    if (!p || !d || p === d) { alert('Choose one contact to keep and a different one to merge.'); return; }
    if (confirm('Merge these two contacts? The removed contact is archived; this can be undone from the merge log.')) {
        document.getElementById('mergeForm').submit();
    }
}
</script>
