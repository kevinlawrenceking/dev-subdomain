<cfsilent>
<!--- Migration Verification Queries for V2_1 --->
</cfsilent>
<cfset response = {success: false, message: "", checks: {}}>
<cftry>
<cfset dsn = "abod">
<!--- Check 1: file_hash column --->
<cfquery name="q1" datasource="#dsn#">
SELECT COLUMN_NAME, DATA_TYPE FROM information_schema.columns
WHERE table_schema = 'new_development' AND table_name = 'import_jobs' AND column_name = 'file_hash'
</cfquery>
<cfset response.checks.file_hash_column = {exists: q1.recordCount gt 0, data_type: (q1.recordCount gt 0 ? q1.DATA_TYPE : "N/A")}>
<!--- Check 2: unique index --->
<cfquery name="q2" datasource="#dsn#">
SELECT INDEX_NAME, NON_UNIQUE FROM information_schema.statistics
WHERE table_schema = 'new_development' AND table_name = 'import_jobs' AND index_name = 'UX_import_jobs_userid_file_hash'
</cfquery>
<cfset response.checks.unique_index = {exists: q2.recordCount gt 0, non_unique: (q2.recordCount gt 0 ? q2.NON_UNIQUE : "N/A")}>
<!--- Check 3: relationship_system mapping --->
<cfquery name="q3" datasource="#dsn#">
SELECT canonical_field, display_name, field_type FROM import_field_mappings WHERE canonical_field = 'relationship_system'
</cfquery>
<cfset response.checks.relationship_system_mapping = {exists: q3.recordCount gt 0, display_name: (q3.recordCount gt 0 ? q3.display_name : "N/A")}>
<!--- Check 4: Google/Apple aliases --->
<cfquery name="q4" datasource="#dsn#">
SELECT COUNT(*) as alias_count FROM import_field_aliases 
WHERE alias_pattern IN ('given name', 'family name', 'fn', 'n_given', 'n_family', 'e-mail 1 - value')
</cfquery>
<cfset response.checks.google_apple_aliases = {count: q4.alias_count, expected: 6}>
<!--- Check 5: Total aliases count --->
<cfquery name="q5" datasource="#dsn#">SELECT COUNT(*) as total FROM import_field_aliases</cfquery>
<cfset response.checks.total_aliases = q5.total>
<cfset response.success = true>
<cfset response.message = "Verification completed">
<cfcatch>
<cfset response.message = "Error: " & cfcatch.message>
</cfcatch>
</cftry>
<cfcontent type="application/json" reset="true"><cfoutput>#serializeJSON(response)#</cfoutput>
