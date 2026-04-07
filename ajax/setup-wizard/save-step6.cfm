<!---
    P11 Step 6 Save: My Links
    Updates sitelinks_user_tbl URLs for existing rows, inserts custom links.
    Auth + CSRF handled by ajax/Application.cfc.
--->
<cfset userid = session.userid>

<cfparam name="form.existingLinks" default="[]" />
<cfparam name="form.customLinks" default="[]" />

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

    <!--- Update existing link URLs --->
    <cfloop array="#existingLinks#" index="link">
        <cfset linkId = val(link.sitelinkId ?: 0)>
        <cfset linkUrl = trim(link.siteurl ?: "")>
        <cfif linkId GT 0>
            <cfquery datasource="#application.datasource#">
                UPDATE sitelinks_user_tbl
                SET siteurl = <cfqueryparam value="#linkUrl#" cfsqltype="cf_sql_varchar" />
                WHERE id = <cfqueryparam value="#linkId#" cfsqltype="cf_sql_integer" />
                  AND userid = <cfqueryparam value="#userid#" cfsqltype="cf_sql_integer" />
            </cfquery>
        </cfif>
    </cfloop>

    <!--- Insert new custom links --->
    <cfloop array="#customLinks#" index="clink">
        <cfset cName = trim(clink.sitename ?: "")>
        <cfset cUrl = trim(clink.siteurl ?: "")>
        <cfif len(cName) AND len(cUrl)>
            <cfquery datasource="#application.datasource#">
                INSERT INTO sitelinks_user_tbl (userid, sitename, siteurl, iscustom)
                VALUES (
                    <cfqueryparam value="#userid#" cfsqltype="cf_sql_integer" />,
                    <cfqueryparam value="#cName#" cfsqltype="cf_sql_varchar" />,
                    <cfqueryparam value="#cUrl#" cfsqltype="cf_sql_varchar" />,
                    1
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
    <cflog file="TAO_setup_wizard" type="error"
           text="Step 6 save failed for user #userid#: #cfcatch.message#" />
    <cfcontent type="application/json; charset=utf-8" reset="true">
    <cfoutput>#serializeJSON({"success": false, "message": "Failed to save links."})#</cfoutput>
</cfcatch>
</cftry>
