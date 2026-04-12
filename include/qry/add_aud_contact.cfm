<cfinclude template="/include/perfcount.cfm" />
<cfset auditionService = createObject("component", "services.ContactAuditionService")>

<!--- Input values --->
<cfparam name="audprojectid" type="numeric" default="0">
<cfparam name="autocomplete_aud" type="string" default="0">

<!--- autocomplete_aud now contains the contactid directly from the dropdown --->
<cfif isNumeric(autocomplete_aud) AND autocomplete_aud GT 0>
    <cfset new_contactid = int(autocomplete_aud)>
    <cfset auditionService.INSaudcontacts_auditions_xref_23780(
        audprojectid=audprojectid,
        new_contactid=new_contactid
    )>
<cfelse>
    <cfset new_contactid = 0>
</cfif>
