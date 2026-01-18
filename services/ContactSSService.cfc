<cfcomponent displayname="ContactSSService" hint="Handles operations for ContactSS table" > 
<cffunction output="false" name="SELcontacts_ss" access="public" returntype="query">
    <cfargument name="userId" type="numeric" required="true">

<cfquery name="result">
        SELECT col1 
        FROM contacts_ss 
        WHERE userid = <cfqueryparam value="#arguments.userId#" cfsqltype="CF_SQL_INTEGER"> 
        AND col1 NOT LIKE <cfqueryparam value="%#chr(34)#%" cfsqltype="CF_SQL_VARCHAR">
    </cfquery>

<cfreturn result>
</cffunction>

<cffunction output="false" name="SELcontacts_ss_23946" access="public" returntype="query">
    <cfargument name="userid" type="numeric" required="true">
    <cfargument name="topsearch_myteam" type="string" required="true">

<cfquery name="result">
        SELECT CONTACTID 
        FROM contacts_ss 
        WHERE userid = <cfqueryparam value="#arguments.userid#" cfsqltype="CF_SQL_INTEGER"> 
        AND col1 = <cfqueryparam value="#arguments.topsearch_myteam#" cfsqltype="CF_SQL_VARCHAR">
    </cfquery>

<cfreturn result>
</cffunction>
</cfcomponent>