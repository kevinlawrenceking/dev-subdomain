<!---
    PURPOSE: Contact duplicate detection (report) and SAFE merge.
    AUTHOR:  Kevin King
    DATE:    2025-08-07
    REWRITE: 2026-06-25 - rebuilt against the VERIFIED schema.
             Old version queried non-existent columns (contactfirst/contactlast,
             cd.timestamp), a non-existent table (contactnotes), a wrong join
             (itemcategories ci.catid), and contained a data-corrupting merge
             (UPDATE events SET eventid = <contactid>). All removed.

    SCHEMA NOTES (verified):
      contactdetails(_tbl): contactid PK, userid, contactFullName, recordname,
        contacttitle, contactNickname, contactPronoun, contactBirthday,
        contactMeetingDate, contactMeetingLoc, refer_contact_id,
        newsletter_yn, googlealert_yn, socialmedia_yn, contactCreationDate,
        isdeleted.
      contactitems(_tbl): itemid PK, contactid, valueCategory ('Email'|'Phone'|
        'Company'|'Address'|'Tag'|...), valueType, valuetext, valueCompany,
        valueCity, itemStatus ('Active'...), primary_yn, isDeleted.
        Email/Phone are identified by valueCategory DIRECTLY (no itemcategory join).
      Child tables carrying contactid: contactitems_tbl, noteslog_tbl,
        eventcontactsxref_tbl, audcontacts_auditions_xref, fusystemusers_tbl.
        funotifications has NO contactid (links via suID -> fusystemusers), and
        actionusers is keyed by actionid+userid -- neither is repointed directly.

    DEPENDENCIES: application.datasource, EventService.fireIcsRegen,
                  contact_merge_log / contact_merge_map (2026-06-25 migration).
--->

<cfcomponent displayname="ContactDuplicateService" hint="Contact duplicate detection (report) and safe merge">

    <cffunction name="init" access="public" returntype="ContactDuplicateService">
        <cfreturn this />
    </cffunction>

    <!--- =====================================================================
          REPORT: FULL duplicates (high confidence)
          One row per match group. Match types: EMAIL, PHONE, NAME.
          Scoped to a single user.
         ===================================================================== --->
    <cffunction name="findFullDuplicates" access="public" returntype="query" output="false">
        <cfargument name="userid" type="numeric" required="true" />

        <cfquery name="qFull" datasource="#application.datasource#">
            -- a) Same EMAIL
            SELECT cd.userid,
                   'EMAIL'                       AS match_type,
                   LOWER(TRIM(ci.valuetext))     AS match_key,
                   COUNT(DISTINCT cd.contactid)  AS dupe_count,
                   GROUP_CONCAT(DISTINCT cd.contactid ORDER BY cd.contactid)                       AS contact_ids,
                   GROUP_CONCAT(DISTINCT cd.contactFullName ORDER BY cd.contactid SEPARATOR ' | ') AS names
            FROM   contactitems ci
            JOIN   contactdetails cd ON cd.contactid = ci.contactid
            WHERE  cd.userid     = <cfqueryparam value="#arguments.userid#" cfsqltype="cf_sql_integer" />
              AND  cd.isdeleted  = <cfqueryparam value="0" cfsqltype="cf_sql_bit" />
              AND  ci.itemStatus = 'Active'
              AND  ci.valueCategory = 'Email'
              AND  ci.valuetext LIKE '%@%'
              AND  TRIM(ci.valuetext) <> ''
            GROUP  BY cd.userid, LOWER(TRIM(ci.valuetext))
            HAVING COUNT(DISTINCT cd.contactid) > 1

            UNION ALL

            -- b) Same PHONE (digits only, last 10)
            SELECT cd.userid,
                   'PHONE',
                   RIGHT(REGEXP_REPLACE(ci.valuetext, '[^0-9]', ''), 10),
                   COUNT(DISTINCT cd.contactid),
                   GROUP_CONCAT(DISTINCT cd.contactid ORDER BY cd.contactid),
                   GROUP_CONCAT(DISTINCT cd.contactFullName ORDER BY cd.contactid SEPARATOR ' | ')
            FROM   contactitems ci
            JOIN   contactdetails cd ON cd.contactid = ci.contactid
            WHERE  cd.userid     = <cfqueryparam value="#arguments.userid#" cfsqltype="cf_sql_integer" />
              AND  cd.isdeleted  = <cfqueryparam value="0" cfsqltype="cf_sql_bit" />
              AND  ci.itemStatus = 'Active'
              AND  ci.valueCategory = 'Phone'
              AND  LENGTH(REGEXP_REPLACE(ci.valuetext, '[^0-9]', '')) >= 10
            GROUP  BY cd.userid, RIGHT(REGEXP_REPLACE(ci.valuetext, '[^0-9]', ''), 10)
            HAVING COUNT(DISTINCT cd.contactid) > 1

            UNION ALL

            -- c) Same NAME (trim, collapse spaces, lowercase)
            SELECT cd.userid,
                   'NAME',
                   LOWER(REGEXP_REPLACE(TRIM(cd.contactFullName), '\\s+', ' ')),
                   COUNT(*),
                   GROUP_CONCAT(cd.contactid ORDER BY cd.contactid),
                   GROUP_CONCAT(cd.contactFullName ORDER BY cd.contactid SEPARATOR ' | ')
            FROM   contactdetails cd
            WHERE  cd.userid    = <cfqueryparam value="#arguments.userid#" cfsqltype="cf_sql_integer" />
              AND  cd.isdeleted = <cfqueryparam value="0" cfsqltype="cf_sql_bit" />
              AND  TRIM(COALESCE(cd.contactFullName, '')) <> ''
            GROUP  BY cd.userid, LOWER(REGEXP_REPLACE(TRIM(cd.contactFullName), '\\s+', ' '))
            HAVING COUNT(*) > 1

            ORDER BY match_type, dupe_count DESC
        </cfquery>
<cfif structKeyExists(request,"perfSvcQueryCount")><cfset request.perfSvcQueryCount++></cfif>

        <cfreturn qFull />
    </cffunction>

    <!--- =====================================================================
          REPORT: POSSIBLE duplicates (review bucket)
          Slightly different names via SOUNDEX. Returned as contact pairs.
         ===================================================================== --->
    <cffunction name="findPossibleDuplicates" access="public" returntype="query" output="false">
        <cfargument name="userid" type="numeric" required="true" />

        <!--- SOUNDEX is only a CHEAP CANDIDATE PRE-FILTER. On its own it matched
              names that merely start with a similar sound (Josh Siegel <-> Jessica
              Kelly, Paul Hardt <-> Paul Ruddy, Nancy Nayor <-> Nike Imoru), which
              flooded the review list with false positives (ticket 5A). We keep the
              SOUNDEX join to bound the candidate set, then gate each pair on a real
              edit-distance similarity in CFML - same "SQL candidates + CFML score"
              pattern DuplicateMatcherService uses. This also avoids depending on a
              MySQL LEVENSHTEIN()/version we cannot assume. --->
        <cfquery name="qCandidates" datasource="#application.datasource#">
            SELECT a.userid,
                   a.contactid       AS id_a,
                   a.contactFullName AS name_a,
                   b.contactid       AS id_b,
                   b.contactFullName AS name_b
            FROM   contactdetails a
            JOIN   contactdetails b
                   ON  b.userid    = a.userid
                   AND b.contactid > a.contactid
            WHERE  a.userid    = <cfqueryparam value="#arguments.userid#" cfsqltype="cf_sql_integer" />
              AND  a.isdeleted = <cfqueryparam value="0" cfsqltype="cf_sql_bit" />
              AND  b.isdeleted = <cfqueryparam value="0" cfsqltype="cf_sql_bit" />
              AND  TRIM(COALESCE(a.contactFullName,'')) <> ''
              AND  TRIM(COALESCE(b.contactFullName,'')) <> ''
              AND  SOUNDEX(a.contactFullName) = SOUNDEX(b.contactFullName)
              AND  LOWER(REGEXP_REPLACE(TRIM(a.contactFullName), '\\s+', ' '))
                <> LOWER(REGEXP_REPLACE(TRIM(b.contactFullName), '\\s+', ' '))
            ORDER BY name_a
        </cfquery>
