<cfcomponent displayname="TicketService" hint="Handles operations for Ticket table" > 
<cffunction output="false" name="UPDtickets" access="public" returntype="void">
    <cfargument name="ticketid" type="numeric" required="true">
    <cfargument name="new_ticketname" type="string" required="true">
    <cfargument name="new_ticketdetails" type="string" required="true">
    <cfargument name="new_ticketresponse" type="string" required="true">
    <cfargument name="new_ticketStatus" type="string" required="true">
    <cfargument name="new_ticketType" type="string" required="true">
    <cfargument name="new_testingscript" type="string" required="true">
    <cfargument name="new_patchNote" type="string" required="true">
    <cfargument name="new_environ" type="string" required="true">
    <cfargument name="new_ticketPriority" type="string" required="true">
    <cfargument name="new_userid" type="numeric" required="false">
    <cfargument name="new_verid" type="numeric" required="false">
    <cfargument name="new_pgid" type="numeric" required="false">
    <cfargument name="new_esthours" type="numeric" required="false">

<cfquery result="result"  name="updateTicketQuery">
            UPDATE tickets SET 
                ticketname = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.new_ticketname#">,
                ticketdetails = <cfqueryparam cfsqltype="cf_sql_longvarchar" value="#arguments.new_ticketdetails#">,
                ticketresponse = <cfqueryparam cfsqltype="cf_sql_longvarchar" value="#arguments.new_ticketresponse#">,
                ticketStatus = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.new_ticketStatus#">,
                ticketType = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.new_ticketType#">,
                testingscript = <cfqueryparam cfsqltype="cf_sql_longvarchar" value="#arguments.new_testingscript#">,
                patchNote = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.new_patchNote#">,
                environ = <cfqueryparam cfsqltype="cf_sql_char" value="#arguments.new_environ#">,
                ticketPriority = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.new_ticketPriority#">
            <cfif isNumeric(arguments.new_userid) AND arguments.new_userid NEQ "">
                , userid = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.new_userid#">
            </cfif>
            <cfif isNumeric(arguments.new_verid) AND arguments.new_verid NEQ "">
                , verid = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.new_verid#">
            </cfif>
            <cfif isNumeric(arguments.new_pgid) AND arguments.new_pgid NEQ "">
                , pgid = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.new_pgid#">
            </cfif>
            <cfif isNumeric(arguments.new_esthours) AND arguments.new_esthours NEQ "">
                , esthours = <cfqueryparam cfsqltype="cf_sql_float" value="#decimalformat(arguments.new_esthours)#">
            </cfif>
            WHERE ticketid = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.ticketid#">
        </cfquery>

</cffunction>
<cffunction output="false" name="SELtickets" access="public" returntype="query">
    <cfargument name="conditions" type="struct" required="false" default="#structNew()#">
    <cfset var queryResult = "">
    <cfset var sql = "SELECT DISTINCT t.ticketstatus FROM tickets t">
    <cfset var whereClause = "">
    <cfset var paramList = []>

<!--- Build WHERE clause dynamically based on arguments --->
    <cfif structCount(arguments.conditions) gt 0>
        <cfset whereClause = " WHERE ">
        <cfloop collection="#arguments.conditions#" item="key">
            <cfset whereClause &= "t.#key# = ? AND ">
            <cfset arrayAppend(paramList, {value=arguments.conditions[key], cfsqltype=determineSQLType(key)})>
        </cfloop>
        <cfset whereClause = left(whereClause, len(whereClause) - 5)> <!--- Remove trailing ' AND ' --->
    </cfif>

<!--- Complete SQL statement with ORDER BY clause --->
    <cfset sql &= whereClause & " ORDER BY t.ticketstatus">

<!--- Execute the query within a try/catch block for error handling --->

<cfquery result="result" name="queryResult" >
            #sql#
            <cfloop array="#paramList#" index="param">
                <cfqueryparam value="#param.value#" cfsqltype="#param.cfsqltype#">
            </cfloop>
        </cfquery>

<!--- Return the query result --->
    <cfreturn queryResult>
</cffunction>
<cffunction output="false" name="SELtickets_23720" access="public" returntype="query">
    <cfargument name="verid" type="numeric" required="true">
    <cfargument name="col6" type="numeric" required="true">

<cfset var sql = "">

