<cfset sharesService = createObject("component", "services.ShareService")>
<cfset shares = sharesService.SELshares(userId=userid)>