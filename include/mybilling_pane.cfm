<!--- Billing pane: fetches billing portal secret from PayKickstart and renders iframe --->
<cfif structKeyExists(application, "secrets") AND structKeyExists(application.secrets, "paykickstartAuthToken")>
    <cfset authToken = application.secrets.paykickstartAuthToken>
<cfelse>
    <cfset authToken = "">
    <cflog file="tao_errors" type="warning" text="mybilling_pane: application.secrets.paykickstartAuthToken not available">
</cfif>

<cfset secret = "">

<cftry>
    <cfset apiUrl = "https://app.paykickstart.com/api/billing-customer?auth_token=#authToken#&email=#urlEncodedFormat(userEmail)#">

    <cfhttp url="#apiUrl#" method="post" result="apiResponse" timeout="10">
    </cfhttp>

    <cfset responseData = DeserializeJSON(apiResponse.fileContent)>

    <cfif structKeyExists(responseData, "status") AND responseData.status EQ true>
        <cfset secret = responseData.secret>
    </cfif>

<cfcatch type="any">
    <cflog file="tao_errors" type="error" text="mybilling_pane: PayKickstart API error: #cfcatch.message#">
</cfcatch>
</cftry>

<cfoutput>
<iframe width="100%" scrolling="no" frameborder="0" src="https://app.paykickstart.com/billing?portal=uGz4JGGnPi9VaXn73gSYxd3SqQRtMPY648otrWR5eGKKNquowi&secret=#secret#"></iframe>
<script src="https://app.paykickstart.com/billing-portal/js/uGz4JGGnPi9VaXn73gSYxd3SqQRtMPY648otrWR5eGKKNquowi"></script>
</cfoutput>
