<cfcomponent displayname="ReportItemService" hint="Handles operations for ReportItem table" > 
<cffunction output="false" name="INSreportitems" access="public" returntype="numeric">
    <cfargument name="itemLabel" type="string" required="true">
    <cfargument name="itemOrderNo" type="numeric" required="true">
    <cfargument name="itemValueInt" type="numeric" required="true">
    <cfargument name="ID" type="numeric" required="true">
    <cfargument name="itemDataset" type="string" required="true">

<cfquery result="result">
        INSERT INTO reportitems 
        (itemLabel, itemOrderNo, itemValueInt, ID, itemDataset, userid) 
        VALUES 
        (
            <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.itemLabel#" />,
            <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.itemOrderNo#" />,
            <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.itemValueInt#" />,
            <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.ID#" />,
            <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.itemDataset#" />,
            <cfqueryparam cfsqltype="cf_sql_integer" value="#userid#" />
        )
    </cfquery>
    <cfreturn result.generatedKey>
</cffunction>

<cffunction output="false" name="SELreportitems" access="public" returntype="query">
    <cfargument name="userid" type="numeric" required="true">
    <cfargument name="reportid" type="numeric" required="true">

<cfquery name="result">
        SELECT 
            r.reportid, 
            i.itemid, 
            i.itemLabel, 
            i.itemOrderNo, 
            i.itemValueInt, 
            i.itemDataset, 
            i.userid 
        FROM 
            reportitems i 
        INNER JOIN 
            reports_user r ON r.id = i.id 
        WHERE 
            i.userid = <cfqueryparam value="#arguments.userid#" cfsqltype="CF_SQL_INTEGER"> 
        AND 
            r.reportid = <cfqueryparam value="#arguments.reportid#" cfsqltype="CF_SQL_INTEGER">
    </cfquery>

<cfreturn result>
</cffunction>

<cffunction output="false" name="SELreportitems_24225" access="public" returntype="query">
    <cfargument name="userid" type="numeric" required="true">
    <cfargument name="reportid" type="numeric" required="true">

<cfquery name="result">
        SELECT DISTINCT i.itemdataset
        FROM reportitems i
        INNER JOIN reports_user r ON r.id = i.id
        WHERE i.userid = <cfqueryparam value="#arguments.userid#" cfsqltype="CF_SQL_INTEGER">
        AND r.reportid = <cfqueryparam value="#arguments.reportid#" cfsqltype="CF_SQL_INTEGER">
        ORDER BY i.itemdataset
    </cfquery>

<cfreturn result>
</cffunction>

<cffunction output="false" name="SELreportitems_24226" access="public" returntype="query">
    <cfargument name="userid" type="numeric" required="true">
    <cfargument name="reportid" type="numeric" required="true">

<cfquery name="result">
        SELECT DISTINCT i.itemlabel
        FROM reportitems i
        INNER JOIN reports_user r ON r.id = i.id
        WHERE i.userid = <cfqueryparam value="#arguments.userid#" cfsqltype="CF_SQL_INTEGER">
        AND r.reportid = <cfqueryparam value="#arguments.reportid#" cfsqltype="CF_SQL_INTEGER">
    </cfquery>

<cfreturn result>
</cffunction>

<cffunction output="false" name="SELreportitems_24227" access="public" returntype="query">
    <cfargument name="userid" type="numeric" required="true">
    <cfargument name="reportid" type="numeric" required="true">
    <cfargument name="itemdataset" type="string" required="true">

<cfquery name="result">
        SELECT DISTINCT 
            i.itemlabel, 
            i.itemValueInt 
        FROM 
            reportitems i 
        INNER JOIN 
            reports_user r ON r.id = i.id 
        WHERE 
            i.userid = <cfqueryparam value="#arguments.userid#" cfsqltype="CF_SQL_INTEGER"> 
            AND r.reportid = <cfqueryparam value="#arguments.reportid#" cfsqltype="CF_SQL_INTEGER"> 
            AND i.itemDataset = <cfqueryparam value="#arguments.itemdataset#" cfsqltype="CF_SQL_VARCHAR"> 
        ORDER BY 
            i.itemlabel
    </cfquery>

<cfreturn result>
</cffunction>

<cffunction output="false" name="DELreportitems" access="public" returntype="void">
    <cfargument name="userid" type="numeric" required="true">

<cfquery result="result">
        DELETE FROM reportitems
        WHERE userid = <cfqueryparam value="#arguments.userid#" cfsqltype="CF_SQL_INTEGER">
    </cfquery>
</cffunction>

<cffunction output="false" name="INSreportitems_24233" access="public" returntype="numeric">
    <cfargument name="newLabel" type="string" required="true">
    <cfargument name="itemOrderNo" type="numeric" required="true">
    <cfargument name="newID" type="numeric" required="true">
    <cfargument name="newItemDataSet" type="string" required="true">
    <cfargument name="userID" type="numeric" required="true">

<cfquery result="result">
        INSERT INTO reportitems 
        (itemLabel, itemOrderNo, itemValueInt, ID, itemDataset, userid) 
        VALUES (
            <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.newLabel#" />,
            <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.itemOrderNo#" />,
            <cfqueryparam cfsqltype="cf_sql_integer" value="0" />,
            <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.newID#" />,
            <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.newItemDataSet#" />,
            <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.userID#" />
        )
    </cfquery>
    <cfreturn result.generatedKey>
</cffunction>

<cffunction output="false" name="UPDreportitems" access="public" returntype="void">
    <cfargument name="new_itemvalueint" type="numeric" required="true">
    <cfargument name="new_itemid" type="numeric" required="true">

<cfquery result="result" name="updateQuery" >
            UPDATE reportitems 
            SET itemValueInt = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.new_itemvalueint#" />
            WHERE itemid = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.new_itemid#" />
        </cfquery>

</cffunction>
<cffunction output="false" name="RESreportitems" access="public" returntype="query">
    <cfargument name="userId" type="numeric" required="true">

<cfquery name="result" >
            SELECT *
            FROM reportitems
            WHERE userid = <cfqueryparam value="#arguments.userId#" cfsqltype="CF_SQL_INTEGER">
        </cfquery>

<cfreturn result>
</cffunction>
</cfcomponent>
