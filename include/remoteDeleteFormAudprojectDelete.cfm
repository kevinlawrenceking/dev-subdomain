<!--- This ColdFusion page processes project details, retrieves related role and event information, and performs deletions before redirecting to the auditions page. --->

<cfinclude template="/include/qry/projectDetails_232_1.cfm" />

<cfset audroleid = projectDetails.audroleid />

<cfinclude template="/include/qry/roleDetails_232_2.cfm" />

<cfinclude template="/include/qry/events_232_3.cfm" />

<!--- Collect event IDs and process deletions --->
<cfset deleteEventIds = []>
<cfloop query="events">
    <cfset new_eventid = events.eventid />
    <cfset arrayAppend(deleteEventIds, events.eventid)>
    <cfinclude template="/include/qry/del_232_4.cfm" />
</cfloop>

<cfinclude template="/include/qry/del2_232_5.cfm" />
<cfinclude template="/include/qry/del3_232_6.cfm" />
<cfinclude template="/include/qry/del4_232_7.cfm" />
<cfif arrayLen(deleteEventIds)>
    <cfset eventContactsService = createObject("component", "services.EventContactsXRefService")>
    <cfset eventContactsService.DELeventcontactsxref(eventIds=deleteEventIds)>
</cfif>

<!--- Redirect to the auditions page --->
<cflocation url="/app/auditions/" />

