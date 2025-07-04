<cfcomponent displayname="UploadService" hint="Handles operations for Upload table" > 
<cffunction output="false" name="INSuploads" access="public" returntype="numeric">
    <cfargument name="userid" type="numeric" required="true">

<cfquery result="result">
        INSERT INTO uploads (userid) 
        VALUES (<cfqueryparam value="#arguments.userid#" cfsqltype="CF_SQL_INTEGER">)
    </cfquery>
    <cfreturn result.generatedKey>
</cffunction>
<cffunction output="false" name="DETuploads" access="public" returntype="query">
    <cfargument name="uploadid" type="numeric" required="true">

<cfquery name="result">
        SELECT uploadid, `TIMESTAMP`, userid, uploadstatus
        FROM uploads
        WHERE uploadid = <cfqueryparam value="#arguments.uploadid#" cfsqltype="CF_SQL_INTEGER">
    </cfquery>

<cfreturn result>
</cffunction>
</cfcomponent>