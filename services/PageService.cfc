<cfcomponent displayname="PageService" hint="Handles operations for Page table" >

    

    <cffunction name="getLinksTop" access="public" returntype="query" output="false">
        
        <cfargument name="pgid" type="numeric" required="true">

        <cfquery name="result" >
            SELECT
                l.linkid, l.linkurl, l.linkname, l.linktype,
                l.link_no, l.linkloc_tb, l.pluginname,
                l.rel, l.hrefid
            FROM pgapplinks l
            INNER JOIN pgplugins p ON p.pluginName = l.pluginname
            INNER JOIN pgpagespluginsxref x ON x.pluginid = p.pluginid
            INNER JOIN pgpages g ON g.pgid = x.pgid
            WHERE g.pgid = <cfqueryparam value="#arguments.pgid#" cfsqltype="CF_SQL_INTEGER">
              AND l.linkloc_tb = 't'
            ORDER BY l.link_no
        </cfquery>

        <cfreturn result>
    </cffunction>

    <cffunction name="getLinksBottom" access="public" returntype="query" output="false">
        
        <cfargument name="pgid" type="numeric" required="true">

        <cfquery name="result" >
            SELECT
                l.linkid, l.linkurl, l.linkname, l.linktype,
                l.link_no, l.linkloc_tb, l.pluginname,
                l.rel, l.hrefid
            FROM pgapplinks l
            INNER JOIN pgplugins p ON p.pluginName = l.pluginname
            INNER JOIN pgpagespluginsxref x ON x.pluginid = p.pluginid
            INNER JOIN pgpages g ON g.pgid = x.pgid
            WHERE g.pgid = <cfqueryparam value="#arguments.pgid#" cfsqltype="CF_SQL_INTEGER">
              AND l.linkloc_tb = 'b'
              AND l.linkname NOT LIKE '%calendar - custom%'
              AND l.linktype <> 'css'
            ORDER BY l.link_no
        </cfquery>

        <cfreturn result>
    </cffunction>

    <cffunction name="getLinksExtra" access="public" returntype="query" output="false">
        
        <cfargument name="pgid" type="numeric" required="true">

        <cfquery name="result" >
            SELECT DISTINCT
                l.pluginname
            FROM pgapplinks l
            INNER JOIN pgplugins p ON p.pluginName = l.pluginname
            INNER JOIN pgpagespluginsxref x ON x.pluginid = p.pluginid
            INNER JOIN pgpages g ON g.pgid = x.pgid
            WHERE g.pgid = <cfqueryparam value="#arguments.pgid#" cfsqltype="CF_SQL_INTEGER">
              AND l.linkloc_tb = 'b'
              AND l.pluginname <> 'global'
            ORDER BY l.link_no
        </cfquery>

        <cfreturn result>
    </cffunction>

    <cffunction name="getPagesByShare" access="public" returntype="query" output="false">

        <cfquery name="result">
            SELECT
                a.appname, 
                a.appAuthor, 
                c.compname, 
                p.pgname,
                a.appId, 
                a.appDescription, 
                a.appLogoName,
                a.colorTopBar, 
                a.colorLeftSideBar, 
                a.mocktoday,
                a.mock_yn, 
                c.compid, 
                c.compDir, 
                c.compTable,
                c.compowner, 
                c.compIcon, 
                c.menuYN, 
                c.menuOrder,
                c.compInner, 
                c.compRecordName, 
                c.compActive,
                p.pgid, 
                p.pgDir, 
                p.pgTitle, 
                p.pgHeading, 
                p.pgFilename,
                p.datatables_YN, 
                p.fullcalendar_YN, 
                p.editable_YN,
                p.newdatatables_YN, 
                p.pk, 
                p.update_type
            FROM pgpages p
            INNER JOIN pgcomps c ON c.compID = p.compID
            INNER JOIN pgapps a ON a.appID = c.appid
            WHERE p.pgDir = 'share'
        </cfquery>

        <!--- Return Query Result --->
        <cfreturn result>
    </cffunction>


<cffunction name="SELpgpages_24740" access="public" returntype="query" output="false">

<cfargument name="pgid" type="numeric" required="true">

<cfquery name="FindJoins" >
        SELECT      
            f.fname,
            f2.fname AS fnameb,
            c2.comptable AS comptableb,
            c.comptable,
            f2.fieldid,
            f2.fkey,
            CONCAT('t', f.fieldid) AS talias
        FROM 
            pgpages p
        INNER JOIN 
            pgcomps c ON c.compID = p.compID
        INNER JOIN 
            pgapps a ON a.appID = c.appid
        INNER JOIN 
            pgfields f ON f.pgid = p.pgid
        LEFT JOIN 
            pgfields f2 ON f.fkey = f2.fieldid
        LEFT JOIN 
            pgpages p2 ON p2.pgid = f2.pgid
        LEFT JOIN 
            pgcomps c2 ON c2.compid = p2.compid
        WHERE 
            p.pgid = <cfqueryparam value="#arguments.pgid#" cfsqltype="CF_SQL_INTEGER">
            AND f.results_yn = 'Y' 
            AND f.fkey <> ''
    </cfquery>

