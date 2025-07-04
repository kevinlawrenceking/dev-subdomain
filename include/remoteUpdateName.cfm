<!--- This ColdFusion page handles the display and update of contact information including name, birthday, meeting date, pronouns, and referral details. --->

<cfinclude template="/include/qry/pronouns_210_1.cfm" />
<cfinclude template="/include/qry/refers_210_2.cfm" />
<cfinclude template="/include/qry/details_269_3.cfm" />

<cfset contactbirthday = details.contactbirthday />
<cfset contactmeetingdate = details.contactmeetingdate />

<form action="/include/remoteUpdateNameUpdate.cfm" method="post" class="parsley-examples" id="profile-form" 
      data-parsley-excluded="input[type=button], input[type=submit], input[type=reset], input[type=hidden], [disabled], :hidden" 
      data-parsley-trigger="keyup" data-parsley-validate>
    
    <cfoutput>
        <input type="hidden" name="contactid" value="#details.contactid#" />
    </cfoutput>

    <div class="row" />

    <cfoutput>
        <div class="form-group col-md-12">
            <label for="contactfullname">Name<span class="text-danger">*</span></label>
            <input class="form-control" type="text" id="contactfullname" name="contactfullname" 
                   value="#details.contactfullname#" data-parsley-maxlength="500" 
                   data-parsley-maxlength-message="Max length 500 characters" 
                   data-parsley-required data-parsley-error-message="Valid Name is required" 
                   placeholder="Enter Name">
        </div>

        <cfscript>
            if (Len(trim(contactbirthday)) > 0 && REFind("^\d{4}-\d{2}-\d{2}$", contactbirthday)) {
                parsedDate = ParseDateTime(contactbirthday);
                contactbirthday = DateFormat(parsedDate, "yyyy-mm-dd");
            } else {
                contactbirthday = JavaCast("null", "");
            }

            if (Len(trim(contactmeetingdate)) > 0 && REFind("^\d{4}-\d{2}-\d{2}$", contactmeetingdate)) {
                parsedDate = ParseDateTime(contactmeetingdate);
                contactmeetingdate = DateFormat(parsedDate, "yyyy-mm-dd");
            } else {
                contactmeetingdate = JavaCast("null", "");
            }
        </cfscript>

        <div class="form-group col-sm-6 mb-6">
            <label for="simpleinput">Next Birthday</label>
            <input class="form-control" id="contactbirthday" value="#contactbirthday ?: ''#" type="date" name="contactbirthday" />
        </div>

        <div class="form-group col-sm-6 mb-6">
            <label for="simpleinput">Initial Meeting Date</label>
            <input class="form-control" id="contactmeetingdate" value="#contactmeetingdate ?: ''#" type="date" name="contactmeetingdate" />
        </div>

        <div class="form-group col-sm-6 mb-6">
            <label for="contactmeetingloc">Initial Meeting Location</label>
            <input class="form-control" id="contactmeetingloc" type="text" name="contactmeetingloc" value="#details.contactmeetingloc#" />
        </div>
    </cfoutput>

    <div class="form-group col-sm-6 mb-6">
        <label for="contactPronoun">Gender Pronoun</label>
        <select id="contactPronoun" name="contactPronoun" class="form-control" 
                onchange="if (this.value=='custom'){this.form['custom'].style.display='block',this.form['custom'].required=true}else {this.form['custom'].style.display='none',this.form['custom'].required=false};">
            <option value="">Select a Pronoun</option>
            <cfoutput query="pronouns">
                <option value="#pronouns.genderPronoun#" <cfif #pronouns.genderPronoun# is "#details.contactPronoun#"> Selected</cfif>>#pronouns.genderPronoun#</option>
            </cfoutput>
            <option value="custom">Custom</option>
        </select>
    </div>

    <div class="form-group col-sm-6 mb-6">
        <label for="refer_contact_id">Referred By</label>
        <select id="refer_contact_id" name="refer_contact_id" class="form-control w-100">
            <option value="">Select a Relationship</option>
            <cfoutput query="refers">
                <option value="#refers.contactid#" <cfif "#refers.contactid#" is "#details.refer_contact_id#"> selected</cfif>>#refers.contactfullname#</option>
            </cfoutput>
        </select>
    </div>

    <div class="form-group col-sm-6 mb-6">
        <div class="input-group">
            <input class="form-control" type="text" name="custom" id="custom" style="display:none;" 
                   data-parsley-maxlength="50" placeholder="Add a Gender Pronoun in single/plural format.">
        </div>
    </div>

    <input type="hidden" name="deleteitem" value="0" />

<div class="form-group text-end">
    <button class="btn btn-primary btn-sm" type="submit">Add</button>
</div>

</form>

<script>
    $(document).ready(function() {
        $(".parsley-examples").parsley()
    });
</script>

<cfset script_name_include="/include/#ListLast(GetCurrentTemplatePath(), " \")#" />

