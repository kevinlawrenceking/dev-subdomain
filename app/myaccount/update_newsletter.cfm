 
<!--- Use datasource from Application.cfc --->
<cfset dsn = application.dsn />
<cfset rev = application.rev />

<cfquery result="result"  name="update">
        update taousers
        set nletter_link = '#new_nletter_link#'
        ,nletter_yn = '#new_nletter_yn#'
        where userid = #userid#
    </cfquery>

<Cflocation url="/app/myaccount/?new_pgid=124&t4=1" />
 
