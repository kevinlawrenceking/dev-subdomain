<cfcontent type="application/json; charset=utf-8">
<cfset dsn = application.dsn>
<cfparam name="url.showInactive" default="0">

<cfquery name="qRem" datasource="#dsn#">
  SELECT id, reminder_text, status, due_date, last_updated
  FROM reminders
  <cfif NOT val(url.showInactive)>
    WHERE status = 'Pending'
  </cfif>
  ORDER BY due_date
</cfquery>

<cfset data = []>
<cfloop query="qRem">
  <cfset arrayAppend(data, {
    id: qRem.id,
    reminder_text: qRem.reminder_text,
    due_date: dateFormat(qRem.due_date, "mm/dd/yyyy"),
    status: qRem.status,
    last_updated: dateFormat(qRem.last_updated, "mm/dd/yyyy")
  })>
</cfloop>

<cfoutput>#serializeJSON({data:data})#</cfoutput>
