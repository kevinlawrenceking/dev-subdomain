<cfcomponent displayname="AuditionSubmitSiteUserService" hint="Handles operations for AuditionSubmitSiteUser table" >

<cffunction name="UPDaudsubmitsites_user_24167" access="public" returntype="void" output="false">

<cfargument name="submitsiteid" type="numeric" required="true">
    <cfargument name="new_submitsitename" type="string" required="true">
    <cfargument name="isdeleted" type="boolean" required="true">
    <cfargument name="catlist" type="string" required="false" default="">

<cfquery>
        UPDATE `audsubmitsites_user`
        SET submitsitename = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.new_submitsitename#">,
            isDeleted = <cfqueryparam cfsqltype="CF_SQL_BIT" value="#arguments.isdeleted#">
        <cfif len(arguments.catlist)>
            ,catlist = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.catlist#">
        <cfelse>
            ,catlist = NULL
        </cfif>
        WHERE submitsiteid = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#arguments.submitsiteid#">
    </cfquery>
</cffunction>

<cffunction output="false" name="SELaudsubmitsites_user" access="public" returntype="query">
    <cfargument name="userid" type="numeric" required="true">

<cfquery name="result">
        SELECT submitsiteid, submitsitename, catlist
        FROM audsubmitsites_user
        WHERE userid = <cfqueryparam value="#arguments.userid#" cfsqltype="CF_SQL_INTEGER">
        AND submitsitename <> ''
        ORDER BY submitsitename
    </cfquery>
    <cfreturn result>
</cffunction>

<cffunction output="false" name="SELaudsubmitsites_user_24034" access="public" returntype="query">
    <cfargument name="userid" type="numeric" required="true">
    <cfargument name="new_submitsitename" type="string" required="true">

<cfquery name="result">
        SELECT submitsiteid 
        FROM audsubmitsites_user 
        WHERE userid = <cfqueryparam value="#arguments.userid#" cfsqltype="CF_SQL_INTEGER"> 
          AND submitsitename = <cfqueryparam value="#arguments.new_submitsitename#" cfsqltype="CF_SQL_VARCHAR">
    </cfquery>
    <cfreturn result>
</cffunction>

<cffunction output="false" name="UPDaudsubmitsites_user" access="public" returntype="void">
    <cfargument name="new_submitsitename" type="string" required="true">
    <cfargument name="sortedCatList" type="string" required="false" default="">
    <cfargument name="submitsiteid" type="numeric" required="true">
    <cfquery result="result">
        UPDATE audsubmitsites_user 
        SET submitsitename = <cfqueryparam value="#arguments.new_submitsitename#" cfsqltype="CF_SQL_VARCHAR">,
            isDeleted = <cfqueryparam value="0" cfsqltype="CF_SQL_BIT">
            <cfif arguments.sortedCatList neq "">,
                catlist = <cfqueryparam value="#arguments.sortedCatList#" cfsqltype="CF_SQL_VARCHAR">
            <cfelse>,
                catlist = NULL
            </cfif>
        WHERE submitsiteid = <cfqueryparam value="#arguments.submitsiteid#" cfsqltype="CF_SQL_INTEGER">
    </cfquery>
</cffunction>

<cffunction output="false" name="INSaudsubmitsites_user" access="public" returntype="numeric">
    <cfargument name="new_submitsitename" type="string" required="true">
    <cfargument name="sortedCatList" type="string" required="true">
    <cfargument name="userid" type="numeric" required="true">
    <cfquery result="result">
        INSERT INTO audsubmitsites_user (submitsitename, catlist, userid)
        VALUES (
            <cfqueryparam value="#arguments.new_submitsitename#" cfsqltype="CF_SQL_VARCHAR">,
            <cfqueryparam value="#arguments.sortedCatList#" cfsqltype="CF_SQL_VARCHAR">,
            <cfqueryparam value="#arguments.userid#" cfsqltype="CF_SQL_INTEGER">
        )
    </cfquery>
    <cfreturn result.generatedKey>
</cffunction>

<cffunction output="false" name="DETaudsubmitsites_user" access="public" returntype="query">
    <cfargument name="submitsiteid" type="numeric" required="true">

<cfquery name="result">
        SELECT submitsiteid, submitsitename, catlist
        FROM audsubmitsites_user
        WHERE submitsiteid = <cfqueryparam value="#arguments.submitsiteid#" cfsqltype="CF_SQL_INTEGER">
    </cfquery>
    <cfreturn result>
</cffunction>

<cffunction output="false" name="SELaudsubmitsites_user_24265" access="public" returntype="query">
    <cfargument name="userid" type="numeric" required="true">
    <cfargument name="new_audcatid" type="string" required="true">

<cfquery name="result">
        SELECT submitsiteid, submitsitename 
        FROM audsubmitsites_user 
        WHERE userid = <cfqueryparam value="#arguments.userid#" cfsqltype="CF_SQL_INTEGER"> 
        AND catlist LIKE <cfqueryparam value="%#arguments.new_audcatid#%" cfsqltype="CF_SQL_VARCHAR"> 
        AND isdeleted = 0 
        ORDER BY submitsitename
    </cfquery>
    <cfreturn result>
</cffunction>

<cffunction output="false" name="SELaudsubmitsites_user_24295" access="public" returntype="query">
    <cfargument name="userid" type="numeric" required="true">
    <cfargument name="new_submitsitename" type="string" required="true">

<cfquery name="result" >
            SELECT 
                submitsiteid AS new_submitsiteid, 
                catlist AS new_catlist 
            FROM 
                audsubmitsites_user 
            WHERE 
                userid = <cfqueryparam value="#arguments.userid#" cfsqltype="CF_SQL_INTEGER"> 
                AND submitsitename = <cfqueryparam value="#trim(arguments.new_submitsitename)#" cfsqltype="CF_SQL_VARCHAR">
        </cfquery>

<cfreturn result>
</cffunction>
<cffunction output="false" name="UPDaudsubmitsites_user_24296" access="public" returntype="void">
    <cfargument name="new_catlist" type="string" required="true">
    <cfargument name="new_submitsiteid" type="numeric" required="true">

<cfquery result="result" >
            UPDATE audsubmitsites_user 
            SET catlist = <cfqueryparam value="#arguments.new_catlist#" cfsqltype="CF_SQL_VARCHAR">
            WHERE submitsiteid = <cfqueryparam value="#arguments.new_submitsiteid#" cfsqltype="CF_SQL_INTEGER">
        </cfquery>

</cffunction>
<cffunction output="false" name="INSaudsubmitsites_user_24297" access="public" returntype="numeric">
    <cfargument name="new_submitsitename" type="string" required="true">
    <cfargument name="userid" type="numeric" required="true">
    <cfargument name="new_catid" type="string" required="true">

<cfquery result="result" >
            INSERT INTO audsubmitsites_user_tbl (submitsiteName, userid, catlist)
            VALUES (
                <cfqueryparam value="#trim(arguments.new_submitsitename)#" cfsqltype="CF_SQL_VARCHAR">,
                <cfqueryparam value="#arguments.userid#" cfsqltype="CF_SQL_INTEGER">,
                <cfqueryparam value="#arguments.new_catid#" cfsqltype="CF_SQL_VARCHAR">
            )
        </cfquery>
 <cfreturn result.generatedKey>
</cffunction>
</cfcomponent>
