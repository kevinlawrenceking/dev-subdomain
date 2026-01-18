<cfcontent type="application/json">
<cftry>
 
    <cfparam name="form.contactid" type="integer">
    <cfparam name="form.audprojectid" type="integer">

    <cfset contactItemService = createObject("component", "services.contactItemService")>

    <cfset contactItemService.deleteAudContact(contactid=form.contactid, audprojectid=form.audprojectid)>

    <cfoutput>#serializeJSON({ "success": true, "message": "Contact removed successfully." })#</cfoutput>

<cfcatch>

    <cfoutput>#serializeJSON({ "success": false, "message": cfcatch.message })#</cfoutput>
</cfcatch>
</cftry>

