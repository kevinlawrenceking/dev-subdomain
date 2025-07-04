<cfset authorizationCode = trim(URL.code)>
<cfset clientId = "764716537559-ncfiag8dl4p05v7c9kcoltss0ou3heki.apps.googleusercontent.com">
<cfset clientSecret = "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">
<cfset redirectUri = "https://app.theactorsoffice.com/oauth/oauth_callback.cfm">
<cfset tokenUrl = "https://oauth2.googleapis.com/token">

<cfhttp url="#tokenUrl#" method="post" result="tokenResponse" charset="utf-8">
    <cfhttpparam type="header" name="Content-Type" value="application/x-www-form-urlencoded">
    <cfhttpparam type="formField" name="code" value="#authorizationCode#">
    <cfhttpparam type="formField" name="client_id" value="#clientId#">
    <cfhttpparam type="formField" name="client_secret" value="#clientSecret#">
    <cfhttpparam type="formField" name="redirect_uri" value="#redirectUri#">
    <cfhttpparam type="formField" name="grant_type" value="authorization_code">
</cfhttp>

<cfif Left(tokenResponse.statusCode, 3) EQ "200" AND StructKeyExists(tokenResponse, "FileContent")>
    <cftry>
        <cfset tokenData = DeserializeJSON(tokenResponse.FileContent)>

        <cfoutput>
            <h2>Token Exchange Successful</h2>
            <p><strong>Access Token:</strong></p>
            <pre>#tokenData.access_token#</pre>

            <cfif StructKeyExists(tokenData, "refresh_token")>
                <p><strong>Refresh Token:</strong></p>
                <pre>#tokenData.refresh_token#</pre>
            <cfelse>
                <p>No refresh token returned (possibly already granted).</p>
            </cfif>

            <p><strong>Expires in:</strong> #tokenData.expires_in# seconds</p>
        </cfoutput>

  
       
        <cfquery>
            UPDATE taousers
            SET access_token = <cfqueryparam value="#tokenData.access_token#" cfsqltype="CF_SQL_VARCHAR">,
                refresh_token = <cfqueryparam value="#tokenData.refresh_token#" cfsqltype="CF_SQL_VARCHAR">
            WHERE userid = <cfqueryparam value="#session.userid#" cfsqltype="CF_SQL_INTEGER">
        </cfquery>
     

    <cfcatch type="any">
        <cfoutput>
            <h2>Error parsing token response</h2>
            <pre>#cfcatch.message#</pre>
            <pre>#cfcatch.detail#</pre>
        </cfoutput>
    </cfcatch>

 
    </cftry>

       <cflocation url="/app/calendar-appoint/" addtoken="no">
<cfelse>
    <cfoutput>
        <h2>Token Request Failed</h2>
        <p><strong>Status:</strong> #tokenResponse.statusCode#</p>
        <p><strong>Error:</strong></p>
        <pre>#tokenResponse.FileContent#</pre>
    </cfoutput>
</cfif>
