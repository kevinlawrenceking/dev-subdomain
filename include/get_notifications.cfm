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
    external_id, 
    fk_submitsite, 
    submitted_at, 
    sender, 
    subject,
    message, 
    request_type, 
    audition_date, 
    is_viewed, 
    request_id, 
    profile_id, 
    account_id, 
    created_at, 
    userid
  FROM audition_notifications
  WHERE userid = <cfqueryparam value="#userid#" cfsqltype="cf_sql_integer">
  
  <cfif showInactive EQ 1>
    AND is_viewed IN (0, 1)
  <cfelse>
    AND is_viewed = 0
  </cfif>

  ORDER BY submitted_at DESC

  <cfif notificationLimit GT 0>
    LIMIT <cfqueryparam value="#notificationLimit#" cfsqltype="cf_sql_integer">
  </cfif>
</cfquery>

<cfset results = []>
<cfloop query="getNotifications">
  <cfset dateReceivedf = (submitted_at NEQ "") ? dateFormat(submitted_at, "mm/dd/yyyy") : "">
  <cfset auditionDatef = (audition_date NEQ "") ? dateFormat(audition_date, "mm/dd/yyyy") : "">
  <cfset createdAtf = (created_at NEQ "") ? dateFormat(created_at, "mm/dd/yyyy") : "">

  <cfset arrayAppend(results, {
    "external_id": external_id,
    "fk_submitsite": fk_submitsite,
    "date_received": dateReceivedf,
    "from": sender,
    "subject": subject,
    "message": message,
    "request_type": request_type,
    "audition_date": auditionDatef,
    "is_viewed": is_viewed,
    "request_id": request_id,
    "profile_id": profile_id,
    "account_id": account_id,
    "created_at": createdAtf,
    "userid": userid
  })>
</cfloop>

<cfoutput>#serializeJSON(results, true)#</cfoutput>
