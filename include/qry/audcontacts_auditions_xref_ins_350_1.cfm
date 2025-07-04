<cfset contactAuditionService = createObject("component", "services.ContactAuditionService")>
  <cfoutput>new_contactid=#new_contactid#<BR>
    new_audprojectid=#new_audprojectid#</cfoutput>
<cfset contactAuditionService.INSaudcontacts_auditions_xref_24512(
    new_contactid=new_contactid,
    new_audprojectid=new_audprojectid
)>