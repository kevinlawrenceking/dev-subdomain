<!--- This ColdFusion page handles the inclusion of a template and redirects the user to a specific URL based on event and project IDs. --->

<cfinclude template="/include/qry/audmedia_details_238_1.cfm" />

<!--- Redirect to the audition page with specified parameters. --->
<cflocation url="/app/audition/?eventid=#eventid#&audprojectid=#audprojectid#&secid=#secid#" />
