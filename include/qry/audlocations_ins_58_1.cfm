<cfset componentPath = "/services/AuditionProjectService">
<cfset auditionProjectService = createObject("component", componentPath)>

<!--- Get audprojectid from the audroleid --->
<cfquery name="getProjectID">
    SELECT audprojectid 
    FROM audroles 
    WHERE audroleid = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#new_audroleid#">
</cfquery>

<!--- Update all booking fields using the unified method --->
<cfif isDefined("getProjectID.audprojectid") AND getProjectID.recordCount GT 0>
    <cfset auditionProjectService.UPDaudprojects_23811(
        new_audprojectid = getProjectID.audprojectid,
        new_audroleid = new_audroleid,
        new_incometypeid = isDefined("new_incometypeid") ? new_incometypeid : "",
        new_payrate = isDefined("new_payrate") ? new_payrate : "",
        new_netincome = isDefined("new_netincome") ? new_netincome : "",
        new_buyout = isDefined("new_buyout") ? new_buyout : "",
        new_paycycleid = isDefined("new_paycycleid") ? new_paycycleid : "",
        new_conflict_notes = isDefined("form.new_conflict_notes") ? form.new_conflict_notes : "",
        new_conflict_enddate = isDefined("form.new_conflict_enddate") ? form.new_conflict_enddate : ""
    )>
</cfif>
