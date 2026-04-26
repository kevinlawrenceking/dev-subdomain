<cfsetting requestTimeout="60" enablecfoutputonly="false">
<cfcontent type="text/html; charset=utf-8" reset="true">

<!--- Host derivation matches /include/pgload.cfm:14-15 and
      /include/fetchPageService.cfm:41-42. Do not simplify. --->
<cfset currentURL = cgi.server_name>
<cfset host = ListFirst(currentURL, ".")>
<cfset contactid = 0>
<cfparam name="shareid" default="">

<!--- Page-scope userid. /ajax/Application.cfc:77 sets variables.userid in the CFC,
      not the requested page. Main MyAccount gets it from /include/pgload.cfm:9
      cfparam; this AJAX endpoint must do the same. fetchUsers.cfm and
      getMyTeam.cfm both reference unscoped userid. --->
<cfparam name="userid" default="#session.userid#">

<!--- App-scope drift guard. /app/Application.cfc:84-97 populates the avatar URL
      chain in its pseudo-constructor on every /app/* request; /ajax/Application.cfc
      ensures only baseMediaPath/baseMediaUrl. myteam_pane.cfm:225 reads
      application.defaultAvatarUrl unconditionally. Same shape as the existing
      cold-start guard at /ajax/Application.cfc:47-55. Mirrors the documented
      "Defensive resolver pattern required" — see baseMediaPath drift incident. --->
<cfif NOT structKeyExists(application, "defaultAvatarUrl")>
    <cfset application.defaultAvatarUrl = application.baseMediaUrl & "/images/defaults/avatar.jpg">
</cfif>

<cftry>
    <cfinclude template="/include/qry/fetchUsers.cfm">
    <cfinclude template="/include/myteam_pane.cfm">
<cfcatch type="any">
    <cflog file="tao_account_tabs" type="error"
           text="loadTeam failed for userid=#session.userid#: #cfcatch.type# - #cfcatch.message# | detail=#cfcatch.detail# | tagContext=#cfcatch.tagContext[1].template#:#cfcatch.tagContext[1].line#">
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
