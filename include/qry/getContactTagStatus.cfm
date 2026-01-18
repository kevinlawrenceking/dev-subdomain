<cfset contactItemService = createObject("component", "services.ContactItemService")>
<cfset new_systemscope = contactItemService.getContactTagStatus(contactid=contactid, userid=userid)>

<cfoutput>
    Determined system scope: #new_systemscope#
</cfoutput>
