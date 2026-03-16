<cfparam name="select_userid" default="792" />

<cfquery result="result" name="x" datasource="#application.dsn#">
    SELECT sitetypeid, sitetypename, sitetypedescription
    FROM sitetypes_user
    WHERE userid = <cfqueryparam cfsqltype="cf_sql_integer" value="#select_userid#" />
</cfquery>

<cfloop query="x">

    <cfset new_pntitle = x.sitetypename & " Links" />
    <cfset new_sitetypeid = x.sitetypeid />

    <cfquery result="result" name="Findtotal" maxrows="1" datasource="#application.dsn#">
        SELECT p.pnOrderno + 1 AS new_pnOrderNo
        FROM pgpanels_user p
        WHERE p.userid = <cfqueryparam cfsqltype="cf_sql_integer" value="#select_userid#" />
        ORDER BY p.pnOrderno DESC
    </cfquery>

    <cfquery name="add" datasource="#application.dsn#" result="PN">
        INSERT INTO pgpanels_user (pnTitle, pnFilename, pnorderno, pncolxl, pncolMd, pnDescription, IsDeleted, IsVisible, userid)
        VALUES (
            <cfqueryparam cfsqltype="cf_sql_varchar" value="#new_pnTitle#" />,
            <cfqueryparam cfsqltype="cf_sql_varchar" value="mylinks_user.cfm" />,
            <cfqueryparam cfsqltype="cf_sql_integer" value="#Findtotal.new_pnOrderNo#" />,
            3, 3,
            <cfqueryparam cfsqltype="cf_sql_varchar" value="" />,
            0, 1,
            <cfqueryparam cfsqltype="cf_sql_integer" value="#select_userid#" />
        )
    </cfquery>

    <cfset new_pnid = PN.generated_key />

    <cfquery result="result" name="add" datasource="#application.dsn#">
        UPDATE sitetypes_user
        SET pnid = <cfqueryparam cfsqltype="cf_sql_integer" value="#new_pnid#" />
        WHERE sitetypeid = <cfqueryparam cfsqltype="cf_sql_integer" value="#new_sitetypeid#" />
    </cfquery>

</cfloop>

