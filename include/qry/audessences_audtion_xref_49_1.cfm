<cfset essenceService = createObject("component", "services.EssenceService") />
<cfset audessences_audtion_xref = essenceService.SELessences(audroleid=roledetails.audroleid) />