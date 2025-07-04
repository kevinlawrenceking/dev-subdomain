<!--- This ColdFusion page retrieves active system users for a specific contact and user, with an option to hide completed statuses. --->

<cfparam name="hide_completed" default="N" />

<!--- Query to fetch active system users based on contact ID and user ID --->
<cfinclude template="/include/qry/sysActive_537_1.cfm" />

