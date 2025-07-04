<!--- This ColdFusion page initializes parameters and includes a query for selecting contract types. --->

<cfparam name="dbug" default="N" />

<cfset tname = "audcontracttypes" />
<cfset fid = "contracttypeid" />
<cfset fname = "contracttype" />
<cfset orderby = "contracttype" />

<!--- Include the query template for selecting contract types --->
<cfinclude template="/include/qry/select_cat_query.cfm" />