<cfset sql = "
            SELECT v.major, v.minor, v.patch, v.verid AS id, v.alphabeta, 
                   CONCAT(v.major, '.', v.minor, '.', v.patch, '.', v.version, '.', v.build, ' - ', v.versiontype) AS name,
                   ((v.hoursavail) - IFNULL((SELECT SUM(esthours) FROM tickets t WHERE verid = v.verid), 0)) AS hoursleft
            FROM taoversions v
            WHERE v.verid <> ? 
              AND ((v.hoursavail) - IFNULL((SELECT SUM(esthours) FROM tickets t WHERE verid = v.verid), 0) - ?) >= 0
              AND v.versionstatus = 'Pending'
            UNION
            SELECT v.major, v.minor, v.patch, v.verid AS id, v.alphabeta,
                   CONCAT(v.major, '.', v.minor, '.', v.patch, '.', v.version, '.', v.build, ' - ', v.versiontype) AS name,
                   ((v.hoursavail) - (SELECT SUM(esthours) FROM tickets t WHERE verid = v.verid)) AS hoursleft
            FROM taoversions v
            WHERE v.verid = ?
            ORDER BY major, minor, patch
        ">

<cfquery name="result" >
            #sql#
            <cfqueryparam value="#arguments.verid#" cfsqltype="CF_SQL_INTEGER">
            <cfqueryparam value="#arguments.col6#" cfsqltype="CF_SQL_DECIMAL">
            <cfqueryparam value="#arguments.verid#" cfsqltype="CF_SQL_INTEGER">
        </cfquery>

<cfreturn result>

</cffunction>
<cffunction output="false" name="UPDtickets_23866" access="public" returntype="void" hint="Updates the status of a ticket to Closed and marks it as deleted.">
    <cfargument name="recid" type="numeric" required="true" hint="The ID of the ticket to update.">

<cfquery result="result" >
            UPDATE tickets_tbl 
            SET ticketstatus = <cfqueryparam value="Closed" cfsqltype="CF_SQL_VARCHAR">, 
                isdeleted = <cfqueryparam value="1" cfsqltype="CF_SQL_BIT">
            WHERE ticketid = <cfqueryparam value="#arguments.recid#" cfsqltype="CF_SQL_INTEGER">
        </cfquery>

</cffunction>
<cffunction output="false" name="SELtickets_23997" access="public" returntype="query">
    <cfargument name="recid" type="numeric" required="true">

<cfquery name="result" >
            SELECT 
                p.pgid, 
                t.ticketID AS recID, 
                t.ticketID AS pk, 
                CONCAT(u.userfirstname, ' ', u.userlastname) AS col1, 
                'User' AS head1, 
                'Date' AS head2, 
                'Time' AS head3, 
                'Page' AS head4, 
                'Status' AS head5, 
                'Title' AS head6, 
                'Response' AS head7, 
                'Completed' AS head8, 
                t.ticketResponse, 
                t.ticketCompletedDate, 
                t.ticketdetails, 
                t.ticketCreatedDate, 
                t.ticketCreatedDate, 
                p.pgname, 
                t.ticketStatus, 
                t.ticketType, 
                t.ticketPriority, 
                t.verid, 
                t.esthours, 
                t.ticketName, 
                t.ticketResponse, 
                t.ticketCompletedDate, 
                p.pgname, 
                p.pgdir, 
                t.patchnote, 
                t.complete_email, 
                t.initial_email
            FROM tickets t
            INNER JOIN taousers u ON u.userid = t.userid
            INNER JOIN pgpages p ON p.pgid = t.pgid
            WHERE t.verid = <cfqueryparam value="#arguments.recid#" cfsqltype="CF_SQL_INTEGER">
            AND t.patchnote <> <cfqueryparam value="" cfsqltype="CF_SQL_VARCHAR">
        </cfquery>

<cfreturn result>
</cffunction>
<cffunction output="false" name="DETtickets" access="public" returntype="query">
    <cfargument name="recid" type="numeric" required="true">

<cfquery name="result" >
            SELECT 
                p.pgid, 
                t.ticketID,
                t.ticketID AS recID, 
                t.ticketID AS pk, 
                CONCAT(u.userfirstname, ' ', u.userlastname) AS col1, 
                u.userid,
                'User' AS head1, 
                'Date' AS head2, 
                'Time' AS head3, 
                'Page' AS head4, 
                'Status' AS head5, 
                'Title' AS head6, 
                'Response' AS head7, 
                'Completed' AS head8, 
                t.ticketResponse, 
                t.environ,
                t.ticketCompletedDate, 
                t.ticketdetails, 
                t.ticketCreatedDate, 
                t.ticketCreatedDate, 
                p.pgname, 
                t.ticketStatus, 
                t.ticketType, 
                t.ticketPriority, 
                t.verid, 
                t.esthours, 
                t.ticketName, 
                t.ticketResponse, 
                t.ticketCompletedDate, 
                p.pgname, 
                p.pgdir, 
                t.patchnote, 
                t.complete_email, 
                t.testingscript,
                t.customTestPageName,
                t.customTestPageLink,
                t.initial_email
            FROM tickets t
            INNER JOIN taousers u ON u.userid = t.userid
            INNER JOIN pgpages p ON p.pgid = t.pgid
            WHERE t.ticketid = <cfqueryparam value="#arguments.recid#" cfsqltype="CF_SQL_INTEGER">
        </cfquery>

