<!--- This ColdFusion page initializes parameters and includes a query template for selecting categories. --->
<cfparam name="dbug" default="y" />

<cfset tname = "auddialects" />
<cfset fid = "auddialectid" />
<cfset fname = "auddialect" />
<cfset orderby = "auddialect" />

<!--- Include the query template for selecting categories --->
<cfinclude template="/include/qry/select_cat_query.cfm" />
