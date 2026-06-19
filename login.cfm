<!---
    Legacy route shim. Old clients / bookmarks / bots still request /login.cfm
    (16 File-Not-Found hits in the error log). The canonical login page is
    /loginform.cfm. Permanent redirect so callers and search engines update,
    and the 404 log spam stops. No login logic lives here by design.
--->
<cfheader statuscode="301" statustext="Moved Permanently" />
<cflocation url="/loginform.cfm" statuscode="301" addtoken="false" />
