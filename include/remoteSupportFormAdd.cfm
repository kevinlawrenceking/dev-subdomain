<CFINCLUDE template="/include/remote_load.cfm" />
<cfparam name="mailuser" default="Y">
<cfparam name="qstring" default="">

    <cfset script_name_include="/include/#ListLast(GetCurrentTemplatePath(), " \")#" />
    <cfinclude template="/include/bigbrotherinclude.cfm" />






    <cfquery name="add" datasource="#dsn#" result="result">
        INSERT INTO tickets (pgid,verid,ticketName,ticketdetails,tickettype,userid,ticketactive,ticketstring)
        Values (
        <cfqueryparam value="0" cfsqltype="cf_sql_integer" />
        ,
        
        <cfqueryparam value="#new_verid#" cfsqltype="cf_sql_integer" />
        ,
        <cfqueryparam value="#new_ticketName#" cfsqltype="cf_sql_varchar" />
        ,
        <cfqueryparam value="#new_ticketdetails#" cfsqltype="cf_sql_varchar" />
        ,
        <cfqueryparam value="#new_tickettype#" cfsqltype="cf_sql_varchar" />
        ,
        <cfqueryparam value="#new_userid#" cfsqltype="cf_sql_integer" />
        ,
        <cfqueryparam value="Y" cfsqltype="cf_sql_varchar" />
        ,
        <cfqueryparam value="#qstring#" cfsqltype="cf_sql_varchar" />
        )


    </cfquery>
    <cfquery name="users" datasource="#dsn#">
    Select * from taousers where userid = #session.userid#
    </cfquery>
    <cfset recid=result.generatedkey>
        
    <cfoutput>
        
    <cfset new_tlogDetails = "Created the ticket." />
    <cfset new_ticketid = "#recid#" />
    <cfset new_ticketstatus = "Pending" />
    </cfoutput>
     
    <cfinclude template="/include/qry/inserttlog.cfm" />
        
    
    

    
    
    

    

        <cfquery name="details" datasource="#dsn#">
            SELECT u.isbetatester
            ,p.pgid
            ,t.ticketID as recID
            ,t.ticketcreateddate
            ,t.ticketID as pk
            ,CONCAT(u.userfirstname,' ',u.userlastname) AS col1
            ,'User' as head1
            ,'Date' as head2
            ,'Time' as head3
            ,'Page' as head4
            ,'Status' as head5
            ,'Title' as head6
            ,u.useremail
            ,u.userfirstname
            ,'Response' as head7
            ,'Completed' as head8
            ,t.ticketResponse as col7
            ,t.ticketCompletedDate as col8
            ,t.ticketdetails
            ,CONCAT(u.userfirstname,' ',u.userlastname) AS col1
            ,t.ticketCreatedDate AS col2
            ,t.ticketCreatedDate AS col3
            ,p.pgname AS col4
            ,t.ticketStatus AS col5
            ,t.ticketName AS col6
            ,t.ticketResponse
            ,t.ticketCompletedDate
            ,p.pgname
            ,t.tickettype
            ,p.pgdir
            ,t.complete_email
            ,t.initial_email
            FROM tickets t
            INNER JOIN taousers u ON u.userid = t.userid
            INNER JOIN pgpages p ON p.pgid = t.pgid
            WHERE t.ticketid = #recid#
        </cfquery>

        <cfset to_email="#details.useremail#" />
 
<cfset todoist_date = "#dateformat('#details.ticketcreateddate#','mm-dd-yyyy')#" />
<cfset date_tag = "" />
<cfif #todoist_date# is not "">
<cfset date_tag = "<date #todoist_date#" />
</cfif>

<cfif #mailuser# is "Y" >





    <cfmail from="support@theactorsoffice.com" 
            to="add.task.swxn8hp4jz4m0x79@todoist.net" 
            bcc="kevinking7135@gmail.com" 
            subject="#details.recid# - #details.ticketdetails# !!1 @Programming" 
            type="HTML">
        <cfset emailBody = "<p>#details.ticketdetails#</p>">
        #emailBody#
    </cfmail>






   <cfmail from="support@theactorsoffice.com"   to="add.task.swxn8hp4jz4m0x79@todoist.net" bcc="kevinking7135@gmail.com" subject="#details.recid# - #details.ticketdetails# " type="HTML">
      
