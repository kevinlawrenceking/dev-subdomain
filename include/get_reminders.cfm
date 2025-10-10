<cfcontent type="application/json">
<cfsetting showdebugoutput="false">

<cfparam name="url.currentid" default="0" type="numeric">
<cfparam name="url.showInactive" default="0" type="numeric">
<cfparam name="url.userid" default="#session.userid#" type="numeric">
<cfset contactID = url.currentid>
<cfset showInactive = url.showInactive>
<cfset userid = url.userid>

<cfset host = ListFirst(cgi.server_name, ".")/>

<cfif host is "app">
    <cfset dsn = "abo"/>
<cfelse>
    <cfset dsn = "abod"/>
</cfif>

<!--- Get the system user ID for this contact --->
<cfquery name="getSu" datasource="#dsn#">
  SELECT suid
  FROM fusystemusers
  WHERE contactid = <cfqueryparam value="#contactID#" cfsqltype="cf_sql_integer">
    AND userid = <cfqueryparam value="#userid#" cfsqltype="cf_sql_integer">
    AND sustatus = 'Active'
</cfquery>

<cfif getSu.recordCount>
  <cfset sysActiveSuid = getSu.suid>
<cfelse>
  <cfoutput>#serializeJSON([])#</cfoutput>
  <cfabort>
</cfif>

<!--- Main reminders query --->
<cfquery name="getReminders" datasource="#dsn#">
  SELECT
    n.notID as id,
    n.actionID,
    n.userID,
    n.suID as suid,
    n.notStartDate,
    n.notEndDate,
    n.notStatus as status,
    n.ispastdue,
    a.actionTitle,
    a.actionDetails as reminder_text,
    a.actionInfo as action_info,
    a.actionDetails as action_details,
    ns.status_color,
    c.recordname as contactfullname,
    s.systemname as system_type,
    s.recordname as recordname,
    s.systemdescript as systemdescript,
    f.sustartdate as sustartDate,
    f.suenddate as suenddate,
    CONCAT('/app/contact/?contactid=', f.contactID) as hlink
  FROM funotifications n
  INNER JOIN fusystemusers f ON f.suID = n.suID
  INNER JOIN fuactions a ON a.actionID = n.actionID
  INNER JOIN notstatuses ns ON ns.notstatus = n.notStatus
  INNER JOIN fusystems s ON s.systemID = f.systemID
  LEFT JOIN contactdetails c ON c.contactid = f.contactid
  WHERE f.contactID = <cfqueryparam value="#contactID#" cfsqltype="cf_sql_integer">
    AND f.suID = <cfqueryparam value="#sysActiveSuid#" cfsqltype="cf_sql_integer">
    AND n.notStartDate IS NOT NULL
    AND n.notStartDate <= <cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">
    <cfif showInactive EQ 0>
      AND n.notStatus = 'Pending'
    </cfif>
  ORDER BY 
    FIELD(n.notStatus, 'Pending', 'Completed', 'Skipped'),
    n.notStartDate
</cfquery>

<cfset results = []>
<cfloop query="getReminders">
  <cfset notStartDatef = (notStartDate NEQ "") ? dateFormat(notStartDate, "mm/dd/yyyy") : "">
  <cfset notEndDatef = (notEndDate NEQ "") ? dateFormat(notEndDate, "mm/dd/yyyy") : "">
  
  <cfset arrayAppend(results, {
    "id": id,
    "actionID": actionID,
    "suid": suid,
    "notStartDatef": notStartDatef,
    "notEndDatef": notEndDatef,
    "status": status,
    "reminder_text": reminder_text,
    "action_info": action_info,
    "action_details": action_details,
    "contactfullname": contactfullname,
    "system_type": system_type,
    "recordname": recordname,
    "systemdescript": systemdescript,
    "sustartDate": sustartDate,
    "suenddate": suenddate,
    "hlink": hlink,
    "ispastdue": ispastdue
  })>
</cfloop>

<cfoutput>#serializeJSON(results, true)#</cfoutput>
