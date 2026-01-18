<cfset systemUserService = createObject("component", "services.SystemUserService")>
<cfset oldSystemDetails = systemUserService.getOldSystemDetails(suid=suid)>

<cfoutput>
    Old System Scope: #oldSystemDetails.old_systemscope#<br>
    Old System Type: #oldSystemDetails.old_systemtype#
</cfoutput>