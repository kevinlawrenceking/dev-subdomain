<cfset componentPath = "/services/AuditionRoleService">
<cfset auditionRoleService = createObject("component", componentPath)>

<!--- Update role information --->
<cfset auditionRoleService.UPDaudroles_23810(
    new_audroleid = new_audroleid,
    new_incometypeid = new_incometypeid,
    new_payrate = new_payrate,
    new_netincome = new_netincome,
    new_buyout = new_buyout,
    new_paycycleid = new_paycycleid
)>

<!--- Get audprojectid from the audroleid --->
<cfquery name="getProjectID">
    SELECT audprojectid 
    FROM audroles 
    WHERE audroleid = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#new_audroleid#">
</cfquery>

<!--- Update conflict information --->
<cfif isDefined("getProjectID.audprojectid") AND getProjectID.recordCount GT 0>
    <cfset auditionRoleService.UPDaudprojects_conflict(
        audprojectid = getProjectID.audprojectid,
        conflict_notes = isDefined("form.new_conflict_notes") ? form.new_conflict_notes : "",
        conflict_enddate = isDefined("form.new_conflict_enddate") ? form.new_conflict_enddate : ""
    )>
</cfif>
