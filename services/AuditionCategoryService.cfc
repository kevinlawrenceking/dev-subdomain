<cfcomponent displayname="AuditionCategoryService" hint="Handles operations for AuditionCategory table" output="false">

<cffunction name="SELaudcategories" access="public" returntype="query">
    <cfargument name="new_audsubcatid" type="numeric" required="true">

<cfset var queryResult = "" />
   <cfquery name="queryResult">
        SELECT 
            c.audcatid, 
            c.audcatname, 
            s.audsubcatid, 
            s.audsubcatname 
        FROM 
            audcategories c 
        INNER JOIN 
            audsubcategories s ON s.audcatid = c.audcatid 
        WHERE 
            s.audsubcatid = <cfqueryparam value="#arguments.new_audsubcatid#" cfsqltype="CF_SQL_INTEGER">
    </cfquery>

<cfreturn queryResult>  
</cffunction>

<cffunction name="SELaudcategories_23908" access="public" returntype="query">
    <cfargument name="audcatid" type="numeric" required="false">

<cfset var result = "">
    <cfset var sql = "SELECT s.audsubcatid AS ID, CONCAT(c.audcatname, ' - ', s.audsubcatname) AS NAME FROM audcategories c INNER JOIN audsubcategories s ON s.audcatid = c.audcatid">
    <cfset var whereClause = "">
    <cfset var params = []>

<cfif structKeyExists(arguments, "audcatid")>
        <cfset whereClause = " WHERE s.audcatid = ?">
        <cfset arrayAppend(params, {value=arguments.audcatid, cfsqltype="CF_SQL_INTEGER"})>
    </cfif>

<!--- Complete SQL query with ORDER BY clause --->
    <cfset sql = sql & whereClause & " ORDER BY c.audcatname, s.audsubcatname">

<!--- Execute the query with error handling --->
    <cfquery  result="result">
        #sql#
        <cfloop array="#params#" index="param">
            <cfqueryparam value="#param.value#" cfsqltype="#param.cfsqltype#">
        </cfloop>
    </cfquery>

<cfreturn result>
</cffunction>

<cffunction name="SELaudcategories_24033" access="public" returntype="query" output="false">

<cfquery name="categories" result="result">
        SELECT audcatid, audcatname
        FROM audcategories
        WHERE isdeleted = 0
        ORDER BY audcatname
    </cfquery>
    <cfreturn categories>

</cffunction>

<cffunction name="SELaudcategories_24357" access="public" returntype="query">
    <cfargument name="audcatname" type="string" required="true">

<cfset var result = "">

<cfquery  result="result">
        SELECT audcatid 
        FROM audcategories 
        WHERE audcatname = <cfqueryparam value="#arguments.audcatname#" cfsqltype="CF_SQL_VARCHAR">
    </cfquery>

<cfreturn result>
</cffunction>

<cffunction name="SELaudcategories_24367" access="public" returntype="query">
    <cfargument name="audcatname" type="string" required="true">

<cfquery   result="result">
        SELECT s.audsubcatid 
        FROM audcategories c 
        INNER JOIN audsubcategories s ON s.audcatid = c.audcatid 
        WHERE c.isdeleted = 0 
        AND s.isdeleted = 0 
        AND CONCAT(c.audcatname, "-", s.audSubCatName) = <cfqueryparam value="#arguments.audcatname#" cfsqltype="CF_SQL_VARCHAR">
    </cfquery>

<cfreturn result>
</cffunction>

<cffunction name="SELaudcategories_24368" access="public" returntype="query">
    <cfargument name="audcatname" type="string" required="true">

<cfset var result = "">

<cfquery name="result" result="result">
        SELECT audCatId,audCatName,isDeleted,recordname
        FROM audcategories
        WHERE audcatname = <cfqueryparam value="#arguments.audcatname#" cfsqltype="CF_SQL_VARCHAR">
        AND isdeleted = <cfqueryparam value="0" cfsqltype="CF_SQL_BIT">
    </cfquery>

