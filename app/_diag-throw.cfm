<!--- TEMPORARY DIAGNOSTIC - DELETE AFTER TESTING.
      Forces an exception so app/Application.cfc onError -> ErrorService runs end to end
      (browser path: friendly screen + initial user email). Login-guarded so the error
      carries a real userid/email for the initial-email gate. --->
<cfif NOT structKeyExists(session, "userid") OR NOT isNumeric(session.userid)>
  <cflocation url="/loginform.cfm" addtoken="false" />
</cfif>
<cfthrow type="TAO.Diag.Test" message="Controlled test error (browser) - safe to ignore" detail="Triggered from /app/_diag-throw.cfm for error-flow QA." />
