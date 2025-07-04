<!--- This ColdFusion page retrieves contact items from the database based on the contact ID and category area. --->

<cfparam name="contactid" default="1" />

<!--- Query to select all items related to the contact ID and category area --->
<cfinclude template="/include/qry/itemsAll_489_1.cfm" />

