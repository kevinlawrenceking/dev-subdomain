<cfcomponent displayname="ContactAuditionService" hint="Handles operations for ContactAudition table" > 
<cffunction output="false" name="INSaudcontacts_auditions_xref" access="public" returntype="numeric">
    <cfargument name="contactId" type="numeric" required="true">
    <cfargument name="audStepId" type="numeric" required="true">

<cfset var queryResult = "">

<cfquery result="result" name="queryResult">
        INSERT INTO audcontacts_auditions_xref (contactid, audprojectid, xrefnotes)
        SELECT DISTINCT x.contactid, r.audprojectid, 'Was missing - audition_check.cfm' AS xrefnotes
        FROM eventcontactsxref x
        INNER JOIN events e ON x.eventid = e.eventid
        INNER JOIN audroles r ON r.audRoleID = e.audroleid
        LEFT JOIN audcontacts_auditions_xref ax ON x.contactid = ax.contactid AND r.audprojectid = ax.audprojectid
        WHERE ax.contactid IS NULL 
        AND x.contactid = <cfqueryparam value="#arguments.contactId#" cfsqltype="CF_SQL_INTEGER">
        AND e.audstepid <> <cfqueryparam value="#arguments.audStepId#" cfsqltype="CF_SQL_INTEGER">
    </cfquery>

<!--- Return the total number of records inserted --->
    <cfreturn result.recordCount>
</cffunction>

<cffunction output="false" name="INSaudcontacts_auditions_xref_2" access="public" returntype="numeric">
    <cfargument name="audprojectid" type="numeric" required="true">
    <cfargument name="autocomplete_aud" type="string" required="true">
    <cfargument name="userid" type="numeric" required="true">

<!--- Initialize new_contactid --->
    <cfset var new_contactid = 0>

<!--- Query to fetch contactid --->
    <cfquery name="contactQuery">
        SELECT contactid 
        FROM contacts_ss 
        WHERE userid = <cfqueryparam value="#arguments.userid#" cfsqltype="CF_SQL_INTEGER">
        AND col1 = <cfqueryparam value="#arguments.autocomplete_aud#" cfsqltype="CF_SQL_VARCHAR">
    </cfquery>

<!--- If a contactid is found, proceed with the insert --->
    <cfif contactQuery.recordCount EQ 1>
        <cfset new_contactid = contactQuery.contactid>

<cfquery>
            INSERT IGNORE INTO audcontacts_auditions_xref 
            SET audprojectid = <cfqueryparam value="#arguments.audprojectid#" cfsqltype="CF_SQL_INTEGER">, 
                xrefNotes = <cfqueryparam value="/qry/audition.cfm" cfsqltype="CF_SQL_VARCHAR">, 
                contactid = <cfqueryparam value="#new_contactid#" cfsqltype="CF_SQL_INTEGER">
        </cfquery>
    </cfif>

<!--- Return new_contactid --->
    <cfreturn new_contactid>
</cffunction>

<cffunction output="false" name="INSaudcontacts_auditions_xref_23780" access="public" returntype="void">
    <cfargument name="audprojectid" type="numeric" required="true">
    <cfargument name="new_contactid" type="numeric" required="true">

<cfquery result="result">
        INSERT IGNORE INTO audcontacts_auditions_xref 
        SET audprojectid = <cfqueryparam value="#arguments.audprojectid#" cfsqltype="CF_SQL_INTEGER">, 
            xrefNotes = <cfqueryparam value="audition-add2.cfm" cfsqltype="CF_SQL_VARCHAR">, 
            contactid = <cfqueryparam value="#arguments.new_contactid#" cfsqltype="CF_SQL_INTEGER">
    </cfquery>

</cffunction>

<cffunction name="getAuditionContacts" access="public" returntype="query" output="false">
    <cfargument name="audprojectid" type="numeric" required="true">
    <cfargument name="new_contactid" type="numeric" required="true">

<cfquery name="result">
        SELECT *
        FROM audcontacts_auditions_xref
        WHERE audprojectid = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#arguments.audprojectid#">
        AND contactid = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#arguments.new_contactid#">
    </cfquery>

<cfreturn result>
</cffunction>

