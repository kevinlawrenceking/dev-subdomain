<cfinclude template="/include/perfcount.cfm" />
<cfset userService = request.svc("UserService")>
<cfset userService.UPDtaousers(view=view, userid=userid)>
<!--- PERF: Bust fetchUsers session cache so next request picks up the changes --->
<cfset session.bustUserCache = true>