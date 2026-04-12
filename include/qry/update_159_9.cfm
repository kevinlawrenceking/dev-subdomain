<cfinclude template="/include/perfcount.cfm" />
<cfset userService = request.svc("UserService")>
<cfset userService.UPDtaousers_23951(
    calstarttime = calstarttime,
    calendtime = calendtime,
    defRows = defRows,
    defCountry = defCountry,
    defState = defState,
    userid = userid
)>
<!--- PERF: Bust fetchUsers session cache so next request picks up the changes --->
<cfset session.bustUserCache = true>