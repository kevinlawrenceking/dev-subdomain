<cfcomponent displayname="PanelUserService" hint="Handles operations for PanelUser table" >

<cffunction output="false" name="SELpgpanels_user" access="public" returntype="query">
    <cfargument name="userid" type="numeric" required="true">

<cfquery name="result">
        SELECT 
            p.pnid, 
            p.pntitle, 
            p.pnColXl, 
            p.pnColMd, 
            p.pnFilename, 
            -1 AS new_pnorderno, 
            p.isvisible
        FROM 
            pgpanels_user p
        WHERE 
            p.userid = <cfqueryparam value="#arguments.userid#" cfsqltype="CF_SQL_INTEGER">
        ORDER BY 
            p.pnorderno
    </cfquery>
    <cfreturn result>
</cffunction>

<cffunction output="false" name="UPDpgpanels_user" access="public" returntype="void">
    <cfargument name="userid" type="numeric" required="true">
    <cfquery result="result">
        UPDATE pgpanels_user 
        SET isvisible = 0 
        WHERE userid = <cfqueryparam value="#arguments.userid#" cfsqltype="CF_SQL_INTEGER">
    </cfquery>
</cffunction>
<cffunction output="false" name="UPDpgpanels_user_23858" access="public" returntype="void">
    <cfargument name="userid" type="numeric" required="true">
    <cfargument name="new_isvisible" type="string" required="true">
    <!--- new_isvisible should be a comma-separated string of pnid values --->

