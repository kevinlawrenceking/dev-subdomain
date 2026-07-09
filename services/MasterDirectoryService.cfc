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

    <cfquery name="qLoc">
        SELECT colocid, location, address1, city, state
        FROM co_locations
        WHERE coid = <cfqueryparam value="#arguments.coid#" cfsqltype="CF_SQL_INTEGER">
        ORDER BY colocid
    </cfquery>
    <cfif structKeyExists(request,"perfSvcQueryCount")><cfset request.perfSvcQueryCount++></cfif>

    <cfloop query="qLoc">
        <cfset arrayAppend(results, {
            "colocid":  qLoc.colocid,
            "location": qLoc.location,
            "address1": qLoc.address1,
            "city":     qLoc.city,
            "state":    qLoc.state
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
        SELECT cc.id AS master_co_contact_id, cc.fullname, cc.coid AS cc_coid, co.coName
        FROM co_contacts cc
        LEFT JOIN companies co ON co.coid = cc.coid
        WHERE cc.id = <cfqueryparam value="#arguments.masterCoContactId#" cfsqltype="CF_SQL_INTEGER">
    </cfquery>
    <cfif qMaster.recordCount EQ 0>
        <cfreturn { "success": false, "message": "Master record not found." }>
    </cfif>

    <cfset var coName    = qMaster.coName>
    <cfset var newCoid   = len(arguments.coid)   AND val(arguments.coid)   GT 0 ? int(arguments.coid)   : (len(qMaster.cc_coid) AND val(qMaster.cc_coid) GT 0 ? int(qMaster.cc_coid) : "")>
    <cfset var newColoc  = len(arguments.colocid) AND val(arguments.colocid) GT 0 ? int(arguments.colocid) : "">
    <cfset var preSrc    = qOwn.contactCompany_src>
    <cfset var preCompany = qOwn.contactCompany>
    <cfset var itemAction = "none">

    <cftransaction>
        <!--- Step 1 (R-3): Company item maintenance. --->
        <cfquery name="qItems">
            SELECT itemID, valueCompany
            FROM contactitems_tbl
            WHERE contactID   = <cfqueryparam value="#arguments.contactid#" cfsqltype="CF_SQL_INTEGER">
              AND valueCategory = <cfqueryparam value="Company" cfsqltype="CF_SQL_VARCHAR">
              AND itemStatus    = <cfqueryparam value="Active"  cfsqltype="CF_SQL_VARCHAR">
              AND IsDeleted     = <cfqueryparam value="0" cfsqltype="CF_SQL_BIT">
        </cfquery>

        <cfif qItems.recordCount EQ 0 AND len(trim(coName))>
            <!--- No active Company item and the master has a name -> create the canonical item --->
            <cfset request.svc("ContactItemService").createCompanyItem(
                       contactid   = arguments.contactid,
                       companyName = coName)>
            <cfset itemAction = "created">
        <cfelseif preSrc EQ "master" AND len(trim(coName)) AND len(trim(preCompany)) AND preCompany NEQ coName>
            <!--- Re-link after a master rename: rename the matched master-sourced item only --->
            <cfquery name="qRename">
                UPDATE contactitems_tbl
                SET valueCompany = <cfqueryparam value="#coName#" cfsqltype="CF_SQL_VARCHAR">
                WHERE contactID    = <cfqueryparam value="#arguments.contactid#" cfsqltype="CF_SQL_INTEGER">
                  AND valueCategory = <cfqueryparam value="Company" cfsqltype="CF_SQL_VARCHAR">
                  AND itemStatus    = <cfqueryparam value="Active"  cfsqltype="CF_SQL_VARCHAR">
                  AND IsDeleted     = <cfqueryparam value="0" cfsqltype="CF_SQL_BIT">
                  AND valueCompany  = <cfqueryparam value="#preCompany#" cfsqltype="CF_SQL_VARCHAR">
            </cfquery>
            <cfset itemAction = "renamed">
        </cfif>

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
      unlinkMaster(contactid, userid)  -- R-1 (match-guard), confirmed as written
      ============================================================ --->
<cffunction name="unlinkMaster" access="public" returntype="struct" output="false">
    <cfargument name="contactid" type="numeric" required="true">
    <cfargument name="userid"    type="numeric" required="true">

    <!--- Ownership gate + pre-mutation state read --->
    <cfquery name="qOwn">
        SELECT contactid, userid, master_co_contact_id, master_coid,
               company_location_id, contactCompany, contactCompany_src
        FROM contactdetails
        WHERE contactid = <cfqueryparam value="#arguments.contactid#" cfsqltype="CF_SQL_INTEGER">
          AND userid    = <cfqueryparam value="#arguments.userid#"    cfsqltype="CF_SQL_INTEGER">
    </cfquery>
    <cfif qOwn.recordCount EQ 0>
        <cfreturn { "success": false, "message": "Contact not found." }>
    </cfif>

    <!--- Idempotent no-op: pointers already NULL (covers FK ON DELETE SET NULL orphan state) --->
    <cfif NOT len(trim(qOwn.master_co_contact_id))
          AND NOT len(trim(qOwn.master_coid))
          AND NOT len(trim(qOwn.company_location_id))>
        <cfreturn { "success": true, "message": "Already unlinked.", "data": { "itemAction": "none", "noop": true } }>
    </cfif>

    <cfset var preSrc = qOwn.contactCompany_src>
    <cfset var itemAction = "none">
    <cfset var masterCoName = "">

    <!--- Resolve master coName via master_coid (for the exact-match soft-delete) --->
    <cfif len(trim(qOwn.master_coid))>
        <cfquery name="qCo">
            SELECT coName FROM companies
            WHERE coid = <cfqueryparam value="#qOwn.master_coid#" cfsqltype="CF_SQL_INTEGER">
        </cfquery>
        <cfif qCo.recordCount EQ 1><cfset masterCoName = qCo.coName></cfif>
    </cfif>

    <cftransaction>
        <!--- Step 1 (R-1): if the snapshot was master-owned, soft-delete active Company
              items whose valueCompany EXACTLY equals the master coName. User items survive. --->
        <cfif preSrc EQ "master" AND len(trim(masterCoName))>
            <cfquery name="qSoftDel" result="rDel">
                UPDATE contactitems_tbl
                SET IsDeleted = <cfqueryparam value="1" cfsqltype="CF_SQL_BIT">
                WHERE contactID   = <cfqueryparam value="#arguments.contactid#" cfsqltype="CF_SQL_INTEGER">
                  AND valueCategory = <cfqueryparam value="Company" cfsqltype="CF_SQL_VARCHAR">
                  AND itemStatus    = <cfqueryparam value="Active"  cfsqltype="CF_SQL_VARCHAR">
                  AND IsDeleted     = <cfqueryparam value="0" cfsqltype="CF_SQL_BIT">
                  AND valueCompany  = <cfqueryparam value="#masterCoName#" cfsqltype="CF_SQL_VARCHAR">
            </cfquery>
            <cfset itemAction = "softdeleted:" & rDel.recordCount>
        </cfif>

        <!--- Step 2: NULL the 3 pointers; clear master-sourced snapshot + reset _src='user'; bump sync. --->
        <cfset var upd = {
            "master_co_contact_id": "",
            "master_coid":          "",
            "company_location_id":  "",
            "contactCompany_src":   "user",
            "master_last_sync":     now()
        }>
        <cfif preSrc EQ "master">
            <cfset upd["contactCompany"] = "">
        </cfif>

        <cfset request.svc("ContactService").update(contactid = arguments.contactid, data = upd)>
    </cftransaction>

    <cflog file="master_link" type="information"
           text="UNLINK contactid=#arguments.contactid# userid=#arguments.userid# preSrc=#preSrc# masterCoName=#(len(masterCoName) ? masterCoName : 'na')# itemAction=#itemAction# clearedCompany=#(preSrc EQ 'master' ? 'yes' : 'no')#">

    <cfreturn { "success": true, "message": "Unlinked.", "data": { "itemAction": itemAction } }>
</cffunction>

</cfcomponent>
