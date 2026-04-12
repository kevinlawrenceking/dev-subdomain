<cfcomponent displayname="DuplicateMatcherService" hint="Duplicate detection and matching for contact imports">

<!--- ========================================
      DUPLICATE MATCHER SERVICE
      Purpose: Find potential duplicate contacts
      in the database before import. Uses scoring
      algorithm with configurable thresholds.
     ======================================== --->

<!--- Matching thresholds --->
<cfset this.THRESHOLD_HIGH = 70>
<cfset this.THRESHOLD_MEDIUM = 40>
<cfset this.THRESHOLD_LOW = 25>
<cfset this.MAX_CANDIDATES = 5>

<!--- Feature flags --->
<cfset this.ENABLE_NAME_FALLBACK = true>
<cfset this.NAME_FALLBACK_LIMIT = 20>

<!--- Phase 4.1: Memory guardrails for dupe index --->
<cfset this.MAX_DUPE_INDEX_ITEMS = 200000>
<cfset this.MAX_DUPE_INDEX_CONTACTIDS = 50000>
<cfset this.MAX_DUPE_INDEX_BUILD_MS = 5000>
<cfset this.DETAILS_BATCH_CHUNK_SIZE = 200>

<!--- ========================================
      NORMALIZATION HELPERS (pure, no DB)
     ======================================== --->

<cffunction name="normalizeEmail" access="public" returntype="string" output="false"
    hint="Normalize email: lowercase and trim">
    <cfargument name="email" type="string" required="true">
    <cfreturn lcase(trim(arguments.email))>
</cffunction>

<cffunction name="normalizePhone" access="public" returntype="string" output="false"
    hint="Normalize phone: digits only, last 10 if longer">
    <cfargument name="phone" type="string" required="true">
    <cfset var digits = reReplace(arguments.phone, "[^0-9]", "", "ALL")>
    <!--- Remove leading 1 from US numbers --->
    <cfif len(digits) eq 11 and left(digits, 1) eq "1">
        <cfset digits = mid(digits, 2, 10)>
    </cfif>
    <!--- If still longer than 10, take last 10 --->
    <cfif len(digits) gt 10>
        <cfset digits = right(digits, 10)>
    </cfif>
    <cfreturn digits>
</cffunction>

<cffunction name="normalizeName" access="public" returntype="string" output="false"
    hint="Normalize name: trim, collapse spaces, lowercase">
    <cfargument name="name" type="string" required="true">
    <cfset var result = trim(arguments.name)>
    <!--- Collapse multiple spaces to single --->
    <cfset result = reReplace(result, "\s+", " ", "ALL")>
    <cfreturn lcase(result)>
</cffunction>

<!--- ========================================
      TABLE AVAILABILITY CHECK
     ======================================== --->

<cffunction name="isDupeDetectionAvailable" access="public" returntype="struct" output="false"
    hint="Check if required tables/views exist for duplicate detection">

    <cfset var result = {
        available: false,
        reason: "",
        tables: {},
        table_types: {},
        base_tables: {},
        schema: ""
    }>

    <cftry>
        <!--- First get the actual schema name for debug visibility --->
        <cfquery name="qSchema" datasource="#application.datasource#" timeout="5">
            SELECT DATABASE() AS schema_name
        </cfquery>
<cfif structKeyExists(request,"perfSvcQueryCount")><cfset request.perfSvcQueryCount++></cfif>
        <cfset result.schema = qSchema.schema_name>

        <!--- Check contactdetails - get both existence and table type --->
        <cfquery name="qCheckDetails" datasource="#application.datasource#" timeout="5">
            SELECT TABLE_NAME, TABLE_TYPE
            FROM information_schema.TABLES
            WHERE TABLE_SCHEMA = DATABASE()
              AND TABLE_NAME = 'contactdetails'
        </cfquery>
<cfif structKeyExists(request,"perfSvcQueryCount")><cfset request.perfSvcQueryCount++></cfif>
        <cfset result.tables.contactdetails = qCheckDetails.recordCount gt 0>
        <cfif qCheckDetails.recordCount gt 0>
            <cfset result.table_types.contactdetails = qCheckDetails.TABLE_TYPE>
        </cfif>

        <!--- Check contactitems - get both existence and table type --->
        <cfquery name="qCheckItems" datasource="#application.datasource#" timeout="5">
            SELECT TABLE_NAME, TABLE_TYPE
            FROM information_schema.TABLES
            WHERE TABLE_SCHEMA = DATABASE()
              AND TABLE_NAME = 'contactitems'
        </cfquery>
<cfif structKeyExists(request,"perfSvcQueryCount")><cfset request.perfSvcQueryCount++></cfif>
        <cfset result.tables.contactitems = qCheckItems.recordCount gt 0>
        <cfif qCheckItems.recordCount gt 0>
            <cfset result.table_types.contactitems = qCheckItems.TABLE_TYPE>
        </cfif>

        <!--- Also check for base tables (_tbl suffix) where indexes live --->
        <cfquery name="qCheckDetailsTbl" datasource="#application.datasource#" timeout="5">
            SELECT TABLE_NAME, TABLE_TYPE
            FROM information_schema.TABLES
            WHERE TABLE_SCHEMA = DATABASE()
              AND TABLE_NAME = 'contactdetails_tbl'
        </cfquery>
<cfif structKeyExists(request,"perfSvcQueryCount")><cfset request.perfSvcQueryCount++></cfif>
        <cfset result.base_tables.contactdetails_tbl = qCheckDetailsTbl.recordCount gt 0>

        <cfquery name="qCheckItemsTbl" datasource="#application.datasource#" timeout="5">
            SELECT TABLE_NAME, TABLE_TYPE
            FROM information_schema.TABLES
            WHERE TABLE_SCHEMA = DATABASE()
              AND TABLE_NAME = 'contactitems_tbl'
        </cfquery>
<cfif structKeyExists(request,"perfSvcQueryCount")><cfset request.perfSvcQueryCount++></cfif>
        <cfset result.base_tables.contactitems_tbl = qCheckItemsTbl.recordCount gt 0>

        <!--- Both contactdetails and contactitems must exist (as views or tables) --->
        <cfif result.tables.contactdetails and result.tables.contactitems>
            <cfset result.available = true>
            <cfset var typeInfo = []>
            <cfif structKeyExists(result.table_types, "contactdetails")>
                <cfset arrayAppend(typeInfo, "contactdetails=" & result.table_types.contactdetails)>
            </cfif>
            <cfif structKeyExists(result.table_types, "contactitems")>
                <cfset arrayAppend(typeInfo, "contactitems=" & result.table_types.contactitems)>
            </cfif>
            <cfset result.reason = "Objects available in schema [" & result.schema & "]: " & arrayToList(typeInfo, ", ")>

            <!--- Log if views are being used (expected in TAO) --->
            <cfif structKeyExists(result.table_types, "contactdetails") and result.table_types.contactdetails eq "VIEW">
                <cflog file="importv3" text="DupeService: contactdetails is VIEW, indexes on contactdetails_tbl base_table_exists=#result.base_tables.contactdetails_tbl#">
            </cfif>
            <cfif structKeyExists(result.table_types, "contactitems") and result.table_types.contactitems eq "VIEW">
                <cflog file="importv3" text="DupeService: contactitems is VIEW, indexes on contactitems_tbl base_table_exists=#result.base_tables.contactitems_tbl#">
            </cfif>
        <cfelse>
            <cfset var missing = []>
            <cfif not result.tables.contactdetails>
                <cfset arrayAppend(missing, "contactdetails")>
            </cfif>
            <cfif not result.tables.contactitems>
                <cfset arrayAppend(missing, "contactitems")>
            </cfif>
            <cfset result.reason = "Missing tables/views in schema [" & result.schema & "]: " & arrayToList(missing, ", ")>
        </cfif>

        <cfcatch type="any">
            <cfset result.available = false>
            <cfset result.reason = "Table check failed: " & cfcatch.message>
            <cflog file="importv3" text="DupeService.isDupeDetectionAvailable ERROR: #cfcatch.message#">
        </cfcatch>
    </cftry>

    <cfreturn result>
</cffunction>

<!--- ========================================
      PHASE 4: BATCH DUPE INDEX METHODS
      Build in-memory index once per job, lookup in O(1)
     ======================================== --->

