       <cfquery result="result" name="getDeletedRecords" datasource="abod">
    SELECT id, qry_details
    FROM tao_files
    WHERE status = 'deleted'
    AND qry_details IS NOT NULL
</cfquery>

<cfloop query="getDeletedRecords">
    <!--- Find the matching non-deleted record for this qry_details --->
    <cfquery result="result" name="getReplacementRecord" datasource="abod">
        SELECT id
        FROM tao_files
        WHERE qry_details = <cfqueryparam value="#getDeletedRecords.qry_details#" cfsqltype="cf_sql_longvarchar">
        AND status <> 'deleted'
        LIMIT 1
    </cfquery>

    <!--- If a matching non-deleted record is found, update the deleted record with replacement_id --->
    <cfif getReplacementRecord.recordcount GT 0>
        <cfquery result="result" datasource="abod">
            UPDATE tao_files
            SET replacement_id = <cfqueryparam value="#getReplacementRecord.id#" cfsqltype="cf_sql_integer">
            WHERE id = <cfqueryparam value="#getDeletedRecords.id#" cfsqltype="cf_sql_integer">
        </cfquery>
    </cfif>
</cfloop>
