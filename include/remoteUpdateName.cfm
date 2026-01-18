<!--- 
================================================================================
REMOTE UPDATE NAME - Contact Information Update Form
================================================================================

Purpose:
This file provides a modal form interface for updating contact information in the
TAO Relationship System. It handles the display and update of contact details including
name, birthday, meeting information, pronouns, and referral relationships.

TAO System Integration:
- Part of the Contact Management module
- Provides interface for updating existing contact details
- Integrates with contact profile management system
- Supports custom gender pronouns and referral tracking

Database Tables:
- contactdetails: Main contact information storage
- pronouns: Gender pronoun options for contacts
- refers: Referral relationship tracking
- actionusers_tbl: User account information

Key Features:
- Contact name editing with validation
- Birthday and meeting date management
- Custom gender pronoun support
- Referral relationship assignment
- Meeting location tracking
- Form validation with Parsley.js

Dependencies:
- jQuery for form handling and validation
- Parsley.js for client-side form validation
- Bootstrap for UI components
- ColdFusion for server-side processing

Related Files:
- /include/qry/pronouns_210_1.cfm: Gender pronoun options
- /include/qry/refers_210_2.cfm: Referral contact list
- /include/qry/details_269_3.cfm: Contact detail retrieval
- /include/remoteUpdateNameUpdate.cfm: Form processing handler

Author: TAO Development Team
Last Updated: 2025
================================================================================
--->

<!--- ============================================================================ --->
<!--- SECTION 1: INITIALIZATION AND DATA RETRIEVAL --->
<!--- ============================================================================ --->

<!--- Load required data queries --->
<cfinclude template="/include/qry/pronouns_210_1.cfm" />
<cfinclude template="/include/qry/refers_210_2.cfm" />
<cfinclude template="/include/qry/details_269_3.cfm" />

<!--- Initialize date variables for processing --->
<cfset contactbirthday = details.contactbirthday />
<cfset contactmeetingdate = details.contactmeetingdate />

<!--- ============================================================================ --->
<!--- SECTION 2: FORM STRUCTURE AND HIDDEN FIELDS --->
<!--- ============================================================================ --->

