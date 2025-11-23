<!--- Migrated from /include/qry/contacts_333_1.cfm - inline service call --->
<cfset contactService = createObject("component", "services.ContactService") />
<cfset contacts = contactService.SELcontactdetails_24483(userid=userid) />
	 <cfinclude template="/include/qry/types_333_2.cfm" />
