
    <!--- Instantiate the SystemService component --->
    <cfset systemService = createObject("component", "services.SystemService")>
    
    <!--- Call the SELfusystems_24634 function to get the query --->
    <cfset systemNAMES = systemService.SELfusystems_24634()>

    <cftry>
    <!--- Instantiate the SystemService component --->
    <cfset systemService = createObject("component", "services.SystemService")>
    
    <!--- Call the SELfusystemtypes function to get the query --->
    <cfset variables.systems = systemService.SELfusystemtypes()>
    
    <!--- Validate that systems is a query and has records --->
    <cfif NOT isQuery(variables.systems) OR variables.systems.recordCount EQ 0>
        <cfthrow message="The query returned no results or was not executed properly.">
    </cfif>
    
<cfcatch type="any">
    <!--- Log the error for debugging purposes --->
    <cflog file="errorLog" text="[Error in fetchSystemTypes.cfm]: #cfcatch.message#">
</cfcatch>
</cftry>

<!--- This ColdFusion page includes different contact templates based on the device type (mobile or desktop) --->
<cfif #devicetype# is "mobile">
    <!--- Include the template for mobile contacts --->
    <cfinclude template="/include/contacts_all.cfm">
<cfelse>
    <!--- Include the template for desktop contacts --->
    <cfinclude template="/include/contacts.cfm">
</cfif>
