<cfheader name="Content-Type" value="application/json">

<!--- ADMIN GUARD --->
<cfif NOT isDefined("session.isAdmin") OR session.isAdmin NEQ true>
  <cfoutput>{"success": false, "message": "Unauthorized."}</cfoutput>
  <cfabort>
</cfif>

<!--- INPUT --->
<cfparam name="form.ticketID" default="0">
<cfif NOT isNumeric(form.ticketID) OR form.ticketID LT 1>
  <cfoutput>{"success": false, "message": "Invalid ticket ID."}</cfoutput>
  <cfabort>
</cfif>

<!--- FETCH TICKET + USER EMAIL (inline query — avoids modifying DETtickets_24767) --->
<cfquery name="qTicket" datasource="#application.dsn#">
  SELECT
    t.developerResponse,
    t.resolvedEmailSentAt,
    t.ticketdetails,
    t.ticketID,
    u.useremail
  FROM tickets t
  INNER JOIN taousers_tbl u ON t.userid = u.userid
  WHERE t.ticketID = <cfqueryparam value="#form.ticketID#" cfsqltype="cf_sql_integer">
    AND t.isdeleted = <cfqueryparam value="0" cfsqltype="cf_sql_bit">
</cfquery>

<cfif qTicket.recordCount EQ 0>
  <cfoutput>{"success": false, "message": "Ticket not found."}</cfoutput>
  <cfabort>
</cfif>

<!--- IDEMPOTENCY CHECK --->
<cfif isDate(qTicket.resolvedEmailSentAt)>
  <cfset sentLabel = DateTimeFormat(qTicket.resolvedEmailSentAt, "mmm d, yyyy h:mm tt")>
  <cfoutput>{"success": false, "message": "Resolution email already sent on #sentLabel#."}</cfoutput>
  <cfabort>
</cfif>

<!--- EMPTY RESPONSE CHECK --->
<cfif len(trim(qTicket.developerResponse)) EQ 0>
  <cfoutput>{"success": false, "message": "Developer response is required before sending."}</cfoutput>
  <cfabort>
</cfif>

<!--- BUILD EMAIL BODY --->
<cfsavecontent variable="resolutionEmailBody">
  <cfoutput>
  <html><body style="font-family: Arial, sans-serif; color: ##333;">
    <h2 style="color: ##2a7a2a;">Your Issue Has Been Resolved</h2>
    <p><strong>Original Request:</strong> #encodeForHtml(qTicket.ticketdetails)#</p>
    <hr>
    <h3>Resolution</h3>
    <pre style="background:##f5f5f5; padding:12px; border-left:4px solid ##2a7a2a;
                font-family:Arial,sans-serif; white-space:pre-wrap;">#encodeForHtml(qTicket.developerResponse)#</pre>
    <hr>
    <p>-- The Actors Office Support Team<br>support@theactorsoffice.com</p>
  </body></html>
  </cfoutput>
</cfsavecontent>

<!--- SEND + COMMIT (email outside transaction — commit only if send succeeds) --->
<cftry>
  <cfmail
    to="#qTicket.useremail#"
    from="support@theactorsoffice.com"
    failto="kking@theactorsoffice.com"
    replyto="support@theactorsoffice.com"
    bcc="kking@theactorsoffice.com"
    subject="Your support request has been resolved -- Ticket ###form.ticketID#"
    type="html"
    usessl="true"
    usetls="true">
    #resolutionEmailBody#
  </cfmail>

  <cftransaction>
    <cfquery datasource="#application.dsn#">
      UPDATE tickets
      SET resolvedEmailSentAt = <cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">
      WHERE ticketID = <cfqueryparam value="#form.ticketID#" cfsqltype="cf_sql_integer">
    </cfquery>

    <cfquery datasource="#application.dsn#">
      INSERT INTO ticketslog_tbl (tlogDetails, userID, ticketid, ticketstatus)
      VALUES (
        <cfqueryparam value="Resolution email sent to #qTicket.useremail#" cfsqltype="cf_sql_varchar">,
        <cfqueryparam value="#session.userid#" cfsqltype="cf_sql_integer">,
        <cfqueryparam value="#form.ticketID#" cfsqltype="cf_sql_integer">,
        <cfqueryparam value="resolution_email_sent" cfsqltype="cf_sql_varchar">
      )
    </cfquery>
  </cftransaction>

  <cfset sentAt = DateTimeFormat(now(), "mmm d, yyyy h:mm tt")>
  <cfoutput>{"success": true, "message": "Resolution email sent.", "data": {"sentAt": "#sentAt#", "sentTo": "#qTicket.useremail#"}}</cfoutput>

  <cfcatch type="any">
    <cflog type="error" log="application"
      text="TAO_ticket_errors: resolution email failed for ticket ###form.ticketID# -- #cfcatch.message#">
    <cfoutput>{"success": false, "message": "Email send failed. No changes were saved."}</cfoutput>
  </cfcatch>
</cftry>
