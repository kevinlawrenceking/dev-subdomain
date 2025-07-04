<!--- This ColdFusion page sets up variables for querying the 'audcategories' table and includes a select query template. --->

<cfset dbug = "Y" />

<cfset tname = "audcategories" />
<cfset fid = "audcatid" />
<cfset fname = "audcatname" />
<cfset orderby = "audcatname" />

<!--- Include the select query template for database operations --->
<cfinclude template="/include/qry/select_query.cfm" />