<!--- Return the query result --->
    <cfreturn FindJoins>
</cffunction>

<cffunction output="false" name="SELpgpages" access="public" returntype="query">
    <cfargument name="ticketActive" type="string" required="true">
    <cfset var queryResult = "">

<cfquery result="result" name="queryResult" >
            SELECT DISTINCT p.pgid, p.pgname 
            FROM taousers u 
            INNER JOIN tickets t ON u.userID = t.userid 
            INNER JOIN pgpages p ON p.pgid = t.pgid 
            WHERE t.ticketactive = <cfqueryparam value="#arguments.ticketActive#" cfsqltype="CF_SQL_CHAR"> 
            ORDER BY p.pgname
        </cfquery>

<cfreturn queryResult>
</cffunction>
<cffunction output="false" name="SELpgpages_23868" access="public" returntype="query">
    <cfargument name="pgid" type="numeric" required="true">

<cfquery name="result" >
            SELECT *
            FROM pgpages p
            INNER JOIN pgcomps c ON c.compID = p.compid
            INNER JOIN pgapps a ON a.appID = c.appid
            WHERE p.parentpgid = <cfqueryparam value="#arguments.pgid#" cfsqltype="CF_SQL_INTEGER">
            AND p.pgfilename = <cfqueryparam value="results.cfm" cfsqltype="CF_SQL_VARCHAR">
        </cfquery>

<cfreturn result>
</cffunction>

<cffunction output="false" name="DETpgpages" access="public" returntype="query">
    <cfargument name="compid" type="numeric" required="true">
    <cfargument name="pgid" type="numeric" required="true">

<cfquery name="result" >
            SELECT pgid, pgdir
            FROM pgpages
            WHERE compid = <cfqueryparam value="#arguments.compid#" cfsqltype="CF_SQL_INTEGER">
            AND pgid <> <cfqueryparam value="#arguments.pgid#" cfsqltype="CF_SQL_INTEGER">
            AND pgfilename = <cfqueryparam value="results.cfm" cfsqltype="CF_SQL_VARCHAR">
        </cfquery>

<!---  #arguments.pgid# AND pgfilename = 'results.cfm'"> --->
    <cfreturn result>
</cffunction>
<cffunction output="false" name="SELpgpages_23870" access="public" returntype="query">
    <cfargument name="rpgid" type="numeric" required="true">

<cfquery name="result" >
            SELECT p.pgTitle, c.compname 
            FROM pgpages p 
            INNER JOIN pgcomps c ON c.compID = p.compID 
            INNER JOIN pgapps a ON a.appID = c.appid 
            WHERE p.pgid = <cfqueryparam value="#arguments.rpgid#" cfsqltype="CF_SQL_INTEGER">
        </cfquery>

<cfreturn result>
</cffunction>

<cffunction output="false" name="SELpgpages_23912" access="public" returntype="query">
    <cfargument name="ref_pgid" type="numeric" required="true">

<cfquery name="result" >
            SELECT 
                a.appname, a.appAuthor, c.compname, p.pgname, a.appId, 
                a.appDescription, a.appLogoName, a.colorTopBar, a.colorLeftSideBar, 
                a.mocktoday, a.mock_yn, c.compid, c.compDir, c.compTable, 
                c.compowner, c.compIcon, c.menuYN, c.menuOrder, c.compInner, 
                c.compRecordName, c.compActive, p.pgid, p.pgDir, p.pgTitle, 
                p.pgHeading, p.pgFilename, p.datatables_YN, p.fullcalendar_YN, 
                p.editable_YN, p.newdatatables_YN, p.pk
            FROM pgpages p
            INNER JOIN pgcomps c ON c.compID = p.compID
            INNER JOIN pgapps a ON a.appID = c.appid
            WHERE p.pgid = <cfqueryparam value="#arguments.ref_pgid#" cfsqltype="CF_SQL_INTEGER">
        </cfquery>

<cfreturn result>

</cffunction>

<cffunction output="false" name="DETpgpages_23991" access="public" returntype="query">
    <cfargument name="pgid" type="numeric" required="true">

<cfquery name="result" >
            SELECT pgdir 
            FROM pgpages 
            WHERE pgid = <cfqueryparam value="#arguments.pgid#" cfsqltype="CF_SQL_INTEGER">
        </cfquery>

<cfreturn result>
</cffunction>

<cffunction output="false" name="getDynamicQuery" access="public" returntype="query">
    <cfargument name="rpgid" type="numeric" required="true">

