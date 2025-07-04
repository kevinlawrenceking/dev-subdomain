<cfset objService = createObject("component", "services.AuditionNetworkUserService")>
<cfset new_networkid = objService.INSaudnetworks_user(
    CustomNetwork = CustomNetwork,
    audcatid = audcatid,
    userid = userid
)>