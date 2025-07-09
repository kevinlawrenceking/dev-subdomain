<cfcontent type="application/json">
<cfsetting showdebugoutput="false">

<cftry>
  <cfparam name="form.reminder_id" type="numeric">
  <cfparam name="form.new_status" type="string">

  <cfset userID = session.user_id>
  <cfset validStatus = "Completed,Skipped">

  <!-- Validate status -->
  <cfif NOT listFindNoCase(validStatus, form.new_status)>
    <cfthrow message="Invalid status.">
  </cfif>

  <!-- Update -->
  <cfquery datasource="abod" name="updateReminder">
    UPDATE funotifications
    SET
      notstatus = <cfqueryparam value="#form.new_status#" cfsqltype="cf_sql_varchar">,
      last_updated = GETDATE()
    WHERE
      id = <cfqueryparam value="#form.reminder_id#" cfsqltype="cf_sql_integer">
      AND user_id = <cfqueryparam value="#userID#" cfsqltype="cf_sql_integer">
  </cfquery>

  <cfoutput>#serializeJSON({ "success": true })#</cfoutput>

  <cfcatch>
    <cfoutput>#serializeJSON({ "success": false, "error": "#cfcatch.message#" })#</cfoutput>
  </cfcatch>
</cftry>
