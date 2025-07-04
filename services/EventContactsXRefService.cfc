<cfcomponent displayname="EventContactsXRefService" hint="Handles operations for EventContactsXRef table" >

<cffunction name="eventaudsync" access="public" returntype="void" output="false">
<cfargument name="audprojectid" type="numeric" required="true">
    <cfquery>
        INSERT INTO eventcontactsxref (eventid, contactid)
        SELECT DISTINCT e.eventid, c.contactid
        FROM audprojects p
        INNER JOIN audroles r ON r.audprojectID = p.audprojectID  
        INNER JOIN events a ON a.audroleid = r.audroleid
        INNER JOIN events e ON e.eventid = a.eventid
        INNER JOIN audcontacts_auditions_xref x ON x.audprojectid = p.audprojectID
        INNER JOIN contactdetails c ON c.contactid = x.contactid
        WHERE 
            p.audprojectid = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.audprojectid#"/>
            and a.isDeleted = 0 
            AND r.isdeleted = 0 
            AND p.isdeleted = 0 
            AND c.contactid <> 0
            AND NOT EXISTS (
                SELECT 1 
                FROM eventcontactsxref ecx
                WHERE ecx.eventid = e.eventid AND ecx.contactid = c.contactid
            )
    </cfquery>
</cffunction>


<cffunction output="false" name="INSeventcontactsxref" access="public" returntype="numeric">
    <cfargument name="new_eventid" type="numeric" required="true">
    <cfargument name="new_contactid" type="numeric" required="true">

<cfquery result="result">
        INSERT INTO eventcontactsxref (eventid, contactid)
        VALUES (
            <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.new_eventid#"/>,
            <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.new_contactid#"/>
        )
    </cfquery>
    <cfreturn result.generatedKey>
</cffunction>

<cffunction output="false" name="SELeventcontactsxref" access="public" returntype="query">
    <cfargument name="ContactID" type="numeric" required="true">
    <cfargument name="EventID" type="numeric" required="true">

<cfquery name="result">
        SELECT * 
        FROM eventcontactsxref 
        WHERE contactID = <cfqueryparam value="#arguments.ContactID#" cfsqltype="CF_SQL_INTEGER"> 
        AND eventid = <cfqueryparam value="#arguments.EventID#" cfsqltype="CF_SQL_INTEGER">
    </cfquery>

<cfreturn result>
</cffunction>

<cffunction output="false" name="UPDeventcontactsxref" access="public" returntype="void">
    <cfargument name="eventid" type="numeric" required="true">

<cfquery result="result">
        UPDATE eventcontactsxref 
        SET isdeleted = 1 
        WHERE eventid = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.eventid#" />
    </cfquery>
</cffunction>

<cffunction output="false" name="INSeventcontactsxref_23737" access="public" returntype="numeric">
    <cfargument name="eventid" type="numeric" required="true">
    <cfargument name="new_contactid" type="numeric" required="true">

<cfquery result="result">
        INSERT INTO eventcontactsxref (eventid, contactid)
        VALUES (
            <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.eventid#" />,
            <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.new_contactid#" />
        )
    </cfquery>
    <cfreturn result.generatedKey>
</cffunction>

<cffunction output="false" name="SELeventcontactsxref_23738" access="public" returntype="query">
    <cfargument name="eventId" type="numeric" required="true">

<cfquery name="result">
        SELECT *
        FROM eventcontactsxref
        WHERE eventid = <cfqueryparam value="#arguments.eventId#" cfsqltype="CF_SQL_INTEGER">
    </cfquery>

<cfreturn result>
</cffunction>

<cffunction output="false" name="INSeventcontactsxref_24020" access="public" returntype="numeric">
    <cfargument name="audProjectID" type="numeric" required="true">
    <cfargument name="audStepID" type="numeric" required="true">

<cfquery result="result" name="qryInsertEventContactsXref">
        INSERT INTO eventcontactsxref (eventid, contactid)
        SELECT DISTINCT e.eventid, c.contactid
        FROM audprojects p
        INNER JOIN audcontacts_auditions_xref ax ON ax.audprojectid = p.audprojectid
        INNER JOIN contactdetails c ON c.contactid = ax.contactid
        INNER JOIN audroles r ON r.audprojectID = p.audprojectid
        INNER JOIN events e ON e.audRoleID = r.audroleid
        LEFT JOIN eventcontactsxref ecx ON ecx.eventid = e.eventid AND ecx.contactid = c.contactid
        WHERE p.isdeleted = 0 
          AND c.IsDeleted = 0 
          AND e.isdeleted = 0 
          AND r.isdeleted = 0 
          AND e.audstepid <> <cfqueryparam value="#arguments.audStepID#" cfsqltype="CF_SQL_INTEGER">
          AND ecx.eventid IS NULL;
    </cfquery>
    <cfreturn result.generatedKey>
