<!--- This ColdFusion page retrieves audio category data based on user ID and optional audio category ID. --->
<cfset dbug = "y" />
<cfparam name="new_audcatid" default="0" />
<cfparam name="new_userid" default="0" />

<!--- Query to select audio categories and user information --->
<cfinclude template="/include/qry/tname_sel_530_1.cfm" />

