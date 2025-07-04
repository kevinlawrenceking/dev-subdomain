<!--- This ColdFusion page retrieves media information for a specific user, filtering out deleted items and specific media types. --->

<cfparam name="userid" default="0" />

<!--- Query to select headshots related to the user --->
<cfinclude template="/include/qry/headshots_sel_479_1.cfm" />

