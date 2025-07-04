<!--- This ColdFusion page retrieves details about media items from the database based on the provided media ID. --->

<cfparam name="userid" default="0" />

<!--- Query to fetch media details from the database --->
<cfinclude template="/include/qry/materials_details_493_1.cfm" />

