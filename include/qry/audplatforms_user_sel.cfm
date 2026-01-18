<!--- This ColdFusion page initializes parameters and includes a query for user data related to audio platforms. --->
<cfparam name="dbug" default="N" />

<cfset tname = "audplatforms_user" />
<cfset fid = "audplatformid" />
<cfset fname = "audplatform" />
<cfset orderby = "audplatform" />
<cfset new_userid = userid />

<!--- Include the query for audio platforms user selection --->
<cfinclude template="/include/qry/Audplatforms_user_sel_396_1.cfm" />
