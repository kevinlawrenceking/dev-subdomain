<cfsetting requestTimeout="60" enablecfoutputonly="false">
<cfcontent type="text/html; charset=utf-8" reset="true">

<!--- Host derivation matches /include/pgload.cfm:14-15 and
      /include/fetchPageService.cfm:41-42. Set even though mybilling_pane.cfm
      does not currently read host — parity with loadTeam, insulates against
      nested includes that may. --->
<cfset currentURL = cgi.server_name>
<cfset host = ListFirst(currentURL, ".")>
<cfset contactid = 0>
<cfparam name="shareid" default="">

<!--- userid is set by /ajax/Application.cfc:77; fetchUsers.cfm provides userEmail. --->
<cfinclude template="/include/qry/fetchUsers.cfm">

<cftry>
    <cfinclude template="/include/mybilling_pane.cfm">
<cfcatch type="any">
    <cflog file="tao_account_tabs" type="error" text="loadBilling failed: #cfcatch.message# / #cfcatch.detail#">
    <cfheader statuscode="500">
    <cfoutput>
    <div class="alert alert-danger" data-tab-error="1">
        <strong>Couldn't load this tab.</strong>
        <div class="small text-muted">Reference: #dateTimeFormat(now(),'yyyy-mm-dd HH:nn:ss')#</div>
        <button type="button" class="btn btn-sm btn-outline-secondary mt-2 tao-tab-retry">Retry</button>
    </div>
    </cfoutput>
    <cfabort>
</cfcatch>
</cftry>
