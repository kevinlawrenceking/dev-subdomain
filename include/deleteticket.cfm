<!--- This ColdFusion page handles redirection based on the presence of an old version ID. --->

<cfinclude template="/include/qry/deleteticket_105_1.cfm" />

<!--- Check if 'oldverid' is defined --->
<cfif isdefined('oldverid')>
    <!--- Redirect to the version page with the old version ID --->
    <cflocation url="/app/version/?recid=#oldverid#" />
<cfelse>
    <!--- Redirect to the admin support page if 'oldverid' is not defined --->
    <cflocation url="/app/admin-support/" />
</cfif>
