<cfset systemUserService = createObject("component", "services.SystemUserService")>
<!---
<cfoutput>
  <div style="border:1px solid ##ccc; padding:10px; margin:10px 0;">
    <strong>DEBUG INPUTS</strong><br>
    currentid: <cfif isDefined("currentid")>#htmlEditFormat(currentid)#<cfelse><em>undefined</em></cfif><br>
    sessionUserId: <cfif isDefined("userid")>#htmlEditFormat(userid)#<cfelse><em>undefined</em></cfif><br>
    hideCompleted: <cfif isDefined("hide_completed")>#htmlEditFormat(hide_completed)#<cfelse><em>undefined</em></cfif><br>
  </div>
</cfoutput> --->

<cfset sysActive = systemUserService.SELfusystemusers_24758(
    currentid = currentid,
    sessionUserId = userid,
    hideCompleted = hide_completed
)>