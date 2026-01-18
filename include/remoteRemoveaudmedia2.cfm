<!--- This ColdFusion page includes a query template and redirects to an audition page based on the provided project ID. --->

<cfinclude template="/include/qry/audmedia_details_225_1.cfm" />

<!--- Redirect to the audition page with the specified project ID and section ID. --->
<cflocation url="/app/audition/?audprojectid=#audprojectid#&secid=177" />

