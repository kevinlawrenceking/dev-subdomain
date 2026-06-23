<cfsilent>
<!--- Migration Runner: widen auditionsimport.note VARCHAR(500) -> TEXT.
      Stops audition-import notes truncating at 500 chars.
      Idempotent (guarded by information_schema DATA_TYPE) and env-agnostic.
      Usage: /database/run-auditionsimport-note-migration.cfm?run=yes --->
<cfinclude template="/database/admin-guard.cfm">
</cfsilent>
<cfset response = {success: false, step: "", message: "", results: []}>
<cftry>
<cfif not structKeyExists(url, "run") or url.run neq "yes">
    <cfset response.message = "Add ?run=yes to execute migration">
    <cfcontent type="application/json" reset="true"><cfoutput>#serializeJSON(response)#</cfoutput>
    <cfabort>
</cfif>

<!--- Step 1: check current type --->
<cfset response.step = "Check auditionsimport.note type">
<cfquery name="qCol" datasource="#application.dsn#">
    SELECT data_type, character_maximum_length
    FROM information_schema.columns
    WHERE table_schema = DATABASE()
      AND table_name = 'auditionsimport'
      AND column_name = 'note'
</cfquery>

<cfif qCol.recordCount eq 0>
    <cfset response.success = true>
    <cfset response.message = "No-op: auditionsimport.note not found on this schema.">
    <cfcontent type="application/json" reset="true"><cfoutput>#serializeJSON(response)#</cfoutput>
    <cfabort>
</cfif>

<cfif qCol.data_type eq "varchar">
    <cfset response.step = "Widen auditionsimport.note to TEXT">
    <cfquery datasource="#application.dsn#">
        ALTER TABLE auditionsimport MODIFY COLUMN note TEXT NULL
    </cfquery>
    <cfset arrayAppend(response.results, "Widened auditionsimport.note from varchar(" & qCol.character_maximum_length & ") to TEXT")>
<cfelse>
    <cfset arrayAppend(response.results, "auditionsimport.note already " & qCol.data_type & " - no change")>
</cfif>

<!--- Post-check --->
<cfquery name="qVerify" datasource="#application.dsn#">
    SELECT data_type, character_maximum_length
    FROM information_schema.columns
    WHERE table_schema = DATABASE()
      AND table_name = 'auditionsimport'
      AND column_name = 'note'
</cfquery>
<cfset arrayAppend(response.results, "Post-check data_type=" & qVerify.data_type)>

<cfset response.success = true>
<cfset response.message = "auditionsimport.note migration completed">

<cfcatch type="any">
    <cfset response.message = "Error at step [" & response.step & "]: " & cfcatch.message>
    <cfif structKeyExists(cfcatch, "sql") and len(cfcatch.sql)>
        <cfset response.message = response.message & " | SQL: " & left(cfcatch.sql, 200)>
    </cfif>
</cfcatch>
</cftry>
<cfcontent type="application/json" reset="true"><cfoutput>#serializeJSON(response)#</cfoutput>
