<cfcomponent displayname="UserService" hint="Handles operations for User table" >

<cffunction name="dateformatpref" access="public" returntype="void" output="false" hint="Updates the date format preference for a user and refreshes the session.">
    <cfargument name="userid" type="numeric" required="true" hint="The user ID whose preferences are being updated.">
    <cfargument name="dateformatid" type="numeric" required="true" hint="The new date format ID.">

    <!--- Update the date format in the database --->
    <cfquery name="updateDateFormat">
        UPDATE taousers
        SET dateformatid = <cfqueryparam value="#arguments.dateformatid#" cfsqltype="CF_SQL_INTEGER">
        WHERE userid = <cfqueryparam value="#arguments.userid#" cfsqltype="CF_SQL_INTEGER">
    </cfquery>

    <!--- Fetch the updated date format preference --->
    <cfquery name="getUpdatedPreferences">
        SELECT 
            u.dateformatid, 
            d.formatExample
        FROM 
            taousers u
        LEFT JOIN 
            dateformats d ON u.dateformatid = d.id
        WHERE 
            u.userid = <cfqueryparam value="#arguments.userid#" cfsqltype="CF_SQL_INTEGER">
    </cfquery>

    <!--- Refresh session.user with updated preferences --->
    <cfif getUpdatedPreferences.recordcount>
        <cfset session.user.dateformatid = getUpdatedPreferences.dateformatid>
        <cfset session.user.dateformatExample = getUpdatedPreferences.formatExample>
    </cfif>
</cffunction>

<cffunction output="false" name="getUserById" access="public" returntype="struct">
    <cfargument name="userId" type="numeric" required="true">
    
    <cfset var user = {}>

    <cfquery name="qUserDetails">
        SELECT
            u.*,  
            t.tzname, 
            t.tzgeneral,
            tc.*, 
            df.formatexample AS dateformatExample,
            df.id AS dateformatID,
            pp.planName,
            pr.BaseProductLabel,
            r.regionname AS regionName,
            c.countryname AS countryName
        FROM taousers u
        LEFT JOIN dateformats df ON u.dateformatid = df.id
        LEFT JOIN timezones t ON u.tzid = t.tzid
        LEFT JOIN thrivecart tc ON u.customerid = tc.id  
        LEFT JOIN paymentplans pp ON pp.BasePaymentPlanId = tc.BasePaymentPlanId
        LEFT JOIN products pr ON pr.BaseProductId = tc.BaseProductId
        LEFT JOIN regions r ON u.region_id = r.region_id
        LEFT JOIN countries c ON u.countryid = c.countryid
        WHERE u.userid = <cfqueryparam value="#arguments.userId#" cfsqltype="cf_sql_integer">
    </cfquery>

    <cfif qUserDetails.recordCount>
        <cfloop array="#qUserDetails.getRow(1)#" index="col">
            <cfset user[col] = iif(isNull(qUserDetails[col]), "", qUserDetails[col])>
        </cfloop>
        <cfset user.calendarName = REReplace(user.recordName, "[\s\-]", "", "all")>
    </cfif>

    <cfreturn user>
</cffunction>




<cffunction name="getUserByHash" access="public" returntype="query" output="false">
        <!--- Arguments --->
        <cfargument name="uid" type="string" required="true">

        <!--- Query --->
        <cfquery name="result" >
            SELECT
                u.userid,
                u.recordname,
                u.userFirstName,
                u.userLastName,
                u.userEmail,
                u.contactid,
                u.userRole,
                u.IsBetaTester,
                u.defRows,
                u.defCountry,
                u.defState,
                u.calstarttime,
                u.calendtime,
                u.avatarname,
                u.contactid AS userContactID,
                u.tzid,
                t.tzname,
                u.customerid
            FROM taousers u
            LEFT JOIN timezones t ON t.tzid = u.tzid
            WHERE LEFT(u.passwordhash, 10) = <cfqueryparam value="#arguments.uid#" cfsqltype="CF_SQL_CHAR">
        </cfquery>

        <!--- Return Query Result --->
        <cfreturn result>
    </cffunction>