</cffunction>

<cffunction output="false" name="DELeventcontactsxref" access="public" returntype="void">
    <cfargument name="eventIds" type="array" required="true">

<cfset var local = {}>

<cfif arrayLen(arguments.eventIds) eq 0>
        <!--- Return early if no event IDs are provided --->
        <cfreturn>
    </cfif>

<cfquery result="result" name="deleteQuery">
        DELETE FROM eventcontactsxref 
        WHERE eventid NOT IN (
            SELECT eventid FROM events
        )
        AND eventid NOT IN (
            <cfloop array="#arguments.eventIds#" index="eventId">
                <cfqueryparam value="#eventId#" cfsqltype="CF_SQL_INTEGER" list="true">
            </cfloop>
        )
    </cfquery>
</cffunction>

<cffunction name="deleteEventContactsXref" access="public" returntype="query" output="false">
    <cfargument name="audStepId" type="numeric" required="true">

<cfif NOT isNumeric(arguments.audStepId)>
        <cfthrow message="Invalid input: audStepId must be numeric.">
    </cfif>

<cfset var result = "">

<cfquery name="result">
        DELETE FROM eventcontactsxref
        WHERE eventid IN (
            SELECT eventid 
            FROM events 
            WHERE audstepid = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#arguments.audStepId#">
        )
    </cfquery>

<cfreturn result>
</cffunction>

<cffunction output="false" name="SELeventcontactsxref_24060" access="public" returntype="query">
    <cfargument name="eventNumber" type="numeric" required="true">
    <cfargument name="contactID" type="numeric" required="true">

<cfquery name="result">
        SELECT * 
        FROM eventcontactsxref 
        WHERE eventid = <cfqueryparam value="#arguments.eventNumber#" cfsqltype="cf_sql_integer"> 
          AND contactid = <cfqueryparam value="#arguments.contactID#" cfsqltype="cf_sql_integer">
    </cfquery>

<cfreturn result>
</cffunction>

<cffunction output="false" name="INSeventcontactsxref_24061" access="public" returntype="void">
    <cfargument name="eventNumber" type="numeric" required="true">
    <cfargument name="contactID" type="numeric" required="true">

<cfquery result="result" >
            INSERT IGNORE INTO eventcontactsxref (eventid, contactid)
            VALUES (
                <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.eventNumber#" />,
                <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.contactID#" />
            )
        </cfquery>
</cffunction>
<cffunction output="false" name="SELeventcontactsxref_24489" access="public" returntype="query">
    <cfargument name="eventid" type="numeric" required="true">

<cfquery name="result" >
            SELECT *
            FROM eventcontactsxref
            WHERE eventid = <cfqueryparam value="#arguments.eventid#" cfsqltype="CF_SQL_INTEGER" />
        </cfquery>

<cfreturn result>
</cffunction>
<cffunction output="false" name="SELeventcontactsxref_24499" access="public" returntype="struct">
    <cfargument name="eventid" type="numeric" required="true">

<cfquery name="result">
        SELECT * FROM eventcontactsxref
        WHERE eventid = <cfqueryparam value="#arguments.eventid#" cfsqltype="CF_SQL_INTEGER">
    </cfquery>

<cfset var returnStruct = structNew()>
    <cfset returnStruct.query = result>
    <cfset returnStruct.recordCount = result.recordCount>

<cfreturn returnStruct>
</cffunction>
<cffunction output="false" name="INSeventcontactsxref_24532" access="public" returntype="numeric">
    <cfargument name="new_eventid" type="numeric" required="true">
    <cfargument name="new_contactid" type="numeric" required="true">

<cfquery result="result">
            INSERT INTO eventcontactsxref (eventid, contactid)
            VALUES (
                <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.new_eventid#" />,
                <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.new_contactid#" />
            )
        </cfquery>

</cffunction>
<cffunction output="false" name="UPDeventcontactsxref_24549" access="public" returntype="void">
    <cfargument name="deletecontactid" type="numeric" required="true">
    <cfargument name="audprojectid" type="numeric" required="true">

<cfquery result="result" >
            UPDATE eventcontactsxref_tbl x
            INNER JOIN events e ON x.eventid = e.eventid
            INNER JOIN audroles r ON r.audRoleID = e.audroleid
            INNER JOIN audprojects p ON r.audprojectid = p.audprojectid
            SET x.isdeleted = 1
            WHERE x.contactid = <cfqueryparam value="#arguments.deletecontactid#" cfsqltype="cf_sql_integer">
            AND p.audprojectid = <cfqueryparam value="#arguments.audprojectid#" cfsqltype="cf_sql_integer">
        </cfquery>

</cffunction>
</cfcomponent>
