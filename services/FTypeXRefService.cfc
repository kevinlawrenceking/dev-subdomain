<cfcomponent displayname="FTypeXRefService" hint="Handles operations for FTypeXRef table" > 
    <cffunction output="false" name="SELftypexref" access="public" returntype="query">
        <cfargument name="type" type="string" required="true">

<cfquery name="result">
            SELECT cfparam 
            FROM ftypexref_tbl 
            WHERE ftypefull = <cfqueryparam value="#arguments.type#" cfsqltype="CF_SQL_VARCHAR">
        </cfquery>

<cfreturn result>
    </cffunction>
</cfcomponent>