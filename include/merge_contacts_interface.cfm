<!---
    PURPOSE: Contact merge interface for selecting field values
    AUTHOR: Kevin King
    DATE: 2025-08-07
    PARAMETERS: contactIds, duplicateType, userid
    DEPENDENCIES: ContactDuplicateService
--->

<cfparam name="contactIds" default="" />
<cfparam name="duplicateType" default="name" />
<cfparam name="userid" default="#session.userid#" />

<!--- Initialize service and get contact details --->
<cfset duplicateService = createObject("component", "services.ContactDuplicateService") />
<cfset contactDetails = duplicateService.getContactDetails(contactIds, userid) />
<cfset contactItems = duplicateService.getContactItems(contactIds) />

<cfif contactDetails.recordcount lt 2>
    <div class="alert alert-warning">
        <i class="fe-alert-triangle"></i>
        Not enough contacts found for merging. Please try again.
    </div>
    <cfabort />
</cfif>

<!--- Organize contact items by contact and category --->
<cfset contactItemsStruct = {} />
<cfloop query="contactItems">
    <cfif not structKeyExists(contactItemsStruct, contactid)>
        <cfset contactItemsStruct[contactid] = {} />
    </cfif>
    <cfif not structKeyExists(contactItemsStruct[contactid], valueCategory)>
        <cfset contactItemsStruct[contactid][valueCategory] = [] />
    </cfif>
    <cfset arrayAppend(contactItemsStruct[contactid][valueCategory], {
        itemid: itemid,
        valuetext: valuetext
    }) />
</cfloop>

<form id="mergeForm" method="post" action="/app/contact-duplicates/">
    <input type="hidden" name="action" value="merge" />
    <input type="hidden" name="userid" value="<cfoutput>#userid#</cfoutput>" />
    
    <!--- Step 1: Select Primary Contact --->
    <div class="merge-step" id="step1">
        <h5 class="text-primary mb-3">
            <span class="badge bg-primary me-2">1</span>
            Select Primary Contact
        </h5>
        <p class="text-muted mb-4">Choose which contact will be kept as the main record:</p>
        
        <div class="row">
            <cfloop query="contactDetails">
                <div class="col-md-6 mb-3">
                    <div class="contact-card card h-100" onclick="selectPrimaryContact(this, <cfoutput>#contactid#</cfoutput>)">
                        <div class="card-body">
                            <div class="form-check">
                                <input class="form-check-input" type="radio" 
                                       name="primaryContactId" 
                                       value="<cfoutput>#contactid#</cfoutput>" 
                                       id="primary<cfoutput>#contactid#</cfoutput>" />
                                <label class="form-check-label" for="primary<cfoutput>#contactid#</cfoutput>">
                                    <h6 class="card-title mb-2">
                                        <cfoutput>#contactfirst# #contactlast#</cfoutput>
                                    </h6>
                                </label>
                            </div>
                            
                            <div class="contact-info">
                                <p class="mb-1"><small class="text-muted">Created: <cfoutput>#dateFormat(created_date, 'mm/dd/yyyy')#</cfoutput></small></p>
                                
                                <!--- Show email if available --->
                                <cfif structKeyExists(contactItemsStruct, contactid) and structKeyExists(contactItemsStruct[contactid], "Email")>
                                    <cfloop array="#contactItemsStruct[contactid]['Email']#" index="emailItem">
                                        <p class="mb-1"><small><i class="fe-mail"></i> <cfoutput>#emailItem.valuetext#</cfoutput></small></p>
                                    </cfloop>
                                </cfif>
                                
                                <!--- Show phone if available --->
                                <cfif structKeyExists(contactItemsStruct, contactid) and structKeyExists(contactItemsStruct[contactid], "Phone")>
                                    <cfloop array="#contactItemsStruct[contactid]['Phone']#" index="phoneItem">
                                        <p class="mb-1"><small><i class="fe-phone"></i> <cfoutput>#phoneItem.valuetext#</cfoutput></small></p>
                                    </cfloop>
                                </cfif>
                                
                                <cfif len(trim(contactpronoun))>
                                    <p class="mb-1"><small><strong>Pronoun:</strong> <cfoutput>#contactpronoun#</cfoutput></small></p>
                                </cfif>
                                
                                <cfif isDate(contactbirthday)>
                                    <p class="mb-1"><small><strong>Birthday:</strong> <cfoutput>#dateFormat(contactbirthday, 'mm/dd')#</cfoutput></small></p>
                                </cfif>
                                
                                <cfif len(trim(contactmeetingloc))>
                                    <p class="mb-1"><small><strong>Meeting Location:</strong> <cfoutput>#contactmeetingloc#</cfoutput></small></p>
                                </cfif>
                            </div>
                        </div>
                    </div>
                </div>
            </cfloop>
        </div>
        
        <div class="text-end mt-3">
            <button type="button" class="btn btn-primary" onclick="goToStep(2)" disabled id="step1Next">
                Next: Select Field Values <i class="fe-arrow-right"></i>
            </button>
        </div>
    </div>

    <!--- Step 2: Select Field Values --->
    <div class="merge-step d-none" id="step2">
        <h5 class="text-primary mb-3">
            <span class="badge bg-primary me-2">2</span>
            Choose Field Values
        </h5>
        <p class="text-muted mb-4">For each field with different values, select which one to keep:</p>
        
        <div id="fieldComparisons">
            <!--- Field comparisons will be populated by JavaScript --->
        </div>
        
        <div class="d-flex justify-content-between mt-4">
            <button type="button" class="btn btn-secondary" onclick="goToStep(1)">
                <i class="fe-arrow-left"></i> Back
            </button>
            <button type="button" class="btn btn-success" onclick="submitMerge()">
                <i class="fe-shuffle"></i> Complete Merge
            </button>
        </div>
    </div>
