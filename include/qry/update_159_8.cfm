<cfinclude template="/include/perfcount.cfm" />
<cfset userService = request.svc("UserService")>
<cfset userService.UPDtaousers_23950(
    new_nletter_link = new_nletter_link,
    new_nletter_yn = new_nletter_yn,
    userid = userid
)>
<!--- PERF: Bust fetchUsers session cache so next request picks up the changes --->
<cfset session.bustUserCache = true>