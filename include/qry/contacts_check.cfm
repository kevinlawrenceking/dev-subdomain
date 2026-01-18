<cfparam name="devicetype" default="desktop" />

<!--- This ColdFusion page includes different contact queries based on the device type (mobile or desktop) --->
<cfif #devicetype# is "mobile">
    <!--- Include the query for all contacts for mobile devices --->
    <cfinclude template="/include/qry/contacts_all.cfm">
<cfelse>
    <!--- Include the query for contacts for non-mobile devices --->
    <cfinclude template="/include/qry/contacts.cfm">
</cfif>
