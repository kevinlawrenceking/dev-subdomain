<cfcomponent displayname="NoteService" hint="Handles operations for Note table" > 
<cffunction output="false" name="INSnoteslog" access="public" returntype="numeric">
    <cfargument name="userid" type="numeric" required="true">
    <cfargument name="newcontactid" type="numeric" required="true">
    <cfargument name="newnoteDetails" type="string" required="true">

<cfquery result="result" >
            INSERT INTO noteslog (userid, contactid, noteDetails) 
            VALUES (
                <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.userid#" />, 
                <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.newcontactid#" />, 
                <cfqueryparam cfsqltype="cf_sql_longvarchar" value="#LEFT(trim(arguments.newnoteDetails), 2000)#" />
            )
        </cfquery>
<cfreturn result.generatedKey>
</cffunction>
<cffunction output="false" name="DELnoteslog" access="public" returntype="void" hint="Deletes a note by its ID">
    <cfargument name="noteid" type="numeric" required="true" hint="ID of the note to delete">

<cfquery result="result" >
            DELETE FROM noteslog 
            WHERE noteid = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.noteid#" />
        </cfquery>

</cffunction>
<cffunction output="false" name="DELnoteslog_23709" access="public" returntype="void">
    <cfargument name="noteId" type="numeric" required="true">

<cfquery result="result" >
            DELETE FROM noteslog 
            WHERE noteid = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.noteId#" />
        </cfquery>

</cffunction>
<cffunction output="false" name="INSnoteslog_23730" access="public" returntype="numeric">
    <cfargument name="userid" type="numeric" required="true">
    <cfargument name="new_eventid" type="numeric" required="true">
    <cfargument name="noteDetails" type="string" required="true">

<cfquery result="result" >
            INSERT INTO noteslog (userid, contactid, eventid, noteDetails, ispublic)
            VALUES (
                <cfqueryparam value="#arguments.userid#" cfsqltype="CF_SQL_INTEGER">,
                <cfqueryparam value="0" cfsqltype="CF_SQL_INTEGER">,
                <cfqueryparam value="#arguments.new_eventid#" cfsqltype="CF_SQL_INTEGER">,
                <cfqueryparam value="#trim(arguments.noteDetails)#" cfsqltype="CF_SQL_VARCHAR">,
                <cfqueryparam value="1" cfsqltype="CF_SQL_BIT">
            )
        </cfquery>
       <cfreturn result.generatedKey>
</cffunction>
<cffunction output="false" name="SELnoteslog" access="public" returntype="query">
    <cfargument name="noteid" type="numeric" required="true">

<cfquery name="result" >
            SELECT noteID,noteDetails,notedetailshtml,userid,notetimestamp,contactid,isdeleted,eventid,ispublic,audprojectid
            FROM noteslog 
            WHERE noteid = <cfqueryparam value="#arguments.noteid#" cfsqltype="CF_SQL_INTEGER">
        </cfquery>

<cfreturn result>
</cffunction>
<cffunction output="false" name="UPDnoteslog" access="public" returntype="void">
    <cfargument name="recid" type="numeric" required="true">

<cfquery result="result" >
            UPDATE noteslog_tbl 
            SET isdeleted = 1 
            WHERE noteid = <cfqueryparam value="#arguments.recid#" cfsqltype="CF_SQL_INTEGER">
        </cfquery>

</cffunction>
<cffunction output="false" name="INSnoteslog_23966" access="public" returntype="numeric" >
    <cfargument name="userid" type="numeric" required="true">
    <cfargument name="contactid" type="numeric" required="true">
    <cfargument name="noteDetails" type="string" required="true">
    <cfargument name="isPublic" type="boolean" required="true">
    <cfargument name="audprojectid" type="numeric" required="true">
    <cfargument name="notedetailshtml" type="string" required="true">

<cfquery result="result" >
            INSERT INTO noteslog (userid, contactid, noteDetails, isPublic, audprojectid, notedetailshtml)
            VALUES (
                <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.userid#" />,
                <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.contactid#" />,
                <cfqueryparam cfsqltype="cf_sql_longvarchar" value="#LEFT(trim(arguments.noteDetails),2000)#" />,
                <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.isPublic#" />,
                <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.audprojectid#" />,
                <cfqueryparam cfsqltype="cf_sql_longvarchar" value="#arguments.notedetailshtml#" />
            )
        </cfquery>

