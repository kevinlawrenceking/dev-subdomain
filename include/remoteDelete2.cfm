<!--- This ColdFusion page redirects to the audition page based on the provided project ID and section ID. --->
<cfinclude template="/include/qry/audmedia_details_225_1.cfm" />

<!--- Redirect to audition page with specified project ID and section ID --->
<cflocation url="/app/audition/?audprojectid=#audprojectid#&secid=#secid#" />
