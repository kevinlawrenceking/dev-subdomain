<cfcomponent displayname = "TaoVersionService" hint = "Handles operations for TaoVersion table" 
             output = "false">

                 <!--- Function to get active versions --->
    <cffunction name="getActiveTaoVersions" access="public" returntype="query" output="false" hint="Fetches active versions with 'Pending' status">
   
        <cfset var activeVersions = "">

        <!--- Query to fetch active versions --->
        <cfquery name="activeVersions" >
            SELECT 
                v.verid AS id,
                CONCAT(v.major, '.', v.minor, '.', v.patch, '.', v.version, '.', v.build, ' - ', v.versiontype) AS Name,
                v.versionstatus
            FROM taoversions v
            WHERE v.versionstatus = 'Pending'
            ORDER BY v.major, v.minor, v.patch, v.version, v.build
        </cfquery>

        <!--- Return the query result --->
        <cfreturn activeVersions />
    </cffunction>




              <cffunction name="versions_sel" access="public" returntype="query" output="false">

        <cfquery name="result">
            SELECT 
                verid AS id, 
                CONCAT(major, '.', minor, '.', patch, '.', version, '.', build) as name,
                versiontype,
                major,
                minor,
                patch,
                version,
                build, 
                alphabeta,
                isactive 
            FROM 
                taoversions 
            ORDER BY 
                major, minor, patch, version
        </cfquery>

        <cfreturn result>
    </cffunction>



<cffunction name = "SELtaoversions" access = "public" returntype = "query">

<cfquery name = "result">
            SELECT verid
            FROM taoversions
            WHERE 1=1
            AND isactive = 1
            ORDER BY isactive DESC, verid DESC
            LIMIT 1
        </cfquery>
        <cfreturn result>
    </cffunction>

<cffunction name = "SELtaoversions_24215" access = "public" returntype = "query">
        <cfargument name = "major" type = "numeric" required = "false"/>
        <cfargument name = "minor" type = "numeric" required = "false"/>
        <cfargument name = "patch" type = "numeric" required = "false"/>
        <cfargument name = "version" type = "string" required = "false"/>

<cfset var local = {}>

<cfset local.queryString = "
        SELECT verid AS id, major, minor, patch, version, versiontype, alphabeta, isactive 
        FROM taoversions 
        WHERE 1=1
    ">

<cfif structKeyExists(arguments, "major")>
            <cfset local.queryString &= " AND major = ?">
            <cfset arrayAppend(local.params, {value = arguments.major, cfsqltype = "CF_SQL_INTEGER"})>
        </cfif>

<cfif structKeyExists(arguments, "minor")>
            <cfset local.queryString &= " AND minor = ?">
            <cfset arrayAppend(local.params, {value = arguments.minor, cfsqltype = "CF_SQL_INTEGER"})>
        </cfif>

<cfif structKeyExists(arguments, "patch")>
            <cfset local.queryString &= " AND patch = ?">
            <cfset arrayAppend(local.params, {value = arguments.patch, cfsqltype = "CF_SQL_INTEGER"})>
        </cfif>

<cfif structKeyExists(arguments, "version")>
            <cfset local.queryString &= " AND version = ?">
            <cfset arrayAppend(local.params, {value = arguments.version, cfsqltype = "CF_SQL_VARCHAR"})>
        </cfif>

<cfset local.queryString &= " ORDER BY major, minor, patch, version">

<cfquery name = "local.result">#local.queryString#
            <cfloop array = "#local.params#" index = "param">
                <cfqueryparam value = "#param.value#" cfsqltype = "#param.cfsqltype#">
            </cfloop>
        </cfquery>

<cfreturn local.result>
    </cffunction>

<cffunction name = "SELtaoversions_24331" access = "public" returntype = "query">

<cfquery name = "result">
            SELECT verid
            FROM taoversions
            ORDER BY verid DESC
            LIMIT 1
        </cfquery>

<cfreturn result>
    </cffunction>

<cffunction name = "SELtaoversions_24386" access = "public" returntype = "query">
        <cfargument name = "old_verid" type = "numeric" required = "true"/>

