<!--- This ColdFusion page retrieves headshot media information for a specific user that is not marked as deleted and is associated with a specific audition project. --->
<cfparam name="userid" default="0" />

<!--- Query to select headshots based on user ID and audition project ID --->
<cfinclude template="/include/qry/headshots_sel_495_1.cfm" />

