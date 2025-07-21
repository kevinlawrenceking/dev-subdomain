<!--- 
    PURPOSE: Common variables and settings for share functionality
    AUTHOR: Updated by GitHub Copilot
    DATE: 2025-07-20
    PARAMETERS: None
    DEPENDENCIES: None
--->

<!--- Do not define functions here, only set variables and parameters --->
<cfparam name="debug" default="NO">
<cfset appname = "The Actors Office" />
<cfset pgTitle = "Summary"  />
<!--- Import debug settings from parent if available --->
<cfif isDefined("variables.debug") AND variables.debug eq "YES">
    <cfset debug = "YES">
</cfif>

<!--- Ensure application variables are set --->
<cfif not structKeyExists(application, "dsn")>
    <cfif debug is "YES"><cfoutput><p style="background:##ffe6e6;padding:5px;border:1px solid red">Application DSN not found, initializing...</p></cfoutput></cfif>
    <cfset onApplicationStart() />
</cfif>
<cfset dsn = application.dsn />

<!--- Common variable defaults for share.cfm --->
<cfparam name="userid" default="0">
<cfparam name="userfirstname" default="">
<cfparam name="userlastname" default="">
<cfparam name="host" default="app">
<cfparam name="u" default="0">
<cfparam name="auditions" default="false">

<!--- Use built-in ColdFusion functions --->
<!--- Note: 'rand' is already a built-in ColdFusion function, so we don't need to define it --->
<!--- Instead, we can use it directly with RandRange() where needed --->
