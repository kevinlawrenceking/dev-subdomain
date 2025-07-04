<cfcomponent displayname="UpdateLogService" hint="Handles operations for UpdateLog table" > 
<cffunction output="false" name="INSupdatelog" access="public" returntype="numeric">
    <cfargument name="oldvalue" type="string" required="true">
    <cfargument name="newvalue" type="string" required="true">
    <cfargument name="recordname" type="string" required="true">
    <cfargument name="updatename" type="string" required="true">
    <cfargument name="recid" type="numeric" required="true">
    <cfargument name="compid" type="numeric" required="true">
    <cfargument name="userid" type="numeric" required="true">
    <cfargument name="updatedetails" type="string" required="true">

<cfquery result="result">
        INSERT INTO updatelog (
            oldValue, NewValue, recordname, updatename, recid, compid, userid, updatedetails
        ) VALUES (
            <cfqueryparam value="#arguments.oldvalue#" cfsqltype="CF_SQL_VARCHAR">,
            <cfqueryparam value="#arguments.newvalue#" cfsqltype="CF_SQL_VARCHAR">,
            <cfqueryparam value="#arguments.recordname#" cfsqltype="CF_SQL_VARCHAR">,
            <cfqueryparam value="#arguments.updatename#" cfsqltype="CF_SQL_VARCHAR">,
            <cfqueryparam value="#arguments.recid#" cfsqltype="CF_SQL_INTEGER">,
            <cfqueryparam value="#arguments.compid#" cfsqltype="CF_SQL_INTEGER">,
            <cfqueryparam value="#arguments.userid#" cfsqltype="CF_SQL_INTEGER">,
            <cfqueryparam value="#arguments.updatedetails#" cfsqltype="CF_SQL_VARCHAR">
        )
    </cfquery>
    <cfreturn result.generatedKey>
</cffunction>
<cffunction output="false" name="RESupdatelog" access="public" returntype="query">
    <cfargument name="userId" type="numeric" required="true">

<cfquery name="result">
        SELECT 
            u.updateID, 
            u.oldValue, 
            u.newValue, 
            u.updateTimestamp AS col1, 
            u.updateTimestamp AS col2, 
            CONCAT(t.userFirstName, ' ', t.userLastName) AS col3, 
            p.compname AS col4, 
            u.recordname AS col5, 
            u.updatename AS col6, 
            u.updateDetails AS col7, 
            u.updateSource, 
            u.recid, 
            u.compId, 
            u.userid,
            'Date' AS head1,
            'Time' AS head2,
            'User' AS head3,
            'Module' AS head4,
            'Record' AS head5,
            'Label' AS head6,
            'Details' AS head7
        FROM updatelog u
        INNER JOIN taousers t ON t.userid = u.userid
        INNER JOIN pgcomps p ON p.compid = u.compid
        WHERE u.userid = <cfqueryparam value="#arguments.userId#" cfsqltype="CF_SQL_INTEGER">
        ORDER BY u.updateid DESC
    </cfquery>

<cfreturn result>
</cffunction>
</cfcomponent>