<cfreturn result>
</cffunction>
<cffunction output="false" name="UPDtickets_24076" access="public" returntype="void" hint="Updates the ticket status based on ticket ID.">
    <cfargument name="new_ticketid" type="numeric" required="true" hint="The ID of the ticket to update.">

<cfquery result="result" name="updateStatus" >
            UPDATE tickets 
            SET ticketstatus = <cfqueryparam value="Tested - Success" cfsqltype="CF_SQL_VARCHAR">
            WHERE ticketid = <cfqueryparam value="#arguments.new_ticketid#" cfsqltype="CF_SQL_INTEGER">
        </cfquery>

</cffunction>
<cffunction output="false" name="UPDtickets_24077" access="public" returntype="void">
    <cfargument name="new_ticketid" type="numeric" required="true">

<cfquery result="result" name="updateQuery" >
            UPDATE tickets 
            SET ticketstatus = <cfqueryparam value="Tested - Bug" cfsqltype="CF_SQL_VARCHAR"> 
            WHERE ticketid = <cfqueryparam value="#arguments.new_ticketid#" cfsqltype="CF_SQL_INTEGER">
        </cfquery>

</cffunction>
<cffunction output="false" name="DETtickets_24109" access="public" returntype="query">
    <cfargument name="recid" type="numeric" required="true">

<cfquery name="result" >
            SELECT 
                p.pgid, 
                t.ticketID AS recID, 
                t.ticketID AS pk, 
                CONCAT(u.userfirstname, ' ', u.userlastname) AS col1, 
                'User' AS head1, 
                'Date' AS head2, 
                'Time' AS head3, 
                'Page' AS head4, 
                'Status' AS head5, 
                'Title' AS head6, 
                'Response' AS head7, 
                'Completed' AS head8, 
                t.ticketResponse AS col7, 
                t.ticketCompletedDate AS col8, 
                t.ticketdetails, 
                t.ticketCreatedDate AS col2, 
                t.ticketCreatedDate AS col3, 
                p.pgname AS col4, 
                t.ticketStatus AS col5, 
                t.ticketName AS col6, 
                t.ticketResponse, 
                t.ticketCompletedDate, 
                p.pgname, 
                p.pgdir, 
                t.patchnote, 
                t.complete_email, 
                t.initial_email
            FROM tickets t
            INNER JOIN taousers u ON u.userid = t.userid
            INNER JOIN pgpages p ON p.pgid = t.pgid
            WHERE t.ticketid = <cfqueryparam value="#arguments.recid#" cfsqltype="CF_SQL_INTEGER">
        </cfquery>

<cfreturn result>
</cffunction>
<cffunction output="false" name="INStickets" access="public" returntype="numeric">
    <cfargument name="new_verid" type="numeric" required="true">
    <cfargument name="new_ticketName" type="string" required="true">
    <cfargument name="new_ticketdetails" type="string" required="true">
    <cfargument name="new_tickettype" type="string" required="true">
    <cfargument name="new_userid" type="numeric" required="true">
    <cfargument name="qstring" type="string" required="true">

<cfquery result="result" >
            INSERT INTO tickets (
                pgid, verid, ticketName, ticketdetails, tickettype, userid, ticketactive, ticketstring
            ) VALUES (
                <cfqueryparam value="0" cfsqltype="cf_sql_integer">,
                <cfqueryparam value="#arguments.new_verid#" cfsqltype="cf_sql_integer">,
                <cfqueryparam value="#arguments.new_ticketName#" cfsqltype="cf_sql_varchar">,
                <cfqueryparam value="#arguments.new_ticketdetails#" cfsqltype="cf_sql_varchar">,
                <cfqueryparam value="#arguments.new_tickettype#" cfsqltype="cf_sql_varchar">,
                <cfqueryparam value="#arguments.new_userid#" cfsqltype="cf_sql_integer">,
                <cfqueryparam value="Y" cfsqltype="cf_sql_varchar">,
                <cfqueryparam value="#arguments.qstring#" cfsqltype="cf_sql_varchar">
            )
        </cfquery>
<cfreturn result.generatedKey>
</cffunction>
<cffunction output="false" name="DETtickets_24162" access="public" returntype="query">
    <cfargument name="recid" type="numeric" required="true">

