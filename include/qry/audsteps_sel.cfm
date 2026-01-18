<!--- This ColdFusion page initializes parameters and includes a query for selecting data related to audit steps. --->
<cfparam name="dbug" default="N" />

<cfset tname = "audsteps" /> <!--- Set the table name for audit steps --->
<cfset fid = "audstepid" /> <!--- Set the field identifier for audit step ID --->
<cfset fname = "audstep" /> <!--- Set the field name for audit step --->
<cfset orderby = "audstep" /> <!--- Set the order by field for audit step --->
  
<cfinclude template="/include/qry/select_query.cfm" /> <!--- Include the select query template for fetching data --->

