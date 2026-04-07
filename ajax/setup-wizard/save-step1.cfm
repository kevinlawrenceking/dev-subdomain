<!---
    P11 Step 1 Save: Welcome and Account Info
    POST endpoint. Auth + CSRF handled by ajax/Application.cfc.
    Updates taousers_tbl + contactdetails_tbl + contactitems_tbl (phone).
--->
<cfset userid = session.userid>

<!--- Parse input (form-encoded) --->
<cfparam name="form.firstName" default="" />
<cfparam name="form.lastName" default="" />
<cfparam name="form.nickname" default="" />
<cfparam name="form.pronouns" default="" />
<cfparam name="form.phone" default="" />
<cfparam name="form.timezoneId" default="0" />
<cfparam name="form.dateFormatId" default="0" />

<cfset firstName = trim(form.firstName)>
<cfset lastName = trim(form.lastName)>
<cfset nickname = trim(form.nickname)>
<cfset pronouns = trim(form.pronouns)>
<cfset phone = trim(form.phone)>
<cfset timezoneId = val(form.timezoneId)>
<cfset dateFormatId = val(form.dateFormatId)>

<!--- Validate required fields --->
<cfif NOT len(firstName) OR NOT len(lastName)>
    <cfcontent type="application/json; charset=utf-8" reset="true">
    <cfoutput>#serializeJSON({"success": false, "message": "First and last name are required."})#</cfoutput>
    <cfabort>
</cfif>

<cftry>
<cftransaction>

    <!--- 1. Update user profile --->
    <cfquery datasource="#application.datasource#">
        UPDATE taousers_tbl
        SET userFirstName = <cfqueryparam value="#firstName#" cfsqltype="cf_sql_varchar" />,
            userLastName = <cfqueryparam value="#lastName#" cfsqltype="cf_sql_varchar" />,
            tzid = <cfqueryparam value="#timezoneId#" cfsqltype="cf_sql_integer" />,
            dateFormatID = <cfqueryparam value="#dateFormatId#" cfsqltype="cf_sql_integer" />
        WHERE userid = <cfqueryparam value="#userid#" cfsqltype="cf_sql_integer" />
    </cfquery>

    <!--- 2. Find self-contact --->
    <cfquery name="qSelf" datasource="#application.datasource#" maxrows="1">
        SELECT contactid
        FROM contactdetails
        WHERE userid = <cfqueryparam value="#userid#" cfsqltype="cf_sql_integer" />
          AND user_yn = 'Y'
    </cfquery>

    <cfif qSelf.recordCount>
        <!--- 3. Update self-contact details --->
        <cfquery datasource="#application.datasource#">
            UPDATE contactdetails_tbl
            SET contactFullName = <cfqueryparam value="#firstName# #lastName#" cfsqltype="cf_sql_varchar" />,
                contactNickname = <cfqueryparam value="#nickname#" cfsqltype="cf_sql_varchar" />,
                contactPronoun = <cfqueryparam value="#pronouns#" cfsqltype="cf_sql_varchar" />
            WHERE contactid = <cfqueryparam value="#qSelf.contactid#" cfsqltype="cf_sql_integer" />
        </cfquery>

        <!--- 4. Phone upsert on self-contact --->
        <cfif len(phone)>
            <cfquery name="qExistingPhone" datasource="#application.datasource#" maxrows="1">
                SELECT itemid
                FROM contactitems
                WHERE contactid = <cfqueryparam value="#qSelf.contactid#" cfsqltype="cf_sql_integer" />
                  AND valueCategory = 'Phone'
                  AND primary_yn = 'Y'
                  AND itemStatus = 'Active'
            </cfquery>

            <cfif qExistingPhone.recordCount>
                <cfquery datasource="#application.datasource#">
                    UPDATE contactitems_tbl
                    SET valuetext = <cfqueryparam value="#phone#" cfsqltype="cf_sql_varchar" />
                    WHERE itemid = <cfqueryparam value="#qExistingPhone.itemid#" cfsqltype="cf_sql_integer" />
                </cfquery>
            <cfelse>
                <cfquery datasource="#application.datasource#">
                    INSERT INTO contactitems_tbl (contactid, valueCategory, valueType, valuetext, primary_yn, itemStatus)
                    VALUES (
                        <cfqueryparam value="#qSelf.contactid#" cfsqltype="cf_sql_integer" />,
                        'Phone', 'Mobile',
                        <cfqueryparam value="#phone#" cfsqltype="cf_sql_varchar" />,
                        'Y', 'Active'
                    )
                </cfquery>
            </cfif>
        </cfif>
    </cfif>

    <!--- 5. Update wizard progress --->
    <cfquery datasource="#application.datasource#">
        UPDATE taousers_tbl
        SET setup_step = 1
        WHERE userid = <cfqueryparam value="#userid#" cfsqltype="cf_sql_integer" />
    </cfquery>

</cftransaction>

    <cfset session.setup_step = 1>
    <!--- Bust user data cache so next fetchUsers gets fresh data --->
    <cfset session.bustUserCache = true>

    <cfcontent type="application/json; charset=utf-8" reset="true">
    <cfoutput>#serializeJSON({"success": true, "message": "Profile saved."})#</cfoutput>

<cfcatch type="any">
    <cflog file="TAO_setup_wizard" type="error"
           text="Step 1 save failed for user #userid#: #cfcatch.message# | #cfcatch.detail#" />
    <cfcontent type="application/json; charset=utf-8" reset="true">
    <cfoutput>#serializeJSON({"success": false, "message": "Failed to save profile. Please try again."})#</cfoutput>
</cfcatch>
</cftry>
