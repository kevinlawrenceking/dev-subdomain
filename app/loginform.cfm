<!---
    Legacy route shim. Old clients still request /app/loginform.cfm (4
    File-Not-Found hits in the error log). The canonical login page now lives
    at the web root: /loginform.cfm. Redirect there instead of 404-ing.

    Note: app/Application.cfc onRequestStart already bounces unauthenticated
    requests to /loginform.cfm before this template runs; this shim covers the
    authenticated / edge cases and removes the TemplateNotFound noise. No old
    login logic is recreated here.
--->
<cfheader statuscode="301" statustext="Moved Permanently" />
<cflocation url="/loginform.cfm" statuscode="301" addtoken="false" />
