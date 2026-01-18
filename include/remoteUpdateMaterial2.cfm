<!--- This ColdFusion page handles user redirection based on the session user ID and specified parameters. --->

<cfset userid = userid/>

<cfparam name="dir" default="account" />
<cfparam name="audprojectid" default="0" />

<cfoutput>#dir#</cfoutput>

<cfinclude template="/include/qry/audmedia_upd.cfm"/>

<!--- Check if the directory is "account" and redirect accordingly --->
<cfif #dir# is "account">
    <cflocation url="/app/myaccount/?t9=1&tab9_expand=true&t1=0" />
</cfif>

<!--- Check if the directory is "aud" and redirect accordingly --->
<cfif #dir# is "aud">
    <cflocation url="/app/audition/?audprojectid=#audprojectid#&secid=177" />
</cfif>
