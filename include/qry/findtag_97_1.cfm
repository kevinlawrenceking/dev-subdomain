<cfset contactItemService = createObject("component", "services.ContactItemService") />
<cfif myteam.contactid eq ""><cfset myteam_contactid = 0><cfelse><cfset myteam_contactid = myteam.contactid></cfif>
<cfset findtag = contactItemService.SELcontactitems_23855(contactid=myteam_contactid) />