<!---
    P11 Step 2 Save: Add Your Representation
    Creates contacts with rep tags (Agent/Manager/Publicist, My Rep Team, My Team).
    Auth + CSRF handled by ajax/Application.cfc.
--->
<cfset userid = session.userid>

<!--- Parse rep array from form data --->
<cfparam name="form.reps" default="[]" />
<cfset reps = []>
<cftry>
    <cfset reps = deserializeJSON(form.reps)>
    <cfcatch>
        <cfset reps = []>
    </cfcatch>
</cftry>

<cfset contactsCreated = 0>

<cftry>
<cftransaction>

    <cfloop array="#reps#" index="rep">
        <cfset repName = trim(rep.name ?: "")>
        <cfif NOT len(repName)>
            <cfcontinue>
        </cfif>

        <cfset repRole = trim(rep.role ?: "Agent")>
        <cfset repCompany = trim(rep.company ?: "")>
        <cfset repPhone = trim(rep.phone ?: "")>
        <cfset repEmail = trim(rep.email ?: "")>

        <!--- Create contact via ContactService --->
        <cfset contactService = request.svc("ContactService")>
        <cfset newContactId = contactService.create({
            userid: userid,
            contactFullName: repName,
            contacttitle: repRole,
            contactStatus: "Active"
        })>

        <!--- Insert contact items --->
        <cfif len(repEmail)>
            <cfquery datasource="#application.datasource#">
                INSERT INTO contactitems_tbl (contactid, valueCategory, valueType, valuetext, primary_yn, itemStatus)
                VALUES (
                    <cfqueryparam value="#newContactId#" cfsqltype="cf_sql_integer" />,
                    'Email', 'Business',
                    <cfqueryparam value="#repEmail#" cfsqltype="cf_sql_varchar" />,
                    'Y', 'Active'
                )
            </cfquery>
        </cfif>

        <cfif len(repPhone)>
            <cfquery datasource="#application.datasource#">
                INSERT INTO contactitems_tbl (contactid, valueCategory, valueType, valuetext, primary_yn, itemStatus)
                VALUES (
                    <cfqueryparam value="#newContactId#" cfsqltype="cf_sql_integer" />,
                    'Phone', 'Work',
                    <cfqueryparam value="#repPhone#" cfsqltype="cf_sql_varchar" />,
                    'Y', 'Active'
                )
            </cfquery>
        </cfif>

        <cfif len(repCompany)>
            <cfquery datasource="#application.datasource#">
                INSERT INTO contactitems_tbl (contactid, valueCategory, valueType, valueCompany, itemStatus)
                VALUES (
                    <cfqueryparam value="#newContactId#" cfsqltype="cf_sql_integer" />,
                    'Company', 'Company',
                    <cfqueryparam value="#repCompany#" cfsqltype="cf_sql_varchar" />,
                    'Active'
                )
            </cfquery>
        </cfif>

        <!--- Tags: role, My Rep Team, My Team --->
        <cfloop list="#repRole#,My Rep Team,My Team" index="tagName">
            <cfquery datasource="#application.datasource#">
                INSERT INTO contactitems_tbl (contactid, valueCategory, valueType, valuetext, itemStatus)
                VALUES (
                    <cfqueryparam value="#newContactId#" cfsqltype="cf_sql_integer" />,
                    'Tag', 'Tags',
                    <cfqueryparam value="#tagName#" cfsqltype="cf_sql_varchar" />,
                    'Active'
                )
            </cfquery>
        </cfloop>

        <cfset contactsCreated++>
    </cfloop>

    <!--- Update wizard progress --->
    <cfquery datasource="#application.datasource#">
        UPDATE taousers_tbl
        SET setup_step = 2
        WHERE userid = <cfqueryparam value="#userid#" cfsqltype="cf_sql_integer" />
    </cfquery>

</cftransaction>

    <cfset session.setup_step = 2>

    <cfcontent type="application/json; charset=utf-8" reset="true">
    <cfoutput>#serializeJSON({
        "success": true,
        "message": contactsCreated & " contact(s) created.",
        "data": {"contactsCreated": contactsCreated}
    })#</cfoutput>

<cfcatch type="any">
    <cflog file="TAO_setup_wizard" type="error"
           text="Step 2 save failed for user #userid#: #cfcatch.message# | #cfcatch.detail#" />
    <cfcontent type="application/json; charset=utf-8" reset="true">
    <cfoutput>#serializeJSON({"success": false, "message": "Failed to save contacts. Please try again."})#</cfoutput>
</cfcatch>
</cftry>
