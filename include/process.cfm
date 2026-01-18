<!--- This ColdFusion page handles redirection based on the selected category. --->

<cfset dbug = 'N'>
<cfoutput>category: #category#</cfoutput><cfoutput>
    <h1>Form Variables</h1>
    <table border="1" cellpadding="5" cellspacing="0">
        <thead>
            <tr>
                <th>Variable Name</th>
                <th>Value</th>
            </tr>
        </thead>
        <tbody>
            <!--- Loop through the FORM scope to display all submitted variables --->
            <cfloop collection="#FORM#" item="key">
                <tr>
                    <td>#key#</td>
                    <td>#FORM[key]#</td>
                </tr>
            </cfloop>
        </tbody>
    </table>
</cfoutput>

 
<!--- Check the category and redirect accordingly --->
<cfif category eq "Contacts">
    <cflocation url = "/app/contact/?contactid=#selectedid#"/>
    
<cfelseif category eq "Tags">
    <cflocation url = "/app/contacts/?bytag=#selectedid#"/>
    
<cfelse>
    <cflocation url = "/app/appoint-update/?eventid=#selectedid#&returnurl=calendar-appoint&rcontactid=0"/>
</cfif>
