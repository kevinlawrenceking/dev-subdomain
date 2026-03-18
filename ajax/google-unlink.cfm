<cfsilent>
<!---
    ajax/google-unlink.cfm — Unlink Google Calendar
    Clears stored Google OAuth tokens for the current user.
    Redirects back to calendar page.
--->

<!--- Revoke the token at Google (best-effort) --->
<cfquery name="userTokens">
    SELECT access_token FROM taousers
    WHERE userid = <cfqueryparam value="#session.userid#" cfsqltype="CF_SQL_INTEGER" />
</cfquery>

<cfif userTokens.recordCount GT 0 AND len(trim(userTokens.access_token))>
    <cftry>
        <cfhttp url="https://oauth2.googleapis.com/revoke?token=#URLEncodedFormat(userTokens.access_token)#"
                method="post" result="revokeResult" timeout="5">
            <cfhttpparam type="header" name="Content-Type" value="application/x-www-form-urlencoded" />
        </cfhttp>
        <cflog file="tao_google_oauth"
               text="[unlink] Revoked token at Google. status=#revokeResult.statusCode# userid=#session.userid#" />
    <cfcatch>
        <cflog file="tao_google_oauth" type="warning"
               text="[unlink] Revoke request failed: #cfcatch.message# userid=#session.userid#" />
    </cfcatch>
    </cftry>
</cfif>

<!--- Clear tokens in database --->
<cfquery>
    UPDATE taousers
    SET access_token = '', refresh_token = ''
    WHERE userid = <cfqueryparam value="#session.userid#" cfsqltype="CF_SQL_INTEGER" />
</cfquery>

<cflog file="tao_google_oauth"
       text="[unlink] Tokens cleared. userid=#session.userid#" />

</cfsilent>
<cflocation url="/app/calendar-appoint/?google_unlinked=1" addtoken="no" />
