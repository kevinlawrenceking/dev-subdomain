<!--- This ColdFusion page sets up variables and includes a user query template for processing audit projects. --->
<cfset dbug = "Y" />

<!--- Define table name and field identifiers --->
<cfset tname = "audprojects" />
<cfset fid = "audprojectID" />
<cfset fname = "projname" />
<cfset orderby = "projname" />

<!--- Include the user query template --->
<cfinclude template = "/include/qry/select_user_query.cfm" />
