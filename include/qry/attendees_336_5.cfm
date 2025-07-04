<cfset attendeesService = createObject("component", "services.EventContactsXRefService")>
<cfset attendeesStruct = attendeesService.SELeventcontactsxref_24499(eventid=eventid)>

<cfset attendees = attendeesStruct.query>
<cfset attendeesCount = attendeesStruct.recordCount>
