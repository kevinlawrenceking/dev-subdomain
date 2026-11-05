<!--- This ColdFusion page handles parameter initialization and includes necessary query templates before redirecting the user to the account page. --->

<cfparam name="newpnids" default="" />

<!--- SECURITY (2026-10-17): /include/* has no login gate and this app resolves bare variables
      from url/form/cookie, so a client-supplied userid could rewrite another user's dashboard
      panels (x_94_1.cfm hides all, pgpanels_94_2.cfm shows the list). Pin the owner to the
      session before either include runs. --->
<cfif NOT structKeyExists(session, "userid") OR NOT isNumeric(session.userid) OR val(session.userid) LTE 0>
    <cflocation url="/loginform.cfm" addtoken="false" />
</cfif>
<cfset userid = val(session.userid) />

<!--- Include the first query template for processing data. --->
<cfinclude template="/include/qry/x_94_1.cfm" />

<!--- Include the second query template for pagination panels. --->
<cfinclude template="/include/qry/pgpanels_94_2.cfm" />

<!--- Redirect the user to the account page with a query parameter. --->
<cflocation url="/app/myaccount/?t1=1" />