<cffunction name="buildUserDupeIndex" access="public" returntype="struct" output="false"
    hint="Build in-memory dupe index for a user (one-time per job)">
    <cfargument name="userid" type="numeric" required="true">
    <cfargument name="metricsRef" type="struct" required="false" default="#{}#">

    <cfset var startTime = getTickCount()>
    <cfset var result = {
        "email_map": {},
        "phone_map": {},
        "build_ms": 0,
        "items_total": 0,
        "contactids_total": 0,
        "abort_reason": ""
    }>

    <cftry>
        <!--- Track query count --->
        <cfif structKeyExists(arguments.metricsRef, "dupe_queries_total")>
            <cfset arguments.metricsRef.dupe_queries_total++>
        </cfif>

        <!--- Single query to fetch all Email/Phone items for this user --->
        <cfquery name="qItems" datasource="#application.datasource#" timeout="30">
            SELECT ci.contactid, ci.valueCategory, ci.valuetext
            FROM contactitems ci
            INNER JOIN contactdetails d ON d.contactid = ci.contactid
            WHERE d.userid = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.userid#">
              AND (d.isdeleted IS NULL OR d.isdeleted = 0)
              AND ci.itemStatus = 'Active'
              AND (ci.isDeleted IS NULL OR ci.isDeleted = 0)
              AND ci.valueCategory IN ('Email', 'Phone')
        </cfquery>
<cfif structKeyExists(request,"perfSvcQueryCount")><cfset request.perfSvcQueryCount++></cfif>

        <cfset result.items_total = qItems.recordCount>

        <!--- Phase 4.1: Check items ceiling before building index --->
        <cfif result.items_total gt this.MAX_DUPE_INDEX_ITEMS>
            <cfset result.build_ms = getTickCount() - startTime>
            <cfset result.abort_reason = "items_exceeded">
            <cflog file="importv3" text="DupeService.buildUserDupeIndex ABORT userid=#arguments.userid# items=#result.items_total# exceeds max=#this.MAX_DUPE_INDEX_ITEMS#">
            <cfreturn result>
        </cfif>

        <!--- Build maps: normalized_value -> [contactid1, contactid2, ...] --->
        <cfset var uniqueContactIds = {}>
        <cfset var rowCount = 0>
        <cfset var checkpointInterval = 10000>

        <cfloop query="qItems">
            <cfset rowCount++>

            <!--- Phase 4.1: Periodic timeout check --->
            <cfif rowCount mod checkpointInterval eq 0>
                <cfset var elapsedMs = getTickCount() - startTime>
                <cfif elapsedMs gt this.MAX_DUPE_INDEX_BUILD_MS>
                    <cfset result.build_ms = elapsedMs>
                    <cfset result.contactids_total = structCount(uniqueContactIds)>
                    <cfset result.abort_reason = "timeout">
                    <cflog file="importv3" text="DupeService.buildUserDupeIndex ABORT userid=#arguments.userid# timeout at row=#rowCount# elapsed=#elapsedMs#ms max=#this.MAX_DUPE_INDEX_BUILD_MS#ms">
                    <cfreturn result>
                </cfif>
            </cfif>

            <cfset var contactId = qItems.contactid>
            <cfset uniqueContactIds[contactId] = true>

            <!--- Phase 4.1: Check contactids ceiling --->
            <cfif structCount(uniqueContactIds) gt this.MAX_DUPE_INDEX_CONTACTIDS>
                <cfset result.build_ms = getTickCount() - startTime>
                <cfset result.contactids_total = structCount(uniqueContactIds)>
                <cfset result.abort_reason = "contactids_exceeded">
                <cflog file="importv3" text="DupeService.buildUserDupeIndex ABORT userid=#arguments.userid# contactids=#structCount(uniqueContactIds)# exceeds max=#this.MAX_DUPE_INDEX_CONTACTIDS#">
                <cfreturn result>
            </cfif>

            <cfif qItems.valueCategory eq "Email">
                <cfset var normalizedEmail = normalizeEmail(qItems.valuetext)>
                <cfif len(normalizedEmail)>
                    <cfif not structKeyExists(result.email_map, normalizedEmail)>
                        <cfset result.email_map[normalizedEmail] = []>
                    </cfif>
                    <!--- Add contactId if not already in array --->
                    <cfif not arrayFind(result.email_map[normalizedEmail], contactId)>
                        <cfset arrayAppend(result.email_map[normalizedEmail], contactId)>
                    </cfif>
                </cfif>
            <cfelseif qItems.valueCategory eq "Phone">
                <cfset var normalizedPhone = normalizePhone(qItems.valuetext)>
                <cfif len(normalizedPhone)>
                    <cfif not structKeyExists(result.phone_map, normalizedPhone)>
                        <cfset result.phone_map[normalizedPhone] = []>
                    </cfif>
                    <!--- Add contactId if not already in array --->
                    <cfif not arrayFind(result.phone_map[normalizedPhone], contactId)>
                        <cfset arrayAppend(result.phone_map[normalizedPhone], contactId)>
                    </cfif>
                </cfif>
            </cfif>
        </cfloop>

        <cfset result.contactids_total = structCount(uniqueContactIds)>
        <cfset result.build_ms = getTickCount() - startTime>

        <!--- Track metrics --->
        <cfif structKeyExists(arguments.metricsRef, "dupe_index_build_ms")>
            <cfset arguments.metricsRef.dupe_index_build_ms = result.build_ms>
        </cfif>
        <cfif structKeyExists(arguments.metricsRef, "dupe_index_items_total")>
            <cfset arguments.metricsRef.dupe_index_items_total = result.items_total>
        </cfif>
        <cfif structKeyExists(arguments.metricsRef, "dupe_index_contactids_total")>
            <cfset arguments.metricsRef.dupe_index_contactids_total = result.contactids_total>
        </cfif>

        <cflog file="importv3" text="DupeService.buildUserDupeIndex userid=#arguments.userid# items=#result.items_total# contacts=#result.contactids_total# emails=#structCount(result.email_map)# phones=#structCount(result.phone_map)# ms=#result.build_ms#">

        <cfcatch type="any">
            <cfset result.build_ms = getTickCount() - startTime>
            <cfset result.abort_reason = "exception">
            <cfset result.error = cfcatch.message>
            <cflog file="importv3" text="DupeService.buildUserDupeIndex ERROR userid=#arguments.userid# err=#cfcatch.message#">
        </cfcatch>
    </cftry>

    <cfreturn result>
</cffunction>


<cffunction name="getCandidateContactIdsFromIndex" access="public" returntype="array" output="false"
    hint="Get candidate contactids from in-memory index (pure CFML, no DB)">
    <cfargument name="dupeIndex" type="struct" required="true">
    <cfargument name="emails" type="array" required="true">
    <cfargument name="phones" type="array" required="true">
    <cfargument name="metricsRef" type="struct" required="false" default="#{}#">

    <cfset var result = []>
    <cfset var seen = {}>

    <!--- Lookup emails in index --->
    <cfloop array="#arguments.emails#" index="email">
        <cfset var ne = normalizeEmail(email)>
        <cfif len(ne) and structKeyExists(arguments.dupeIndex.email_map, ne)>
            <cfloop array="#arguments.dupeIndex.email_map[ne]#" index="contactId">
                <cfif not structKeyExists(seen, contactId)>
                    <cfset arrayAppend(result, contactId)>
                    <cfset seen[contactId] = true>
                </cfif>
            </cfloop>
        </cfif>
    </cfloop>

    <!--- Lookup phones in index --->
    <cfloop array="#arguments.phones#" index="phone">
        <cfset var np = normalizePhone(phone)>
        <cfif len(np) and structKeyExists(arguments.dupeIndex.phone_map, np)>
            <cfloop array="#arguments.dupeIndex.phone_map[np]#" index="contactId">
                <cfif not structKeyExists(seen, contactId)>
                    <cfset arrayAppend(result, contactId)>
                    <cfset seen[contactId] = true>
                </cfif>
            </cfloop>
        </cfif>
    </cfloop>

    <!--- Limit to 100 candidates max --->
    <cfif arrayLen(result) gt 100>
        <cfset result = arraySlice(result, 1, 100)>
    </cfif>

    <cfreturn result>
</cffunction>


