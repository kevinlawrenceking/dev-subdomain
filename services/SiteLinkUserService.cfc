<cfcomponent displayname="SiteLinkUserService" hint="Handles operations for SiteLinkUser table" >

<cffunction output="false" name="UPDsitelinks_user" access="public" returntype="void">
    <cfargument name="fileName" type="string" required="true">
    <cfargument name="id" type="numeric" required="true">

<cfquery result="result">
        UPDATE sitelinks_user 
        SET siteicon = <cfqueryparam value="#arguments.fileName#" cfsqltype="cf_sql_varchar"> 
        WHERE id = <cfqueryparam value="#arguments.id#" cfsqltype="cf_sql_integer">
    </cfquery>
</cffunction>

<cffunction output="false" name="SELsitelinks_user" access="public" returntype="query">
    <cfargument name="siteIcon" type="string" required="false" default="unknown.png">

<cfset var sql = "SELECT id, sitename, siteurl, siteicon FROM sitelinks_user WHERE iscustom = 1 AND siteicon = ?">

<cfquery name="result">
        #sql#
        <cfqueryparam value="#arguments.siteIcon#" cfsqltype="CF_SQL_VARCHAR">
    </cfquery>

<cfreturn result>
</cffunction>

<cffunction output="false" name="UPDsitelinks_user_23854" access="public" returntype="void" hint="Updates the site icon for a user.">
    <cfargument name="new_siteicon" type="string" required="true" hint="New site icon value."/>
    <cfargument name="id" type="numeric" required="true" hint="User ID."/>

<cfquery result="result">
        UPDATE sitelinks_user 
        SET siteicon = <cfqueryparam value="#arguments.new_siteicon#" cfsqltype="CF_SQL_VARCHAR">
        WHERE id = <cfqueryparam value="#arguments.id#" cfsqltype="CF_SQL_INTEGER">
    </cfquery>
</cffunction>

<cffunction output="false" name="UPDsitelinks_user_23883" access="public" returntype="void">
    <cfargument name="new_id" type="numeric" required="true">

<cfquery result="result">
        UPDATE sitelinks_user_tbl 
        SET isdeleted = 1 
        WHERE id = <cfqueryparam value="#arguments.new_id#" cfsqltype="CF_SQL_INTEGER">
    </cfquery>
</cffunction>

<cffunction output="false" name="UPDsitelinks_user_23930" access="public" returntype="void">
    <cfargument name="new_id" type="numeric" required="true">

<cfquery result="result">
        UPDATE sitelinks_user_tbl
        SET isdeleted = 0
        WHERE id = <cfqueryparam value="#arguments.new_id#" cfsqltype="CF_SQL_INTEGER">
    </cfquery>
</cffunction>

<cffunction output="false" name="SELsitelinks_user_23943" access="public" returntype="query">
    <cfargument name="userid" type="numeric" required="true">

<cfquery name="result">
        SELECT 
            s.id, 
            s.sitetypeid, 
            s.sitename, 
            s.siteurl, 
            s.siteicon, 
            s.sitetypeid, 
            t.sitetypename, 
            t.pntitle
        FROM 
            sitelinks_user s
        INNER JOIN 
            sitetypes_user t ON t.sitetypeid = s.siteTypeid
        WHERE 
            s.userid = <cfqueryparam value="#arguments.userid#" cfsqltype="CF_SQL_INTEGER">
        ORDER BY 
            s.sitename
    </cfquery>

<cfreturn result>
</cffunction>

<cffunction output="false" name="SELsitelinks_user_23958" access="public" returntype="query">
    <cfargument name="userId" type="numeric" required="true">
    <cfargument name="siteTypeId" type="numeric" required="true">

<cfquery name="result">
        SELECT 
            s.id, 
            s.sitetypeid, 
            s.sitename, 
            s.siteurl, 
            s.siteicon, 
            s.sitetypeid, 
            t.sitetypename, 
            t.pntitle, 
            s.ver
        FROM 
            sitelinks_user s
        INNER JOIN 
            sitetypes_user t ON t.sitetypeid = s.siteTypeid
        WHERE 
            s.userid = <cfqueryparam value="#arguments.userId#" cfsqltype="CF_SQL_INTEGER"> 
            AND s.sitetypeid = <cfqueryparam value="#arguments.siteTypeId#" cfsqltype="CF_SQL_INTEGER">
        ORDER BY 
            s.sitename
    </cfquery>

<cfreturn result>
</cffunction>

<cffunction output="false" name="SELsitelinks_user_23959" access="public" returntype="query">
    <cfargument name="userId" type="numeric" required="true">
    <cfargument name="siteTypeId" type="numeric" required="true">

