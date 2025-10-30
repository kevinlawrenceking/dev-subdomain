 <cfinclude template="/include/qry/relationships_334_1.cfm" />
	 <cfinclude template="/include/qry/types_334_2.cfm" />
<cfinclude template="/include/qry/eventdetails_334_3.cfm" />

<cfset new_eventid = eventid />
 <cfset qContacts = application.services.ContactsService.listContacts({})>

 <cfinclude template="/include/qry/attendees_334_5.cfm" />