<cffunction name="getCandidateDetailsBatch" access="public" returntype="struct" output="false"
    hint="Batch fetch contact details for multiple contactids (for Phase 4 batch mode)">
    <cfargument name="userid" type="numeric" required="true">
    <cfargument name="contactIds" type="array" required="true">
    <cfargument name="metricsRef" type="struct" required="false" default="#{}#">

    <!--- Returns struct keyed by contactid with details and items --->
    <cfset var result = {}>

    <cfif arrayLen(arguments.contactIds) eq 0>
        <cfreturn result>
    </cfif>

    <cftry>

    <!--- Track query count --->
    <cfif structKeyExists(arguments.metricsRef, "dupe_queries_total")>
        <cfset arguments.metricsRef.dupe_queries_total++>
    </cfif>

    <!--- Query 1: Get contact details --->
    <cfquery name="qDetails" datasource="#application.datasource#" timeout="10">
        SELECT contactid, contactFullName, recordname
        FROM contactdetails
        WHERE userid = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.userid#">
          AND (isdeleted IS NULL OR isdeleted = 0)
          AND contactid IN (
            <cfloop from="1" to="#arrayLen(arguments.contactIds)#" index="i">
                <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.contactIds[i]#"><cfif i lt arrayLen(arguments.contactIds)>,</cfif>
            </cfloop>
          )
    </cfquery>
<cfif structKeyExists(request,"perfSvcQueryCount")><cfset request.perfSvcQueryCount++></cfif>

    <!--- Initialize result struct --->
    <cfloop query="qDetails">
        <cfset result[qDetails.contactid] = {
            contactid: qDetails.contactid,
            contactFullName: qDetails.contactFullName,
            recordname: len(qDetails.recordname) ? qDetails.recordname : qDetails.contactFullName,
            emails: [],
            phones: [],
            company: "",
            city: ""
        }>
    </cfloop>

    <!--- Track query count --->
    <cfif structKeyExists(arguments.metricsRef, "dupe_queries_total")>
        <cfset arguments.metricsRef.dupe_queries_total++>
    </cfif>

    <!--- Query 2: Get relevant items for all candidates at once --->
    <cfquery name="qItems" datasource="#application.datasource#" timeout="10">
        SELECT contactid, valueCategory, valuetext, valueCompany, valueCity
        FROM contactitems
        WHERE contactid IN (
            <cfloop from="1" to="#arrayLen(arguments.contactIds)#" index="i">
                <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.contactIds[i]#"><cfif i lt arrayLen(arguments.contactIds)>,</cfif>
            </cfloop>
          )
          AND itemStatus = 'Active'
          AND (isDeleted IS NULL OR isDeleted = 0)
          AND valueCategory IN ('Email', 'Phone', 'Company', 'Address')
    </cfquery>
<cfif structKeyExists(request,"perfSvcQueryCount")><cfset request.perfSvcQueryCount++></cfif>

    <!--- Populate items into result struct --->
    <cfloop query="qItems">
        <cfif structKeyExists(result, qItems.contactid)>
            <cfswitch expression="#qItems.valueCategory#">
                <cfcase value="Email">
                    <cfset arrayAppend(result[qItems.contactid].emails, normalizeEmail(qItems.valuetext))>
                </cfcase>
                <cfcase value="Phone">
                    <cfset arrayAppend(result[qItems.contactid].phones, normalizePhone(qItems.valuetext))>
                </cfcase>
                <cfcase value="Company">
                    <cfif len(qItems.valueCompany) and not len(result[qItems.contactid].company)>
                        <cfset result[qItems.contactid].company = lcase(trim(qItems.valueCompany))>
                    </cfif>
                </cfcase>
                <cfcase value="Address">
                    <cfif len(qItems.valueCity) and not len(result[qItems.contactid].city)>
                        <cfset result[qItems.contactid].city = lcase(trim(qItems.valueCity))>
                    </cfif>
                </cfcase>
            </cfswitch>
        </cfif>
    </cfloop>

    <cfcatch type="any">
        <cflog file="importv3_debug" text="[ImportV3] getCandidateDetailsBatch FAIL userid=#arguments.userid# contactIds_count=#arrayLen(arguments.contactIds)# error=#cfcatch.message# detail=#cfcatch.detail#" type="error">
        <!--- Return partial result (whatever was populated before the error) --->
    </cfcatch>
    </cftry>

    <cfreturn result>
</cffunction>


