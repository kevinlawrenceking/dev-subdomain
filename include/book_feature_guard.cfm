<!---
  JSON guard for Book endpoints. Include right after <cfcontent type="application/json" reset="true">.
  When the Book switch (include/book_feature.cfm) is off: 403 + standard JSON envelope, nothing
  else in the endpoint runs (no service call, no query, no write).
--->
<cfinclude template="book_feature.cfm">
<cfif NOT request.bookFeatureEnabled>
    <cfheader statuscode="403" statustext="Feature Disabled">
    <cfoutput>#serializeJSON({ "success": false, "code": "FEATURE_DISABLED", "message": "This feature is temporarily unavailable.", "data": {} })#</cfoutput>
    <cfabort>
</cfif>
