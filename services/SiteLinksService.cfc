<cfcomponent displayname="SiteLinksService"  hint="Handles site links retrieval for specific panels.">

<cffunction output="false" name="getSiteLinksByPanelId" access="public" returntype="query"  hint="Retrieve site links for a specific panel ID.">
        <cfargument name="panelId" type="numeric" required="true" hint="The panel ID (pnid) for which to retrieve site links.">

<cfquery result="result" name="mylinks_user">
            SELECT 
                s.id,
                s.id as new_id,
                s.sitetypeid,
                s.sitename,
                s.siteurl,
                s.siteicon,
                t.sitetypename,
                t.pntitle
            FROM sitetypes_user t
            INNER JOIN sitelinks_user s ON t.sitetypeid = s.siteTypeid
            WHERE t.pnid = <cfqueryparam value="#arguments.panelId#" cfsqltype="cf_sql_integer">
            ORDER BY s.sitename
        </cfquery>

<cfreturn mylinks_user>
    </cffunction>

<cffunction output="false" name="getAllUrlsByPanelId" access="public" returntype="string"  hint="Retrieve all URLs for a specific panel for the 'Open All' button.">
        <cfargument name="panelId" type="numeric" required="true" hint="The panel ID for which to retrieve all URLs.">

<cfquery result="result" name="allUrls">
            SELECT GROUP_CONCAT(s.siteurl ORDER BY s.siteurl ASC SEPARATOR ', ') AS siteurl_list
            FROM sitetypes_user t
            INNER JOIN sitelinks_user s ON t.sitetypeid = s.siteTypeid
            WHERE t.pnid = <cfqueryparam value="#arguments.panelId#" cfsqltype="cf_sql_integer">
        </cfquery>

<cfreturn allUrls.siteurl_list>
    </cffunction>

<cffunction output="false" name="getLinkDetailsById" access="public" returntype="query"  hint="Retrieve link details for a specific link ID.">
        <cfargument name="linkId" type="numeric" required="true" hint="The ID of the link to retrieve details for.">

<cfquery result="result" name="linkdetails">
            SELECT 
                id, 
                siteName, 
                siteURL, 
                siteicon, 
                siteTypeid, 
                userid, 
                isDeleted, 
                isCustom, 
                ver, 
                siteicon_url 
            FROM sitelinks_user 
            WHERE id = <cfqueryparam value="#arguments.linkId#" cfsqltype="cf_sql_integer">
        </cfquery>

<cfreturn linkdetails>
    </cffunction>

<cffunction output="false" name="updateSiteLinkDetails" access="public" returntype="void"  hint="Check for duplicate sitenames and update site link details">
        <cfargument name="new_id" type="numeric" required="true" hint="ID of the site link to update">
        <cfargument name="userid" type="numeric" required="true" hint="User ID">
        <cfargument name="new_sitename" type="string" required="true" hint="New site name to check for duplicates">
        <cfargument name="new_siteurl" type="string" required="true" hint="New site URL">
        <cfargument name="new_iscustom" type="numeric" required="true" hint="Indicates if the site is custom">
        <cfargument name="deletelink" type="numeric" required="true" hint="Indicates if the site link should be deleted">

<cfset var corrected_new_siteurl = new_siteurl>
        <cfif left(new_siteurl, 8) neq "https://" and left(new_siteurl, 7) neq "http://">
            <cfset corrected_new_siteurl = "https://" & new_siteurl />
        </cfif>

<cfquery result="result" name="duplicateCount">
            SELECT COUNT(*) AS duplicateCount
            FROM sitelinks_user
            WHERE userid = <cfqueryparam value="#arguments.userid#" cfsqltype="cf_sql_integer">
            AND sitename = <cfqueryparam value="#arguments.new_sitename#" cfsqltype="cf_sql_varchar">
            AND id <> <cfqueryparam value="#arguments.new_id#" cfsqltype="cf_sql_integer">
        </cfquery>

<cfquery result="result" name="updateSiteLink">
            UPDATE sitelinks_user
            SET 
                siteurl = <cfqueryparam value="#corrected_new_siteurl#" cfsqltype="cf_sql_varchar">,
                isdeleted = <cfqueryparam value="#deletelink#" cfsqltype="cf_sql_bit">,
                sitename = <cfqueryparam value="#new_sitename#" cfsqltype="cf_sql_varchar">
            WHERE id = <cfqueryparam value="#new_id#" cfsqltype="cf_sql_integer">
        </cfquery>
    </cffunction>

<!--- Function to update sitelinks_user table dynamically based on passed variables --->
    <cffunction output="false" name="updateSiteLink" access="public" returntype="void"  hint="Updates the sitelinks_user table dynamically based on available arguments.">
        <cfargument name="new_id" type="numeric" required="true" hint="ID of the site link to update">
        <cfargument name="new_sitename" type="string" required="false" hint="New site name">
        <cfargument name="new_siteurl" type="string" required="false" hint="New site URL">
        <cfargument name="new_siteicon" type="string" required="false" hint="New site icon">
        <cfargument name="new_sitetypeid" type="numeric" required="false" hint="Site type ID">
        <cfargument name="new_iscustom" type="boolean" required="false" hint="Is custom site link">
        <cfargument name="deletelink" type="boolean" required="false" hint="Flag for deletion">
        <cfargument name="ver" type="integer" required="false" hint="Version number">
        <cfargument name="new_siteicon_url" type="string" required="false" hint="New site icon URL">

