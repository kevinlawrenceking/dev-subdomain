<!--- This ColdFusion page includes query templates and redirects to the audition page based on the provided project ID. --->
<cfinclude template="/include/qry/del_230_1.cfm" />
<cfinclude template="/include/qry/del2_230_2.cfm" />
<cfset eventContactsService = createObject("component", "services.EventContactsXRefService")>
<cfset eventContactsService.DELeventcontactsxref(eventIds=[eventid])>
<cflocation url="/app/audition/?audprojectid=#audprojectid#" />
<!--- Redirect to the audition page with the specified project ID --->

