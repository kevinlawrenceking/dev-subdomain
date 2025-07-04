 
<cfset currentURL = cgi.server_name />

<cfset host = ListFirst(currentURL, ".") />

<cfif #host# is "app">
    <cfset dsn = "abo" />
    <cfset rev = "1.2.0" />
    <cfelse>
  <cfset dsn = "abod" />
<cfset rev = rand() />
</cfif>

<cfquery result="result"  name="update">
        update taousers
        set nletter_link = '#new_nletter_link#'
        ,nletter_yn = '#new_nletter_yn#'
        where userid = #userid#
    </cfquery>

<Cflocation url="/app/myaccount/?new_pgid=124&t4=1" />
 