<cffunction name="update_cal" access="public" returntype="numeric" output="false">
    <cfargument name="userid" type="numeric" required="true">
    <cfargument name="calstarttime" type="string" required="true">
    <cfargument name="calendtime" type="string" required="true">
    <cfargument name="defRows" type="numeric" required="true">
    <cfargument name="viewtypeid" type="numeric" required="true">
    <cfargument name="dateformatid" type="numeric" required="true">
    <cfargument name="tzid" type="string" required="true">

    <!--- Execute the update query --->
    <cfquery name="update" result="updateResult">
        UPDATE taousers
        SET 
            calstarttime = <cfqueryparam cfsqltype="cf_sql_time" value="#arguments.calstarttime#">,
            calendtime = <cfqueryparam cfsqltype="cf_sql_time" value="#arguments.calendtime#">,
            defRows = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.defRows#">,
            viewtypeid = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.viewtypeid#">,
            dateformatid = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.dateformatid#">,
            tzid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.tzid#">
        WHERE 
            userid = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.userid#">
    </cfquery>

    <!--- Return the number of rows affected --->
    <cfreturn updateResult.recordcount>
</cffunction>






<cffunction name="users_sel" access="public" returntype="query" output="false" hint="Fetches a list of users with the minimum user ID for each record name.">
    <!--- Fetches a list of users with the minimum user ID for each record name. --->
    <cfquery name="users">
        SELECT 
            MIN(u.userid) AS id,
            u.recordname AS name
        FROM 
            taousers u
        GROUP BY 
            u.recordname
        ORDER BY 
            u.recordname
    </cfquery>

<!--- Return the query result --->
    <cfreturn users>
</cffunction>

<!--- Function to retrieve user details by user ID --->
    <cffunction output="false" name="GetUserDetails" access="public" returntype="query" >
        <cfargument name="userid" type="numeric" required="yes">

<cfquery result="result" name="details">
            SELECT 
                u.viewtypeid, 
                tz.tzgeneral,
                u.add1, 
                u.add2, 
                u.city, 
                u.region_id AS new_region_id, 
                u.region_id,
                u.zip, 
                u.tzid, 
                u.defRows,
                u.calstarttime, 
                u.calendtime, 
                u.avatarname, 
                u.userfirstname, 
                u.userlastname, 
                u.useremail, 
                u.nletter_yn,
                u.nletter_link, 
                v.viewtype,
                u.defcountry,
                u.defstate,
                c.countryid,
                c.countryid AS new_countryid,
                u.add1,
                u.add2,
                u.city,
                u.zip,
                u.dateformatid,
                df.*
            FROM 
                taousers u 
                LEFT JOIN dateformats df ON df.id = u.dateFormatid
                LEFT OUTER JOIN viewtypes v ON v.viewtypeid = u.viewtypeid
                LEFT JOIN regions r ON r.region_id = u.region_id
                LEFT JOIN countries c ON c.countryid = r.countryid
                LEFT JOIN timezones tz ON tz.tzid = u.tzid
            WHERE 
                u.userid = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#arguments.userid#">
        </cfquery>

<cfreturn details>
    </cffunction>

<cffunction output="false" name="SELtaousers" access="public" returntype="query">
    <cfargument name="ticketActive" type="string" required="true">

<cfquery result="result" name="qResult" >
            SELECT DISTINCT 
                u.recordname, 
                u.userrole, 
                u.userid 
            FROM 
                taousers u 
            INNER JOIN 
                tickets t ON u.userID = t.userid 
            WHERE 
                t.ticketactive = <cfqueryparam value="#arguments.ticketActive#" cfsqltype="CF_SQL_CHAR">
            ORDER BY 
                u.userlastname, 
                u.userfirstname
        </cfquery>

<cfreturn qResult>
</cffunction>
<cffunction output="false" name="SELtaousers_23718" access="public" returntype="query">
    <cfargument name="ticketActive" type="string" required="true">

<cfquery name="result" >
            SELECT DISTINCT t.tickettype
            FROM taousers u
            INNER JOIN tickets t ON u.userID = t.userid
            WHERE t.ticketactive = <cfqueryparam value="#arguments.ticketActive#" cfsqltype="CF_SQL_CHAR">
            ORDER BY t.tickettype
        </cfquery>

<cfreturn result>
</cffunction>

<cffunction output="false" name="SELtaousers_23721" access="public" returntype="query">
    <cfargument name="ticketId" type="numeric" required="true">

