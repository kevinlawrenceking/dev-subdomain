<cfcomponent displayname="MasterDirectoryService" hint="DIR-WO-2 master-link orchestrator (TAO-MCD-P1). Search the master directory (co_contacts/companies/co_locations) and link/unlink a TAO contact to a master person. Orchestrates ContactService (sole contactdetails writer) and ContactItemService.createCompanyItem (canonical Company item). Never writes contactPhone/contactEmail (PD-L1). Dev-only under DIR-WO-2.">

<!--- Standard init. Services are instantiated via request.svc() (no init call),
      so all methods are self-contained and use the framework default datasource
      (bare cfquery inherits application.datasource -> abod on dev). init() is
      provided for manual instantiation only. --->
<cffunction name="init" access="public" returntype="MasterDirectoryService" output="false">
    <cfreturn this>
</cffunction>

<!--- ============================================================
      searchPeople(term, limit) -> array of person structs
      Prefix match on the BTREE fullname index (G0-11). No co_locations join.
      ============================================================ --->
<cffunction name="searchPeople" access="public" returntype="array" output="false">
    <cfargument name="term"  type="string"  required="true">
    <cfargument name="limit" type="numeric" required="false" default="10">

    <cfset var results = []>

    <!--- Guard: require at least 2 chars, else return empty --->
    <cfif len(trim(arguments.term)) LT 2>
        <cfreturn results>
    </cfif>

    <!--- Clamp limit to 1..25, default 10 --->
    <cfset var lim = int(val(arguments.limit))>
    <cfif lim LT 1><cfset lim = 10></cfif>
    <cfif lim GT 25><cfset lim = 25></cfif>

    <cfquery name="qPeople">
        SELECT cc.id AS master_co_contact_id,
               cc.fullname,
               cc.jobtitle_type,
               cc.coid,
               co.coName
        FROM co_contacts cc
        LEFT JOIN companies co ON co.coid = cc.coid
        WHERE cc.fullname LIKE <cfqueryparam value="#trim(arguments.term)#%" cfsqltype="CF_SQL_VARCHAR">
        ORDER BY cc.fullname
        LIMIT <cfqueryparam value="#lim#" cfsqltype="CF_SQL_INTEGER">
    </cfquery>
    <cfif structKeyExists(request,"perfSvcQueryCount")><cfset request.perfSvcQueryCount++></cfif>

    <cfloop query="qPeople">
        <cfset arrayAppend(results, {
            "master_co_contact_id": qPeople.master_co_contact_id,
            "fullname":             qPeople.fullname,
            "jobtitle_type":        qPeople.jobtitle_type,
            "coid":                 qPeople.coid,
            "coName":               qPeople.coName
        })>
    </cfloop>

    <cfreturn results>
</cffunction>

<!--- ============================================================
      getLocations(coid) -> array of office structs
      ============================================================ --->
<cffunction name="getLocations" access="public" returntype="array" output="false">
    <cfargument name="coid" type="numeric" required="true">

    <cfset var results = []>

    <!--- DIR-LNK-WO-7: widened to feed the link-preview office picker + the diff (office phone/email
          are the master p/e source, D-21). Ordered so the default-office candidate is first:
          address1-non-blank ahead of blank, tie-break MIN(colocid) (WO-0b default-office rule). --->
    <cfquery name="qLoc">
        SELECT colocid, location, address1, address2, city, state, zip, phone, email
        FROM co_locations
        WHERE coid = <cfqueryparam value="#arguments.coid#" cfsqltype="CF_SQL_INTEGER">
        ORDER BY (address1 IS NULL OR TRIM(address1) = '') ASC, colocid ASC
    </cfquery>
    <cfif structKeyExists(request,"perfSvcQueryCount")><cfset request.perfSvcQueryCount++></cfif>

    <cfloop query="qLoc">
        <cfset arrayAppend(results, {
            "colocid":  qLoc.colocid,
            "location": qLoc.location,
            "address1": qLoc.address1,
            "address2": qLoc.address2,
            "city":     qLoc.city,
            "state":    qLoc.state,
            "zip":      qLoc.zip,
            "phone":    qLoc.phone,
            "email":    qLoc.email
        })>
    </cfloop>

    <cfreturn results>
</cffunction>

<!--- ============================================================
      linkContactToMaster(contactid, masterCoContactId, coid, colocid, userid)
      PD-L2/L4. Idempotent, transactional. PD-L1: phone/email never written.
      ============================================================ --->