<cffunction name="findDuplicatesWithIndex" access="public" returntype="struct" output="false"
    hint="Find duplicates using pre-built index (Phase 4: O(1) lookup per row)">
    <cfargument name="userid" type="numeric" required="true">
    <cfargument name="rowData" type="struct" required="true">
    <cfargument name="dupeIndex" type="struct" required="true">
    <cfargument name="candidateDetailsCache" type="struct" required="true">
    <cfargument name="threshold" type="numeric" required="false" default="#this.THRESHOLD_LOW#">
    <cfargument name="metricsRef" type="struct" required="false" default="#{}#">

    <cfset var dupeStartTime = getTickCount()>

    <cfset var result = {
        hasDuplicate: false,
        bestMatchScore: 0,
        bestMatchContactId: 0,
        candidates: [],
        candidateIdsToFetch: []
    }>

    <!--- Extract searchable fields from row data --->
    <cfset var emails = []>
    <cfset var phones = []>
    <cfset var firstName = "">
    <cfset var lastName = "">
    <cfset var fullName = "">
    <cfset var company = "">
    <cfset var city = "">

    <!--- Collect emails --->
    <cfif structKeyExists(arguments.rowData, "email_business") and len(arguments.rowData.email_business)>
        <cfset arrayAppend(emails, arguments.rowData.email_business)>
    </cfif>
    <cfif structKeyExists(arguments.rowData, "email_personal") and len(arguments.rowData.email_personal)>
        <cfset arrayAppend(emails, arguments.rowData.email_personal)>
    </cfif>

    <!--- Collect phones --->
    <cfif structKeyExists(arguments.rowData, "phone_work") and len(arguments.rowData.phone_work)>
        <cfset arrayAppend(phones, arguments.rowData.phone_work)>
    </cfif>
    <cfif structKeyExists(arguments.rowData, "phone_mobile") and len(arguments.rowData.phone_mobile)>
        <cfset arrayAppend(phones, arguments.rowData.phone_mobile)>
    </cfif>
    <cfif structKeyExists(arguments.rowData, "phone_home") and len(arguments.rowData.phone_home)>
        <cfset arrayAppend(phones, arguments.rowData.phone_home)>
    </cfif>

    <!--- Extract other fields for scoring --->
    <cfif structKeyExists(arguments.rowData, "firstName")>
        <cfset firstName = trim(arguments.rowData.firstName)>
    </cfif>
    <cfif structKeyExists(arguments.rowData, "lastName")>
        <cfset lastName = trim(arguments.rowData.lastName)>
    </cfif>
    <cfif structKeyExists(arguments.rowData, "contactFullName")>
        <cfset fullName = trim(arguments.rowData.contactFullName)>
    </cfif>
    <cfif structKeyExists(arguments.rowData, "company")>
        <cfset company = lcase(trim(arguments.rowData.company))>
    </cfif>
    <cfif structKeyExists(arguments.rowData, "address_city")>
        <cfset city = lcase(trim(arguments.rowData.address_city))>
    </cfif>

    <!--- Build full name if not provided --->
    <cfif not len(fullName) and (len(firstName) or len(lastName))>
        <cfset fullName = trim(firstName & " " & lastName)>
    </cfif>
    <cfset var normalizedFullName = normalizeName(fullName)>

    <!--- Normalize search keys for matching --->
    <cfset var normalizedEmails = []>
    <cfset var normalizedPhones = []>
    <cfloop array="#emails#" index="e">
        <cfset var ne = normalizeEmail(e)>
        <cfif len(ne) and not arrayFind(normalizedEmails, ne)>
            <cfset arrayAppend(normalizedEmails, ne)>
        </cfif>
    </cfloop>
    <cfloop array="#phones#" index="p">
        <cfset var np = normalizePhone(p)>
        <cfif len(np) and not arrayFind(normalizedPhones, np)>
            <cfset arrayAppend(normalizedPhones, np)>
        </cfif>
    </cfloop>

    <!--- Track if row has keys for metrics --->
    <cfset var hasKeys = arrayLen(normalizedEmails) gt 0 or arrayLen(normalizedPhones) gt 0>
    <cfif structKeyExists(arguments.metricsRef, "dupe_rows_with_keys") and hasKeys>
        <cfset arguments.metricsRef.dupe_rows_with_keys++>
    </cfif>

    <!--- PHASE 4: Use in-memory index lookup (O(1)) --->
    <cfset var candidateIds = []>

    <cfif hasKeys>
        <!--- O(1) lookup from pre-built index --->
        <cfset candidateIds = getCandidateContactIdsFromIndex(arguments.dupeIndex, emails, phones, arguments.metricsRef)>

        <cfif structKeyExists(arguments.metricsRef, "dupe_candidates_total")>
            <cfset arguments.metricsRef.dupe_candidates_total += arrayLen(candidateIds)>
        </cfif>
    </cfif>

    <!--- Collect candidateIds that need to be fetched (not already in cache) --->
    <cfloop array="#candidateIds#" index="cid">
        <cfif not structKeyExists(arguments.candidateDetailsCache, cid)>
            <cfset arrayAppend(result.candidateIdsToFetch, cid)>
        </cfif>
    </cfloop>

    <!--- If there are candidates but we don't have their details yet, return early --->
    <!--- The caller will batch-fetch and call again with populated cache --->
    <cfif arrayLen(result.candidateIdsToFetch) gt 0>
        <cfreturn result>
    </cfif>

    <!--- Score candidates using cached details --->
    <cfset var allCandidates = {}>

    <cfloop array="#candidateIds#" index="contactId">
        <cfif structKeyExists(arguments.candidateDetailsCache, contactId)>
            <cfset var contact = arguments.candidateDetailsCache[contactId]>
            <cfset var score = 0>
            <cfset var reasons = []>
            <cfset var matchedFields = {}>

            <!--- Email match (50 points) --->
            <cfloop array="#normalizedEmails#" index="searchEmail">
                <cfif arrayFind(contact.emails, searchEmail)>
                    <cfset score += 50>
                    <cfset arrayAppend(reasons, "email matches")>
                    <cfset matchedFields["email"] = searchEmail>
                    <cfbreak>
                </cfif>
            </cfloop>

            <!--- Phone match (40 points) --->
            <cfloop array="#normalizedPhones#" index="searchPhone">
                <cfif arrayFind(contact.phones, searchPhone)>
                    <cfset score += 40>
                    <cfset arrayAppend(reasons, "phone matches")>
                    <cfset matchedFields["phone"] = searchPhone>
                    <cfbreak>
                </cfif>
            </cfloop>

            <!--- Name match (30 points) --->
            <cfif len(normalizedFullName)>
                <cfset var contactNormalizedName = normalizeName(contact.contactFullName)>
                <cfset var contactNormalizedRecord = normalizeName(contact.recordname)>
                <cfif normalizedFullName eq contactNormalizedName or normalizedFullName eq contactNormalizedRecord>
                    <cfset score += 30>
                    <cfset arrayAppend(reasons, "name matches")>
                    <cfset matchedFields["name"] = fullName>
                </cfif>
            </cfif>

            <!--- Name + Company match (25 points) --->
            <cfif len(normalizedFullName) and len(company) and len(contact.company)>
                <cfset var contactNormalizedName2 = normalizeName(contact.contactFullName)>
                <cfif (normalizedFullName eq contactNormalizedName2) and (company eq contact.company)>
                    <cfset score += 25>
                    <cfset arrayAppend(reasons, "name+company matches")>
                    <cfset matchedFields["name+company"] = fullName & " @ " & company>
                </cfif>
            </cfif>

            <!--- Name + City match (15 points) --->
            <cfif len(normalizedFullName) and len(city) and len(contact.city)>
                <cfset var contactNormalizedName3 = normalizeName(contact.contactFullName)>
                <cfif (normalizedFullName eq contactNormalizedName3) and (city eq contact.city)>
                    <cfset score += 15>
                    <cfset arrayAppend(reasons, "name+city matches")>
                    <cfset matchedFields["name+city"] = fullName & " in " & city>
                </cfif>
            </cfif>

            <!--- Add to candidates if above threshold --->
            <cfif score gte arguments.threshold>
                <cfset allCandidates[contactId] = {
                    contactid: contact.contactid,
                    contactFullName: contact.contactFullName,
                    recordname: contact.recordname,
                    score: score,
                    reasons: reasons,
                    matchedFields: matchedFields
                }>
            </cfif>
        </cfif>
    </cfloop>

    <!--- Convert to sorted array --->
    <cfset var sortedCandidates = []>
    <cfloop collection="#allCandidates#" item="cid">
        <cfset arrayAppend(sortedCandidates, allCandidates[cid])>
    </cfloop>

    <!--- Sort by score descending --->
    <cfset arraySort(sortedCandidates, function(a, b) {
        return b.score - a.score;
    })>

    <!--- Limit to top N --->
    <cfif arrayLen(sortedCandidates) gt this.MAX_CANDIDATES>
        <cfset sortedCandidates = arraySlice(sortedCandidates, 1, this.MAX_CANDIDATES)>
    </cfif>

    <!--- Set result --->
    <cfset result.candidates = sortedCandidates>
    <cfif arrayLen(sortedCandidates) gt 0>
        <cfset result.hasDuplicate = true>
        <cfset result.bestMatchScore = sortedCandidates[1].score>
        <cfset result.bestMatchContactId = sortedCandidates[1].contactid>
    </cfif>

    <cfreturn result>
</cffunction>


<!--- ========================================
      CANDIDATE LOOKUP METHODS (Phase 3 optimization)
     ======================================== --->

<cffunction name="getCandidateContactIds" access="public" returntype="array" output="false"
    hint="Get candidate contactids matching any email or phone in one query">
    <cfargument name="userid" type="numeric" required="true">
    <cfargument name="emails" type="array" required="true">
    <cfargument name="phones" type="array" required="true">
    <cfargument name="metricsRef" type="struct" required="false" default="#{}#">

    <cfset var result = []>
    <cfset var normalizedEmails = []>
    <cfset var normalizedPhones = []>

    <!--- Normalize and filter empty values --->
    <cfloop array="#arguments.emails#" index="e">
        <cfset var ne = normalizeEmail(e)>
        <cfif len(ne) and not arrayFind(normalizedEmails, ne)>
            <cfset arrayAppend(normalizedEmails, ne)>
        </cfif>
    </cfloop>
    <cfloop array="#arguments.phones#" index="p">
        <cfset var np = normalizePhone(p)>
        <cfif len(np) and not arrayFind(normalizedPhones, np)>
            <cfset arrayAppend(normalizedPhones, np)>
        </cfif>
    </cfloop>

    <!--- If no keys, return empty without hitting DB --->
    <cfif arrayLen(normalizedEmails) eq 0 and arrayLen(normalizedPhones) eq 0>
        <cfreturn result>
    </cfif>

    <!--- Track query count --->
    <cfif structKeyExists(arguments.metricsRef, "dupe_queries_total")>
        <cfset arguments.metricsRef.dupe_queries_total++>
    </cfif>

    <!--- Single query to find all matching contactids --->
    <!--- Note: MySQL default collation (utf8_general_ci) is case-insensitive, so no LOWER() needed for email.
          Phone matching still requires REPLACE() since stored values have formatting - index helps filter first. --->
    <cfquery name="qCandidates" datasource="#application.datasource#" timeout="10">
        SELECT DISTINCT ci.contactid
        FROM contactitems ci
        INNER JOIN contactdetails d ON d.contactid = ci.contactid
        WHERE d.userid = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.userid#">
          AND (d.isdeleted IS NULL OR d.isdeleted = 0)
          AND ci.itemStatus = 'Active'
          AND (ci.isDeleted IS NULL OR ci.isDeleted = 0)
          AND (
            <cfif arrayLen(normalizedEmails) gt 0>
                (ci.valueCategory = 'Email' AND ci.valuetext IN (
                    <cfloop from="1" to="#arrayLen(normalizedEmails)#" index="i">
                        <cfqueryparam cfsqltype="cf_sql_varchar" value="#normalizedEmails[i]#"><cfif i lt arrayLen(normalizedEmails)>,</cfif>
                    </cfloop>
                ))
            </cfif>
            <cfif arrayLen(normalizedEmails) gt 0 and arrayLen(normalizedPhones) gt 0> OR </cfif>
            <cfif arrayLen(normalizedPhones) gt 0>
                (ci.valueCategory = 'Phone' AND REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(ci.valuetext, ' ', ''), '-', ''), '(', ''), ')', ''), '+', '') IN (
                    <cfloop from="1" to="#arrayLen(normalizedPhones)#" index="i">
                        <cfqueryparam cfsqltype="cf_sql_varchar" value="#normalizedPhones[i]#"><cfif i lt arrayLen(normalizedPhones)>,</cfif>
                    </cfloop>
                ))
            </cfif>
          )
        LIMIT 100
    </cfquery>
