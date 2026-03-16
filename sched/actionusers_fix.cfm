

<cfquery result="result" name="u" maxrows="1000">
        SELECT * FROM taousers
        </cfquery>

    <cfloop query="u">

        <cfquery result="result" name="xs" maxrows="10000">
        SELECT actionid, actiondaysno, actiondaysrecurring FROM fuactions
        </cfquery>

        <cfloop query="xs">

<cfquery result="result" name="find">
            SELECT * FROM actionusers
            WHERE actionid = <cfqueryparam cfsqltype="cf_sql_integer" value="#xs.actionid#" />
            AND userid = <cfqueryparam cfsqltype="cf_sql_integer" value="#u.userid#" />
            </cfquery>

            <cfif find.recordcount is "0">

                <cfquery result="result" name="insert">
                    INSERT INTO `actionusers_tbl` (`actionid`,`userid`,`actiondaysno`<cfif xs.actiondaysrecurring is not "">,`actiondaysrecurring`</cfif>,`IsDeleted`)
                    VALUES (
                        <cfqueryparam cfsqltype="cf_sql_integer" value="#xs.actionid#" />,
                        <cfqueryparam cfsqltype="cf_sql_integer" value="#u.userid#" />,
                        <cfqueryparam cfsqltype="cf_sql_integer" value="#xs.actiondaysno#" />
                        <cfif xs.actiondaysrecurring is not "">,<cfqueryparam cfsqltype="cf_sql_integer" value="#xs.actiondaysrecurring#" /></cfif>,
                        0
                    );
                </cfquery>

            </cfif>

        </cfloop>

</cfloop>
