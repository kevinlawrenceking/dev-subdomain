<cfinclude template="/include/perfcount.cfm" />
<cfset contactItemService = request.svc("ContactItemService") />
<cfset castingdirectors_sel = contactItemService.SELcontactitems_24620(userid=userid) />