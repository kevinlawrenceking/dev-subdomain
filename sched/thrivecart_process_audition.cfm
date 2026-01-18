<cfset dbug="N" />

<Cfset to_email="kevinking7135@gmail.com" />

<cfset currentURL = cgi.server_name />

<cfset host = ListFirst(currentURL, ".") />

<cfif #host# is "app">
    <cfset dsn = "abo" />
  <cfoutput>  <cfset rev = "#rand()#" /> </cfoutput>
    <cfset suffix = "_1.5" />
    <cfset information_schema = "actorsbusinessoffice" />
    <cfelse>
  <cfset dsn = "abod" />
<cfset rev = rand() />
        <cfset suffix = "" />
        
    <cfset information_schema = "new_development" />
</cfif>

<cfquery result="result"  name="U" datasource="#dsn#">
    SELECT th.id,u.userid,u.recordname,th.purchasedate,u.useremail

    FROM thrivecart th
    
    INNER JOIN taousers u ON u.userEmail = th.Customeremail
    
    WHERE th.STATUS = 'Pending' AND th.BasePaymentPlanID = 88221 AND th.BaseProductid = 61 AND u.isauditionmodule = 0
</cfquery>

<cfloop query="U">

    <cfset new_userid=U.userid />
    <cfset new_id=U.id />
    <cfoutput>

<cfset new_recordname="#u.recordname#" />
        <cfset new_useremail="#u.useremail#" />
 <cfset new_purchasedate="#u.purchasedate#" />
 
    </cfoutput>

    <cfquery result="result"  name="update" datasource="#dsn#">
        UPDATE thrivecart
        set STATUS = 'Completed'
         
        where id = #new_id#
    </cfquery>

<cfmail from="support@theactorsoffice.com" to="support@theactorsoffice.com" bcc="kevinking7135@gmail.com" subject="Audition module activation: #new_recordname#" type="HTML">
        <HTML>

        <head>
            <title>The Actor's Office</title>

        </head>

        <body>
            <!--- Style Tag in the Body, not Head, for Email --->
            <style type="text/css">
                body {
                    font-size: 14px;
                }

            </style>

<p>This is an automated confirmation</p>

            <p>The audition module has been activated for #new_recordname#.</p>

       <p>Purchased: #new_purchasedate#</p>

</body>

        </HTML>
    </cfmail>
    <cfquery result="result"  name="update" datasource="#dsn#">
        UPDATE taousers
        set isAuditionModule = 1
         
        where userid = #new_userid#
    </cfquery>

</cfloop>
