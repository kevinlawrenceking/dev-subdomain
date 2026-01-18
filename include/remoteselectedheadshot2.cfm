<!--- This ColdFusion page handles user session data and includes query templates for processing audition information. It redirects the user to a specific URL after setting the return URL. --->
<cfset userid = userid />

<!--- Include first query template for audition processing --->
<cfinclude template="/include/qry/ins_252_1.cfm" />

<!--- Include second query template for audition processing --->
<cfinclude template="/include/qry/ins_252_2.cfm" />

<!--- Set the return URL for redirection after processing --->
<cfoutput>
    <cfset returnurl = "/app/audition/?audprojectid=#audprojectid#&secid=196" />
</cfoutput>

<!--- Redirect the user to the specified return URL --->
<cflocation url="#returnurl#" />
