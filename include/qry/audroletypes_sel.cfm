<!--- This ColdFusion page initializes parameters and includes a query template for selecting categories. --->
<cfparam name="dbug" default="N" />

<cfset tname = "audroletypes" />
<cfset fid = "audroletypeid" />
<cfset fname = "audroletype" />
<cfset orderby = "audroletype" />

<!--- Include the query template for selecting categories --->
<cfinclude template="/include/qry/select_cat_query.cfm" />
