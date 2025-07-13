<cfcomponent displayname="AuditionGenreService" hint="Handles operations for AuditionGenre table">
    <!--- 
        Standardized CRUD operations for AuditionGenre
        Created: July 12, 2025
    --->
    
    <!--- Create: Add a new genre --->
    <cffunction name="create" output="false" access="public" returntype="numeric" 
              hint="Creates a new audition genre record">
        <cfargument name="audgenre" type="string" required="true" hint="The genre name">
        <cfargument name="audCatid" type="numeric" required="true" hint="Category ID">
        <cfargument name="isDeleted" type="boolean" required="false" default="false" hint="Deletion flag">
        
        <cfquery result="result">
            INSERT INTO audgenres (
                audgenre,
                audCatid,
                isDeleted
            ) VALUES (
                <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#trim(arguments.audgenre)#" maxlength="100" null="#NOT len(trim(arguments.audgenre))#">,
                <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#arguments.audCatid#" null="#NOT arguments.audCatid#">,
                <cfqueryparam cfsqltype="CF_SQL_BIT" value="#arguments.isDeleted#">
            )
        </cfquery>
        
        <cfreturn result.generatedKey>
    </cffunction>
    
    <!--- Read: Get a single genre by ID --->
    <cffunction name="read" output="false" access="public" returntype="query" 
              hint="Retrieves a specific audition genre by ID">
        <cfargument name="audgenreid" type="numeric" required="true" hint="The genre ID to retrieve">
        
        <cfquery name="qRead">
            SELECT 
                ag.audgenreid,
                ag.audgenre,
                ag.audCatid,
                ag.isDeleted,
                ac.audcategory AS categoryName
            FROM 
                audgenres ag
            LEFT JOIN 
                audcategories ac ON ag.audCatid = ac.audcatid
            WHERE 
                ag.audgenreid = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#arguments.audgenreid#">
        </cfquery>
        
        <cfreturn qRead>
    </cffunction>
    
    <!--- Update: Modify an existing genre --->
    <cffunction name="update" output="false" access="public" returntype="void" 
              hint="Updates an existing audition genre record">
        <cfargument name="audgenreid" type="numeric" required="true" hint="ID of the genre to update">
        <cfargument name="audgenre" type="string" required="true" hint="The genre name">
        <cfargument name="audCatid" type="numeric" required="true" hint="Category ID">
        <cfargument name="isDeleted" type="boolean" required="false" default="false" hint="Deletion flag">
        
        <cfquery>
            UPDATE audgenres 
            SET 
                audgenre = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#trim(arguments.audgenre)#" maxlength="100" null="#NOT len(trim(arguments.audgenre))#">, 
                audCatid = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#arguments.audCatid#" null="#NOT arguments.audCatid#">, 
                isDeleted = <cfqueryparam cfsqltype="CF_SQL_BIT" value="#arguments.isDeleted#"> 
            WHERE 
                audgenreid = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#arguments.audgenreid#">
        </cfquery>
    </cffunction>
    
    <!--- Delete: Soft delete a genre --->
    <cffunction name="delete" output="false" access="public" returntype="void" 
              hint="Soft deletes an audition genre by setting isDeleted flag">
        <cfargument name="audgenreid" type="numeric" required="true" hint="ID of the genre to delete">
        
        <cfquery>
            UPDATE audgenres 
            SET isDeleted = <cfqueryparam cfsqltype="CF_SQL_BIT" value="true">
            WHERE audgenreid = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#arguments.audgenreid#">
        </cfquery>
    </cffunction>
    
    <!--- List: Get filtered list of genres --->
    <cffunction name="list" output="false" access="public" returntype="query" 
              hint="Retrieves a filtered list of audition genres">
        <cfargument name="audCatid" type="numeric" required="false" default="0" hint="Category ID filter (0 for all)">
        <cfargument name="includeDeleted" type="boolean" required="false" default="false" hint="Include deleted records">
        <cfargument name="sortBy" type="string" required="false" default="audgenre" hint="Sort field">
        <cfargument name="sortDir" type="string" required="false" default="ASC" hint="Sort direction">
        
        <cfquery name="qList">
            SELECT 
                ag.audgenreid,
                ag.audgenre,
                ag.audCatid,
                ag.isDeleted,
                ac.audcategory AS categoryName
            FROM 
                audgenres ag
            LEFT JOIN 
                audcategories ac ON ag.audCatid = ac.audcatid
            WHERE 
                1=1
                <cfif arguments.audCatid GT 0>
                    AND ag.audCatid = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#arguments.audCatid#">
                </cfif>
                <cfif NOT arguments.includeDeleted>
                    AND ag.isDeleted = <cfqueryparam cfsqltype="CF_SQL_BIT" value="false">
                </cfif>
            ORDER BY 
                #arguments.sortBy# #arguments.sortDir#
        </cfquery>
        
        <cfreturn qList>
    </cffunction>
    
    <!--- 
        Legacy function mappings for backward compatibility
        These should be updated in calling code and removed in future versions
    --->
    <cffunction name="INSaudgenres" output="false" access="public" returntype="numeric">
        <cfargument name="new_audgenre" type="string" required="true">
        <cfargument name="new_audCatid" type="numeric" required="true">
        <cfargument name="new_isDeleted" type="boolean" required="true">
        
        <cfreturn create(
            audgenre = arguments.new_audgenre,
            audCatid = arguments.new_audCatid,
            isDeleted = arguments.new_isDeleted
        )>
    </cffunction>
    
    <cffunction name="UPDaudgenres" output="false" access="public" returntype="void">
        <cfargument name="new_audgenre" type="string" required="true">
        <cfargument name="new_audCatid" type="numeric" required="true">
        <cfargument name="new_isDeleted" type="boolean" required="true">
        <cfargument name="new_audgenreid" type="numeric" required="true">
        
        <cfset update(
            audgenreid = arguments.new_audgenreid,
            audgenre = arguments.new_audgenre,
            audCatid = arguments.new_audCatid,
            isDeleted = arguments.new_isDeleted
        )>
    </cffunction>
</cfcomponent>
