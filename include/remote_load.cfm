<!--- This ColdFusion page sets up database connection parameters based on the host environment. --->

<cfinclude template="/include/qry/findit_278_1.cfm" />

<cfset current_ver = int(findit.verid) />

<!--- Use datasource configured in Application.cfc --->
<cfset dsn = application.dsn />
<cfset rev = current_ver />
<cfset suffix = application.suffix />
<cfset information_schema = application.information_schema />
