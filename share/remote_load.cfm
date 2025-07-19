<!--- 
    PURPOSE: Handle loading of shared content for external viewing
    AUTHOR: Updated by GitHub Copilot
    DATE: 2025-07-19
    PARAMETERS: shareToken
    DEPENDENCIES: services.ContactItemService, services.ReminderService
--->

<cfparam name="url.shareToken" default="" />

<!--- Ensure we have access to the application datasource --->
<cfif not structKeyExists(application, "dsn")>
    <cfset onApplicationStart() />
</cfif>
<cfset dsn = application.dsn />
