<cfset auditionRoleService = createObject("component", "services.AuditionRoleService")>

<cfset roleArgs = {
    new_audRoleName = new_audRoleName,
    new_isDeleted = new_isDeleted,
    new_audRoleID = new_audRoleID
}>

<cfif isNumeric(new_opencallid)>
    <cfset roleArgs.new_opencallid = new_opencallid>
</cfif>
<cfif isNumeric(new_audRoleTypeID)>
    <cfset roleArgs.new_audRoleTypeID = new_audRoleTypeID>
</cfif>
<cfif isNumeric(new_audDialectID)>
    <cfset roleArgs.new_audDialectID = new_audDialectID>
</cfif>
<cfif isNumeric(new_audSourceID)>
    <cfset roleArgs.new_audSourceID = new_audSourceID>
</cfif>
<cfif isNumeric(new_contactid)>
<cfset roleArgs.new_contactid = new_contactid>
<Cfelse>
<cfset roleArgs.new_contactid = 0 />
    
</cfif>
<cfif isNumeric(new_submitsiteid)>
    <cfset roleArgs.new_submitsiteid = new_submitsiteid>
</cfif>

<cfif len(trim(new_charDescription))>
    <cfset roleArgs.new_charDescription = new_charDescription>
</cfif>

<cfset auditionRoleService.UPDaudroles_24299(argumentCollection=roleArgs)>
