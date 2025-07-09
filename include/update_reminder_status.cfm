<cfcontent type="application/json">
<cfsetting showdebugoutput="false">

<cfparam name="url.showInactive" default="0">

<cfset showInactive = url.showInactive>
<cfset userID = session.user_id>

<cfquery name="getReminders" datasource="abod">
  SELECT
    id,
    reminder_text,
    notstatus,
    CONVERT(varchar, notstartdate, 101) AS due_date,
    CONVERT(varchar, last_updated, 100) AS last_updated
  FROM funotifications
  WHERE
    user_id = <cfqueryparam value="#userID#" cfsqltype="cf_sql_integer">
    AND notstartdate IS NOT NULL
    AND notstartdate <= GETDATE()
    <cfif showInactive EQ 1>
      AND notstatus IN ('Pending', 'Completed', 'Skipped')
    <cfelse>
      AND notstatus = 'Pending'
    </cfif>
  ORDER BY notstartdate ASC
</cfquery>

<cfset results = []>
<cfloop query="getReminders">
  <cfset arrayAppend(results, {
    "id": id,
    "reminder_text": reminder_text,
    "status": notstatus,
    "due_date": due_date,
    "last_updated": last_updated
  })>
</cfloop>

<cfoutput>#serializeJSON(results)#</cfoutput>
