 
<!--- Use datasource from Application.cfc --->
<cfset dsn = application.dsn />
<cfset rev = application.rev />

<cfquery result="result"  name="update">
        update taousers
        set nletter_link = '#new_nletter_link#'
        ,nletter_yn = '#new_nletter_yn#'
        where userid = #userid#
    </cfquery>

<!--- Bust the fetchUsers session cache so the next page render picks up the new values. --->
<cfset session.bustUserCache = true />

<Cflocation url="/app/myaccount/?new_pgid=124&t4=1" />
 