<!--- Main form with validation configuration --->
<form action="/include/remoteUpdateNameUpdate.cfm" method="post" class="parsley-examples" id="profile-form" 
      data-parsley-excluded="input[type=button], input[type=submit], input[type=reset], input[type=hidden], [disabled], :hidden" 
      data-parsley-trigger="keyup" data-parsley-validate>
    
    <!--- Hidden contact ID field --->
    <cfoutput>
        <input type="hidden" name="contactid" value="#details.contactid#" />
    </cfoutput>

    <div class="row" />

    <!--- ============================================================================ --->
    <!--- SECTION 3: CONTACT NAME FIELD --->
    <!--- ============================================================================ --->

    <cfoutput>
        <div class="form-group col-md-12">
            <label for="contactfullname">Name<span class="text-danger">*</span></label>
            <input class="form-control" type="text" id="contactfullname" name="contactfullname" 
                   value="#details.contactfullname#" data-parsley-maxlength="500" 
                   data-parsley-maxlength-message="Max length 500 characters" 
                   data-parsley-required data-parsley-error-message="Valid Name is required" 
                   placeholder="Enter Name">
        </div>

        <!--- ============================================================================ --->
        <!--- SECTION 4: DATE PROCESSING AND VALIDATION --->
        <!--- ============================================================================ --->

        <cfscript>
            // Process birthday date format
            if (Len(trim(contactbirthday)) > 0 && REFind("^\d{4}-\d{2}-\d{2}$", contactbirthday)) {
                parsedDate = ParseDateTime(contactbirthday);
                contactbirthday = DateFormat(parsedDate, "yyyy-mm-dd");
            } else {
                contactbirthday = JavaCast("null", "");
            }

            // Process meeting date format
            if (Len(trim(contactmeetingdate)) > 0 && REFind("^\d{4}-\d{2}-\d{2}$", contactmeetingdate)) {
                parsedDate = ParseDateTime(contactmeetingdate);
                contactmeetingdate = DateFormat(parsedDate, "yyyy-mm-dd");
            } else {
                contactmeetingdate = JavaCast("null", "");
            }
        </cfscript>

        <!--- ============================================================================ --->
        <!--- SECTION 5: DATE AND MEETING INFORMATION FIELDS --->
        <!--- ============================================================================ --->

        <div class="form-group col-sm-6 mb-6">
            <label for="contactbirthday">Next Birthday</label>
            <input class="form-control" id="contactbirthday" value="#contactbirthday ?: ''#" 
                   type="date" name="contactbirthday" />
        </div>

        <div class="form-group col-sm-6 mb-6">
            <label for="contactmeetingdate">Initial Meeting Date</label>
            <input class="form-control" id="contactmeetingdate" value="#contactmeetingdate ?: ''#" 
                   type="date" name="contactmeetingdate" />
        </div>

        <div class="form-group col-sm-6 mb-6">
            <label for="contactmeetingloc">Initial Meeting Location</label>
            <input class="form-control" id="contactmeetingloc" type="text" name="contactmeetingloc" 
                   value="#details.contactmeetingloc#" />
        </div>
    </cfoutput>

    <!--- ============================================================================ --->
    <!--- SECTION 6: GENDER PRONOUN SELECTION --->
    <!--- ============================================================================ --->

    <div class="form-group col-sm-6 mb-6">
        <label for="contactPronoun">Gender Pronoun</label>
        <select id="contactPronoun" name="contactPronoun" class="form-control" 
                onchange="if (this.value=='custom'){this.form['custom'].style.display='block',this.form['custom'].required=true}else {this.form['custom'].style.display='none',this.form['custom'].required=false};">
            <option value="">Select a Pronoun</option>
            <cfoutput query="pronouns">
                <option value="#pronouns.genderPronoun#" <cfif pronouns.genderPronoun is details.contactPronoun> Selected</cfif>>#pronouns.genderPronoun#</option>
            </cfoutput>
            <option value="custom">Custom</option>
        </select>
    </div>

    <!--- ============================================================================ --->
    <!--- SECTION 7: REFERRAL RELATIONSHIP SELECTION --->
    <!--- ============================================================================ --->

    <div class="form-group col-sm-6 mb-6">
        <label for="refer_contact_id">Referred By</label>
        <select id="refer_contact_id" name="refer_contact_id" class="form-control w-100">
            <option value="">Select a Relationship</option>
            <cfoutput query="refers">
                <option value="#refers.contactid#" <cfif refers.contactid is details.refer_contact_id> selected</cfif>>#refers.contactfullname#</option>
            </cfoutput>
        </select>
    </div>

    <!--- ============================================================================ --->
    <!--- SECTION 8: CUSTOM PRONOUN INPUT FIELD --->
    <!--- ============================================================================ --->

    <div class="form-group col-sm-6 mb-6">
        <div class="input-group">
            <input class="form-control" type="text" name="custom" id="custom" style="display:none;" 
                   data-parsley-maxlength="50" placeholder="Add a Gender Pronoun in single/plural format.">
        </div>
    </div>

    <!--- ============================================================================ --->
    <!--- SECTION 9: FORM SUBMISSION AND HIDDEN FIELDS --->
    <!--- ============================================================================ --->

    <!--- Hidden field for delete functionality --->
    <input type="hidden" name="deleteitem" value="0" />

    <!--- Submit button --->
    <div class="form-group text-end">
        <button class="btn btn-primary btn-sm" type="submit">Update</button>
    </div>

</form>

<!--- ============================================================================ --->
<!--- SECTION 10: JAVASCRIPT INITIALIZATION --->
<!--- ============================================================================ --->

<!--- Initialize form validation --->
<script>
    $(document).ready(function() {
        $(".parsley-examples").parsley();
    });
</script>

<!--- Script include for tracking --->
<cfset script_name_include = "/include/#ListLast(GetCurrentTemplatePath(), '\')#" />

