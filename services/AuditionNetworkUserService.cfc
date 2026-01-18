<cfcomponent displayname="AuditionNetworkUserService" hint="Handles operations for AuditionNetworkUser table" >

<cffunction output="false" name="INSaudnetworks_user" access="public" returntype="numeric">

<cfargument name="CustomNetwork" type="string" required="true">
        <cfargument name="audcatid" type="numeric" required="true">
        <cfargument name="userid" type="numeric" required="true">

<cfquery result="result">
            INSERT INTO audnetworks_user_tbl (network, audcatid, userid)
            VALUES (
                <cfqueryparam value="#arguments.CustomNetwork#" cfsqltype="CF_SQL_VARCHAR">,
                <cfqueryparam value="#arguments.audcatid#" cfsqltype="CF_SQL_INTEGER">,
                <cfqueryparam value="#arguments.userid#" cfsqltype="CF_SQL_INTEGER">
            )
        </cfquery>
        <cfreturn result.generatedKey>
    </cffunction>
</cfcomponent>