<cffunction name="linkContactToMaster" access="public" returntype="struct" output="false">
    <cfargument name="contactid"         type="numeric" required="true">
    <cfargument name="masterCoContactId" type="numeric" required="true">
    <cfargument name="coid"              type="numeric" required="false" default="0">
    <cfargument name="colocid"           type="numeric" required="false" default="0">
    <cfargument name="userid"            type="numeric" required="true">

    <!--- Ownership gate + current-state read (view read). Generic failure on miss (no existence leak). --->
    <cfquery name="qOwn">
        SELECT contactid, userid, master_co_contact_id, master_coid,
               company_location_id, contactCompany, contactCompany_src, master_linked_date
        FROM contactdetails
        WHERE contactid = <cfqueryparam value="#arguments.contactid#" cfsqltype="CF_SQL_INTEGER">
          AND userid    = <cfqueryparam value="#arguments.userid#"    cfsqltype="CF_SQL_INTEGER">
    </cfquery>
    <cfif qOwn.recordCount EQ 0>
        <cfreturn { "success": false, "message": "Contact not found." }>
    </cfif>

    <!--- Resolve the master person + company name --->
    <cfquery name="qMaster">
        SELECT cc.id AS master_co_contact_id, cc.fullname, cc.coid AS cc_coid,
               co.coid AS co_coid_check, co.coName
        FROM co_contacts cc
        LEFT JOIN companies co ON co.coid = cc.coid
        WHERE cc.id = <cfqueryparam value="#arguments.masterCoContactId#" cfsqltype="CF_SQL_INTEGER">
    </cfquery>
    <cfif qMaster.recordCount EQ 0>
        <!--- S-6 sibling: neutral message, no enumeration oracle (mirrors confirmLink). not-yours and
              does-not-exist are already caught above at qOwn (filtered by userid) with "Contact not
              found."; a valid-owned contact paired with a bad/foreign master previously returned the
              DISTINCT "Master record not found.", revealing the ownership check had passed. All three
              now return the identical neutral message. Message-only change; no behavioral change. This
              is the legacy DIR-WO-2 link path (uncalled by the WO-7 UI but reachable by direct POST);
              its data-integrity bypass posture is tracked separately for a retirement ruling. --->
        <cfreturn { "success": false, "message": "Contact not found." }>
    </cfif>

    <cfset var coName    = qMaster.coName>
    <!--- F-2 (Q-3.1/3.2 amended): coid derived SOLELY from the master person row, and ONLY when
          the referenced companies row actually exists (co_coid_check non-null). Client-supplied
          arguments.coid is IGNORED. Zero / dangling positive / no-company -> "" -> master_coid NULL,
          company parts NULL, no fill, no item. Never write a coid the FK cannot satisfy. --->
    <cfset var newCoid = (val(qMaster.cc_coid) GT 0 AND len(qMaster.co_coid_check) AND val(qMaster.co_coid_check) GT 0) ? int(qMaster.cc_coid) : "">
    <!--- F-2 (Q-3.3): colocid accepted only if >0 AND it belongs to the derived company
          (co_locations.coid = newCoid). Wrong-company / missing / non-numeric / no-company -> "" -> NULL. --->
    <cfset var newColoc = "">
    <cfif val(arguments.colocid) GT 0 AND len(newCoid) AND val(newCoid) GT 0>
        <cfquery name="qLocChk">
            SELECT 1 FROM co_locations
            WHERE colocid = <cfqueryparam value="#int(arguments.colocid)#" cfsqltype="CF_SQL_INTEGER">
              AND coid    = <cfqueryparam value="#int(newCoid)#" cfsqltype="CF_SQL_INTEGER">
        </cfquery>
        <cfif qLocChk.recordCount EQ 1><cfset newColoc = int(arguments.colocid)></cfif>
    </cfif>
    <cfset var preSrc    = qOwn.contactCompany_src>
    <cfset var preCompany = qOwn.contactCompany>
    <cfset var itemAction = "none">

    <cftransaction>
        <!--- DIR-LNK-WO-7 BRIDGE DISABLE: the DIR-WO-2 Company-item maintenance block (create /
              rename / soft-delete on link) is REMOVED here. Linking no longer writes Company
              contactitems (spec 15.2; the D-19 relink-accumulation source). The company value is
              carried solely by the contactCompany column (the read source since WO-5). Historical
              bridge items are cleaned up in WO-11. This legacy endpoint is now column-only and is
              slated for retirement once the WO-7 preview flow (confirmLink) replaces it; itemAction
              stays "none". --->

        <!--- Step 2: Snapshot + pointers via ContactService (sole contactdetails writer). --->
        <cfset var upd = {
            "master_co_contact_id": int(arguments.masterCoContactId),
            "master_coid":          newCoid,
            "company_location_id":  newColoc,
            "master_last_sync":     now()
        }>

        <!--- contactCompany provenance rules:
              - blank snapshot -> fill + _src='master'
              - _src='master'  -> refresh to current coName (PD-L4)
              - _src='user'    -> never touch --->
        <cfif len(trim(coName))>
            <cfif NOT len(trim(preCompany))>
                <cfset upd["contactCompany"]     = coName>
                <cfset upd["contactCompany_src"] = "master">
            <cfelseif preSrc EQ "master">
                <cfset upd["contactCompany"]     = coName>
                <cfset upd["contactCompany_src"] = "master">
            </cfif>
        <cfelseif preSrc EQ "master">
            <!--- F-3: re-link to a no-company master -> clear the stale master-owned snapshot --->
            <cfset upd["contactCompany"]     = "">
            <cfset upd["contactCompany_src"] = "user">
        </cfif>

        <!--- master_linked_date only when currently NULL --->
        <cfif NOT len(trim(qOwn.master_linked_date))>
            <cfset upd["master_linked_date"] = now()>
        </cfif>

        <cfset request.svc("ContactService").update(contactid = arguments.contactid, data = upd)>
    </cftransaction>

    <cflog file="master_link" type="information"
           text="LINK contactid=#arguments.contactid# userid=#arguments.userid# master_co_contact_id=#arguments.masterCoContactId# master_coid=#(len(newCoid) ? newCoid : 'null')# company_location_id=#(len(newColoc) ? newColoc : 'null')# itemAction=#itemAction# companySrc=#(structKeyExists(upd,'contactCompany_src') ? upd.contactCompany_src : preSrc)#">

    <cfreturn {
        "success": true,
        "message": "Linked.",
        "data": {
            "master_co_contact_id": arguments.masterCoContactId,
            "master_coid":          (len(newCoid) ? newCoid : ""),
            "company_location_id":  (len(newColoc) ? newColoc : ""),
            "contactCompany":       coName,
            "itemAction":           itemAction
        }
    }>