<!--- Update the pgpanels_user table based on user ID and provided pnid list --->
    <cfquery>
        UPDATE pgpanels_user
        SET isvisible = 1
        WHERE userid = <cfqueryparam value="#arguments.userid#" cfsqltype="CF_SQL_INTEGER">
        AND pnid IN (#arguments.new_isvisible#)
    </cfquery>
</cffunction>

<cffunction output="false" name="UPDpgpanels_user_23886" access="public" returntype="void">
    <cfargument name="pnid" type="numeric" required="true">
    <cfquery result="result">
        UPDATE pgpanels_user
        SET isdeleted = 1
        WHERE pnid = <cfqueryparam value="#arguments.pnid#" cfsqltype="CF_SQL_INTEGER">
    </cfquery>
</cffunction>

<cffunction output="false" name="SELpgpanels_user_24136" access="public" returntype="query">
    <cfargument name="userId" type="numeric" required="true">

<cfquery name="result">
        SELECT 
            p.pnid, 
            p.pntitle, 
            s.pnTitle AS correct_title
        FROM 
            pgpanels_user p
        LEFT JOIN 
            sitetypes_user s ON s.pnid = p.pnid
        WHERE 
            p.userid = <cfqueryparam value="#arguments.userId#" cfsqltype="CF_SQL_INTEGER"> 
            AND p.pntitle <> s.pntitle
    </cfquery>

<cfreturn result>
</cffunction>

<cffunction output="false" name="pgPanelsFix" access="public" returntype="void">
<cfquery result="result">
UPDATE pgpanels_user AS p
INNER JOIN sitetypes_user AS s ON p.pnid = s.pnid
SET 
    p.pnTitle = CONCAT(s.sitetypename, ' Links');
    </cfquery>
</cffunction>

<cffunction output="false" name="SELpgpanels_user_24147" access="public" returntype="query">
    <cfargument name="userid" type="numeric" required="true">

<cfquery name="result">
        SELECT p.pnOrderno + 1 AS new_pnOrderNo
        FROM pgpanels_user p
        WHERE p.userid = <cfqueryparam value="#arguments.userid#" cfsqltype="CF_SQL_INTEGER">
        ORDER BY p.pnOrderno DESC
    </cfquery>

<cfreturn result>
</cffunction>

<cffunction output="false" name="INSpgpanels_user" access="public" returntype="numeric">
    <cfargument name="new_pnTitle" type="string" required="true">
    <cfargument name="new_pnOrderNo" type="numeric" required="true">
    <cfargument name="userid" type="numeric" required="true">

<cfquery result="result">
        INSERT INTO pgpanels_user (
            pnTitle, 
            pnFilename, 
            pnorderno, 
            pncolxl, 
            pncolMd, 
            pnDescription, 
            IsDeleted, 
            IsVisible, 
            userid
        ) VALUES (
            <cfqueryparam value="#arguments.new_pnTitle#" cfsqltype="CF_SQL_VARCHAR">,
            <cfqueryparam value="mylinks_user.cfm" cfsqltype="CF_SQL_VARCHAR">,
            <cfqueryparam value="#arguments.new_pnOrderNo#" cfsqltype="CF_SQL_INTEGER">,
            <cfqueryparam value="3" cfsqltype="CF_SQL_INTEGER">,
            <cfqueryparam value="3" cfsqltype="CF_SQL_INTEGER">,
            <cfqueryparam value="" cfsqltype="CF_SQL_VARCHAR">,
            <cfqueryparam value="0" cfsqltype="CF_SQL_BIT">,
            <cfqueryparam value="1" cfsqltype="CF_SQL_BIT">,
            <cfqueryparam value="#arguments.userid#" cfsqltype="CF_SQL_INTEGER">
        )
    </cfquery>
    <cfreturn result.generatedKey>
</cffunction>

<cffunction output="false" name="SELpgpanels_user_24435" access="public" returntype="query">
    <cfargument name="userid" type="numeric" required="true">
    <cfargument name="pnFilename" type="string" required="true">

<cfquery name="result" >
            SELECT *
            FROM pgpanels_user
            WHERE userid = <cfqueryparam value="#arguments.userid#" cfsqltype="CF_SQL_INTEGER">
            AND pnFilename = <cfqueryparam value="#arguments.pnFilename#" cfsqltype="CF_SQL_VARCHAR">
        </cfquery>

<cfreturn result>
</cffunction>
<cffunction output="false" name="INSpgpanels_user_24436" access="public" returntype="numeric">
    <cfargument name="select_userid" type="numeric" required="true">
    <cfargument name="m" type="struct" required="true">

<cfset var queryResult = "">

<cfquery result="result" name="queryResult" >
            INSERT INTO pgpanels_user_tbl (
                userid, 
                pnTitle, 
                pnFilename, 
                pnOrderNo, 
                pnColXl, 
                pnColMd, 
                pnDescription, 
                IsVisible
            ) VALUES (
                <cfqueryparam value="#arguments.select_userid#" cfsqltype="CF_SQL_INTEGER">,
                <cfqueryparam value="#arguments.m.pntitle#" cfsqltype="CF_SQL_VARCHAR">,
                <cfqueryparam value="#arguments.m.pnfilename#" cfsqltype="CF_SQL_VARCHAR">,
                <cfqueryparam value="#arguments.m.pnOrderNo#" cfsqltype="CF_SQL_INTEGER">,
                <cfqueryparam value="#arguments.m.pnColXl#" cfsqltype="CF_SQL_INTEGER">,
                <cfqueryparam value="#arguments.m.pnColMd#" cfsqltype="CF_SQL_INTEGER">,
                <cfqueryparam value="#arguments.m.pnDescription#" cfsqltype="CF_SQL_VARCHAR">,
                <cfqueryparam value="1" cfsqltype="CF_SQL_BIT">
            )
        </cfquery>
<cfreturn result.generatedKey>
</cffunction>
<cffunction output="false" name="SELpgpanels_user_24440" access="public" returntype="query">
    <cfargument name="select_userid" type="numeric" required="true">

<cfquery name="result" >
            SELECT p.pnOrderno + 1 AS new_pnOrderNo
            FROM pgpanels_user p
            WHERE p.userid = <cfqueryparam value="#arguments.select_userid#" cfsqltype="CF_SQL_INTEGER">
            ORDER BY p.pnOrderno DESC
        </cfquery>

<cfreturn result>
</cffunction>
<cffunction output="false" name="INSpgpanels_user_24441" access="public" returntype="numeric">
    <cfargument name="new_pnTitle" type="string" required="true">
    <cfargument name="new_pnOrderNo" type="numeric" required="true">
    <cfargument name="select_userid" type="numeric" required="true">

<cfquery result="result" >
            INSERT INTO pgpanels_user (
                pnTitle, 
                pnFilename, 
                pnorderno, 
                pncolxl, 
                pncolMd, 
                pnDescription, 
                IsDeleted, 
                IsVisible, 
                userid
            ) VALUES (
                <cfqueryparam value="#arguments.new_pnTitle#" cfsqltype="CF_SQL_VARCHAR">,
                <cfqueryparam value="mylinks_user.cfm" cfsqltype="CF_SQL_VARCHAR">,
                <cfqueryparam value="#arguments.new_pnOrderNo#" cfsqltype="CF_SQL_INTEGER">,
                <cfqueryparam value="3" cfsqltype="CF_SQL_INTEGER">,
                <cfqueryparam value="3" cfsqltype="CF_SQL_INTEGER">,
                <cfqueryparam value="" cfsqltype="CF_SQL_VARCHAR">,
                <cfqueryparam value="0" cfsqltype="CF_SQL_BIT">,
                <cfqueryparam value="1" cfsqltype="CF_SQL_BIT">,
                <cfqueryparam value="#arguments.select_userid#" cfsqltype="CF_SQL_INTEGER">
            )
        </cfquery>
<cfreturn result.generatedKey>
</cffunction>
<cffunction output="false" name="SELpgpanels_user_24640" access="public" returntype="query">
    <cfargument name="userid" type="numeric" required="true">

<cfquery name="result" >
            SELECT 
                p.pnid, 
                p.pntitle, 
                p.pnColXl, 
                p.pnColMd, 
                p.pnFilename, 
                p.pnorderno AS new_pnorderno
            FROM 
                pgpanels_user p
            WHERE 
                p.userid = <cfqueryparam value="#arguments.userid#" cfsqltype="CF_SQL_INTEGER"> 
                AND p.isvisible = <cfqueryparam value="1" cfsqltype="CF_SQL_BIT">
            ORDER BY 
                p.pnorderno
        </cfquery>

<cfreturn result>
</cffunction>
<cffunction output="false" name="SELpgpanels_user_24642" access="public" returntype="query">
    <cfargument name="userid" type="numeric" required="true">

<cfquery name="result" >
            SELECT 
                p.pnid, 
                p.pntitle, 
                p.pnColXl, 
                p.pnColMd, 
                p.pnFilename, 
                p.pnorderno AS new_pnorderno, 
                p.isvisible 
            FROM 
                pgpanels_user p 
            WHERE 
                p.userid = <cfqueryparam value="#arguments.userid#" cfsqltype="CF_SQL_INTEGER"> 
            ORDER BY 
                pnOrderno
        </cfquery>

<cfreturn result>
</cffunction>
</cfcomponent>
