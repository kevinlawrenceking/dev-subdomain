<cfparam name="form.notificationID" default="">
<cfparam name="form.status" default="">
<cfif isNumeric(form.notificationID) AND listFind("Completed,Skipped", form.status)>
  <cfquery datasource="#dsn#">
    UPDATE funotifications
    SET notstatus = <cfqueryparam value="#form.status#" cfsqltype="cf_sql_varchar">,
        notenddate = <cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">
    WHERE notid = <cfqueryparam value="#form.notificationID#" cfsqltype="cf_sql_integer">
  </cfquery>
  <cfoutput>{"success": true}</cfoutput>
<cfelse>
  <cfoutput>{"success": false, "error": "Invalid input"}</cfoutput>
</cfif>