</cffunction>

<!--- ============================================================
      confirmLink(contactid, masterCoContactId, colocid, photoChoice, userid) -> struct
      DIR-LNK-WO-7 link/relink ENGINE (fed by the preview modal's confirm endpoint). One
      transaction: preserve displaced user primaries as items (spec 7.3, BEFORE population) ->
      populate the master snapshot (7.4; blank office p/e mirror the master per 7.5) -> apply the
      photo choice -> write audit rows. Bridge OFF: no Company item is created. Server re-derives
      every master value from co_contacts/companies/co_locations; the client supplies ids + the
      photo choice only. Idempotent: re-confirm to the SAME master is a no-op success.
      Name choice is not offered (WO-7 ruling 1: name picker dropped, names stay user-owned).
      ============================================================ --->
<cffunction name="confirmLink" access="public" returntype="struct" output="false">
    <cfargument name="contactid"         type="numeric" required="true">
    <cfargument name="masterCoContactId" type="numeric" required="true">
    <cfargument name="colocid"           type="numeric" required="false" default="0">
    <cfargument name="photoChoice"       type="string"  required="false" default="user">
    <cfargument name="userid"            type="numeric" required="true">

    <cfset var cs  = request.svc("ContactService")>
    <cfset var cis = request.svc("ContactItemService")>
    <cfset var aud = request.svc("MasterAuditService")>
    <cfset var coName   = "">
    <cfset var newCoid  = "">
    <cfset var newColoc = "">
    <cfset var offPhone = "">
    <cfset var offEmail = "">
    <cfset var isRelink = false>
    <cfset var prevMaster = 0>
    <cfset var adoptPhoto = (lCase(trim(arguments.photoChoice)) EQ "master")>
    <cfset var idemBase = "WO7:" & int(arguments.contactid) & ":" & int(arguments.masterCoContactId)>
    <cfset var preservedCount = 0>
    <cfset var ok = true>
    <cfset var fields = []>
    <cfset var f = "">
    <cfset var valCol = "">
    <cfset var snap = "">
    <cfset var storedColoc = 0>
    <cfset var chosenColoc = 0>
    <cfset var officeUnchanged = false>
    <cfset var photoUnchanged = false>

    <!--- Ownership + current-state read (view read; generic failure on miss, no existence leak) --->
    <cfquery name="qOwn">
        SELECT contactid, userid, master_co_contact_id, company_location_id, contactPhoto_src,
               contactPhone, contactPhone_src, contactEmail, contactEmail_src,
               contactCompany, contactCompany_src
        FROM contactdetails
        WHERE contactid = <cfqueryparam value="#arguments.contactid#" cfsqltype="CF_SQL_INTEGER">
          AND userid    = <cfqueryparam value="#arguments.userid#"    cfsqltype="CF_SQL_INTEGER">
          AND isdeleted = <cfqueryparam value="0" cfsqltype="CF_SQL_BIT">
    </cfquery>
    <cfif qOwn.recordCount EQ 0>
        <cfreturn { "success": false, "message": "Contact not found." }>
    </cfif>

    <!--- S-7 FIX: link-epoch discriminator folded into idemBase. Every idempotency key built below
          (PRESERVE / SNAP / LINK / RELINK, and the same-master office-change SNAP) must be identical
          for concurrent double-submits of ONE link event (so INSERT IGNORE dedups the retry) yet
          DIFFER across distinct link events for the same contact+master - otherwise a
          link -> unlink -> relink-to-the-same-master regenerates byte-identical keys, the audit
          INSERT IGNORE no-ops, and the write path fails (S-7). The append-only master_audit_tbl is
          itself the epoch source: MAX(auditID) for this contact is read from committed pre-mutation
          state, so two concurrent submits observe the same value (deterministic within the request),
          while any intervening unlink writes RESTORE/CLEAR rows that advance it (distinct across
          events). Indexed by IX_master_audit_contact. No schema change; existing rows and their keys
          are untouched; the unlink path keeps its own UNLINK:prevMaster discriminator unchanged. --->
    <cfquery name="qEpoch">
        SELECT COALESCE(MAX(auditID), 0) AS linkEpoch
        FROM master_audit_tbl
        WHERE contactID = <cfqueryparam value="#arguments.contactid#" cfsqltype="CF_SQL_INTEGER">
    </cfquery>
    <cfset idemBase = idemBase & ":e" & val(qEpoch.linkEpoch)>

    <!--- FLAG-1 (2a): the no-op discriminator is the PAYLOAD (master + office + photo), not the
          master alone. The same-master branch below decides true no-op vs office/photo re-snapshot;
          it needs the office phone/email, so it is placed AFTER master + office resolution. --->

    <!--- Resolve master person + company (re-derived; client coid ignored) --->
    <cfquery name="qMaster">
        SELECT cc.id, cc.fullname, cc.coid AS cc_coid, co.coid AS co_coid_check, co.coName
        FROM co_contacts cc
        LEFT JOIN companies co ON co.coid = cc.coid
        WHERE cc.id = <cfqueryparam value="#arguments.masterCoContactId#" cfsqltype="CF_SQL_INTEGER">
    </cfquery>
    <cfif qMaster.recordCount EQ 0>
        <!--- S-6: neutral message, no enumeration oracle. not-yours and does-not-exist are already
              caught above at qOwn (filtered by userid) and return "Contact not found."; a valid-owned
              contact paired with a bad/foreign master previously returned the DISTINCT "Master record
              not found.", which revealed that the ownership check had passed. All three now return the
              identical neutral message so the response cannot be used to probe ownership. --->
        <cfreturn { "success": false, "message": "Contact not found." }>
    </cfif>
    <cfset coName  = trim(qMaster.coName)>
    <cfset newCoid = (val(qMaster.cc_coid) GT 0 AND len(qMaster.co_coid_check) AND val(qMaster.co_coid_check) GT 0) ? int(qMaster.cc_coid) : "">

    <!--- Resolve the chosen office + its phone/email (the master p/e source, D-21). colocid accepted
          only if it belongs to the derived company. No / blank office -> blank master p/e, mirrored
          per spec 7.5 (Q4). --->
    <cfif val(arguments.colocid) GT 0 AND len(newCoid) AND val(newCoid) GT 0>
        <cfquery name="qLoc">
            SELECT colocid, phone, email
            FROM co_locations
            WHERE colocid = <cfqueryparam value="#int(arguments.colocid)#" cfsqltype="CF_SQL_INTEGER">
              AND coid    = <cfqueryparam value="#int(newCoid)#" cfsqltype="CF_SQL_INTEGER">
        </cfquery>
        <cfif qLoc.recordCount EQ 1>
            <cfset newColoc = int(qLoc.colocid)>
            <cfset offPhone = trim(qLoc.phone)>
            <cfset offEmail = trim(qLoc.email)>
        </cfif>
    </cfif>

    <cfset isRelink   = (len(trim(qOwn.master_co_contact_id)) AND val(qOwn.master_co_contact_id) NEQ int(arguments.masterCoContactId))>
    <cfset prevMaster = (len(trim(qOwn.master_co_contact_id)) ? int(qOwn.master_co_contact_id) : 0)>

    <!--- FLAG-1 (2a): the SAME master is already linked. A true no-op (and double-submit protection)
          applies ONLY when master AND office AND photo choice are all unchanged. If the office or the
          photo choice changed, re-snapshot phone/email/company from the newly chosen office and audit
          MASTER_SNAPSHOT_POPULATED - the person did not change, so this is NOT a relink. No
          preservation pass here: the displaced values are already master-sourced (spec 15). --->
    <cfif len(trim(qOwn.master_co_contact_id)) AND val(qOwn.master_co_contact_id) EQ int(arguments.masterCoContactId)>
        <cfset storedColoc     = len(trim(qOwn.company_location_id)) ? int(qOwn.company_location_id) : 0>
        <cfset chosenColoc     = len(newColoc) ? int(newColoc) : 0>
        <cfset officeUnchanged = (storedColoc EQ chosenColoc)>
        <cfset photoUnchanged  = ( (adoptPhoto AND qOwn.contactPhoto_src EQ "master") OR (NOT adoptPhoto AND qOwn.contactPhoto_src EQ "user") )>

        <cfif officeUnchanged AND photoUnchanged>
            <cfreturn { "success": true, "message": "No change.", "data": { "noop": true } }>
        </cfif>

        <cftransaction>
            <cfset snap = cs.writeLinkSnapshot(
                        contactid=arguments.contactid, userid=arguments.userid,
                        phone=offPhone, email=offEmail, company=coName,
                        masterCoContactId=int(arguments.masterCoContactId),
                        masterCoid=(len(newCoid) ? newCoid : ""), colocid=(len(newColoc) ? newColoc : ""),
                        adoptPhoto=adoptPhoto)>
            <cfif NOT snap.success>
                <cftransaction action="rollback" />
                <cfset ok = false>
            <cfelse>
                <cfset aud.record(contactID=arguments.contactid, actor_userid=arguments.userid, actor_type="user",
                    action_type="MASTER_SNAPSHOT_POPULATED", master_co_contact_id=int(arguments.masterCoContactId),
                    master_coid=(len(newCoid) ? newCoid : 0), company_location_id=chosenColoc,
                    field_name="contactPhone", old_value=trim(qOwn.contactPhone), new_value=offPhone, new_source="master",
                    reason="office/photo change", idempotency_key=idemBase & ":SNAP:contactPhone:coloc" & chosenColoc)>
                <cfset aud.record(contactID=arguments.contactid, actor_userid=arguments.userid, actor_type="user",
                    action_type="MASTER_SNAPSHOT_POPULATED", master_co_contact_id=int(arguments.masterCoContactId),
                    master_coid=(len(newCoid) ? newCoid : 0), company_location_id=chosenColoc,
                    field_name="contactEmail", old_value=trim(qOwn.contactEmail), new_value=offEmail, new_source="master",
                    reason="office/photo change", idempotency_key=idemBase & ":SNAP:contactEmail:coloc" & chosenColoc)>
                <cfset aud.record(contactID=arguments.contactid, actor_userid=arguments.userid, actor_type="user",
                    action_type="MASTER_SNAPSHOT_POPULATED", master_co_contact_id=int(arguments.masterCoContactId),
                    master_coid=(len(newCoid) ? newCoid : 0), company_location_id=chosenColoc,
                    field_name="contactCompany", old_value=trim(qOwn.contactCompany), new_value=coName, new_source="master",
                    reason="office/photo change", idempotency_key=idemBase & ":SNAP:contactCompany:coloc" & chosenColoc)>
            </cfif>
        </cftransaction>

        <cfif NOT ok>
            <cfreturn { "success": false, "message": "The contact changed while updating. Nothing was saved - reload and try again." }>
        </cfif>

        <cflog file="master_link" type="information"
               text="CONFIRMLINK-UPDATE contactid=#arguments.contactid# userid=#arguments.userid# master=#arguments.masterCoContactId# colocid=#(len(newColoc) ? newColoc : 'null')# officeChanged=#(NOT officeUnchanged)# photoChanged=#(NOT photoUnchanged)#">

        <cfreturn {
            "success": true, "message": "Updated.",
            "data": {
                "master_co_contact_id": int(arguments.masterCoContactId),
                "company_location_id":  (len(newColoc) ? newColoc : ""),
                "officeChanged":        (NOT officeUnchanged),
                "photoChanged":         (NOT photoUnchanged)
            }
        }>
    </cfif>

    <cfset fields = [
        { "cat":"Phone",   "field":"contactPhone",   "cur":trim(qOwn.contactPhone),   "master":offPhone, "src":qOwn.contactPhone_src },
        { "cat":"Email",   "field":"contactEmail",   "cur":trim(qOwn.contactEmail),   "master":offEmail, "src":qOwn.contactEmail_src },
        { "cat":"Company", "field":"contactCompany", "cur":trim(qOwn.contactCompany), "master":coName,   "src":qOwn.contactCompany_src }
    ]>

    <cftransaction>
        <!--- STEP 1: preserve displaced user primaries as items (7.3), BEFORE population. Preserve
              only when the value is USER-sourced (never preserve a prior master value into items -
              spec 15; matters on relink where current primaries are _src='master') AND non-blank AND
              differs from the incoming master value AND no equivalent active item exists (7.3.4). --->
        <cfloop array="#fields#" index="f">
            <!--- L-3: skip-if-equal-master is TRIM + CASE-INSENSITIVE, no digit-normalization of
                  phone (D-5: 25 distinct formats on record). Preserving a near-duplicate is safer
                  than losing a real value. --->
            <cfif f.src EQ "user" AND len(f.cur) AND compareNoCase(trim(f.cur), trim(f.master)) NEQ 0>
                <cfset valCol = (f.cat EQ "Company") ? "valueCompany" : "valuetext">
                <cfquery name="qEq">
                    SELECT 1 FROM contactitems_tbl
                    WHERE contactID     = <cfqueryparam value="#arguments.contactid#" cfsqltype="CF_SQL_INTEGER">
                      AND valueCategory = <cfqueryparam value="#f.cat#" cfsqltype="CF_SQL_VARCHAR">
                      AND itemStatus    = <cfqueryparam value="Active" cfsqltype="CF_SQL_VARCHAR">
                      AND IsDeleted     = <cfqueryparam value="0" cfsqltype="CF_SQL_BIT">
                      AND #valCol#      = <cfqueryparam value="#f.cur#" cfsqltype="CF_SQL_VARCHAR">
                    LIMIT 1
                </cfquery>
                <cfif qEq.recordCount EQ 0>
                    <cfset cis.createPreservedItem(contactid=arguments.contactid, category=f.cat, value=f.cur)>
                    <cfset preservedCount = preservedCount + 1>
                    <cfset aud.record(
                        contactID=arguments.contactid, actor_userid=arguments.userid, actor_type="user",
                        action_type="PRELINK_VALUE_PRESERVED", master_co_contact_id=int(arguments.masterCoContactId),
                        master_coid=(len(newCoid) ? newCoid : 0), company_location_id=(len(newColoc) ? newColoc : 0),
                        field_name=f.field, old_value=f.cur, previous_source="user",
                        reason="pre-link preservation", idempotency_key=idemBase & ":PRESERVE:" & f.field)>
                </cfif>
            </cfif>
        </cfloop>

        <!--- STEP 2: snapshot population (7.4). Blank office p/e mirror the master (7.5). --->
        <cfset snap = cs.writeLinkSnapshot(
                    contactid=arguments.contactid, userid=arguments.userid,
                    phone=offPhone, email=offEmail, company=coName,
                    masterCoContactId=int(arguments.masterCoContactId),
                    masterCoid=(len(newCoid) ? newCoid : ""), colocid=(len(newColoc) ? newColoc : ""),
                    adoptPhoto=adoptPhoto)>

        <cfif NOT snap.success>
            <!--- Ownership/state race: nothing written. Roll back any preserves + preserve-audits. --->
            <cftransaction action="rollback" />
            <cfset ok = false>
        <cfelse>
            <!--- STEP 3: audit the snapshot (per field) + the link/relink event. --->
            <cfset aud.record(contactID=arguments.contactid, actor_userid=arguments.userid, actor_type="user",
                action_type="MASTER_SNAPSHOT_POPULATED", master_co_contact_id=int(arguments.masterCoContactId),
                master_coid=(len(newCoid) ? newCoid : 0), company_location_id=(len(newColoc) ? newColoc : 0),
                field_name="contactPhone", new_value=offPhone, new_source="master",
                idempotency_key=idemBase & ":SNAP:contactPhone")>
            <cfset aud.record(contactID=arguments.contactid, actor_userid=arguments.userid, actor_type="user",
                action_type="MASTER_SNAPSHOT_POPULATED", master_co_contact_id=int(arguments.masterCoContactId),
                master_coid=(len(newCoid) ? newCoid : 0), company_location_id=(len(newColoc) ? newColoc : 0),
                field_name="contactEmail", new_value=offEmail, new_source="master",
                idempotency_key=idemBase & ":SNAP:contactEmail")>
            <cfset aud.record(contactID=arguments.contactid, actor_userid=arguments.userid, actor_type="user",
                action_type="MASTER_SNAPSHOT_POPULATED", master_co_contact_id=int(arguments.masterCoContactId),
                master_coid=(len(newCoid) ? newCoid : 0), company_location_id=(len(newColoc) ? newColoc : 0),
                field_name="contactCompany", new_value=coName, new_source="master",
                idempotency_key=idemBase & ":SNAP:contactCompany")>

            <cfif isRelink>
                <cfset aud.record(contactID=arguments.contactid, actor_userid=arguments.userid, actor_type="user",
                    action_type="MASTER_RELINKED", master_co_contact_id=int(arguments.masterCoContactId),
                    master_coid=(len(newCoid) ? newCoid : 0), company_location_id=(len(newColoc) ? newColoc : 0),
                    old_value=prevMaster, new_value=int(arguments.masterCoContactId),
                    reason="relink from master_co_contact_id " & prevMaster, idempotency_key=idemBase & ":RELINK")>
            <cfelse>
                <cfset aud.record(contactID=arguments.contactid, actor_userid=arguments.userid, actor_type="user",
                    action_type="LINK_CREATED", master_co_contact_id=int(arguments.masterCoContactId),
                    master_coid=(len(newCoid) ? newCoid : 0), company_location_id=(len(newColoc) ? newColoc : 0),
                    reason="link", idempotency_key=idemBase & ":LINK")>
            </cfif>
        </cfif>
    </cftransaction>

    <cfif NOT ok>
        <cfreturn { "success": false, "message": "The contact changed while linking. Nothing was saved - reload the contact and try again." }>
    </cfif>

    <cflog file="master_link" type="information"
           text="CONFIRMLINK contactid=#arguments.contactid# userid=#arguments.userid# master=#arguments.masterCoContactId# coid=#(len(newCoid) ? newCoid : 'null')# colocid=#(len(newColoc) ? newColoc : 'null')# relink=#isRelink# preserved=#preservedCount# photo=#lCase(trim(arguments.photoChoice))#">

    <cfreturn {
        "success": true,
        "message": (isRelink ? "Relinked." : "Linked."),
        "data": {
            "master_co_contact_id": int(arguments.masterCoContactId),
            "master_coid":          (len(newCoid) ? newCoid : ""),
            "company_location_id":  (len(newColoc) ? newColoc : ""),
            "relink":               isRelink,
            "preserved":            preservedCount
        }
    }>
</cffunction>

<!--- ============================================================
      unlinkMaster(contactid, userid)  -- DIR-LNK-WO-7 restore semantics (spec 11.4)
      ============================================================ --->
<cffunction name="unlinkMaster" access="public" returntype="struct" output="false">
    <cfargument name="contactid" type="numeric" required="true">
    <cfargument name="userid"    type="numeric" required="true">

    <cfset var cs  = request.svc("ContactService")>
    <cfset var aud = request.svc("MasterAuditService")>
    <cfset var prevMaster   = 0>
    <cfset var idemBase     = "">
    <cfset var fields       = []>
    <cfset var f            = "">
    <cfset var restore      = {}>
    <cfset var valCol       = "">
    <cfset var st           = "">
    <cfset var us           = "">
    <cfset var ok           = true>
    <cfset var restoredCount = 0>
    <cfset var clearedCount  = 0>

    <!--- Ownership + pre-mutation state read --->
    <cfquery name="qOwn">
        SELECT contactid, userid, master_co_contact_id, master_coid,
               contactPhone, contactPhone_src, contactEmail, contactEmail_src,
               contactCompany, contactCompany_src
        FROM contactdetails
        WHERE contactid = <cfqueryparam value="#arguments.contactid#" cfsqltype="CF_SQL_INTEGER">
          AND userid    = <cfqueryparam value="#arguments.userid#"    cfsqltype="CF_SQL_INTEGER">
          AND isdeleted = <cfqueryparam value="0" cfsqltype="CF_SQL_BIT">
    </cfquery>
    <cfif qOwn.recordCount EQ 0>
        <cfreturn { "success": false, "message": "Contact not found." }>
    </cfif>

    <!--- Idempotent no-op: not linked --->
    <cfif NOT len(trim(qOwn.master_co_contact_id))>
        <cfreturn { "success": true, "message": "Already unlinked.", "data": { "noop": true } }>
    </cfif>

    <cfset prevMaster = int(qOwn.master_co_contact_id)>
    <cfset idemBase   = "WO7:" & int(arguments.contactid) & ":UNLINK:" & prevMaster>

    <cfset fields = [
        { "cat":"Phone",   "field":"contactPhone",   "cur":trim(qOwn.contactPhone),   "src":qOwn.contactPhone_src },
        { "cat":"Email",   "field":"contactEmail",   "cur":trim(qOwn.contactEmail),   "src":qOwn.contactEmail_src },
        { "cat":"Company", "field":"contactCompany", "cur":trim(qOwn.contactCompany), "src":qOwn.contactCompany_src }
    ]>

    <!--- Resolve the restore value per field (R-B precedence), READ-ONLY here (writes are in the txn):
          master-owned field -> (1) most-recent ACTIVE preserved item value; else (2) most-recent
          PRELINK_VALUE_PRESERVED audit old_value; else (3) blank/clear. user-owned field -> keep. --->
    <cfloop array="#fields#" index="f">
        <cfset restore[f.field] = { "val":"", "itemID":0, "source":"cleared" }>
        <cfif f.src EQ "master">
            <cfset valCol = (f.cat EQ "Company") ? "valueCompany" : "valuetext">
            <cfquery name="qItem">
                SELECT itemID, #valCol# AS itemVal
                FROM contactitems_tbl
                WHERE contactID     = <cfqueryparam value="#arguments.contactid#" cfsqltype="CF_SQL_INTEGER">
                  AND valueCategory = <cfqueryparam value="#f.cat#" cfsqltype="CF_SQL_VARCHAR">
                  AND itemStatus    = <cfqueryparam value="Active" cfsqltype="CF_SQL_VARCHAR">
                  AND IsDeleted     = <cfqueryparam value="0" cfsqltype="CF_SQL_BIT">
                ORDER BY itemID DESC
                LIMIT 1
            </cfquery>
            <cfif qItem.recordCount EQ 1 AND len(trim(qItem.itemVal))>
                <cfset restore[f.field] = { "val":trim(qItem.itemVal), "itemID":int(qItem.itemID), "source":"item" }>
            <cfelse>
                <cfquery name="qAud">
                    SELECT old_value
                    FROM master_audit_tbl
                    WHERE contactID   = <cfqueryparam value="#arguments.contactid#" cfsqltype="CF_SQL_INTEGER">
                      AND action_type = <cfqueryparam value="PRELINK_VALUE_PRESERVED" cfsqltype="CF_SQL_VARCHAR">
                      AND field_name  = <cfqueryparam value="#f.field#" cfsqltype="CF_SQL_VARCHAR">
                    ORDER BY auditID DESC
                    LIMIT 1
                </cfquery>
                <cfif qAud.recordCount EQ 1 AND len(trim(qAud.old_value))>
                    <cfset restore[f.field] = { "val":trim(qAud.old_value), "itemID":0, "source":"audit" }>
                </cfif>
            </cfif>
        <cfelse>
            <!--- user-owned field: keep the current value untouched (spec 11.4 step 3) --->
            <cfset restore[f.field] = { "val":f.cur, "itemID":0, "source":"kept" }>
        </cfif>
    </cfloop>

    <cftransaction>
        <!--- Consume (soft-delete) any preserved item used as a restore source (R-B). --->
        <cfloop array="#fields#" index="f">
            <cfif restore[f.field].itemID GT 0>
                <cfquery>
                    UPDATE contactitems_tbl
                    SET IsDeleted = <cfqueryparam value="1" cfsqltype="CF_SQL_BIT">
                    WHERE itemID    = <cfqueryparam value="#restore[f.field].itemID#" cfsqltype="CF_SQL_INTEGER">
                      AND contactID = <cfqueryparam value="#arguments.contactid#" cfsqltype="CF_SQL_INTEGER">
                </cfquery>
            </cfif>
        </cfloop>

        <!--- Restore/clear the three primaries + clear pointers (one enforced UPDATE). --->
        <cfset us = cs.writeUnlinkState(
                    contactid=arguments.contactid, userid=arguments.userid,
                    phone=restore.contactPhone.val, email=restore.contactEmail.val, company=restore.contactCompany.val)>

        <cfif NOT us.success>
            <cftransaction action="rollback" />
            <cfset ok = false>
        <cfelse>
            <cfloop array="#fields#" index="f">
                <cfset st = restore[f.field].source>
                <cfif st EQ "item" OR st EQ "audit">
                    <cfset restoredCount = restoredCount + 1>
                    <cfset aud.record(contactID=arguments.contactid, actor_userid=arguments.userid, actor_type="user",
                        action_type="PRELINK_VALUE_RESTORED", master_co_contact_id=prevMaster,
                        field_name=f.field, new_value=restore[f.field].val, new_source="user",
                        reason=(st EQ "item" ? ("restored from consumed item " & restore[f.field].itemID) : "restored from audit history"),
                        idempotency_key=idemBase & ":RESTORE:" & f.field)>
                <cfelseif st EQ "cleared">
                    <cfset clearedCount = clearedCount + 1>
                    <cfset aud.record(contactID=arguments.contactid, actor_userid=arguments.userid, actor_type="user",
                        action_type="PRIMARY_FIELD_CLEARED_AFTER_UNLINK", master_co_contact_id=prevMaster,
                        field_name=f.field, previous_source="master",
                        reason="no reliable pre-link value", idempotency_key=idemBase & ":CLEAR:" & f.field)>
                </cfif>
            </cfloop>
        </cfif>
    </cftransaction>

    <cfif NOT ok>
        <cfreturn { "success": false, "message": "The contact changed while unlinking. Nothing was saved - reload and try again." }>
    </cfif>

    <cflog file="master_link" type="information"
           text="UNLINK contactid=#arguments.contactid# userid=#arguments.userid# prevMaster=#prevMaster# restored=#restoredCount# cleared=#clearedCount#">

    <cfreturn { "success": true, "message": "Unlinked.", "data": { "restored": restoredCount, "cleared": clearedCount } }>
</cffunction>

</cfcomponent>