<cfquery name="result" >
            SELECT 
                u.isbetatester, 
                p.pgid, 
                t.ticketID AS recID, 
                t.ticketcreateddate, 
                t.ticketID AS pk, 
                CONCAT(u.userfirstname, ' ', u.userlastname) AS col1, 
                'User' AS head1, 
                'Date' AS head2, 
                'Time' AS head3, 
                'Page' AS head4, 
                'Status' AS head5, 
                'Title' AS head6, 
                u.useremail, 
                u.userfirstname, 
                'Response' AS head7, 
                'Completed' AS head8, 
                t.ticketResponse AS col7, 
                t.ticketCompletedDate AS col8, 
                t.ticketdetails, 
                CONCAT(u.userfirstname, ' ', u.userlastname) AS col1, 
                t.ticketCreatedDate AS col2, 
                t.ticketCreatedDate AS col3, 
                p.pgname AS col4, 
                t.ticketStatus AS col5, 
                t.ticketName AS col6, 
                t.ticketResponse, 
                t.ticketCompletedDate, 
                p.pgname, 
                t.tickettype, 
                p.pgdir, 
                t.complete_email, 
                t.initial_email
            FROM tickets t
            INNER JOIN taousers u ON u.userid = t.userid
            INNER JOIN pgpages p ON p.pgid = t.pgid
            WHERE t.ticketid = <cfqueryparam value="#arguments.recid#" cfsqltype="CF_SQL_INTEGER">
        </cfquery>

<cfreturn result>
</cffunction>
<cffunction output="false" name="DETtickets_24208" access="public" returntype="query">
    <cfargument name="recid" type="numeric" required="true">

<cfquery name="result" >
            SELECT 
                p.pgid, 
                t.ticketID AS recID, 
                t.ticketID AS pk, 
                CONCAT(u.userfirstname, ' ', u.userlastname) AS col1, 
                'User' AS head1, 
                'Date' AS head2, 
                'Time' AS head3, 
                'Page' AS head4, 
                'Status' AS head5, 
                'Title' AS head6, 
                'Response' AS head7, 
                'Completed' AS head8, 
                t.ticketResponse, 
                t.ticketCompletedDate, 
                t.ticketdetails, 
                t.ticketCreatedDate, 
                p.pgname, 
                t.ticketStatus, 
                t.ticketType, 
                t.ticketPriority, 
                t.verid, 
                t.esthours, 
                t.testingscript, 
                t.ticketName, 
                t.customtestpagename, 
                t.customtestpagelink, 
                t.patchnote, 
                t.complete_email, 
                t.initial_email
            FROM tickets t
            INNER JOIN taousers u ON u.userid = t.userid
            INNER JOIN pgpages p ON p.pgid = t.pgid
            WHERE t.ticketid = <cfqueryparam value="#arguments.recid#" cfsqltype="CF_SQL_INTEGER">
        </cfquery>

<cfreturn result>
</cffunction>
<cffunction output="false" name="UPDtickets_24216" access="public" returntype="void">
    <cfargument name="new_ticketname" type="string" required="true">
    <cfargument name="new_testingscript" type="string" required="true">
    <cfargument name="new_ticketType" type="string" required="true">
    <cfargument name="new_ticketStatus" type="string" required="true">
    <cfargument name="new_verid" type="any" required="true">
    <cfargument name="new_pgid" type="numeric" required="true">
    <cfargument name="new_customtestpagename" type="string" required="true">
    <cfargument name="new_customtestpagelink" type="string" required="true">
    <cfargument name="new_ticketPriority" type="string" required="true">
    <cfargument name="new_esthours" type="numeric" required="true">
    <cfargument name="ticketid" type="numeric" required="true">

<cfquery result="result" name="updateQuery">
            UPDATE tickets 
            SET 
                ticketname = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.new_ticketname#" />,
                testingscript = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.new_testingscript#" />,
                ticketType = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.new_ticketType#" />,
                ticketStatus = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.new_ticketStatus#" />,
                verid = 
                    <cfif arguments.new_verid is "NULL"> 
                        NULL, ticketstatus = 'Pending' 
                    <cfelse> 
                        <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.new_verid#" /> 
                    </cfif>,
                pgid = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.new_pgid#" />,
                customtestpagename = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.new_customtestpagename#" />,
                customtestpagelink = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.new_customtestpagelink#" />,
                ticketPriority = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.new_ticketPriority#" />,
                esthours = <cfqueryparam cfsqltype="cf_sql_float" value="#numberformat(arguments.new_esthours, '9.99')#" />
            WHERE 
                ticketid = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.ticketid#" />
        </cfquery>
        <!--- Add any additional logic here if needed --->

