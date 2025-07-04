<cfset currentURL = cgi.server_name />

<cfset host = ListFirst(currentURL, ".") />

<cfif #host# is "app">
    <cfset dsn = "abo" />
  <cfoutput>  <cfset rev = "#rand()#" /> </cfoutput>
    <cfset suffix = "_1.5" />
    <cfset information_schema = "actorsbusinessoffice" />
    <cfelse>
  <cfset dsn = "abod" />
<cfset rev = rand() />
        <cfset suffix = "" />
        
    <cfset information_schema = "new_development" />
</cfif>

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
