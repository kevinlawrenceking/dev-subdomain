<!--- This ColdFusion page determines the return URL based on the contact ID provided and redirects the user accordingly. --->

<cfparam name="rcontactid" default="0" />

<cfinclude template="/include/qry/updatenote_179_1.cfm" />

<!--- Check if the contact ID is 0 to set the return URL accordingly --->
<Cfif "#rcontactid#" is "0">
    
    <cfoutput>
        <cfset return_url = "/app/#returnurl#/" />
    </cfoutput>
    
<Cfelse>
    
    <cfoutput>
        <cfset return_url = "/app/#returnurl#?contactid=#rcontactid#" />
    </cfoutput>

</Cfif>

<!--- Redirect to the determined return URL with a query parameter --->
<cflocation url="#return_url#&t3=1">
