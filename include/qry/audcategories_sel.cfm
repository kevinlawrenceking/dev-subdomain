<!--- This ColdFusion page initializes parameters and includes a query template for retrieving audience categories. --->
<cfparam name="dbug" default="N" />

<cfset tname = "audcategories" /> <!--- Set the table name for audience categories --->
<cfset fid = "audcatid" />       <!--- Set the field identifier for audience category ID --->
<cfset fname = "audcatname" />   <!--- Set the field name for audience category name --->
<cfset orderby = "audcatname" /> <!--- Set the default order by field for audience categories --->
  
<cfinclude template="/include/qry/select_query.cfm" /> <!--- Include the query template for audience categories --->

