<!--- This ColdFusion page handles the insertion of a note and redirects based on the contact ID provided. --->

<cfparam name="rcontactid" default="0" />

<cfinclude template="/include/qry/InsertNote_173_1.cfm" />

<!--- Check if the contact ID is 0 to determine the return URL. --->
<Cfif "#rcontactid#" is "0">
    <cfoutput>
        <cfset return_url = "/app/#returnurl#/" />
    </cfoutput>
<Cfelse>
    <cfoutput>
        <cfset return_url = "/app/#returnurl#?contactid=#rcontactid#" />
    </cfoutput>
</Cfif>

<!--- Redirect to the determined return URL with a query parameter. --->
<cflocation url="#return_url#&t3=1">
