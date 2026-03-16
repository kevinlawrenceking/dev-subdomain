
<cfparam name="select_userid" default="793" />

<cfset n=0 />
<cfset dsn = application.dsn />
<cfset dbug = "Y" />

<cfquery result="result" datasource="#dsn#" name="z" maxrows="5">
    SELECT * FROM taousers
    WHERE userid = <cfqueryparam cfsqltype="cf_sql_integer" value="#select_userid#" />
</cfquery>

<cfif dbug eq "Y"><cfoutput>select * from taousers where imdbid is null order by userid desc<BR /></cfoutput></cfif>
<cfloop query="z">

<cfset select_userid = z.userid />

    <cfif dbug eq "Y"> <cfoutput><h1>#z.userfirstname# #z.userlastname#</h1></cfoutput><BR /></cfif>

<cfset n=0 />

<cfquery result="result" datasource="#dsn#" name="x">
    SELECT sitetypename, sitetypedescription FROM sitetypes_master
</cfquery>

<cfloop query="x">

    <cfquery result="result" datasource="#dsn#" name="find">
        SELECT * FROM sitetypes_user
        WHERE sitetypename = <cfqueryparam cfsqltype="cf_sql_varchar" value="#x.sitetypename#" />
        AND userid = <cfqueryparam cfsqltype="cf_sql_integer" value="#select_userid#" />
    </cfquery>

    <cfif dbug eq "y">
    <cfoutput>  Select * from sitetypes_user
        where sitetypename = '#x.sitetypename#' and userid = #select_userid# - #find.recordcount#<br/></cfoutput>
    </cfif>

<cfif find.recordcount eq "0">
        <cfoutput>
            <cfset n = n + 1 />
            <cfif n eq "1" and dbug eq "Y">
                <h3>SiteTypes</h3>
            </cfif>
        </cfoutput>
        <cfquery result="result" datasource="#dsn#" name="insert">
            INSERT INTO `sitetypes_user` (`siteTypeName`, `siteTypeDescription`, `userid`)
            VALUES (
                <cfqueryparam cfsqltype="cf_sql_varchar" value="#x.sitetypename#" />,
                <cfqueryparam cfsqltype="cf_sql_varchar" value="#x.sitetypedescription#" />,
                <cfqueryparam cfsqltype="cf_sql_integer" value="#select_userid#" />
            );
        </cfquery>
  <cfif dbug eq "y">
        <cfoutput>
            INSERT INTO sitetypes_user (siteTypeName, siteTypeDescription, userid)
            VALUES ('#x.sitetypename#','#x.sitetypedescription#',#select_userid#);<br/>
Sitetypes_user added: #x.sitetypename#<br />
        </cfoutput>
        </cfif>
    </cfif>

</cfloop>

<cfquery result="result" datasource="#dsn#" name="x">
    SELECT
    s.id
    ,s.sitename
    ,s.siteURL
    ,s.siteicon
    ,s.sitetypeid
    ,t.sitetypename
    FROM sitelinks_master s INNER JOIN sitetypes_master t ON t.sitetypeid = s.siteTypeid
    ORDER BY s.sitename
</cfquery>

<cfloop query="x">

    <cfquery result="result" datasource="#dsn#" name="find">
        SELECT sitetypeid FROM sitetypes_user
        WHERE sitetypename = <cfqueryparam cfsqltype="cf_sql_varchar" value="#x.sitetypename#" />
        AND userid = <cfqueryparam cfsqltype="cf_sql_integer" value="#select_userid#" />
    </cfquery>

     <cfif dbug eq "Y">
<cfoutput>Select sitetypeid from sitetypes_user
    where sitetypename = '#x.sitetypename#' and userid = #select_userid# (#find.recordcount#)<br/></cfoutput></cfif>

    <cfif find.recordcount eq "1">

<cfoutput>
            <cfset n = n + 1 />
            <cfif n eq "1">
                <h3>sitelinks_user</h3>
            </cfif>
        </cfoutput>

        <cfset new_sitetypeid = find.sitetypeid />

        <cfif dbug eq "y">
        <cfoutput><h3>new_sitetypeid: #new_sitetypeid#</h3></cfoutput>
    </cfif>
        <cfquery result="result" datasource="#dsn#" name="find2">
            SELECT * FROM sitelinks_user
            WHERE sitename = <cfqueryparam cfsqltype="cf_sql_varchar" value="#x.sitename#" />
            AND userid = <cfqueryparam cfsqltype="cf_sql_integer" value="#select_userid#" />
        </cfquery>

        <cfif dbug eq "y">
<cfoutput>Select * from sitelinks_user where sitename = '#x.sitename#' and userid = #select_userid#<br/>

<h3>find2 recordcount: #find2.recordcount#</h3>

    </cfoutput>

        </cfif>
        <cfif find2.recordcount eq "0">

            <cfif dbug eq "y">
<cfoutput>     INSERT INTO sitelinks_user_tbl (siteName,siteURL,siteicon,siteTypeid,userid)
                VALUES ('#x.sitename#','#x.siteurl#','#x.siteicon#', #new_sitetypeid#, #select_userid#)<br/></cfoutput>
            </cfif>

            <cfquery result="result" datasource="#dsn#" name="insert">
                INSERT INTO `sitelinks_user_tbl` (`siteName`,`siteURL`,`siteicon`,`siteTypeid`,`userid`)
                VALUES (
                    <cfqueryparam cfsqltype="cf_sql_varchar" value="#x.sitename#" />,
                    <cfqueryparam cfsqltype="cf_sql_varchar" value="#x.siteurl#" />,
                    <cfqueryparam cfsqltype="cf_sql_varchar" value="#x.siteicon#" />,
                    <cfqueryparam cfsqltype="cf_sql_integer" value="#new_sitetypeid#" />,
                    <cfqueryparam cfsqltype="cf_sql_integer" value="#select_userid#" />
                )
            </cfquery>

            <cfif dbug eq "Y">

                <CFOUTPUT> sitelinks_user_tbl: #x.sitename# added</CFOUTPUT><br />

            </cfif>

        </cfif>

    </cfif>

</cfloop>

<cfquery result="result" datasource="#dsn#" name="update">
    UPDATE taousers SET imdbid = 0
    WHERE userid = <cfqueryparam cfsqltype="cf_sql_integer" value="#select_userid#" />
</cfquery>

</cfloop>
