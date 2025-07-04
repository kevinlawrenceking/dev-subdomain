<Cfparam name="pass1" default="" />

<cfset currentURL = cgi.server_name />

<cfset host = ListFirst(currentURL, ".") />

<cfif #host# is "app">
    
    <cfset dsn = "abo" />
    
    <cfelse>
  
        <cfset dsn = "abod" />

</cfif>
    
    
<cfset new_passwordSalt=hash(generateSecretKey("AES"),"SHA-512") />

        <cfquery name="update" datasource="abo"    >
    UPDATE taousers
    set passwordHash = <cfqueryparam cfsqltype="char" value="#hash(pass1 & new_passwordSalt,'SHA-512')#" />
            ,recover = ''
            ,userPassword = '#pass1#'
            ,passwordSalt = <cfqueryparam cfsqltype="char" value="#new_passwordSalt#" />
    where  userid = #new_userid#
    </cfquery>
        
<cfset cookie.userid = new_userid />

 
<cflocation url="../loginform.cfm?pgrecover=Y"/>