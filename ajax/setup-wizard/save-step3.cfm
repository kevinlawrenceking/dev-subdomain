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

        <cfset contactsCreated++>
    </cfloop>

    <cfquery datasource="#application.datasource#">
        UPDATE taousers_tbl SET setup_step = 3
        WHERE userid = <cfqueryparam value="#userid#" cfsqltype="cf_sql_integer" />
    </cfquery>

</cftransaction>

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
