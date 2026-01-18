<!--- This ColdFusion page handles the email notification for completed tickets and redirects to the support details page. --->
<cfparam name="email_user" default="Y" />
<cfparam name="patchnote" default="" />

<!--- Include the query to find ticket details --->
<cfinclude template="/include/qry/find_303_1.cfm" />

<cfoutput>
    <cfset next_verid = #find.verid# />
</cfoutput>

<!--- Include the query to update ticket status --->
<cfinclude template="/include/qry/update_303_2.cfm" />

<!--- Include the query to get ticket details --->
<cfinclude template="/include/qry/details_303_3.cfm" />

<cfset to_email = details.useremail />

<!--- Check if email notification is enabled --->
<cfif #email_user# is "Y">
    <cfmail from="support@theactorsoffice.com" 
            failto="kevinking7135@gmail.com" 
            replyto="support@theactorsoffice.com" 
            to="#to_email#" 
            cc="support@theactorsoffice.com"  
            usessl="true" 
            usetls="true" 
            subject="re: TAO TICKET NO #details.recid#" 
            type="HTML">
        <HTML>
            <head>
                <title>TAO TICKET NO #details.recid#</title>
            </head>
            <body>
                <!--- Style Tag in the Body, not Head, for Email --->
                <style type="text/css">
                    body { font-size: 14px; }
                </style>
                <p>Hi #details.userfirstname#,</p>
                <p>This is to inform you that your ticket (no. #details.recid#) has been completed.</p>
                
                <!--- Check if there is a response to the ticket --->
                <cfif #trim(details.ticketresponse)# is not "">
                    <p>#details.ticketresponse#</p>
                </cfif>
                
                <p>If there are any further issues on this topic, please open another ticket.</p>
                <p>&nbsp;</p>
                <p>Best,</p>
                <p>Kevin King<BR>Lead Developer<BR>The Actor's Office</p>
                <p>&nbsp;</p>

                <!--- Main HTML structure for email --->
                <table class="main_html" style="direction: ltr; border-radius: 0; border-collapse: collapse;">
                    <tbody>
                        <tr>
                            <td>
                                <table cellpadding="0" cellspacing="0" class="ws-tpl" style="font-family: Verdana; line-height: 1.25; padding-bottom: 10px; color: ##000;">
                                    <tbody>
                                        <tr>
                                            <td style="vertical-align: top; padding-right: 24px;">
                                                <table cellpadding="0" cellspacing="0" class="ws-tpl-photo" style="width:65px;">
                                                    <tbody>
                                                        <tr>
                                                            <td>
                                                                <img src="https://d36urhup7zbd7q.cloudfront.net/9f1033c8-aa07-4e56-a7e8-dedf97184598/IMG_4968.format_png.resize_200x.jpeg" 
                                                                     height="100" 
                                                                     width="65" 
                                                                     style="width: 65px; border-radius: 0px; height: 100px;" 
                                                                     class="fr-fil fr-dib">
                                                            </td>
                                                        </tr>
                                                    </tbody>
                                                </table>
                                            </td>
                                        </tr>
                                    </tbody>
                                </table>

                                <table border="0" cellpadding="0" cellspacing="0">
                                    <tbody>
                                        <tr>
                                            <td style="line-height:0;">
                                                <br>
                                            </td>
                                        </tr>
                                    </tbody>
                                </table>
                            </td>
                        </tr>
                    </tbody>
                </table>

                <table cellpadding="0" cellspacing="0" style="opacity:0!important;">
                    <tbody>
                        <tr>
                            <td height="1" style="height: 1px!important; width:1px!important; font-size: 0px!important;" width="1">&zwnj;</td>
                        </tr>
                    </tbody>
                </table>

                <p>&nbsp;</p>
                <hr>
                <h3>Ticket No #details.recid# Details</h3>      
                <p> Submitted by #details.col1# on #this.formatDate(details.col2)# at #TimeFormat("#details.col3#","medium")#</p>
                <p><strong>Type:</strong> #details.tickettype#</p>
                <p><strong>Status:</strong> #details.col5#</p>
                <p><strong>User Details:</strong> #details.ticketdetails#</p>
                <p><strong>Support Response:</strong> #details.ticketresponse#</p>
                <p> Completed by Kevin King on #this.formatDate(details.ticketCompletedDate)# at #TimeFormat("#details.ticketCompletedDate#","medium")#</p>
            </body>
        </HTML>
    </cfmail>
</cfif>

<!--- Redirect to the support details page --->
<cflocation url="/app/admin-support-details/?recid=#recid#" />