<cfreturn result.generatedKey>
</cffunction>
<cffunction output="false" name="UPDnoteslog_23967" access="public" returntype="void">
    <cfquery>
        UPDATE noteslog 
        SET NOTEDETAILSHTML = REPLACE(
            NOTEDETAILSHTML, 
            '<input type="text" data-formula="e=mc^2" data-link="https://quilljs.com" data-video="Embed URL">', 
            ''
        ) 
        WHERE NOTEDETAILSHTML LIKE '%<input %';
    </cfquery>
</cffunction>

<cffunction output="false" name="INSnoteslog_23969" access="public" returntype="numeric">
    <cfargument name="userid" type="numeric" required="true">
    <cfargument name="contactid" type="numeric" required="true">
    <cfargument name="noteDetails" type="string" required="true">
    <cfargument name="isPublic" type="boolean" required="true">
    <cfargument name="eventid" type="numeric" required="true">
    <cfargument name="notedetailshtml" type="string" required="true">
        <cfquery result="result" >
            INSERT INTO noteslog (userid, contactid, noteDetails, isPublic, eventid, notedetailshtml)
            VALUES (
                <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.userid#" />,
                <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.contactid#" />,
                <cfqueryparam cfsqltype="cf_sql_longvarchar" value="#LEFT(trim(arguments.noteDetails),2000)#" />,
                <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.isPublic#" />,
                <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.eventid#" />,
                <cfqueryparam cfsqltype="cf_sql_longvarchar" value="#arguments.notedetailshtml#" />
            )
        </cfquery>
<cfreturn result.generatedKey>
</cffunction>
<cffunction output="false" name="INSnoteslog_23972" access="public" returntype="numeric">
    <cfargument name="userid" type="numeric" required="true">
    <cfargument name="contactid" type="numeric" required="true">
    <cfargument name="noteDetails" type="string" required="true">
    <cfargument name="isPublic" type="numeric" required="true">
    <cfargument name="eventid" type="numeric" required="true">

<cfquery result="result" >
            INSERT INTO noteslog (userid, contactid, noteDetails, isPublic, eventid) 
            VALUES (
                <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.userid#" />,
                <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.contactid#" />,
                <cfqueryparam cfsqltype="cf_sql_longvarchar" value="#LEFT(trim(arguments.noteDetails),2000)#" />,
                <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.isPublic#" />,
                <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.eventid#" />
            )
        </cfquery>

</cffunction>
<cffunction output="false" name="UPDnoteslog_23974" access="public" returntype="void">
    <cfargument name="noteDetails" type="string" required="true">
    <cfargument name="new_noteText" type="string" required="true">
    <cfargument name="isPublic" type="boolean" required="true">
    <cfargument name="noteid" type="numeric" required="true">

<cfquery result="result" >
            UPDATE noteslog 
            SET 
                noteDetails = <cfqueryparam cfsqltype="cf_sql_longvarchar" value="#LEFT(trim(arguments.noteDetails),2000)#">,
                notedetailshtml = <cfqueryparam cfsqltype="cf_sql_longvarchar" value="#trim(arguments.new_noteText)#">,
                isPublic = <cfqueryparam cfsqltype="cf_sql_bit" value="#arguments.isPublic#">
            WHERE 
                noteid = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.noteid#">
        </cfquery>

</cffunction>
<cffunction output="false" name="UPDnoteslog_23980" access="public" returntype="void" >
    <cfargument name="noteDetails" type="string" required="true">
    <cfargument name="isPublic" type="boolean" required="true">
    <cfargument name="noteid" type="numeric" required="true">

<cfquery result="result" >
            UPDATE noteslog 
            SET 
                noteDetails = <cfqueryparam cfsqltype="cf_sql_longvarchar" value="#LEFT(trim(arguments.noteDetails),2000)#">,
                isPublic = <cfqueryparam cfsqltype="cf_sql_bit" value="#arguments.isPublic#">
            WHERE 
                noteid = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.noteid#">
        </cfquery>

</cffunction>
<cffunction output="false" name="SELnoteslog_23987" access="public" returntype="query">
    <cfargument name="userID" type="numeric" required="true">
    <cfargument name="eventID" type="numeric" required="true">

<cfquery name="result" >
            SELECT 
                n.noteID, 
                n.noteTimestamp, 
                n.noteid AS recid, 
                'Date' AS head1, 
                'Time' AS head2, 
                'Relationships' AS head3, 
                'Status' AS head4, 
                'Details' AS head5, 
                n.noteTimestamp AS col1, 
                n.noteTimestamp AS col2, 
                n.isPublic AS col4, 
                n.noteDetails AS col5, 
                n.noteDetailsHTML, 
                n.userID
            FROM 
                noteslog n
            WHERE 
                n.userID = <cfqueryparam value="#arguments.userID#" cfsqltype="CF_SQL_INTEGER"> 
                AND n.eventid = <cfqueryparam value="#arguments.eventID#" cfsqltype="CF_SQL_INTEGER">
            ORDER BY 
                n.noteTimestamp DESC
        </cfquery>

