<!--- This ColdFusion page processes audition location data and redirects the user to a specific URL based on parameters. --->

<!--- Safely setup form and URL parameters with cfparam --->
<cfparam name="form.audprojectid" default="0" />
<cfparam name="form.eventid" default="0" />
<cfparam name="form.focusid" default="0" />
<cfparam name="url.audprojectid" default="#form.audprojectid#" />
<cfparam name="url.eventid" default="#form.eventid#" />
<cfparam name="url.focusid" default="#form.focusid#" />

<!--- Set local variables from form/URL scope (URL takes precedence) --->
<cfset audprojectid = url.audprojectid NEQ 0 ? url.audprojectid : form.audprojectid />
<cfset eventid = url.eventid NEQ 0 ? url.eventid : form.eventid />
<cfset focusid = url.focusid NEQ 0 ? url.focusid : form.focusid />

<cfinclude template="/include/qry/audlocations_ins_58_1.cfm" /> 

<!--- Set the return URL based on audition project, event, section, and focus IDs. --->
<cfset returnurl = "/app/audition/?audprojectid=#audprojectid#&eventid=#eventid#&secid=181&focusid=#focusid#" />

<!--- Redirect the user to the constructed return URL. --->
<cflocation url="#returnurl#" />
