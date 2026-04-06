<!--- /app/setup/ajax/complete.cfm
     Completes user setup: sets userstatus to Active, issetup to 1.
     Called via AJAX from the setup welcome page. --->
<cfsilent>
<cfset response = { "success": false, "message": "" } />

<cftry>
    <cfif NOT structKeyExists(session, "userid")>
        <cfset response.message = "Not authenticated." />
        <cfheader statuscode="401" />
        <cfoutput>#serializeJSON(response)#</cfoutput>
        <cfabort />
    </cfif>

    <cfset uid = val(session.userid) />

    <!--- Update userstatus to Active and mark setup complete --->
    <cfquery datasource="#application.dsn#">
        UPDATE taousers_tbl
        SET userstatus = 'Active',
            issetup = 1
        WHERE userid = <cfqueryparam value="#uid#" cfsqltype="cf_sql_integer" />
    </cfquery>

    <!--- Bust the cached user data so the new status takes effect --->
    <cfset session.bustUserCache = true />

    <cflog file="TAO_setup" type="info"
           text="User #uid# completed setup - status set to Active" />

    <cfset response.success = true />
    <cfset response.message = "Setup complete." />
    <cfset response.redirect = "/app/dashboard" />

    <cfcatch>
        <cfset response.message = "An error occurred completing setup." />
        <cflog file="TAO_setup" type="error"
               text="Setup complete failed for user #session.userid#: #cfcatch.message#" />
    </cfcatch>
</cftry>
</cfsilent>
<cfoutput>#serializeJSON(response)#</cfoutput>