<cfreturn result>
</cffunction>
<cffunction output="false" name="DETnoteslog" access="public" returntype="query">
    <cfargument name="updateNoteID" type="numeric" required="true">

<cfquery name="result" >
            SELECT 
                n.noteID, 
                n.noteDetails, 
                n.userID, 
                n.noteTimestamp, 
                n.contactID, 
                n.isPublic, 
                d.contactFullName AS fullname
            FROM 
                noteslog n
            INNER JOIN 
                contactDetails d ON d.contactid = n.contactid
            WHERE 
                n.noteid = <cfqueryparam value="#arguments.updateNoteID#" cfsqltype="CF_SQL_INTEGER">
        </cfquery>

<cfreturn result>
</cffunction>
<cffunction output="false" name="INSnoteslog_24319" access="public" returntype="numeric">
    <cfargument name="userid" type="numeric" required="true">
    <cfargument name="contactid" type="numeric" required="true">
    <cfargument name="noteDetails" type="string" required="true">
    <cfargument name="isPublic" type="boolean" required="true">
    <cfargument name="eventid" type="numeric" required="true">

<cfquery result="result" >
            INSERT INTO noteslog (userid, contactid, noteDetails, isPublic, eventid) 
            VALUES (
                <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.userid#" />,
                <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.contactid#" />,
                <cfqueryparam cfsqltype="cf_sql_longvarchar" value="#arguments.noteDetails#" />,
                <cfqueryparam cfsqltype="cf_sql_bit" value="#arguments.isPublic#" />,
                <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.eventid#" />
            )
        </cfquery>

<cfreturn result.generatedKey>
</cffunction>
<cffunction output="false" name="INSnoteslog_24373" access="public" returntype="numeric">
    <cfargument name="userid" type="numeric" required="true">
    <cfargument name="noteDetails" type="string" required="true">
    <cfargument name="new_audprojectid" type="numeric" required="true">

<cfquery result="result" >
            INSERT INTO noteslog (userid, noteDetails, isPublic, audprojectid, contactid) 
            VALUES (
                <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.userid#" />,
                <cfqueryparam cfsqltype="cf_sql_varchar" value="#LEFT(trim(arguments.noteDetails), 2000)#" />,
                <cfqueryparam cfsqltype="cf_sql_bit" value="1" />,
                <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.new_audprojectid#" />,
                0
            )
        </cfquery>

</cffunction>
<cffunction output="false" name="SELnoteslog_24400" access="public" returntype="query">
    <cfargument name="select_userid" type="numeric" required="true">
    <cfargument name="select_contactid" type="numeric" required="true">
    <cfargument name="noteDetailsPrefix" type="string" required="true">

<cfquery name="result" >
            SELECT * 
            FROM noteslog 
            WHERE userid = <cfqueryparam value="#arguments.select_userid#" cfsqltype="CF_SQL_INTEGER"> 
            AND contactid = <cfqueryparam value="#arguments.select_contactid#" cfsqltype="CF_SQL_INTEGER"> 
            AND noteDetails LIKE '#arguments.noteDetailsPrefix#%'
        </cfquery>

<cfreturn result>
</cffunction>
<cffunction output="false" name="INSnoteslog_24401" access="public" returntype="numeric">
    <cfargument name="userid" type="numeric" required="true">
    <cfargument name="contactid" type="numeric" required="true">
    <cfargument name="noteDetails" type="string" required="true">

<cfquery result="result" >
            INSERT INTO noteslog (userid, contactid, noteDetails, ispublic) 
            VALUES (
                <cfqueryparam value="#arguments.userid#" cfsqltype="CF_SQL_INTEGER">,
                <cfqueryparam value="#arguments.contactid#" cfsqltype="CF_SQL_INTEGER">,
                <cfqueryparam value="#trim(arguments.noteDetails)#" cfsqltype="CF_SQL_VARCHAR">,
                <cfqueryparam value="1" cfsqltype="CF_SQL_BIT">
            )
        </cfquery>
      <cfreturn result.generatedKey>
</cffunction>
<cffunction output="false" name="SELnoteslog_24698" access="public" returntype="query">
    <cfargument name="audprojectid" type="numeric" required="true">

