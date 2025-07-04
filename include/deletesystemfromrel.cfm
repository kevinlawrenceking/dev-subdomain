<!--- This ColdFusion page handles bulk actions for system management, including setting session variables and including necessary query templates. --->

<cfset dbug = "n" />

<cfparam name="idlist" default="0" />

<!--- Check if idlist is not defined and set it to idlist if true --->
<Cfif not isdefined('idlist')>
    <cfset idlist = idlist />
</Cfif>

<!--- If idlist is "0" and idlist is not "0", set idlist to idlist --->
<cfif idlist is "0" and idlist is not "0">
    <cfset idlist = idlist />
</cfif>

<!--- Set the session action to "bulk" --->
<cfset session.pg_action = "bulk" />

<!--- Include the first query template for finding records --->
<cfinclude template="/include/qry/find_d_104_1.cfm" />

<!--- Include the second query template for deleting systems --->
<cfinclude template="/include/qry/deletesystem_104_2.cfm" />

<!--- Redirect to the contacts page with appropriate parameters --->
<cflocation url="/app/contacts/?pgaction=bulk&bt=system&d=#find_d.recordcount#&s=0&a=0&t=#new_systemid#" />
