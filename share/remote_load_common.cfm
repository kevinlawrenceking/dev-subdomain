<!--- 
    PURPOSE: Common variables and settings for share functionality
    AUTHOR: Updated by GitHub Copilot
    DATE: 2025-07-19
    PARAMETERS: None
    DEPENDENCIES: None
--->

<!--- Do not define functions here, only set variables and parameters --->
<cfparam name="debug" default="NO">
<cfset appname = "The Actors Office" />
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