<cfquery name = "result">
            SELECT CONCAT(v.major, '.', v.minor, '.', v.patch, '.', v.version, '.', v.build) AS 
            old_findname
            FROM taoversions v
            WHERE v.verid = <cfqueryparam value = "#arguments.old_verid#" 
                      cfsqltype = "CF_SQL_INTEGER">
        </cfquery>

<cfreturn result>
    </cffunction>

<cffunction name = "SELtaoversions_24387" access = "public" returntype = "query">
        <cfargument name = "new_verid" type = "numeric" required = "true"/>

<cfquery name = "result">
            SELECT CONCAT(v.major, '.', v.minor, '.', v.patch, '.', v.version, '.', v.build) AS 
            new_findname
            FROM taoversions v
            WHERE v.verid = <cfqueryparam value = "#arguments.new_verid#" 
                      cfsqltype = "CF_SQL_INTEGER">
        </cfquery>

<cfreturn result>
    </cffunction>

<cffunction name = "SELtaoversions_24469" access = "public" returntype = "query">
        <cfargument name = "new_major" type = "numeric" required = "true"/>
        <cfargument name = "new_minor" type = "numeric" required = "true"/>
        <cfargument name = "new_patch" type = "numeric" required = "true"/>
        <cfargument name = "new_version" type = "string" required = "true"/>
        <cfargument name = "new_build" type = "numeric" required = "true"/>

<cfquery name = "result">
            SELECT *
            FROM taoversions
            WHERE major = <cfqueryparam value = "#arguments.new_major#" cfsqltype = "CF_SQL_INTEGER">
            AND minor = <cfqueryparam value = "#arguments.new_minor#" cfsqltype = "CF_SQL_INTEGER">
            AND patch = <cfqueryparam value = "#arguments.new_patch#" cfsqltype = "CF_SQL_INTEGER">
            AND version = <cfqueryparam value = "#arguments.new_version#" 
                      cfsqltype = "CF_SQL_VARCHAR">
            AND build = <cfqueryparam value = "#arguments.new_build#" cfsqltype = "CF_SQL_INTEGER">
        </cfquery>

<cfreturn result>
    </cffunction>

<cffunction name = "INStaoversions" access = "public" returntype = "numeric">
        <cfargument name = "new_major" type = "numeric" required = "true"/>
        <cfargument name = "new_minor" type = "numeric" required = "true"/>
        <cfargument name = "new_patch" type = "numeric" required = "true"/>
        <cfargument name = "new_versionstatus" type = "string" required = "true"/>
        <cfargument name = "new_versiontype" type = "string" required = "true"/>
        <cfargument name = "new_version" type = "numeric" required = "true"/>
        <cfargument name = "new_build" type = "numeric" required = "true"/>
        <cfargument name = "new_reviewDate" type = "date" required = "false"/>
        <cfargument name = "new_releaseDate" type = "date" required = "false"/>
        <cfargument name = "new_reviewtime" type = "string" required = "false"/>
        <cfargument name = "new_releasetime" type = "string" required = "false"/>
        <cfargument name = "new_hoursavail" type = "numeric" required = "false"/>