<cfquery name="result" >
            SELECT 
                tu.id, 
                tu.ticketid, 
                tu.userid, 
                u.recordname, 
                tu.teststatus, 
                tu.rejectnotes
            FROM 
                tickettestusers tu
            INNER JOIN 
                taousers u ON u.userid = tu.userid
            WHERE 
                tu.ticketid = <cfqueryparam value="#arguments.ticketId#" cfsqltype="CF_SQL_INTEGER">
        </cfquery>

<cfreturn result>
</cffunction>
<cffunction output="false" name="UPDtaousers" access="public" returntype="void">
    <cfargument name="view" type="string" required="true">
    <cfargument name="userid" type="numeric" required="true">

<cfset var viewTypeId = 0>

<!--- Determine viewTypeId based on view argument --->
    <cfif arguments.view eq "tbl">
        <cfset viewTypeId = 1>
    <cfelse>
        <cfset viewTypeId = 2>
    </cfif>

<!--- Execute the parameterized query --->
        <cfquery result="result" >
            UPDATE taousers 
            SET viewtypeid = <cfqueryparam value="#viewTypeId#" cfsqltype="CF_SQL_INTEGER"> 
            WHERE userid = <cfqueryparam value="#arguments.userid#" cfsqltype="CF_SQL_INTEGER">
        </cfquery>

</cffunction>
<cffunction output="false" name="SELtaousers_23842" access="public" returntype="query" >
    <cfargument name="select_userid" type="numeric" required="true">

<cfquery name="result" >
            SELECT 
                u.userid, 
                u.recordname, 
                u.userFirstName, 
                u.userLastName, 
                u.userEmail, 
                u.contactid, 
                u.userRole 
            FROM 
                taousers u
            <cfif arguments.select_userid neq 0>
                WHERE u.userid = <cfqueryparam value="#arguments.select_userid#" cfsqltype="CF_SQL_INTEGER">
            </cfif>
        </cfquery>

<cfreturn result>
</cffunction>
<cffunction output="false" name="UPDtaousers_23911" access="public" returntype="void">
    <cfargument name="accessToken" type="string" required="false">
    <cfargument name="userId" type="numeric" required="true">

<cfquery result="result" >
            UPDATE taousers 
            SET access_token = <cfqueryparam value="#arguments.accessToken#" cfsqltype="CF_SQL_VARCHAR"> 
            WHERE userid = <cfqueryparam value="#arguments.userId#" cfsqltype="CF_SQL_INTEGER">
        </cfquery>

</cffunction>

<cffunction output="false" name="UPDtaousers_23945" access="public" returntype="void">

    <cfargument name="new_userfirstname" type="string" required="false">
    <cfargument name="new_userlastname" type="string" required="false">
    <cfargument name="new_avatarname" type="string" required="false">
    <cfargument name="new_useremail" type="string" required="false">
    <cfargument name="add1" type="string" required="false">
    <cfargument name="add2" type="string" required="false">
    <cfargument name="city" type="string" required="false">
    <cfargument name="zip" type="string" required="false">
    <cfargument name="region_id" type="numeric" required="false">
    <cfargument name="countryid" type="string" required="false">
    <cfargument name="userid" type="numeric" required="true">

  


<cfquery result="result" >
        UPDATE taousers 
        SET userfirstname = <cfqueryparam value="#arguments.new_userfirstname#" cfsqltype="CF_SQL_VARCHAR">,
            userlastname = <cfqueryparam value="#arguments.new_userlastname#" cfsqltype="CF_SQL_VARCHAR">,
            avatarname = <cfqueryparam value="#arguments.new_avatarname#" cfsqltype="CF_SQL_VARCHAR">,
            useremail = <cfqueryparam value="#arguments.new_useremail#" cfsqltype="CF_SQL_VARCHAR">,
            add1 = <cfqueryparam value="#arguments.add1#" cfsqltype="CF_SQL_VARCHAR">,
            add2 = <cfqueryparam value="#arguments.add2#" cfsqltype="CF_SQL_VARCHAR">,
            city = <cfqueryparam value="#arguments.city#" cfsqltype="CF_SQL_VARCHAR">,
            zip = <cfqueryparam value="#arguments.zip#" cfsqltype="CF_SQL_VARCHAR">,
            region_id = <cfqueryparam value="#arguments.region_id#" cfsqltype="CF_SQL_INTEGER">,
            countryid = <cfqueryparam value="#arguments.countryid#" cfsqltype="CF_SQL_VARCHAR">
        WHERE userid = <cfqueryparam value="#arguments.userid#" cfsqltype="CF_SQL_INTEGER">
    </cfquery>

