<cfcomponent displayname="AttachmentService" hint="Handles operations for Attachment table" >

<cffunction output="false" name="INSattachments" access="public" returntype="numeric">
        <cfargument name="attachname" type="string" required="true">
        <cfargument name="attachfilename" type="string" required="true">
        <cfargument name="noteid" type="numeric" required="true">

<cfquery result="result">
            INSERT INTO attachments (attachname, attachfilename, isdeleted, userid, noteid) 
            VALUES (
                <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.attachname#" />,
                <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.attachfilename#" />,
                <cfqueryparam cfsqltype="cf_sql_integer" value="0" />,
                <cfqueryparam cfsqltype="cf_sql_integer" value="#userid#" />,
                <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.noteid#" />
            )
        </cfquery>
         <cfreturn result.generatedKey>
    </cffunction>

<cffunction output="false" name="DETattachments" access="public" returntype="query">
        <cfargument name="attachid" type="numeric" required="true">

<cfquery name="result">
SELECT a.attachid, a.noteid, a.attachname, a.attachfilename,n.contactid
FROM attachments a
    INNER JOIN noteslog n on n.noteid = a.noteid
WHERE attachid = <cfqueryparam value="#arguments.attachid#" cfsqltype="CF_SQL_INTEGER">
        </cfquery>
<cfreturn result>
    </cffunction>

<cffunction output="false" name="UPDattachments" access="public" returntype="void">
        <cfargument name="attachid" type="numeric" required="true">

<cfquery result="result">
            UPDATE attachments
            SET isdeleted = 1
            WHERE attachid = <cfqueryparam value="#arguments.attachid#" cfsqltype="CF_SQL_INTEGER">
        </cfquery>
    </cffunction>

<cffunction output="false" name="SELattachments" access="public" returntype="query">
        <cfargument name="new_noteid" type="numeric" required="true">

<cfquery name="result">
            SELECT attachid, noteid, attachname, attachfilename, userid
            FROM attachments
            WHERE noteid = <cfqueryparam value="#arguments.new_noteid#" cfsqltype="CF_SQL_INTEGER">
        </cfquery>

<cfreturn result>
    </cffunction>

</cfcomponent>