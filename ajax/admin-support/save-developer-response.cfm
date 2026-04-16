<cfheader name="Content-Type" value="application/json">

<!--- ADMIN GUARD --->
<cfif NOT isDefined("session.isAdmin") OR session.isAdmin NEQ true>
  <cfoutput>{"success": false, "message": "Unauthorized."}</cfoutput>
  <cfabort>
</cfif>

<!--- INPUT --->
<cfparam name="form.ticketID" default="0">
<cfparam name="form.developerResponse" default="">

<cfif NOT isNumeric(form.ticketID) OR form.ticketID LT 1>
  <cfoutput>{"success": false, "message": "Invalid ticket ID."}</cfoutput>
  <cfabort>
</cfif>

<cftry>
  <!--- WHERE guard prevents overwriting after resolution email is sent --->
  <cfquery datasource="#application.dsn#">
    UPDATE tickets
    SET developerResponse = <cfqueryparam value="#form.developerResponse#" cfsqltype="cf_sql_longvarchar">
    WHERE ticketID = <cfqueryparam value="#form.ticketID#" cfsqltype="cf_sql_integer">
      AND resolvedEmailSentAt IS NULL
  </cfquery>
  <cfoutput>{"success": true}</cfoutput>

  <cfcatch type="any">
    <cflog type="error" log="application"
      text="TAO_ticket_errors: save-developer-response failed for ticket ###form.ticketID# -- #cfcatch.message#">
    <cfoutput>{"success": false, "message": "Save failed."}</cfoutput>
  </cfcatch>
</cftry>
