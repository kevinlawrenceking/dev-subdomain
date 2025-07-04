<cfcomponent displayname="SiteTypeUserService" hint="Handles operations for SiteTypeUser table" > 
<cffunction name="SELsitetypes_user" access="public" returntype="query" output="false">
    <cfargument name="sitetypeid" type="numeric" required="true">

    <!--- Perform the query --->
    <cfquery name="result">
        SELECT pnid 
        FROM sitetypes_user_tbl 
        WHERE sitetypeid = <cfqueryparam value="#arguments.sitetypeid#" cfsqltype="CF_SQL_INTEGER">
    </cfquery>

    <!--- Return the query result --->
    <cfreturn result>
</cffunction>

<cffunction output="false" name="UPDsitetypes_user" access="public" returntype="void">
    <cfargument name="sitetypeid" type="numeric" required="true">

<cfquery result="result" name="queryResult">
        UPDATE sitetypes_user_tbl 
        SET isdeleted = 1 
        WHERE sitetypeid = <cfqueryparam value="#arguments.sitetypeid#" cfsqltype="CF_SQL_INTEGER">
    </cfquery>
</cffunction>
<cffunction output="false" name="SELsitetypes_user_24133" access="public" returntype="query">
    <cfargument name="new_sitetypeid" type="numeric" required="true">

<cfquery name="result">
        SELECT 
            p.pnid, 
            p.isvisible, 
            s.sitetypeid, 
            s.sitetypename, 
            s.sitetypedescription, 
            s.pntitle 
        FROM 
            sitetypes_user s 
        LEFT JOIN 
            pgpanels_user p ON p.pnid = s.pnid 
        WHERE 
            s.sitetypeid = <cfqueryparam value="#arguments.new_sitetypeid#" cfsqltype="CF_SQL_INTEGER">
    </cfquery>

<cfreturn result>
</cffunction>
<cffunction output="false" name="UPDsitetypes_user_24134" access="public" returntype="void">
    <cfargument name="new_sitetypename" type="string" required="true">
    <cfargument name="new_sitetypeid" type="numeric" required="true">
