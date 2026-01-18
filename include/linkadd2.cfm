<!--- This ColdFusion page processes a link URL and generates a return URL based on the presence of an 'audprojectid' --->
<cfif #left(linkurl,4)# is not "http">
    <!--- If the link URL does not start with 'http', prepend 'https://' --->
    <cfset linkurl = "https://#linkurl#" />
</cfif>

<!--- Include the template for adding a record --->
<cfinclude template="/include/qry/add_149_1.cfm" />

<!--- Check if 'audprojectid' is defined --->
<cfif #isdefined('audprojectid')#>
    <cfoutput>
        <!--- Set the return URL with 'audprojectid' --->
        <cfset returnurl = "/app/#returnurl#/?contactid=#rcontactid#&audprojectid=#audprojectid#&tab2_expand=true&secid=178&t3=1" />
    </cfoutput>
<cfelse>
    <cfoutput>
        <!--- Set the return URL with 'eventid' if 'audprojectid' is not defined --->
        <cfset returnurl = "/app/#returnurl#/?contactid=#rcontactid#&eventid=#reventid#&tab2_expand=true&secid=178&t3=1" />
    </cfoutput>
</cfif>

<!--- Redirect to the generated return URL --->
<cflocation url="#returnurl#" />