</cffunction>
<cffunction output="false" name="DETtickets_24217" access="public" returntype="query">
    <cfargument name="ticketid" type="numeric" required="true">

<cfquery name="result" >
            SELECT 
                t.ticketid, 
                t.ticketID AS recID, 
                t.ticketName, 
                t.testingscript, 
                CONCAT(u.userfirstname, ' ', u.userlastname) AS username, 
                t.ticketCreatedDate AS createddate, 
                t.pgid, 
                t.userid, 
                t.ticketstatus, 
                t.tickettype, 
                t.environ, 
                t.ticketPriority, 
                p.pgname, 
                p.pgdir, 
                t.esthours, 
                t.ticketCompletedDate, 
                t.verid, 
                t.ticketdetails, 
                t.ticketResponse, 
                t.patchnote, 
                t.recordname, 
                v.major, 
                v.minor, 
                v.patch, 
                v.alphabeta, 
                v.version, 
                v.releasedate, 
                t.customtestpagename, 
                t.customtestpagelink
            FROM tickets t
            INNER JOIN taousers u ON u.userid = t.userid
            INNER JOIN pgpages p ON p.pgid = t.pgid
            LEFT JOIN taoversions v ON v.verid = t.verid
            WHERE t.ticketid = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.ticketid#" />
        </cfquery>

<cfreturn result>

</cffunction>
<cffunction output="false" name="UPDtickets_24332" access="public" returntype="void">
    <cfargument name="recid" type="numeric" required="true">

<cfquery result="result" >
            UPDATE tickets 
            SET ticketCompletedDate = <cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp" />, 
                complete_email = <cfqueryparam value="1" cfsqltype="cf_sql_bit" />
            WHERE ticketid = <cfqueryparam value="#arguments.recid#" cfsqltype="cf_sql_integer" />
        </cfquery>

</cffunction>
<cffunction output="false" name="REStickets" access="public" returntype="query">
    <cfargument name="recid" type="numeric" required="true">

<cfquery name="result" >
            SELECT 
                u.isbetatester, 
                p.pgid, 
                t.ticketID AS recID, 
                t.ticketID AS pk, 
                CONCAT(u.userfirstname, ' ', u.userlastname) AS col1, 
                'User' AS head1, 
                'Date' AS head2, 
                'Time' AS head3, 
                'Page' AS head4, 
                'Status' AS head5, 
                'Title' AS head6, 
                u.useremail, 
                u.userfirstname, 
                'Response' AS head7, 
                'Completed' AS head8, 
                t.ticketResponse AS col7, 
                t.ticketCompletedDate AS col8, 
                t.ticketdetails, 
                CONCAT(u.userfirstname, ' ', u.userlastname) AS col1, 
                t.ticketCreatedDate AS col2, 
                t.ticketCreatedDate AS col3, 
                p.pgname AS col4, 
                t.ticketStatus AS col5, 
                t.ticketName AS col6, 
                t.ticketResponse, 
                t.ticketCompletedDate, 
                p.pgname, 
                t.tickettype, 
                p.pgdir, 
                t.complete_email, 
                t.initial_email
            FROM tickets t
            INNER JOIN taousers u ON u.userid = t.userid
            INNER JOIN pgpages p ON p.pgid = t.pgid
            WHERE t.ticketid = <cfqueryparam value="#arguments.recid#" cfsqltype="CF_SQL_INTEGER">
        </cfquery>

<cfreturn result>

</cffunction>
<cffunction output="false" name="UPDtickets_24335" access="public" returntype="void">
    <cfargument name="ticketId" type="numeric" required="true">
    <cfargument name="userFirstName" type="string" required="true">
    <cfargument name="userLastName" type="string" required="true">

<cfquery result="result" name="updateTicket" >
            UPDATE tickets
            SET ticketstatus = <cfqueryparam value="Closed" cfsqltype="cf_sql_varchar">,
                ticketcompleteddate = CURDATE(),
                ticketresponse = <cfqueryparam value="Closed by #arguments.userFirstName# #arguments.userLastName#" cfsqltype="cf_sql_varchar">
            WHERE ticketid = <cfqueryparam value="#arguments.ticketId#" cfsqltype="cf_sql_integer">
        </cfquery>

</cffunction>
<cffunction output="false" name="UPDtickets_24337" access="public" returntype="void">
    <cfargument name="ticketresponse" type="string" required="true">
    <cfargument name="next_verid" type="numeric" required="true">
    <cfargument name="patchnote" type="string" required="true">
    <cfargument name="recid" type="numeric" required="true">

