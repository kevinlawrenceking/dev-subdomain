<!--- Reminders page - shows all reminders for user across all contacts --->
<cfparam name="url.showInactive" default="0">
<cfset showContact = "Y">
<cfset contactid = 0>
<cfset userid = session.userid>

<cfinclude template="reminder_pane.cfm">