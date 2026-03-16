<!--- This ColdFusion page is responsible for deleting records from the audessences_audtion_xref table based on the provided audroleid. --->

<cfquery name="delete">
    <!--- Execute a delete operation on the audessences_audtion_xref table based on the specified audroleid. --->
    DELETE FROM audessences_audtion_xref 
    WHERE audroleid = <cfqueryparam value="#new_audroleid#" cfsqltype="cf_sql_integer">
</cfquery>
