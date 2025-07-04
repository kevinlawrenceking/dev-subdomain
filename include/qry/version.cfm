<!--- This ColdFusion page retrieves version details and ticket information based on a given version ID. --->

<cfif not #isdefined('recid')#>
    <!--- Set recid to verid if not defined --->
    <cfset recid = verid />
</cfif>

<cfinclude template="/include/qry/details_556_1.cfm" />

<cfinclude template="/include/qry/results_556_2.cfm" />

<cfinclude template="/include/qry/priorities_556_3.cfm" />

