<!--- This ColdFusion page handles the deletion of records from the audvocaltypes_audition_xref table based on the provided audroleid. --->

<cfquery name="delete">
    <!--- Execute a delete operation on the audvocaltypes_audition_xref table --->
    delete from audvocaltypes_audition_xref 
    where audroleid = #new_audroleid#
</cfquery>
