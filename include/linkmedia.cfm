<!--- This ColdFusion page handles redirection after processing audition project information. --->

<cfinclude template="/include/qry/linkmedia_152_1.cfm" />

<cfoutput>
    <!--- Set the return URL for redirection after processing. --->
    <cfset returnurl = "/app/audition/?audprojectid=#audprojectid#&secid=177" />
</cfoutput>

<!--- Redirect to the specified return URL. --->
<cflocation url="#returnurl#">
