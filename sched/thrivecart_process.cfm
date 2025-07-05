<cfset dbug="N" />

<!--- Use datasource from Application.cfc --->
<cfset dsn = application.dsn />
<cfset rev = application.rev />
<cfset suffix = application.suffix />
<cfset information_schema = application.information_schema />

<Cfset to_email="kevinking7135@gmail.com" />

<cfquery result="result"  name="U" datasource="#dsn#">
    SELECT th.id
    ,th.CustomerFirst
    ,th.CustomerLast
    ,th.CustomerEmail
    ,th.`status`
    ,th.BaseProductLabel
    ,pp.planName
    FROM thrivecart th
    INNER JOIN paymentplans pp ON pp.BasePaymentPlanId = th.BasePaymentPlanId
    INNER JOIN products pr ON pr.BaseProductId = th.BaseProductId
    WHERE th.STATUS = 'Pending'
</cfquery>

<cfloop query="U">

    <cfset new_id=U.id />

    <cfoutput>

        <cfset new_uuid="#CreateUUID()#" />
        <cfset new_customerfirst="#u.CustomerFirst#" />
        <cfset new_customerlast="#u.CustomerLast#" />
        <cfset new_customerEmail="#u.CustomerEmail#" />
        <cfset new_BaseProductLabel="#u.BaseProductLabel#" />
        <cfset new_planName="#u.planName#" />
    </cfoutput>

    <cfquery result="result"  name="update" datasource="#dsn#">
        UPDATE thrivecart
        set uuid =
        <cfqueryparam cfsqltype="cf_sql_varchar" value="#new_uuid#" />
        where id = #new_id#
    </cfquery>

    <cfmail 
    from="support@theactorsoffice.com" 
    to="#new_customerEmail#"  bcc="kevinking7135@gmail.com"
    subject="#new_customerfirst#, set up your profile for The Actor's Office!" 
    type="HTML">
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
            <p>Hi #new_customerfirst#,</p>

            <p>Your purchase of The Actor's Office has been received.</p>

            <p>Now, it's time for you to create your user profile and get immediate access to the system.</p>

            <p>To get started, click the button below where you'll create your password and be walked through the setup process.</p>

            <p><a href="https://#host#.theactorsoffice.com/setup/?uuid=#new_uuid#"><button>GET STARTED</button></a></p>

            <p>If you have any questions, simply respond to this email.</p>

            <p>Welcome aboard!</p>

            <p>More to come...</p>
            <p>Jodie Bentley and The Actor's Office Team</p>

            <p>&nbsp;</p>

</body>

        </HTML>
</cfmail>

    <cfquery result="result"  name="update" datasource="#dsn#">
        UPDATE thrivecart
        set status =
        <cfqueryparam cfsqltype="cf_sql_varchar" value="Emailed" />
        where id = #new_id#
    </cfquery>

</cfloop>

<cfinclude template="thrivecart_process_audition.cfm" />