<cfquery name="result" >
            SELECT 
                f.fname, f.fieldid, f.pgid, f.ftype, f.ftypefull, 
                f.update_yn, f.updatename, f.updatetype, f.fkey, 
                c2.comptable AS comptableb, c.comptable, 
                CONCAT('t', f.fieldid) AS talias 
            FROM pgpages p 
            INNER JOIN pgcomps c ON c.compID = p.compID 
            INNER JOIN pgapps a ON a.appID = c.appid 
            INNER JOIN pgfields f ON f.pgid = p.pgid 
            LEFT JOIN pgfields f2 ON f.fkey = f2.fieldid 
            LEFT JOIN pgpages p2 ON p2.pgid = f2.pgid 
            LEFT JOIN pgcomps c2 ON c2.compid = p2.compid 
            WHERE p.pgid = <cfqueryparam value="#arguments.rpgid#" cfsqltype="CF_SQL_INTEGER">
            AND f.results_yn = 'Y'
            ORDER BY f.displayOrder
        </cfquery>

<cfreturn result>
</cffunction>

<cffunction output="false" name="SELpgpages_24003" access="public" returntype="query">
    <cfargument name="thispage" type="string" required="true">

<cfquery name="result" >
            SELECT 
                a.appname, a.appAuthor, c.compname, p.pgname, a.appId, a.appDescription, 
                a.appLogoName, a.colorTopBar, a.colorLeftSideBar, a.mocktoday, a.mock_yn, 
                c.compid, c.compDir, c.compTable, c.compowner, c.compIcon, c.menuYN, 
                c.menuOrder, c.compInner, c.compRecordName, c.compActive, p.pgid, p.pgDir, 
                p.pgTitle, p.pgHeading, p.pgFilename, p.datatables_YN, p.fullcalendar_YN,
                p.editable_YN, p.newdatatables_YN, p.pk, p.update_type
            FROM 
                pgpages p 
            INNER JOIN 
                pgcomps c ON c.compID = p.compID 
            INNER JOIN 
                pgapps a ON a.appID = c.appid 
            WHERE 
                p.pgDir = <cfqueryparam value="#trim(arguments.thispage)#" cfsqltype="CF_SQL_VARCHAR">
        </cfquery>

<cfreturn result>
</cffunction>
<cffunction output="false" name="FindFields" access="public" returntype="query">
    <cfargument name="thispage" type="string" required="true">

<cfquery name="result" >
            SELECT 
                a.appname, c.compname, p.pgname, f.fname, 
                a.appId, a.appName, a.appDescription, a.appLogoName, 
                a.colorTopBar, a.colorLeftSideBar, c.compid, c.compDir, 
                c.compTable, c.compowner, c.compIcon, c.menuYN, 
                c.menuOrder, c.compInner, c.compRecordName, c.compActive, 
                p.pgid, p.pgDir, p.pgTitle, p.pgHeading, p.pgFilename, 
                p.datatables_YN, p.fullcalendar_YN, p.editable_YN, 
                p.newdatatables_YN, p.pk, f.fieldid, f.pgid as fieldPgid,
                f.ftype, f.ftypefull, f.update_yn, f.updatename,
                f.updatetype, f.fkey, f.num_min, f.num_max
            FROM 
                pgpages p
            INNER JOIN 
                pgcomps c ON c.compID = p.compID
            INNER JOIN 
                pgapps a ON a.appID = c.appid
            INNER JOIN 
                pgfields f ON f.pgid = p.pgid
            WHERE 
                p.pgDir = <cfqueryparam value="#trim(arguments.thispage)#" cfsqltype="CF_SQL_VARCHAR">
        </cfquery>

<cfreturn result>
</cffunction>
<cffunction output="false" name="SELpgpages_24004" access="public" returntype="query">
    <cfargument name="thispage" type="string" required="true">

<cfquery name="result" >
            SELECT 
                a.appname, c.compname, p.pgname, f.fname, 
                a.appId, a.appName, a.appDescription, a.appLogoName, 
                a.colorTopBar, a.colorLeftSideBar, c.compid, c.compDir, 
                c.compTable, c.compowner, c.compIcon, c.menuYN, 
                c.menuOrder, c.compInner, c.compRecordName, c.compActive, 
                p.pgid, p.pgDir, p.pgTitle, p.pgHeading, p.pgFilename, 
                p.datatables_YN, p.fullcalendar_YN, p.editable_YN, 
                p.newdatatables_YN, p.pk, f.fieldid, f.pgid as fieldPgid,
                f.ftype, f.ftypefull, f.update_yn, f.updatename,
                f.updatetype, f.fkey, f.num_min, f.num_max
            FROM 
                pgpages p
            INNER JOIN 
                pgcomps c ON c.compID = p.compID
            INNER JOIN 
                pgapps a ON a.appID = c.appid
            INNER JOIN 
                pgfields f ON f.pgid = p.pgid
            WHERE 
                p.pgDir = <cfqueryparam value="#trim(arguments.thispage)#" cfsqltype="CF_SQL_VARCHAR">
        </cfquery>

<cfreturn result>
</cffunction>
<cffunction output="false" name="DETpgpages_24197" access="public" returntype="query">
    <cfargument name="details_pgid" type="numeric" required="true">

<cfquery name="result" >
            SELECT pgdir
            FROM pgpages
            WHERE pgid = <cfqueryparam value="#arguments.details_pgid#" cfsqltype="CF_SQL_INTEGER">
        </cfquery>

