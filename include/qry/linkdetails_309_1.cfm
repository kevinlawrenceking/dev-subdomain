<cfinclude template="/include/perfcount.cfm" />
<cfset eventTypesUserService = createObject("component", "services.EventTypesUserService")>
<cfset linkdetails = eventTypesUserService.DETeventtypes_user(id=eventtypeid)>