</cffunction>
<cffunction output="false" name="UPDtaousers_23950" access="public" returntype="void">
    <cfargument name="new_nletter_link" type="string" required="true">
    <cfargument name="new_nletter_yn" type="string" required="true">
    <cfargument name="userid" type="numeric" required="true">

<cfquery result="result" >
            UPDATE taousers 
            SET nletter_link = <cfqueryparam value="#arguments.new_nletter_link#" cfsqltype="CF_SQL_VARCHAR">, 
                nletter_yn = <cfqueryparam value="#arguments.new_nletter_yn#" cfsqltype="CF_SQL_VARCHAR">
            WHERE userid = <cfqueryparam value="#arguments.userid#" cfsqltype="CF_SQL_INTEGER">
        </cfquery>

</cffunction>

<cffunction output="false" name="UPDtaousers_23951" access="public" returntype="void">
    <cfargument name="calstarttime" type="date" required="false">
    <cfargument name="calendtime" type="date" required="false">
    <cfargument name="defRows" type="numeric" required="false">
    <cfargument name="defCountry" type="string" required="false">
    <cfargument name="defState" type="string" required="false">
    <cfargument name="userid" type="numeric" required="true">

<cfquery result="result" >
            UPDATE taousers 
            SET 
                calstarttime = <cfqueryparam cfsqltype="cf_sql_time" value="#arguments.calstarttime#" />,
                calendtime = <cfqueryparam cfsqltype="cf_sql_time" value="#arguments.calendtime#" />,
                defRows = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.defRows#" />,
                defCountry = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.defCountry#" />,
                defState = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.defState#" />
            WHERE 
                userid = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.userid#" />
        </cfquery>

</cffunction>

<cffunction output="false" name="SELtaousers_23956" access="public" returntype="query">
    <cfargument name="userid" type="numeric" required="true">

<cfquery name="result" >
            SELECT contactid 
            FROM taousers 
            WHERE userid = <cfqueryparam value="#arguments.userid#" cfsqltype="CF_SQL_INTEGER">
        </cfquery>

<cfreturn result>
</cffunction>

<cffunction output="false" name="UPDtaousers_23989" access="public" returntype="void">
    <cfargument name="accesstoken" type="string" required="true">
    <cfargument name="refreshToken" type="string" required="true">
    <cfargument name="userid" type="numeric" required="true">

<cfquery result="result" >
            UPDATE taousers 
            SET access_token = <cfqueryparam value="#arguments.accesstoken#" cfsqltype="CF_SQL_VARCHAR">, 
                refresh_token = <cfqueryparam value="#arguments.refreshToken#" cfsqltype="CF_SQL_VARCHAR"> 
            WHERE userid = <cfqueryparam value="#arguments.userid#" cfsqltype="CF_SQL_INTEGER">
        </cfquery>

</cffunction>

<cffunction output="false" name="UPDtaousers_23990" access="public" returntype="void" hint="Updates the access token for a user based on their userid.">
    <cfargument name="accessToken" type="string" required="true" hint="The new access token to be set.">
    <cfargument name="userid" type="numeric" required="true" hint="The ID of the user whose access token is to be updated.">

<cfquery result="result" >
            UPDATE taousers 
            SET access_token = <cfqueryparam value="#arguments.accessToken#" cfsqltype="CF_SQL_VARCHAR"> 
            WHERE userid = <cfqueryparam value="#arguments.userid#" cfsqltype="CF_SQL_INTEGER">
        </cfquery>

</cffunction>

<cffunction output="false" name="SELtaousers_23998" access="public" returntype="query">
    <cfargument name="userID" type="numeric" required="true">

<cfquery name="result" >
            SELECT 
                u.userid, 
                u.recordname, 
                u.userFirstName, 
                u.userLastName, 
                u.userEmail, 
                u.contactid, 
                u.userRole, 
                u.IsBetaTester, 
                u.defRows, 
                u.defCountry, 
                u.defState, 
                u.calstarttime, 
                u.calendtime, 
                u.avatarname, 
                u.contactid AS userContactID, 
                u.tzid, 
                t.tzname, 
                u.customerid
            FROM taousers u
            LEFT JOIN timezones t ON t.tzid = u.tzid
            WHERE u.userid = <cfqueryparam value="#arguments.userID#" cfsqltype="CF_SQL_INTEGER">
        </cfquery>

