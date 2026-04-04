<cfset systemUserService = request.svc("SystemUserService")>
<cfset result = systemUserService.INSfusystemusers_24477(
    systemID = systemID,
    contactID = contactID,
    userID = userid,
    suStartDate = suStartDate
)>