<cfquery name="result">
        SELECT 
            s.id, 
            s.sitetypeid, 
            s.sitename, 
            s.siteurl, 
            s.siteicon, 
            s.sitetypeid, 
            t.sitetypename, 
            t.pntitle, 
            s.ver
        FROM 
            sitelinks_user_tbl s
        INNER JOIN 
            sitetypes_user t ON t.sitetypeid = s.siteTypeid
        WHERE 
            s.userid = <cfqueryparam value="#arguments.userId#" cfsqltype="CF_SQL_INTEGER"> 
            AND s.sitetypeid = <cfqueryparam value="#arguments.siteTypeId#" cfsqltype="CF_SQL_INTEGER"> 
            AND s.isdeleted = 1 
            AND s.isCustom = 0
        ORDER BY 
            s.sitename
    </cfquery>

<cfreturn result>
</cffunction>

<cffunction output="false" name="SELsitelinks_user_24138" access="public" returntype="query">
    <cfargument name="userid" type="numeric" required="true">
    <cfargument name="new_sitename" type="string" required="true">

<cfquery name="result">
        SELECT * 
        FROM sitelinks_user 
        WHERE userid = <cfqueryparam value="#arguments.userid#" cfsqltype="CF_SQL_INTEGER"> 
        AND sitename = <cfqueryparam value="#arguments.new_sitename#" cfsqltype="CF_SQL_VARCHAR">
    </cfquery>

<cfreturn result>
</cffunction>

<cffunction output="false" name="INSsitelinks_user" access="public" returntype="numeric">
    <cfargument name="new_sitename" type="string" required="true">
    <cfargument name="new_siteurl" type="string" required="true">
    <cfargument name="userid" type="numeric" required="true">
    <cfargument name="new_sitetypeid" type="numeric" required="true">
    <cfargument name="ver" type="string" required="false" default="">

<cfquery  result="result">
        INSERT INTO sitelinks_user (
            sitename, 
            siteurl, 
            userid, 
            sitetypeid, 
            IsCustom
            <cfif len(arguments.ver) gt 0>, ver</cfif>
        ) VALUES (
            <cfqueryparam value="#arguments.new_sitename#" cfsqltype="CF_SQL_VARCHAR">,
            <cfqueryparam value="#arguments.new_siteurl#" cfsqltype="CF_SQL_VARCHAR">,
            <cfqueryparam value="#arguments.userid#" cfsqltype="CF_SQL_INTEGER">,
            <cfqueryparam value="#arguments.new_sitetypeid#" cfsqltype="CF_SQL_INTEGER">,
            <cfqueryparam value="1" cfsqltype="CF_SQL_BIT">
            <cfif len(arguments.ver) gt 0>, 
                <cfqueryparam value="#arguments.ver#" cfsqltype="CF_SQL_VARCHAR">
            </cfif>
        );
    </cfquery>

<cfreturn result.generatedKey>
</cffunction>

<cffunction output="false" name="SELsitelinks_user_24448" access="public" returntype="query">
    <cfargument name="sitename" type="string" required="true">
    <cfargument name="userid" type="numeric" required="true">

<cfquery name="result" >
            SELECT *
            FROM sitelinks_user_tbl
            WHERE sitename = <cfqueryparam value="#arguments.sitename#" cfsqltype="CF_SQL_VARCHAR">
            AND userid = <cfqueryparam value="#arguments.userid#" cfsqltype="CF_SQL_INTEGER">
        </cfquery>

<cfreturn result>
</cffunction>
<cffunction output="false" name="INSsitelinks_user_24449" access="public" returntype="numeric">
    <cfargument name="sitename" type="string" required="true">
    <cfargument name="siteurl" type="string" required="true">
    <cfargument name="siteicon" type="string" required="true">
    <cfargument name="sitetypeid" type="numeric" required="true">
    <cfargument name="userid" type="numeric" required="true">

<cfquery result="result" >
            INSERT INTO sitelinks_user_tbl (siteName, siteURL, siteicon, siteTypeid, userid)
            VALUES (
                <cfqueryparam value="#arguments.sitename#" cfsqltype="CF_SQL_VARCHAR">,
                <cfqueryparam value="#arguments.siteurl#" cfsqltype="CF_SQL_VARCHAR">,
                <cfqueryparam value="#arguments.siteicon#" cfsqltype="CF_SQL_VARCHAR">,
                <cfqueryparam value="#arguments.sitetypeid#" cfsqltype="CF_SQL_INTEGER">,
                <cfqueryparam value="#arguments.userid#" cfsqltype="CF_SQL_INTEGER">
            )
        </cfquery>
        <cfreturn result.generatedKey>
</cffunction>
</cfcomponent>
