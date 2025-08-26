<!--- This ColdFusion page handles the retrieval and insertion of version records, redirecting to a specific URL based on the outcome. --->

<!--- Form and URL parameter validation with cfparam --->
<cfparam name="form.major" default="0" />
<cfparam name="form.minor" default="0" />
<cfparam name="form.patch" default="0" />
<cfparam name="form.version" default="" />
<cfparam name="form.versionstatus" default="Development" />
<cfparam name="form.versiontype" default="Feature" />
<cfparam name="form.userid" default="#session.userid#" />
<cfparam name="url.returnurl" default="/app/versions/" />

<!--- Assign local variables with proper scope qualification --->
<cfset local.major = trim(form.major) />
<cfset local.minor = trim(form.minor) />
<cfset local.patch = trim(form.patch) />
<cfset local.version = trim(form.version) />
<cfset local.versionstatus = trim(form.versionstatus) />
<cfset local.versiontype = trim(form.versiontype) />
<cfset local.userid = form.userid />
<cfset local.returnurl = trim(url.returnurl) />

<!--- Use local variables for processing --->
<cfset major = local.major />
<cfset minor = local.minor />
<cfset patch = local.patch />
<cfset version = local.version />
<cfset versionstatus = local.versionstatus />
<cfset versiontype = local.versiontype />
<cfset userid = local.userid />
<cfset returnurl = local.returnurl />

<cfinclude template="/include/qry/find_320_1.cfm" />

<!--- Check if a record was found --->
<cfif find.recordcount eq 1>
    <cfset verid = find.verid />
<cfelse>
    <!--- Include the insert query template if no record was found --->
    <cfinclude template="/include/qry/insert_320_2.cfm" />
    
    <!--- Get the last inserted ID --->
    <cfset verid = insertResult.GENERATEDKEY />
</cfif>

<!--- Redirect to the new URL with the record ID --->
<cflocation url="/app/version/?recid=#verid#" addtoken="false" />
