<!--- Require authenticated session --->
<cfif NOT structKeyExists(session, "userid")>
    <cfheader statuscode="403">
    <cfabort>
</cfif>

<cfoutput>
    Codex test is working! #now()#
</cfoutput>