<cfquery result="result" >
            UPDATE tickets 
            SET ticketCompletedDate = <cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">,
                ticketstatus = <cfqueryparam value="Completed" cfsqltype="cf_sql_varchar">,
                ticketresponse = <cfqueryparam value="#arguments.ticketresponse#" cfsqltype="cf_sql_varchar">,
                verid = <cfqueryparam value="#arguments.next_verid#" cfsqltype="cf_sql_integer">,
                patchnote = <cfqueryparam value="#arguments.patchnote#" cfsqltype="cf_sql_varchar">,
                complete_email = 1
            WHERE ticketid = <cfqueryparam value="#arguments.recid#" cfsqltype="cf_sql_integer">
        </cfquery>

</cffunction>
<cffunction output="false" name="UPDtickets_24339" access="public" returntype="void">
    <cfargument name="ticketId" type="numeric" required="true">
    <cfargument name="status" type="string" required="true" default="Pass">

<cfquery result="result" >
            UPDATE tickets 
            SET ticketstatus = <cfqueryparam value="#arguments.status#" cfsqltype="cf_sql_varchar" />
            WHERE ticketid = <cfqueryparam value="#arguments.ticketId#" cfsqltype="cf_sql_integer" />
        </cfquery>

</cffunction>
<cffunction output="false" name="UPDtickets_24384" access="public" returntype="void">
    <cfargument name="ticketid" type="numeric" required="true">
    <cfargument name="new_verid" type="any" required="true">
    <cfargument name="new_ticketpriority" type="string" required="true">

<cfquery result="result" >
            UPDATE tickets
            <cfif arguments.new_verid is "NULL">
                SET verid = NULL, ticketstatus = 'Pending'
            <cfelse>
                SET verid = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.new_verid#" />
            </cfif>
            , ticketpriority = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.new_ticketpriority#" />
            WHERE ticketid = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.ticketid#" />
        </cfquery>

</cffunction>
<cffunction output="false" name="DETtickets_24385" access="public" returntype="query">
    <cfargument name="ticketid" type="numeric" required="true">

<cfquery name="result" >
            SELECT ticketstatus AS new_ticketstatus
            FROM tickets
            WHERE ticketid = <cfqueryparam value="#arguments.ticketid#" cfsqltype="CF_SQL_INTEGER">
        </cfquery>

<cfreturn result>
</cffunction>
<cffunction output="false" name="SELtickets_24472" access="public" returntype="query">
    <cfargument name="verid" type="numeric" required="false">

<cfquery name="result" >
            SELECT 
                v.versiontype, 
                v.versiontype, 
                v.major, 
                v.minor, 
                v.patch, 
                v.verid AS id, 
                v.alphabeta, 
                CONCAT(v.major, '.', v.minor, '.', v.patch, '.', v.version, '.', v.build, ' - ', v.versiontype) AS name, 
                ((v.hoursavail) - (SELECT SUM(esthours) FROM tickets t WHERE verid = v.verid)) AS hoursleft 
            FROM 
                taoversions v
            WHERE 
                1=1
            <cfif structKeyExists(arguments, "verid")>
                AND v.verid = <cfqueryparam value="#arguments.verid#" cfsqltype="CF_SQL_INTEGER">
            </cfif>
            ORDER BY 
                v.major, v.minor, v.patch, v.build
        </cfquery>

<cfreturn result>
</cffunction>
<cffunction output="false" name="SELtickets_24473" access="public" returntype="query">
    <cfargument name="verid" type="numeric" required="true">
    <cfargument name="col6" type="numeric" required="true">

<cfset var resultQuery = "">

<cfquery result="result" name="resultQuery" >
            SELECT 
                v.major, 
                v.minor, 
                v.patch, 
                v.verid AS id, 
                v.alphabeta, 
                CONCAT(v.major, '.', v.minor, '.', v.patch, '.', v.version, '.', v.build) AS name, 
                ((v.hoursavail) - IFNULL((SELECT SUM(esthours) FROM tickets t WHERE verid = v.verid), 0)) AS hoursleft 
            FROM 
                taoversions v 
            WHERE 
                v.verid <> <cfqueryparam value="#arguments.verid#" cfsqltype="CF_SQL_INTEGER"> 
                AND ((v.hoursavail) - IFNULL((SELECT SUM(esthours) FROM tickets t WHERE verid = v.verid), 0) - <cfqueryparam value="#arguments.col6#" cfsqltype="CF_SQL_DECIMAL"> >= 0) 
                AND v.versionstatus = 'Pending'
            UNION
            SELECT 
                v.major, 
                v.minor, 
                v.patch, 
                v.verid AS id, 
                v.alphabeta, 
                CONCAT(v.major, '.', v.minor, '.', v.patch, '.', v.version, '.', v.build) AS name, 
                ((v.hoursavail) - (SELECT SUM(esthours) FROM tickets t WHERE verid = v.verid)) AS hoursleft 
            FROM 
                taoversions v 
            WHERE 
                v.verid = <cfqueryparam value="#arguments.verid#" cfsqltype="CF_SQL_INTEGER">
            ORDER BY major, minor, patch
        </cfquery>