<cfif structKeyExists(request,"perfSvcQueryCount")><cfset request.perfSvcQueryCount++></cfif>

    <!--- Convert to array --->
    <cfloop query="qCandidates">
        <cfset arrayAppend(result, qCandidates.contactid)>
    </cfloop>

    <cfreturn result>
</cffunction>


<cffunction name="getCandidateContacts" access="public" returntype="struct" output="false"
    hint="Get contact details and items for candidate contactids">
    <cfargument name="userid" type="numeric" required="true">
    <cfargument name="contactIds" type="array" required="true">
    <cfargument name="metricsRef" type="struct" required="false" default="#{}#">

    <!--- Returns struct keyed by contactid with details and items --->
    <cfset var result = {}>

    <cfif arrayLen(arguments.contactIds) eq 0>
        <cfreturn result>
    </cfif>

    <!--- Track query count --->
    <cfif structKeyExists(arguments.metricsRef, "dupe_queries_total")>
        <cfset arguments.metricsRef.dupe_queries_total++>
    </cfif>

    <!--- Query 1: Get contact details --->
    <cfquery name="qDetails" datasource="#application.datasource#" timeout="10">
        SELECT contactid, contactFullName, recordname
        FROM contactdetails
        WHERE userid = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.userid#">
          AND (isdeleted IS NULL OR isdeleted = 0)
          AND contactid IN (
            <cfloop from="1" to="#arrayLen(arguments.contactIds)#" index="i">
                <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.contactIds[i]#"><cfif i lt arrayLen(arguments.contactIds)>,</cfif>
            </cfloop>
          )
    </cfquery>
<cfif structKeyExists(request,"perfSvcQueryCount")><cfset request.perfSvcQueryCount++></cfif>

    <!--- Initialize result struct --->
    <cfloop query="qDetails">
        <cfset result[qDetails.contactid] = {
            contactid: qDetails.contactid,
            contactFullName: qDetails.contactFullName,
            recordname: len(qDetails.recordname) ? qDetails.recordname : qDetails.contactFullName,
            emails: [],
            phones: [],
            company: "",
            city: ""
        }>
    </cfloop>

    <!--- Track query count --->
    <cfif structKeyExists(arguments.metricsRef, "dupe_queries_total")>
        <cfset arguments.metricsRef.dupe_queries_total++>
    </cfif>

    <!--- Query 2: Get relevant items for all candidates at once --->
    <cfquery name="qItems" datasource="#application.datasource#" timeout="10">
        SELECT contactid, valueCategory, valuetext, valueCompany, valueCity
        FROM contactitems
        WHERE contactid IN (
            <cfloop from="1" to="#arrayLen(arguments.contactIds)#" index="i">
                <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.contactIds[i]#"><cfif i lt arrayLen(arguments.contactIds)>,</cfif>
            </cfloop>
          )
          AND itemStatus = 'Active'
          AND (isDeleted IS NULL OR isDeleted = 0)
          AND valueCategory IN ('Email', 'Phone', 'Company', 'Address')
    </cfquery>
<cfif structKeyExists(request,"perfSvcQueryCount")><cfset request.perfSvcQueryCount++></cfif>

    <!--- Populate items into result struct --->
    <cfloop query="qItems">
        <cfif structKeyExists(result, qItems.contactid)>
            <cfswitch expression="#qItems.valueCategory#">
                <cfcase value="Email">
                    <cfset arrayAppend(result[qItems.contactid].emails, normalizeEmail(qItems.valuetext))>
                </cfcase>
                <cfcase value="Phone">
                    <cfset arrayAppend(result[qItems.contactid].phones, normalizePhone(qItems.valuetext))>
                </cfcase>
                <cfcase value="Company">
                    <cfif len(qItems.valueCompany) and not len(result[qItems.contactid].company)>
                        <cfset result[qItems.contactid].company = lcase(trim(qItems.valueCompany))>
                    </cfif>
                </cfcase>
                <cfcase value="Address">
                    <cfif len(qItems.valueCity) and not len(result[qItems.contactid].city)>
                        <cfset result[qItems.contactid].city = lcase(trim(qItems.valueCity))>
                    </cfif>
                </cfcase>
            </cfswitch>
        </cfif>
    </cfloop>

    <cfreturn result>
</cffunction>


<cffunction name="getCandidatesByName" access="public" returntype="struct" output="false"
    hint="Fallback: Get candidates by name match (bounded query)">
    <cfargument name="userid" type="numeric" required="true">
    <cfargument name="fullName" type="string" required="true">
    <cfargument name="metricsRef" type="struct" required="false" default="#{}#">

    <cfset var result = {}>
    <cfset var normalizedName = normalizeName(arguments.fullName)>

    <cfif not len(normalizedName) or not this.ENABLE_NAME_FALLBACK>
        <cfreturn result>
    </cfif>

    <!--- Track query count --->
    <cfif structKeyExists(arguments.metricsRef, "dupe_queries_total")>
        <cfset arguments.metricsRef.dupe_queries_total++>
    </cfif>

    <!--- Bounded name search --->
    <cfquery name="qNameMatch" datasource="#application.datasource#" timeout="10">
        SELECT contactid, contactFullName, recordname
        FROM contactdetails
        WHERE userid = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.userid#">
          AND (isdeleted IS NULL OR isdeleted = 0)
          AND (
              LOWER(contactFullName) = <cfqueryparam cfsqltype="cf_sql_varchar" value="#normalizedName#">
              OR LOWER(recordname) = <cfqueryparam cfsqltype="cf_sql_varchar" value="#normalizedName#">
          )
        LIMIT <cfqueryparam cfsqltype="cf_sql_integer" value="#this.NAME_FALLBACK_LIMIT#">
    </cfquery>
<cfif structKeyExists(request,"perfSvcQueryCount")><cfset request.perfSvcQueryCount++></cfif>

    <!--- Build result struct --->
    <cfloop query="qNameMatch">
        <cfset result[qNameMatch.contactid] = {
            contactid: qNameMatch.contactid,
            contactFullName: qNameMatch.contactFullName,
            recordname: len(qNameMatch.recordname) ? qNameMatch.recordname : qNameMatch.contactFullName,
            emails: [],
            phones: [],
            company: "",
            city: ""
        }>
    </cfloop>

    <cfreturn result>
</cffunction>


<cffunction name="findDuplicatesSafe" access="public" returntype="struct" output="false"
    hint="Safe wrapper for findDuplicates - returns empty result on error instead of throwing">
    <cfargument name="userid" type="numeric" required="true">
    <cfargument name="rowData" type="struct" required="true">
    <cfargument name="threshold" type="numeric" required="false" default="#this.THRESHOLD_LOW#">
    <cfargument name="metricsRef" type="struct" required="false" default="#{}#">

    <cfset var result = {
        hasDuplicate: false,
        bestMatchScore: 0,
        bestMatchContactId: 0,
        candidates: [],
        error: "",
        hadError: false
    }>

    <cftry>
        <cfset var dupeResult = findDuplicates(arguments.userid, arguments.rowData, arguments.threshold, arguments.metricsRef)>
        <cfset result.hasDuplicate = dupeResult.hasDuplicate>
        <cfset result.bestMatchScore = dupeResult.bestMatchScore>
        <cfset result.bestMatchContactId = dupeResult.bestMatchContactId>
        <cfset result.candidates = dupeResult.candidates>

        <cfcatch type="any">
            <cfset result.hadError = true>
            <cfset result.error = cfcatch.message>
            <cflog file="importv3" text="DupeService.findDuplicatesSafe ERROR userid=#arguments.userid# err=#cfcatch.message#">
        </cfcatch>
    </cftry>

    <cfreturn result>
</cffunction>

<!--- ========================================
      MAIN MATCHING METHODS
     ======================================== --->

