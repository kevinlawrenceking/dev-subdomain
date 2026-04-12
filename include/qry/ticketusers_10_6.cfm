<cfinclude template="/include/perfcount.cfm" />
<cfset userService = request.svc("UserService")>
<cfset ticketusers = userService.SELtaousers_23721(ticketId=results.recid)>