<cfset auditionRoleService = createObject("component", "services.AuditionRoleService")>

<!--- Handle empty numeric fields --->
<cfif new_audRoleTypeID EQ "">
    <cfset new_audRoleTypeID = 0>
</cfif>
<cfif new_audDialectID EQ "">
    <cfset new_audDialectID = 0>
</cfif>
<cfif new_audSourceID EQ "">
    <cfset new_audSourceID = 0>
</cfif>

<!--- Handle empty date fields --->
<cfif NOT isDate(new_holdStartDate)>
    <cfset new_holdStartDate = "1970-01-01">
</cfif>
<cfif NOT isDate(new_holdEndDate)>
    <cfset new_holdEndDate = "1970-01-01">
</cfif>

<!--- Call the function --->
<cfset new_audRoleID = auditionRoleService.INSaudroles_24593(
    new_audRoleName = new_audRoleName,
    new_audprojectID = new_audprojectID,
    new_audRoleTypeID = new_audRoleTypeID,
    new_charDescription = new_charDescription,
    new_holdStartDate = new_holdStartDate,
    new_holdEndDate = new_holdEndDate,
    new_audDialectID = new_audDialectID,
    new_audSourceID = new_audSourceID,
    new_userid = new_userid,
    new_isDeleted = new_isDeleted,
    isbooked = isbooked,
    isCallback = isCallback,
    ispin = ispin,
    isredirect = isredirect
)>
