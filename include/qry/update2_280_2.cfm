<cfset reportRangeService = createObject("component", "services.ReportRangeService") />
<cfif IsDate(new_rangeend)>
<cfset reportRangeService.UPDreportranges(new_rangestart=new_rangestart, new_rangeend=new_rangeend, current_rangeid=current_rangeid) />
</cfif>