<!--- This ColdFusion page handles the sending of an email notification when a ticket status is updated to "Implemented" and redirects to a specific version page. --->

<cfinclude template="/include/qry/update_275_1.cfm" />
<cfinclude template="/include/qry/details_275_2.cfm" />

<cfset to_email = "cansoff@gmail.com" />

<!--- Determine the start page and page names based on the presence of a custom test page name. --->
<cfif #details.customtestpagename# is "">
    <cfset startpage = "https://dev.theactorsoffice.com/app/#details.pgdir#/" />
    <cfset pgnames = "#details.pgname#" />
<cfelse>
    <cfset startpage = "#details.customtestpagelink#" />
    <cfset pgnames = "#details.customtestpagename#" />
</cfif>

<!--- Check if the ticket status has changed to "Implemented" and send an email notification. --->
<cfif #old_ticketstatus# is not "Implemented" and #new_ticketstatus# is "Implemented">
    <cfmail from="support@theactorsoffice.com" 
            failto="kevinking7135@gmail.com" 
            replyto="kevinking7135@gmail.com" 
            to="cansoff@gmail.com" 
            bcc="kevinking7135@gmail.com"  
            cc="jodie@jodiebentley.com" 
            usessl="true" 
            usetls="true" 
            subject="TICKET NO #details.recid# - Ready for Testing" 
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
                <p>Hi Chris,</p>
                <p>This is to inform you that ticket No. #details.recid# has been implemented and is ready for testing in the dev environment.</p>
                <h4><A HREF="https://app.theactorsoffice.com/app/testing/?recid=#details.ticketid#">TEST</A></h4>
                <p>&nbsp;</p>
                <p>Best,</p>
                <p>Kevin</p>
                <p>&nbsp;</p>

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
                                                                <img src="https://d36urhup7zbd7q.cloudfront.net/9f1033c8-aa07-4e56-a7e8-dedf97184598/IMG_4968.format_png.resize_200x.jpeg" height="100" width="65" style="width: 65px; border-radius: 0px; height: 100px;" class="fr-fil fr-dib" />
                                                            </td>
                                                        </tr>
                                                    </tbody>
                                                </table>
                                            </td>
                                            <td style="vertical-align: top;" valign="top">
                                                <table cellpadding="0" cellspacing="0" style="font-family: Verdana;">
                                                    <tbody>
                                                        <tr>
                                                            <td style="line-height: 1.32;">
                                                                <span class="ws-tpl-name" data-acs="name" style="color-scheme: light only; color: ##406E8E; font-size: 12px; font-family: Verdana; font-weight: bold;">&nbsp;Kevin King&nbsp;</span>
                                                                <br>
                                                                <span class="ws-tpl-title" data-acs="title" style="color-scheme: light only; font-size: 12px; letter-spacing: 0px; color: ##4e4b4c; font-family: Verdana; text-transform: initial; color: ##406E8E;">&nbsp;Partner / Lead Application Developer at&nbsp;</span>
                                                                <span class="ws-tpl-company" data-acs="company" style="color-scheme: light only; font-size: 12px; letter-spacing: 0px; color: ##4e4b4c; font-family: Verdana; text-transform: initial; color: ##406E8E;">&nbsp;<strong>The Actor&##39;s Office&nbsp;</strong></span>
                                                            </td>
                                                        </tr>
                                                        <tr>
                                                            <td style="line-height: 0; padding-top: 14px; padding-bottom: 14px;">
                                                                <table cellpadding="0" cellspacing="0" style="width: 100%;">
                                                                    <tbody>
                                                                        <tr>
                                                                            <td class="ws-tpl-separator" style="line-height: 0; font-size: 1pt; border-bottom-width: 5px; border-bottom-style: solid; border-bottom-color: ##406E8E;">&nbsp;</td>
                                                                        </tr>
                                                                    </tbody>
                                                                </table>
                                                            </td>
                                                        </tr>
                                                        <tr>
                                                            <td style="line-height: 0;">
                                                                <table cellpadding="0" cellspacing="0">
                                                                    <tbody>
                                                                        <tr>
                                                                            <td>
                                                                                <table cellpadding="0" cellspacing="0">
                                                                                    <tbody>
                                                                                        <tr>
                                                                                            <td style="line-height: 0%; padding-bottom: 8px;">
                                                                                                <table cellpadding="0" cellspacing="0" class="ws-tpl-website" style="line-height: 14px; font-size: 12px; font-family: Verdana;">
                                                                                                    <tbody>
                                                                                                        <tr>
                                                                                                            <td style="color-scheme: light only; font-family: Verdana; font-weight: bold; font-size: 12px; color: ##406E8E;"><span style="line-height: 1.2;">W</span></td>
                                                                                                            <td style="width: 7px; font-size: 1pt; line-height: 0;" width="7">&nbsp;</td>
                                                                                                            <td style="color-scheme: light only; font-family: Verdana; font-size: 12px;">
                                                                                                                <a href="http://www.theactorsoffice.com" style="color-scheme: light only; text-decoration: none; font-size: 12px; font-family: Verdana;" target="_blank">&nbsp;<span data-acs="website" style="line-height: 1.2; color-scheme: light only; color: ##212121; font-family: Verdana; white-space: nowrap; font-size: 12px;">&nbsp;www.theactorsoffice.com&nbsp;</span>&nbsp;</a>
                                                                                                            </td>
                                                                                                        </tr>
                                                                                                    </tbody>
                                                                                                </table>
                                                                                            </td>
                                                                                            <td style="line-height: 0%; padding-bottom: 8px;">
                                                                                                <table cellpadding="0" cellspacing="0" class="ws-tpl-email" style="line-height: 14px; font-size: 12px; font-family: Verdana;">
                                                                                                    <tbody>
                                                                                                        <tr>
                                                                                                            <td style="padding: 0 8px;"><span style="color-scheme: light only; font-family: Verdana; font-weight: bold; font-size: 12px; color: ##212121;">&nbsp;</span></td>
                                                                                                            <td style="color-scheme: light only; font-family: Verdana; font-weight: bold; font-size: 12px; color: ##406E8E;"><span style="line-height: 1.2;">E</span></td>
                                                                                                            <td style="width: 7px; font-size: 1pt; line-height: 0;" width="7">&nbsp;</td>
                                                                                                            <td style="color-scheme: light only; font-family: Verdana; font-size: 12px;">
                                                                                                                <a href="mailto:kking@theactorsoffice.com" style="color-scheme: light only; text-decoration: none; font-size: 12px; font-family: Verdana;" target="_blank">&nbsp;<span data-acs="email" style="line-height: 1.2; color-scheme: light only; color: ##212121; font-family: Verdana; white-space: nowrap; font-size: 12px;">&nbsp;kking@theactorsoffice.com&nbsp;</span>&nbsp;</a>
                                                                                                            </td>
                                                                                                        </tr>
                                                                                                    </tbody>
                                                                                                </table>
                                                                                            </td>
                                                                                        </tr>
                                                                                    </tbody>
                                                                                </table>
                                                                            </td>
                                                                        </tr>
                                                                    </tbody>
                                                                </table>
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
                                            <td style="line-height: 0;">
                                                <br>
                                            </td>
                                        </tr>
                                    </tbody>
                                </table>
                            </td>
                        </tr>
                    </tbody>
                </table>

                <table cellpadding="0" cellspacing="0" style="opacity: 0!important;">
                    <tbody>
                        <tr>
                            <td height="1" style="height: 1px!important; width: 1px!important; font-size: 0px!important;" width="1">&zwnj;</td>
                        </tr>
                    </tbody>
                </table>
            </body>
        </HTML>
    </cfmail>
</cfif>

<!--- Redirect to the version page after processing the email notification. --->
<cflocation url="/app/version/?recid=#oldverid#" />
