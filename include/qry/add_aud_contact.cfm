<cfset auditionService = createObject("component", "services.ContactAuditionService")>

<!--- Input values for the fetch --->
<cfparam name="audprojectid" type="numeric" default="0">
<cfparam name="autocomplete_aud" type="string" default="">
<cfparam name="userid" type="numeric" default="0">

<!--- Call the function to insert into audcontacts_auditions_xref --->
<cfset new_contactid = auditionService.INSaudcontacts_auditions_xref_2(
    audprojectid=audprojectid,
    autocomplete_aud=autocomplete_aud,
    userid=userid
)>
