<!--- This ColdFusion page initializes parameters and includes a query for user categories related to audio genres. --->

<cfparam name="dbug" default="N" />

<cfset tname = "audgenres_user" />
<cfset fid = "audgenreid" />
<cfset fname = "audgenre" />
<cfset orderby = "audgenre" />

<!--- Include the query template for selecting user categories --->
<cfinclude template="/include/qry/select_cat_user_query.cfm" />
