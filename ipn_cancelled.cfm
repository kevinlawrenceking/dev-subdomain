<!--- This ColdFusion page displays billing information including invoice ID, purchase date, trial end date, product, and plan details. --->


<iframe width="100%" scrolling="no" frameborder="0" src="https://app.paykickstart.com/billing?portal=uGz4JGGnPi9VaXn73gSYxd3SqQRtMPY648otrWR5eGKKNquowi"></iframe><script src="https://app.paykickstart.com/billing-portal/js/uGz4JGGnPi9VaXn73gSYxd3SqQRtMPY648otrWR5eGKKNquowi"></script>


<cfset apiUrl = "https://app.paykickstart.com/api/billing-customer">
<cfset apiKey = "4OWaGHPXFibE"> <!--- Replace with your actual API key --->


<!--- Make API Request --->
<cfhttp url="#apiUrl#" method="post" result="apiResponse">
    <cfhttpparam type="header" name="Authorization" value="Bearer #apiKey#">
    <cfhttpparam type="formfield" name="customer_id" value="#customerId#">
</cfhttp>

<!--- Parse JSON Response --->
<cfset responseData = DeserializeJSON(apiResponse.FileContent)>

<!--- Handle Response --->
<cfif StructKeyExists(responseData, "billing_url")>
    <cfset billingPortalUrl = responseData.billing_url>
    <cfoutput>
        <p>Access your billing portal here: <a href="#billingPortalUrl#">Billing Portal</a></p>
    </cfoutput>
<cfelse>
    <cfoutput>
        Failed to retrieve billing URL: #responseData.error#
    </cfoutput>
</cfif>