<cfreturn result>
</cffunction>
<cffunction output="false" name="SELpgpages_24210" access="public" returntype="query">
    <cfargument name="compactive" type="string" required="true">

<cfquery name="result" >
            SELECT p.pgid AS ID, p.pgname AS name
            FROM pgpages p
            INNER JOIN pgcomps c ON c.compid = p.compid
            WHERE c.compactive = <cfqueryparam value="#arguments.compactive#" cfsqltype="CF_SQL_CHAR">
            ORDER BY p.pgname
        </cfquery>

<cfreturn result>
</cffunction>
<cffunction output="false" name="DETpgpages_24259" access="public" returntype="query">
    <cfargument name="compid" type="numeric" required="true">
    <cfargument name="pgid" type="numeric" required="true">

<cfquery name="result" >
            SELECT pgid, pgdir 
            FROM pgpages 
            WHERE compid = <cfqueryparam value="#arguments.compid#" cfsqltype="CF_SQL_INTEGER"> 
            AND pgid <> <cfqueryparam value="#arguments.pgid#" cfsqltype="CF_SQL_INTEGER"> 
            AND pgfilename = <cfqueryparam value="details.cfm" cfsqltype="CF_SQL_VARCHAR">
        </cfquery>

<cfreturn result>
</cffunction>

<cffunction output="false" name="SELpgpages_24300" access="public" returntype="query">
    <cfargument name="rpgid" type="numeric" required="true">

<cfquery name="result" >
            SELECT 
                a.appname, a.appAuthor, c.compname, p.pgname, a.appId, a.appDescription, 
                a.appLogoName, a.colorTopBar, a.colorLeftSideBar, c.compid, c.compDir, 
                c.compTable, c.compowner, c.compIcon, c.menuYN, c.menuOrder, c.compInner, 
                c.compRecordName, c.compActive, p.pgid, p.pgDir, p.pgTitle, p.pgHeading, 
                p.pgFilename, p.datatables_YN, p.fullcalendar_YN, p.editable_YN, 
                p.newdatatables_YN, p.pk, p.update_type
            FROM 
                pgpages p 
            INNER JOIN 
                pgcomps c ON c.compID = p.compID 
            INNER JOIN 
                pgapps a ON a.appID = c.appid
            WHERE 
                p.pgid = <cfqueryparam value="#arguments.rpgid#" cfsqltype="CF_SQL_INTEGER">
        </cfquery>

<cfreturn result>
</cffunction>

<cffunction output="false" name="SELpgpages_24301" access="public" returntype="query">
    <cfargument name="rpgid" type="numeric" required="true">

<cfquery name="result" >
            SELECT 
                a.appname, c.compname, p.pgname, f.fname, f.num_min, f.num_max, 
                f.required_yn, a.appId, a.appName, a.appDescription, a.appLogoName, 
                a.colorTopBar, a.colorLeftSideBar, c.compid, c.compDir, c.compTable, 
                c.compowner, c.compIcon, c.menuYN, c.menuOrder, c.compInner, 
                c.compRecordName, c.compActive, p.pgid, p.pgDir, p.pgTitle, 
                p.pgHeading, p.pgFilename, p.datatables_YN, p.fullcalendar_YN,
                p.editable_YN, p.newdatatables_YN, p.pk, f.fieldid, f.pgid,
                f.tableSelect, f.ftype, f.ftypefull, f.update_yn,
                f.updatename, f.updatetype, f.fkey, p.update_type
            FROM pgpages p
            INNER JOIN pgcomps c ON c.compID = p.compID
            INNER JOIN pgapps a ON a.appID = c.appid
            LEFT JOIN pgfields f ON f.pgid = p.pgid
            WHERE p.pgid = <cfqueryparam value="#arguments.rpgid#" cfsqltype="CF_SQL_INTEGER">
            AND f.update_yn = <cfqueryparam value="y" cfsqltype="CF_SQL_CHAR">
        </cfquery>

<cfreturn result>
</cffunction>

<cffunction output="false" name="RESpgpages_24302" access="public" returntype="query">
    <cfargument name="rpgid" type="numeric" required="true">

<cfquery name="result" >
            SELECT 
                a.appname, c.compname, p.pgname, f.fname, f.required_yn, f.num_min, f.num_max,
                a.appId, a.appName, a.appDescription, a.appLogoName, a.colorTopBar, a.colorLeftSideBar,
                c.compid, c.compDir, c.compTable, c.compowner, c.compIcon, c.menuYN, c.menuOrder,
                c.compInner, c.compRecordName, c.compActive,
                p.pgid, p.pgDir, p.pgTitle, p.pgHeading, p.pgFilename,
                p.datatables_YN, p.fullcalendar_YN, p.editable_YN, p.newdatatables_YN,
                p.pk,
                f.fieldid, f.pgid as fieldPgid, f.tableSelect, f.ftype, f.ftypefull,
                f.update_yn, f.updatename, f.updatetype, f.fkey,
                p.update_type
            FROM 
                pgpages p
            INNER JOIN 
                pgcomps c ON c.compID = p.compID
            INNER JOIN 
                pgapps a ON a.appID = c.appid
            LEFT JOIN 
                pgfields f ON f.pgid = p.pgid
            WHERE 
                p.pgid = <cfqueryparam value="#arguments.rpgid#" cfsqltype="CF_SQL_INTEGER">
            AND 
                f.results_yn = <cfqueryparam value="y" cfsqltype="CF_SQL_CHAR">
        </cfquery>