<cffunction name="findDuplicates" access="public" returntype="struct" output="false"
    hint="Find duplicate candidates for a contact row (Phase 3: optimized candidate lookup)">
    <cfargument name="userid" type="numeric" required="true">
    <cfargument name="rowData" type="struct" required="true">
    <cfargument name="threshold" type="numeric" required="false" default="#this.THRESHOLD_LOW#">
    <cfargument name="metricsRef" type="struct" required="false" default="#{}#">

    <cfset var dupeStartTime = getTickCount()>

    <cfset var result = {
        hasDuplicate: false,
        bestMatchScore: 0,
        bestMatchContactId: 0,
        candidates: []
    }>

    <!--- Extract searchable fields from row data --->
    <cfset var emails = []>
    <cfset var phones = []>
    <cfset var firstName = "">
    <cfset var lastName = "">
    <cfset var fullName = "">
    <cfset var company = "">
    <cfset var city = "">

    <!--- Collect emails --->
    <cfif structKeyExists(arguments.rowData, "email_business") and len(arguments.rowData.email_business)>
        <cfset arrayAppend(emails, arguments.rowData.email_business)>
    </cfif>
    <cfif structKeyExists(arguments.rowData, "email_personal") and len(arguments.rowData.email_personal)>
        <cfset arrayAppend(emails, arguments.rowData.email_personal)>
    </cfif>

    <!--- Collect phones --->
    <cfif structKeyExists(arguments.rowData, "phone_work") and len(arguments.rowData.phone_work)>
        <cfset arrayAppend(phones, arguments.rowData.phone_work)>
    </cfif>
    <cfif structKeyExists(arguments.rowData, "phone_mobile") and len(arguments.rowData.phone_mobile)>
        <cfset arrayAppend(phones, arguments.rowData.phone_mobile)>
    </cfif>
    <cfif structKeyExists(arguments.rowData, "phone_home") and len(arguments.rowData.phone_home)>
        <cfset arrayAppend(phones, arguments.rowData.phone_home)>
    </cfif>

    <!--- Extract other fields for scoring --->
    <cfif structKeyExists(arguments.rowData, "firstName")>
        <cfset firstName = trim(arguments.rowData.firstName)>
    </cfif>
    <cfif structKeyExists(arguments.rowData, "lastName")>
        <cfset lastName = trim(arguments.rowData.lastName)>
    </cfif>
    <cfif structKeyExists(arguments.rowData, "contactFullName")>
        <cfset fullName = trim(arguments.rowData.contactFullName)>
    </cfif>
    <cfif structKeyExists(arguments.rowData, "company")>
        <cfset company = lcase(trim(arguments.rowData.company))>
    </cfif>
    <cfif structKeyExists(arguments.rowData, "address_city")>
        <cfset city = lcase(trim(arguments.rowData.address_city))>
    </cfif>

    <!--- Build full name if not provided --->
    <cfif not len(fullName) and (len(firstName) or len(lastName))>
        <cfset fullName = trim(firstName & " " & lastName)>
    </cfif>
    <cfset var normalizedFullName = normalizeName(fullName)>

    <!--- Normalize search keys for matching --->
    <cfset var normalizedEmails = []>
    <cfset var normalizedPhones = []>
    <cfloop array="#emails#" index="e">
        <cfset var ne = normalizeEmail(e)>
        <cfif len(ne) and not arrayFind(normalizedEmails, ne)>
            <cfset arrayAppend(normalizedEmails, ne)>
        </cfif>
    </cfloop>
    <cfloop array="#phones#" index="p">
        <cfset var np = normalizePhone(p)>
        <cfif len(np) and not arrayFind(normalizedPhones, np)>
            <cfset arrayAppend(normalizedPhones, np)>
        </cfif>
    </cfloop>

    <!--- Track if row has keys for metrics --->
    <cfset var hasKeys = arrayLen(normalizedEmails) gt 0 or arrayLen(normalizedPhones) gt 0>
    <cfif structKeyExists(arguments.metricsRef, "dupe_rows_with_keys") and hasKeys>
        <cfset arguments.metricsRef.dupe_rows_with_keys++>
    </cfif>

    <!--- PHASE 3 OPTIMIZATION: Use candidate lookup strategy --->
    <cfset var candidateContacts = {}>

    <cfif hasKeys>
        <!--- Step 1: Get candidate contactids in one query --->
        <cfset var candidateIds = getCandidateContactIds(arguments.userid, emails, phones, arguments.metricsRef)>

        <!--- Step 2: If we have candidates, get their details --->
        <cfif arrayLen(candidateIds) gt 0>
            <cfset candidateContacts = getCandidateContacts(arguments.userid, candidateIds, arguments.metricsRef)>

            <!--- Track candidates checked --->
            <cfif structKeyExists(arguments.metricsRef, "dupe_candidates_total")>
                <cfset arguments.metricsRef.dupe_candidates_total += arrayLen(candidateIds)>
            </cfif>
        </cfif>
    <cfelseif len(normalizedFullName) and this.ENABLE_NAME_FALLBACK>
        <!--- No email/phone keys: fall back to bounded name search --->
        <cfset candidateContacts = getCandidatesByName(arguments.userid, fullName, arguments.metricsRef)>

        <cfif structKeyExists(arguments.metricsRef, "dupe_candidates_total")>
            <cfset arguments.metricsRef.dupe_candidates_total += structCount(candidateContacts)>
        </cfif>
    </cfif>

    <!--- Step 3: Score candidates in CFML --->
    <cfset var allCandidates = {}>

    <cfloop collection="#candidateContacts#" item="contactId">
        <cfset var contact = candidateContacts[contactId]>
        <cfset var score = 0>
        <cfset var reasons = []>
        <cfset var matchedFields = {}>

        <!--- Email match (50 points) --->
        <cfloop array="#normalizedEmails#" index="searchEmail">
            <cfif arrayFind(contact.emails, searchEmail)>
                <cfset score += 50>
                <cfset arrayAppend(reasons, "email matches")>
                <cfset matchedFields["email"] = searchEmail>
                <cfbreak>
            </cfif>
        </cfloop>

        <!--- Phone match (40 points) --->
        <cfloop array="#normalizedPhones#" index="searchPhone">
            <cfif arrayFind(contact.phones, searchPhone)>
                <cfset score += 40>
                <cfset arrayAppend(reasons, "phone matches")>
                <cfset matchedFields["phone"] = searchPhone>
                <cfbreak>
            </cfif>
        </cfloop>

        <!--- Name match (30 points) --->
        <cfif len(normalizedFullName)>
            <cfset var contactNormalizedName = normalizeName(contact.contactFullName)>
            <cfset var contactNormalizedRecord = normalizeName(contact.recordname)>
            <cfif normalizedFullName eq contactNormalizedName or normalizedFullName eq contactNormalizedRecord>
                <cfset score += 30>
                <cfset arrayAppend(reasons, "name matches")>
                <cfset matchedFields["name"] = fullName>
            </cfif>
        </cfif>

        <!--- Name + Company match (25 points) --->
        <cfif len(normalizedFullName) and len(company) and len(contact.company)>
            <cfset var contactNormalizedName2 = normalizeName(contact.contactFullName)>
            <cfif (normalizedFullName eq contactNormalizedName2) and (company eq contact.company)>
                <cfset score += 25>
                <cfset arrayAppend(reasons, "name+company matches")>
                <cfset matchedFields["name+company"] = fullName & " @ " & company>
            </cfif>
        </cfif>

        <!--- Name + City match (15 points) --->
        <cfif len(normalizedFullName) and len(city) and len(contact.city)>
            <cfset var contactNormalizedName3 = normalizeName(contact.contactFullName)>
            <cfif (normalizedFullName eq contactNormalizedName3) and (city eq contact.city)>
                <cfset score += 15>
                <cfset arrayAppend(reasons, "name+city matches")>
                <cfset matchedFields["name+city"] = fullName & " in " & city>
            </cfif>
        </cfif>

        <!--- Add to candidates if above threshold --->
        <cfif score gte arguments.threshold>
            <cfset allCandidates[contactId] = {
                contactid: contact.contactid,
                contactFullName: contact.contactFullName,
                recordname: contact.recordname,
                score: score,
                reasons: reasons,
                matchedFields: matchedFields
            }>
        </cfif>
    </cfloop>

    <!--- Convert to sorted array --->
    <cfset var sortedCandidates = []>
    <cfloop collection="#allCandidates#" item="cid">
        <cfset arrayAppend(sortedCandidates, allCandidates[cid])>
    </cfloop>

    <!--- Sort by score descending --->
    <cfset arraySort(sortedCandidates, function(a, b) {
        return b.score - a.score;
    })>

    <!--- Limit to top N --->
    <cfif arrayLen(sortedCandidates) gt this.MAX_CANDIDATES>
        <cfset sortedCandidates = arraySlice(sortedCandidates, 1, this.MAX_CANDIDATES)>
    </cfif>

    <!--- Set result --->
    <cfset result.candidates = sortedCandidates>
    <cfif arrayLen(sortedCandidates) gt 0>
        <cfset result.hasDuplicate = true>
        <cfset result.bestMatchScore = sortedCandidates[1].score>
        <cfset result.bestMatchContactId = sortedCandidates[1].contactid>
    </cfif>

    <cfset var dupeElapsed = getTickCount() - dupeStartTime>
    <cflog file="importv3" text="DupeService.findDuplicates END userid=#arguments.userid# hasDupe=#result.hasDuplicate# candidates=#arrayLen(sortedCandidates)# elapsed=#dupeElapsed#ms">

    <cfreturn result>
