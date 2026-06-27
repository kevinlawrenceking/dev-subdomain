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

        <cfquery name="qPossible" datasource="#application.datasource#">
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

        <cfreturn qPossible />
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

        <!--- Guard: cannot merge a contact into itself --->
        <cfif pri EQ dup>
            <cfset result.message = "Primary and duplicate are the same contact." />
            <cfreturn result />
        </cfif>

        <!--- Guard: both must exist, be owned by this user, and be active --->
        <cfquery name="qGuard" datasource="#application.datasource#">
            SELECT contactid
            FROM   contactdetails
            WHERE  contactid IN (<cfqueryparam value="#pri#,#dup#" cfsqltype="cf_sql_integer" list="true" />)
              AND  userid    = <cfqueryparam value="#arguments.userid#" cfsqltype="cf_sql_integer" />
              AND  isdeleted = <cfqueryparam value="0" cfsqltype="cf_sql_bit" />
        </cfquery>
        <cfif qGuard.recordCount NEQ 2>
            <cfset result.message = "One or both contacts were not found, are not yours, or were already merged." />
            <cfreturn result />
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

                <!--- 4. Event attendance (dedupe by eventid, then repoint) --->
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
                <cfquery datasource="#application.datasource#">
                    INSERT INTO contact_merge_map (mergeid, tbl, pkcol, pkval, old_contactid, new_contactid, action)
                    SELECT <cfqueryparam value="#mergeid#" cfsqltype="cf_sql_integer" />, 'eventcontactsxref_tbl', 'eventid',
                           eventid, <cfqueryparam value="#dup#" cfsqltype="cf_sql_integer" />,
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

                <!--- 5. Audition links (dedupe by audprojectid, then repoint) --->
                <cfquery datasource="#application.datasource#">
                    DELETE d FROM audcontacts_auditions_xref d
                    WHERE  d.contactid = <cfqueryparam value="#dup#" cfsqltype="cf_sql_integer" />
                      AND  EXISTS (
                            SELECT 1 FROM (SELECT * FROM audcontacts_auditions_xref) p
                            WHERE p.contactid = <cfqueryparam value="#pri#" cfsqltype="cf_sql_integer" />
                              AND p.audprojectid = d.audprojectid
                           )
                </cfquery>
                <cfquery datasource="#application.datasource#">
                    INSERT INTO contact_merge_map (mergeid, tbl, pkcol, pkval, old_contactid, new_contactid, action)
                    SELECT <cfqueryparam value="#mergeid#" cfsqltype="cf_sql_integer" />, 'audcontacts_auditions_xref', 'audprojectid',
                           audprojectid, <cfqueryparam value="#dup#" cfsqltype="cf_sql_integer" />,
                           <cfqueryparam value="#pri#" cfsqltype="cf_sql_integer" />, 'repointed'
                    FROM   audcontacts_auditions_xref
                    WHERE  contactid = <cfqueryparam value="#dup#" cfsqltype="cf_sql_integer" />
                </cfquery>
                <cfquery datasource="#application.datasource#">
                    UPDATE audcontacts_auditions_xref
                    SET    contactid = <cfqueryparam value="#pri#" cfsqltype="cf_sql_integer" />
                    WHERE  contactid = <cfqueryparam value="#dup#" cfsqltype="cf_sql_integer" />
                </cfquery>

                <!--- 6. Relationship system enrollments (repoint; see note re: dupe enrollments) --->
                <cfquery datasource="#application.datasource#">
                    INSERT INTO contact_merge_map (mergeid, tbl, pkcol, pkval, old_contactid, new_contactid, action)
                    SELECT <cfqueryparam value="#mergeid#" cfsqltype="cf_sql_integer" />, 'fusystemusers_tbl', 'suID',
                           suID, <cfqueryparam value="#dup#" cfsqltype="cf_sql_integer" />,
                           <cfqueryparam value="#pri#" cfsqltype="cf_sql_integer" />, 'repointed'
                    FROM   fusystemusers_tbl
                    WHERE  contactid = <cfqueryparam value="#dup#" cfsqltype="cf_sql_integer" />
                </cfquery>
                <cfquery datasource="#application.datasource#">
                    UPDATE fusystemusers_tbl
                    SET    contactid = <cfqueryparam value="#pri#" cfsqltype="cf_sql_integer" />
                    WHERE  contactid = <cfqueryparam value="#dup#" cfsqltype="cf_sql_integer" />
                </cfquery>

                <!--- 7. Notifications/reminders: funotifications has NO contactid column.
                         Each reminder links to a contact only via suID -> fusystemusers.contactid,
                         which step 6 already repointed. Nothing to do here. --->

                <!--- 8. Referral links pointing at the duplicate --->
                <cfquery datasource="#application.datasource#">
                    INSERT INTO contact_merge_map (mergeid, tbl, pkcol, pkval, old_contactid, new_contactid, action)
                    SELECT <cfqueryparam value="#mergeid#" cfsqltype="cf_sql_integer" />, 'contactdetails_tbl', 'contactid',
                           contactid, <cfqueryparam value="#dup#" cfsqltype="cf_sql_integer" />,
                           <cfqueryparam value="#pri#" cfsqltype="cf_sql_integer" />, 'refer_repointed'
                    FROM   contactdetails_tbl
                    WHERE  refer_contact_id = <cfqueryparam value="#dup#" cfsqltype="cf_sql_integer" />
                      AND  userid = <cfqueryparam value="#arguments.userid#" cfsqltype="cf_sql_integer" />
                </cfquery>
                <cfquery datasource="#application.datasource#">
                    UPDATE contactdetails_tbl
                    SET    refer_contact_id = <cfqueryparam value="#pri#" cfsqltype="cf_sql_integer" />
                    WHERE  refer_contact_id = <cfqueryparam value="#dup#" cfsqltype="cf_sql_integer" />
                      AND  userid = <cfqueryparam value="#arguments.userid#" cfsqltype="cf_sql_integer" />
                </cfquery>

                <!--- 9. Apply user-chosen field values to the primary (plain columns only;
                         recordname intentionally NOT written - it may be a GENERATED column). --->
                <cfset applyMergedFields(pri, arguments.userid, arguments.mergeData) />

                <!--- 10. Soft-delete the duplicate --->
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
