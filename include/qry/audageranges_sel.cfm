<!--- This ColdFusion page sets up variables for database queries and includes a select query template. --->
<cfset dbug = "Y" />

<!--- Define table and field names for the query --->
<cfset tname = "audageranges" />
<cfset fid = "rangeid" />
<cfset fname = "rangename" />
<cfset orderby = "rangeid" />

<!--- Include the select query template --->
<cfinclude template = "/include/qry/select_query.cfm" />
