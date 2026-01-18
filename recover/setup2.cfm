<Cfparam name="pass1" default="" />

<!--- Use datasource configured in Application.cfc --->
<cfset dsn = application.dsn />
    
    
<cfset new_passwordSalt=hash(generateSecretKey("AES"),"SHA-512") />

        <cfquery name="update" datasource="#application.dsn#"    >
    UPDATE taousers
    set passwordHash = <cfqueryparam cfsqltype="char" value="#hash(pass1 & new_passwordSalt,'SHA-512')#" />
            ,recover = ''
            ,userPassword = '#pass1#'
            ,passwordSalt = <cfqueryparam cfsqltype="char" value="#new_passwordSalt#" />
    where  userid = #new_userid#
    </cfquery>
        
<cfset cookie.userid = new_userid />

 
<cflocation url="../loginform.cfm?pgrecover=Y"/>