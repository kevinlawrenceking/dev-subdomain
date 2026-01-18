<!--- This ColdFusion page retrieves active contact items from the database based on a specified contact ID. --->
<cfparam name="contactid" default="1" />

<!--- Query to fetch active contact items from the database --->
<cfinclude template="/include/qry/items_488_1.cfm" />

