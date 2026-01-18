<!--- This ColdFusion page processes contact information, including meeting dates and birthdays, and updates the contact records accordingly. --->

<cfparam name="deleteitem" default="0" /> 
<cfparam name="valuetext" default="" /> 
<cfparam name="refer_contact_id" default="" /> 
<cfparam name="custompronoun" default="" /> 

<cfscript>
    if (Len(trim(form.contactmeetingdate)) > 0 && REFind("^\d{4}-\d{2}-\d{2}$", form.contactmeetingdate)) {
        parsedDate = ParseDateTime(form.contactmeetingdate);
        contactmeetingdate = DateFormat(parsedDate, "yyyy-mm-dd");
    } else {
        contactmeetingdate = JavaCast("null", "");
    }

    if (Len(trim(form.contactbirthday)) > 0 && REFind("^\d{4}-\d{2}-\d{2}$", form.contactbirthday)) {
        parsedDate = ParseDateTime(form.contactbirthday);
        contactbirthday = DateFormat(parsedDate, "yyyy-mm-dd");
    } else {
        contactbirthday = JavaCast("null", "");
    }
</cfscript>

<cfinclude template="/include/qry/updatecontact_270_1.cfm" />

<!--- Check if contactbirthday is not empty --->
<cfif #contactbirthday# is not "">
    <cfinclude template="/include/birthday_fix.cfm" />    
</cfif>

<!--- Check if custom pronoun is provided and matches "custom" --->
<cfif #custom# is not "" and #contactPronoun# is "custom">
    <cfinclude template="/include/qry/find_270_2.cfm" />
    
    <!--- If no records found, add new record --->
    <cfif #find.recordcount# is "0">
        <cfinclude template="/include/qry/add_270_3.cfm" />
    </cfif>
</cfif>

<!--- Redirect to contact page with contactid --->
<cflocation url="/app/contact/?contactid=#contactid#" /> 
