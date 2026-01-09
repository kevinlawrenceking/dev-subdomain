<cfsilent>
<!--- Migration Runner for V2_1 --->
</cfsilent>
<cfset response = {success: false, step: "", message: "", results: []}>
<cftry>
<cfif not structKeyExists(url, "run") or url.run neq "yes">
    <cfset response.message = "Add ?run=yes to execute migration">
    <cfcontent type="application/json" reset="true"><cfoutput>#serializeJSON(response)#</cfoutput>
    <cfabort>
</cfif>
<cfset dsn = "reach">
<cfquery name="qCheckColumn" datasource="#dsn#">
SELECT COLUMN_NAME, DATA_TYPE FROM information_schema.columns
WHERE table_schema = 'new_development' AND table_name = 'import_jobs' AND column_name = 'file_hash'
</cfquery>
<cfif qCheckColumn.recordCount eq 0>
    <cfquery datasource="#dsn#">ALTER TABLE import_jobs ADD COLUMN file_hash VARCHAR(64) NULL</cfquery>
    <cfset arrayAppend(response.results, "Added file_hash column")>
<cfelse>
    <cfset arrayAppend(response.results, "file_hash column exists: " & qCheckColumn.DATA_TYPE)>
</cfif>
<cfquery name="qCheckIdx" datasource="#dsn#">
SELECT COUNT(*) AS cnt FROM information_schema.statistics
WHERE table_schema = 'new_development' AND table_name = 'import_jobs' AND index_name = 'UX_import_jobs_userid_file_hash'
</cfquery>
<cfif qCheckIdx.cnt eq 0>
    <cfquery datasource="#dsn#">CREATE UNIQUE INDEX UX_import_jobs_userid_file_hash ON import_jobs(userid, file_hash)</cfquery>
    <cfset arrayAppend(response.results, "Created unique index")>
<cfelse>
    <cfset arrayAppend(response.results, "Unique index exists")>
</cfif>
<cfquery name="qCheckMap" datasource="#dsn#">SELECT COUNT(*) AS cnt FROM import_field_mappings WHERE canonical_field = 'relationship_system'</cfquery>
<cfif qCheckMap.cnt eq 0>
    <cfquery datasource="#dsn#">INSERT INTO import_field_mappings (canonical_field, display_name, field_category, field_type, is_required, max_length, sort_order) VALUES ('relationship_system', 'Relationship System', 'contact', 'select', 0, 50, 90)</cfquery>
    <cfset arrayAppend(response.results, "Added relationship_system mapping")>
<cfelse>
    <cfset arrayAppend(response.results, "relationship_system mapping exists")>
</cfif>
<cfquery datasource="#dsn#">
INSERT IGNORE INTO import_field_aliases (canonical_field, alias_pattern, confidence) VALUES
('relationship_system', 'relationship_system', 0.95),
('relationship_system', 'relationship system', 0.95),
('relationship_system', 'maintenance_or_target', 0.95),
('relationship_system', 'maintenance or target', 0.95),
('relationship_system', 'system', 0.70),
('relationship_system', 'fu system', 0.85),
('relationship_system', 'follow up system', 0.85),
('relationship_system', 'followup system', 0.85),
('firstName', 'given name', 0.98),
('lastName', 'family name', 0.98),
('contactFullName', 'name', 0.85),
('email_business', 'e-mail 1 - value', 0.95),
('email_personal', 'e-mail 2 - value', 0.90),
('phone_work', 'phone 1 - value', 0.90),
('phone_mobile', 'phone 2 - value', 0.85),
('phone_home', 'phone 3 - value', 0.80),
('company', 'organization 1 - name', 0.98),
('jobTitle', 'organization 1 - title', 0.98),
('department', 'organization 1 - department', 0.98),
('address_street', 'address 1 - street', 0.98),
('address_city', 'address 1 - city', 0.98),
('address_state', 'address 1 - region', 0.98),
('address_zip', 'address 1 - postal code', 0.98),
('address_country', 'address 1 - country', 0.98),
('birthday', 'birthday', 0.98),
('notes', 'notes', 0.98),
('website', 'website 1 - value', 0.95),
('contactFullName', 'fn', 0.98),
('firstName', 'n_given', 0.98),
('lastName', 'n_family', 0.98),
('email_business', 'email_work', 0.98),
('email_personal', 'email_home', 0.98),
('phone_work', 'tel_work', 0.98),
('phone_mobile', 'tel_cell', 0.98),
('phone_home', 'tel_home', 0.98),
('company', 'org', 0.98),
('jobTitle', 'title', 0.85),
('address_street', 'adr_street', 0.98),
('address_city', 'adr_city', 0.98),
('address_state', 'adr_region', 0.98),
('address_zip', 'adr_postal', 0.98),
('address_country', 'adr_country', 0.98),
('birthday', 'bday', 0.98),
('notes', 'note', 0.95),
('website', 'url', 0.95)
</cfquery>
<cfset arrayAppend(response.results, "Inserted aliases (INSERT IGNORE)")>
<cfset response.success = true>
<cfset response.message = "V2_1 Migration completed">
<cfcatch>
    <cfset response.message = "Error: " & cfcatch.message & " - " & cfcatch.detail>
</cfcatch>
</cftry>
<cfcontent type="application/json" reset="true"><cfoutput>#serializeJSON(response)#</cfoutput>
