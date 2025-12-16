<cfsilent>
<!---
    Contact Import V2 - Column Mapping Endpoint
    GET /ajax/import/columns.cfm?job_id=123

    Returns: JSON with column mappings and available fields
--->

<cfset response = {
    success: false,
    columns: [],
    available_fields: [],
    message: ""
}>

<cftry>
    <!--- Validate user session --->
    <cfif not isDefined("userid") or not isNumeric(userid)>
        <cfset response.message = "Authentication required">
        <cfoutput>#serializeJSON(response)#</cfoutput>
        <cfabort>
    </cfif>

    <!--- Validate job_id --->
    <cfparam name="url.job_id" default="0">
    <cfif not isNumeric(url.job_id) or url.job_id eq 0>
        <cfset response.message = "Missing or invalid job_id">
        <cfoutput>#serializeJSON(response)#</cfoutput>
        <cfabort>
    </cfif>

    <!--- Get job --->
    <cfset importService = new services.ContactImportV2Service()>
    <cfset job = importService.getJob(url.job_id)>

    <cfif not job.found>
        <cfset response.message = "Job not found">
        <cfoutput>#serializeJSON(response)#</cfoutput>
        <cfabort>
    </cfif>

    <!--- Verify ownership --->
    <cfif job.userid neq userid>
        <cfset response.message = "Access denied">
        <cfoutput>#serializeJSON(response)#</cfoutput>
        <cfabort>
    </cfif>

    <!--- Get column mappings --->
    <cfset qColumns = importService.getColumnMappings(url.job_id)>
    <cfset columns = []>

    <cfloop query="qColumns">
        <cfset arrayAppend(columns, {
            column_id: qColumns.column_id,
            source_index: qColumns.source_column_index,
            source_name: qColumns.source_column_name,
            suggested_field: qColumns.normalized_field,
            confidence: qColumns.confidence,
            confirmed: qColumns.user_confirmed eq 1
        })>
    </cfloop>

    <!--- Get available fields --->
    <cfset qFields = importService.getAvailableFields()>
    <cfset availableFields = []>

    <cfloop query="qFields">
        <cfset arrayAppend(availableFields, {
            field: qFields.canonical_field,
            display_name: qFields.display_name,
            category: qFields.field_category,
            type: qFields.field_type,
            required: qFields.is_required eq 1
        })>
    </cfloop>

    <!--- Return success --->
    <cfset response.success = true>
    <cfset response.columns = columns>
    <cfset response.available_fields = availableFields>

    <cfcatch type="any">
        <cfset response.message = "Error: " & cfcatch.message>
    </cfcatch>
</cftry>
</cfsilent>
<cfcontent type="application/json" reset="true"><cfoutput>#serializeJSON(response)#</cfoutput>