<cfif structKeyExists(request,"perfSvcQueryCount")><cfset request.perfSvcQueryCount++></cfif>

        <!--- Precise similarity gate. Keep a pair only when the two normalized
              full names are within a small edit distance AND share the same
              surname signature. That keeps genuine variants (Krystal O'Conner /
              Krystal OConnor) and drops different people who merely sound alike. --->
        <cfset var qPossible = queryNew("userid,id_a,name_a,id_b,name_b,match_score",
                                        "integer,integer,varchar,integer,varchar,integer") />
        <cfset var na = "" />
        <cfset var nb = "" />
        <cfset var dist = 0 />
        <cfset var maxLen = 0 />
        <cfset var minLen = 0 />
        <cfset var threshold = 0 />
        <cfset var score = 0 />

        <!--- Ticket 5B: pairs the user has explicitly marked "not a match" are
              suppressed from the review list. --->
        <cfset var dismissed = getDismissedPairs(arguments.userid) />

        <cfloop query="qCandidates">
            <cfif structKeyExists(dismissed, pairKey(qCandidates.id_a, qCandidates.id_b))><cfcontinue /></cfif>
            <cfset na = cdNormalizeName(qCandidates.name_a) />
            <cfset nb = cdNormalizeName(qCandidates.name_b) />
            <cfif NOT len(na) OR NOT len(nb)><cfcontinue /></cfif>

            <cfset dist   = cdLevenshtein(na, nb) />
            <cfset maxLen = max(len(na), len(nb)) />
            <cfset minLen = min(len(na), len(nb)) />

            <!--- Allow a little more slack on longer names, but never a lot:
                  2 edits minimum, otherwise 20% of the shorter name. --->
            <cfset threshold = max(2, int(minLen * 0.2)) />

            <!--- Require BOTH a small absolute edit distance AND matching surnames
                  so "Paul Hardt"/"Paul Ruddy" (same first name, different surname)
                  is rejected while "Krystal O'Conner"/"Krystal OConnor" is kept. --->
            <cfif dist LTE threshold AND cdSurnameMatches(qCandidates.name_a, qCandidates.name_b)>
                <cfset score = maxLen GT 0 ? int((1 - (dist / maxLen)) * 100) : 0 />
                <cfset queryAddRow(qPossible) />
                <cfset querySetCell(qPossible, "userid",      qCandidates.userid) />
                <cfset querySetCell(qPossible, "id_a",        qCandidates.id_a) />
                <cfset querySetCell(qPossible, "name_a",      qCandidates.name_a) />
                <cfset querySetCell(qPossible, "id_b",        qCandidates.id_b) />
                <cfset querySetCell(qPossible, "name_b",      qCandidates.name_b) />
                <cfset querySetCell(qPossible, "match_score", score) />
            </cfif>
        </cfloop>

        <cfreturn qPossible />
    </cffunction>

    <!--- ---------------------------------------------------------------------
          Similarity helpers for the POSSIBLE-duplicate gate. Pure CFML, no DB.
         --------------------------------------------------------------------- --->
    <!--- Normalize a name for comparison: lowercase, strip anything that is not a
          letter/number/space, collapse whitespace. So "O'Conner" and "OConnor"
          compare as "oconner"/"oconnor" (distance 1) instead of being separated
          by punctuation noise. --->
    <cffunction name="cdNormalizeName" access="private" returntype="string" output="false">
        <cfargument name="name" type="string" required="true" />
        <cfset var s = lcase(trim(arguments.name)) />
        <cfset s = reReplace(s, "[^a-z0-9 ]", "", "ALL") />
        <cfset s = reReplace(s, "\s+", " ", "ALL") />
        <cfreturn trim(s) />
    </cffunction>

    <!--- True when the two names share a surname signature. We treat the LAST
          whitespace-delimited token as the surname and accept either an exact
          normalized match or a SOUNDEX match (spelling variants like
          O'Conner/OConnor). This is the guard that kills "same first name only"
          false positives (Paul Hardt vs Paul Ruddy). --->
    <cffunction name="cdSurnameMatches" access="private" returntype="boolean" output="false">
        <cfargument name="nameA" type="string" required="true" />
        <cfargument name="nameB" type="string" required="true" />
        <cfset var a = cdNormalizeName(arguments.nameA) />
        <cfset var b = cdNormalizeName(arguments.nameB) />
        <cfif NOT len(a) OR NOT len(b)><cfreturn false /></cfif>
        <cfset var sa = listLast(a, " ") />
        <cfset var sb = listLast(b, " ") />
        <cfif sa EQ sb><cfreturn true /></cfif>
        <!--- cdSoundex() is a LOCAL CFML implementation. Adobe ColdFusion (this server)
              has NO built-in SoundEx() -- it is Lucee-only, and calling it threw
              "Variable SOUNDEX is undefined". The MySQL SOUNDEX() in the SQL prefilter
              above is a separate, valid database function and is unaffected. --->
        <cfif len(sa) AND len(sb) AND cdSoundex(sa) EQ cdSoundex(sb)
              AND cdLevenshtein(sa, sb) LTE 2><cfreturn true /></cfif>
        <cfreturn false />
    </cffunction>

    <!--- Local SoundEx. Adobe CF has no built-in SoundEx() (Lucee-only), so this is the
          classic algorithm: keep the first letter, map consonants to digits, drop vowels
          and adjacent duplicate codes, then pad/truncate to 4 chars. Both surnames run
          through this SAME function, so the comparison is internally consistent even if
          the code differs from another engine's SoundEx by an edge case. --->
    <cffunction name="cdSoundex" access="private" returntype="string" output="false">
        <cfargument name="word" type="string" required="true" />
        <cfset var w = reReplace(ucase(trim(arguments.word)), "[^A-Z]", "", "ALL") />
        <cfif NOT len(w)><cfreturn "" /></cfif>
        <!--- code for A B C D E F G H I J K L M N O P Q R S T U V W X Y Z --->
        <cfset var codeMap = "01230120022455012623010202" />
        <cfset var result = left(w, 1) />
        <cfset var prevCode = mid(codeMap, asc(left(w, 1)) - 64, 1) />
        <cfset var i = 0 />
        <cfset var ch = "" />
        <cfset var code = "" />
        <cfloop from="2" to="#len(w)#" index="i">
            <cfset ch = mid(w, i, 1) />
            <cfset code = mid(codeMap, asc(ch) - 64, 1) />
            <cfif code NEQ "0" AND code NEQ prevCode>
                <cfset result = result & code />
                <cfif len(result) GTE 4><cfbreak /></cfif>
            </cfif>
            <!--- Vowels (A,E,I,O,U,Y) reset the run; H and W are skipped without
                  resetting prevCode (classic SoundEx rule). --->
            <cfif code EQ "0" AND listFindNoCase("A,E,I,O,U,Y", ch)>
                <cfset prevCode = "0" />
            <cfelseif code NEQ "0">
                <cfset prevCode = code />
            </cfif>
        </cfloop>
        <cfreturn left(result & "000", 4) />
    </cffunction>

    <!--- Standard iterative Levenshtein edit distance. Names are short so the
          O(n*m) table is trivial. --->
    <cffunction name="cdLevenshtein" access="private" returntype="numeric" output="false">
        <cfargument name="s" type="string" required="true" />
        <cfargument name="t" type="string" required="true" />
        <cfset var m = len(arguments.s) />
        <cfset var n = len(arguments.t) />
        <cfif m EQ 0><cfreturn n /></cfif>
        <cfif n EQ 0><cfreturn m /></cfif>

        <cfset var prev = [] />
        <cfset var curr = [] />
        <cfset var i = 0 />
        <cfset var j = 0 />
        <cfset var cost = 0 />
        <cfset var sc = "" />
        <cfset var tc = "" />

        <cfloop from="0" to="#n#" index="j">
            <cfset prev[j + 1] = j />
        </cfloop>

        <cfloop from="1" to="#m#" index="i">
            <cfset curr[1] = i />
            <cfset sc = mid(arguments.s, i, 1) />
            <cfloop from="1" to="#n#" index="j">
                <cfset tc = mid(arguments.t, j, 1) />
                <cfset cost = (sc EQ tc) ? 0 : 1 />
                <cfset curr[j + 1] = min(
                        curr[j] + 1,
                        min(prev[j + 1] + 1, prev[j] + cost)
                    ) />
            </cfloop>
            <cfset prev = curr />
            <cfset curr = [] />
        </cfloop>

        <cfreturn prev[n + 1] />
    </cffunction>

    <!--- ---------------------------------------------------------------------
          "NOT A MATCH" dismissals (ticket 5B). A user can flag a possible-duplicate
          pair as two different people; we remember it so the review list stops
          showing it. Pairs are stored order-independent (low id, high id).
         --------------------------------------------------------------------- --->
    <!--- Order-independent key for a contact pair, e.g. "12_87". --->
    <cffunction name="pairKey" access="private" returntype="string" output="false">
        <cfargument name="a" type="numeric" required="true" />
        <cfargument name="b" type="numeric" required="true" />
        <cfreturn min(int(arguments.a), int(arguments.b)) & "_" & max(int(arguments.a), int(arguments.b)) />
    </cffunction>

    <!--- Set of dismissed pair keys for this user. Wrapped in cftry so the page
          still works before the 2026-07-02 migration is applied (missing table =
          no dismissals). --->
    <cffunction name="getDismissedPairs" access="public" returntype="struct" output="false">
        <cfargument name="userid" type="numeric" required="true" />
        <cfset var result = {} />
        <cftry>
            <cfquery name="qDismissed" datasource="#application.datasource#">
                SELECT contactid_low, contactid_high
                FROM   contact_not_duplicate
                WHERE  userid = <cfqueryparam value="#arguments.userid#" cfsqltype="cf_sql_integer" />
            </cfquery>
            <cfloop query="qDismissed">
                <cfset result[qDismissed.contactid_low & "_" & qDismissed.contactid_high] = true />
            </cfloop>
            <cfcatch type="any">
                <cflog file="contact_merge" type="warning"
                       text="getDismissedPairs: #cfcatch.message# (run 2026-07-02_contact_not_duplicate.sql?)" />
            </cfcatch>
        </cftry>
        <cfreturn result />
    </cffunction>

    <!--- Record a pair as "not a match". Idempotent via the UNIQUE key; verifies
          both contacts belong to the user before storing. --->
    <cffunction name="dismissDuplicatePair" access="public" returntype="struct" output="false">
        <cfargument name="userid"     type="numeric" required="true" />
        <cfargument name="contactIdA" type="numeric" required="true" />
        <cfargument name="contactIdB" type="numeric" required="true" />

        <cfset var result = { success: false, message: "" } />
        <cfset var lo = min(int(arguments.contactIdA), int(arguments.contactIdB)) />
        <cfset var hi = max(int(arguments.contactIdA), int(arguments.contactIdB)) />

        <cfif lo EQ hi>
            <cfset result.message = "A contact cannot be marked as not-a-match with itself." />
            <cfreturn result />
        </cfif>

        <!--- Ownership guard: both contacts must belong to this user. --->
        <cfquery name="qOwn" datasource="#application.datasource#">
            SELECT contactid FROM contactdetails
            WHERE  contactid IN (<cfqueryparam value="#lo#,#hi#" cfsqltype="cf_sql_integer" list="true" />)
              AND  userid = <cfqueryparam value="#arguments.userid#" cfsqltype="cf_sql_integer" />
        </cfquery>
        <cfif qOwn.recordCount NEQ 2>
            <cfset result.message = "One or both contacts are not yours." />
            <cfreturn result />
        </cfif>

        <cftry>
            <cfquery datasource="#application.datasource#">
                INSERT IGNORE INTO contact_not_duplicate (userid, contactid_low, contactid_high, created_by)
                VALUES (
                    <cfqueryparam value="#arguments.userid#" cfsqltype="cf_sql_integer" />,
                    <cfqueryparam value="#lo#" cfsqltype="cf_sql_integer" />,
                    <cfqueryparam value="#hi#" cfsqltype="cf_sql_integer" />,
                    <cfqueryparam value="#arguments.userid#" cfsqltype="cf_sql_integer" />
                )
            </cfquery>
            <cfset result.success = true />
            <cfset result.message = "Pair marked as not a match." />
            <cfcatch type="any">
                <cfset result.message = "Could not save: " & cfcatch.message />
                <cflog file="contact_merge" type="error"
                       text="dismissDuplicatePair FAIL userid=#arguments.userid# a=#lo# b=#hi# err=#cfcatch.message#" />
            </cfcatch>
        </cftry>
        <cfreturn result />
    </cffunction>

    <!--- =====================================================================
          Detail fetch for the merge modal (verified columns)
         ===================================================================== --->
    <cffunction name="getContactDetails" access="public" returntype="query" output="false">
        <cfargument name="contactIds" type="string" required="true" />
        <cfargument name="userid"     type="numeric" required="true" />

        <cfquery name="qDetails" datasource="#application.datasource#">
            SELECT cd.contactid, cd.userid,
                   cd.contactFullName, cd.recordname, cd.contacttitle, cd.contactNickname,
                   cd.contactPronoun, cd.contactBirthday, cd.contactMeetingDate, cd.contactMeetingLoc,
                   cd.refer_contact_id, cd.newsletter_yn, cd.googlealert_yn, cd.socialmedia_yn,
                   cd.contactCreationDate,
                   DATE_FORMAT(cd.contactCreationDate, '%Y-%m-%d %H:%i:%s') AS created_date
            FROM   contactdetails cd
            WHERE  cd.contactid IN (<cfqueryparam value="#arguments.contactIds#" cfsqltype="cf_sql_integer" list="true" />)
              AND  cd.userid    = <cfqueryparam value="#arguments.userid#" cfsqltype="cf_sql_integer" />
              AND  cd.isdeleted = <cfqueryparam value="0" cfsqltype="cf_sql_bit" />
            ORDER BY cd.contactCreationDate ASC
        </cfquery>
<cfif structKeyExists(request,"perfSvcQueryCount")><cfset request.perfSvcQueryCount++></cfif>

        <cfreturn qDetails />
    </cffunction>

    <!--- Contact items (email, phone, company, etc.) for the merge modal --->
    <cffunction name="getContactItems" access="public" returntype="query" output="false">
        <cfargument name="contactIds" type="string" required="true" />
        <cfargument name="userid"     type="numeric" required="true" />

        <cfquery name="qItems" datasource="#application.datasource#">
            SELECT ci.itemid, ci.contactid, ci.valueCategory, ci.valueType,
                   ci.valuetext, ci.valueCompany, ci.primary_yn
            FROM   contactitems ci
            JOIN   contactdetails cd ON cd.contactid = ci.contactid
            WHERE  ci.contactid IN (<cfqueryparam value="#arguments.contactIds#" cfsqltype="cf_sql_integer" list="true" />)
              AND  cd.userid     = <cfqueryparam value="#arguments.userid#" cfsqltype="cf_sql_integer" />
              AND  ci.itemStatus = 'Active'
            ORDER BY ci.contactid, ci.valueCategory, ci.itemid
        </cfquery>
<cfif structKeyExists(request,"perfSvcQueryCount")><cfset request.perfSvcQueryCount++></cfif>

        <cfreturn qItems />
    </cffunction>

    <!--- =====================================================================
          SAFE MERGE
          Repoints all child rows from duplicate -> primary inside ONE
          transaction, dedupes contact items, fixes referral links,
          soft-deletes the duplicate, and records a full audit/undo map.
          Idempotent: refuses if either contact is missing/not owned/deleted.
         ===================================================================== --->
    <cffunction name="mergeContacts" access="public" returntype="struct" output="false">
        <cfargument name="primaryContactId"   type="numeric" required="true" />
        <cfargument name="duplicateContactId" type="numeric" required="true" />
        <cfargument name="mergeData"          type="struct"  required="true" />
        <cfargument name="userid"             type="numeric" required="true" />

        <cfset var result = { success: false, message: "", mergeid: 0 } />
        <cfset var pri = int(arguments.primaryContactId) />
        <cfset var dup = int(arguments.duplicateContactId) />

        <!--- Local working vars. This service can be a shared singleton, so every value
              computed in CFML is kept function-local to avoid cross-request bleed. --->
        <cfset var qUserLink       = "" />
        <cfset var priPhoto        = "" />
        <cfset var dupPhoto        = "" />
        <cfset var avatarCarry     = false />
        <cfset var avatarValue     = "" />
        <cfset var host            = "" />
        <cfset var mediaRoot       = "" />
        <cfset var contactsFolder  = "" />
        <cfset var dupPhotoPath    = "" />
        <cfset var priFolder       = "" />
        <cfset var qShareKeep      = "" />
        <cfset var qRef            = "" />
        <cfset var priReferrer     = "" />
        <cfset var dupReferrer     = "" />
        <cfset var newReferrer     = "" />
        <cfset var referralActionA = "" />
        <cfset var cndExists       = "" />
        <cfset var qKeepPhoto      = "" />

        <!--- Guard: cannot merge a contact into itself --->
        <cfif pri EQ dup>
            <cfset result.message = "Primary and duplicate are the same contact." />
            <cfreturn result />
        </cfif>

        <!--- STEP 0. D1 pre-flight: a contact wired to a user account IS that user's own
              record and must never be merged away (only kept). Runs BEFORE any write; the
              keep side (pri) being a user record is allowed. --->
        <cfquery name="qUserLink" datasource="#application.datasource#">
            SELECT contactid
            FROM   taousers_tbl
            WHERE  contactid = <cfqueryparam value="#dup#" cfsqltype="cf_sql_integer" />
        </cfquery>
        <cfif qUserLink.recordCount GT 0>
            <cfset result.message = "This contact is linked to a user account and can't be merged away. Keep it as the primary instead." />
            <cfreturn result />
        </cfif>

        <!--- Guard: both must exist, be owned by this user, and be active. Also pulls
              contactphoto for the avatar carry-over pre-read (step 9). --->
        <cfquery name="qGuard" datasource="#application.datasource#">
            SELECT contactid, contactphoto
            FROM   contactdetails
            WHERE  contactid IN (<cfqueryparam value="#pri#,#dup#" cfsqltype="cf_sql_integer" list="true" />)
              AND  userid    = <cfqueryparam value="#arguments.userid#" cfsqltype="cf_sql_integer" />
              AND  isdeleted = <cfqueryparam value="0" cfsqltype="cf_sql_bit" />
        </cfquery>
        <cfif qGuard.recordCount NEQ 2>
            <cfset result.message = "One or both contacts were not found, are not yours, or were already merged." />
            <cfreturn result />
        </cfif>

        <!--- STEP 9 (pre-txn half). Avatar carry-over, mixed-driver branch: contactphoto is a
              real column AND the image lives by convention at
              <mediaRoot>\users\<userid>\contacts\<contactid>\<file>
              (writer: services/ContactImportV2Service.cfc:1703-1712,1738). Carry ONLY when the
              keep side has no photo and the duplicate has one. Copy the file BEFORE the
              transaction (an orphaned copy on rollback is harmless); the column write happens
              INSIDE the transaction and is mapped, and only if this copy succeeded. Every
              failure here is non-fatal - a merge must never fail on a photo. --->
        <cfloop query="qGuard">
            <cfif qGuard.contactid EQ pri>
                <cfset priPhoto = trim(qGuard.contactphoto) />
            <cfelseif qGuard.contactid EQ dup>
                <cfset dupPhoto = trim(qGuard.contactphoto) />
            </cfif>
        </cfloop>
        <cfif NOT len(priPhoto) AND len(dupPhoto)>
            <cftry>
                <cfset host           = listFirst(cgi.server_name, ".") />
                <cfset mediaRoot      = "C:\home\theactorsoffice.com\wwwroot\" & host & "-subdomain\media-" & host />
                <cfset contactsFolder = mediaRoot & "\users\" & int(arguments.userid) & "\contacts" />
                <cfset dupPhotoPath   = contactsFolder & "\" & dup & "\" & dupPhoto />
                <cfset priFolder      = contactsFolder & "\" & pri />
                <cfif fileExists(dupPhotoPath)>
                    <cfif NOT directoryExists(priFolder)>
                        <cfdirectory directory="#priFolder#" action="create" />
                    </cfif>
                    <cffile action="copy" source="#dupPhotoPath#" destination="#priFolder#\" />
                    <cfset avatarCarry = true />
                    <cfset avatarValue = dupPhoto />
                <cfelse>
                    <cflog file="contact_merge" type="warning"
                           text="avatar carry skipped (source missing) pri=#pri# dup=#dup# path=#dupPhotoPath#" />
                </cfif>
                <cfcatch type="any">
                    <cfset avatarCarry = false />
                    <cflog file="contact_merge" type="warning"
                           text="avatar carry copy failed pri=#pri# dup=#dup# err=#cfcatch.message#" />
                </cfcatch>
            </cftry>
        </cfif>

        <cftry>
            <cftransaction>
                <!--- 1. Audit header --->
                <cfquery datasource="#application.datasource#" result="logRes">
                    INSERT INTO contact_merge_log (userid, primary_contactid, duplicate_contactid, merged_by, status)
                    VALUES (
                        <cfqueryparam value="#arguments.userid#" cfsqltype="cf_sql_integer" />,
                        <cfqueryparam value="#pri#" cfsqltype="cf_sql_integer" />,
                        <cfqueryparam value="#dup#" cfsqltype="cf_sql_integer" />,
                        <cfqueryparam value="#arguments.userid#" cfsqltype="cf_sql_integer" />,
                        'merged'
                    )
                </cfquery>
                <cfset var mergeid = logRes.generatedKey />

                <!--- 2a. Map contact items that COLLIDE with primary (same category + value) --->
                <cfquery datasource="#application.datasource#">
                    INSERT INTO contact_merge_map (mergeid, tbl, pkcol, pkval, old_contactid, new_contactid, action)
                    SELECT <cfqueryparam value="#mergeid#" cfsqltype="cf_sql_integer" />, 'contactitems_tbl', 'itemid',
                           d.itemid, <cfqueryparam value="#dup#" cfsqltype="cf_sql_integer" />,
                           <cfqueryparam value="#pri#" cfsqltype="cf_sql_integer" />, 'item_deleted'
                    FROM   contactitems_tbl d
                    WHERE  d.contactid = <cfqueryparam value="#dup#" cfsqltype="cf_sql_integer" />
                      AND  (d.isDeleted IS NULL OR d.isDeleted = 0)
                      AND  EXISTS (
                            SELECT 1 FROM contactitems_tbl p
                            WHERE p.contactid = <cfqueryparam value="#pri#" cfsqltype="cf_sql_integer" />
                              AND (p.isDeleted IS NULL OR p.isDeleted = 0)
                              AND p.valueCategory = d.valueCategory
                              AND LOWER(TRIM(p.valuetext)) = LOWER(TRIM(d.valuetext))
                           )
                </cfquery>
                <!--- 2b. Soft-delete those colliding duplicate items --->
                <cfquery datasource="#application.datasource#">
                    UPDATE contactitems_tbl d
                    SET    d.isDeleted = 1
                    WHERE  d.contactid = <cfqueryparam value="#dup#" cfsqltype="cf_sql_integer" />
                      AND  (d.isDeleted IS NULL OR d.isDeleted = 0)
                      AND  EXISTS (
                            SELECT 1 FROM (SELECT * FROM contactitems_tbl) p
                            WHERE p.contactid = <cfqueryparam value="#pri#" cfsqltype="cf_sql_integer" />
                              AND (p.isDeleted IS NULL OR p.isDeleted = 0)
                              AND p.valueCategory = d.valueCategory
                              AND LOWER(TRIM(p.valuetext)) = LOWER(TRIM(d.valuetext))
                           )
                </cfquery>
                <!--- 2c. Map + repoint the remaining (non-colliding) duplicate items --->
                <cfquery datasource="#application.datasource#">
                    INSERT INTO contact_merge_map (mergeid, tbl, pkcol, pkval, old_contactid, new_contactid, action)
                    SELECT <cfqueryparam value="#mergeid#" cfsqltype="cf_sql_integer" />, 'contactitems_tbl', 'itemid',
                           itemid, <cfqueryparam value="#dup#" cfsqltype="cf_sql_integer" />,
                           <cfqueryparam value="#pri#" cfsqltype="cf_sql_integer" />, 'repointed'
                    FROM   contactitems_tbl
                    WHERE  contactid = <cfqueryparam value="#dup#" cfsqltype="cf_sql_integer" />
                      AND  (isDeleted IS NULL OR isDeleted = 0)
                </cfquery>
                <cfquery datasource="#application.datasource#">
                    UPDATE contactitems_tbl
                    SET    contactid = <cfqueryparam value="#pri#" cfsqltype="cf_sql_integer" />
                    WHERE  contactid = <cfqueryparam value="#dup#" cfsqltype="cf_sql_integer" />
                      AND  (isDeleted IS NULL OR isDeleted = 0)
                </cfquery>

                <!--- 3. Notes --->
                <cfquery datasource="#application.datasource#">
                    INSERT INTO contact_merge_map (mergeid, tbl, pkcol, pkval, old_contactid, new_contactid, action)
                    SELECT <cfqueryparam value="#mergeid#" cfsqltype="cf_sql_integer" />, 'noteslog_tbl', 'noteid',
                           noteid, <cfqueryparam value="#dup#" cfsqltype="cf_sql_integer" />,
                           <cfqueryparam value="#pri#" cfsqltype="cf_sql_integer" />, 'repointed'
                    FROM   noteslog_tbl
                    WHERE  contactid = <cfqueryparam value="#dup#" cfsqltype="cf_sql_integer" />
                </cfquery>
                <cfquery datasource="#application.datasource#">
                    UPDATE noteslog_tbl
                    SET    contactid = <cfqueryparam value="#pri#" cfsqltype="cf_sql_integer" />
                    WHERE  contactid = <cfqueryparam value="#dup#" cfsqltype="cf_sql_integer" />
                </cfquery>

                <!--- 4. Event attendance. Dedupe by eventid, then repoint. C-D fix: the map PK
                         column is eventContactID (the true PK), not the eventid FK; and the
                         colliding rows that get soft-deleted are now mapped (action='deleted')
                         BEFORE the delete so the audit/undo map is complete. Deletes precede the
                         repoint update so no unique index can fire mid-transaction. --->
                <!--- 4a. Map colliding duplicate rows (share an eventid with primary) --->
                <cfquery datasource="#application.datasource#">
                    INSERT INTO contact_merge_map (mergeid, tbl, pkcol, pkval, old_contactid, new_contactid, action)
                    SELECT <cfqueryparam value="#mergeid#" cfsqltype="cf_sql_integer" />, 'eventcontactsxref_tbl', 'eventContactID',
                           d.eventContactID, <cfqueryparam value="#dup#" cfsqltype="cf_sql_integer" />,
                           <cfqueryparam value="#pri#" cfsqltype="cf_sql_integer" />, 'deleted'
                    FROM   eventcontactsxref_tbl d
                    WHERE  d.contactid = <cfqueryparam value="#dup#" cfsqltype="cf_sql_integer" />
                      AND  (d.IsDeleted IS NULL OR d.IsDeleted = 0)
                      AND  EXISTS (
                            SELECT 1 FROM eventcontactsxref_tbl p
                            WHERE p.contactid = <cfqueryparam value="#pri#" cfsqltype="cf_sql_integer" />
                              AND (p.IsDeleted IS NULL OR p.IsDeleted = 0)
                              AND p.eventid = d.eventid
                           )
                </cfquery>
                <!--- 4b. Soft-delete those colliding duplicate rows --->
                <cfquery datasource="#application.datasource#">
                    UPDATE eventcontactsxref_tbl d
                    SET    d.IsDeleted = 1
                    WHERE  d.contactid = <cfqueryparam value="#dup#" cfsqltype="cf_sql_integer" />
                      AND  (d.IsDeleted IS NULL OR d.IsDeleted = 0)
                      AND  EXISTS (
                            SELECT 1 FROM (SELECT * FROM eventcontactsxref_tbl) p
                            WHERE p.contactid = <cfqueryparam value="#pri#" cfsqltype="cf_sql_integer" />
                              AND (p.IsDeleted IS NULL OR p.IsDeleted = 0)
                              AND p.eventid = d.eventid
                           )
                </cfquery>
                <!--- 4c. Map + repoint the remaining (non-colliding) rows (pkcol eventContactID) --->
                <cfquery datasource="#application.datasource#">
                    INSERT INTO contact_merge_map (mergeid, tbl, pkcol, pkval, old_contactid, new_contactid, action)
                    SELECT <cfqueryparam value="#mergeid#" cfsqltype="cf_sql_integer" />, 'eventcontactsxref_tbl', 'eventContactID',
                           eventContactID, <cfqueryparam value="#dup#" cfsqltype="cf_sql_integer" />,
                           <cfqueryparam value="#pri#" cfsqltype="cf_sql_integer" />, 'repointed'
                    FROM   eventcontactsxref_tbl
                    WHERE  contactid = <cfqueryparam value="#dup#" cfsqltype="cf_sql_integer" />
                      AND  (IsDeleted IS NULL OR IsDeleted = 0)
                </cfquery>
                <cfquery datasource="#application.datasource#">
                    UPDATE eventcontactsxref_tbl
                    SET    contactid = <cfqueryparam value="#pri#" cfsqltype="cf_sql_integer" />
                    WHERE  contactid = <cfqueryparam value="#dup#" cfsqltype="cf_sql_integer" />
                      AND  (IsDeleted IS NULL OR IsDeleted = 0)
                </cfquery>

                <!--- 5. Audition links. C-E retrofit: salvage the duplicate's xrefnotes onto the
                         surviving row when the survivor has none; map the colliding rows with the
                         true PK (id, action='deleted') BEFORE hard-deleting them; then repoint the
                         rest (also mapped with pkcol id). Deletes precede the repoint update. --->
                <!--- 5a. Salvage xrefnotes from a colliding duplicate row to the survivor --->
                <cfquery datasource="#application.datasource#">
                    UPDATE audcontacts_auditions_xref p
                    JOIN   audcontacts_auditions_xref d
                           ON  d.audprojectid = p.audprojectid
                           AND d.contactid = <cfqueryparam value="#dup#" cfsqltype="cf_sql_integer" />
                    SET    p.xrefnotes = d.xrefnotes
                    WHERE  p.contactid = <cfqueryparam value="#pri#" cfsqltype="cf_sql_integer" />
                      AND  (p.xrefnotes IS NULL OR TRIM(p.xrefnotes) = '')
                      AND  d.xrefnotes IS NOT NULL AND TRIM(d.xrefnotes) <> ''
                </cfquery>
                <!--- 5b. Map colliding duplicate rows (share an audprojectid with primary) --->
                <cfquery datasource="#application.datasource#">
                    INSERT INTO contact_merge_map (mergeid, tbl, pkcol, pkval, old_contactid, new_contactid, action)
                    SELECT <cfqueryparam value="#mergeid#" cfsqltype="cf_sql_integer" />, 'audcontacts_auditions_xref', 'id',
                           d.id, <cfqueryparam value="#dup#" cfsqltype="cf_sql_integer" />,
                           <cfqueryparam value="#pri#" cfsqltype="cf_sql_integer" />, 'deleted'
                    FROM   audcontacts_auditions_xref d
                    WHERE  d.contactid = <cfqueryparam value="#dup#" cfsqltype="cf_sql_integer" />
                      AND  EXISTS (
                            SELECT 1 FROM audcontacts_auditions_xref p
                            WHERE p.contactid = <cfqueryparam value="#pri#" cfsqltype="cf_sql_integer" />
                              AND p.audprojectid = d.audprojectid
                           )
                </cfquery>
                <!--- 5c. Hard-delete the colliding duplicate rows --->
                <cfquery datasource="#application.datasource#">
                    DELETE d FROM audcontacts_auditions_xref d
                    WHERE  d.contactid = <cfqueryparam value="#dup#" cfsqltype="cf_sql_integer" />
                      AND  EXISTS (
                            SELECT 1 FROM (SELECT * FROM audcontacts_auditions_xref) p
                            WHERE p.contactid = <cfqueryparam value="#pri#" cfsqltype="cf_sql_integer" />
                              AND p.audprojectid = d.audprojectid
                           )
                </cfquery>
                <!--- 5d. Map + repoint the remaining (non-colliding) rows (pkcol id) --->
                <cfquery datasource="#application.datasource#">
                    INSERT INTO contact_merge_map (mergeid, tbl, pkcol, pkval, old_contactid, new_contactid, action)
                    SELECT <cfqueryparam value="#mergeid#" cfsqltype="cf_sql_integer" />, 'audcontacts_auditions_xref', 'id',
                           id, <cfqueryparam value="#dup#" cfsqltype="cf_sql_integer" />,
                           <cfqueryparam value="#pri#" cfsqltype="cf_sql_integer" />, 'repointed'
                    FROM   audcontacts_auditions_xref
                    WHERE  contactid = <cfqueryparam value="#dup#" cfsqltype="cf_sql_integer" />
                </cfquery>
                <cfquery datasource="#application.datasource#">
                    UPDATE audcontacts_auditions_xref
                    SET    contactid = <cfqueryparam value="#pri#" cfsqltype="cf_sql_integer" />
                    WHERE  contactid = <cfqueryparam value="#dup#" cfsqltype="cf_sql_integer" />
                </cfquery>

                <!--- 6. Relationship system enrollments. fusystemusers_tbl has a UNIQUE index
                         uq_active_enrollment(userid, contactid, systemid, active_guard) [WO-3.1],
                         where active_guard = 1 only for Active, non-deleted rows. A blind repoint
                         throws a duplicate-key error when BOTH contacts are actively enrolled in the
                         same system. So: soft-delete the duplicate's colliding active enrollments
                         first (active_guard recomputes to NULL, freeing the index), then repoint the
                         remaining rows. --->
                <!--- 6a. Map + soft-delete duplicate's active enrollments that collide with primary --->
                <cfquery datasource="#application.datasource#">
                    INSERT INTO contact_merge_map (mergeid, tbl, pkcol, pkval, old_contactid, new_contactid, action)
                    SELECT <cfqueryparam value="#mergeid#" cfsqltype="cf_sql_integer" />, 'fusystemusers_tbl', 'suID',
                           d.suID, <cfqueryparam value="#dup#" cfsqltype="cf_sql_integer" />,
                           <cfqueryparam value="#pri#" cfsqltype="cf_sql_integer" />, 'enroll_deleted'
                    FROM   fusystemusers_tbl d
                    WHERE  d.contactid = <cfqueryparam value="#dup#" cfsqltype="cf_sql_integer" />
                      AND  d.sustatus = 'Active' AND (d.isdeleted IS NULL OR d.isdeleted = 0)
                      AND  EXISTS (
                            SELECT 1 FROM (SELECT * FROM fusystemusers_tbl) p
                            WHERE p.contactid = <cfqueryparam value="#pri#" cfsqltype="cf_sql_integer" />
                              AND p.userid = d.userid AND p.systemid = d.systemid
                              AND p.sustatus = 'Active' AND (p.isdeleted IS NULL OR p.isdeleted = 0)
                           )
                </cfquery>
                <cfquery datasource="#application.datasource#">
                    UPDATE fusystemusers_tbl d
                    SET    d.isdeleted = 1
                    WHERE  d.contactid = <cfqueryparam value="#dup#" cfsqltype="cf_sql_integer" />
                      AND  d.sustatus = 'Active' AND (d.isdeleted IS NULL OR d.isdeleted = 0)
                      AND  EXISTS (
                            SELECT 1 FROM (SELECT * FROM fusystemusers_tbl) p
                            WHERE p.contactid = <cfqueryparam value="#pri#" cfsqltype="cf_sql_integer" />
                              AND p.userid = d.userid AND p.systemid = d.systemid
                              AND p.sustatus = 'Active' AND (p.isdeleted IS NULL OR p.isdeleted = 0)
                           )
                </cfquery>
                <!--- 6b. Map + repoint the remaining (non-colliding) duplicate enrollments --->
                <cfquery datasource="#application.datasource#">
                    INSERT INTO contact_merge_map (mergeid, tbl, pkcol, pkval, old_contactid, new_contactid, action)
                    SELECT <cfqueryparam value="#mergeid#" cfsqltype="cf_sql_integer" />, 'fusystemusers_tbl', 'suID',
                           suID, <cfqueryparam value="#dup#" cfsqltype="cf_sql_integer" />,
                           <cfqueryparam value="#pri#" cfsqltype="cf_sql_integer" />, 'repointed'
                    FROM   fusystemusers_tbl
                    WHERE  contactid = <cfqueryparam value="#dup#" cfsqltype="cf_sql_integer" />
                      AND  (isdeleted IS NULL OR isdeleted = 0)
                </cfquery>
                <cfquery datasource="#application.datasource#">
                    UPDATE fusystemusers_tbl
                    SET    contactid = <cfqueryparam value="#pri#" cfsqltype="cf_sql_integer" />
                    WHERE  contactid = <cfqueryparam value="#dup#" cfsqltype="cf_sql_integer" />
                      AND  (isdeleted IS NULL OR isdeleted = 0)
                </cfquery>

                <!--- 7. Notifications/reminders: funotifications has NO contactid column
                         (it links to a contact only via suID -> fusystemusers.contactid, already
                         repointed in step 6). Nothing to do for funotifications. --->

                <!--- 7A. events_tbl (direct contactid FK). Straight repoint. --->
                <cfquery datasource="#application.datasource#">
                    INSERT INTO contact_merge_map (mergeid, tbl, pkcol, pkval, old_contactid, new_contactid, action)
                    SELECT <cfqueryparam value="#mergeid#" cfsqltype="cf_sql_integer" />, 'events_tbl', 'eventID',
                           eventID, <cfqueryparam value="#dup#" cfsqltype="cf_sql_integer" />,
                           <cfqueryparam value="#pri#" cfsqltype="cf_sql_integer" />, 'repointed'
                    FROM   events_tbl
                    WHERE  contactid = <cfqueryparam value="#dup#" cfsqltype="cf_sql_integer" />
                </cfquery>
                <cfquery datasource="#application.datasource#">
                    UPDATE events_tbl
                    SET    contactid = <cfqueryparam value="#pri#" cfsqltype="cf_sql_integer" />
                    WHERE  contactid = <cfqueryparam value="#dup#" cfsqltype="cf_sql_integer" />
                </cfquery>

                <!--- 7B. audprojects (direct contactid FK). Straight repoint. --->
                <cfquery datasource="#application.datasource#">
                    INSERT INTO contact_merge_map (mergeid, tbl, pkcol, pkval, old_contactid, new_contactid, action)
                    SELECT <cfqueryparam value="#mergeid#" cfsqltype="cf_sql_integer" />, 'audprojects', 'audprojectID',
                           audprojectID, <cfqueryparam value="#dup#" cfsqltype="cf_sql_integer" />,
                           <cfqueryparam value="#pri#" cfsqltype="cf_sql_integer" />, 'repointed'
                    FROM   audprojects
                    WHERE  contactid = <cfqueryparam value="#dup#" cfsqltype="cf_sql_integer" />
                </cfquery>
                <cfquery datasource="#application.datasource#">
                    UPDATE audprojects
                    SET    contactid = <cfqueryparam value="#pri#" cfsqltype="cf_sql_integer" />
                    WHERE  contactid = <cfqueryparam value="#dup#" cfsqltype="cf_sql_integer" />
                </cfquery>

                <!--- 7C. auditions (direct contactid FK). Straight, unconditional. Prod has 0
                         contactid rows today (no-op) but the live import writer can create them,
                         so the repoint stays to protect against a future dangling row. --->
                <cfquery datasource="#application.datasource#">
                    INSERT INTO contact_merge_map (mergeid, tbl, pkcol, pkval, old_contactid, new_contactid, action)
                    SELECT <cfqueryparam value="#mergeid#" cfsqltype="cf_sql_integer" />, 'auditions', 'audition_id',
                           audition_id, <cfqueryparam value="#dup#" cfsqltype="cf_sql_integer" />,
                           <cfqueryparam value="#pri#" cfsqltype="cf_sql_integer" />, 'repointed'
                    FROM   auditions
                    WHERE  contactid = <cfqueryparam value="#dup#" cfsqltype="cf_sql_integer" />
                </cfquery>
                <cfquery datasource="#application.datasource#">
                    UPDATE auditions
                    SET    contactid = <cfqueryparam value="#pri#" cfsqltype="cf_sql_integer" />
                    WHERE  contactid = <cfqueryparam value="#dup#" cfsqltype="cf_sql_integer" />
                </cfquery>

                <!--- 7D. audroles (direct contactid FK). Straight repoint. The only UNIQUE index
                         (audprojectID,audRoleID) does not involve contactid, so no collision. --->
                <cfquery datasource="#application.datasource#">
                    INSERT INTO contact_merge_map (mergeid, tbl, pkcol, pkval, old_contactid, new_contactid, action)
                    SELECT <cfqueryparam value="#mergeid#" cfsqltype="cf_sql_integer" />, 'audroles', 'audRoleID',
                           audRoleID, <cfqueryparam value="#dup#" cfsqltype="cf_sql_integer" />,
                           <cfqueryparam value="#pri#" cfsqltype="cf_sql_integer" />, 'repointed'
                    FROM   audroles
                    WHERE  contactid = <cfqueryparam value="#dup#" cfsqltype="cf_sql_integer" />
                </cfquery>
                <cfquery datasource="#application.datasource#">
                    UPDATE audroles
                    SET    contactid = <cfqueryparam value="#pri#" cfsqltype="cf_sql_integer" />
                    WHERE  contactid = <cfqueryparam value="#dup#" cfsqltype="cf_sql_integer" />
                </cfquery>

                <!--- 7E. notifications_tbl (direct contactid FK, 3,308 live rows). Straight. --->
                <cfquery datasource="#application.datasource#">
                    INSERT INTO contact_merge_map (mergeid, tbl, pkcol, pkval, old_contactid, new_contactid, action)
                    SELECT <cfqueryparam value="#mergeid#" cfsqltype="cf_sql_integer" />, 'notifications_tbl', 'ID',
                           ID, <cfqueryparam value="#dup#" cfsqltype="cf_sql_integer" />,
                           <cfqueryparam value="#pri#" cfsqltype="cf_sql_integer" />, 'repointed'
                    FROM   notifications_tbl
                    WHERE  contactid = <cfqueryparam value="#dup#" cfsqltype="cf_sql_integer" />
                </cfquery>
                <cfquery datasource="#application.datasource#">
                    UPDATE notifications_tbl
                    SET    contactid = <cfqueryparam value="#pri#" cfsqltype="cf_sql_integer" />
                    WHERE  contactid = <cfqueryparam value="#dup#" cfsqltype="cf_sql_integer" />
                </cfquery>

                <!--- 7F. tmpcontactgroups_tbl (direct contactid FK). Straight repoint: no UNIQUE
                          constraint on membership (PRIMARY is contactgroupid) and nothing reads the
                          table, so a plain repoint cannot fire a constraint and needs no dedupe. --->
                <cfquery datasource="#application.datasource#">
                    INSERT INTO contact_merge_map (mergeid, tbl, pkcol, pkval, old_contactid, new_contactid, action)
                    SELECT <cfqueryparam value="#mergeid#" cfsqltype="cf_sql_integer" />, 'tmpcontactgroups_tbl', 'contactgroupid',
                           contactgroupid, <cfqueryparam value="#dup#" cfsqltype="cf_sql_integer" />,
                           <cfqueryparam value="#pri#" cfsqltype="cf_sql_integer" />, 'repointed'
                    FROM   tmpcontactgroups_tbl
                    WHERE  contactid = <cfqueryparam value="#dup#" cfsqltype="cf_sql_integer" />
                </cfquery>
                <cfquery datasource="#application.datasource#">
                    UPDATE tmpcontactgroups_tbl
                    SET    contactid = <cfqueryparam value="#pri#" cfsqltype="cf_sql_integer" />
                    WHERE  contactid = <cfqueryparam value="#dup#" cfsqltype="cf_sql_integer" />
                </cfquery>

                <!--- 8. shares (PRIMARY KEY IS contactid). Two-branch guarded on the PK: if the
                         keep side already has a share row, the duplicate's row is mapped 'deleted'
                         and removed (keep's public share link survives; the duplicate's now-dead
                         external link is accepted). Otherwise the duplicate's row is repointed by
                         rewriting its PK. Delete precedes update so the PK cannot collide. --->
                <cfquery name="qShareKeep" datasource="#application.datasource#">
                    SELECT contactid
                    FROM   shares
                    WHERE  contactid = <cfqueryparam value="#pri#" cfsqltype="cf_sql_integer" />
                </cfquery>
                <cfif qShareKeep.recordCount GT 0>
                    <cfquery datasource="#application.datasource#">
                        INSERT INTO contact_merge_map (mergeid, tbl, pkcol, pkval, old_contactid, new_contactid, action)
                        SELECT <cfqueryparam value="#mergeid#" cfsqltype="cf_sql_integer" />, 'shares', 'contactid',
                               contactid, <cfqueryparam value="#dup#" cfsqltype="cf_sql_integer" />,
                               <cfqueryparam value="#pri#" cfsqltype="cf_sql_integer" />, 'deleted'
                        FROM   shares
                        WHERE  contactid = <cfqueryparam value="#dup#" cfsqltype="cf_sql_integer" />
                    </cfquery>
                    <cfquery datasource="#application.datasource#">
                        DELETE FROM shares
                        WHERE  contactid = <cfqueryparam value="#dup#" cfsqltype="cf_sql_integer" />
                    </cfquery>
                <cfelse>
                    <cfquery datasource="#application.datasource#">
                        INSERT INTO contact_merge_map (mergeid, tbl, pkcol, pkval, old_contactid, new_contactid, action)
                        SELECT <cfqueryparam value="#mergeid#" cfsqltype="cf_sql_integer" />, 'shares', 'contactid',
                               contactid, <cfqueryparam value="#dup#" cfsqltype="cf_sql_integer" />,
                               <cfqueryparam value="#pri#" cfsqltype="cf_sql_integer" />, 'repointed'
                        FROM   shares
                        WHERE  contactid = <cfqueryparam value="#dup#" cfsqltype="cf_sql_integer" />
                    </cfquery>
                    <cfquery datasource="#application.datasource#">
                        UPDATE shares
                        SET    contactid = <cfqueryparam value="#pri#" cfsqltype="cf_sql_integer" />
                        WHERE  contactid = <cfqueryparam value="#dup#" cfsqltype="cf_sql_integer" />
                    </cfquery>
                </cfif>

                <!--- 9. Referral links (A1b) - blanket. Every OTHER contact whose
                         refer_contact_id points at the duplicate is repointed to the keep contact.
                         The NOT IN (:pri,:dup) filter means it never touches the keep or duplicate
                         row, so its position is independent of the applyMergedFields/avatar/edge
                         ordering below. The pri-first edge (A1a) runs AFTER applyMergedFields at
                         step 13, so it evaluates the keep contact's current referrer. --->
                <cfquery datasource="#application.datasource#">
                    INSERT INTO contact_merge_map (mergeid, tbl, pkcol, pkval, old_contactid, new_contactid, action)
                    SELECT <cfqueryparam value="#mergeid#" cfsqltype="cf_sql_integer" />, 'contactdetails_tbl', 'contactID',
                           contactid, <cfqueryparam value="#dup#" cfsqltype="cf_sql_integer" />,
                           <cfqueryparam value="#pri#" cfsqltype="cf_sql_integer" />, 'referral_repointed'
                    FROM   contactdetails_tbl
                    WHERE  refer_contact_id = <cfqueryparam value="#dup#" cfsqltype="cf_sql_integer" />
                      AND  contactid NOT IN (<cfqueryparam value="#pri#,#dup#" cfsqltype="cf_sql_integer" list="true" />)
                      AND  userid = <cfqueryparam value="#arguments.userid#" cfsqltype="cf_sql_integer" />
                </cfquery>
                <cfquery datasource="#application.datasource#">
                    UPDATE contactdetails_tbl
                    SET    refer_contact_id = <cfqueryparam value="#pri#" cfsqltype="cf_sql_integer" />
                    WHERE  refer_contact_id = <cfqueryparam value="#dup#" cfsqltype="cf_sql_integer" />
                      AND  contactid NOT IN (<cfqueryparam value="#pri#,#dup#" cfsqltype="cf_sql_integer" list="true" />)
                      AND  userid = <cfqueryparam value="#arguments.userid#" cfsqltype="cf_sql_integer" />
                </cfquery>

                <!--- 10. contact_not_duplicate cleanup (5B). Existence-guarded via
                          information_schema so it is safe whether or not the dismissals table has
                          been rolled out in this environment. Any dismissal pairing the duplicate
                          is mapped 'deleted' (new_contactid=pri per A2) then removed. --->
                <cfquery name="cndExists" datasource="#application.datasource#">
                    SELECT COUNT(*) AS n
                    FROM   information_schema.tables
                    WHERE  table_schema = DATABASE()
                      AND  table_name   = 'contact_not_duplicate'
                </cfquery>
                <cfif cndExists.n GT 0>
                    <cfquery datasource="#application.datasource#">
                        INSERT INTO contact_merge_map (mergeid, tbl, pkcol, pkval, old_contactid, new_contactid, action)
                        SELECT <cfqueryparam value="#mergeid#" cfsqltype="cf_sql_integer" />, 'contact_not_duplicate', 'id',
                               id, <cfqueryparam value="#dup#" cfsqltype="cf_sql_integer" />,
                               <cfqueryparam value="#pri#" cfsqltype="cf_sql_integer" />, 'deleted'
                        FROM   contact_not_duplicate
                        WHERE  userid = <cfqueryparam value="#arguments.userid#" cfsqltype="cf_sql_integer" />
                          AND  <cfqueryparam value="#dup#" cfsqltype="cf_sql_integer" /> IN (contactid_low, contactid_high)
                    </cfquery>
                    <cfquery datasource="#application.datasource#">
                        DELETE FROM contact_not_duplicate
                        WHERE  userid = <cfqueryparam value="#arguments.userid#" cfsqltype="cf_sql_integer" />
                          AND  <cfqueryparam value="#dup#" cfsqltype="cf_sql_integer" /> IN (contactid_low, contactid_high)
                    </cfquery>
                <cfelse>
                    <cflog file="contact_merge" type="information"
                           text="contact_not_duplicate absent - cleanup skipped (merge #mergeid#)" />
                </cfif>

                <!--- 11. Apply user-chosen field values to the primary (plain columns only;
                          recordname intentionally NOT written - it may be a GENERATED column).
                          Runs BEFORE the avatar re-check and the A1 pri-first edge so those two
                          steps evaluate the keep contact's current, post-choice state. --->
                <cfset applyMergedFields(pri, arguments.userid, arguments.mergeData) />

                <!--- 12. Avatar carry-over (column half). Only when the pre-txn file copy succeeded
                          AND the keep contact STILL has no photo in its CURRENT
                          (post-applyMergedFields) state - so an explicit modal photo choice wins and
                          the carry correctly skips (the orphaned pre-txn copy is harmless). Mapped
                          as 'avatar_carried'. --->
                <cfif avatarCarry>
                    <cfquery name="qKeepPhoto" datasource="#application.datasource#">
                        SELECT contactphoto
                        FROM   contactdetails_tbl
                        WHERE  contactid = <cfqueryparam value="#pri#" cfsqltype="cf_sql_integer" />
                          AND  userid    = <cfqueryparam value="#arguments.userid#" cfsqltype="cf_sql_integer" />
                    </cfquery>
                    <cfif NOT len(trim(qKeepPhoto.contactphoto))>
                        <cfquery datasource="#application.datasource#">
                            INSERT INTO contact_merge_map (mergeid, tbl, pkcol, pkval, old_contactid, new_contactid, action)
                            VALUES (
                                <cfqueryparam value="#mergeid#" cfsqltype="cf_sql_integer" />, 'contactdetails_tbl', 'contactID',
                                <cfqueryparam value="#pri#" cfsqltype="cf_sql_integer" />,
                                <cfqueryparam value="#dup#" cfsqltype="cf_sql_integer" />,
                                <cfqueryparam value="#pri#" cfsqltype="cf_sql_integer" />, 'avatar_carried'
                            )
                        </cfquery>
                        <cfquery datasource="#application.datasource#">
                            UPDATE contactdetails_tbl
                            SET    contactphoto = <cfqueryparam value="#avatarValue#" cfsqltype="cf_sql_varchar" />
                            WHERE  contactid = <cfqueryparam value="#pri#" cfsqltype="cf_sql_integer" />
                              AND  userid    = <cfqueryparam value="#arguments.userid#" cfsqltype="cf_sql_integer" />
                        </cfquery>
                    <cfelse>
                        <cflog file="contact_merge" type="information"
                               text="avatar carry skipped: keep photo set during merge (post-applyMergedFields) pri=#pri#" />
                    </cfif>
                </cfif>

                <!--- 13. Referral pri-first edge (A1a). Runs AFTER applyMergedFields so its
                          inherit/clear logic reads the CURRENT keep referrer: if the keep contact
                          ends up referred by the duplicate (including a user-submitted refer choice
                          of the duplicate), inherit the duplicate's referrer, or clear it when that
                          would form a self/dup loop. This corrects a submitted :dup with no new
                          code and writes the referral_inherited / referral_cleared map row. --->
                <cfquery name="qRef" datasource="#application.datasource#">
                    SELECT contactid, refer_contact_id
                    FROM   contactdetails_tbl
                    WHERE  contactid IN (<cfqueryparam value="#pri#,#dup#" cfsqltype="cf_sql_integer" list="true" />)
                      AND  userid = <cfqueryparam value="#arguments.userid#" cfsqltype="cf_sql_integer" />
                </cfquery>
                <cfloop query="qRef">
                    <cfif qRef.contactid EQ pri>
                        <cfset priReferrer = qRef.refer_contact_id />
                    <cfelseif qRef.contactid EQ dup>
                        <cfset dupReferrer = qRef.refer_contact_id />
                    </cfif>
                </cfloop>
                <cfif isNumeric(priReferrer) AND priReferrer EQ dup>
                    <cfif isNumeric(dupReferrer) AND dupReferrer NEQ pri AND dupReferrer NEQ dup>
                        <cfset newReferrer = int(dupReferrer) />
                        <cfset referralActionA = "referral_inherited" />
                    <cfelse>
                        <cfset newReferrer = "" />
                        <cfset referralActionA = "referral_cleared" />
                    </cfif>
                    <cfquery datasource="#application.datasource#">
                        INSERT INTO contact_merge_map (mergeid, tbl, pkcol, pkval, old_contactid, new_contactid, action)
                        VALUES (
                            <cfqueryparam value="#mergeid#" cfsqltype="cf_sql_integer" />, 'contactdetails_tbl', 'contactID',
                            <cfqueryparam value="#pri#" cfsqltype="cf_sql_integer" />,
                            <cfqueryparam value="#dup#" cfsqltype="cf_sql_integer" />,
                            <cfqueryparam value="#pri#" cfsqltype="cf_sql_integer" />,
                            <cfqueryparam value="#referralActionA#" cfsqltype="cf_sql_varchar" />
                        )
                    </cfquery>
                    <cfquery datasource="#application.datasource#">
                        UPDATE contactdetails_tbl
                        SET    refer_contact_id = <cfqueryparam value="#newReferrer#" cfsqltype="cf_sql_integer" null="#(NOT len(newReferrer))#" />
                        WHERE  contactid = <cfqueryparam value="#pri#" cfsqltype="cf_sql_integer" />
                          AND  userid    = <cfqueryparam value="#arguments.userid#" cfsqltype="cf_sql_integer" />
                    </cfquery>
                </cfif>

                <!--- 14. Soft-delete the duplicate --->
                <cfquery datasource="#application.datasource#">
                    INSERT INTO contact_merge_map (mergeid, tbl, pkcol, pkval, old_contactid, new_contactid, action)
                    VALUES (
                        <cfqueryparam value="#mergeid#" cfsqltype="cf_sql_integer" />, 'contactdetails_tbl', 'contactid',
                        <cfqueryparam value="#dup#" cfsqltype="cf_sql_integer" />,
                        <cfqueryparam value="#dup#" cfsqltype="cf_sql_integer" />,
                        <cfqueryparam value="#pri#" cfsqltype="cf_sql_integer" />, 'softdeleted'
                    )
                </cfquery>
                <cfquery datasource="#application.datasource#">
                    UPDATE contactdetails_tbl
                    SET    isdeleted = <cfqueryparam value="1" cfsqltype="cf_sql_bit" />
                    WHERE  contactid = <cfqueryparam value="#dup#" cfsqltype="cf_sql_integer" />
                      AND  userid    = <cfqueryparam value="#arguments.userid#" cfsqltype="cf_sql_integer" />
                </cfquery>

                <!--- Stamp rows_affected on the log header --->
                <cfquery datasource="#application.datasource#">
                    UPDATE contact_merge_log
                    SET    rows_affected = (SELECT COUNT(*) FROM contact_merge_map WHERE mergeid = <cfqueryparam value="#mergeid#" cfsqltype="cf_sql_integer" />)
                    WHERE  mergeid = <cfqueryparam value="#mergeid#" cfsqltype="cf_sql_integer" />
                </cfquery>

                <cfset result.success = true />
                <cfset result.mergeid = mergeid />
                <cfset result.message = "Contacts merged successfully." />
            </cftransaction>

            <!--- merge rewrote event-attendance rows - rebuild this user's ICS feed --->
            <cftry>
                <cfset request.svc("EventService").fireIcsRegen(arguments.userid) />
                <cfcatch type="any"><!--- non-fatal: calendar regen failure must not undo a committed merge ---></cfcatch>
            </cftry>

            <cfcatch type="any">
                <cfset result.success = false />
                <cfset result.mergeid = 0 />
                <cfset result.message = "Error merging contacts: " & cfcatch.message />
                <cfset result.detail = cfcatch.detail />
                <cflog file="contact_merge" type="error"
                       text="mergeContacts FAIL userid=#arguments.userid# primary=#pri# duplicate=#dup# err=#cfcatch.message# detail=#cfcatch.detail#" />
            </cfcatch>
        </cftry>

        <cfreturn result />
    </cffunction>

    <!--- Apply chosen field values to the primary contact. Dynamic SET so only
          provided fields change. recordname is deliberately excluded. --->
    <cffunction name="applyMergedFields" access="private" returntype="void" output="false">
        <cfargument name="primaryContactId" type="numeric" required="true" />
        <cfargument name="userid"           type="numeric" required="true" />
        <cfargument name="mergeData"        type="struct"  required="true" />

        <cfset var fieldTypes = {
            "contactFullName":    "cf_sql_varchar",
            "contacttitle":       "cf_sql_varchar",
            "contactNickname":    "cf_sql_varchar",
            "contactPronoun":     "cf_sql_varchar",
            "contactMeetingLoc":  "cf_sql_varchar",
            "newsletter_yn":      "cf_sql_char",
            "googlealert_yn":     "cf_sql_char",
            "socialmedia_yn":     "cf_sql_char",
            "contactBirthday":    "cf_sql_date",
            "contactMeetingDate": "cf_sql_date",
            "refer_contact_id":   "cf_sql_integer"
        } />
        <cfset var present = [] />
        <cfset var fld = "" />
        <cfset var t   = "" />
        <cfset var raw = "" />
        <cfset var i   = 0 />

        <!--- Collect only the fields actually supplied --->
        <cfloop collection="#fieldTypes#" item="fld">
            <cfif structKeyExists(arguments.mergeData, fld)>
                <cfset arrayAppend(present, fld) />
            </cfif>
        </cfloop>
        <cfif arrayLen(present) EQ 0><cfreturn /></cfif>

        <cfquery datasource="#application.datasource#">
            UPDATE contactdetails_tbl
            SET
            <cfloop from="1" to="#arrayLen(present)#" index="i">
                <cfset fld = present[i] />
                <cfset t   = fieldTypes[fld] />
                <cfset raw = arguments.mergeData[fld] />
                <cfif i GT 1>,</cfif>
                #fld# =
                <cfif t EQ "cf_sql_date">
                    <cfqueryparam value="#raw#" cfsqltype="cf_sql_date" null="#(NOT isDate(raw))#" />
                <cfelseif t EQ "cf_sql_integer">
                    <cfqueryparam value="#raw#" cfsqltype="cf_sql_integer" null="#(NOT isNumeric(raw))#" />
                <cfelse>
                    <cfqueryparam value="#raw#" cfsqltype="#t#" null="#(NOT len(trim(raw)))#" />
                </cfif>
            </cfloop>
            WHERE contactid = <cfqueryparam value="#arguments.primaryContactId#" cfsqltype="cf_sql_integer" />
              AND userid    = <cfqueryparam value="#arguments.userid#" cfsqltype="cf_sql_integer" />
        </cfquery>
<cfif structKeyExists(request,"perfSvcQueryCount")><cfset request.perfSvcQueryCount++></cfif>
    </cffunction>

</cfcomponent>
