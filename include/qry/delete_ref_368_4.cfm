<cfset contactAuditionService = createObject("component", "services.ContactAuditionService")>

<cfset rowsDeleted = contactAuditionService.DELaudcontacts_auditions_xref_24545(audprojectid=audprojectid)>

<Cfif application.dbug eq "Y" and userid eq 30 >
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
