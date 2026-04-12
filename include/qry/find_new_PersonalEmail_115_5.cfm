<cfinclude template="/include/perfcount.cfm" />
<cfset contactItemService = request.svc("ContactItemService")>
<cfset find_new_PersonalEmail = contactItemService.SELcontactitems_23891(new_contactid=new_contactid)>