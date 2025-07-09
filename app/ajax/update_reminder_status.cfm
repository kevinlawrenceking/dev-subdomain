<cfcontent type="application/json; charset=utf-8">
<cfset dsn = application.dsn>
<cfparam name="form.reminder_id" default="">
<cfparam name="form.new_status" default="">

<cfif isNumeric(form.reminder_id) AND listFind('Pending,Completed,Skipped', form.new_status)>
  <cfquery datasource="#dsn#">
    UPDATE reminders
    SET status = <cfqueryparam value="#form.new_status#" cfsqltype="cf_sql_varchar">,
        last_updated = <cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">
    WHERE id = <cfqueryparam value="#form.reminder_id#" cfsqltype="cf_sql_integer">
  </cfquery>
  <cfoutput>#serializeJSON({"success": true})#</cfoutput>
<cfelse>
  <cfoutput>#serializeJSON({"success": false, "error": "Invalid input"})#</cfoutput>
</cfif>