<cfreturn resultQuery>

</cffunction>

<cffunction output="false" name="SELtickets_24480" access="public" returntype="query">
    <cfargument name="verid" type="numeric" required="false">

<cfquery name="result" >
            SELECT 
                v.versiontype, 
                v.major, 
                v.minor, 
                v.patch, 
                v.verid AS id, 
                v.alphabeta, 
                CONCAT(v.major, '.', v.minor, '.', v.patch, '.', v.version, '.', v.build, ' - ', v.versiontype) AS name,
                (v.hoursavail - (SELECT SUM(esthours) FROM tickets t WHERE verid = v.verid)) AS hoursleft
            FROM 
                taoversions v
            WHERE 
                1=1
            <cfif structKeyExists(arguments, "verid")>
                AND v.verid = <cfqueryparam value="#arguments.verid#" cfsqltype="CF_SQL_INTEGER">
            </cfif>
            ORDER BY 
                v.major, v.minor, v.patch, v.build
        </cfquery>

<cfreturn result>
</cffunction>

<cffunction output="false" name="DETtickets_24767" access="public" returntype="query">
    <cfargument name="recID" type="numeric" required="true">

<cfquery name="result" >
            SELECT 
                t.ticketID AS recID, 
                t.ticketName, 
                CONCAT(u.userfirstname, ' ', u.userlastname) AS username, 
                t.ticketCreatedDate AS createddate, 
                t.ticketstatus, 
                t.tickettype, 
                t.environ, 
                t.ticketPriority, 
                p.pgdir, 
                p.pgname, 
                t.esthours, 
                t.ticketCompletedDate, 
                t.verid, 
                t.ticketdetails, 
                t.ticketResponse, 
                t.patchnote, 
                t.recordname, 
                t.testingscript, 
                v.major, 
                v.minor, 
                v.patch, 
                v.alphabeta, 
                v.version, 
                v.releasedate, 
                t.customtestpagelink, 
                t.customtestpagename
            FROM tickets t
            INNER JOIN taousers_tbl u ON u.userid = t.userid
            INNER JOIN pgpages p ON p.pgid = t.pgid
            LEFT JOIN taoversions v ON v.verid = t.verid
            WHERE t.ticketid = <cfqueryparam value="#arguments.recID#" cfsqltype="CF_SQL_INTEGER">
        </cfquery>

<cfreturn result>

</cffunction>

<cffunction output="false" name="REStickets_24768" access="public" returntype="query">
    <cfargument name="statusList" type="array" required="true">

<cfquery name="result" >
            SELECT 
                'ID' AS head1, 
                'Details' AS head2, 
                'Page' AS head3, 
                'Type' AS head4, 
                'Status' AS head45, 
                'Priority' AS head5, 
                'Hours' AS head6, 
                'Release' AS head7, 
                t.ticketID AS col1, 
                t.ticketID AS recid, 
                t.ticketName AS col2, 
                p.pgname AS col3, 
                t.tickettype AS col4, 
                t.ticketstatus AS col45, 
                t.ticketpriority AS col5, 
                t.esthours AS col6, 
                CONCAT(v.major, '.', v.minor, '.', v.patch, '.', v.version, '.', v.build) AS col7,
                p.pgname,
                p.pgdir
            FROM tickets t
            INNER JOIN taousers_tbl u ON u.userid = t.userid
            INNER JOIN pgpages p ON p.pgid = t.pgid
            INNER JOIN taoversions v ON v.verid = t.verid
            WHERE t.ticketstatus IN (
                <cfloop array="#arguments.statusList#" index="status">
                    <cfqueryparam value="#status#" cfsqltype="CF_SQL_VARCHAR" list="true">
                    <cfif NOT isLastArrayElement()>,</cfif>
                </cfloop>
            )
        </cfquery>

<cfreturn result>
</cffunction>

<cffunction output="false" name="DETtickets_24782" access="public" returntype="query">
    <cfargument name="recid" type="numeric" required="true">

