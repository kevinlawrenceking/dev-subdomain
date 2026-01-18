<!--- This ColdFusion page sets up parameters and includes a query template for user data without deleted entries. --->
<cfparam name="dbug" default="N" />

<cfset tname = "audsources" />
<cfset fid = "audsourceid" />
<cfset fname = "audsource" />
<cfset orderby = "audsource" />

<!--- Include the user query template --->
<cfinclude template="/include/qry/select_user_query_noisdelete.cfm" />
