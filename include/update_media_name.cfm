<cfparam name="mediaid" default="">
<cfparam name="medianame" default="">

    <!--- Use datasource configured in Application.cfc --->
    <cfset dsn = application.dsn />
    <cfset rev = application.rev />
    <cfset suffix = application.suffix />
 

<cfif isNumeric(mediaid) AND len(trim(medianame)) GT 0>
    <cfquery datasource="#dsn#">
        UPDATE audmedia
        SET medianame = <cfqueryparam value="#medianame#" cfsqltype="CF_SQL_VARCHAR">
        WHERE mediaid = <cfqueryparam value="#mediaid#" cfsqltype="CF_SQL_INTEGER">
    </cfquery>

    <cfoutput>success</cfoutput>
<cfelse>
    <cfoutput>error</cfoutput>
</cfif>