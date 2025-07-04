<!--- This ColdFusion page handles redirection after updating audition details --->
<cfinclude template="/include/qry/update_56_1.cfm" />

<cfoutput>
    <!--- Set the return URL for redirection based on parameters --->
    <cfset returnurl = "/app/audition/?audprojectid=#audprojectid#&eventid=#eventid#&secid=#secid#" />
</cfoutput>

<!--- Redirect to the specified return URL --->
<cflocation url="#returnurl#">
