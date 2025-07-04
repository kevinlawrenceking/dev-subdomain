<!--- This ColdFusion page updates the audunions table with new values based on provided parameters. --->
<cfparam name="new_unionName" default="" />
<cfparam name="new_countryid" default="" />
<cfparam name="new_audCatID" default="" />
<cfparam name="new_isDeleted" default="0" />

<!--- Execute the update query for audunions table --->
<cfinclude template="/include/qry/audunions_ins_434_1.cfm" />

