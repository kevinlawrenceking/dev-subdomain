<cfset systemUserService = createObject("component", "services.SystemUserService")>
<cfset NewSUID = systemUserService.INSfusystemusers_23934(
    new_systemid = new_systemid,
    new_contactid = new_contactid,
    new_userid = new_userid,
    suStartDate = suStartDate,
    sunotes = sunotes
)>