</cffunction>


<cffunction name="findDuplicatesBatch" access="public" returntype="array" output="false"
    hint="Find duplicates for multiple rows">
    <cfargument name="userid" type="numeric" required="true">
    <cfargument name="rows" type="array" required="true">
    <cfargument name="threshold" type="numeric" required="false" default="#this.THRESHOLD_LOW#">

    <cfset var results = []>

    <cfloop array="#arguments.rows#" index="row">
        <cfset var dupeResult = findDuplicates(arguments.userid, row, arguments.threshold)>
        <cfset arrayAppend(results, dupeResult)>
    </cfloop>

    <cfreturn results>
</cffunction>


<!--- ========================================
      DATABASE LOOKUP METHODS
     ======================================== --->

<cffunction name="findByEmail" access="private" returntype="query" output="false"
    hint="Find contacts by email address">
    <cfargument name="userid" type="numeric" required="true">
    <cfargument name="email" type="string" required="true">
    <cfargument name="metricsRef" type="struct" required="false" default="#{}#">

    <cfif structKeyExists(arguments.metricsRef, "dupe_queries_total")>
        <cfset arguments.metricsRef.dupe_queries_total++>
    </cfif>
    <cfquery name="result" datasource="#application.datasource#" timeout="10">
        SELECT DISTINCT
            d.contactid,
            d.contactFullName,
            d.recordname,
            ci.valuetext AS matched_email
        FROM contactdetails d
        INNER JOIN contactitems ci ON ci.contactid = d.contactid
        WHERE d.userid = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.userid#">
          AND (d.isdeleted IS NULL OR d.isdeleted = 0)
          AND ci.valueCategory = 'Email'
          AND ci.itemStatus = 'Active'
          AND (ci.isDeleted IS NULL OR ci.isDeleted = 0)
          AND LOWER(ci.valuetext) = <cfqueryparam cfsqltype="cf_sql_varchar" value="#lcase(arguments.email)#">
    </cfquery>
<cfif structKeyExists(request,"perfSvcQueryCount")><cfset request.perfSvcQueryCount++></cfif>

    <cfreturn result>
</cffunction>


<cffunction name="findByPhone" access="private" returntype="query" output="false"
    hint="Find contacts by phone number (digits only)">
    <cfargument name="userid" type="numeric" required="true">
    <cfargument name="phone" type="string" required="true">
    <cfargument name="metricsRef" type="struct" required="false" default="#{}#">

    <!--- Phone should already be normalized to digits only --->
    <cfif structKeyExists(arguments.metricsRef, "dupe_queries_total")>
        <cfset arguments.metricsRef.dupe_queries_total++>
    </cfif>
    <cfquery name="result" datasource="#application.datasource#" timeout="10">
        SELECT DISTINCT
            d.contactid,
            d.contactFullName,
            d.recordname,
            ci.valuetext AS matched_phone
        FROM contactdetails d
        INNER JOIN contactitems ci ON ci.contactid = d.contactid
        WHERE d.userid = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.userid#">
          AND (d.isdeleted IS NULL OR d.isdeleted = 0)
          AND ci.valueCategory = 'Phone'
          AND ci.itemStatus = 'Active'
          AND (ci.isDeleted IS NULL OR ci.isDeleted = 0)
          AND REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(ci.valuetext, ' ', ''), '-', ''), '(', ''), ')', ''), '+', '') = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.phone#">
    </cfquery>
<cfif structKeyExists(request,"perfSvcQueryCount")><cfset request.perfSvcQueryCount++></cfif>

    <cfreturn result>
</cffunction>


<cffunction name="findByName" access="private" returntype="query" output="false"
    hint="Find contacts by name (exact match)">
    <cfargument name="userid" type="numeric" required="true">
    <cfargument name="fullName" type="string" required="true">
    <cfargument name="metricsRef" type="struct" required="false" default="#{}#">

    <cfif structKeyExists(arguments.metricsRef, "dupe_queries_total")>
        <cfset arguments.metricsRef.dupe_queries_total++>
    </cfif>
    <cfquery name="result" datasource="#application.datasource#" timeout="10">
        SELECT DISTINCT
            d.contactid,
            d.contactFullName,
            d.recordname
        FROM contactdetails d
        WHERE d.userid = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.userid#">
          AND (d.isdeleted IS NULL OR d.isdeleted = 0)
          AND (
              LOWER(d.contactFullName) = <cfqueryparam cfsqltype="cf_sql_varchar" value="#lcase(arguments.fullName)#">
              OR LOWER(d.recordname) = <cfqueryparam cfsqltype="cf_sql_varchar" value="#lcase(arguments.fullName)#">
          )
    </cfquery>
<cfif structKeyExists(request,"perfSvcQueryCount")><cfset request.perfSvcQueryCount++></cfif>

    <cfreturn result>
</cffunction>


<cffunction name="findByNameAndCompany" access="private" returntype="query" output="false"
    hint="Find contacts by name and company">
    <cfargument name="userid" type="numeric" required="true">
    <cfargument name="fullName" type="string" required="true">
    <cfargument name="company" type="string" required="true">
    <cfargument name="metricsRef" type="struct" required="false" default="#{}#">

    <cfif structKeyExists(arguments.metricsRef, "dupe_queries_total")>
        <cfset arguments.metricsRef.dupe_queries_total++>
    </cfif>
    <cfquery name="result" datasource="#application.datasource#" timeout="10">
        SELECT DISTINCT
            d.contactid,
            d.contactFullName,
            d.recordname,
            ci.valueCompany AS matched_company
        FROM contactdetails d
        INNER JOIN contactitems ci ON ci.contactid = d.contactid
        WHERE d.userid = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.userid#">
          AND (d.isdeleted IS NULL OR d.isdeleted = 0)
          AND ci.valueCategory = 'Company'
          AND ci.itemStatus = 'Active'
          AND (ci.isDeleted IS NULL OR ci.isDeleted = 0)
          AND (
              LOWER(d.contactFullName) = <cfqueryparam cfsqltype="cf_sql_varchar" value="#lcase(arguments.fullName)#">
              OR LOWER(d.recordname) = <cfqueryparam cfsqltype="cf_sql_varchar" value="#lcase(arguments.fullName)#">
          )
          AND LOWER(ci.valueCompany) = <cfqueryparam cfsqltype="cf_sql_varchar" value="#lcase(arguments.company)#">
    </cfquery>
<cfif structKeyExists(request,"perfSvcQueryCount")><cfset request.perfSvcQueryCount++></cfif>

    <cfreturn result>
</cffunction>


<cffunction name="findByNameAndCity" access="private" returntype="query" output="false"
    hint="Find contacts by name and city">
    <cfargument name="userid" type="numeric" required="true">
    <cfargument name="fullName" type="string" required="true">
    <cfargument name="city" type="string" required="true">
    <cfargument name="metricsRef" type="struct" required="false" default="#{}#">

    <cfif structKeyExists(arguments.metricsRef, "dupe_queries_total")>
        <cfset arguments.metricsRef.dupe_queries_total++>
    </cfif>
    <cfquery name="result" datasource="#application.datasource#" timeout="10">
        SELECT DISTINCT
            d.contactid,
            d.contactFullName,
            d.recordname,
            ci.valueCity AS matched_city
        FROM contactdetails d
        INNER JOIN contactitems ci ON ci.contactid = d.contactid
        WHERE d.userid = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.userid#">
          AND (d.isdeleted IS NULL OR d.isdeleted = 0)
          AND ci.valueCategory = 'Address'
          AND ci.itemStatus = 'Active'
          AND (ci.isDeleted IS NULL OR ci.isDeleted = 0)
          AND (
              LOWER(d.contactFullName) = <cfqueryparam cfsqltype="cf_sql_varchar" value="#lcase(arguments.fullName)#">
              OR LOWER(d.recordname) = <cfqueryparam cfsqltype="cf_sql_varchar" value="#lcase(arguments.fullName)#">
          )
          AND LOWER(ci.valueCity) = <cfqueryparam cfsqltype="cf_sql_varchar" value="#lcase(arguments.city)#">
    </cfquery>
