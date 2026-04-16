<cfinclude template="/include/perfcount.cfm" />
<!--- This ColdFusion page fetches ticket details and ticket log information based on a given record ID. --->
<cfset ticketService = request.svc("TicketService")>

<!--- Fetch ticket details using the DETtickets_24767 function --->
<cfset ticketDetails = ticketService.DETtickets_24767(recid = #recid#)>

<!--- Fetch new notification columns + user email (not in DETtickets_24767) --->
<cfquery name="qTicketExtra" datasource="#application.dsn#">
  SELECT t.developerResponse, t.resolvedEmailSentAt, u.useremail
  FROM tickets t
  INNER JOIN taousers_tbl u ON u.userid = t.userid
  WHERE t.ticketID = <cfqueryparam value="#recid#" cfsqltype="cf_sql_integer">
</cfquery>

<!--- Fetch ticket log using the REStickets_24785 function --->
<cfset ticketLog = ticketService.REStickets_24785(recid = #recid#)>
