<!--- This ColdFusion page initializes parameters and includes a query template for user tones. --->
<cfparam name="dbug" default="N" />

<!--- Set user ID for new user --->
<cfset new_userid = userid />

<!--- Define table and field names --->
<cfset tname = "audtones_user" />
<cfset fid = "toneid" />
<cfset fname = "tone" />
<cfset orderby = "tone" />

<!--- Include the query template for selecting user tones --->
<cfinclude template="/include/qry/select_cat_user_query.cfm" />
