<cfinclude template="/include/perfcount.cfm" />
<cfset bigBrotherService = createObject("component", "services.BigBrotherService")>
<cfset results = bigBrotherService.RESbigbrother(userId=30)>