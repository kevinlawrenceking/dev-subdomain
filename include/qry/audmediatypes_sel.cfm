<!--- This ColdFusion page initializes parameters and includes a query template for retrieving media types. --->
<cfparam name="dbug" default="N" />

<cfset tname = "audmediatypes" />
<cfset fid = "mediatypeid" />
<cfset fname = "mediatype" />
<cfset orderby = "mediatype" />

<!--- Include the select query template for fetching media types --->
<cfinclude template="/include/qry/select_query.cfm" />