<cfargument name="new_isvisible" type="numeric" required="true" default="0">
<cfquery result="result" >
UPDATE sitetypes_user AS s
INNER JOIN pgpanels_user AS p ON s.pnid = p.pnid
SET 
    s.sitetypename = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.new_sitetypename#">,
    p.isvisible = <cfqueryparam cfsqltype="cf_sql_BIT" value="#arguments.new_isvisible#">,
    p.pnTitle = CONCAT(<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.new_sitetypename#">, ' Links')
WHERE 
    s.sitetypeid = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.new_sitetypeid#">


    </cfquery>

</cffunction>
<cffunction output="false" name="SELsitetypes_user_24144" access="public" returntype="query">
    <cfargument name="userid" type="numeric" required="true">
    <cfargument name="new_sitetypename" type="string" required="true">

<cfquery name="result">
        SELECT *
        FROM sitetypes_user
        WHERE userid = <cfqueryparam value="#arguments.userid#" cfsqltype="CF_SQL_INTEGER">
        AND sitetypename = <cfqueryparam value="#arguments.new_sitetypename#" cfsqltype="CF_SQL_VARCHAR">
    </cfquery>

<cfreturn result>
</cffunction>
<cffunction output="false" name="INSsitetypes_user" access="public" returntype="numeric">
    <cfargument name="new_siteTypeName" type="string" required="true">
    <cfargument name="userid" type="numeric" required="true">

<cfquery result="result">
        INSERT INTO sitetypes_user_tbl (siteTypeName, siteTypeDescription, userid, IsDeleted) 
        VALUES (
            <cfqueryparam value="#arguments.new_siteTypeName#" cfsqltype="CF_SQL_VARCHAR">,
            <cfqueryparam value="" cfsqltype="CF_SQL_VARCHAR">,
            <cfqueryparam value="#arguments.userid#" cfsqltype="CF_SQL_INTEGER">,
            <cfqueryparam value="0" cfsqltype="CF_SQL_BIT">
        )
    </cfquery>
    <cfreturn result.generatedKey>
</cffunction>
<cffunction output="false" name="SELsitetypes_user_24146" access="public" returntype="query">
    <cfargument name="sitetypeid" type="numeric" required="true">

<cfquery name="result">
        SELECT *
        FROM sitetypes_user
        WHERE sitetypeid = <cfqueryparam value="#arguments.sitetypeid#" cfsqltype="CF_SQL_INTEGER">
    </cfquery>

<cfreturn result>
</cffunction>
<cffunction output="false" name="UPDsitetypes_user_24149" access="public" returntype="void">
    <cfargument name="new_pnid" type="numeric" required="true">
    <cfargument name="new_sitetypeid" type="numeric" required="true">

<cfquery result="result">
        UPDATE sitetypes_user
        SET pnid = <cfqueryparam value="#arguments.new_pnid#" cfsqltype="CF_SQL_INTEGER">
        WHERE sitetypeid = <cfqueryparam value="#arguments.new_sitetypeid#" cfsqltype="CF_SQL_INTEGER">
    </cfquery>
</cffunction>
<cffunction output="false" name="SELsitetypes_user_24438" access="public" returntype="query">
    <cfargument name="sitetypename" type="string" required="true">
    <cfargument name="userid" type="numeric" required="true">

<cfquery name="result">
        SELECT * 
        FROM sitetypes_user 
        WHERE sitetypename = <cfqueryparam value="#arguments.sitetypename#" cfsqltype="CF_SQL_VARCHAR"> 
        AND userid = <cfqueryparam value="#arguments.userid#" cfsqltype="CF_SQL_INTEGER">
    </cfquery>

<cfreturn result>
</cffunction>
<cffunction output="false" name="INSsitetypes_user_24439" access="public" returntype="numeric">
    <cfargument name="siteTypeName" type="string" required="true">
    <cfargument name="siteTypeDescription" type="string" required="true">
    <cfargument name="userId" type="numeric" required="true">

<cfquery result="result">
        INSERT INTO sitetypes_user (siteTypeName, siteTypeDescription, userid) 
        VALUES (
            <cfqueryparam value="#arguments.siteTypeName#" cfsqltype="CF_SQL_VARCHAR">,
            <cfqueryparam value="#arguments.siteTypeDescription#" cfsqltype="CF_SQL_VARCHAR">,
            <cfqueryparam value="#arguments.userId#" cfsqltype="CF_SQL_INTEGER">
        )
    </cfquery>
    <cfreturn result.generatedKey>
</cffunction>
<cffunction output="false" name="SELsitetypes_user_24447" access="public" returntype="query">
    <cfargument name="sitetypename" type="string" required="true">
    <cfargument name="userid" type="numeric" required="true">

<cfquery name="result" >
            SELECT sitetypeid 
            FROM sitetypes_user 
            WHERE sitetypename = <cfqueryparam value="#arguments.sitetypename#" cfsqltype="CF_SQL_VARCHAR"> 
            AND userid = <cfqueryparam value="#arguments.userid#" cfsqltype="CF_SQL_INTEGER">
        </cfquery>

<cfreturn result>
</cffunction>
<cffunction output="false" name="SELsitetypes_user_24752" access="public" returntype="query">
    <cfargument name="userid" type="numeric" required="true">

<cfquery name="result" >
            SELECT sitetypeid, sitetypename, sitetypedescription, pntitle
            FROM sitetypes_user
            WHERE userid = <cfqueryparam value="#arguments.userid#" cfsqltype="CF_SQL_INTEGER">
            ORDER BY sitetypename
        </cfquery>

<cfreturn result>
</cffunction>
</cfcomponent>