<cfquery name="result" >
            SELECT 
                n.noteID, 
                n.noteTimestamp, 
                n.noteid AS recid, 
                'Date' AS head1, 
                'Time' AS head2, 
                'Relationships' AS head3, 
                'Status' AS head4, 
                'Details' AS head5, 
                n.noteDetails, 
                n.noteTimestamp AS col1, 
                n.noteTimestamp AS col2, 
                n.isPublic AS col4, 
                n.noteDetails AS col5, 
                n.noteDetailsHTML, 
                n.userID
            FROM noteslog n
            WHERE n.audprojectid = <cfqueryparam value="#arguments.audprojectid#" cfsqltype="CF_SQL_INTEGER">
            AND n.audprojectid <> 0
            ORDER BY n.noteTimestamp DESC
        </cfquery>

<cfreturn result>
</cffunction>


<cffunction output="false" name="SELnoteslog_24700" access="public" returntype="query">
    <cfargument name="userID" type="numeric" required="true">
    <cfargument name="contactID" type="numeric" required="true">

<cfquery name="result" >
SELECT DISTINCT
    n.noteID, 
    n.noteid AS recid, 
    'Date' AS head1, 
    'Time' AS head2, 
    'Relationships' AS head3, 
    'Status' AS head4, 
    'Details' AS head5, 
    n.noteTimestamp AS col1, 
    n.noteTimestamp AS col2, 
    d.contactfullname AS col3, 
    n.isPublic AS col4, 
    n.noteDetails AS col5, 
    n.userID, 
    n.contactID
FROM noteslog n
INNER JOIN contactDetails d ON d.contactid = n.contactid
WHERE n.userID = <cfqueryparam value="#arguments.userID#" cfsqltype="CF_SQL_INTEGER">
AND (
  
    n.contactID = <cfqueryparam value="#arguments.contactID#" cfsqltype="CF_SQL_INTEGER">
    
 
    OR n.contactID IN (
        SELECT x.contactid FROM eventcontactsxref x
        WHERE x.contactid = <cfqueryparam value="#arguments.contactID#" cfsqltype="CF_SQL_INTEGER">
    )
)
ORDER BY n.noteTimestamp DESC;


        </cfquery>

<cfreturn result>
</cffunction>
<cffunction output="false" name="SELnoteslog_24702" access="public" returntype="query">
    <cfargument name="userID" type="numeric" required="true">
    <cfargument name="eventID" type="numeric" required="true">

<cfquery name="result" >
            SELECT 
                n.noteID, 
                n.noteTimestamp, 
                n.noteid AS recid, 
                'Date' AS head1, 
                'Time' AS head2, 
                'Relationships' AS head3, 
                'Status' AS head4, 
                'Details' AS head5, 
                n.noteDetails, 
                n.noteTimestamp AS col1, 
                n.noteTimestamp AS col2, 
                n.isPublic AS col4, 
                n.noteDetails AS col5, 
                n.noteDetailsHTML, 
                n.userID
            FROM noteslog n
            WHERE n.userID = <cfqueryparam value="#arguments.userID#" cfsqltype="CF_SQL_INTEGER">
            AND n.eventid = <cfqueryparam value="#arguments.eventID#" cfsqltype="CF_SQL_INTEGER">
            ORDER BY n.noteTimestamp DESC
        </cfquery>

<cfreturn result>

</cffunction>
<cffunction output="false" name="SELnoteslog_24704" access="public" returntype="query">
    <cfargument name="userID" type="numeric" required="true">
    <cfargument name="contactID" type="numeric" required="true">

<cfquery name="result" >
            SELECT 
                n.noteID, 
                n.noteid AS recid, 
                'Date' AS head1, 
                'Time' AS head2, 
                'Relationships' AS head3, 
                'Status' AS head4, 
                'Details' AS head5, 
                n.notetimestamp, 
                n.noteTimestamp AS col1, 
                n.noteTimestamp AS col2, 
                n.noteDetails, 
                d.contactfullname AS col3, 
                n.isPublic AS col4, 
                n.noteDetails AS col5, 
                n.noteDetailsHTML, 
                n.userID, 
                n.contactID
            FROM noteslog n
            INNER JOIN contactDetails d ON d.contactid = n.contactid
            WHERE n.userID = <cfqueryparam value="#arguments.userID#" cfsqltype="CF_SQL_INTEGER"> 
            AND n.contactid = <cfqueryparam value="#arguments.contactID#" cfsqltype="CF_SQL_INTEGER">
            ORDER BY n.noteTimestamp DESC
        </cfquery>

<cfreturn result>
</cffunction>
</cfcomponent>
