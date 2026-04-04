<cfcomponent displayname="PageAppLinks" >

<cffunction output="false" name="GetPageAppLinks" access="public" returntype="query" >
        <cfargument name="pgid" type="numeric" required="yes">

<!--- PERF: Page layout links rarely change; cache for 30 minutes. --->
<!--- MIGRATE: In Go, this becomes a Redis-cached lookup keyed on pgid. --->
<cfquery result="result" name="FindLinksT" cachedwithin="#createTimeSpan(0,0,30,0)#">
            SELECT
                l.linkid,
                l.linkurl,
                l.linkname,
                l.linktype,
                l.link_no,
                l.linkloc_tb,
                l.pluginname,
                l.rel,
                l.hrefid
            FROM
                pgapplinks l
                INNER JOIN pgplugins p ON p.pluginName = l.pluginname
                INNER JOIN pgpagespluginsxref x ON x.pluginid = p.pluginid
                INNER JOIN pgpages g ON g.pgid = x.pgid
            WHERE
                g.pgid = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#arguments.pgid#">
                AND l.linkloc_tb in ('t','i')
            ORDER BY
                l.link_no
        </cfquery>

<cfreturn FindLinksT>
    </cffunction>

<cffunction output="false" name="GetLinksForPageB" access="public" returntype="query" >
        <cfargument name="pgid" type="numeric" required="true">

<!--- PERF: Page layout links rarely change; cache for 30 minutes. --->
<cfquery name="result" cachedwithin="#createTimeSpan(0,0,30,0)#">
            SELECT
                l.linkid, l.linkurl, l.linkname, l.linktype,
                l.link_no, l.linkloc_tb, l.pluginname,
                l.rel, l.hrefid
            FROM pgapplinks l
            INNER JOIN pgplugins p ON p.pluginName = l.pluginname
            INNER JOIN pgpagespluginsxref x ON x.pluginid = p.pluginid
            INNER JOIN pgpages g ON g.pgid = x.pgid
            WHERE g.pgid = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#arguments.pgid#">
              AND l.linkloc_tb = 'b'
              AND l.linkname NOT LIKE '%calendar - custom%'
              AND l.linktype <> 'css'
            ORDER BY l.link_no
        </cfquery>

<cfreturn result>
    </cffunction>

</cfcomponent>