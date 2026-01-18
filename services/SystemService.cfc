<cfcomponent displayname="SystemService" hint="Handles operations for System table" >


    <!--- Finds a system by its ID ---> 
    <cffunction name="findSystemByID" access="public" returntype="query" output="false" hint="Finds a system by its ID">
        <cfargument name="suid" type="numeric" required="true" hint="The system ID to search for">
        
        <cfquery name="findSystemByID" >
            SELECT 
                s.systemid,
                s.systemscope,
                s.systemtype
            FROM 
                fusystems s
            INNER JOIN 
                fusystemusers u ON u.systemid = s.systemid
            WHERE 
                u.suid = <cfqueryparam value="#arguments.suid#" cfsqltype="CF_SQL_INTEGER">
        </cfquery>
        
        <cfreturn findSystemByID>
    </cffunction>




<cffunction output="false" name="SELfusystemtypes" access="public" returntype="query" >
    <cfquery result="result" name="queryResult">
        SELECT systemtype AS ID, systemtype AS systemname 
        FROM fusystemtypes 
        ORDER BY systemtype
    </cfquery>
    <cfreturn queryResult>
</cffunction>

<cffunction output="false" name="SELfusystems_23821" access="public" returntype="query">
    <cfargument name="newsystemscope" type="string" required="true">

<cfquery name="result">
        SELECT s.systemid
        FROM fusystems s
        WHERE s.systemtype = <cfqueryparam value="Maintenance List" cfsqltype="CF_SQL_VARCHAR">
        AND s.systemscope = <cfqueryparam value="#arguments.newsystemscope#" cfsqltype="CF_SQL_VARCHAR">
    </cfquery>

<cfreturn result>
</cffunction>

<cffunction output="false" name="SELfusystems_23933" access="public" returntype="query">
    <cfargument name="new_userid" type="numeric" required="true">
    <cfargument name="new_contactid" type="numeric" required="true">
    <cfargument name="new_systemid" type="numeric" required="false">

<cfquery name="result">
        SELECT su.suid 
        FROM fusystems s 
        INNER JOIN fusystemusers su ON su.systemID = s.systemid 
        WHERE su.suStatus = <cfqueryparam value="Active" cfsqltype="CF_SQL_VARCHAR"> 
        AND su.userid = <cfqueryparam value="#arguments.new_userid#" cfsqltype="CF_SQL_INTEGER"> 
        AND su.contactid = <cfqueryparam value="#arguments.new_contactid#" cfsqltype="CF_SQL_INTEGER"> 
        AND (s.systemid = <cfqueryparam value="#arguments.new_systemid#" cfsqltype="CF_SQL_INTEGER" null="#not structKeyExists(arguments, 'new_systemid')#"> 
             OR s.systemid IN (<cfqueryparam value="3,4" cfsqltype="CF_SQL_INTEGER" list="true">))
    </cfquery>

<cfreturn result>
</cffunction>

<cffunction output="false" name="DETfusystems" access="public" returntype="query">
    <cfargument name="systemId" type="numeric" required="true">

<cfquery name="result">
        SELECT *
        FROM fusystems
        WHERE systemid = <cfqueryparam value="#arguments.systemId#" cfsqltype="CF_SQL_INTEGER">
    </cfquery>

<cfreturn result>
</cffunction>

<cffunction output="false" name="SELfusystems_23938" access="public" returntype="query">
    <cfargument name="new_systemid" type="numeric" required="true">
    <cfargument name="new_userid" type="numeric" required="true">

<cfquery name="result">
        SELECT 
            s.systemID, s.systemName, s.SystemType, s.SystemScope, s.SystemDescript, 
            s.SystemTriggerNote, a.actionID, a.actionNo, a.actionDetails, a.actionTitle, 
            a.navToURL, au.actionDaysNo, au.actionDaysRecurring, a.actionNotes, 
            a.actionInfo, a.IsUnique, a.uniquename
        FROM 
            fusystems s 
        INNER JOIN 
            fuactions a ON s.systemid = a.systemid 
        INNER JOIN 
            actionusers au ON au.actionid = a.actionid 
        WHERE 
            a.systemID = <cfqueryparam value="#arguments.new_systemid#" cfsqltype="CF_SQL_INTEGER"> 
            AND au.userid = <cfqueryparam value="#arguments.new_userid#" cfsqltype="CF_SQL_INTEGER"> 
            AND au.actionDaysNo IS NOT NULL 
            AND a.actionID IS NOT NULL 
        ORDER BY 
            a.actionNo
    </cfquery>

