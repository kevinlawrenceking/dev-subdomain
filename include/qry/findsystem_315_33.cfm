<cfset systemUserService = createObject("component", "services.SystemUserService")>
<cfset findsystem = systemUserService.SELfusystemusers_24426(
    maint_contactid = maint_contactid,
    maint_systemid = maint_systemid
)>