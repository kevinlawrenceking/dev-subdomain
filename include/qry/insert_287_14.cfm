<!--- This ColdFusion page inserts a new record into the audgenres_audition_xref table --->
<cfquery name="insert">
    <!--- Insert a new record into the audgenres_audition_xref table with specified genre and role IDs --->
    insert into audgenres_audition_xref (audgenreid, audroleid) 
    values (#new_audgenreid#, #new_audroleid#)
</cfquery>
