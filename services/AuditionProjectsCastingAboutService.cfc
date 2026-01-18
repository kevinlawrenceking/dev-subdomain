<cfcomponent displayname="AuditionProjectsCastingAboutService" hint="Handles operations for AuditionProjectsCastingAbout table" > 
<cffunction output="false" name="INSaudprojects_castingabout" access="public" returntype="numeric">
    <cfargument name="new_projName" type="string" required="true">
    <cfargument name="new_projtye" type="string" required="true">
    <cfargument name="new_Status1" type="string" required="true">
    <cfargument name="new_Status2" type="string" required="true">
    <cfargument name="new_CastingAgency" type="string" required="true">
    <cfargument name="new_CastingDir" type="string" required="true">
    <cfargument name="new_CastingAssociate" type="string" required="true">
    <cfargument name="new_CastingAssistant" type="string" required="true">
    <cfargument name="new_Notes1" type="string" required="true">
    <cfargument name="new_Notes2" type="string" required="true">
    <cfargument name="new_Notes3" type="string" required="true">
    <cfargument name="new_CastingDir2" type="string" required="true">
    <cfargument name="new_audnetwork" type="string" required="true">

<cfquery result="result" name="insertQuery">
        INSERT INTO audprojects_castingabout (
            projName, projtye, Status1, Status2, CastingAgency, 
            CastingDir, CastingAssociate, CastingAssistant, 
            Notes1, Notes2, Notes3, CastingDir2, audnetwork
        ) VALUES (
            <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.new_projName#" maxlength="500">,
            <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.new_projtye#" maxlength="500">,
            <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.new_Status1#" maxlength="500">,
            <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.new_Status2#" maxlength="500">,
            <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.new_CastingAgency#" maxlength="500">,
            <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.new_CastingDir#" maxlength="500">,
            <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.new_CastingAssociate#" maxlength="500">,
            <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.new_CastingAssistant#" maxlength="500">,
            <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.new_Notes1#" maxlength="500">,
            <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.new_Notes2#" maxlength="500">,
            <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.new_Notes3#" maxlength="500">,
            <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.new_CastingDir2#" maxlength="500">,
            <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.new_audnetwork#" maxlength="500">
        )
    </cfquery>
    <cfreturn result.generatedKey>
</cffunction>

<cffunction output="false" name="UPDaudprojects_castingabout" access="public" returntype="void">
    <cfargument name="new_projName" type="string" required="true">
    <cfargument name="new_projtye" type="string" required="true">
    <cfargument name="new_Status1" type="string" required="true">
    <cfargument name="new_Status2" type="string" required="true">
    <cfargument name="new_CastingAgency" type="string" required="true">
    <cfargument name="new_CastingDir" type="string" required="true">
    <cfargument name="new_CastingAssociate" type="string" required="true">
    <cfargument name="new_CastingAssistant" type="string" required="true">
    <cfargument name="new_Notes1" type="string" required="true">
    <cfargument name="new_Notes2" type="string" required="true">
    <cfargument name="new_Notes3" type="string" required="true">
    <cfargument name="new_CastingDir2" type="string" required="true">
    <cfargument name="new_audnetwork" type="string" required="true">
    <cfargument name="new_ID" type="numeric" required="true">

<cfquery result="result" name="updateQuery">
        UPDATE audprojects_castingabout
        SET 
            projName = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.new_projName#" maxlength="500">,
            projtye = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.new_projtye#" maxlength="500">,
            Status1 = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.new_Status1#" maxlength="500">,
            Status2 = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.new_Status2#" maxlength="500">,
            CastingAgency = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.new_CastingAgency#" maxlength="500">,
            CastingDir = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.new_CastingDir#" maxlength="500">,
            CastingAssociate = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.new_CastingAssociate#" maxlength="500">,
            CastingAssistant = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.new_CastingAssistant#" maxlength="500">,
            Notes1 = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.new_Notes1#" maxlength="500">,
            Notes2 = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.new_Notes2#" maxlength="500">,
            Notes3 = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.new_Notes3#" maxlength="500">,
            CastingDir2 = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.new_CastingDir2#" maxlength="500">,
            audnetwork = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.new_audnetwork#" maxlength="500">
        WHERE ID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#arguments.new_ID#">
    </cfquery>
</cffunction>
</cfcomponent>