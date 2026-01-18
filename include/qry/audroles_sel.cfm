<!--- This ColdFusion page sets up variables for querying user roles and includes a user query template. --->
<cfset dbug = "Y" />

<!--- Define table and field names for user roles --->
<cfset tname = "audroles" />
<cfset fid = "audroleid" />
<cfset fname = "audrolename" />
<cfset orderby = "audrolename" />

<!--- Include the user query template --->
<cfinclude template="/include/qry/select_user_query.cfm" />
