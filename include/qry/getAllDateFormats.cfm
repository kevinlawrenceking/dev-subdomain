<cfinclude template="/include/perfcount.cfm" />
<cfset dateFormatService = createObject("component", "services.DateFormatService")>
<cfset dateformats = dateFormatService.SELdateformats()>