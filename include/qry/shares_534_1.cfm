<cfinclude template="/include/perfcount.cfm" />
<cfset sharesService = createObject("component", "services.ShareService")>
<cfset shares = sharesService.SELshares(userId=userid)>