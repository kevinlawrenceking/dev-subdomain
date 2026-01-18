<!--- Create an instance of the ContactService component --->
<cfset ContactService = createObject("component", "services.ContactService")>

<!--- Initialize the systemId to a default value --->
<cfset systemId = 0>

<!--- Check required inputs before proceeding --->
<cfif isDefined("projectDetails.audprojectdate") AND isDefined("new_contactid")>
    <!--- Fetch the system ID using the service function --->
    <cfset new_systemId = ContactService.getSystemIdBasedOnTag(
        audprojectDate = projectDetails.audprojectdate,
        new_contactid = new_contactid
    )>

</cfif>

