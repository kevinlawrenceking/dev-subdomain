<!--- This ColdFusion page retrieves a list of essences for a specific user that are not marked as deleted. --->

<cfparam name="dbug" default="N" />

<!--- Query to select essences for the user --->
<cfinclude template="/include/qry/essence_sel_470_1.cfm" />

