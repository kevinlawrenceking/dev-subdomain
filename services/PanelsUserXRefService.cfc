<cfcomponent displayname="PanelsUserXRefService" hint="Handles operations for PanelsUserXRef table" > 
    <cffunction output="false" name="DELpgpanels_user_xref" access="public" returntype="void">
        <cfargument name="userid" type="numeric" required="true">

<cfquery result="result">
            DELETE FROM pgpanels_user_xref 
            WHERE userid = <cfqueryparam value="#arguments.userid#" cfsqltype="CF_SQL_INTEGER">
        </cfquery>
    </cffunction>

<cffunction output="false" name="INSpgpanels_user_xref" access="public" returntype="numeric">
        <cfargument name="newpnid" type="numeric" required="true">
        <cfargument name="newuserid" type="numeric" required="true">

<cfquery result="result">
            INSERT INTO pgpanels_user_xref (pnid, userid) 
            VALUES (
                <cfqueryparam value="#arguments.newpnid#" cfsqltype="CF_SQL_INTEGER">,
                <cfqueryparam value="#arguments.newuserid#" cfsqltype="CF_SQL_INTEGER">
            )
        </cfquery>
    </cffunction>
</cfcomponent>