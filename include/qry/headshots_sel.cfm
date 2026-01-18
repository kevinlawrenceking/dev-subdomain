<!--- This ColdFusion page retrieves headshot media information for a specific user from the database. --->

<cfparam name="userid" default="0" />

<!--- Query to select headshots for the specified user --->
<cfinclude template="/include/qry/headshots_sel_478_1.cfm" />

