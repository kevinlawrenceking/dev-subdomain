<!--- This ColdFusion page sets the background color based on the host name from the server URL. --->
<cfset currentURL = cgi.server_name />
<cfset host = ListFirst(currentURL, ".") />

<!--- Determine the host color based on the host name --->
<cfif #host# is "app">
    <cfset hostcolor = "##406E8E" />
</cfif>

<cfif #host# is "dev">
    <cfset hostcolor = "##406E8E" />
</cfif>

<cfif #host# is "uat">
    <cfset hostcolor = "purple" />
</cfif>

<cfif #host# is "chris">
    <cfset hostcolor = "green" />
</cfif>

<cfif #host# is "kevin">
    <cfset hostcolor = "violet" />
</cfif>

<style>
    body.authentication-bg {
        background-color: <cfoutput>#hostcolor#</cfoutput>;
        background-size: cover;
        background-position: center;
    }
</style>