</cfmail>
        <cfmail from="support@theactorsoffice.com" failto="kking@theactorsoffice.com" replyto="support@theactorsoffice.com" to="#to_email#,Cansoff@gmail.com" bcc="kevinking7135@gmail.com,cansoff@gmail.com" usessl="true"  usetls="true" subject="TAO TICKET NO #details.recid#" type="HTML">
            <HTML>

            <head>
                <title>TAO TICKET NO #details.recid#</title>

            </head>

            <body>
                <!--- Style Tag in the Body, not Head, for Email --->
                <style type="text/css">
                    body {
                        font-size: 14px;
                    }

                </style>
                <p>Hi #details.userfirstname#,</p>
                <p>This is to inform you that #details.tickettype# Ticket No. #details.recid# has been generated. Please find the details below.</p>

                <cfif #details.tickettype# is "Error">
                    <p>I'm currently troubleshooting this issue and I'll email you if I have any questions.</p>
                </cfif>
                <cfif #details.tickettype# is "change">
                    <p>I'll be reviewing your change request shortly. </p>
                </cfif>
                <cfif #details.tickettype# is "feedback">
                    <p>I appreciate your feedback! We'll review this shortly.</p>
                </cfif>


                <cfif #trim(details.ticketresponse)# is not "">
<blockquote>#trim(details.ticketresponse)#</blockquote>
                </cfif>
                <p>If there are any further issues on this topic, please reply to this email and ticket number.</p>




                <p>Best,</p>
             
                <p>Kevin</p>

   <p>&nbsp;</p>

                <table class="main_html" style="direction: ltr;                                                                                                        border-radius: 0;                                    moz-border-radius:0;                                    khtml-border-radius:0;                                    o-border-radius:0;                                    webkit-border-radius:0;                                    ms-border-radius:0;                                    border-collapse: collapse;">
                    <tbody>
                        <tr>
                            <td>

                                <table cellpadding="0" cellspacing="0" class="ws-tpl" style="font-family: Verdana; line-height: 1.25;padding-bottom: 10px;color:##000;">
                                    <tbody>
                                        <tr>
                                            <td style="vertical-align: top; padding-right: 24px;">

                                                <table cellpadding="0" cellspacing="0" class="ws-tpl-photo" style="width:65px;">
                                                    <tbody>
                                                        <tr>
                                                            <td><img src="https://d36urhup7zbd7q.cloudfront.net/9f1033c8-aa07-4e56-a7e8-dedf97184598/IMG_4968.format_png.resize_200x.jpeg" height="100" width="65" style="width: 65px; border-radius: 0px; height: 100px;" class="fr-fil fr-dib"></td>
                                                        </tr>
                                                    </tbody>
                                                </table>
                                            </td>
                                            <td style="vertica-align:top;" valign="top">

                                                <table cellpadding="0" cellspacing="0" style="font-family: Verdana;">
                                                    <tbody>
                                                        <tr>
                                                            <td style="line-height: 1.32 ;"><span class="ws-tpl-name" data-acs="name" style="color-scheme: light only;  color: ##406E8E;  font-size: 12px;  font-family: Verdana;  font-weight: bold;">&nbsp;Kevin King&nbsp;</span>
                                                                <br><span class="ws-tpl-title" data-acs="title" style="color-scheme: light only;  font-size: 12px;  letter-spacing: 0px;  color: ##4e4b4c;  font-family: Verdana;  text-transform: initial;  color: ##406E8E;">&nbsp;Partner / Lead Application Developer at&nbsp;</span> <span class="ws-tpl-company" data-acs="company" style="color-scheme: light only;  font-size: 12px;  letter-spacing: 0px; color: ##4e4b4c;  font-family: Verdana;  text-transform: initial;  color: ##406E8E;">&nbsp;<strong>The Actor&##39;s Office&nbsp;</strong></span>
                                                            </td>
                                                        </tr>
                                                        <tr>
                                                            <td style="line-height: 0;  padding-top: 14px;  padding-bottom: 14px ;">

                                                                <table cellpadding="0" cellspacing="0" style="width: 100%;">
                                                                    <tbody>
                                                                        <tr>
                                                                            <td class="ws-tpl-separator" style="line-height: 0;  font-size: 1pt;  border-bottom-width: 5px;  border-bottom-style: solid ;  border-bottom-color: ##406E8E ;">&nbsp;</td>
                                                                        </tr>
                                                                    </tbody>
                                                                </table>
                                                            </td>
                                                        </tr>
                                                        <tr>
                                                            <td style="line-height:0;">

                                                                <table cellpadding="0" cellspacing="0">
                                                                    <tbody>
                                                                        <tr>
                                                                            <td>

                                                                                <table cellpadding="0" cellspacing="0">
                                                                                    <tbody>
                                                                                        <tr>
                                                                                            <td style="line-height: 0%; padding-bottom: 8px;">

                                                                                                <table cellpadding="0" cellspacing="0" class="ws-tpl-website" style="line-height: 14px; font-size: 12px;font-family: Verdana;">
                                                                                                    <tbody>
                                                                                                        <tr>
                                                                                                            <td style=" color-scheme: light only; font-family: Verdana; font-weight:bold; font-size: 12px; color: ##406E8E ;"><span style="line-height: 1.2;">W</span></td>
                                                                                                            <td style="width: 7px; font-size: 1pt; line-height: 0;" width="7">&nbsp;</td>
                                                                                                            <td style="color-scheme: light only; font-family: Verdana;font-size: 12px;"><a href="http://www.theactorsoffice.com" style="color-scheme: light only; text-decoration: none; font-size: 12px;font-family: Verdana;" target="_blank">&nbsp;<span data-acs="website" style="line-height: 1.2; color-scheme: light only; color: ##212121; font-family: Verdana; white-space: nowrap; font-size: 12px;">&nbsp;www.theactorsoffice.com&nbsp;</span>&nbsp;</a></td>
                                                                                                        </tr>
                                                                                                    </tbody>
                                                                                                </table>
                                                                                            </td>
                                                                                            <td style="line-height: 0%; padding-bottom: 8px;">

                                                                                                <table cellpadding="0" cellspacing="0" class="ws-tpl-email" style="line-height: 14px; font-size: 12px;font-family: Verdana;">
                                                                                                    <tbody>
                                                                                                        <tr>
                                                                                                            <td style="padding: 0 8px;"><span style="color-scheme: light only; font-family: Verdana; font-weight:bold; font-size: 12px; color: ##212121;">&nbsp;</span></td>
                                                                                                            <td style=" color-scheme: light only; font-family: Verdana; font-weight:bold; font-size: 12px; color: ##406E8E ;"><span style="line-height: 1.2;">E</span></td>
                                                                                                            <td style="width: 7px; font-size: 1pt; line-height: 0;" width="7">&nbsp;</td>
                                                                                                            <td style="color-scheme: light only; font-family: Verdana;font-size: 12px;"><a href="mailto:kking@theactorsoffice.com" style="color-scheme: light only; text-decoration: none; font-size: 12px;font-family: Verdana;" target="_blank">&nbsp;<span data-acs="email" style="line-height: 1.2; color-scheme: light only; color: ##212121; font-family: Verdana; white-space: nowrap; font-size: 12px;">&nbsp;kking@theactorsoffice.com&nbsp;</span>&nbsp;</a></td>
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
                <p> User: #details.col1# on </p>
                <p><strong>Type:</strong> #details.tickettype#</p>
                <p><strong>Status:</strong> #details.col5#</p>
                <p><strong>User Details:</strong> #details.ticketdetails#</p>

                <p> Received on #Dateformat("#details.ticketCreatedDate#","long")# at #TimeFormat("#details.ticketCreatedDate#","medium")#</p>
            </body>

            </HTML>
        </cfmail>
</cfif>









        <cfoutput>
            <cfif #qstring# is not "">

                <cflocation url="/app/#pgdir#/?#qstring#" />
                <cfelse>
                    <cflocation url="/app/#pgdir#/" />

            </cfif>


        </cfoutput>
