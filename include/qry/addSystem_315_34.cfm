<cfset systemUserService = createObject("component", "services.SystemUserService")>
<cfset systemUserService.INSfusystemusers_24427(
    maint_systemID = maint_systemID,
    maint_contactID = maint_contactID,
    userid = userid,
    suStartDate = suStartDate
)>