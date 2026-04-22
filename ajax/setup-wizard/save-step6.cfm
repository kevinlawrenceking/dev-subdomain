<!---
    P11 Step 6 Save: My Links
    Updates sitelinks_user_tbl URLs for existing rows, inserts custom links.
    Auth + CSRF handled by ajax/Application.cfc.
--->
<cfset userid = session.userid>

<cfparam name="form.existingLinks" default="[]" />
<cfparam name="form.customLinks" default="[]" />
<cflog file="TAO_setup_wizard" text="Step 6 save: existingLinks=#form.existingLinks#">

<cfset existingLinks = []>
<cfset customLinks = []>
<cftry>
    <cfset existingLinks = deserializeJSON(form.existingLinks)>
    <cfcatch><cfset existingLinks = []></cfcatch>
</cftry>
<cftry>
    <cfset customLinks = deserializeJSON(form.customLinks)>
    <cfcatch><cfset customLinks = []></cfcatch>
</cftry>

<cftry>
<cftransaction>

    <!--- Snapshot current URLs so we can tell "toggled off an existing link"
          (soft-delete) from "left an empty template row alone" (no-op). --->
    <cfquery name="qCurrent" datasource="#application.datasource#">
        SELECT id, siteurl
        FROM sitelinks_user_tbl
        WHERE userid = <cfqueryparam value="#userid#" cfsqltype="cf_sql_integer" />
          AND isdeleted = 0
    </cfquery>
    <cfset currentUrls = {}>
    <cfloop query="qCurrent">
        <cfset currentUrls[qCurrent.id] = qCurrent.siteurl ?: "">
    </cfloop>

    <!--- Reconcile existing link rows:
          - toggled on + url present  -> update url (and un-delete defensively)
          - toggled off + had url     -> soft-delete
          - toggled off + never had   -> no-op (preserve the template row) --->
    <cfloop array="#existingLinks#" index="link">
        <cfset linkId = val(link.sitelinkId ?: 0)>
        <cfset linkUrl = trim(link.siteurl ?: "")>
        <cfif linkId LTE 0><cfcontinue></cfif>

        <cfset hadUrl = structKeyExists(currentUrls, linkId) AND len(currentUrls[linkId])>

        <cfif len(linkUrl)>
            <cfquery datasource="#application.datasource#">
                UPDATE sitelinks_user_tbl
                SET siteurl = <cfqueryparam value="#linkUrl#" cfsqltype="cf_sql_varchar" />,
                    isdeleted = 0
                WHERE id = <cfqueryparam value="#linkId#" cfsqltype="cf_sql_integer" />
                  AND userid = <cfqueryparam value="#userid#" cfsqltype="cf_sql_integer" />
            </cfquery>
        <cfelseif hadUrl>
            <cfquery datasource="#application.datasource#">
                UPDATE sitelinks_user_tbl
                SET isdeleted = 1,
                    siteurl = <cfqueryparam value="" cfsqltype="cf_sql_varchar" />
                WHERE id = <cfqueryparam value="#linkId#" cfsqltype="cf_sql_integer" />
                  AND userid = <cfqueryparam value="#userid#" cfsqltype="cf_sql_integer" />
            </cfquery>
        </cfif>
    </cfloop>

    <!--- Insert new custom links.
          Column set mirrors setup/user_setup_core.cfm and include/user_setup.cfm
          so MySQL strict mode accepts the row (sitetypeid / siteicon / isdeleted
          are likely NOT NULL or NOT NULL-no-default on this table). --->
    <cfloop array="#customLinks#" index="clink">
        <cfset cName = trim(clink.sitename ?: "")>
        <cfset cUrl = trim(clink.siteurl ?: "")>
        <cfif len(cName) AND len(cUrl)>
            <cfquery datasource="#application.datasource#">
                INSERT INTO sitelinks_user_tbl (
                    userid, sitename, siteurl, siteicon, sitetypeid, iscustom, isdeleted
                ) VALUES (
                    <cfqueryparam value="#userid#" cfsqltype="cf_sql_integer" />,
                    <cfqueryparam value="#cName#" cfsqltype="cf_sql_varchar" />,
                    <cfqueryparam value="#cUrl#" cfsqltype="cf_sql_varchar" />,
                    <cfqueryparam value="" cfsqltype="cf_sql_varchar" null="true" />,
                    <cfqueryparam value="0" cfsqltype="cf_sql_integer" null="true" />,
                    <cfqueryparam value="1" cfsqltype="cf_sql_bit" />,
                    <cfqueryparam value="0" cfsqltype="cf_sql_bit" />
                )
            </cfquery>
        </cfif>
    </cfloop>

    <!--- Update wizard progress --->
    <cfquery datasource="#application.datasource#">
        UPDATE taousers_tbl SET setup_step = 6
        WHERE userid = <cfqueryparam value="#userid#" cfsqltype="cf_sql_integer" />
    </cfquery>

</cftransaction>

    <cfset session.setup_step = 6>
    <cfcontent type="application/json; charset=utf-8" reset="true">
    <cfoutput>#serializeJSON({"success": true, "message": "Links saved."})#</cfoutput>

<cfcatch type="any">
    <cfset ctxFile = "">
    <cfset ctxLine = "">
    <cfif isArray(cfcatch.tagContext) AND arrayLen(cfcatch.tagContext)>
        <cfset ctxFile = cfcatch.tagContext[1].template>
        <cfset ctxLine = cfcatch.tagContext[1].line>
    </cfif>
    <cflog file="TAO_setup_wizard" type="error"
           text="Step 6 save failed for user #userid# type=#cfcatch.type# msg=#cfcatch.message# detail=#cfcatch.detail# at=#ctxFile#:#ctxLine#" />
    <cfcontent type="application/json; charset=utf-8" reset="true">
    <cfoutput>#serializeJSON({
        "success": false,
        "message": "Failed to save links.",
        "errorType": cfcatch.type,
        "errorMessage": cfcatch.message,
        "errorDetail": cfcatch.detail,
        "errorAt": ctxFile & ":" & ctxLine
    })#</cfoutput>
</cfcatch>
</cftry>
