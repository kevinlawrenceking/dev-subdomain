<!--- This ColdFusion page retrieves active audio types from the database for display. --->
<cfparam name="dbug" default="N" />

<!--- Query to select audio types from the database --->
<cfinclude template="/include/qry/audtypes_sel_430_1.cfm" />

