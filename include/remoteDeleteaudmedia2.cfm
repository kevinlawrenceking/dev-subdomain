<!--- This ColdFusion page handles redirection based on the value of secid. --->
<cfinclude template="/include/qry/audmedia_details_225_1.cfm" />

<!--- Check if secid is equal to "196" --->
<cfif #secid# is "196">
    <!--- Redirect to the myaccount page with specific parameters for secid 196 --->
    <cflocation url="/app/myaccount/?t9=1&tab9_expand=true" />
<cfelse>
    <!--- Redirect to the myaccount page with different parameters for other secid values --->
    <cflocation url="/app/myaccount/?t8=1&tab8_expand=true" />
</cfif>

