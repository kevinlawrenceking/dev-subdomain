<cfcomponent displayname="AuditionTypeService" hint="Handles operations for AuditionType table" > 
<cffunction output="false" name="SELaudtypes" access="public" returntype="query">
    <cfargument name="audcatid" type="string" required="true">

<cfquery name="result">
            SELECT 
                audtypeid AS id, 
                audtype AS name, 
                audcategories 
            FROM 
                audtypes 
            WHERE 
                isdeleted = 0 
                AND audcategories LIKE <cfqueryparam value="%#arguments.audcatid#%" cfsqltype="CF_SQL_VARCHAR">
            ORDER BY 
                audtype
        </cfquery>
    <cfreturn result>
</cffunction>

<cffunction output="false" name="SELaudtypes_23793" access="public" returntype="query">
    <cfargument name="userid" type="numeric" required="true">

<cfquery name="result">
            SELECT DISTINCT audtype AS id, audtype AS name
            FROM audtypes
            WHERE audtype IN (
                SELECT t.audtype
                FROM events a
                INNER JOIN audtypes t ON t.audtypeid = a.audtypeid
                WHERE a.userid = <cfqueryparam value="#arguments.userid#" cfsqltype="CF_SQL_INTEGER">
                AND a.isdeleted IS FALSE
            )
            ORDER BY audtype
        </cfquery>
    <cfreturn result>
</cffunction>

<cffunction output="false" name="SELaudtypes_24082" access="public" returntype="query">
    <cfargument name="new_audcatid" type="numeric" required="true">

<cfquery name="result">
            SELECT 
                audtypeid AS id, 
                audtype AS name, 
                audcatid 
            FROM 
                audtypes 
            WHERE 
                isdeleted = 0 
                AND audcatid = <cfqueryparam value="#arguments.new_audcatid#" cfsqltype="CF_SQL_INTEGER"> 
            ORDER BY 
                audtype
        </cfquery>
    <cfreturn result>
</cffunction>

<cffunction name="getAudtypes" access="public" returntype="query" output="false">
    <cfargument name="new_audcatid" type="string" required="false">

<cfquery name="queryResult">
        SELECT 
            audtypeid AS id, 
            audtype AS name, 
            audcategories 
        FROM 
            audtypes 
        WHERE 
            isdeleted = 0
        <cfif len(trim(arguments.new_audcatid))>
            AND audcategories LIKE <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="%%#arguments.new_audcatid#%%">
        </cfif>
    </cfquery>

<cfreturn queryResult>
</cffunction>

<cffunction output="false" name="SELaudtypes_24231" access="public" returntype="query">
    <cfargument name="audstepIds" type="array" required="true">

<cfquery name="result">
            SELECT 
                audstepid, 
                4 AS new_reportid, 
                audtypeid AS NEW_audtypeid, 
                audtype, 
                audtype AS new_label, 
                audstep AS new_itemDataset
            FROM 
                audtypes, audsteps
            WHERE 
                audstepid IN (
                    <cfloop index="i" from="1" to="#arrayLen(arguments.audstepIds)#">
                        <cfqueryparam value="#arguments.audstepIds[i]#" cfsqltype="CF_SQL_INTEGER">
                        <cfif i LT arrayLen(arguments.audstepIds)>,</cfif>
                    </cfloop>
                )
            ORDER BY 
                audtypes.audtype, audsteps.audstep
        </cfquery>
    <cfreturn result>
</cffunction>

<cffunction output="false" name="SELaudtypes_24234" access="public" returntype="query">
    <cfargument name="audstepid" type="numeric" required="true">
    <cfargument name="new_audtypeid" type="numeric" required="true">
    <cfargument name="rangestart" type="date" required="true">
    <cfargument name="rangeend" type="date" required="true">
    <cfargument name="userid" type="numeric" required="true">

<cfquery name="result">
            SELECT count(r.audroleid) as totals
            FROM audtypes t
            LEFT JOIN events a ON a.audtypeid = t.audtypeid
            LEFT JOIN audroles r ON a.audroleid = r.audroleid
            LEFT JOIN audprojects p ON p.audprojectid = r.audprojectid
            LEFT JOIN audsteps st ON st.audstepid = a.audstepid
            WHERE a.isDeleted = 0 
            AND p.isdeleted = 0 
            AND a.audstepid = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#arguments.audstepid#" />
            AND t.audtypeid = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#arguments.new_audtypeid#" />
            AND p.projdate >= <cfqueryparam cfsqltype="CF_SQL_DATE" value="#arguments.rangestart#" />
            AND p.projdate <= <cfqueryparam cfsqltype="CF_SQL_DATE" value="#arguments.rangeend#" />
            AND p.userid = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#arguments.userid#" />
        </cfquery>
    <cfreturn result>
</cffunction>

<cffunction output="false" name="SELaudtypes_24526" access="public" returntype="query">
    <cfargument name="new_audtypeid" type="numeric" required="true">

<cfquery name="result">
            SELECT audtype 
            FROM audtypes 
            WHERE audtypeid = <cfqueryparam value="#arguments.new_audtypeid#" cfsqltype="CF_SQL_INTEGER">
        </cfquery>
    <cfreturn result>
</cffunction>

<cffunction output="false" name="INSaudtypes" access="public" returntype="numeric">
    <cfargument name="new_audtype" type="string" required="true">
    <cfargument name="new_audCatid" type="numeric" required="true">
    <cfargument name="new_isDeleted" type="boolean" required="true">

<cfquery result="result" >
            INSERT INTO audtypes (audtype, audCatid, isDeleted)
            VALUES (
                <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.new_audtype#" maxlength="100" null="#NOT len(trim(arguments.new_audtype))#">,
                <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#arguments.new_audCatid#" null="#NOT len(trim(arguments.new_audCatid))#">,
                <cfqueryparam cfsqltype="CF_SQL_BIT" value="#arguments.new_isDeleted#" null="#NOT len(trim(arguments.new_isDeleted))#">
            )
        </cfquery>
<cfreturn result.generatedKey>
</cffunction>
<cffunction output="false" name="SELaudtypes_24608" access="public" returntype="query">
    <cfargument name="isDeleted" type="boolean" required="true">

<cfquery name="result" >
            SELECT 
                audtypeid AS id, 
                audtype AS name, 
                audcategories 
            FROM 
                audtypes 
            WHERE 
                isdeleted = <cfqueryparam value="#arguments.isDeleted#" cfsqltype="CF_SQL_BIT">
            ORDER BY 
                audtype
        </cfquery>

<cfreturn result>
</cffunction>
<cffunction output="false" name="UPDaudtypes" access="public" returntype="void">
    <cfargument name="new_audtype" type="string" required="true">
    <cfargument name="new_audCatid" type="numeric" required="true">
    <cfargument name="new_isDeleted" type="boolean" required="true">
    <cfargument name="new_audtypeid" type="numeric" required="true">

<cfquery result="result" >
            UPDATE audtypes 
            SET 
                audtype = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#trim(arguments.new_audtype)#" maxlength="100" null="#NOT len(trim(arguments.new_audtype))#">,
                audCatid = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#arguments.new_audCatid#" null="#NOT len(trim(arguments.new_audCatid))#">,
                isDeleted = <cfqueryparam cfsqltype="CF_SQL_BIT" value="#arguments.new_isDeleted#" null="#NOT len(trim(arguments.new_isDeleted))#">
            WHERE 
                audtypeid = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#arguments.new_audtypeid#">
        </cfquery>

</cffunction>
</cfcomponent>
