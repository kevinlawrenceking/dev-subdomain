<!---
    P11 Step 3 Save: Add Contacts (manual quick-add only)
    Creates contacts from quick-add rows. Bulk import removed from setup 2026-05-30.
    Auth + CSRF handled by ajax/Application.cfc.
--->
<cfset userid = session.userid>

<cfparam name="form.contacts" default="[]" />
<cfset contacts = []>
<cftry>
    <cfset contacts = deserializeJSON(form.contacts)>
    <cfcatch><cfset contacts = []></cfcatch>
</cftry>

<cfset contactsCreated = 0>
<!--- WO-C: ids of contacts created this submit, provisioned post-commit. --->
<cfset createdContactIds = []>

<cftry>
<cftransaction>

    <cfloop array="#contacts#" index="c">
        <cfset cName = trim(c.name ?: "")>
        <cfif NOT len(cName)><cfcontinue></cfif>

        <cfset cTag = trim(c.tag ?: "")>
        <cfset cEmailOrPhone = trim(c.emailOrPhone ?: "")>
        <cfset cCompany = trim(c.company ?: "")>

        <!--- Create contact --->
        <cflog file="TAO_setup_wizard" text="Step 3: creating contact '#cName#' for user #userid#">
        <cfset contactService = request.svc("ContactService")>
        <cftry>
            <cfset newContactId = contactService.create({
                userid: userid,
                contactFullName: cName,
                contactStatus: "Active"
            })>
            <cflog file="TAO_setup_wizard" text="Step 3: created contactid #newContactId# for '#cName#'">
        <cfcatch>
            <cflog file="TAO_setup_wizard" type="error"
                   text="Step 3: ContactService.create() failed for '#cName#': #cfcatch.message# | #cfcatch.detail#">
            <cfrethrow>
        </cfcatch>
        </cftry>

        <!--- Detect email vs phone --->
        <cfif len(cEmailOrPhone)>
            <cfif findNoCase("@", cEmailOrPhone)>
                <cfquery datasource="#application.datasource#">
                    INSERT INTO contactitems_tbl (contactid, valueCategory, valueType, valuetext, primary_yn, itemStatus)
                    VALUES (
                        <cfqueryparam value="#newContactId#" cfsqltype="cf_sql_integer" />,
                        'Email', 'Business',
                        <cfqueryparam value="#cEmailOrPhone#" cfsqltype="cf_sql_varchar" />,
                        'Y', 'Active'
                    )
                </cfquery>
            <cfelse>
                <cfquery datasource="#application.datasource#">
                    INSERT INTO contactitems_tbl (contactid, valueCategory, valueType, valuetext, primary_yn, itemStatus)
                    VALUES (
                        <cfqueryparam value="#newContactId#" cfsqltype="cf_sql_integer" />,
                        'Phone', 'Work',
                        <cfqueryparam value="#cEmailOrPhone#" cfsqltype="cf_sql_varchar" />,
                        'Y', 'Active'
                    )
                </cfquery>
            </cfif>
        </cfif>

        <cfif len(cCompany)>
            <cfquery datasource="#application.datasource#">
                INSERT INTO contactitems_tbl (contactid, valueCategory, valueType, valueCompany, itemStatus)
                VALUES (
                    <cfqueryparam value="#newContactId#" cfsqltype="cf_sql_integer" />,
                    'Company', 'Company',
                    <cfqueryparam value="#cCompany#" cfsqltype="cf_sql_varchar" />,
                    'Active'
                )
            </cfquery>
        </cfif>

        <cfif len(cTag)>
            <cfquery datasource="#application.datasource#">
                INSERT INTO contactitems_tbl (contactid, valueCategory, valueType, valuetext, itemStatus)
                VALUES (
                    <cfqueryparam value="#newContactId#" cfsqltype="cf_sql_integer" />,
                    'Tag', 'Tags',
                    <cfqueryparam value="#cTag#" cfsqltype="cf_sql_varchar" />,
                    'Active'
                )
            </cfquery>
        </cfif>

        <cfset arrayAppend(createdContactIds, newContactId)>
        <cfset contactsCreated++>
    </cfloop>

    <cfquery datasource="#application.datasource#">
        UPDATE taousers_tbl SET setup_step = 3
        WHERE userid = <cfqueryparam value="#userid#" cfsqltype="cf_sql_integer" />
    </cfquery>

</cftransaction>

    <!--- WO-C: provision contact media folders. Filesystem-only, best-effort, AFTER
          the DB transaction commits (mirrors remoteAddContactAdd.cfm:62-65). A folder
          failure must NEVER roll back an already-committed contact. --->
    <cfif arrayLen(createdContactIds)>
        <cftry>
            <!--- Defensive: session media paths are normally set by
                  /app/Application.cfc:459-478 on the /app/setup-wizard/ page load.
                  If absent (cold path), derive from application.baseMediaPath with the
                  IDENTICAL derivation -- not a hardcoded path. WO-C register: this
                  inline copy shadows app/Application.cfc block 4. --->
            <cfif NOT structKeyExists(session, "userMediaPath") OR NOT len(trim(session.userMediaPath))>
                <cfset session.userMediaPath    = application.baseMediaPath & "\\users\\" & userid>
                <cfset session.userMediaUrl     = application.baseMediaUrl  & "/users/" & userid>
                <cfset session.userContactsPath = session.userMediaPath & "\\contacts">
                <cfset session.userContactsUrl  = session.userMediaUrl  & "/contacts">
                <cfset session.userImportsUrl   = session.userMediaUrl  & "/imports">
                <cfset session.userAvatarPath   = session.userMediaPath & "\\avatar.jpg">
            </cfif>

            <cfloop array="#createdContactIds#" index="provContactId">
                <cfset select_userid    = userid>
                <cfset select_contactid = provContactId>
                <!--- cfsavecontent captures and discards the include's dir-create HTML
                      so it never reaches the JSON response body. --->
                <cfsavecontent variable="provHtmlSink">
                    <cfinclude template="/include/contactfolder_setup.cfm">
                </cfsavecontent>
                <cflog file="TAO_setup_wizard" type="information"
                       text="WO-C step3 folder provisioned: userid=#userid# contactid=#provContactId# path=#session.userMediaPath#\contacts\#provContactId#">
            </cfloop>
        <cfcatch type="any">
            <cflog file="TAO_setup_wizard" type="error"
                   text="WO-C step3 folder provisioning failed (contacts committed, continuing): #cfcatch.message# | #cfcatch.detail#">
        </cfcatch>
        </cftry>
    </cfif>

    <cfset session.setup_step = 3>
    <cfcontent type="application/json; charset=utf-8" reset="true">
    <cfoutput>#serializeJSON({
        "success": true,
        "message": contactsCreated & " contact(s) added.",
        "data": {"contactsCreated": contactsCreated}
    })#</cfoutput>

<cfcatch type="any">
    <cflog file="TAO_setup_wizard" type="error"
           text="Step 3 save failed for user #userid#: #cfcatch.message#" />
    <cfcontent type="application/json; charset=utf-8" reset="true">
    <cfoutput>#serializeJSON({"success": false, "message": "Failed to save contacts."})#</cfoutput>
</cfcatch>
</cftry>