</form>

<script>
// Contact data for JavaScript processing
const contactData = [
    <cfloop query="contactDetails">
        <cfoutput>
        {
            contactid: #contactid#,
            contactfirst: '#jsStringFormat(contactfirst)#',
            contactlast: '#jsStringFormat(contactlast)#',
            contactfullname: '#jsStringFormat(contactfullname)#',
            contactpronoun: '#jsStringFormat(contactpronoun)#',
            contactbirthday: '<cfif isDate(contactbirthday)>#dateFormat(contactbirthday, 'yyyy-mm-dd')#</cfif>',
            contactmeetingdate: '<cfif isDate(contactmeetingdate)>#dateFormat(contactmeetingdate, 'yyyy-mm-dd')#</cfif>',
            contactmeetingloc: '#jsStringFormat(contactmeetingloc)#',
            refer_contact_id: '#refer_contact_id#',
            newsletter_yn: '#newsletter_yn#',
            googlealert_yn: '#googlealert_yn#',
            socialmedia_yn: '#socialmedia_yn#'
        }<cfif currentRow lt recordcount>,</cfif>
        </cfoutput>
    </cfloop>
];

let selectedPrimaryId = null;
let duplicateContactId = null;

function selectPrimaryContact(card, contactId) {
    // Remove previous selections
    document.querySelectorAll('.contact-card').forEach(c => c.classList.remove('selected'));
    document.querySelectorAll('input[name="primaryContactId"]').forEach(r => r.checked = false);
    
    // Select this contact
    card.classList.add('selected');
    document.getElementById('primary' + contactId).checked = true;
    
    selectedPrimaryId = contactId;
    
    // Find the duplicate contact ID (the other one)
    duplicateContactId = contactData.find(c => c.contactid != contactId).contactid;
    
    // Enable next button
    document.getElementById('step1Next').disabled = false;
    
    // Add hidden input for duplicate contact ID
    let duplicateInput = document.getElementById('duplicateContactId');
    if (!duplicateInput) {
        duplicateInput = document.createElement('input');
        duplicateInput.type = 'hidden';
        duplicateInput.name = 'duplicateContactId';
        duplicateInput.id = 'duplicateContactId';
        document.getElementById('mergeForm').appendChild(duplicateInput);
    }
    duplicateInput.value = duplicateContactId;
}