<cfreturn result>
</cffunction>
<cffunction output="false" name="SELpgpages_24303" access="public" returntype="query">
    <cfargument name="rpgid" type="numeric" required="true">

<cfquery name="result" >
            SELECT f.fname, f.ftype 
            FROM pgpages p 
            INNER JOIN pgcomps c ON c.compID = p.compID 
            INNER JOIN pgapps a ON a.appID = c.appid 
            LEFT JOIN pgfields f ON f.pgid = p.pgid 
            WHERE p.pgid = <cfqueryparam value="#arguments.rpgid#" cfsqltype="CF_SQL_INTEGER"> 
              AND f.updatename = <cfqueryparam value="ID" cfsqltype="CF_SQL_VARCHAR">
        </cfquery>

<cfreturn result>
</cffunction>
<cffunction output="false" name="SELpgpages_24304" access="public" returntype="query">
    <cfargument name="rpgid" type="numeric" required="true">

<cfquery name="result" >
            SELECT 
                a.appname, c.compname, p.pgname, f.fname, f.required_yn, f.num_min, f.num_max, 
                a.appId, a.appName, a.appDescription, a.appLogoName, a.colorTopBar, a.colorLeftSideBar, 
                c.compid, c.compDir, c.compTable, c.compowner, c.compIcon, c.menuYN, c.menuOrder, 
                c.compInner, c.compRecordName, c.compActive, p.pgid, p.pgDir, p.pgTitle, p.pgHeading,
                p.pgFilename, p.datatables_YN, p.fullcalendar_YN, p.editable_YN, p.newdatatables_YN,
                p.pk, f.fieldid, f.pgid AS fieldPgid, f.tableSelect, f.ftype, f.ftypefull,
                f.update_yn, f.add_yn, f.updatename, f.updatetype, f.fkey, p.update_type
            FROM pgpages p 
            INNER JOIN pgcomps c ON c.compID = p.compID 
            INNER JOIN pgapps a ON a.appID = c.appid 
            LEFT JOIN pgfields f ON f.pgid = p.pgid 
            WHERE p.pgid = <cfqueryparam value="#arguments.rpgid#" cfsqltype="CF_SQL_INTEGER"> 
            AND f.add_yn = <cfqueryparam value="y" cfsqltype="CF_SQL_CHAR">
        </cfquery>

<cfreturn result>
</cffunction>
<cffunction output="false" name="SELpgpages_24305" access="public" returntype="query">
    <cfargument name="rpgid" type="numeric" required="true">

<cfquery name="result" >
            SELECT 
                a.appname, c.compname, p.pgname, f.fname, f.num_min, f.num_max, 
                f.required_yn, a.appId, a.appName, a.appDescription, a.appLogoName, 
                a.colorTopBar, a.colorLeftSideBar, c.compid, c.compDir, c.compTable, 
                c.compowner, c.compIcon, c.menuYN, c.menuOrder, c.compInner, 
                c.compRecordName, c.compActive, p.pgid, p.pgDir, p.pgTitle, 
                p.pgHeading, p.pgFilename, p.datatables_YN, p.fullcalendar_YN,
                p.editable_YN, p.newdatatables_YN, p.pk, f.fieldid, f.pgid,
                f.tableSelect, f.ftype, f.ftypefull, f.update_yn, f.add_yn,
                f.updatename, f.updatetype, f.fkey, p.update_type
            FROM 
                pgpages p
            INNER JOIN 
                pgcomps c ON c.compID = p.compID
            INNER JOIN 
                pgapps a ON a.appID = c.appid
            LEFT JOIN 
                pgfields f ON f.pgid = p.pgid
            WHERE 
                p.pgid = <cfqueryparam value="#arguments.rpgid#" cfsqltype="CF_SQL_INTEGER"> 
                AND f.update_yn = <cfqueryparam value="y" cfsqltype="CF_SQL_CHAR">
        </cfquery>

<cfreturn result>
</cffunction>
<cffunction output="false" name="RESpgpages_24652" access="public" returntype="query">
    <cfargument name="pgid" type="numeric" required="true">

