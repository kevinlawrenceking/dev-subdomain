<!--- This ColdFusion page retrieves union information based on specified country and audit category IDs. --->
<cfparam name="dbug" default="N" />
<cfparam name="new_audcatid" default="0" />
<cfparam name="new_countryid" default="US" />

<!--- Query to select unions based on filters --->
<cfinclude template="/include/qry/audunions_sel_433_1.cfm" />

