<!---
    P11: Load Step Content
    GET endpoint that returns the HTML fragment for a given wizard step.
    Auth and CSRF are handled by ajax/Application.cfc.

    Params: step (1-7)
    Returns: HTML fragment
--->
<cfparam name="url.step" default="1" />
<cfset stepNum = val(url.step)>

<!--- Whitelist step numbers to prevent path traversal --->
<cfif stepNum LT 1 OR stepNum GT 7>
    <cfset stepNum = 1>
</cfif>

<!--- Load data needed by the step partial --->
<cfset userid = session.userid>

<cftry>

<!--- Bust cache so step always gets fresh data --->
<cfset session.bustUserCache = true>
<cfinclude template="/include/qry/fetchUsers.cfm" />

<!--- Map step number to partial file --->
<cfswitch expression="#stepNum#">
    <cfcase value="1">
        <cfinclude template="/app/setup-wizard/steps/step1.cfm" />
    </cfcase>
    <cfcase value="2">
        <cfinclude template="/app/setup-wizard/steps/step2.cfm" />
    </cfcase>
    <cfcase value="3">
        <cfinclude template="/app/setup-wizard/steps/step3.cfm" />
    </cfcase>
    <cfcase value="4">
        <cfinclude template="/app/setup-wizard/steps/step4.cfm" />
    </cfcase>
    <cfcase value="5">
        <cfinclude template="/app/setup-wizard/steps/step5.cfm" />
    </cfcase>
    <cfcase value="6">
        <cfinclude template="/app/setup-wizard/steps/step6.cfm" />
    </cfcase>
    <cfcase value="7">
        <cfinclude template="/app/setup-wizard/steps/step7.cfm" />
    </cfcase>
</cfswitch>

<cfcatch type="any">
    <cfset ctxFile = "">
    <cfset ctxLine = "">
    <cfif isArray(cfcatch.tagContext) AND arrayLen(cfcatch.tagContext)>
        <cfset ctxFile = cfcatch.tagContext[1].template>
        <cfset ctxLine = cfcatch.tagContext[1].line>
    </cfif>
    <cflog file="TAO_setup_wizard" type="error"
           text="load-step failed step=#stepNum# user=#session.userid# type=#cfcatch.type# msg=#cfcatch.message# detail=#cfcatch.detail# at=#ctxFile#:#ctxLine#">
    <cfoutput>
    <div class="text-danger p-3" style="font-size:13px;">
        <strong>Step #stepNum# Error:</strong> #encodeForHTML(cfcatch.message)#<br/>
        <strong>Detail:</strong> #encodeForHTML(cfcatch.detail)#<br/>
        <cfif len(ctxFile)>
            <strong>File:</strong> #encodeForHTML(ctxFile)# line #encodeForHTML(ctxLine)#
        </cfif>
    </div>
    </cfoutput>
</cfcatch>
</cftry>
