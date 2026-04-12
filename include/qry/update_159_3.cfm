<cfinclude template="/include/perfcount.cfm" />
<cfset userService = request.svc("UserService")>
<cfset userService.UPDtaousers_23945(
    new_userfirstname = new_userfirstname,
    new_userlastname = new_userlastname,
    new_avatarname = new_avatarname,
    new_useremail = new_useremail,
    userid = userid
)>
<!--- PERF: Bust fetchUsers session cache so next request picks up the changes --->
<cfset session.bustUserCache = true>