<cfquery name="result" >
            SELECT 
                f.fname, f.fieldid, f.pgid, f.ftype, f.ftypefull, 
                f.update_yn, f.updatename, f.updatetype, f.fkey, 
                f.det_cols, c2.comptable AS comptableb, c.comptable, 
                CONCAT('t', f.fieldid) AS talias
            FROM 
                pgpages p
            INNER JOIN 
                pgcomps c ON c.compID = p.compID
            INNER JOIN 
                pgapps a ON a.appID = c.appid
            INNER JOIN 
                pgfields f ON f.pgid = p.pgid
            LEFT JOIN 
                pgfields f2 ON f.fkey = f2.fieldid
            LEFT JOIN 
                pgpages p2 ON p2.pgid = f2.pgid
            LEFT JOIN 
                pgcomps c2 ON c2.compid = p2.compid
            WHERE 
                p.pgid = <cfqueryparam value="#arguments.pgid#" cfsqltype="CF_SQL_INTEGER"> 
                AND f.details_yn = <cfqueryparam value="Y" cfsqltype="CF_SQL_CHAR">
            ORDER BY 
                f.displayOrder
        </cfquery>

<cfreturn result>
</cffunction>
<cffunction output="false" name="SELpgpages_24653" access="public" returntype="query">
    <cfargument name="pgid" type="numeric" required="true">

<cfquery name="result" >
            SELECT 
                f.fname, 
                f2.fname AS fnameb, 
                c2.comptable AS comptableb, 
                c.comptable, 
                f2.fieldid, 
                f2.fkey, 
                concat('t', f.fieldid) AS talias
            FROM 
                pgpages p
            INNER JOIN 
                pgcomps c ON c.compID = p.compID
            INNER JOIN 
                pgapps a ON a.appID = c.appid
            INNER JOIN 
                pgfields f ON f.pgid = p.pgid
            LEFT JOIN 
                pgfields f2 ON f.fkey = f2.fieldid
            LEFT JOIN 
                pgpages p2 ON p2.pgid = f2.pgid
            LEFT JOIN 
                pgcomps c2 ON c2.compid = p2.compid
            WHERE 
                p.pgid = <cfqueryparam value="#arguments.pgid#" cfsqltype="CF_SQL_INTEGER"> 
                AND f.details_yn = <cfqueryparam value="Y" cfsqltype="CF_SQL_CHAR"> 
                AND f.fkey <> ''
        </cfquery>

<cfreturn result>
</cffunction>
<cffunction output="false" name="RESpgpages_24739" access="public" returntype="query">
    <cfargument name="pgid" type="numeric" required="true">

<cfquery name="result" >
            SELECT 
                f.fname, 
                f.fieldid, 
                f.pgid, 
                f.ftype, 
                f.ftypefull, 
                f.update_yn, 
                f.updatename, 
                f.updatetype, 
                f.fkey, 
                c2.comptable AS comptableb, 
                c.comptable, 
                CONCAT('t', f.fieldid) AS talias
            FROM 
                pgpages p
            INNER JOIN 
                pgcomps c ON c.compID = p.compID
            INNER JOIN 
                pgapps a ON a.appID = c.appid
            INNER JOIN 
                pgfields f ON f.pgid = p.pgid
            LEFT JOIN 
                pgfields f2 ON f.fkey = f2.fieldid
            LEFT JOIN 
                pgpages p2 ON p2.pgid = f2.pgid
            LEFT JOIN 
                pgcomps c2 ON c2.compid = p2.compid
            WHERE 
                p.pgid = <cfqueryparam value="#arguments.pgid#" cfsqltype="CF_SQL_INTEGER"> 
            AND 
                f.results_yn = <cfqueryparam value="Y" cfsqltype="CF_SQL_CHAR">
            ORDER BY 
                f.displayOrder
        </cfquery>

<cfreturn result>

</cffunction>

<cffunction output="false" name="getDynamicQueryx" access="public" returntype="query">
    <cfargument name="pgid" type="numeric" required="true">

<cfquery name="result" >
            SELECT 
                f.fname, 
                f2.fname AS fnameb, 
                c2.comptable AS comptableb, 
                c.comptable, 
                f2.fieldid, 
                f2.fkey, 
                CONCAT('t', f.fieldid) AS talias 
            FROM 
                pgpages p 
            INNER JOIN 
                pgcomps c ON c.compID = p.compID 
            INNER JOIN 
                pgapps a ON a.appID = c.appid 
            INNER JOIN 
                pgfields f ON f.pgid = p.pgid 
            LEFT JOIN 
                pgfields f2 ON f.fkey = f2.fieldid 
            LEFT JOIN 
                pgpages p2 ON p2.pgid = f2.pgid 
            LEFT JOIN 
                pgcomps c2 ON c2.compid = p2.compid 
            WHERE 
                p.pgid = <cfqueryparam value="#arguments.pgid#" cfsqltype="CF_SQL_INTEGER">
                AND f.results_yn = 'Y' 
                AND f.fkey <> ''
        </cfquery>

<cfreturn result>
</cffunction>

<cffunction output="false" name="RESpgpages_24777" access="public" returntype="query">
    <cfargument name="rpgid" type="numeric" required="true">

