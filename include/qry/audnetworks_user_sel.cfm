<!--- This ColdFusion page initializes parameters and includes a query for selecting user categories related to ad networks. --->
<cfparam name="dbug" default="N" />

<cfset tname = "audnetworks_user" />
<cfset fid = "networkid" />
<cfset fname = "network" />
<cfset orderby = "network" />
<cfset new_userid = cookie.userid />

<!--- Include the user category selection query --->
<cfinclude template="/include/qry/select_cat_user_query.cfm" />