<cffunction output="false" name="DELaudcontacts_auditions_xref" access="public" returntype="void" hint="Deletes a contact from the audcontacts_auditions_xref table based on project and contact IDs.">
    <cfargument name="audprojectid" type="numeric" required="true" hint="The ID of the project." />
    <cfargument name="old_contactid" type="string" required="true" default="0" hint="The ID of the contact to be deleted." />

    <!--- If old_contactid is null, set it to 0 --->
    <cfif NOT isNumeric(arguments.old_contactid)>
        <cfset arguments.old_contactid = 0>
    </cfif>

    <cfquery result="result">
        DELETE FROM audcontacts_auditions_xref
        WHERE audprojectid = <cfqueryparam value="#arguments.audprojectid#" cfsqltype="CF_SQL_INTEGER">
        AND contactid = <cfqueryparam value="#arguments.old_contactid#" cfsqltype="CF_SQL_INTEGER">
    </cfquery>
</cffunction>


<cffunction output="false" name="INSaudcontacts_auditions_xref_24059" access="public" returntype="void">
    <cfargument name="audprojectid" type="numeric" required="true">
    <cfargument name="contactid" type="numeric" required="true">

<cfquery result="result" name="qryInsert">
        INSERT IGNORE INTO audcontacts_auditions_xref 
        SET 
            audprojectid = <cfqueryparam value="#arguments.audprojectid#" cfsqltype="CF_SQL_INTEGER">, 
            contactid = <cfqueryparam value="#arguments.contactid#" cfsqltype="CF_SQL_INTEGER">
    </cfquery>
</cffunction>

<cffunction output="false" name="DELaudcontacts_auditions_xref_24127" access="public" returntype="void">
    <cfargument name="audprojectid" type="numeric" required="true">

<cfquery result="result">
        DELETE FROM audcontacts_auditions_xref 
        WHERE audprojectid = <cfqueryparam value="#arguments.audprojectid#" cfsqltype="CF_SQL_INTEGER">
    </cfquery>
</cffunction>

<cffunction output="false" name="INSaudcontacts_auditions_xref_24512" access="public" returntype="numeric">
    <cfargument name="new_contactid" type="numeric" required="true">
    <cfargument name="new_audprojectid" type="numeric" required="true">

<!--- Insert query --->
    <cfquery result="result">
        INSERT INTO audcontacts_auditions_xref (contactid, audprojectid)
        VALUES (
            <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#arguments.new_contactid#">,
            <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#arguments.new_audprojectid#">
        )
    </cfquery>

<!--- Return the generated key --->
    <cfreturn result.generatedKey>
</cffunction>

<cffunction output="false" name="UPDaudcontacts_auditions_xref" access="public" returntype="void">
    <cfargument name="new_contactid" type="numeric" required="true">
    <cfargument name="new_audprojectid" type="numeric" required="true">

<cfquery result="result">
        UPDATE audcontacts_auditions_xref 
        SET 
            contactid = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#arguments.new_contactid#">, 
            audprojectid = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#arguments.new_audprojectid#"> 
        WHERE 
            audprojectid = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="0">
    </cfquery>
</cffunction>

<cffunction output="false" name="DELaudcontacts_auditions_xref_24545" access="public" returntype="numeric">
    <cfargument name="audprojectid" type="numeric" required="true">

    <cfquery result="result">
        DELETE FROM audcontacts_auditions_xref 
        WHERE audprojectid = <cfqueryparam value="#arguments.audprojectid#" cfsqltype="CF_SQL_INTEGER"> 
        AND xrefNotes = <cfqueryparam value="Referral" cfsqltype="CF_SQL_VARCHAR">
    </cfquery>

    <cfreturn result.recordcount>
</cffunction>


<cffunction output="false" name="DELaudcontacts_auditions_xref_24548" access="public" returntype="void">
    <cfargument name="audprojectid" type="numeric" required="true">
    <cfargument name="deletecontactid" type="numeric" required="true">

<cfquery result="result" >
            DELETE FROM audcontacts_auditions_xref 
            WHERE audprojectid = <cfqueryparam value="#arguments.audprojectid#" cfsqltype="cf_sql_integer"> 
            AND contactid = <cfqueryparam value="#arguments.deletecontactid#" cfsqltype="cf_sql_integer">
        </cfquery>

</cffunction>
<cffunction output="false" name="INSaudcontacts_auditions_xref_24551" access="public" returntype="void">
    <cfargument name="audprojectid" type="numeric" required="true">
    <cfargument name="contactid" type="numeric" required="true">

<cfquery result="result" >
            INSERT IGNORE INTO audcontacts_auditions_xref 
            SET audprojectid = <cfqueryparam value="#arguments.audprojectid#" cfsqltype="cf_sql_integer">, 
                contactid = <cfqueryparam value="#arguments.contactid#" cfsqltype="cf_sql_integer">
        </cfquery>

</cffunction>
</cfcomponent>