<cfif structKeyExists(request,"perfSvcQueryCount")><cfset request.perfSvcQueryCount++></cfif>

    <cfreturn result>
</cffunction>


<!--- ========================================
      HELPER METHODS
     ======================================== --->

<cffunction name="addCandidate" access="private" returntype="void" output="false"
    hint="Add or update a candidate in the candidates struct">
    <cfargument name="candidates" type="struct" required="true">
    <cfargument name="contactid" type="numeric" required="true">
    <cfargument name="contactData" type="query" required="true">
    <cfargument name="matchType" type="string" required="true">
    <cfargument name="matchValue" type="string" required="true">
    <cfargument name="points" type="numeric" required="true">

    <cfset var key = arguments.contactid>

    <cfif structKeyExists(arguments.candidates, key)>
        <!--- Update existing candidate --->
        <cfset arguments.candidates[key].score += arguments.points>
        <cfset arrayAppend(arguments.candidates[key].reasons, arguments.matchType & " matches")>
        <cfset arguments.candidates[key].matchedFields[arguments.matchType] = arguments.matchValue>
    <cfelse>
        <!--- Add new candidate --->
        <cfset arguments.candidates[key] = {
            contactid: arguments.contactid,
            contactFullName: arguments.contactData.contactFullName,
            recordname: len(arguments.contactData.recordname) ? arguments.contactData.recordname : arguments.contactData.contactFullName,
            score: arguments.points,
            reasons: [arguments.matchType & " matches"],
            matchedFields: {}
        }>
        <cfset arguments.candidates[key].matchedFields[arguments.matchType] = arguments.matchValue>
    </cfif>
</cffunction>


<cffunction name="normalizePhoneForMatch" access="private" returntype="string" output="false"
    hint="Normalize phone to digits only for matching">
    <cfargument name="phone" type="string" required="true">

    <!--- Extract digits only --->
    <cfset var digits = reReplace(arguments.phone, "[^0-9]", "", "ALL")>

    <!--- Remove leading 1 from US numbers for matching --->
    <cfif len(digits) eq 11 and left(digits, 1) eq "1">
        <cfset digits = mid(digits, 2, 10)>
    </cfif>

    <cfreturn digits>
</cffunction>


<!--- ========================================
      CONTACT DETAIL LOOKUP
     ======================================== --->

<cffunction name="getContactDetails" access="public" returntype="struct" output="false"
    hint="Get full contact details for comparison display">
    <cfargument name="contactid" type="numeric" required="true">
    <cfargument name="userid" type="numeric" required="true">

    <cfset var result = {
        found: false,
        contactid: arguments.contactid,
        contactFullName: "",
        recordname: "",
        emails: [],
        phones: [],
        company: "",
        city: "",
        state: ""
    }>

    <!--- Get contact details --->
    <cfquery name="qContact" datasource="#application.datasource#" timeout="10">
        SELECT
            d.contactid,
            d.contactFullName,
            d.recordname
        FROM contactdetails d
        WHERE d.contactid = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.contactid#">
          AND d.userid = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.userid#">
          AND (d.isdeleted IS NULL OR d.isdeleted = 0)
    </cfquery>
<cfif structKeyExists(request,"perfSvcQueryCount")><cfset request.perfSvcQueryCount++></cfif>

    <cfif qContact.recordCount eq 0>
        <cfreturn result>
    </cfif>

    <cfset result.found = true>
    <cfset result.contactFullName = qContact.contactFullName>
    <cfset result.recordname = qContact.recordname>

    <!--- Get emails --->
    <cfquery name="qEmails" datasource="#application.datasource#" timeout="10">
        SELECT valuetext, valueType
        FROM contactitems
        WHERE contactid = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.contactid#">
          AND valueCategory = 'Email'
          AND itemStatus = 'Active'
          AND (isDeleted IS NULL OR isDeleted = 0)
    </cfquery>
<cfif structKeyExists(request,"perfSvcQueryCount")><cfset request.perfSvcQueryCount++></cfif>
    <cfloop query="qEmails">
        <cfset arrayAppend(result.emails, {value: qEmails.valuetext, type: qEmails.valueType})>
    </cfloop>

    <!--- Get phones --->
    <cfquery name="qPhones" datasource="#application.datasource#" timeout="10">
        SELECT valuetext, valueType
        FROM contactitems
        WHERE contactid = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.contactid#">
          AND valueCategory = 'Phone'
          AND itemStatus = 'Active'
          AND (isDeleted IS NULL OR isDeleted = 0)
    </cfquery>
<cfif structKeyExists(request,"perfSvcQueryCount")><cfset request.perfSvcQueryCount++></cfif>
    <cfloop query="qPhones">
        <cfset arrayAppend(result.phones, {value: qPhones.valuetext, type: qPhones.valueType})>
    </cfloop>

    <!--- Get company --->
    <cfquery name="qCompany" datasource="#application.datasource#" timeout="10">
        SELECT valueCompany, valueDepartment, valueTitle
        FROM contactitems
        WHERE contactid = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.contactid#">
          AND valueCategory = 'Company'
          AND itemStatus = 'Active'
          AND (isDeleted IS NULL OR isDeleted = 0)
          AND primary_yn = 'Y'
        LIMIT 1
    </cfquery>
<cfif structKeyExists(request,"perfSvcQueryCount")><cfset request.perfSvcQueryCount++></cfif>
    <cfif qCompany.recordCount gt 0>
        <cfset result.company = qCompany.valueCompany>
    </cfif>

    <!--- Get address --->
    <cfquery name="qAddress" datasource="#application.datasource#" timeout="10">
        SELECT valueCity, valueRegion
        FROM contactitems
        WHERE contactid = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.contactid#">
          AND valueCategory = 'Address'
          AND itemStatus = 'Active'
          AND (isDeleted IS NULL OR isDeleted = 0)
          AND primary_yn = 'Y'
        LIMIT 1
    </cfquery>
<cfif structKeyExists(request,"perfSvcQueryCount")><cfset request.perfSvcQueryCount++></cfif>
    <cfif qAddress.recordCount gt 0>
        <cfset result.city = qAddress.valueCity>
        <cfset result.state = qAddress.valueRegion>
    </cfif>

    <cfreturn result>
</cffunction>


<!--- ========================================
      SCORING CONFIGURATION
     ======================================== --->

<cffunction name="getMatchingRules" access="public" returntype="array" output="false"
    hint="Return the matching rules for documentation">

    <cfset var rules = [
        {
            name: "Email Match",
            field: "email",
            points: 50,
            description: "Exact match on email address (case-insensitive)"
        },
        {
            name: "Phone Match",
            field: "phone",
            points: 40,
            description: "Match on phone digits (ignores formatting)"
        },
        {
            name: "Name Match",
            field: "name",
            points: 30,
            description: "Exact match on full name or record name"
        },
        {
            name: "Name + Company",
            field: "name+company",
            points: 25,
            description: "Name matches and same company"
        },
        {
            name: "Name + City",
            field: "name+city",
            points: 15,
            description: "Name matches and same city"
        }
    ]>

    <cfreturn rules>
</cffunction>


<cffunction name="setThreshold" access="public" returntype="void" output="false"
    hint="Set the minimum score threshold for duplicate detection">
    <cfargument name="threshold" type="numeric" required="true">

    <cfset this.THRESHOLD_LOW = arguments.threshold>
</cffunction>


<cffunction name="getScoreDescription" access="public" returntype="string" output="false"
    hint="Get human-readable description of a match score">
    <cfargument name="score" type="numeric" required="true">

    <cfif arguments.score gte this.THRESHOLD_HIGH>
        <cfreturn "High confidence match">
    <cfelseif arguments.score gte this.THRESHOLD_MEDIUM>
        <cfreturn "Medium confidence match">
    <cfelseif arguments.score gte this.THRESHOLD_LOW>
        <cfreturn "Low confidence match">
    <cfelse>
        <cfreturn "Below threshold">
    </cfif>
</cffunction>

</cfcomponent>
