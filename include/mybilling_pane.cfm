<!--- Billing pane: fetches billing portal secret from PayKickstart and renders iframe --->
<cfif structKeyExists(application, "secrets") AND structKeyExists(application.secrets, "paykickstartAuthToken")>
    <cfset authToken = application.secrets.paykickstartAuthToken>
<cfelse>
    <cfset authToken = "">
    <cflog file="tao_errors" type="warning" text="mybilling_pane: application.secrets.paykickstartAuthToken not available">
</cfif>

<cfset secret = "">

<cfif len(trim(authToken))>
    <cftry>
        <cfhttp url="https://app.paykickstart.com/api/billing-customer" method="post" result="apiResponse" timeout="10">
            <cfhttpparam type="formfield" name="auth_token" value="#authToken#">
            <cfhttpparam type="formfield" name="email" value="#userEmail#">
        </cfhttp>

        <cfset responseData = DeserializeJSON(apiResponse.fileContent)>

        <cfif structKeyExists(responseData, "status") AND responseData.status EQ true>
            <cfset secret = responseData.secret>
        </cfif>

    <cfcatch type="any">
        <cflog file="tao_errors" type="error" text="mybilling_pane: PayKickstart API error: #cfcatch.message#">
    </cfcatch>
    </cftry>
</cfif>

<cfoutput>
<iframe width="100%" scrolling="no" frameborder="0" src="https://app.paykickstart.com/billing?portal=uGz4JGGnPi9VaXn73gSYxd3SqQRtMPY648otrWR5eGKKNquowi&secret=#secret#"></iframe>
<script src="https://app.paykickstart.com/billing-portal/js/uGz4JGGnPi9VaXn73gSYxd3SqQRtMPY648otrWR5eGKKNquowi"></script>
</cfoutput>
