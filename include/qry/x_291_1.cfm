<cfinclude template="/include/perfcount.cfm" />
<cfset userService = request.svc("UserService")>
<cfquery result="result" name="userIds" >
    SELECT DISTINCT userid FROM shares
</cfquery>
<cfset x = userService.SELtaousers_24306(userIds=userIds)>