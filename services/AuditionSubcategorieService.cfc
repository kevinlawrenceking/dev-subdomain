<cfcomponent displayname="AuditionSubcategorieService" hint="Handles operations for AuditionSubcategorie table" > 
<cffunction output="false" name="SELaudsubcategories" access="public" returntype="query">
    <cfargument name="new_audcatid" type="numeric" required="true">
    <cfargument name="audsubcatname" type="string" required="true">

<cfquery name="result">
        SELECT * 
        FROM audsubcategories 
        WHERE audcatid = <cfqueryparam value="#arguments.new_audcatid#" cfsqltype="CF_SQL_INTEGER"> 
        AND audsubcatname = <cfqueryparam value="#arguments.audsubcatname#" cfsqltype="CF_SQL_VARCHAR">
    </cfquery>

<cfreturn result>
</cffunction>
<cffunction output="false" name="INSaudsubcategories" access="public" returntype="numeric">
    <cfargument name="new_audSubCatName" type="string" required="true">
    <cfargument name="new_audCatId" type="numeric" required="true">
    <cfargument name="new_isDeleted" type="boolean" required="true">

<cfquery result="result">
        INSERT INTO audsubcategories (audSubCatName, audCatId, isDeleted)
        VALUES (
            <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.new_audSubCatName#" maxlength="100" null="#NOT len(trim(arguments.new_audSubCatName))#" />,
            <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#arguments.new_audCatId#" null="#NOT len(trim(arguments.new_audCatId))#" />,
            <cfqueryparam cfsqltype="CF_SQL_BIT" value="#arguments.new_isDeleted#" null="#NOT len(trim(arguments.new_isDeleted))#" />
        );
    </cfquery>
    <cfreturn result.generatedKey>
</cffunction>
<cffunction output="false" name="UPDaudsubcategories" access="public" returntype="void">
    <cfargument name="new_audSubCatName" type="string" required="true">
    <cfargument name="new_audCatId" type="numeric" required="true">
    <cfargument name="new_isDeleted" type="boolean" required="true">
    <cfargument name="new_audSubCatId" type="numeric" required="true">

<cfquery result="result">
        UPDATE audsubcategories 
        SET 
            audSubCatName = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#trim(arguments.new_audSubCatName)#" maxlength="100" null="#NOT len(trim(arguments.new_audSubCatName))#">,
            audCatId = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#arguments.new_audCatId#" null="#NOT len(trim(arguments.new_audCatId))#">,
            isDeleted = <cfqueryparam cfsqltype="CF_SQL_BIT" value="#arguments.new_isDeleted#" null="#NOT len(trim(arguments.new_isDeleted))#">
        WHERE 
            audSubCatId = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#arguments.new_audSubCatId#">
    </cfquery>
</cffunction>
</cfcomponent>