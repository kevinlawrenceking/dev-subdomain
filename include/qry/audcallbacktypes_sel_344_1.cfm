<cfinclude template="/include/perfcount.cfm" />
<cfset AuditionCallbackTypeService = createObject("component", "services.AuditionCallbackTypeService")>
<cfset audcallbacktypes_sel = AuditionCallbackTypeService.SELaudcallbacktypes(audcatid=audcatid)>