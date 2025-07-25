<cfcontent type="application/json">
<cfsetting showdebugoutput="false">

<cfparam name="url.currentid" default="0" type="numeric">
<cfparam name="url.showInactive" default="0" type="numeric">
<cfparam name="url.limit" default="5" type="numeric">
<cfset contactID = url.currentid>
<cfset showInactive = url.showInactive>
<cfset reminderLimit = url.limit>

<cfset host=ListFirst(cgi.server_name, ".")/>

<cfif host is "app">
    <cfset dsn="abo"/>
    <cfset information_schema="actorsbusinessoffice"/>
    <cfset suffix="_1.5"/>
<cfelse>
    <cfset dsn="abod"/>
    <cfset information_schema="actorsbusinessoffice"/>
    <cfset suffix="_1.5"/>
</cfif>

<!--- Dashboard-specific query: Get oldest reminder per contact, limited to 5 contacts --->
<cfquery name="getDashboardReminders" datasource="#dsn#">
  SELECT * FROM (
    SELECT
      n.notID,
      s.systemType,
      n.actionID,
      n.userID,
      n.suID,
      n.notStartDate,
      n.notStatus,
      n.ispastdue,
      n.notenddate,
      a.actionTitle,
      a.actionDetails,
      a.actionInfo,
      c.contactid,
      c.contactfullname,
      ns.status_color,
      f.sustartDate,
      f.suEndDate,
      s.recordname,
      s.systemdescript,
      ROW_NUMBER() OVER (PARTITION BY c.contactid ORDER BY n.notStartDate ASC, n.notID ASC) as rn

    FROM funotifications n
    INNER JOIN fusystemusers f ON f.suID = n.suID
    INNER JOIN fusystems s ON s.systemID = f.systemid
    INNER JOIN contactdetails c on c.contactid = f.contactid
    INNER JOIN fuactions a ON a.actionID = n.actionID
    INNER JOIN notstatuses ns ON ns.notstatus = n.notStatus

    WHERE c.userid = <cfqueryparam value="#userid#" cfsqltype="cf_sql_integer">
      AND n.notStartDate IS NOT NULL
      AND n.notStatus = 'Pending' 
      AND n.notStartDate <= <cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">
  ) ranked_reminders
  
  WHERE rn = 1
  ORDER BY notStartDate ASC

  <cfif reminderLimit GT 0>
  LIMIT <cfqueryparam value="#reminderLimit#" cfsqltype="cf_sql_integer">
  </cfif>
</cfquery>

<cfset results = []>
<cfloop query="getDashboardReminders">
  <cfset formattedStart = (sustartDate NEQ "") ? dateFormat(sustartDate, "mm/dd/yyyy") : "">
  <cfset formattedEnd   = (suenddate NEQ "") ? dateFormat(suenddate, "mm/dd/yyyy") : "">
  <cfset notStartDatef   = (notStartDate NEQ "") ? dateFormat(notStartDate, "mm/dd/yyyy") : "">
  <cfset notEndDatef     = (notEndDate NEQ "") ? dateFormat(notEndDate, "mm/dd/yyyy") : "">

  <cfset arrayAppend(results, {
    "id": notID,
    "reminder_text": actionTitle,
    "contactid": contactid,
    "notStartDatef": notStartDatef,
    "notEndDatef": notEndDatef,
    "status": notStatus,
    "contactfullname": contactfullname,
    "status_color": status_color,
    "ispastdue": ispastdue,
    "system_type": systemType,
    "action_info": actionInfo,
    "action_details": actionDetails,
    "suid": suid,
    "sustartDate": formattedStart,
    "suenddate": formattedEnd,
    "recordname": recordname,
    "systemdescript": systemdescript
  })>
</cfloop>

<cfoutput>#serializeJSON(results, true)#</cfoutput>
