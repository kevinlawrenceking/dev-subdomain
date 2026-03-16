

<cfquery result="result" name="x" maxrows="10000">
 SELECT min(notid) as new_notid, actionid, userid, suid
                         FROM funotifications

                         GROUP BY actionid, userid, suid

                        HAVING COUNT(*) > 1
                        ORDER BY actionid, userid, suid
                        LIMIT 10000
</cfquery>

<cfloop query="x">
<cfquery result="result" name="rr">
UPDATE funotifications_tbl
SET isdeleted = 1
WHERE notid = <cfqueryparam cfsqltype="cf_sql_integer" value="#x.new_notid#" />
</cfquery>

</cfloop>

<cfquery result="result" name="de">
UPDATE actionusers_tbl
SET isdeleted = 1
</cfquery>

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