function goToStep(stepNumber) {
    document.querySelectorAll('.merge-step').forEach(step => step.classList.add('d-none'));
    document.getElementById('step' + stepNumber).classList.remove('d-none');
    
    if (stepNumber === 2) {
        buildFieldComparisons();
    }
}

function buildFieldComparisons() {
    const primaryContact = contactData.find(c => c.contactid == selectedPrimaryId);
    const duplicateContact = contactData.find(c => c.contactid == duplicateContactId);
    
    const fieldsToCompare = [
        {key: 'contactfirst', label: 'First Name'},
        {key: 'contactlast', label: 'Last Name'},
        {key: 'contactfullname', label: 'Full Name'},
        {key: 'contactpronoun', label: 'Pronoun'},
        {key: 'contactbirthday', label: 'Birthday'},
        {key: 'contactmeetingdate', label: 'Meeting Date'},
        {key: 'contactmeetingloc', label: 'Meeting Location'},
        {key: 'newsletter_yn', label: 'Newsletter Subscription'},
        {key: 'googlealert_yn', label: 'Google Alert'},
        {key: 'socialmedia_yn', label: 'Social Media Follow'}
    ];
    
    let comparisonsHTML = '';
    
    fieldsToCompare.forEach(field => {
        const primaryValue = primaryContact[field.key] || '';
        const duplicateValue = duplicateContact[field.key] || '';
        
        // Only show comparison if values are different
        if (primaryValue !== duplicateValue) {
            comparisonsHTML += `
                <div class="field-comparison">
                    <h6>${field.label}</h6>
                    <div class="row">
                        <div class="col-md-6">
                            <div class="field-value ${primaryValue ? '' : 'empty-value'}" 
                                 onclick="selectFieldValue('${field.key}', '${primaryValue}', this)">
                                <strong>Primary Contact:</strong><br>
                                ${primaryValue || '<em>No value</em>'}
                            </div>
                        </div>
                        <div class="col-md-6">
                            <div class="field-value ${duplicateValue ? '' : 'empty-value'}" 
                                 onclick="selectFieldValue('${field.key}', '${duplicateValue}', this)">
                                <strong>Duplicate Contact:</strong><br>
                                ${duplicateValue || '<em>No value</em>'}
                            </div>
                        </div>
                    </div>
                    <input type="hidden" name="mergeData[${field.key}]" value="${primaryValue}" />
                </div>
            `;
        } else {
            // If values are the same, just add a hidden input
            comparisonsHTML += `<input type="hidden" name="mergeData[${field.key}]" value="${primaryValue}" />`;
        }
    });
    
    if (!comparisonsHTML.includes('field-comparison')) {
        comparisonsHTML = '<div class="alert alert-info"><i class="fe-info"></i> All field values are identical. No conflicts to resolve.</div>';
    }
    
    document.getElementById('fieldComparisons').innerHTML = comparisonsHTML;
}

function selectFieldValue(fieldKey, value, element) {
    // Remove previous selection for this field
    element.parentElement.parentElement.querySelectorAll('.field-value').forEach(fv => {
        fv.classList.remove('selected');
    });
    
    // Select this value
    element.classList.add('selected');
    
    // Update hidden input
    const input = document.querySelector(`input[name="mergeData[${fieldKey}]"]`);
    if (input) {
        input.value = value;
    }
}

function submitMerge() {
    if (!selectedPrimaryId || !duplicateContactId) {
        alert('Please select a primary contact first.');
        return;
    }
    
    if (confirm('Are you sure you want to merge these contacts? This action cannot be undone.')) {
        document.getElementById('mergeForm').submit();
    }
}
</script>
