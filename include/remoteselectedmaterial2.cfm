<!--- This ColdFusion page handles user session data and includes necessary query templates for processing audition information. It then redirects the user to a specified URL. --->
<cfset userid = userid />

<!--- Include first query template for audition processing --->
<cfinclude template="/include/qry/ins_253_1.cfm" />

<!--- Include second query template for audition processing --->
<cfinclude template="/include/qry/ins_252_2.cfm" />

<!--- Set the return URL for redirection after processing --->
<cfoutput>
    <cfset returnurl = "/app/audition/?audprojectid=#audprojectid#&secid=177" />
</cfoutput>

<!--- Redirect the user to the return URL --->
<cflocation url="#returnurl#">

