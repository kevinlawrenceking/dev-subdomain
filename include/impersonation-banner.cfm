<!---
    Impersonation banner.
    Rendered by core.cfm on every authenticated page. Visible only when an admin is
    currently viewing another user's account via the ?u= impersonation path.
    Gives the admin a clear, always-present way back to their own account.
--->
<cfif structKeyExists(session, "impersonating") AND session.impersonating>
  <cfset variables._impName = "">
  <cfif structKeyExists(session, "cachedUserData") AND isStruct(session.cachedUserData)>
    <cfif structKeyExists(session.cachedUserData, "userFirstName")>
      <cfset variables._impName = trim(session.cachedUserData.userFirstName)>
    </cfif>
    <cfif structKeyExists(session.cachedUserData, "userLastName")>
      <cfset variables._impName = trim(variables._impName & " " & session.cachedUserData.userLastName)>
    </cfif>
  </cfif>
  <cfoutput>
  <div id="taoImpersonationBanner"
       style="position:fixed;left:0;right:0;bottom:0;z-index:20000;background:##b91c1c;color:##fff;
              padding:8px 16px;font-family:Arial,Helvetica,sans-serif;font-size:14px;
              box-shadow:0 -2px 8px rgba(0,0,0,.25);display:flex;align-items:center;
              justify-content:center;gap:14px;flex-wrap:wrap;">
    <span>Admin view &mdash; you are logged in as
      <strong>#encodeForHtml(len(variables._impName) ? variables._impName : "this user")#</strong>
      (uid #encodeForHtml(session.userid)#).</span>
    <a href="/app/admin-users/stop-impersonate.cfm"
       style="background:##fff;color:##b91c1c;font-weight:600;text-decoration:none;
              padding:4px 12px;border-radius:4px;white-space:nowrap;">Return to admin</a>
  </div>
  </cfoutput>
</cfif>
