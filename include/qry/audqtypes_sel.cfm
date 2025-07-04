<!--- This ColdFusion page sets up variables for querying audit types and includes a select query template. --->
<cfset dbug = "Y" />

<!--- Set table and field names for the query --->
<cfset tname = "audqtypes" />
<cfset fid = "qtypeid" />
<cfset fname = "qtype" />
<cfset orderby = "qtype" />

<!--- Include the select query template --->
<cfinclude template = "/include/qry/select_query.cfm" />