<cfreturn result>
</cffunction>
<cffunction output="false" name="UPDtaousers_23999" access="public" returntype="void">
    <cfargument name="userFirstName" type="string" required="false">
    <cfargument name="userId" type="numeric" required="true">

<cfquery result="result" name="updateAvatar" >
            UPDATE taousers 
            SET avatarname = <cfqueryparam value="#arguments.userFirstName#" cfsqltype="CF_SQL_VARCHAR">
            WHERE userid = <cfqueryparam value="#arguments.userId#" cfsqltype="CF_SQL_INTEGER">
        </cfquery>

</cffunction>

<cffunction output="false" name="UPDtaousers_24001" access="public" returntype="void">
    <cfargument name="new_contactid" type="numeric" required="true">
    <cfargument name="userid" type="numeric" required="true">

<cfquery result="result" >
            UPDATE taousers 
            SET contactid = <cfqueryparam value="#arguments.new_contactid#" cfsqltype="CF_SQL_INTEGER">
            WHERE userid = <cfqueryparam value="#arguments.userid#" cfsqltype="CF_SQL_INTEGER">
        </cfquery>

</cffunction>

<cffunction output="false" name="SELtaousers_24002" access="public" returntype="query">
    <cfargument name="userID" type="numeric" required="true">

<cfquery name="result" >
            SELECT 
                u.userid, 
                u.recordname, 
                u.userFirstName, 
                u.userLastName, 
                u.userEmail, 
                u.contactid, 
                u.userRole, 
                u.calstarttime, 
                u.calendtime, 
                u.avatarname, 
                u.IsBetaTester, 
                u.defRows, 
                u.defCountry, 
                u.defState, 
                u.contactid AS userContactID, 
                u.tzid, 
                t.tzname, 
                u.customerid
            FROM taousers u
            LEFT JOIN timezones t ON t.tzid = u.tzid
            WHERE u.userid = <cfqueryparam value="#arguments.userID#" cfsqltype="CF_SQL_INTEGER">
        </cfquery>

<cfreturn result>
</cffunction>
<cffunction output="false" name="SELtaousers_24072" access="public" returntype="query">
    <cfargument name="userid" type="numeric" required="true">

<cfquery name="result" >
            SELECT 
                u.userid AS new_userid, 
                u.recordname AS username 
            FROM 
                taousers u 
            WHERE 
                u.userid = <cfqueryparam value="#arguments.userid#" cfsqltype="CF_SQL_INTEGER">
        </cfquery>

<cfreturn result>
</cffunction>
<cffunction output="false" name="DETtaousers" access="public" returntype="query">
    <cfargument name="userid" type="numeric" required="true">

<cfquery name="result" >
            SELECT * 
            FROM taousers 
            WHERE userid = <cfqueryparam value="#arguments.userid#" cfsqltype="CF_SQL_INTEGER">
        </cfquery>

<cfreturn result>
</cffunction>
<cffunction output="false" name="SELtaousers_24142" access="public" returntype="query">
    <cfargument name="conditions" type="struct" required="false" default="#structNew()#">

<cfset var queryResult = "">
    <cfset var sql = "SELECT userid FROM taousers">
    <cfset var whereClauses = []>
    <cfset var paramValues = []>

<!--- Build WHERE clause dynamically based on conditions argument --->
    <cfloop collection="#arguments.conditions#" item="key">
        <cfset arrayAppend(whereClauses, "#key# = ?")>
        <cfset arrayAppend(paramValues, {value=arguments.conditions[key], cfsqltype=determineSQLType(key)})>
    </cfloop>

<!--- Add WHERE clause if there are conditions --->
    <cfif arrayLen(whereClauses) gt 0>
        <cfset sql &= " WHERE " & arrayToList(whereClauses, " AND ")>
    </cfif>

<!--- Add ORDER BY clause --->
    <cfset sql &= " ORDER BY userid DESC LIMIT 1">

<!--- Execute the query with error handling --->

<cfquery result="result" name="queryResult" >
            #sql#
            <cfloop array="#paramValues#" index="param">
                <cfqueryparam value="#param.value#" cfsqltype="#param.cfsqltype#">
            </cfloop>
        </cfquery>

<!--- Return an empty query set --->

