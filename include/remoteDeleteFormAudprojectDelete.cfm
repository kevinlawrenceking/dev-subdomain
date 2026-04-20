<!--- Soft-deletes an audition project along with all its roles, appointments, and contact xrefs. --->

<cfparam name="audprojectid" default="0" />

<!--- Ownership guard: only allow the owning user to delete the project --->
<cfquery name="ownerCheck" datasource="#application.dsn#">
    SELECT audprojectid
    FROM audprojects
    WHERE audprojectid = <cfqueryparam value="#audprojectid#" cfsqltype="CF_SQL_INTEGER">
      AND userid = <cfqueryparam value="#session.userid#" cfsqltype="CF_SQL_INTEGER">
      AND isdeleted = 0
</cfquery>

<cfif ownerCheck.recordcount EQ 0>
    <cflocation url="/app/auditions/" addtoken="false" />
</cfif>

<!--- A project can have multiple roles; fetch all of them. --->
<cfquery name="projectRoles" datasource="#application.dsn#">
    SELECT audroleid
    FROM audroles
    WHERE audprojectid = <cfqueryparam value="#audprojectid#" cfsqltype="CF_SQL_INTEGER">
</cfquery>

<cfset eventService           = request.svc("EventService")>
<cfset auditionRoleService    = createObject("component", "services.AuditionRoleService")>
<cfset auditionProjectService = request.svc("AuditionProjectService")>
<cfset contactAuditionService = createObject("component", "services.ContactAuditionService")>
<cfset eventContactsService   = createObject("component", "services.EventContactsXRefService")>

<cfset deleteEventIds = []>

<cfloop query="projectRoles">
    <cfset roleEvents = eventService.SELevents_24123(audroleid=projectRoles.audroleid)>
    <cfloop query="roleEvents">
        <cfset arrayAppend(deleteEventIds, roleEvents.eventid)>
        <cfset eventService.UPDevents_24118(eventid=roleEvents.eventid)>
        <cfset eventService.UPDevents_24119(eventid=roleEvents.eventid)>
    </cfloop>
    <cfset auditionRoleService.UPDaudroles_24126(audroleid=projectRoles.audroleid)>
</cfloop>

<cfset auditionProjectService.UPDaudprojects_24125(audprojectid=audprojectid)>
<cfset contactAuditionService.DELaudcontacts_auditions_xref_24127(audprojectid=audprojectid)>

<cfif arrayLen(deleteEventIds)>
    <cfset eventContactsService.DELeventcontactsxref(eventIds=deleteEventIds)>
</cfif>

<cflocation url="/app/auditions/" addtoken="false" />