<cfreturn result>
</cffunction>

<cffunction output="false" name="SELfusystems_23944" access="public" returntype="query">
    <cfargument name="userid" type="numeric" required="true">

<cfquery name="result">
        SELECT 
            au.id, 
            s.systemID, 
            s.systemName, 
            s.SystemType, 
            s.SystemScope, 
            s.SystemDescript, 
            s.SystemTriggerNote, 
            a.actionID, 
            a.actionNo, 
            a.actionDetails, 
            a.actionTitle, 
            a.navToURL, 
            au.actionDaysNo, 
            au.actionDaysRecurring, 
            a.actionNotes, 
            a.actionInfo
        FROM fusystems s
        INNER JOIN fuactions a ON s.systemid = a.systemid
        INNER JOIN actionusers au ON au.actionid = a.actionid
        WHERE au.userid = <cfqueryparam value="#arguments.userid#" cfsqltype="CF_SQL_INTEGER">
        ORDER BY a.actionNo
    </cfquery>

<cfreturn result>
</cffunction>

<cffunction output="false" name="SELfusystems" access="public" returntype="query">
    <cfargument name="new_systemid" type="numeric" required="true">
    <cfargument name="userid" type="numeric" required="true">

<cfquery name="result" >
            SELECT 
                s.systemID, 
                s.systemName, 
                s.SystemType, 
                s.SystemScope, 
                s.SystemDescript, 
                s.SystemTriggerNote, 
                a.actionID, 
                a.actionNo, 
                a.actionDetails, 
                a.actionTitle, 
                a.navToURL, 
                au.actionDaysNo, 
                au.actionDaysRecurring, 
                a.actionNotes, 
                a.actionInfo, 
                a.IsUnique, 
                a.uniquename
            FROM fusystems s
            INNER JOIN fuactions a ON s.systemid = a.systemid
            INNER JOIN actionusers au ON au.actionid = a.actionid
            WHERE s.systemID = <cfqueryparam value="#arguments.new_systemid#" cfsqltype="CF_SQL_INTEGER">
            AND au.userid = <cfqueryparam value="#arguments.userid#" cfsqltype="CF_SQL_INTEGER">
            ORDER BY a.actionNo
        </cfquery>

<cfreturn result>

</cffunction>

<cffunction output="false" name="DETfusystems_24029" access="public" returntype="query">
    <cfargument name="id" type="numeric" required="true">

<cfquery name="result" >
            SELECT 
                au.id, 
                s.systemID, 
                s.systemName, 
                s.SystemType, 
                s.SystemScope, 
                s.SystemDescript, 
                s.SystemTriggerNote, 
                a.actionID, 
                a.actionNo, 
                a.actionDetails, 
                a.actionTitle, 
                a.navToURL, 
                au.actionDaysNo, 
                au.actionDaysRecurring, 
                a.actionNotes, 
                a.actionInfo
            FROM fusystems s
            INNER JOIN fuactions a ON s.systemid = a.systemid
            INNER JOIN actionusers au ON au.actionid = a.actionid
            WHERE au.id = <cfqueryparam value="#arguments.id#" cfsqltype="CF_SQL_INTEGER">
        </cfquery>

<cfreturn result>

</cffunction>
<cffunction output="false" name="SELfusystems_24317" access="public" returntype="query">
    <cfargument name="systemtype" type="string" required="true">
    <cfargument name="systemscope" type="string" required="true">

<cfquery name="result" >
            SELECT * 
            FROM fusystems 
            WHERE systemtype = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.systemtype#" />
            AND systemscope = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.systemscope#" />
        </cfquery>

<cfreturn result>
</cffunction>
<cffunction output="false" name="SELfusystems_24318" access="public" returntype="query">
    <cfargument name="systemType" type="string" required="true">
    <cfargument name="systemScope" type="string" required="true">

<cfquery name="result" >
            SELECT *
            FROM fusystems
            WHERE systemtype = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.systemType#" />
            AND systemscope = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.systemScope#" />
        </cfquery>

<cfreturn result>
    </cffunction>
<cffunction output="false" name="SELfusystems_24320" access="public" returntype="query">
    <cfargument name="systemIds" type="string" required="true">

