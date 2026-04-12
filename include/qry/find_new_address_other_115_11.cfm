<cfinclude template="/include/perfcount.cfm" />
<cfset contactItemService = request.svc("ContactItemService") />
<cfset find_new_address_other = contactItemService.SELcontactitems_23897(new_contactid=new_contactid) />