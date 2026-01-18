<!--- This ColdFusion page handles user redirection based on the event ID. --->
<cfset userid = userid />

<cfparam name="eventid" default="0" />

<!--- Include the query template for data retrieval. --->
<cfinclude template="/include/qry/del_99_1.cfm" />

<!--- Set the return URL for redirection based on the event ID. --->
<cfoutput>
    <cfset returnurl = "/app/audition/?eventid=#eventid#&secid=177" />
</cfoutput>

<!--- Redirect the user to the specified return URL. --->
<cflocation url="#returnurl#">
