<!--- This ColdFusion page handles the initialization of parameters for an audition location and redirects to a specified URL after processing. --->

<cfparam name="new_audlocid" default="" />
<cfparam name="new_eventLocation" default="" />
<cfparam name="new_audlocadd1" default="" />
<cfparam name="new_audlocadd2" default="" />
<cfparam name="new_audcity" default="" />
<cfparam name="new_audzip" default="" />
<cfparam name="new_region_id" default="" />
<cfparam name="new_isDeleted" default="0" />

<!--- Include the query for updating audition locations --->
<cfinclude template="/include/qry/audlocations_upd_37_1.cfm" />

<!--- Set the return URL for redirection after processing --->
<cfoutput>
    <cfset returnurl = "/app/audition/?audprojectid=#audprojectid#&eventid=#eventid#&secid=#secid#&focusid=#eventid#" />
</cfoutput>

<!--- Redirect to the specified return URL --->
<cflocation url="#returnurl#" />
