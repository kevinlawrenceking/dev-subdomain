  <h3>Auddialects</h3>

<!--- Use datasource from Application.cfc --->
<cfset dsn = application.dsn />
<cfset rev = application.rev />
<cfset suffix = application.suffix />
<cfset information_schema = application.information_schema />

<cfset rev = rand() />

<cfquery result="result" name="u" maxrows="1000">
        SELECT * FROM taousers
    </cfquery>

    <cfloop query="u">

         <cfquery result="result" name="x" maxrows="10000">
            SELECT auddialectid, auddialect, audcatid, isDeleted
            FROM auddialects
        </cfquery>

        <cfloop query="x">

             <cfquery result="result" name="find">
            SELECT * FROM auddialects_user
            WHERE auddialect = <cfqueryparam cfsqltype="cf_sql_varchar" value="#x.auddialect#" />
            AND userid = <cfqueryparam cfsqltype="cf_sql_integer" value="#u.userid#" />
            </cfquery>

            <cfif find.recordcount is "0">

                 <cfquery result="result" name="insert">

                    INSERT INTO `auddialects_user` (`auddialect`, `audcatid`, `userid`)
                    VALUES (
                        <cfqueryparam cfsqltype="cf_sql_varchar" value="#x.auddialect#" />,
                        <cfqueryparam cfsqltype="cf_sql_integer" value="#x.audcatid#" />,
                        <cfqueryparam cfsqltype="cf_sql_integer" value="#u.userid#" />
                    );

                </cfquery>

                <cfoutput>
                 auddialects added: #x.auddialect# (user #u.userid#)<BR>
                </cfoutput>
            </cfif>

        </cfloop>

</cfloop>
