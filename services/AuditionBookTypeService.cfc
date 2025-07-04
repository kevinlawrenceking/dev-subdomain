<cfcomponent displayname="AuditionBookTypeService" hint="Handles operations for AuditionBookType table" > 
<cffunction output="false" name="SELaudbooktypes" access="public" returntype="query">
    <cfargument name="audbooktypeid" type="numeric" required="false">

<cfquery name="result">
        SELECT audbooktypeid AS id, audbooktype AS name
        FROM audbooktypes
        WHERE isdeleted = 0
        AND audbooktypeid <> 0
        <cfif structKeyExists(arguments, "audbooktypeid")>
            AND audbooktypeid = <cfqueryparam value="#arguments.audbooktypeid#" cfsqltype="CF_SQL_INTEGER">
        </cfif>
    </cfquery>

<cfreturn result>
</cffunction>
</cfcomponent>