<cfquery name="result" >
            SELECT 
                f.fname, f.fieldid, f.pgid, f.ftype, f.ftypefull, f.update_yn, 
                f.updatename, f.updatetype, f.fkey, f.det_cols, 
                c2.comptable AS comptableb, c.comptable, 
                CONCAT('t', f.fieldid) AS talias
            FROM 
                pgpages p
            INNER JOIN 
                pgcomps c ON c.compID = p.compID
            INNER JOIN 
                pgapps a ON a.appID = c.appid
            INNER JOIN 
                pgfields f ON f.pgid = p.pgid
            LEFT JOIN 
                pgfields f2 ON f.fkey = f2.fieldid
            LEFT JOIN 
                pgpages p2 ON p2.pgid = f2.pgid
            LEFT JOIN 
                pgcomps c2 ON c2.compid = p2.compid
            WHERE 
                p.pgid = <cfqueryparam value="#arguments.rpgid#" cfsqltype="CF_SQL_INTEGER">
                AND f.update_yn = <cfqueryparam value="Y" cfsqltype="CF_SQL_CHAR">
            ORDER BY 
                f.displayOrder
        </cfquery>

<cfreturn result>
</cffunction>

<cffunction output="false" name="SELpgpages_24778" access="public" returntype="query">
    <cfargument name="rpgid" type="numeric" required="true">

<cfquery name="result" >
            SELECT 
                f.fname, 
                f2.fname AS fnameb, 
                c2.comptable AS comptableb, 
                c.comptable, 
                f2.fieldid, 
                f2.fkey, 
                CONCAT('t', f.fieldid) AS talias
            FROM 
                pgpages p
            INNER JOIN 
                pgcomps c ON c.compID = p.compID
            INNER JOIN 
                pgapps a ON a.appID = c.appid
            INNER JOIN 
                pgfields f ON f.pgid = p.pgid
            LEFT JOIN 
                pgfields f2 ON f.fkey = f2.fieldid
            LEFT JOIN 
                pgpages p2 ON p2.pgid = f2.pgid
            LEFT JOIN 
                pgcomps c2 ON c2.compid = p2.compid
            WHERE 
                p.pgid = <cfqueryparam value="#arguments.rpgid#" cfsqltype="CF_SQL_INTEGER"> 
                AND f.details_yn = <cfqueryparam value="Y" cfsqltype="CF_SQL_CHAR"> 
                AND f.fkey <> ''
        </cfquery>

<cfreturn result>
</cffunction>

<cffunction output="false" name="getPageDetails" access="public" returntype="struct"  hint="Fetch page details by page ID or URL">
        <cfargument name="pgid" type="string" required="false" default="">
        <cfargument name="pgDir" type="string" required="false" default="">

<cfset var page = {}>

<cfif NOT Len(arguments.pgid) AND NOT Len(arguments.pgDir)>

</cfif>

<cfquery result="result" name="qPageDetails" >
            SELECT
                a.appname, p.allowdelete_yn, p.allowupdate_yn, p.allowadd_yn, p.allowdetails_yn,
                a.appAuthor, c.compname, p.pgname, a.appId, a.appDescription,
                a.appLogoName, a.colorTopBar, a.colorLeftSideBar, a.mocktoday,
                a.mock_yn, c.compid, c.compDir, c.compTable, c.compowner,
                c.compIcon, c.menuYN, c.menuOrder, c.compInner, c.compRecordName,
                c.compActive, p.pgid, p.pgDir, p.pgTitle, p.pgHeading,
                p.pgFilename, p.datatables_YN, p.fullcalendar_YN, p.editable_YN,
                p.newdatatables_YN, p.pk, p.update_type
            FROM pgpages p
            INNER JOIN pgcomps c ON c.compID = p.compID
            INNER JOIN pgapps a ON a.appID = c.appid
            WHERE 
            <cfif Len(arguments.pgid)>
                p.pgid = <cfqueryparam value="#arguments.pgid#" cfsqltype="cf_sql_varchar">
            <cfelse>
                p.pgDir = <cfqueryparam value="#trim(arguments.pgDir)#" cfsqltype="cf_sql_varchar">
                AND p.isdef = 1
            </cfif>
        </cfquery>

<cfif qPageDetails.recordCount EQ 1>
            <cfset page = {
                "appname": qPageDetails.appname,
                "allowdelete_yn": qPageDetails.allowdelete_yn,
                "allowupdate_yn": qPageDetails.allowupdate_yn,
                "allowadd_yn": qPageDetails.allowadd_yn,
                "allowdetails_yn": qPageDetails.allowdetails_yn,
                "appAuthor": qPageDetails.appAuthor,
                "compname": qPageDetails.compname,
                "pgname": qPageDetails.pgname,
                "appId": qPageDetails.appId,
                "appDescription": qPageDetails.appDescription,
                "appLogoName": qPageDetails.appLogoName,
                "colorTopBar": qPageDetails.colorTopBar,
                "colorLeftSideBar": qPageDetails.colorLeftSideBar,
                "mocktoday": qPageDetails.mocktoday,
                "mock_yn": qPageDetails.mock_yn,
                "compid": qPageDetails.compid,
                "compDir": qPageDetails.compDir,
                "compTable": qPageDetails.compTable,
                "compowner": qPageDetails.compowner,
                "compIcon": qPageDetails.compIcon,
                "menuYN": qPageDetails.menuYN,
                "menuOrder": qPageDetails.menuOrder,
                "compInner": qPageDetails.compInner,
                "compRecordName": qPageDetails.compRecordName,
                "compActive": qPageDetails.compActive,
                "pgid": qPageDetails.pgid,
                "pgDir": qPageDetails.pgDir,
                "pgTitle": qPageDetails.pgTitle,
                "pgHeading": qPageDetails.pgHeading,
                "pgFilename": qPageDetails.pgFilename,
                "datatables_YN": qPageDetails.datatables_YN,
                "fullcalendar_YN": qPageDetails.fullcalendar_YN,
                "editable_YN": qPageDetails.editable_YN,
                "newdatatables_YN": qPageDetails.newdatatables_YN,
                "pk": qPageDetails.pk,
                "update_type": qPageDetails.update_type
            }>
        </cfif>

