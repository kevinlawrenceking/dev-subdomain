<cfcomponent displayname="AuditionQuestionsDefaultService" hint="Handles operations for AuditionQuestionsDefault table" > 
<cffunction output="false" name="INSaudquestions_default" access="public" returntype="numeric">
    <cfargument name="new_qTypeID" type="numeric" required="true">
    <cfargument name="new_qtext" type="string" required="true">
    <cfargument name="new_qorder" type="numeric" required="true">
    <cfargument name="new_isDeleted" type="boolean" required="true">

<cfquery result="result">
        INSERT INTO audquestions_default (qTypeID, qtext, qorder, isDeleted)
        VALUES (
            <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#arguments.new_qTypeID#">,
            <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.new_qtext#" maxlength="500">,
            <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#arguments.new_qorder#">,
            <cfqueryparam cfsqltype="CF_SQL_BIT" value="#arguments.new_isDeleted#">
        )
    </cfquery>
    <cfreturn result.generatedKey>
</cffunction>

<cffunction output="false" name="UPDaudquestions_default" access="public" returntype="void">
    <cfargument name="new_qTypeID" type="numeric" required="true">
    <cfargument name="new_qtext" type="string" required="true">
    <cfargument name="new_qorder" type="numeric" required="true">
    <cfargument name="new_isDeleted" type="boolean" required="true">
    <cfargument name="new_qID" type="numeric" required="true">

<cfquery result="result">
        UPDATE audquestions_default 
        SET 
            qTypeID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#arguments.new_qTypeID#">,
            qtext = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.new_qtext#" maxlength="500">,
            qorder = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#arguments.new_qorder#">,
            isDeleted = <cfqueryparam cfsqltype="CF_SQL_BIT" value="#arguments.new_isDeleted#">
        WHERE 
            qID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#arguments.new_qID#">
    </cfquery>
</cffunction>
</cfcomponent>