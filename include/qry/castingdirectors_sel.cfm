<!--- This ColdFusion page retrieves casting directors' information from the database based on user ID and specific criteria. --->

<cfparam name="dbug" default="N" />

<!--- Query to select casting directors from the database --->
<cfinclude template="/include/qry/castingdirectors_sel_445_1.cfm" />

