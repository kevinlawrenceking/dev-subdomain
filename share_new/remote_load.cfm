<cfset currentURL = cgi.server_name />

<cfset host = ListFirst(currentURL, ".") />

<cfif #host# is "app">
    <cfset dsn = "abo" />
    <cfelse>
  <cfset dsn = "abod" />

</cfif>