<!--- Query to update sitelinks_user with conditional updates --->
        <cfquery result="result" name="updateSiteLink">
            UPDATE sitelinks_user
            SET siteName = <cfqueryparam value="#arguments.new_sitename#" cfsqltype="cf_sql_varchar">

<cfif structKeyExists(arguments, "new_siteurl")>
                    ,siteURL = <cfqueryparam value="#arguments.new_siteurl#" cfsqltype="cf_sql_varchar">
                </cfif>
                <cfif structKeyExists(arguments, "new_siteicon")>
                    ,siteicon = <cfqueryparam value="#arguments.new_siteicon#" cfsqltype="cf_sql_varchar">
                </cfif>
                <cfif structKeyExists(arguments, "new_sitetypeid")>
                    ,siteTypeid = <cfqueryparam value="#arguments.new_sitetypeid#" cfsqltype="cf_sql_integer">
                </cfif>
                <cfif structKeyExists(arguments, "new_iscustom")>
                    ,IsCustom = <cfqueryparam value="#arguments.new_iscustom#" cfsqltype="cf_sql_bit">
                </cfif>
                <cfif structKeyExists(arguments, "deletelink")>
                    ,IsDeleted = <cfqueryparam value="#arguments.deletelink#" cfsqltype="cf_sql_bit">
                </cfif>
                <cfif structKeyExists(arguments, "ver")>
                    ,ver = <cfqueryparam value="#arguments.ver#" cfsqltype="cf_sql_integer">
                </cfif>
                <cfif structKeyExists(arguments, "new_siteicon_url")>
                    ,siteicon_url = <cfqueryparam value="#arguments.new_siteicon_url#" cfsqltype="cf_sql_varchar">
                </cfif>
            WHERE id = <cfqueryparam value="#arguments.new_id#" cfsqltype="cf_sql_integer">
        </cfquery>

</cffunction>

<!--- Function to get sitetypeid and sitetypename for a specific panel ID (pnid) --->
<cffunction output="false" name="getSiteTypeDetailsByPanelId" access="public" returntype="struct"  hint="Retrieve the sitetypeid and sitetypename for a specific panel ID (pnid).">
    <cfargument name="new_pnid" type="numeric" required="true" hint="The panel ID (pnid) for which to retrieve sitetypeid and sitetypename.">

<!--- Query to retrieve sitetypeid and sitetypename --->
    <cfquery result="result" name="siteTypeQuery">
        SELECT su.sitetypeid, su.sitetypename, p.pntitle
        FROM sitetypes_user su
        INNER JOIN pgpanels_user p ON su.pnid = p.pnid
        WHERE su.pnid = <cfqueryparam value="#arguments.new_pnid#" cfsqltype="cf_sql_integer">
        LIMIT 1
    </cfquery>

<!--- Create a structure to return both values --->
    <cfset var siteTypeDetails = structNew()>

<!--- Check if the record exists and populate the structure --->
    <cfif siteTypeQuery.recordcount gt 0>
        <cfset siteTypeDetails.sitetypeid = siteTypeQuery.sitetypeid>
        <cfset siteTypeDetails.sitetypename = siteTypeQuery.sitetypename>
         <cfset siteTypeDetails.pntitle = siteTypeQuery.pntitle>
    <cfelse>
        <!--- Return 0 for sitetypeid and empty string for sitetypename if no result found --->
        <cfset siteTypeDetails.sitetypeid = 0>
        <cfset siteTypeDetails.sitetypename = "">
           <cfset siteTypeDetails.pntitle = "">
    </cfif>

<!--- Return the structure --->
    <cfreturn siteTypeDetails>
</cffunction>

<cffunction name="getPanelData" access="public" returntype="struct" hint="Retrieves all necessary data for a links panel in a single call.">
    <cfargument name="panelId" type="numeric" required="true">

    <cfset var local = {}>
    <cfset var response = {}>

    <!--- Get Panel Details --->
    <cfquery name="local.panelDetails" datasource="#application.dsn#">
        SELECT sitetypeid, sitetypename, pntitle
        FROM sitetypes_user
        WHERE pnid = <cfqueryparam value="#arguments.panelId#" cfsqltype="cf_sql_integer">
    </cfquery>

    <cfif local.panelDetails.recordCount>
        <cfset response.details = {
            sitetypeid = local.panelDetails.sitetypeid,
            sitetypename = local.panelDetails.sitetypename,
            pntitle = local.panelDetails.pntitle
        }>

        <!--- Get Links for the panel --->
        <cfquery name="local.links" datasource="#application.dsn#">
            SELECT id, id as new_id, sitename, siteurl, siteicon
            FROM sitelinks_user
            WHERE siteTypeid = <cfqueryparam value="#local.panelDetails.sitetypeid#" cfsqltype="cf_sql_integer">
              AND isdeleted = 0
            ORDER BY sitename
        </cfquery>
        <cfset response.links = local.links>
        <cfset response.urlList = valueList(local.links.siteurl, ", ")>
    <cfelse>
         <!--- Return empty structure if panel not found --->
        <cfset response.details = structNew()>
        <cfset response.links = queryNew("id,new_id,sitename,siteurl,siteicon")>
        <cfset response.urlList = "">
    </cfif>

    <cfreturn response>
</cffunction>

</cfcomponent>