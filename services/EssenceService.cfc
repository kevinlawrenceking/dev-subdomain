<cfcomponent displayname="EssenceService" hint="Handles operations for Essence table" > 
<cffunction output="false" name="SELessences" access="public" returntype="query">
    <cfargument name="audroleid" type="numeric" required="true">

<cfquery name="result">
        SELECT *
        FROM essences e
        INNER JOIN audessences_audtion_xref x ON x.essenceid = e.essenceid
        WHERE x.audroleid = <cfqueryparam value="#arguments.audroleid#" cfsqltype="CF_SQL_INTEGER">
    </cfquery>
    <cfreturn result>
</cffunction>

<cffunction output="false" name="UPDessences" access="public" returntype="void">
    <cfargument name="new_essenceid" type="numeric" required="true">
    <cfquery result="result">
        UPDATE essences
        SET isdeleted = 1
        WHERE essenceid = <cfqueryparam value="#arguments.new_essenceid#" cfsqltype="CF_SQL_INTEGER">
    </cfquery>
</cffunction>

<cffunction output="false" name="INSessences" access="public" returntype="numeric">
    <cfargument name="new_essenceName" type="string" required="true">
    <cfargument name="userid" type="numeric" required="true">
    <cfquery result="result">
        INSERT INTO essences (essenceName, userID)
        VALUES (
            <cfqueryparam value="#arguments.new_essenceName#" cfsqltype="CF_SQL_VARCHAR">,
            <cfqueryparam value="#arguments.userid#" cfsqltype="CF_SQL_INTEGER">
        )
    </cfquery>
    <cfreturn result.generatedKey>
</cffunction>

<cffunction output="false" name="DETessences" access="public" returntype="query">
    <cfargument name="essenceid" type="numeric" required="true">

<cfquery name="result">
        SELECT *
        FROM essences
        WHERE essenceid = <cfqueryparam value="#arguments.essenceid#" cfsqltype="CF_SQL_INTEGER">
    </cfquery>
    <cfreturn result>
</cffunction>

<cffunction output="false" name="UPDessences_24181" access="public" returntype="void">
    <cfargument name="new_essenceName" type="string" required="true">
    <cfargument name="isdeleted" type="numeric" default="0" required="false">
    <cfargument name="essenceid" type="numeric" required="true">

    <cfquery result="result">
        UPDATE essences 
        SET essenceName = <cfqueryparam value="#arguments.new_essenceName#" cfsqltype="CF_SQL_VARCHAR">, 
            isDeleted = <cfqueryparam value="#arguments.isdeleted#" cfsqltype="CF_SQL_INTEGER">
        WHERE essenceid = <cfqueryparam value="#arguments.essenceid#" cfsqltype="CF_SQL_INTEGER">
    </cfquery>
</cffunction>

<cffunction output="false" name="SELessences_24270" access="public" returntype="query">
    <cfargument name="userid" type="numeric" required="true">

<cfquery name="result">
        SELECT essenceid, essencename
        FROM essences
        WHERE userid = <cfqueryparam value="#arguments.userid#" cfsqltype="CF_SQL_INTEGER">
        AND isdeleted = 0
        ORDER BY essencename
    </cfquery>
    <cfreturn result>
</cffunction>

<cffunction output="false" name="SELessences_24282" access="public" returntype="query">
    <cfargument name="new_essence" type="string" required="true">
    <cfargument name="userid" type="numeric" required="true">

<cfquery name="result">
        SELECT essenceid AS new_essenceid
        FROM essences
        WHERE essencename = <cfqueryparam value="#arguments.new_essence#" cfsqltype="CF_SQL_VARCHAR">
        AND userid = <cfqueryparam value="#arguments.userid#" cfsqltype="CF_SQL_INTEGER">
        AND isdeleted = 0
    </cfquery>
    <cfreturn result>
</cffunction>

<cffunction output="false" name="INSessences_24283" access="public" returntype="numeric">
    <cfargument name="new_essence" type="string" required="true">
    <cfargument name="userid" type="numeric" required="true">
    <cfquery result="result">
        INSERT INTO essences (essenceName, userid, isdeleted)
        VALUES (
            <cfqueryparam value="#arguments.new_essence#" cfsqltype="CF_SQL_VARCHAR">,
            <cfqueryparam value="#arguments.userid#" cfsqltype="CF_SQL_INTEGER">,
            0
        )
    </cfquery>
    <cfreturn result.generatedKey>
</cffunction>

<cffunction output="false" name="SELessences_24658" access="public" returntype="query">
    <cfargument name="userid" type="numeric" required="true">

<cfquery name="result">
        SELECT 
            e.essenceid AS ID, 
            e.essencename AS NAME, 
            e.userid 
        FROM 
            essences e 
        WHERE 
            e.userID = <cfqueryparam value="#arguments.userid#" cfsqltype="CF_SQL_INTEGER"> 
            AND isdeleted = 0
        ORDER BY 
            e.essencename
    </cfquery>
    <cfreturn result>
</cffunction>
</cfcomponent>