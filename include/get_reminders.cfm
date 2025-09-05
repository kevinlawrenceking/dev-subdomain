<cfcontent type="application/json">
<cfsetting showdebugoutput="false">

<cfparam name="url.currentid" default="0" type="numeric">
<cfparam name="url.showInactive" default="0" type="numeric">
<cfparam name="url.limit" default="0" type="numeric">
<cfset contactID = url.currentid>
<cfset showInactive = url.showInactive>
<cfset notificationLimit = url.limit>

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

<cfquery name="getNotifications" datasource="#dsn#">
  SELECT
    n.id,
    n.date_received,
    n.from_email,
    n.from_name,
    n.subject,
    n.message,
    n.read_status,
    n.created_date,
    n.updated_date
  FROM casting_notifications n
  WHERE n.userid = <cfqueryparam value="#userid#" cfsqltype="cf_sql_integer">
  
  <cfif contactid NEQ 0>
  AND n.contact_id = <cfqueryparam value="#contactID#" cfsqltype="cf_sql_integer">
  </cfif>
    
  <cfif showInactive EQ 1>
    AND n.read_status IN ('read', 'unread')
  <cfelse>
    AND n.read_status = 'unread'
  </cfif>

ORDER BY n.date_received DESC

<cfif notificationLimit GT 0>
LIMIT <cfqueryparam value="#notificationLimit#" cfsqltype="cf_sql_integer">
</cfif>
</cfquery>

<cfset results = []>
<cfloop query="getNotifications">
  <cfset dateReceivedf = (date_received NEQ "") ? dateFormat(date_received, "mm/dd/yyyy") : "">
  <cfset fromDisplay = (from_name NEQ "") ? from_name : from_email>
  
  <cfset arrayAppend(results, {
    "id": id,
    "date_received": dateReceivedf,
    "from": fromDisplay,
    "subject": subject,
    "message": message,
    "read_status": read_status,
    "created_date": created_date,
    "updated_date": updated_date
  })>
</cfloop>

<cfoutput>#serializeJSON(results, true)#</cfoutput>