<cfquery name="result" >
            SELECT 
                v.verid, 
                v.major, 
                v.minor, 
                v.patch, 
                v.alphabeta, 
                v.version, 
                v.releasedate, 
                v.releaseTime, 
                v.reviewDate, 
                v.hoursavail, 
                v.build, 
                v.reviewtime, 
                v.versionstatus, 
                v.isActive, 
                v.versiontype,
                CONCAT(v.major, '.', v.minor, '.', v.patch, '.', v.version, '.', v.build, ' -', v.versiontype) AS vername,
                (SELECT COUNT(*) FROM tickets WHERE verid = v.verid) AS total_tickets,
                (SELECT SUM(esthours) FROM tickets WHERE verid = v.verid) AS total_hours
            FROM taoversions v
            WHERE v.verid = <cfqueryparam value="#arguments.recid#" cfsqltype="CF_SQL_INTEGER">
        </cfquery>

<cfreturn result>
</cffunction>

<cffunction output="false" name="DETtickets_24784" access="public" returntype="query">
    <cfargument name="recid" type="numeric" required="true">

<cfquery name="result" >
            SELECT 
                v.verid, 
                v.major, 
                v.minor, 
                v.patch, 
                v.alphabeta, 
                v.version, 
                v.releasedate, 
                v.releaseTime, 
                v.reviewDate, 
                v.reviewtime, 
                v.versionstatus, 
                v.isActive, 
                v.versiontype,
                ((v.hoursavail) - (SELECT SUM(esthours) FROM tickets t WHERE verid = v.verid)) AS hoursleft,
                CONCAT(v.major,'.',v.minor,'.',v.patch,'.',v.version,'.',v.build) AS vername,
                (SELECT COUNT(*) FROM tickets WHERE verid = v.verid) AS total_tickets,
                (SELECT SUM(esthours) FROM tickets WHERE verid = v.verid) AS total_hours
            FROM taoversions v
            WHERE v.verid = <cfqueryparam value="#arguments.recid#" cfsqltype="CF_SQL_INTEGER">
        </cfquery>

<cfreturn result>
</cffunction>

<cffunction output="false" name="REStickets_24785" access="public" returntype="query">
    <cfargument name="recid" type="numeric" required="true">

<cfquery name="result" >
            SELECT 
                'ID' AS head1,
                'Details' AS head2,
                'Page' AS head3,
                'Type' AS head4,
                'Status' AS head45,
                'Priority' AS head5,
                'Hours' AS head6,
                'Release' AS head7,
                t.ticketID AS col1,
                t.ticketID AS recid,
                t.ticketName AS col2,
                p.pgname AS col3,
                t.tickettype AS col4,
                t.ticketstatus AS col45,
                t.ticketpriority AS col5,
                t.esthours AS col6,
                CONCAT(v.major,'.',v.minor,'.',v.patch,'.',v.version,'.',v.build) AS col7,
                p.pgname, 
                p.pgdir, 
                v.verid
            FROM 
                tickets t
            INNER JOIN 
                taousers u ON u.userid = t.userid
            INNER JOIN 
                pgpages p ON p.pgid = t.pgid
            INNER JOIN 
                taoversions v ON v.verid = t.verid
            WHERE 
                t.verid = <cfqueryparam value="#arguments.recid#" cfsqltype="CF_SQL_INTEGER">
            ORDER BY 
                t.ticketid DESC
        </cfquery>

<cfreturn result>
</cffunction>

<cffunction name="REStickets_24787" access="public" returntype="query" output="false" hint="Fetches version and ticket data.">

<!--- Execute the query --->
    <cfquery name="results">
        SELECT 
            v.verid,
            'Release' AS head1,
            'Review Date' AS head2,
            'Release Date' AS head3,
            'Status' AS head4,
            'Type' AS head4b,
            'Total Tickets' AS head5,
            'Hours Left' AS head6,
            CONCAT(v.major, '.', v.minor, '.', v.patch, '.', v.version, '.', v.build, ' - ', v.versiontype) AS col1,
            v.reviewDate AS col2,
            v.reviewtime,
            v.releasedate AS col3,
            v.releaseTime,
            v.versionstatus AS col4,
            v.versiontype AS col4b,
            (SELECT COUNT(*) FROM tickets WHERE verid = v.verid) AS col5,
            (SELECT SUM(esthours) FROM tickets WHERE verid = v.verid) AS col6b,
            v.major,
            v.minor,
            v.patch,
            v.alphabeta,
            v.version,
            ((v.hoursavail) - (SELECT SUM(esthours) FROM tickets t WHERE verid = v.verid)) AS col6,
            v.isActive
        FROM taoversions v
        ORDER BY v.major, v.minor, v.patch, v.version, v.build
    </cfquery>

<cfreturn results>
</cffunction>

</cfcomponent>