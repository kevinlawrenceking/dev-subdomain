<cfinclude template="/include/perfcount.cfm" />
<cfset essencesService = createObject("component", "services.EssenceService")>
<cfset essences = essencesService.SELessences_24270(userid=userid)>