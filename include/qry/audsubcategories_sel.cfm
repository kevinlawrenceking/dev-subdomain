<!--- This ColdFusion page initializes parameters and includes a query for selecting categories. --->

<cfparam name="dbug" default="N" />

<cfset tname = "audsubcategories" />
<cfset fid = "audSubCatId" />
<cfset fname = "audSubCatName" />
<cfset orderby = "audSubCatNameSort" />

<!--- Include the category selection query template --->
<cfinclude template="/include/qry/select_cat_query.cfm" />
