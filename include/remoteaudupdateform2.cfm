<!--- This ColdFusion page processes audition details and updates event information based on specific conditions. --->

<cfparam name="NEW_AUDBOOKTYPEID" default="0" />
<cfparam name="essence" default="" />

<!--- Include the initial query for finding records --->
<cfinclude template="/include/qry/FIND_222_1.cfm" />

<!--- Check conditions for CustomPlatform and handle accordingly --->
<cfif #new_audPlatformid# is "CustomPlatform" and #CustomPlatform# is not "" and #find.recordcount# is "0">
    <cfinclude template="/include/qry/insert_28_11.cfm" />
    <cfset new_audPlatformid = resultx />
<cfelseif #new_audplatformid# is "CustomPlatform" and #CustomPlatform# is not "" and #find.recordcount# is "1">
    <cfset new_audPlatformid = find.audplatformid />
<cfelseif #new_audplatformid# is "CustomPlatform" and #CustomPlatform# is "">
    <cfset new_audPlatformid = old_audplatformid />
</cfif>

<!--- Include additional queries for auditions and event activation --->
<cfinclude template="/include/qry/auditions_upd.cfm" />
<cfinclude template="/include/qry/activate_222_3.cfm" />

<cfinclude template="/include/qry/auditionDetails_222_5.cfm" />
<cfinclude template="/include/qry/projectDetails_222_6.cfm" />

<!--- Set variables based on audition and project details --->
<cfset new_audtypeid = auditionDetails.audtypeid />
<cfset new_audLocation = auditionDetails.audLocation />
<cfset new_audlocid = auditionDetails.audlocid />
<cfset new_eventStart = auditionDetails.eventStart />
<cfset new_eventStartTime = auditionDetails.eventStartTime />
<cfset new_eventStopTime = auditionDetails.eventStopTime />
<cfset new_contactid = projectDetails.contactid />
<cfset new_projname = projectDetails.projName />
<cfset new_projDescription = projectDetails.projDescription />

<!---<cfinclude template="/include/qry/FindEvent_222_4.cfm" /> --->

<!--- Prepare return URL for redirection --->
<cfoutput>
    <cfset returnurl = "/app/audition/?audprojectid=#audprojectid#&secid=#secid#" />
</cfoutput>

<!--- Redirect to the return URL --->
<cflocation url="#returnurl#" />