<cfreturn queryResult>
</cffunction>
<cffunction output="false" name="SELtaousers_24158" access="public" returntype="query">
    <cfargument name="recordName" type="string" required="false">

<cfset var sql = "SELECT MIN(u.userid) AS id, u.recordname AS name FROM taousers u">
    <cfset var whereClause = "">
    <cfset var orderByClause = " 
    ORDER BY u.recordname">

<!--- Build WHERE clause dynamically --->
    <cfif structKeyExists(arguments, "recordName") AND len(arguments.recordName)>
        <cfset whereClause = " WHERE u.recordname = ?">
    </cfif>

<!--- Construct final SQL query --->
    <cfset sql = sql & whereClause & " GROUP BY u.recordname" & orderByClause>

<!--- Execute the query with error handling --->

<cfquery name="result" >
            #sql#
            <cfif len(whereClause)>
                <cfqueryparam value="#arguments.recordName#" cfsqltype="CF_SQL_VARCHAR">
            </cfif>
        </cfquery>

<cfreturn result>
</cffunction>
<cffunction output="false" name="SELtaousers_24306" access="public" returntype="query">
    <cfargument name="userIds" type="array" required="true">

<cfset var sql = "">
    <cfset var paramList = "">

<cfif arrayLen(arguments.userIds) eq 0>
            <!--- Return an empty query if no user IDs are provided --->
            <cfquery name="result" >
                select userID,userFirstName,userLastName,userEmail,userRole,recordname,contactid,IsDeleted,nletter_yn,nletter_link,calStartTime,calEndTime,calSlotDuration,avatarName,IsBetaTester,defRows,defCountry,defState,tzid,customerid,userstatus,recover,passwordHash,passwordSalt,userPassword,isAudition,viewtypeid,add1,add2,city,regionid,zip,isAuditionModule,imdbid,isSetup,countryid,def_regionid,access_token,refresh_token,dateFormatID,datePrefID,region_id from taousers WHERE 1=0
            </cfquery>
        <cfelse>
            <!--- Construct the SQL query with parameterized inputs --->
            <cfset sql = "select userID,userFirstName,userLastName,userEmail,userRole,recordname,contactid,IsDeleted,nletter_yn,nletter_link,calStartTime,calEndTime,calSlotDuration,avatarName,IsBetaTester,defRows,defCountry,defState,tzid,customerid,userstatus,recover,passwordHash,passwordSalt,userPassword,isAudition,viewtypeid,add1,add2,city,regionid,zip,isAuditionModule,imdbid,isSetup,countryid,def_regionid,access_token,refresh_token,dateFormatID,datePrefID,region_id from taousers WHERE userid IN (">

<!--- Loop through userIds to create parameter placeholders --->
            <cfloop index="i" from="1" to="#arrayLen(arguments.userIds)#">
                <cfset sql &= "?">
                <cfif i lt arrayLen(arguments.userIds)>
                    <cfset sql &= ", ">
                </cfif>
                <!--- Append cfqueryparam for each userId --->
                <cfset paramList &= "<cfqueryparam value='#arguments.userIds[i]#' cfsqltype='CF_SQL_INTEGER'>,">
            </cfloop>

<!--- Close the IN clause --->
            <cfset sql &= ")">

<!--- Execute the query --->
            <cfquery name="result" >
                #sql#
                <!--- Dynamically insert cfqueryparam tags --->
                #paramList#
            </cfquery>
        </cfif>

<!--- Return the result query --->
        <cfreturn result>

<!--- Log the error details --->

<!--- Return an empty query on error --->
        <cfquery name="result" >
            select userID,userFirstName,userLastName,userEmail,userRole,recordname,contactid,IsDeleted,nletter_yn,nletter_link,calStartTime,calEndTime,calSlotDuration,avatarName,IsBetaTester,defRows,defCountry,defState,tzid,customerid,userstatus,recover,passwordHash,passwordSalt,userPassword,isAudition,viewtypeid,add1,add2,city,regionid,zip,isAuditionModule,imdbid,isSetup,countryid,def_regionid,access_token,refresh_token,dateFormatID,datePrefID,region_id from taousers WHERE 1=0
        </cfquery>
        <cfreturn result>

</cffunction>
<cffunction output="false" name="SELtaousers_24432" access="public" returntype="query">
    <cfargument name="select_userid" type="numeric" required="true">

