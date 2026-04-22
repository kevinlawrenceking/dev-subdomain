<cfinclude template="/include/perfcount.cfm" />
<cfset contactAuditionService = createObject("component", "services.ContactAuditionService")>

<cfset rowsDeleted = contactAuditionService.DELaudcontacts_auditions_xref_24545(audprojectid=audprojectid)>

<!--- Dev-only debug logger. Bare `userid` is NOT in CF's default scope search,
     and `application.dbug` may not be initialized on cold app start. Guard both. --->
<cfif structKeyExists(application, "dbug") AND application.dbug eq "Y"
      AND structKeyExists(session, "userid") AND session.userid eq 30>
<cfif rowsDeleted gt 0>
    <cfoutput>
        <Cfset msg="Successfully deleted #rowsDeleted# record(s) for Project ID #audprojectid#." />
    </cfoutput>
<cfelse>
    <cfoutput>
        <Cfset msg="No records were deleted for Project ID #audprojectid#." />
    </cfoutput>
</cfif>


<cfset debugService = createObject("component", "services.DebugService")>
<cfset debugService.insertDebugLog(
    filename = cgi.script_name,
    debugDetails = serializeJSON({
        operation = "Delete",
        audprojectid = audprojectid,
        rowsDeleted = rowsDeleted,
        message = msg
    })
)>

</cfif>