<cfreturn result>
</cffunction>

<cffunction name="SELaudcategories_24375" access="public" returntype="query">
    <cfargument name="audsubcatid" type="numeric" required="true">

<cfset var result = "">

<cfquery name="result" result="result">
        SELECT 
            ac.audcatname AS category, 
            aisc.audsubcatname AS subcategory 
        FROM 
            audcategories ac 
        INNER JOIN 
            audsubcategories aisc 
        ON 
            ac.audcatid = aisc.audcatid 
        WHERE 
            aisc.audsubcatid = <cfqueryparam value="#arguments.audsubcatid#" cfsqltype="CF_SQL_INTEGER">
    </cfquery>

<cfreturn result>
</cffunction>

<cffunction name="SELaudcategories_24389" access="public" returntype="query">
    <cfargument name="audcatname" type="string" required="true">
    <cfargument name="audsubcatname" type="string" required="true">

<cfset var result = "">

<cfquery name="result" result="result">
        SELECT s.audsubcatid AS new_audsubcatid
        FROM audcategories c
        INNER JOIN audsubcategories s ON s.audcatid = c.audcatid
        WHERE c.audcatname = <cfqueryparam value="#arguments.audcatname#" cfsqltype="CF_SQL_VARCHAR">
        AND s.audsubcatname = <cfqueryparam value="#arguments.audsubcatname#" cfsqltype="CF_SQL_VARCHAR">
    </cfquery>

<cfreturn result>
</cffunction>

<cffunction name="INSaudcategories" access="public" returntype="void">
    <cfargument name="new_audCatName" type="string" required="true">
    <cfargument name="new_isDeleted" type="boolean" required="true">

<cfquery   result="result">
            INSERT INTO audcategories (audCatName, isDeleted)
            VALUES (
                <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.new_audCatName#" maxlength="100" null="#NOT len(trim(arguments.new_audCatName))#">,
                <cfqueryparam cfsqltype="CF_SQL_BIT" value="#arguments.new_isDeleted#" null="#NOT len(trim(arguments.new_isDeleted))#">
            )
        </cfquery>
         <cfreturn result.generatedKey>
</cffunction>
<cffunction name="UPDaudcategories" access="public" returntype="void">
    <cfargument name="new_audCatName" type="string" required="true">
    <cfargument name="new_isDeleted" type="boolean" required="true">
    <cfargument name="new_audCatId" type="numeric" required="true">

<cfquery  >
            UPDATE audcategories
            SET 
                audCatName = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.new_audCatName#" maxlength="100" null="#NOT len(trim(arguments.new_audCatName))#">,
                isDeleted = <cfqueryparam cfsqltype="CF_SQL_BIT" value="#arguments.new_isDeleted#" null="#NOT len(trim(arguments.new_isDeleted))#">
            WHERE 
                audCatId = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#arguments.new_audCatId#">
        </cfquery>

</cffunction>
<cffunction name="SELaudcategories_24735" access="public" returntype="query">
    <cfargument name="isDeleted" type="boolean" required="false" default=false>

<cfset var result = "" />

<cfquery name="result"  >
            SELECT audcatid, audcatname
            FROM audcategories
            WHERE isdeleted = <cfqueryparam value="#arguments.isDeleted#" cfsqltype="CF_SQL_BIT">
            ORDER BY audcatname
        </cfquery>

<cfreturn result>
</cffunction>
<cffunction name="SELaudcategories_24744" access="public" returntype="query">
    <cfargument name="isDeleted" type="boolean" required="true">

<cfset var result = "">

<cfquery name="result"  >
            SELECT a.audcatid, a.audcatname
            FROM audcategories a
            WHERE a.isDeleted = <cfqueryparam value="#arguments.isDeleted#" cfsqltype="CF_SQL_BIT">
            ORDER BY a.audcatname
        </cfquery>

<cfreturn result>
</cffunction></cfcomponent>
