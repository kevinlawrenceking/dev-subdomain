<!--- This ColdFusion page sets parameters for database queries related to audience platforms. --->
<cfparam name="dbug" default="N" />

<cfset tname = "audplatforms" />
<cfset fid = "audplatformid" />
<cfset fname = "audplatform" />
<cfset orderby = "audplatform" />

<!--- Include the select query template for audience platforms --->
<cfinclude template="/include/qry/select_query.cfm" />
