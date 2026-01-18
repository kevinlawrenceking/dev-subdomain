<!--- This ColdFusion page updates a note in the noteslog table based on the provided note ID and new details. --->

<cfquery name="updatenote">
    <!--- Update the noteslog table with new note details, HTML representation, and visibility status. --->
    UPDATE noteslog
        SET noteDetails = <cfqueryparam cfsqltype="cf_sql_longvarchar" value="#LEFT(trim(noteDetails),2000)#" />,
            notedetailshtml = <cfqueryparam cfsqltype="cf_sql_longvarchar" value="#trim(new_notetext)#" />,
            isPublic = <cfqueryparam cfsqltype="cf_sql_bit" value="#isPublic#" />
        WHERE noteid = <cfqueryparam cfsqltype="cf_sql_integer" value="#noteid#" />
</cfquery>
