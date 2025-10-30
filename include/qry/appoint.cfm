 <cfinclude template="/include/qry/relationships_336_1.cfm" />
	 <cfinclude template="/include/qry/types_336_2.cfm" />
<cfinclude template="/include/qry/eventdetails_336_3.cfm" />

<cfset new_eventid = eventid />
 <cfset qContacts = application.services.ContactsService.listContacts({})>

 <cfinclude template="/include/qry/attendees_336_5.cfm" />