<cfreturn page>
    </cffunction>

<cffunction output="false" name="getPageLinksByLocation" access="public" returntype="struct"  hint="Fetch top and bottom CSS/JS links for the given page">
        <cfargument name="pgid" type="string" required="true" hint="Page ID to fetch links for">
        <cfargument name="version" type="string" required="true" hint="Version to append to the URL as a cache-busting parameter">

<cfset var links = { top_links = "", bottom_links = "" }>

<cfquery result="result" name="qPageLinks">
            SELECT
                CASE 
                    WHEN l.linktype = 'css' THEN 
                        CONCAT('<link href="', l.linkurl, '?ver=6', <cfqueryparam value="#arguments.version#" cfsqltype="cf_sql_varchar">, '" ', 
                               IF(l.rel IS NOT NULL, CONCAT('rel="', l.rel, '" '), ''), 
                               IF(l.hrefid IS NOT NULL, CONCAT('id="', l.hrefid, '" '), ''), 
                               'type="text/css" />')
                    WHEN l.linktype = 'script' THEN 
                        CONCAT('<script src="', l.linkurl, '?ver=6', <cfqueryparam value="#arguments.version#" cfsqltype="cf_sql_varchar">, '"></script>')
                    ELSE ''
                END AS link_html,
                l.linkloc_tb 
            FROM pgapplinks l
            INNER JOIN pgplugins p ON p.pluginName = l.pluginname
            INNER JOIN pgpagespluginsxref x ON x.pluginid = p.pluginid
            INNER JOIN pgpages g ON g.pgid = x.pgid
            WHERE g.pgid = <cfqueryparam value="#arguments.pgid#" cfsqltype="cf_sql_integer">
            AND l.IsDeleted = 0
            ORDER BY l.link_no ASC
        </cfquery>

<!--- Loop through the query and add links to the appropriate section --->
        <cfloop query="qPageLinks">
            <cfif qPageLinks.linkloc_tb EQ "t">
                <!--- Append to top_links --->
                <cfset links.top_links = links.top_links & qPageLinks.link_html>
            <cfelseif qPageLinks.linkloc_tb EQ "b">
                <!--- Append to bottom_links --->
                <cfset links.bottom_links = links.bottom_links & qPageLinks.link_html>
            </cfif>
        </cfloop>

<!--- Return the struct containing top and bottom links --->
        <cfreturn links>
    </cffunction>

<!--- Function to get script_include links for a page --->
    <cffunction output="false" name="getIncludeLinks" access="public" returntype="array"  hint="Fetch script_include links for the given page">
        <cfargument name="pgid" type="numeric" required="true" hint="Page ID to fetch include links for">

<!--- Initialize an empty array to store the include links --->
        <cfset var includeLinksArray = []>

<!--- Query to fetch the script_include links --->
        <cfquery result="result" name="includeLinks">
            SELECT l.linkurl
            FROM pgapplinks l
            INNER JOIN pgplugins p ON p.pluginName = l.pluginname
            INNER JOIN pgpagespluginsxref x ON x.pluginid = p.pluginid
            INNER JOIN pgpages g ON g.pgid = x.pgid
            WHERE g.pgid = <cfqueryparam value="#arguments.pgid#" cfsqltype="cf_sql_integer">
            AND l.IsDeleted = 0
            AND l.linktype = 'script_include'
            ORDER BY l.link_no ASC
        </cfquery>

<!--- Loop through the query and populate the array --->
        <cfloop query="includeLinks">
            <cfset ArrayAppend(includeLinksArray, includeLinks.linkurl)>
        </cfloop>

<!--- Return the array of include links --->
        <cfreturn includeLinksArray>
    </cffunction>

<!--- Function to retrieve a select list of active pages --->
    <cffunction output="false" name="pages_sel" access="remote" returntype="query"  hint="Get a select list of active pages.">
        <cfquery result="result" name="pages">
            SELECT 
                p.pgid AS ID,
                p.pgname AS name
            FROM pgpages p
            INNER JOIN pgcomps c ON c.compid = p.compid
            WHERE c.compactive = 'Y'
            ORDER BY p.pgname
        </cfquery>
        <!--- Return the query result --->
        <cfreturn pages />
    </cffunction>
</cfcomponent>
