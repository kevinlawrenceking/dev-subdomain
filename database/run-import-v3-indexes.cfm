<!---
    Contact Import V3.2 - Dupe Detection Index Migration Runner
    Run: /database/run-import-v3-indexes.cfm?run=yes

    Creates three performance indexes for duplicate detection queries.
    Safe to run multiple times (checks before creating).

    Equivalent to: database/migrations/V3_2__contact_import_v3_dupe_indexes.sql
    Rollback:      database/migrations/V3_2__contact_import_v3_dupe_indexes_ROLLBACK.sql
--->
<cfinclude template="/database/admin-guard.cfm">
<cfsetting requesttimeout="300">
<cfset dsn = application.dsn>
<cfset schemaName = application.information_schema>

<cfset response = {
    success: false,
    environment: {
        dsn: dsn,
        schema: schemaName,
        host: ListFirst(cgi.server_name, ".")
    },
    steps: [],
    indexes_before: [],
    indexes_after: [],
    explain_results: []
}>

<cftry>
    <!--- Safety gate --->
    <cfif not structKeyExists(url, "run") or url.run neq "yes">
        <cfset response.message = "Add ?run=yes to execute. This will create 3 indexes on contactdetails_tbl and contactitems_tbl.">
        <cfcontent type="application/json" reset="true"><cfoutput>#serializeJSON(response)#</cfoutput>
        <cfabort>
    </cfif>

    <!--- ============================================================
         STEP 1: Verify base tables exist
         ============================================================ --->
    <cfquery name="qTables" datasource="#dsn#">
        SELECT table_name, table_type
        FROM information_schema.tables
        WHERE table_schema = <cfqueryparam cfsqltype="cf_sql_varchar" value="#schemaName#">
          AND table_name IN ('contactdetails_tbl', 'contactitems_tbl')
        ORDER BY table_name
    </cfquery>

    <cfset step1 = {step: "verify_base_tables", tables_found: qTables.recordCount, details: []}>
    <cfloop query="qTables">
        <cfset arrayAppend(step1.details, {table: qTables.table_name, type: qTables.table_type})>
    </cfloop>
    <cfset arrayAppend(response.steps, step1)>

    <cfif qTables.recordCount lt 2>
        <cfset response.message = "ABORT: Missing base tables. Expected contactdetails_tbl and contactitems_tbl in #schemaName#.">
        <cfcontent type="application/json" reset="true"><cfoutput>#serializeJSON(response)#</cfoutput>
        <cfabort>
    </cfif>

    <!--- ============================================================
         STEP 2: Check existing indexes (before)
         ============================================================ --->
    <cfquery name="qIdxBefore" datasource="#dsn#">
        SELECT table_name, index_name, GROUP_CONCAT(column_name ORDER BY seq_in_index) AS columns
        FROM information_schema.statistics
        WHERE table_schema = <cfqueryparam cfsqltype="cf_sql_varchar" value="#schemaName#">
          AND table_name IN ('contactdetails_tbl', 'contactitems_tbl')
          AND (index_name LIKE '%dupe%' OR index_name LIKE '%category_status%' OR index_name LIKE '%user%')
        GROUP BY table_name, index_name
        ORDER BY table_name, index_name
    </cfquery>

    <cfloop query="qIdxBefore">
        <cfset arrayAppend(response.indexes_before, {
            table: qIdxBefore.table_name,
            index_name: qIdxBefore.index_name,
            columns: qIdxBefore.columns
        })>
    </cfloop>

    <!--- ============================================================
         STEP 3: Create Index 1 - contactdetails_tbl dupe index
         ============================================================ --->
    <cfset idx1Name = "idx_contactdetails_tbl_dupe_v3">
    <cfquery name="qCheck1" datasource="#dsn#">
        SELECT COUNT(*) AS cnt
        FROM information_schema.statistics
        WHERE table_schema = <cfqueryparam cfsqltype="cf_sql_varchar" value="#schemaName#">
          AND table_name = 'contactdetails_tbl'
          AND index_name = <cfqueryparam cfsqltype="cf_sql_varchar" value="#idx1Name#">
    </cfquery>

    <cfif qCheck1.cnt eq 0>
        <cfquery datasource="#dsn#">
            CREATE INDEX #idx1Name# ON contactdetails_tbl (userid, isdeleted, contactid)
        </cfquery>
        <cfset arrayAppend(response.steps, {step: "create_index_1", index: idx1Name, table: "contactdetails_tbl", columns: "userid, isdeleted, contactid", result: "CREATED"})>
    <cfelse>
        <cfset arrayAppend(response.steps, {step: "create_index_1", index: idx1Name, table: "contactdetails_tbl", result: "ALREADY EXISTS - skipped"})>
    </cfif>

    <!--- ============================================================
         STEP 4: Create Index 2 - contactitems_tbl dupe lookup index
         ============================================================ --->
    <cfset idx2Name = "idx_contactitems_tbl_dupe_v3">
    <cfquery name="qCheck2" datasource="#dsn#">
        SELECT COUNT(*) AS cnt
        FROM information_schema.statistics
        WHERE table_schema = <cfqueryparam cfsqltype="cf_sql_varchar" value="#schemaName#">
          AND table_name = 'contactitems_tbl'
          AND index_name = <cfqueryparam cfsqltype="cf_sql_varchar" value="#idx2Name#">
    </cfquery>

    <cfif qCheck2.cnt eq 0>
        <cfquery datasource="#dsn#">
            CREATE INDEX #idx2Name# ON contactitems_tbl (contactid, itemStatus, isDeleted, valueCategory, valuetext(100))
        </cfquery>
        <cfset arrayAppend(response.steps, {step: "create_index_2", index: idx2Name, table: "contactitems_tbl", columns: "contactid, itemStatus, isDeleted, valueCategory, valuetext(100)", result: "CREATED"})>
    <cfelse>
        <cfset arrayAppend(response.steps, {step: "create_index_2", index: idx2Name, table: "contactitems_tbl", result: "ALREADY EXISTS - skipped"})>
    </cfif>

    <!--- ============================================================
         STEP 5: Create Index 3 - contactitems_tbl category+status index
         ============================================================ --->
    <cfset idx3Name = "idx_contactitems_tbl_category_status">
    <cfquery name="qCheck3" datasource="#dsn#">
        SELECT COUNT(*) AS cnt
        FROM information_schema.statistics
        WHERE table_schema = <cfqueryparam cfsqltype="cf_sql_varchar" value="#schemaName#">
          AND table_name = 'contactitems_tbl'
          AND index_name = <cfqueryparam cfsqltype="cf_sql_varchar" value="#idx3Name#">
    </cfquery>

    <cfif qCheck3.cnt eq 0>
        <cfquery datasource="#dsn#">
            CREATE INDEX #idx3Name# ON contactitems_tbl (valueCategory, itemStatus, isDeleted, contactid)
        </cfquery>
        <cfset arrayAppend(response.steps, {step: "create_index_3", index: idx3Name, table: "contactitems_tbl", columns: "valueCategory, itemStatus, isDeleted, contactid", result: "CREATED"})>
    <cfelse>
        <cfset arrayAppend(response.steps, {step: "create_index_3", index: idx3Name, table: "contactitems_tbl", result: "ALREADY EXISTS - skipped"})>
    </cfif>

    <!--- ============================================================
         STEP 6: Verify indexes (after)
         ============================================================ --->
    <cfquery name="qIdxAfter" datasource="#dsn#">
        SELECT table_name, index_name, GROUP_CONCAT(column_name ORDER BY seq_in_index) AS columns
        FROM information_schema.statistics
        WHERE table_schema = <cfqueryparam cfsqltype="cf_sql_varchar" value="#schemaName#">
          AND table_name IN ('contactdetails_tbl', 'contactitems_tbl')
          AND (index_name LIKE '%dupe%' OR index_name LIKE '%category_status%')
        GROUP BY table_name, index_name
        ORDER BY table_name, index_name
    </cfquery>

    <cfloop query="qIdxAfter">
        <cfset arrayAppend(response.indexes_after, {
            table: qIdxAfter.table_name,
            index_name: qIdxAfter.index_name,
            columns: qIdxAfter.columns
        })>
    </cfloop>

    <!--- ============================================================
         STEP 7: Run EXPLAIN queries to verify index usage
         ============================================================ --->

    <!--- Find a real userid to test with --->
    <cfquery name="qUser" datasource="#dsn#">
        SELECT userid FROM contactdetails_tbl WHERE userid IS NOT NULL LIMIT 1
    </cfquery>

    <cfif qUser.recordCount gt 0>
        <cfset testUserid = qUser.userid>

        <!--- EXPLAIN 1: buildUserDupeIndex query --->
        <cfquery name="qExplain1" datasource="#dsn#">
            EXPLAIN SELECT ci.contactid, ci.valueCategory, ci.valuetext
            FROM contactitems_tbl ci
            INNER JOIN contactdetails_tbl d ON d.contactid = ci.contactid
            WHERE d.userid = <cfqueryparam cfsqltype="cf_sql_integer" value="#testUserid#">
              AND (d.isdeleted IS NULL OR d.isdeleted = 0)
              AND ci.itemStatus = 'Active'
              AND (ci.isDeleted IS NULL OR ci.isDeleted = 0)
              AND ci.valueCategory IN ('Email', 'Phone')
        </cfquery>

        <cfset explain1 = {query: "buildUserDupeIndex", userid: testUserid, rows: []}>
        <cfloop query="qExplain1">
            <cfset arrayAppend(explain1.rows, {
                table: qExplain1.table,
                type: qExplain1.type,
                possible_keys: qExplain1.possible_keys,
                key_used: qExplain1.key,
                rows_estimate: qExplain1.rows,
                extra: qExplain1.extra
            })>
        </cfloop>

        <!--- PASS/FAIL check --->
        <cfset explain1.pass = true>
        <cfloop query="qExplain1">
            <cfif qExplain1.type eq "ALL" or (NOT len(trim(qExplain1.key)))>
                <cfset explain1.pass = false>
            </cfif>
        </cfloop>
        <cfset arrayAppend(response.explain_results, explain1)>

        <!--- EXPLAIN 2: getCandidateContactIds query --->
        <cfquery name="qExplain2" datasource="#dsn#">
            EXPLAIN SELECT DISTINCT ci.contactid
            FROM contactitems_tbl ci
            INNER JOIN contactdetails_tbl d ON d.contactid = ci.contactid
            WHERE d.userid = <cfqueryparam cfsqltype="cf_sql_integer" value="#testUserid#">
              AND (d.isdeleted IS NULL OR d.isdeleted = 0)
              AND ci.itemStatus = 'Active'
              AND (ci.isDeleted IS NULL OR ci.isDeleted = 0)
              AND (ci.valueCategory = 'Email' AND ci.valuetext IN ('test@example.com'))
            LIMIT 100
        </cfquery>

        <cfset explain2 = {query: "getCandidateContactIds", userid: testUserid, rows: []}>
        <cfloop query="qExplain2">
            <cfset arrayAppend(explain2.rows, {
                table: qExplain2.table,
                type: qExplain2.type,
                possible_keys: qExplain2.possible_keys,
                key_used: qExplain2.key,
                rows_estimate: qExplain2.rows,
                extra: qExplain2.extra
            })>
        </cfloop>

        <cfset explain2.pass = true>
        <cfloop query="qExplain2">
            <cfif qExplain2.type eq "ALL" or (NOT len(trim(qExplain2.key)))>
                <cfset explain2.pass = false>
            </cfif>
        </cfloop>
        <cfset arrayAppend(response.explain_results, explain2)>

    <cfelse>
        <cfset arrayAppend(response.explain_results, {query: "SKIPPED", reason: "No users found in contactdetails_tbl"})>
    </cfif>

    <!--- ============================================================
         STEP 8: Table size info
         ============================================================ --->
    <cfquery name="qSizes" datasource="#dsn#">
        SELECT table_name, table_rows,
               ROUND(data_length / 1024 / 1024, 2) AS data_mb,
               ROUND(index_length / 1024 / 1024, 2) AS index_mb
        FROM information_schema.tables
        WHERE table_schema = <cfqueryparam cfsqltype="cf_sql_varchar" value="#schemaName#">
          AND table_name IN ('contactdetails_tbl', 'contactitems_tbl')
    </cfquery>

    <cfset response.table_sizes = []>
    <cfloop query="qSizes">
        <cfset arrayAppend(response.table_sizes, {
            table: qSizes.table_name,
            approx_rows: qSizes.table_rows,
            data_mb: qSizes.data_mb,
            index_mb: qSizes.index_mb
        })>
    </cfloop>

    <!--- Done --->
    <cfset response.success = true>
    <cfset response.message = "V3.2 index migration complete. Check indexes_after and explain_results.">

<cfcatch type="any">
    <cfset response.success = false>
    <cfset response.message = "ERROR: #cfcatch.message#">
    <cfset response.error_detail = cfcatch.detail>
</cfcatch>
</cftry>

<cfcontent type="application/json" reset="true">
<cfoutput>#serializeJSON(response)#</cfoutput>
