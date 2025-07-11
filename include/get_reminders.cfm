<cfcontent type="application/json">
<cfsetting showdebugoutput="false">

<cfparam name="url.currentid" default="0" type="numeric">
<cfparam name="url.showInactive" default="0" type="numeric">

<cfset contactID = url.currentid>
<cfset showInactive = url.showInactive>

<cfif contactID EQ 0>
  <cfoutput>#serializeJSON({ "error": "Missing required parameter: currentid" }, true)#</cfoutput>
  <cfexit>
</cfif>

<cfquery name="getReminders" datasource="abod">
  SELECT
    n.notID,
    s.systemType,
    n.actionID,
    n.userID,
    n.suID,
    n.notStartDate,
    n.notStatus,
    n.ispastdue,

    a.actionTitle,
    a.actionDetails,
    a.actionInfo,

    ns.status_color,
    f.sustartDate,
    f.suEndDate,
    s.recordname,
    s.systemdescript

  FROM funotifications n
  INNER JOIN fusystemusers f ON f.suID = n.suID
  INNER JOIN fuactions a ON a.actionID = n.actionID
  INNER JOIN notstatuses ns ON ns.notstatus = n.notStatus
  INNER JOIN fusystems s ON s.systemID = f.systemid

  WHERE f.contactID = <cfqueryparam value="#contactID#" cfsqltype="cf_sql_integer">
    AND n.notStartDate IS NOT NULL
    
    <cfif showInactive EQ 1>
      AND n.notStatus IN ('Pending', 'Completed', 'Skipped')
    <cfelse>
      AND n.notStatus = 'Pending' AND n.notStartDate <= <cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">
    </cfif>

  ORDER BY 
    CASE 
      WHEN n.notStatus = 'Pending' THEN 1
      WHEN n.notStatus = 'Completed' THEN 2
      WHEN n.notStatus = 'Skipped' THEN 3
      ELSE 4
    END,
    n.notStartDate
</cfquery>

<cfset results = []>
<cfloop query="getReminders">
  <cfset formattedStart = (sustartDate NEQ "") ? dateFormat(sustartDate, "mm/dd/yyyy") : "">
  <cfset formattedEnd   = (suenddate NEQ "") ? dateFormat(suenddate, "mm/dd/yyyy") : "">

  <cfset arrayAppend(results, {
    "id": notID,
    "reminder_text": actionTitle,
    "due_date": dateFormat(notStartDate, "mm/dd/yyyy"),
    "status": notStatus,
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
