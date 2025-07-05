<!--- Use datasource from Application.cfc --->
<cfset dsn = application.dsn />
<cfset rev = application.rev />
<cfset suffix = application.suffix />
<cfset information_schema = application.information_schema />

<cfset rev = rand() />

<cfquery result="result"  name="z" maxrows="10">
    SELECT * FROM taousers where userstatus = 'active' AND issetup IS NOT true
    </cfquery>

<cfloop query="z">
<cfset select_userid  = z.userid />
    
<cfinclude template="user_setup.cfm" />
    
 <cfquery result="result"  name="update">
    update taousers set issetup = 1 where userid = #select_userid# 
    </cfquery>   
    
</cfloop>
