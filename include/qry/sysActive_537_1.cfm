<cfset systemUserService = createObject("component", "services.SystemUserService")>
<cfoutput>
  <hr>
  <strong>DEBUG VARS:</strong><br>
  currentid: #encodeForHtml(currentid)#<br>
  sessionUserId: #encodeForHtml(userid)#<br>
  hideCompleted: #encodeForHtml(hide_completed)#<br>
  <hr>
</cfoutput>
<cfset sysActive = systemUserService.SELfusystemusers_24758(
    currentid = currentid,
    sessionUserId = userid,
    hideCompleted = hide_completed
)>