<cfquery name="result" >
            SELECT 
                users.userid, 
                users.recordname, 
                users.userFirstName, 
                users.userLastName, 
                users.userEmail, 
                users.contactid, 
                users.userRole 
            FROM 
                taousers users
            <cfif arguments.select_userid neq 0>
                WHERE users.userid = <cfqueryparam value="#arguments.select_userid#" cfsqltype="CF_SQL_INTEGER">
            </cfif>
        </cfquery>

<cfreturn result>
</cffunction>
<cffunction output="false" name="SELtaousers_24461" access="public" returntype="query">
    <cfargument name="userid" type="numeric" required="true">

<cfquery name="result" >
            SELECT * 
            FROM taousers 
            WHERE userid = <cfqueryparam value="#arguments.userid#" cfsqltype="CF_SQL_INTEGER">
        </cfquery>

<cfreturn result>
</cffunction>
<cffunction output="false" name="SELtaousers_24759" access="public" returntype="query">
    <cfargument name="userEmail" type="string" required="true">

<cfquery name="result" >
            SELECT 
                u.userid, 
                u.userFirstName, 
                u.userLastName, 
                u.userEmail, 
                u.userRole
            FROM 
                taousers u
            WHERE 
                u.userEmail = <cfqueryparam value="#arguments.userEmail#" cfsqltype="CF_SQL_VARCHAR">
        </cfquery>

<cfreturn result>
</cffunction>
<cffunction output="false" name="SELtaousers_24760" access="public" returntype="query">
    <cfargument name="userEmail" type="string" required="true">

<cfquery name="result" >
            SELECT 
                u.userid, 
                u.userFirstName, 
                u.userLastName, 
                u.userEmail, 
                u.userRole 
            FROM 
                taousers u 
            WHERE 
                u.userEmail = <cfqueryparam value="#arguments.userEmail#" cfsqltype="CF_SQL_VARCHAR">
        </cfquery>

<cfreturn result>
</cffunction>

   <cffunction name="getUsers" access="public" returntype="query" output="false" hint="Fetches users grouped by record name">
        <!--- Local variables scope --->
        <cfset var users = "">

        <!--- Query to fetch users --->
        <cfquery name="users" >
            SELECT 
                MIN(u.userid) AS id,
                u.recordname AS name
            FROM taousers u
            GROUP BY u.recordname
            ORDER BY u.recordname
        </cfquery>

        <!--- Return the query result --->
        <cfreturn users />
    </cffunction>


<!--- Function to get user details by ID, including related tables --->
<cffunction output="false" name="getUserById" access="public" returntype="struct">
    <cfargument name="userId" type="numeric" required="true">
    
    <!--- Initialize a struct to hold user data --->
    <cfset var user = {}>

    <cfquery name="qUserDetails">
        SELECT
            u.*,  
            t.tzname, 
            t.tzgeneral,
            tc.*, 
            df.formatexample AS dateformatExample,
            df.id AS dateformatID,
            pp.planName,
            pr.BaseProductLabel,
            r.regionname AS regionName,
            c.countryname AS countryName
        FROM
            taousers u
        LEFT JOIN dateformats df ON u.dateformatid = df.id
        LEFT JOIN timezones t ON u.tzid = t.tzid
        LEFT JOIN thrivecart tc ON u.customerid = tc.id  
        LEFT JOIN paymentplans pp ON pp.BasePaymentPlanId = tc.BasePaymentPlanId
        LEFT JOIN products pr ON pr.BaseProductId = tc.BaseProductId
        LEFT JOIN regions r ON u.region_id = r.region_id
        LEFT JOIN countries c ON u.countryid = c.countryid
        WHERE u.userid = <cfqueryparam value="#arguments.userId#" cfsqltype="cf_sql_integer">
    </cfquery>

    <cfif qUserDetails.recordCount EQ 1>
       <cfloop list="#qUserDetails.columnList#" index="col">
    <!--- Check if the field is NULL and assign a default value --->
    <cfif isNull(qUserDetails[col])>
        <cfset user[col] = ""> <!--- Default empty string for NULL values --->
    <cfelse>
        <cfset user[col] = qUserDetails[col]>
    </cfif>
</cfloop>

        <!--- Additional Computed Fields --->
        <cfset user.calendarName = REPLACE(REPLACE(user.recordName, " ", ""), "-", "")>
    </cfif>

    <cfreturn user>
</cffunction>


</cfcomponent>