<cfquery result="result" >
            INSERT INTO taoversions (
            major, minor, patch, versionstatus, versiontype, version, build,
            reviewDate, releaseDate, reviewtime, releasetime, hoursavail
            ) VALUES
             (<cfqueryparam cfsqltype = "cf_sql_integer" value = "#arguments.new_major#"/>
            ,<cfqueryparam cfsqltype = "cf_sql_integer" value = "#arguments.new_minor#"/>
            ,<cfqueryparam cfsqltype = "cf_sql_integer" value = "#arguments.new_patch#"/>
            ,<cfqueryparam cfsqltype = "cf_sql_varchar" value = "#arguments.new_versionstatus#"/>
            ,<cfqueryparam cfsqltype = "cf_sql_varchar" value = "#arguments.new_versiontype#"/>
            ,<cfqueryparam cfsqltype = "cf_sql_integer" value = "#arguments.new_version#"/>
            ,<cfqueryparam cfsqltype = "cf_sql_integer" value = "#arguments.new_build#"/>
            ,
            <cfif arguments.new_reviewDate neq "">
                <cfqueryparam cfsqltype = "cf_sql_date" value = "#arguments.new_reviewDate#"/>
            <cfelse>
                NULL 
            </cfif>
            ,
            <cfif arguments.new_releaseDate neq "">
                <cfqueryparam cfsqltype = "cf_sql_date" value = "#arguments.new_releaseDate#"/>
            <cfelse>
                NULL 
            </cfif>
            ,
            <cfif arguments.new_reviewtime neq "">
                <cfqueryparam cfsqltype = "cf_sql_time" value = "#arguments.new_reviewtime#"/>
            <cfelse>
                NULL 
            </cfif>
            ,
            <cfif arguments.new_releasetime neq "">
                <cfqueryparam cfsqltype = "cf_sql_time" value = "#arguments.new_releasetime#"/>
            <cfelse>
                NULL 
            </cfif>
            ,
            <cfif arguments.new_hoursavail neq "">
                <cfqueryparam cfsqltype = "cf_sql_float" 
                              value = "#numberformat(arguments.new_hoursavail,'9.99')#"/>
            <cfelse>
                NULL 
            </cfif>
            )
        </cfquery>
<cfreturn result.generatedKey>

</cffunction>

<cffunction name="UPDtaoversions" access="public" returntype="void" output="false" hint="Updates a version record in the taoversions table.">
    <!--- Define arguments for the function --->
    <cfargument name="verid" type="numeric" required="true" hint="The ID of the version to update.">
    <cfargument name="new_major" type="numeric" required="true" hint="The new major version.">
    <cfargument name="new_minor" type="numeric" required="true" hint="The new minor version.">
    <cfargument name="new_patch" type="numeric" required="true" hint="The new patch version.">
    <cfargument name="new_versionstatus" type="string" required="true" hint="The new version status.">
    <cfargument name="new_versiontype" type="string" required="true" hint="The new version type.">
    <cfargument name="new_version" type="numeric" required="true" hint="The new version number.">
    <cfargument name="new_build" type="numeric" required="true" hint="The new build number.">
    <cfargument name="new_reviewDate" type="string" required="false" default="" hint="The new review date.">
    <cfargument name="new_releaseDate" type="string" required="false" default="" hint="The new release date.">
    <cfargument name="new_reviewtime" type="string" required="false" default="" hint="The new review time.">
    <cfargument name="new_releasetime" type="string" required="false" default="" hint="The new release time.">
    <cfargument name="new_hoursavail" type="numeric" required="false" default="" hint="The new available hours.">

<!--- Execute the query --->
    <cfquery name="update">
        UPDATE taoversions
        SET 
            major = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.new_major#" />,
            minor = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.new_minor#" />,
            patch = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.new_patch#" />,
            versionstatus = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.new_versionstatus#" />,
            versiontype = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.new_versiontype#" />,
            version = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.new_version#" />,
            build = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.new_build#" />

<!--- Conditionally include optional fields --->
            <cfif arguments.new_reviewDate neq "">
                ,reviewDate = <cfqueryparam cfsqltype="cf_sql_date" value="#arguments.new_reviewDate#" />
            </cfif>
            <cfif arguments.new_releaseDate neq "">
                ,releaseDate = <cfqueryparam cfsqltype="cf_sql_date" value="#arguments.new_releaseDate#" />
            </cfif>
            <cfif arguments.new_reviewtime neq "">
                ,reviewtime = <cfqueryparam cfsqltype="cf_sql_time" value="#arguments.new_reviewtime#" />
            </cfif>
            <cfif arguments.new_releasetime neq "">
                ,releasetime = <cfqueryparam cfsqltype="cf_sql_time" value="#arguments.new_releasetime#" />
            </cfif>
            <cfif arguments.new_hoursavail neq "">
                ,hoursavail = <cfqueryparam cfsqltype="cf_sql_float" value="#numberformat(arguments.new_hoursavail, '9.99')#" />
            </cfif>
        WHERE 
            verid = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.verid#" />
    </cfquery>
</cffunction>

</cfcomponent>