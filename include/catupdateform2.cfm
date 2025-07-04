<!--- This ColdFusion page includes a query and redirects the user to a specific URL based on provided parameters. --->
<cfinclude template="/include/qry/audprojects_ins_67_1.cfm" />

<!--- Set the return URL based on the audition project ID and section ID --->
<cfoutput>
    <cfset returnurl = "/app/audition/?audprojectid=#audprojectid#&secid=#secid#" />
</cfoutput>

<!--- Redirect the user to the constructed return URL --->
<cflocation url="#returnurl#">
