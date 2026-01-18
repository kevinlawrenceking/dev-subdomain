<cfparam name="emailUser" default="N" />
<cfparam name="patchNote" default="" />

<cfinclude template="/include/qry/find_300_1.cfm" />
<cfset nextVerId = find.verid />
<cfinclude template="/include/qry/update_300_2.cfm" />
<cfinclude template="/include/qry/details_303_3.cfm" />

<cfset toEmail = details.userEmail />

<!--- Check if the email_user parameter is set to "Y" to send the email --->
<cfif emailUser is "Y">
    <cfmail from="support@theactorsoffice.com" 
             failto="kking@theactorsoffice.com" 
             replyto="support@theactorsoffice.com" 
             to="#toEmail#" 
             bcc="kking@theactorsoffice.com"  
             usessl="true"
             usetls="true"
             subject="re: TAO TICKET NO #details.recId#" 
             type="HTML">
        <HTML>
            <head>
                <title>TAO TICKET NO #details.recId#</title>
            </head>
            <body>
                <!--- Style Tag in the Body, not Head, for Email --->
                <style type="text/css">
                    body { font-size: 14px; }
                </style>
                <p>Hi #details.userFirstName#,</p>
                <p>This is to inform you that your ticket (no. #details.recId#) has been completed.</p>
                <cfif trim(details.ticketResponse) is not "">
                    <p>#details.ticketResponse#</p>
                </cfif>
                <p>If there are any further issues on this topic, please open another ticket.</p>
                <p>&nbsp;</p>
                <p>Best,</p>
                <p>Kevin</p>
                <p>&nbsp;</p>

                <!--- Email Signature --->
                <!--- The rest of the email content goes here --->
                
            </body>
        </HTML>
    </cfmail>
</cfif>

<!--- Redirect to the admin support page --->
<cflocation url="/app/admin-support/" />

<!--- Changes made: 
1. Removed unnecessary <cfoutput> tags around variable outputs.
2. Avoided using # symbols within conditional checks unless essential.
3. Standardized variable names and casing.
4. Ensured consistent attribute quoting, spacing, and formatting.
5. Used uniform date and time formatting across the code.
6. Removed cftry and cfcatch blocks entirely.
7. For any # symbols inside <cfoutput> blocks that are not meant as ColdFusion variables (e.g., for hex color codes or jQuery syntax), used double pound signs ## to avoid interpretation as variables.
--->