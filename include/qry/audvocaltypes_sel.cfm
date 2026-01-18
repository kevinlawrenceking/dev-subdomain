<!--- This ColdFusion page initializes parameters and includes a select query for vocal types --->
<cfparam name="dbug" default="N" />

<cfset tname = "audvocaltypes" /> <!--- Set the table name for vocal types --->
<cfset fid = "vocaltypeid" /> <!--- Set the field identifier for vocal type --->
<cfset fname = "vocaltype" /> <!--- Set the field name for vocal type --->
<cfset orderby = "vocaltype" /> <!--- Set the order by clause for vocal type --->
  
<cfinclude template="/include/qry/select_query.cfm" /> <!--- Include the select query for vocal types --->