<cfquery name="result" >
        SELECT * 
        FROM fusystems 
        WHERE systemid IN (
            <cfqueryparam value="#arguments.systemIds#" cfsqltype="CF_SQL_INTEGER" list="true">
        )
        ORDER BY FIELD(systemid, #arguments.systemIds#)
    </cfquery>

<cfreturn result>
</cffunction>

<cffunction output="false" name="SELfusystems_24321" access="public" returntype="query">
    <cfargument name="systemID" type="numeric" required="true">
    <cfargument name="userID" type="numeric" required="true">

<cfset var queryResult = "">

<cfquery result="result" name="queryResult" >
            SELECT 
                au.id, 
                s.systemID, 
                s.systemName, 
                s.SystemType, 
                s.SystemScope, 
                s.SystemDescript, 
                s.SystemTriggerNote, 
                a.actionID, 
                a.actionNo, 
                a.actionDetails, 
                a.actionTitle, 
                a.navToURL, 
                au.actionDaysNo, 
                au.actionDaysRecurring, 
                a.actionNotes, 
                a.actionInfo
            FROM fusystems s
            INNER JOIN fuactions a ON s.systemid = a.systemid
            INNER JOIN actionusers au ON au.actionid = a.actionid
            WHERE a.systemID = <cfqueryparam value="#arguments.systemID#" cfsqltype="CF_SQL_INTEGER">
            AND au.userid = <cfqueryparam value="#arguments.userID#" cfsqltype="CF_SQL_INTEGER">
            ORDER BY a.actionNo
        </cfquery>

<cfreturn queryResult>
</cffunction>
<cffunction output="false" name="SELfusystems_24322" access="public" returntype="query">
    <cfargument name="systemID" type="numeric" required="true">
    <cfargument name="userID" type="numeric" required="true">

<cfquery name="result" >
            SELECT MAX(au.id) AS id, a.actionID, a.actionTitle, a.actionno 
            FROM fusystems s 
            INNER JOIN fuactions a ON s.systemid = a.systemid 
            INNER JOIN actionusers_tbl au ON au.actionid = a.actionid 
            WHERE a.systemID = <cfqueryparam value="#arguments.systemID#" cfsqltype="CF_SQL_INTEGER"> 
            AND au.userid = <cfqueryparam value="#arguments.userID#" cfsqltype="CF_SQL_INTEGER"> 
            AND au.isdeleted = 1 
            AND a.actionid NOT IN (
                SELECT a.actionID 
                FROM fusystems s 
                INNER JOIN fuactions a ON s.systemid = a.systemid 
                INNER JOIN actionusers au ON au.actionid = a.actionid 
                WHERE a.systemID = <cfqueryparam value="#arguments.systemID#" cfsqltype="CF_SQL_INTEGER"> 
                AND au.userid = <cfqueryparam value="#arguments.userID#" cfsqltype="CF_SQL_INTEGER">
            ) 
            GROUP BY a.actionID, a.actionTitle, a.actionno 
            ORDER BY a.actionno
        </cfquery>
        <cfreturn result>

</cffunction>
<cffunction output="false" name="SELfusystems_24342" access="public" returntype="query">
    <cfargument name="systemType" type="string" required="true">
    <cfargument name="systemScope" type="string" required="true">

<cfquery name="result" >
            SELECT systemid 
            FROM fusystems 
            WHERE systemtype = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.systemType#" />
            AND SystemScope = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.systemScope#" />
        </cfquery>

<cfreturn result>
</cffunction>
<cffunction output="false" name="SELfusystems_24428" access="public" returntype="query">
    <cfargument name="maint_systemID" type="numeric" required="true">
    <cfargument name="userid" type="numeric" required="true">

<cfquery name="result" >
            SELECT 
                s.systemID, 
                s.systemName, 
                s.SystemType, 
                s.SystemScope, 
                s.SystemDescript, 
                s.SystemTriggerNote, 
                a.actionID, 
                a.actionNo, 
                a.actionDetails, 
                a.actionTitle, 
                a.navToURL, 
                au.actionDaysNo, 
                au.actionDaysRecurring, 
                a.actionNotes, 
                a.actionInfo, 
                a.IsUnique
            FROM fusystems s
            INNER JOIN fuactions a ON s.systemid = a.systemid
            INNER JOIN actionusers au ON au.actionid = a.actionid
            WHERE a.systemID = <cfqueryparam value="#arguments.maint_systemID#" cfsqltype="CF_SQL_INTEGER">
            AND au.actionDaysNo IS NOT NULL
            AND au.userid = <cfqueryparam value="#arguments.userid#" cfsqltype="CF_SQL_INTEGER">
            ORDER BY a.actionNo
        </cfquery>

<cfreturn result>
</cffunction>
<cffunction output="false" name="SELfusystems_24634" access="public" returntype="query">
    <cfquery result="result" name="queryResult" >
        SELECT systemid AS id, systemname 
        FROM fusystems 
        ORDER BY systemname
    </cfquery>
    <cfreturn queryResult>
</cffunction>

<cffunction output="false" name="getFuSystemUsersBySystemID" access="public" returntype="query">
    <cfargument name="systemid" type="numeric" required="true">
    <cfargument name="userid" type="numeric" required="true">

<cfquery name="result" >
            SELECT 
                s.systemID, 
                s.systemName, 
                s.SystemType, 
                s.SystemScope, 
                s.SystemDescript, 
                s.SystemTriggerNote, 
                a.actionID, 
                a.actionNo, 
                a.actionDetails, 
                a.actionTitle, 
                a.navToURL, 
                au.actionDaysNo, 
                au.actionDaysRecurring, 
                a.actionNotes, 
                a.actionInfo, 
                a.IsUnique, 
                a.uniquename
            FROM fusystems s
            INNER JOIN fuactions a ON s.systemid = a.systemid
            INNER JOIN actionusers au ON au.actionid = a.actionid
            WHERE s.systemID = <cfqueryparam value="#arguments.systemid#" cfsqltype="CF_SQL_INTEGER">
            AND au.userid = <cfqueryparam value="#arguments.userid#" cfsqltype="CF_SQL_INTEGER">
            ORDER BY a.actionNo
        </cfquery>

<cfreturn result>

</cffunction>
<cffunction output="false" name="SELfusystems_24762" access="public" returntype="query">
    <cfargument name="new_systemscope" type="string" required="true">
    <cfargument name="currentid" type="numeric" required="true">
    <cfargument name="userid" type="numeric" required="true">

<cfquery name="result" >
            SELECT * 
            FROM fusystems 
            WHERE systemscope = <cfqueryparam value="#arguments.new_systemscope#" cfsqltype="CF_SQL_VARCHAR"> 
              AND systemid NOT IN (
                  SELECT systemid 
                  FROM fusystemusers 
                  WHERE contactID = <cfqueryparam value="#arguments.currentid#" cfsqltype="CF_SQL_INTEGER"> 
                    AND userID = <cfqueryparam value="#arguments.userid#" cfsqltype="CF_SQL_INTEGER"> 
                    AND suStatus = <cfqueryparam value='Active' cfsqltype='CF_SQL_VARCHAR'>
              ) 
            ORDER BY FIELD(systemtype, 'Targeted List', 'Follow Up', 'Maintenance List')
        </cfquery>

<cfreturn result>

</cffunction>
<cffunction output="false" name="SELfusystems_24763" access="public" returntype="query">
    <cfargument name="systemID" type="numeric" required="false">
    <cfargument name="systemName" type="string" required="false">

<cfset var queryResult = "">
    <cfset var sql = "SELECT s.systemID, s.systemName, s.SystemType, s.SystemScope, s.SystemDescript, s.SystemTriggerNote FROM fusystems s">
    <cfset var whereClauses = []>
    <cfset var params = []>

<!--- Build dynamic WHERE clause --->
    <cfif structKeyExists(arguments, "systemID")>
        <cfset arrayAppend(whereClauses, "s.systemID = ?")>
        <cfset arrayAppend(params, {value=arguments.systemID, cfsqltype="CF_SQL_INTEGER"})>
    </cfif>

<cfif structKeyExists(arguments, "systemName")>
        <cfset arrayAppend(whereClauses, "s.systemName = ?")>
        <cfset arrayAppend(params, {value=arguments.systemName, cfsqltype="CF_SQL_VARCHAR"})>
    </cfif>

<!--- Append WHERE clauses if any --->
    <cfif arrayLen(whereClauses) gt 0>
        <cfset sql = sql & " WHERE " & arrayToList(whereClauses, " AND ")>
    </cfif>

<!--- Add ORDER BY clause --->
    <cfset sql = sql & " ORDER BY s.systemName">

<!--- Execute the query --->

<cfquery result="result" name="queryResult" >
            #sql#
            <cfloop array="#params#" index="param">
                <cfqueryparam value="#param.value#" cfsqltype="#param.cfsqltype#">
            </cfloop>
        </cfquery>

<cfreturn queryResult>
</cffunction>
</cfcomponent>
