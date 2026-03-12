<cfparam name="form.pass1" default="" />
<cfparam name="form.new_userid" default="0" />

<!--- dsn is set by Application.cfm via env detection --->
<cfif not isDefined("dsn") or not len(dsn)>
    <cfset dsn = listFirst(cgi.server_name, ".") EQ "app" ? "abo" : "abod" />
</cfif>

<!--- Guard: reject if no userid posted --->
<cfif not isNumeric(form.new_userid) or form.new_userid eq 0>
    <cflocation url="/loginform.cfm" />
</cfif>

<cfset new_passwordSalt=hash(generateSecretKey("AES"),"SHA-512") />

        <cfquery name="update" datasource="#dsn#">
    UPDATE taousers
    set passwordHash = <cfqueryparam cfsqltype="char" value="#hash(form.pass1 & new_passwordSalt,'SHA-512')#" />
            ,recover = ''
            ,userPassword = <cfqueryparam cfsqltype="cf_sql_varchar" value="#form.pass1#" />
            ,passwordSalt = <cfqueryparam cfsqltype="char" value="#new_passwordSalt#" />
    where  userid = <cfqueryparam cfsqltype="cf_sql_integer" value="#form.new_userid#" />
    </cfquery>

<cfset cookie.userid = form.new_userid />

 
<cflocation url="../loginform.cfm?pgrecover=Y"/>