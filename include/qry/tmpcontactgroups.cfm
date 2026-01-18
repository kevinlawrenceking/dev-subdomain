<!--- This ColdFusion page retrieves contact details based on a provided list of contact IDs. --->

<cfparam name="idlist" default="0" />

<!--- Query to fetch batch details from the contact details table based on the contact ID list --->
<cfinclude template="/include/qry/BatchDetails_548_1.cfm" />

