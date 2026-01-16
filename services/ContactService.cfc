<cfcomponent displayname="ContactService" hint="Handles operations for Contact table" >

<!--- ========================================
      STANDARDIZED CRUD METHODS (T1)
      Created: 2025-11-23
      Following global service conventions
     ======================================== --->

<cffunction name="create" access="public" returntype="numeric" output="false" hint="Create a new contact record">
    <cfargument name="dataStruct" type="struct" required="true" hint="Contact data structure">

    <!--- Validate required fields --->
    <cfif NOT structKeyExists(arguments.dataStruct, "userid")>
        <cfthrow message="ContactService.create: userid is required">
    </cfif>
    <cfif NOT structKeyExists(arguments.dataStruct, "contactFullName")>
        <cfthrow message="ContactService.create: contactFullName is required">
    </cfif>

    <!--- Define allowed fields for contactdetails table --->
    <cfset var allowedFields = {
        "userid": "CF_SQL_INTEGER",
        "contactFullName": "CF_SQL_VARCHAR",
        "contacttitle": "CF_SQL_VARCHAR",
        "recordname": "CF_SQL_VARCHAR",
        "contactNickname": "CF_SQL_VARCHAR",
        "contactBirthday": "CF_SQL_DATE",
        "contactMeetingDate": "CF_SQL_DATE",
        "contactMeetingLoc": "CF_SQL_VARCHAR",
        "contactPronoun": "CF_SQL_VARCHAR",
        "refer_contact_id": "CF_SQL_INTEGER",
        "contactStatus": "CF_SQL_VARCHAR",
        "contactphoto": "CF_SQL_VARCHAR",
        "user_yn": "CF_SQL_CHAR",
        "newsletter_yn": "CF_SQL_CHAR",
        "googlealert_yn": "CF_SQL_CHAR",
        "socialmedia_yn": "CF_SQL_CHAR",
        "isdeleted": "CF_SQL_BIT"
    }>

    <!--- Build dynamic INSERT query --->
    <cfset var columns = []>
    <cfset var params = []>

    <cfloop collection="#arguments.dataStruct#" item="field">
        <cfif structKeyExists(allowedFields, field)>
            <cfset arrayAppend(columns, field)>
            <cfset arrayAppend(params, {
                value: arguments.dataStruct[field],
                cfsqltype: allowedFields[field]
            })>
        </cfif>
    </cfloop>

    <!--- Execute INSERT - cfqueryparam tags create the placeholders --->
    <cfquery name="qCreate" result="insertResult">
        INSERT INTO contactdetails (#arrayToList(columns)#)
        VALUES (
            <cfloop from="1" to="#arrayLen(params)#" index="i">
                <cfif i GT 1>,</cfif>
                <cfqueryparam value="#params[i].value#" cfsqltype="#params[i].cfsqltype#" null="#(NOT len(trim(params[i].value)))#">
            </cfloop>
        )
    </cfquery>

    <cfreturn insertResult.generatedKey>
</cffunction>

<cffunction name="read" access="public" returntype="struct" output="false" hint="Read a single contact record">
    <cfargument name="contactid" type="numeric" required="true" hint="Contact ID to retrieve">

    <cfquery name="qRead">
        SELECT
            contactid,
            userid,
            contactFullName,
            contacttitle,
            recordname,
            contactNickname,
            contactBirthday,
            contactMeetingDate,
            contactMeetingLoc,
            contactPronoun,
            refer_contact_id,
            contactStatus,
            contactCreationDate,
            contactLastUpdated,
            contactphoto,
            user_yn,
            newsletter_yn,
            googlealert_yn,
            socialmedia_yn,
            isdeleted
        FROM contactdetails
        WHERE contactid = <cfqueryparam value="#arguments.contactid#" cfsqltype="CF_SQL_INTEGER">
    </cfquery>

    <!--- Return empty struct if not found --->
    <cfif qRead.recordCount EQ 0>
        <cfreturn {}>
    </cfif>

    <!--- Convert query row to struct --->
    <cfset var result = {}>
    <cfloop list="#qRead.columnList#" index="col">
        <cfset result[col] = qRead[col][1]>
    </cfloop>

    <cfreturn result>
</cffunction>

<cffunction name="update" access="public" returntype="void" output="false">
    <cfargument name="contactid" type="numeric" required="true">
    <cfargument name="data" type="struct" required="true">

    <!--- No-op if caller passed no fields --->
    <cfif structIsEmpty(arguments.data)>
        <cfreturn>
    </cfif>

    <!--- Build SET clause dynamically so partial updates do not crash or overwrite --->
    <cfset var comma = "">

    <cfquery datasource="reach">
        UPDATE contactdetails
        SET
            <cfif structKeyExists(arguments.data, "contactFullName")>
                #comma# contactFullName = <cfqueryparam value="#arguments.data.contactFullName#" cfsqltype="CF_SQL_VARCHAR" null="#isNull(arguments.data.contactFullName)#">
                <cfset comma = ",">
            </cfif>

            <cfif structKeyExists(arguments.data, "contacttitle")>
                #comma# contacttitle = <cfqueryparam value="#arguments.data.contacttitle#" cfsqltype="CF_SQL_VARCHAR" null="#isNull(arguments.data.contacttitle)#">
                <cfset comma = ",">
            </cfif>

            <cfif structKeyExists(arguments.data, "recordname")>
                #comma# recordname = <cfqueryparam value="#arguments.data.recordname#" cfsqltype="CF_SQL_VARCHAR" null="#isNull(arguments.data.recordname)#">
                <cfset comma = ",">
            </cfif>

            <cfif structKeyExists(arguments.data, "contactNickname")>
                #comma# contactNickname = <cfqueryparam value="#arguments.data.contactNickname#" cfsqltype="CF_SQL_VARCHAR" null="#isNull(arguments.data.contactNickname)#">
                <cfset comma = ",">
            </cfif>

            <cfif structKeyExists(arguments.data, "contactBirthday")>
                #comma# contactBirthday = <cfqueryparam value="#arguments.data.contactBirthday#" cfsqltype="CF_SQL_DATE" null="#isNull(arguments.data.contactBirthday)#">
                <cfset comma = ",">
            </cfif>

            <cfif structKeyExists(arguments.data, "contactMeetingDate")>
                #comma# contactMeetingDate = <cfqueryparam value="#arguments.data.contactMeetingDate#" cfsqltype="CF_SQL_DATE" null="#isNull(arguments.data.contactMeetingDate)#">
                <cfset comma = ",">
            </cfif>

            <cfif structKeyExists(arguments.data, "contactMeetingLoc")>
                #comma# contactMeetingLoc = <cfqueryparam value="#arguments.data.contactMeetingLoc#" cfsqltype="CF_SQL_VARCHAR" null="#isNull(arguments.data.contactMeetingLoc)#">
                <cfset comma = ",">
            </cfif>

            <cfif structKeyExists(arguments.data, "contactPronoun")>
                #comma# contactPronoun = <cfqueryparam value="#arguments.data.contactPronoun#" cfsqltype="CF_SQL_VARCHAR" null="#isNull(arguments.data.contactPronoun)#">
                <cfset comma = ",">
            </cfif>

            <cfif structKeyExists(arguments.data, "refer_contact_id")>
                #comma# refer_contact_id = <cfqueryparam value="#arguments.data.refer_contact_id#" cfsqltype="CF_SQL_INTEGER" null="#isNull(arguments.data.refer_contact_id)#">
                <cfset comma = ",">
            </cfif>

            <cfif structKeyExists(arguments.data, "contactStatus")>
                #comma# contactStatus = <cfqueryparam value="#arguments.data.contactStatus#" cfsqltype="CF_SQL_VARCHAR" null="#isNull(arguments.data.contactStatus)#">
                <cfset comma = ",">
            </cfif>

            <cfif structKeyExists(arguments.data, "contactphoto")>
                #comma# contactphoto = <cfqueryparam value="#arguments.data.contactphoto#" cfsqltype="CF_SQL_VARCHAR" null="#isNull(arguments.data.contactphoto)#">
                <cfset comma = ",">
            </cfif>

            <cfif structKeyExists(arguments.data, "user_yn")>
                #comma# user_yn = <cfqueryparam value="#arguments.data.user_yn#" cfsqltype="CF_SQL_CHAR" null="#isNull(arguments.data.user_yn)#">
                <cfset comma = ",">
            </cfif>

            <cfif structKeyExists(arguments.data, "newsletter_yn")>
                #comma# newsletter_yn = <cfqueryparam value="#arguments.data.newsletter_yn#" cfsqltype="CF_SQL_CHAR" null="#isNull(arguments.data.newsletter_yn)#">
                <cfset comma = ",">
            </cfif>

            <cfif structKeyExists(arguments.data, "googlealert_yn")>
                #comma# googlealert_yn = <cfqueryparam value="#arguments.data.googlealert_yn#" cfsqltype="CF_SQL_CHAR" null="#isNull(arguments.data.googlealert_yn)#">
                <cfset comma = ",">
            </cfif>

            <cfif structKeyExists(arguments.data, "socialmedia_yn")>
                #comma# socialmedia_yn = <cfqueryparam value="#arguments.data.socialmedia_yn#" cfsqltype="CF_SQL_CHAR" null="#isNull(arguments.data.socialmedia_yn)#">
                <cfset comma = ",">
            </cfif>

            <cfif structKeyExists(arguments.data, "isdeleted")>
                #comma# isdeleted = <cfqueryparam value="#arguments.data.isdeleted#" cfsqltype="CF_SQL_BIT" null="#isNull(arguments.data.isdeleted)#">
                <cfset comma = ",">
            </cfif>
        WHERE contactid = <cfqueryparam value="#arguments.contactid#" cfsqltype="CF_SQL_INTEGER">
    </cfquery>
</cffunction>

<cffunction name="update22" access="public" returntype="void" output="false" hint="Update an existing contact record">
    <cfargument name="contactid" type="numeric" required="true" hint="Contact ID to update">
    <cfargument name="dataStruct" type="struct" required="true" hint="Fields to update">

    <!--- Define allowed fields for updates --->
    <cfset var allowedFields = {
        "contactFullName": "CF_SQL_VARCHAR",
        "contacttitle": "CF_SQL_VARCHAR",
        "recordname": "CF_SQL_VARCHAR",
        "contactNickname": "CF_SQL_VARCHAR",
        "contactBirthday": "CF_SQL_DATE",
        "contactMeetingDate": "CF_SQL_DATE",
        "contactMeetingLoc": "CF_SQL_VARCHAR",
        "contactPronoun": "CF_SQL_VARCHAR",
        "refer_contact_id": "CF_SQL_INTEGER",
        "contactStatus": "CF_SQL_VARCHAR",
        "contactphoto": "CF_SQL_VARCHAR",
        "user_yn": "CF_SQL_CHAR",
        "newsletter_yn": "CF_SQL_CHAR",
        "googlealert_yn": "CF_SQL_CHAR",
        "socialmedia_yn": "CF_SQL_CHAR",
        "isdeleted": "CF_SQL_BIT"
    }>

    <!--- Build dynamic UPDATE query --->
    <cfset var setClauses = []>
    <cfset var params = []>

    <cfloop collection="#arguments.dataStruct#" item="field">
        <cfif structKeyExists(allowedFields, field)>
            <cfset arrayAppend(setClauses, "#field# = ?")>
            <cfset arrayAppend(params, {
                value: arguments.dataStruct[field],
                cfsqltype: allowedFields[field]
            })>
        </cfif>
    </cfloop>

    <!--- Only execute if there are fields to update --->
    <cfif arrayLen(setClauses) GT 0>
        <cfset var updateSql = "UPDATE contactdetails SET ">
        <cfloop from="1" to="#arrayLen(setClauses)#" index="i">
            <cfif i GT 1><cfset updateSql &= ", "></cfif>
            <cfset updateSql &= setClauses[i]>
        </cfloop>
        <cfset updateSql &= " WHERE contactid = ?">

        <cfquery name="qUpdate">
            #preserveSingleQuotes(updateSql)#
            <cfloop from="1" to="#arrayLen(params)#" index="i">
                <cfqueryparam value="#params[i].value#" cfsqltype="#params[i].cfsqltype#" null="#isNull(params[i].value)#">
            </cfloop>
            <cfqueryparam value="#arguments.contactid#" cfsqltype="CF_SQL_INTEGER">
        </cfquery>
    </cfif>
</cffunction>


<cffunction name="updatebad" access="public" returntype="void" output="false">
    <cfargument name="contactid" type="numeric" required="true">
    <cfargument name="data" type="struct" required="true">

    <cfquery datasource="reach">
        UPDATE contactdetails
        SET
            contactFullName    = <cfqueryparam value="#data.contactFullName#"    cfsqltype="CF_SQL_VARCHAR" null="#isNull(data.contactFullName)#">,
            contacttitle       = <cfqueryparam value="#data.contacttitle#"       cfsqltype="CF_SQL_VARCHAR" null="#isNull(data.contacttitle)#">,
            recordname         = <cfqueryparam value="#data.recordname#"         cfsqltype="CF_SQL_VARCHAR" null="#isNull(data.recordname)#">,
            contactNickname    = <cfqueryparam value="#data.contactNickname#"    cfsqltype="CF_SQL_VARCHAR" null="#isNull(data.contactNickname)#">,
            contactBirthday    = <cfqueryparam value="#data.contactBirthday#"    cfsqltype="CF_SQL_DATE"    null="#isNull(data.contactBirthday)#">,
            contactMeetingDate = <cfqueryparam value="#data.contactMeetingDate#" cfsqltype="CF_SQL_DATE"    null="#isNull(data.contactMeetingDate)#">,
            contactMeetingLoc  = <cfqueryparam value="#data.contactMeetingLoc#"  cfsqltype="CF_SQL_VARCHAR" null="#isNull(data.contactMeetingLoc)#">,
            contactPronoun     = <cfqueryparam value="#data.contactPronoun#"     cfsqltype="CF_SQL_VARCHAR" null="#isNull(data.contactPronoun)#">,
            refer_contact_id   = <cfqueryparam value="#data.refer_contact_id#"   cfsqltype="CF_SQL_INTEGER" null="#isNull(data.refer_contact_id)#">,
            contactStatus      = <cfqueryparam value="#data.contactStatus#"      cfsqltype="CF_SQL_VARCHAR" null="#isNull(data.contactStatus)#">,
            contactphoto       = <cfqueryparam value="#data.contactphoto#"       cfsqltype="CF_SQL_VARCHAR" null="#isNull(data.contactphoto)#">,
            user_yn            = <cfqueryparam value="#data.user_yn#"            cfsqltype="CF_SQL_CHAR"    null="#isNull(data.user_yn)#">,
            newsletter_yn      = <cfqueryparam value="#data.newsletter_yn#"      cfsqltype="CF_SQL_CHAR"    null="#isNull(data.newsletter_yn)#">,
            googlealert_yn     = <cfqueryparam value="#data.googlealert_yn#"     cfsqltype="CF_SQL_CHAR"    null="#isNull(data.googlealert_yn)#">,
            socialmedia_yn     = <cfqueryparam value="#data.socialmedia_yn#"     cfsqltype="CF_SQL_CHAR"    null="#isNull(data.socialmedia_yn)#">,
            isdeleted          = <cfqueryparam value="#data.isdeleted#"          cfsqltype="CF_SQL_BIT"     null="#isNull(data.isdeleted)#">
        WHERE contactid = <cfqueryparam value="#arguments.contactid#" cfsqltype="CF_SQL_INTEGER">
    </cfquery>
</cffunction>

<!---
<cffunction name="updatse" access="public" returntype="void" output="false" hint="Update an existing contact record">
    <cfargument name="contactid" type="numeric" required="true" hint="Contact ID to update">
    <cfargument name="dataStruct" type="struct" required="true" hint="Fields to update">

    <!--- Define allowed fields for updates --->
    <cfset var allowedFields = {
        "contactFullName": "CF_SQL_VARCHAR",
        "contacttitle": "CF_SQL_VARCHAR",
        "recordname": "CF_SQL_VARCHAR",
        "contactNickname": "CF_SQL_VARCHAR",
        "contactBirthday": "CF_SQL_DATE",
        "contactMeetingDate": "CF_SQL_DATE",
        "contactMeetingLoc": "CF_SQL_VARCHAR",
        "contactPronoun": "CF_SQL_VARCHAR",
        "refer_contact_id": "CF_SQL_INTEGER",
        "contactStatus": "CF_SQL_VARCHAR",
        "contactphoto": "CF_SQL_VARCHAR",
        "user_yn": "CF_SQL_CHAR",
        "newsletter_yn": "CF_SQL_CHAR",
        "googlealert_yn": "CF_SQL_CHAR",
        "socialmedia_yn": "CF_SQL_CHAR",
        "isdeleted": "CF_SQL_BIT"
    }>


    <cfset var setClauses = []>
    <cfset var params = []>

    <cfloop collection="#arguments.dataStruct#" item="field">
        <cfif structKeyExists(allowedFields, field)>
            <cfset arrayAppend(setClauses, "#field# = ?")>
            <cfset arrayAppend(params, {
                value: arguments.dataStruct[field],
                cfsqltype: allowedFields[field]
            })>
        </cfif>
    </cfloop>

    <!--- Only execute if there are fields to update --->
    <cfif arrayLen(setClauses) GT 0>
        <cfset var updateSql = "UPDATE contactdetails SET ">
        <cfloop from="1" to="#arrayLen(setClauses)#" index="i">
            <cfif i GT 1><cfset updateSql &= ", "></cfif>
            <cfset updateSql &= setClauses[i]>
        </cfloop>
        <cfset updateSql &= " WHERE contactid = ?">

        <cfquery name="qUpdate">
            #preserveSingleQuotes(updateSql)#
            <cfloop from="1" to="#arrayLen(params)#" index="i">
                <cfqueryparam value="#params[i].value#" cfsqltype="#params[i].cfsqltype#" null="#isNull(params[i].value)#">
            </cfloop>
            <cfqueryparam value="#arguments.contactid#" cfsqltype="CF_SQL_INTEGER">
        </cfquery>
    </cfif>
</cffunction>

--->

<cffunction name="delete" access="public" returntype="void" output="false" hint="Soft-delete a contact record">
    <cfargument name="contactid" type="numeric" required="true" hint="Contact ID to delete">

    <!--- Soft delete by setting isdeleted = 1 --->
    <cfquery name="qDelete">
        UPDATE contactdetails
        SET isdeleted = <cfqueryparam value="1" cfsqltype="CF_SQL_BIT">
        WHERE contactid = <cfqueryparam value="#arguments.contactid#" cfsqltype="CF_SQL_INTEGER">
    </cfquery>
</cffunction>

<cffunction name="list" access="public" returntype="query" output="false" hint="List contacts with optional filters">
    <cfargument name="filtersStruct" type="struct" required="true" hint="Filter criteria">

    <!--- userid is always required --->
    <cfif NOT structKeyExists(arguments.filtersStruct, "userid")>
        <cfthrow message="ContactService.list: userid is required in filtersStruct">
    </cfif>

    <!--- Build base query --->
    <cfset var sql = "SELECT contactid, userid, contactFullName, contactStatus, recordname, contactCreationDate, contactLastUpdated FROM contactdetails WHERE userid = ?">
    <cfset var params = [{value: arguments.filtersStruct.userid, cfsqltype: "CF_SQL_INTEGER"}]>

    <!--- Apply optional filters --->
    <cfif structKeyExists(arguments.filtersStruct, "contactStatus") AND len(trim(arguments.filtersStruct.contactStatus))>
        <cfset sql &= " AND contactStatus = ?">
        <cfset arrayAppend(params, {value: arguments.filtersStruct.contactStatus, cfsqltype: "CF_SQL_VARCHAR"})>
    </cfif>

    <cfif structKeyExists(arguments.filtersStruct, "isdeleted")>
        <cfset sql &= " AND isdeleted = ?">
        <cfset arrayAppend(params, {value: arguments.filtersStruct.isdeleted, cfsqltype: "CF_SQL_BIT"})>
    <cfelse>
        <!--- Default: exclude deleted records --->
        <cfset sql &= " AND (isdeleted IS NULL OR isdeleted = 0)">
    </cfif>

    <cfif structKeyExists(arguments.filtersStruct, "search") AND len(trim(arguments.filtersStruct.search))>
        <cfset sql &= " AND (contactFullName LIKE ? OR recordname LIKE ?)">
        <cfset var searchTerm = "%" & trim(arguments.filtersStruct.search) & "%">
        <cfset arrayAppend(params, {value: searchTerm, cfsqltype: "CF_SQL_VARCHAR"})>
        <cfset arrayAppend(params, {value: searchTerm, cfsqltype: "CF_SQL_VARCHAR"})>
    </cfif>

    <!--- Apply ordering --->
    <cfif structKeyExists(arguments.filtersStruct, "orderBy") AND len(trim(arguments.filtersStruct.orderBy))>
        <cfset sql &= " ORDER BY #arguments.filtersStruct.orderBy#">
        <cfif structKeyExists(arguments.filtersStruct, "orderDir") AND arguments.filtersStruct.orderDir EQ "DESC">
            <cfset sql &= " DESC">
        <cfelse>
            <cfset sql &= " ASC">
        </cfif>
    <cfelse>
        <cfset sql &= " ORDER BY contactFullName ASC">
    </cfif>

    <!--- Execute query --->
    <cfquery name="qList">
        #preserveSingleQuotes(sql)#
        <cfloop from="1" to="#arrayLen(params)#" index="i">
            <cfqueryparam value="#params[i].value#" cfsqltype="#params[i].cfsqltype#">
        </cfloop>
    </cfquery>

    <cfreturn qList>
</cffunction>

<!--- ========================================
      LEGACY METHODS (Pre-T1)
      To be refactored as thin wrappers
     ======================================== --->

<cffunction name="updateContactUnique" access="public" returntype="void" output="false">
    <!--- Arguments --->
    <cfargument name="contactid" type="numeric" required="true">
    <cfargument name="uniquename" type="string" required="true">

    <!--- Update contact details --->
    <cfquery name="updateContact">
        UPDATE contactdetails
        SET #arguments.uniquename# = 'Y'
        WHERE contactid = <cfqueryparam value="#arguments.contactid#" cfsqltype="cf_sql_integer">
    </cfquery>
</cffunction>


<cffunction name="addMembers" access="public" returntype="void" output="false">
    <!--- Arguments required for the function --->
    <cfargument name="userid" type="numeric" required="true">
    <cfargument name="topsearch_myteam" type="string" required="true">

<!--- Perform a single query to find and optionally insert the record --->
    <cfquery name="addTeamMember">
        INSERT INTO contactitems (contactid, valuetype, valuecategory, valuetext, itemstatus, primary_yn)
        SELECT 
            contactid, 
            'Tags', 
            'Tag', 
            'My Team', 
            'Active', 
            'Y'
        FROM contacts_ss
        WHERE userid = <cfqueryparam value="#arguments.userid#" cfsqltype="CF_SQL_INTEGER">
          AND col1 = <cfqueryparam value="#arguments.topsearch_myteam#" cfsqltype="CF_SQL_VARCHAR">
          AND NOT EXISTS (
              SELECT 1 
              FROM contactitems 
              WHERE contactid = contacts_ss.contactid
                AND valuetext = 'My Team'
          )
    </cfquery>


</cffunction>

<cffunction name="getSystemIdBasedOnTag" access="public" returntype="numeric" output="false">
    <cfargument name="audprojectDate" type="date" required="true">
    <cfargument name="new_contactid" type="numeric" required="true">

<cfset var new_systemid = 0>

<!--- Check if the project date is in the past --->
    <cfif DateCompare(arguments.audprojectDate, Now()) LT 0>
        <cfquery name="findtag"  maxrows="1">
            SELECT * 
            FROM contactdetails d
            JOIN contactitems i ON i.contactid = d.contactid
            JOIN tags tu ON (CONVERT(tu.tagname USING UTF8) = i.valueText)
            WHERE 
                d.contactid = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#arguments.new_contactid#">
                AND i.valuecategory = 'Tag'  
                AND tu.tagtype = 'C'
        </cfquery>

<!--- Determine system ID based on tag existence --->
        <cfif findtag.recordcount EQ 1>
            <cfset new_systemid = 1>
        <cfelse>
            <cfset new_systemid = 2>
        </cfif>
    </cfif>

<cfreturn new_systemid>
</cffunction>

<cffunction name="getContactCount" access="public" returntype="numeric">
    <cfargument name="userid" type="numeric" required="true">
    <cfargument name="relationship" type="numeric" required="true">

<!--- Query to get the count of contacts based on userid and relationship --->
    <cfquery name="qCount">
        SELECT COUNT(contactid) AS totalCount
        FROM contactdetails
        WHERE userid = <cfqueryparam value="#arguments.userid#" cfsqltype="CF_SQL_INTEGER">
        AND contactid = <cfqueryparam value="#arguments.relationship#" cfsqltype="CF_SQL_INTEGER">
    </cfquery>

<!--- Return the count result --->
    <cfreturn qCount.totalCount>
</cffunction>

<cffunction output="false" name="getFilteredContactsByEvent" access="public" returntype="query">
    <!--- Define required arguments --->
    <cfargument name="contacts_table" type="string" required="true">
    <cfargument name="userid" type="numeric" required="true">
    <cfargument name="eventid" type="numeric" required="true">

<!--- Execute the query with only userid and eventid parameters --->
    <cfquery name="qFiltered" result="result">
        SELECT contactid, col1, col2, col3, col4, col5, userid, hlink
        FROM #arguments.contacts_table#
        WHERE userid = <cfqueryparam value="#arguments.userid#" cfsqltype="CF_SQL_INTEGER">
        AND contactid IN (
            SELECT contactid
            FROM eventcontactsxref
            WHERE eventid = <cfqueryparam value="#arguments.eventid#" cfsqltype="CF_SQL_INTEGER">
        )
    </cfquery>

<!--- Return the query result --->
    <cfreturn qFiltered>
</cffunction>

<cffunction output="false" name="ru" access="public" returntype="query">
        <cfargument name="contactid" type="numeric" required="true">
        <cfargument name="userid" type="numeric" required="true">

<cfquery result="result" name="ru">
            SELECT 
                fc.suID,
                fc.contactid,
                fc.userid,
                fc.suStartDate,
                fc.suenddate,
                fc.suStatus,
                s.systemName,
                s.systemdescript,
                s.systemtype,
                s.systemscope,
                s.systemid,
                s.recordname
            FROM fusystemusers fc 
            INNER JOIN fusystems s ON s.systemID = fc.systemID
            WHERE fc.contactID = <cfqueryparam value="#arguments.contactid#" cfsqltype="cf_sql_integer">
              AND fc.userID = <cfqueryparam value="#arguments.userid#" cfsqltype="cf_sql_integer">
              AND fc.sustatus = 'Active'
        </cfquery>

<cfreturn ru>
    </cffunction>

<!--- Function to retrieve filtered contacts --->
    <cffunction output="false" name="getFilteredContacts" access="public" returntype="query" >
        <!--- Define arguments --->
        <cfargument name="contacts_table" type="string" required="true">
        <cfargument name="userid" type="numeric" required="true">
        <cfargument name="bytag" type="string" required="false" default="">
        <cfargument name="byimport" type="string" required="false" default="">
        <cfargument name="bylike" type="string" required="false" default="">
        <cfargument name="uploadid" type="numeric" required="false" default="0">
        <cfargument name="search" type="string" required="false" default="">
        <cfargument name="listColumns" type="string" required="false" default="">
        <cfargument name="formOrderColumn" type="string" required="false" default="">
        <cfargument name="formOrderDir" type="string" required="false" default="asc">

<!--- Declare local variables --->
        <cfset var qFiltered = "">
        <cfset var sql = "">
        <cfset var paramList = []>
        <cfset var allowedOrderColumns = {
            "1": "col1",
            "2": "col2",
            "3": "col2b",
            "4": "col3",
            "5": "col4",
            "6": "col5"
        }>
        <cfset var orderColumn = "">
        <cfset var orderDir = "asc">
        <cfset var i = 0>

<!--- Start building SQL query --->
        <cfset sql = "SELECT contactid, col1, col2, col2b, col3, col4, col5, userid, hlink FROM #arguments.contacts_table# WHERE userid = ?">
        <cfset paramList.append({value=arguments.userid, cfsqltype="CF_SQL_INTEGER"})>

<!--- Build WHERE clauses based on conditions --->
        <cfif len(trim(arguments.bytag))>
            <cfset sql &= " AND contactid IN ( SELECT contactid FROM contactitems WHERE valuetype = 'tags' AND itemstatus = 'active' AND valuetext = ? )">
            <cfset paramList.append({value=arguments.bytag, cfsqltype="CF_SQL_VARCHAR"})>
        </cfif>

<cfif len(trim(arguments.byimport))>
            <cfset sql &= " AND contactid IN ( SELECT contactid FROM contactsimport WHERE uploadid = ? )">
            <cfset paramList.append({value=arguments.byimport, cfsqltype="CF_SQL_INTEGER"})>
        </cfif>

<cfif len(trim(arguments.bylike))>
            <cfset sql &= " AND col1 LIKE ?">
            <cfset paramList.append({value="%" & trim(arguments.bylike) & "%", cfsqltype="CF_SQL_VARCHAR"})>
        </cfif>

<cfif arguments.uploadid neq 0>
            <cfset sql &= " AND contactid IN ( SELECT contactid FROM contactsimport WHERE uploadid = ? )">
            <cfset paramList.append({value=arguments.uploadid, cfsqltype="CF_SQL_INTEGER"})>
        </cfif>

<cfif len(trim(arguments.search))>
            <cfif trim(arguments.search) is "no system">
                <cfset sql &= " AND contactid NOT IN ( SELECT contactid FROM contacts_ss_followup WHERE userid = ? )">
                <cfset paramList.append({value=arguments.userid, cfsqltype="CF_SQL_INTEGER"})>
                <cfset sql &= " AND contactid NOT IN ( SELECT contactid FROM contacts_ss_maint WHERE userid = ? )">
                <cfset paramList.append({value=arguments.userid, cfsqltype="CF_SQL_INTEGER"})>
                <cfset sql &= " AND contactid NOT IN ( SELECT contactid FROM contacts_ss_target WHERE userid = ? )">
                <cfset paramList.append({value=arguments.userid, cfsqltype="CF_SQL_INTEGER"})>
            <cfelse>
                <cfset sql &= " AND (">
                <cfloop list="#arguments.listColumns#" index="thisColumn">
                    <cfif i gt 0>
                        <cfset sql &= " OR ">
                    </cfif>
                    <cfset sql &= "#thisColumn# LIKE ?">
                    <cfset paramList.append({value="%" & trim(arguments.search) & "%", cfsqltype="CF_SQL_VARCHAR"})>
                    <cfset i++>
                </cfloop>
                <cfset sql &= " )">
            </cfif>
        </cfif>

<!--- Build ORDER BY clause if applicable --->
        <cfif structKeyExists(allowedOrderColumns, arguments.formOrderColumn)>
            <cfset orderColumn = allowedOrderColumns[arguments.formOrderColumn]>
            <cfif arguments.formOrderDir eq "desc">
                <cfset orderDir = "DESC">
            <cfelse>
                <cfset orderDir = "ASC">
            </cfif>
            <cfset sql &= " ORDER BY #orderColumn# #orderDir#">
        </cfif>

<!--- Execute query --->

<cfquery result="result" name="qFiltered" >
                #sql#
                <!--- Bind parameters --->
                <cfloop array="#paramList#" index="param">
                    <cfqueryparam value="#param.value#" cfsqltype="#param.cfsqltype#">
                </cfloop>
            </cfquery>
            <!--- Return the query result --->
            <cfreturn qFiltered>

<!--- Log the error --->

<!--- Return an empty query --->

</cffunction>

<cffunction output="false" name="getContactUpdates" access="public" returntype="query">
    <cfargument name="userid" type="numeric" required="true">
    <cfargument name="compid" type="numeric" required="true">

<cfquery result="result" name="updates" >
        SELECT 
            d.contactid,
            'Name' AS head1,
            'Last Update' AS head2,
            d.contactfullname AS col1,
            MAX(u.updatetimestamp) AS col2
        FROM 
            contactdetails d
        LEFT JOIN 
            updatelog u 
            ON u.recid = d.contactid
        WHERE 
            d.contactStatus = 'Active' 
            AND d.userid = <cfqueryparam value="#arguments.userid#" cfsqltype="CF_SQL_INTEGER"> 
            AND u.userid = d.userid
            AND u.compid = <cfqueryparam value="#arguments.compid#" cfsqltype="CF_SQL_INTEGER">
        GROUP BY 
            d.contactfullname
    </cfquery>

<cfreturn updates>
</cffunction>

<cffunction output="false" name="SELcontactdetails" access="public" returntype="query">
    <cfargument name="addDaysNoUniqueName" type="string" required="true">
    <cfargument name="newContactId" type="numeric" required="true">

<cfquery name="result" maxrows="1">
            SELECT d.contactid
            FROM contactdetails d
            WHERE d.#arguments.addDaysNoUniqueName# = <cfqueryparam value="Y" cfsqltype="CF_SQL_CHAR">
            AND d.contactid = <cfqueryparam value="#arguments.newContactId#" cfsqltype="CF_SQL_INTEGER">

</cfquery>

<cfreturn result>
</cffunction>
<cffunction output="false" name="SELcontactdetails_23722" access="public" returntype="query">
    <cfargument name="userId" type="numeric" required="true">

<cfquery name="result" >
            SELECT d.contactid, d.recordname
            FROM contactdetails d 
            WHERE recordname <> '' 
              AND userid = <cfqueryparam value="#arguments.userId#" cfsqltype="CF_SQL_INTEGER"> 
            ORDER BY d.contactfullname
        </cfquery>

<cfreturn result>
</cffunction>
<cffunction output="false" name="SELcontactdetails_23727" access="public" returntype="query" hint="Legacy wrapper - delegates to read() for single record">
    <cfargument name="userid" required="true" type="numeric">
    <cfargument name="relationship" required="true" type="numeric">

    <!--- Thin wrapper: this is a single-record fetch by contactid, delegate to read() --->
    <cfset var contactStruct = this.read(arguments.relationship)>

    <!--- Verify userid matches for security --->
    <cfif NOT structIsEmpty(contactStruct) AND contactStruct.userid NEQ arguments.userid>
        <!--- Return empty query if userid doesn't match --->
        <cfset contactStruct = {}>
    </cfif>

    <!--- Convert struct to query to maintain legacy return type --->
    <cfif structIsEmpty(contactStruct)>
        <cfset var result = queryNew("contactid")>
    <cfelse>
        <cfset var columnList = structKeyList(contactStruct)>
        <cfset var result = queryNew(columnList)>
        <cfset queryAddRow(result, 1)>
        <cfloop collection="#contactStruct#" item="col">
            <cfset querySetCell(result, col, contactStruct[col], 1)>
        </cfloop>
    </cfif>

    <cfreturn result>
</cffunction>
<cffunction output="false" name="INScontactdetails" access="public" returntype="numeric" hint="Legacy wrapper - delegates to create()">
    <cfargument name="userid" type="numeric" required="true">
    <cfargument name="contactFullName" type="string" required="true">

    <!--- Thin wrapper: map arguments to dataStruct and delegate to create() --->
    <cfset var dataStruct = {
        userid: arguments.userid,
        contactFullName: arguments.contactFullName
    }>

    <cfreturn this.create(dataStruct)>
</cffunction>
<cffunction output="false" name="INScontactdetails_23769" access="public" returntype="numeric" hint="Legacy wrapper - delegates to create()">
    <cfargument name="userid" type="numeric" required="true">
    <cfargument name="cdfullname" type="string" required="true">

    <!--- Thin wrapper: map arguments to dataStruct and delegate to create() --->
    <cfset var dataStruct = {
        userid: arguments.userid,
        contactFullName: arguments.cdfullname
    }>

    <cfreturn this.create(dataStruct)>
</cffunction>

<cffunction output="false" name="SELcontactdetails_23806" access="public" returntype="query">
    <cfargument name="contactid" type="numeric" required="true">

<cfquery name="result" >
            SELECT contactid, contactbirthday 
            FROM contactdetails 
            WHERE contactbirthday IS NOT NULL 
            AND contactid = <cfqueryparam value="#arguments.contactid#" cfsqltype="CF_SQL_INTEGER">
        </cfquery>

<cfreturn result>
</cffunction>

<cffunction output="false" name="UPDcontactdetails" access="public" returntype="void" hint="Legacy wrapper - delegates to update()">
    <cfargument name="final_birthday" type="date" required="true">
    <cfargument name="New_contactid" type="numeric" required="true">

    <!--- Thin wrapper: map arguments to dataStruct and delegate to update() --->
    <cfset var dataStruct = {
        contactBirthday: arguments.final_birthday
    }>

    <cfset this.update(arguments.New_contactid, dataStruct)>
</cffunction>
 
<cffunction output="false" name="UPDcontactdetails_23816" access="public" returntype="void" hint="Legacy wrapper - dynamic field update">
    <cfargument name="uniquename" type="string" required="true">
    <cfargument name="contactid" type="numeric" required="true">

    <!--- This method uses dynamic column name which can't be safely mapped to dataStruct --->
    <!--- Preserve legacy implementation for now as it's a special case --->
    <cfquery result="result" >
        UPDATE contactdetails
        SET #arguments.uniquename# = <cfqueryparam value="Y" cfsqltype="CF_SQL_CHAR">
        WHERE contactid = <cfqueryparam value="#arguments.contactid#" cfsqltype="CF_SQL_INTEGER">
    </cfquery>
</cffunction>
<cffunction output="false" name="INScontactdetails_23839" access="public" returntype="numeric" hint="Legacy wrapper - delegates to create()">
    <cfargument name="userid" type="numeric" required="true">
    <cfargument name="contactfullname" type="string" default="Unknown">

    <!--- Thin wrapper: map arguments to dataStruct and delegate to create() --->
    <cfset var dataStruct = {
        userid: arguments.userid,
        contactFullName: arguments.contactfullname
    }>

    <cfreturn this.create(dataStruct)>
</cffunction>
<cffunction output="false" name="SELcontactdetails_23843" access="public" returntype="query">
    <cfargument name="userid" type="numeric" required="true">
    <cfargument name="select_contactid" type="numeric" default="0">

<cfquery name="result" >
            SELECT contactid, recordname 
            FROM contactdetails 
            WHERE userid = <cfqueryparam value="#arguments.userid#" cfsqltype="CF_SQL_INTEGER">
            <cfif arguments.select_contactid neq 0>
                AND contactid = <cfqueryparam value="#arguments.select_contactid#" cfsqltype="CF_SQL_INTEGER">
            </cfif>
            ORDER BY contactid
        </cfquery>
    <cfreturn result>
</cffunction>
<cffunction output="false" name="UPDcontactdetails_23861" access="public" returntype="void">
    <cfargument name="idList" type="string" required="true">
    <!--- Ensure the idList is sanitized --->

<!--- Update query --->
    <cfquery name="queryResult">
        UPDATE contactdetails_tbl
        SET isdeleted = 1
        WHERE contactid IN (#idList#)
    </cfquery>
</cffunction>

<cffunction output="false" name="SELcontactdetails_23888" access="public" returntype="query">
    <cfargument name="userId" type="numeric" required="true">
    <cfargument name="idList" type="string" required="true">

<cfquery name="result" >
            SELECT 
                contactid AS new_contactid, 
                SUBSTRING_INDEX(contactfullname, ' ', 1) AS new_FirstName, 
                SUBSTRING(contactfullname, LENGTH(SUBSTRING_INDEX(contactfullname, ' ', 1)) + 2) AS new_LastName, 
                contactmeetingdate AS new_contactmeetingdate, 
                ContactMeetingLoc AS new_ContactMeetingLoc, 
                contactbirthday AS new_contactbirthday 
            FROM 
                contactdetails d
            WHERE 
                d.contactStatus = <cfqueryparam cfsqltype="cf_sql_varchar" value="Active"> 
                AND d.userid = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.userId#"> 
                AND d.contactid IN (<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.idList#" list="true">)
        </cfquery>

<cfreturn result>
</cffunction>
<cffunction output="false" name="SELcontactdetails_23906" access="public" returntype="query">
    <cfargument name="searchTerm" type="string" required="true">

<cfquery name="result" >
            SELECT DISTINCT contactfullname 
            FROM contactdetails 
            WHERE contactfullname <> '' 
            AND contactfullname IS NOT NULL 
            AND contactfullname <> 'NULL' 
            AND contactfullname <> ' ' 
            AND contactfullname LIKE <cfqueryparam value="#arguments.searchTerm#%" cfsqltype="cf_sql_varchar">

UNION

SELECT DISTINCT recordname AS contactfullname 
            FROM imdb 
            WHERE recordname <> '' 
            AND recordname IS NOT NULL 
            AND recordname <> 'NULL' 
            AND recordname <> ' ' 
            AND recordname LIKE <cfqueryparam value="#arguments.searchTerm#%" cfsqltype="cf_sql_varchar">

ORDER BY contactfullname
            LIMIT 10
        </cfquery>

<cfreturn result>

</cffunction>

<cffunction output="false" name="SELcontactdetails_23913" access="public" returntype="query">

<cfargument name="contactid" type="numeric" required="true">

<cfquery name="result" >
            SELECT recordname 
            FROM contactdetails 
            WHERE contactid = <cfqueryparam value="#arguments.contactid#" cfsqltype="CF_SQL_INTEGER">
        </cfquery>

<cfreturn result>
</cffunction>

<cffunction name="getContactRecordName" access="public" returntype="query" output="false">
    <cfargument name="new_contactid" type="numeric" required="false" default="0">

<cfif NOT isNumeric(arguments.new_contactid) OR arguments.new_contactid EQ 0>
        <cfreturn queryNew("recordname", "varchar")>
    </cfif>

<cfquery name="result">
            SELECT recordname
            FROM contactdetails
            WHERE contactid = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#arguments.new_contactid#">
            AND contactid <> 0
        </cfquery>

<cfreturn result>
</cffunction>

<cffunction output="false" name="SELcontactdetails_23939" access="public" returntype="query">
    <cfargument name="addDaysNoUniqueName" type="string" required="true">
    <cfargument name="contactId" type="numeric" required="true">

<cfquery name="result" >
            SELECT d.contactid 
            FROM contactdetails d 
            WHERE d.#arguments.addDaysNoUniqueName# = <cfqueryparam value="Y" cfsqltype="CF_SQL_CHAR"> 
            AND d.contactid = <cfqueryparam value="#arguments.contactId#" cfsqltype="CF_SQL_INTEGER"> 
            LIMIT 1
        </cfquery>

<cfreturn result>

</cffunction>

<cffunction output="false" name="INScontactdetails_24000" access="public" returntype="numeric" hint="Legacy wrapper - delegates to create()">
    <cfargument name="userFirstName" type="string" required="true">
    <cfargument name="userLastName" type="string" required="true">
    <cfargument name="userId" type="numeric" required="true">

    <!--- Preserve legacy behavior: concatenate first and last name --->
    <cfset var fullName = "#arguments.userFirstName# #arguments.userLastName#">

    <!--- Thin wrapper: map arguments to dataStruct and delegate to create() --->
    <cfset var dataStruct = {
        userid: arguments.userId,
        contactFullName: fullName,
        user_yn: "Y"
    }>

    <cfreturn this.create(dataStruct)>
</cffunction>
<cffunction output="false" name="INScontactdetails_24048" access="public" returntype="numeric">
    <cfargument name="userid" type="numeric" required="true">
    <cfargument name="contactfullname" type="string" required="true">

<cfquery result="result" >
            INSERT INTO contactdetails_tbl (userid, contactfullname)
            VALUES (
                <cfqueryparam value="#arguments.userid#" cfsqltype="CF_SQL_INTEGER">,
                <cfqueryparam value="#TRIM(arguments.contactfullname)#" cfsqltype="CF_SQL_VARCHAR">
            )
        </cfquery>
<cfreturn result.generatedKey>
</cffunction>
<cffunction output="false" name="SELcontactdetails_24069" access="public" returntype="query" hint="Legacy wrapper - delegates to list()">
    <cfargument name="userid" type="numeric" required="true">

    <!--- Thin wrapper: map arguments to filtersStruct and delegate to list() --->
    <cfset var filtersStruct = {
        userid: arguments.userid,
        orderBy: "contactfullname",
        orderDir: "ASC"
    }>

    <!--- Note: list() returns subset of columns; this legacy method expects all columns --->
    <!--- For full SELECT *, fall back to direct query to maintain legacy behavior --->
    <cfquery name="result" >
        SELECT *
        FROM contactdetails
        WHERE userid = <cfqueryparam value="#arguments.userid#" cfsqltype="CF_SQL_INTEGER">
        ORDER BY contactfullname
    </cfquery>

    <cfreturn result>
</cffunction>
<cffunction output="false" name="INScontactdetails_24070" access="public" returntype="numeric" hint="Legacy wrapper - delegates to create()">
    <cfargument name="userid" type="numeric" required="true">
    <cfargument name="contactFullName" type="string" required="true">
    <cfargument name="contactBirthday" type="date" required="false" default="#JavaCast('null', '')#">
    <cfargument name="referContactId" type="numeric" required="false" default="#JavaCast('null', '')#">
    <cfargument name="contactMeetingDate" type="date" required="false" default="#JavaCast('null', '')#">
    <cfargument name="contactMeetingLoc" type="string" required="true">
    <cfargument name="contactPronoun" type="string" required="true">

    <!--- Thin wrapper: map arguments to dataStruct preserving legacy conditional logic --->
    <cfset var dataStruct = {
        userid: arguments.userid,
        contactFullName: arguments.contactFullName,
        contactMeetingLoc: arguments.contactMeetingLoc,
        contactPronoun: arguments.contactPronoun
    }>

    <!--- Add optional fields if they exist and are valid (preserving legacy behavior) --->
    <cfif structKeyExists(arguments, "contactBirthday") and isDate(arguments.contactBirthday)>
        <cfset dataStruct.contactBirthday = arguments.contactBirthday>
    </cfif>
    <cfif structKeyExists(arguments, "referContactId") and isNumeric(arguments.referContactId)>
        <cfset dataStruct.refer_contact_id = arguments.referContactId>
    </cfif>
    <cfif structKeyExists(arguments, "contactMeetingDate") and isDate(arguments.contactMeetingDate)>
        <cfset dataStruct.contactMeetingDate = arguments.contactMeetingDate>
    </cfif>

    <cfreturn this.create(dataStruct)>
</cffunction>

<cffunction output="false" name="DETcontactdetails" access="public" returntype="query" hint="Legacy wrapper - delegates to read() and converts to query">
    <cfargument name="contactid" type="numeric" required="true">

    <!--- Thin wrapper: delegate to read() and convert struct to query for backward compatibility --->
    <cfset var contactStruct = this.read(arguments.contactid)>

    <!--- Convert struct to query to maintain legacy return type --->
    <cfif structIsEmpty(contactStruct)>
        <!--- Return empty query if not found --->
        <cfset var result = queryNew("contactid")>
    <cfelse>
        <!--- Build query from struct --->
        <cfset var columnList = structKeyList(contactStruct)>
        <cfset var result = queryNew(columnList)>
        <cfset queryAddRow(result, 1)>
        <cfloop collection="#contactStruct#" item="col">
            <cfset querySetCell(result, col, contactStruct[col], 1)>
        </cfloop>
    </cfif>

    <cfreturn result>
</cffunction>
<cffunction output="false" name="UPDcontactdetails_24202" access="public" returntype="void" hint="Legacy wrapper - delegates to update()">
    <cfargument name="contactid" type="numeric" required="true">
    <cfargument name="contactfullname" type="string" required="true">
    <cfargument name="contactPronoun" type="string" required="true">
    <cfargument name="custom" type="string" required="false" default="">
    <cfargument name="contactbirthday" type="any" required="false" default="">
    <cfargument name="contactmeetingdate" type="any" required="false" default="">
    <cfargument name="contactmeetingloc" type="string" required="false" default="">
    <cfargument name="deleteitem" type="numeric" required="false" default=false>
    <cfargument name="refer_contact_id"  required="false">

    <!--- Thin wrapper: build dataStruct preserving all legacy conditional logic --->
    <cfset var dataStruct = {}>

    <!--- Always update these fields --->
    <cfset dataStruct.contactFullName = trim(arguments.contactfullname)>
    <cfset dataStruct.contactMeetingLoc = trim(arguments.contactmeetingloc)>

    <!--- Handle custom pronoun logic --->
    <cfif arguments.contactPronoun is "custom">
        <cfset dataStruct.contactPronoun = trim(arguments.custom)>
    <cfelse>
        <cfset dataStruct.contactPronoun = trim(arguments.contactPronoun)>
    </cfif>

    <!--- Conditionally add optional fields if they have values --->
    <cfif not isNull(arguments.contactbirthday) and len(trim(arguments.contactbirthday))>
        <cfset dataStruct.contactBirthday = arguments.contactbirthday>
    </cfif>

    <cfif not isNull(arguments.contactmeetingdate) and len(trim(arguments.contactmeetingdate))>
        <cfset dataStruct.contactMeetingDate = arguments.contactmeetingdate>
    </cfif>

    <cfif arguments.deleteitem>
        <cfset dataStruct.isdeleted = 1>
    </cfif>

    <cfif isDefined("arguments.refer_contact_id") and Len(trim(arguments.refer_contact_id))>
        <cfset dataStruct.refer_contact_id = arguments.refer_contact_id>
    </cfif>

    <!--- Delegate to update() --->
    <cfset this.update(arguments.contactid, dataStruct)>
</cffunction>

<cffunction output="false" name="SELcontactdetails_24263" access="public" returntype="query">
    <cfargument name="userid" type="numeric" required="true">

<cfquery name="result" >
            SELECT contactid, recordname
            FROM contactdetails
            WHERE userid = <cfqueryparam value="#arguments.userid#" cfsqltype="CF_SQL_INTEGER">
            AND recordname <> ''
            ORDER BY recordname
        </cfquery>

<cfreturn result>
</cffunction>
<cffunction output="false" name="DETcontactdetails_24264" access="public" returntype="query" hint="Legacy wrapper - delegates to read() and converts to query">
    <cfargument name="contactid" type="numeric" required="true">

    <!--- Thin wrapper: delegate to read() and convert struct to query for backward compatibility --->
    <cfset var contactStruct = this.read(arguments.contactid)>

    <!--- Convert struct to query to maintain legacy return type --->
    <cfif structIsEmpty(contactStruct)>
        <cfset var result = queryNew("contactid")>
    <cfelse>
        <cfset var columnList = structKeyList(contactStruct)>
        <cfset var result = queryNew(columnList)>
        <cfset queryAddRow(result, 1)>
        <cfloop collection="#contactStruct#" item="col">
            <cfset querySetCell(result, col, contactStruct[col], 1)>
        </cfloop>
    </cfif>

    <cfreturn result>
</cffunction>
<cffunction output="false" name="SELcontactdetails_24293" access="public" returntype="query">
    <cfargument name="userid" type="numeric" required="true">
    <cfargument name="referral" type="string" required="true">

<cfquery name="result" maxrows="1" >
            SELECT * 
            FROM contactdetails 
            WHERE userid = <cfqueryparam value="#arguments.userid#" cfsqltype="CF_SQL_INTEGER"> 
            AND recordname = <cfqueryparam value="#arguments.referral#" cfsqltype="CF_SQL_VARCHAR">
        </cfquery>

<cfreturn result>
</cffunction>
<cffunction output="false" name="INScontactdetails_24294" access="public" returntype="numeric">
    <cfargument name="userid" type="numeric" required="true">
    <cfargument name="contactfullname" type="string" required="true">

<cfquery result="result" >
            INSERT INTO contactdetails (userid, contactfullname) 
            VALUES (
                <cfqueryparam value="#arguments.userid#" cfsqltype="CF_SQL_INTEGER">,
                <cfqueryparam value="#arguments.contactfullname#" cfsqltype="CF_SQL_VARCHAR">
            )
        </cfquery>

</cffunction>
<cffunction output="false" name="DETcontactdetails_24340" access="public" returntype="query">
    <cfargument name="idList" type="string" required="true">

<cfif len(trim(arguments.idList)) neq 0 and arguments.idList neq "0">



<cfquery name="result">
        SELECT contactid, recordname
        FROM contactdetails d
        WHERE d.contactid IN (
            <cfqueryparam value="#arguments.idList#" cfsqltype="CF_SQL_INTEGER" list="true">
        )
    </cfquery>

<cfreturn result>
</cfif>
</cffunction>

<cffunction output="false" name="SELcontactdetails_24364" access="public" returntype="query">
    <cfargument name="cdfullname" type="string" required="true">
    <cfargument name="userid" type="numeric" required="true">

<cfquery name="result" >
            SELECT * 
            FROM contactdetails 
            WHERE contactfullname = <cfqueryparam value="#arguments.cdfullname#" cfsqltype="CF_SQL_VARCHAR"> 
            AND userid = <cfqueryparam value="#arguments.userid#" cfsqltype="CF_SQL_INTEGER">
        </cfquery>

<cfreturn result>
</cffunction>
<cffunction output="false" name="SELcontactdetails_24397" access="public" returntype="query">
    <cfargument name="fname" type="string" required="true">
    <cfargument name="lname" type="string" required="true">

<cfquery name="result" >
            SELECT *
            FROM contactdetails
            WHERE contactfullname = <cfqueryparam value="#arguments.fname# #arguments.lname#" cfsqltype="CF_SQL_VARCHAR">
            AND userid = <cfqueryparam value="#userid#" cfsqltype="CF_SQL_INTEGER">
        </cfquery>

<cfreturn result>
</cffunction>


<cffunction name="INScontactdetails_24399" access="public" returntype="struct" output="false">
    <!--- Arguments --->
    <cfargument name="new_x" type="struct" required="true">
    <cfargument name="userid" type="numeric" required="true">
  
    <!--- Local variables --->
    <cfset var result = {}>

    <!--- SQL Query --->

    <!--- Check if a record with the same first and last name exists --->
    <cfquery name="checkExisting">
        SELECT contactid
        FROM contactdetails_tbl
        WHERE contactfullname = '#trim(arguments.new_x.fname)# #trim(arguments.new_x.lname)#'
        AND userid = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.userid#">
    </cfquery>

    <cfif checkExisting.recordCount>
        <!--- Update the existing record --->
        <cfquery name="updateRecord">
            UPDATE contactdetails_tbl
            SET 
                contactMeetingDate = <cfif len(trim(arguments.new_x.contactMeetingDate))>
                                        <cfqueryparam cfsqltype="cf_sql_date" value="#arguments.new_x.contactMeetingDate#">
                                    <cfelse>NULL</cfif>,
                contactMeetingLoc = <cfif len(trim(arguments.new_x.contactMeetingLoc))>
                                        <cfqueryparam cfsqltype="cf_sql_varchar" value="#trim(arguments.new_x.contactMeetingLoc)#">
                                    <cfelse>NULL</cfif>,
                contactBirthday = <cfif len(trim(arguments.new_x.birthday))>
                                        <cfqueryparam cfsqltype="cf_sql_date" value="#arguments.new_x.birthday#">
                                    <cfelse>NULL</cfif>
            WHERE contactid = <cfqueryparam cfsqltype="cf_sql_integer" value="#checkExisting.contactid#">
        </cfquery>

        <!--- Return success response for update --->
        <cfset result.new_contactid = checkExisting.contactid />
        <cfset result.success = true>
        <cfset result.message = "Record updated successfully.">
        <cfset result.status = "Duplicate">
    <cfelse>
        <!--- Insert a new record --->
        <cfquery name="add" result="result">
            INSERT INTO contactdetails_tbl (
                contactfullname, userid
                <cfif len(trim(arguments.new_x.contactMeetingDate))>
                    , contactMeetingDate
                </cfif>
                <cfif len(trim(arguments.new_x.contactMeetingLoc))>
                    , contactMeetingLoc
                </cfif>
                <cfif len(trim(arguments.new_x.birthday))>
                    , contactBirthday
                </cfif>
            )
            VALUES (
                <cfqueryparam cfsqltype="cf_sql_varchar" value="#trim(arguments.new_x.fname)# #trim(arguments.new_x.lname)#">,
                <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.userid#">
                <cfif len(trim(arguments.new_x.contactMeetingDate))>
                    , <cfqueryparam cfsqltype="cf_sql_date" value="#arguments.new_x.contactMeetingDate#">
                </cfif>
                <cfif len(trim(arguments.new_x.contactMeetingLoc))>
                    , <cfqueryparam cfsqltype="cf_sql_varchar" value="#trim(arguments.new_x.contactMeetingLoc)#">
                </cfif>
                <cfif len(trim(arguments.new_x.birthday))>
                    , <cfqueryparam cfsqltype="cf_sql_date" value="#arguments.new_x.birthday#">
                </cfif>
            )
        </cfquery>

        <!--- Return success response for insert --->
        <cfset result.new_contactid = result.generatedKey />
        <cfset result.success = true>
        <cfset result.message = "Record inserted successfully.">
        <cfset result.status = "Added">
    </cfif>
<cfset var newContactId = result.new_contactid>
    <!--- Update the importcontacts table --->
    <cfquery name="updateImportContacts">
        UPDATE contactsimport
        SET 
            contactid = <cfqueryparam value="#newContactId#" cfsqltype="cf_sql_integer">,
            status = <cfqueryparam value="#result.status#" cfsqltype="cf_sql_varchar">
        WHERE id = <cfqueryparam value="#arguments.new_x.new_id#" cfsqltype="cf_sql_integer">
    </cfquery>

    <!--- Return the final result --->
    <cfreturn result>
</cffunction>




<cffunction output="false" name="SELcontactdetails_24433" access="public" returntype="query">
    <cfargument name="userId" type="numeric" required="true">
    <cfargument name="selectContactId" type="numeric" required="false" default="0">

<cfquery name="result" >
            SELECT contactid, recordname
            FROM contactdetails
            WHERE userid = <cfqueryparam value="#arguments.userId#" cfsqltype="CF_SQL_INTEGER">
            <cfif arguments.selectContactId neq 0>
                AND contactid = <cfqueryparam value="#arguments.selectContactId#" cfsqltype="CF_SQL_INTEGER">
            </cfif>
            ORDER BY contactid
        </cfquery>

<cfreturn result>
</cffunction>
<cffunction output="false" name="SELcontactdetails_24483" access="public" returntype="query" hint="Legacy wrapper - delegates to list() with Active filter">
    <cfargument name="userid" type="numeric" required="true">

    <!--- Thin wrapper: map arguments to filtersStruct and delegate to list() --->
    <cfset var filtersStruct = {
        userid: arguments.userid,
        contactStatus: "Active",
        orderBy: "contactfullname",
        orderDir: "ASC"
    }>

    <!--- list() returns standard columns; this needs contactid and recordname --->
    <!--- For specific column selection, fall back to direct query to maintain legacy behavior --->
    <cfquery name="result" >
        SELECT
            d.contactid,
            d.recordname
        FROM
            contactdetails d
        WHERE
            d.contactStatus = <cfqueryparam value="Active" cfsqltype="CF_SQL_VARCHAR">
            AND d.userid = <cfqueryparam value="#arguments.userid#" cfsqltype="CF_SQL_INTEGER">
        ORDER BY
            d.contactfullname
    </cfquery>

    <cfreturn result>
</cffunction>

<cffunction output="false" name="SELcontactdetails_24515" access="public" returntype="query">
    <cfargument name="userid" type="numeric" required="true">
    <cfargument name="audprojectid" type="numeric" required="true">

<cfquery name="result" >
            SELECT DISTINCT 
                d.contactid, 
                d.recordname AS contactname, 
                d.contactStatus 
            FROM 
                contactdetails d 
            WHERE 
                d.userid = <cfqueryparam value="#arguments.userid#" cfsqltype="CF_SQL_INTEGER"> 
                AND d.contactid NOT IN (
                    SELECT contactid 
                    FROM audcontacts_auditions_xref 
                    WHERE audprojectid = <cfqueryparam value="#arguments.audprojectid#" cfsqltype="CF_SQL_INTEGER">
                )  
            ORDER BY 
                d.recordname
        </cfquery>

<cfreturn result>
</cffunction>
<cffunction output="false" name="INScontactdetails_24537" access="public" returntype="numeric">
    <cfargument name="userid" type="numeric" required="true">
    <cfargument name="cdfullname" type="string" required="true">

<cfquery result="result" >
            INSERT INTO contactdetails (userid, cdco) 
            VALUES (
                <cfqueryparam value="#arguments.userid#" cfsqltype="CF_SQL_INTEGER">, 
                <cfqueryparam value="#arguments.cdfullname#" cfsqltype="CF_SQL_VARCHAR">
            )
        </cfquery>

<cfreturn result.generatedKey>
</cffunction>
<cffunction output="false" name="SELcontactdetails_24617" access="public" returntype="query">
    <cfargument name="userId" type="numeric" required="true">

<cfquery name="result" >
            SELECT 
                datediff(d.contactbirthday, curdate()) AS daysuntil, 
                d.contactfullname AS col1, 
                d.contactid, 
                DATE_FORMAT(d.contactbirthday, '%m-%d') AS col2 
            FROM 
                contactdetails d 
            WHERE 
                d.userid = <cfqueryparam value="#arguments.userId#" cfsqltype="CF_SQL_INTEGER"> 
                AND d.contactbirthday IS NOT NULL 
                AND datediff(d.contactbirthday, curdate()) < 15 
            ORDER BY 
                datediff(d.contactbirthday)
        </cfquery>

<cfreturn result>
</cffunction>
<cffunction output="false" name="DETcontactdetails_24624" access="public" returntype="query">
    <cfargument name="contactid" type="numeric" required="true">

<cfquery name="result" >
    SELECT 
        d.contactid, 
        d.contacttitle, 
        d.recordname, 
        d.contactmeetingdate, 
        d.contactmeetingloc, 
        d.refer_contact_id, 
        d.contactFullName AS fullname, 
        d.contactfullname, 
        d.contactNickname, 
        d.contactID, 
        d.userID, 
        d.contactStatus, 
        d.contactCreationDate, 
        d.contactLastUpdated, 
        d.contactphoto, 
        d.contactBirthday, 
        d.contactPronoun, 
        d.newsletter_yn, 
        d.googlealert_yn, 
        d.socialmedia_yn,
        d2.contactFullName AS referDetailsFullname  
    FROM contactdetails d
    INNER JOIN taousers u ON u.userid = d.userid
    LEFT JOIN contactdetails d2 ON d.refer_contact_id = d2.contactid  
    WHERE d.contactID = <cfqueryparam value="#arguments.contactid#" cfsqltype="CF_SQL_INTEGER">
</cfquery>

<cfreturn result>

</cffunction>
<cffunction output="false" name="DETcontactdetails_24625" access="public" returntype="query">
    <cfargument name="refer_contact_id" type="numeric" required="true">

<cfquery name="result" >
            SELECT 
                d.contactid, 
                d.contacttitle, 
                d.recordname, 
                d.contactmeetingdate, 
                d.contactmeetingloc, 
                d.refer_contact_id, 
                d.contactFullName AS fullname, 
                d.contactNickname, 
                d.contactID, 
                d.userID, 
                d.contactStatus, 
                d.contactCreationDate, 
                d.contactLastUpdated, 
                d.contactphoto, 
                d.contactBirthday, 
                d.contactPronoun
            FROM contactdetails d
            INNER JOIN taousers u ON u.userid = d.userid
            WHERE d.contactID = <cfqueryparam value="#arguments.refer_contact_id#" cfsqltype="CF_SQL_INTEGER">
        </cfquery>

<cfreturn result>
</cffunction>
<cffunction output="false" name="REScontactdetails" access="public" returntype="query">
    <cfargument name="userId" type="numeric" required="true">

<cfquery name="result" >
            SELECT 
                d.contactid, 
                d.recordname AS col1 
            FROM 
                contactdetails d 
            WHERE 
                d.contactstatus = 'Active' 
                AND d.userid = <cfqueryparam value="#arguments.userId#" cfsqltype="CF_SQL_INTEGER"> 
            ORDER BY 
                d.contactfullname
        </cfquery>

<cfreturn result>
</cffunction>
<cffunction output="false" name="DETcontactdetails_24629" access="public" returntype="query">
    <cfargument name="refer_contact_id" type="numeric" required="true">

<cfquery name="result" >
            SELECT 
                d.contactid, 
                d.contacttitle, 
                d.recordname, 
                d.contactmeetingdate, 
                d.contactmeetingloc, 
                d.refer_contact_id, 
                d.contactFullName AS fullname, 
                d.contactfullname, 
                d.contactNickname, 
                d.contactID, 
                d.userID, 
                d.contactStatus, 
                d.contactCreationDate, 
                d.contactLastUpdated, 
                d.contactphoto, 
                d.contactBirthday, 
                d.contactPronoun
            FROM contactdetails d
            INNER JOIN taousers u ON u.userid = d.userid
            WHERE d.contactID = <cfqueryparam value="#arguments.refer_contact_id#" cfsqltype="CF_SQL_INTEGER">
        </cfquery>

<cfreturn result>
</cffunction>
<cffunction output="false" name="SELcontactdetails_24674" access="public" returntype="query">
    <cfargument name="userId" type="numeric" required="true">
    <cfargument name="compId" type="numeric" required="true">

<cfquery name="result" >
            SELECT 
                d.contactid, 
                'Name' AS head1, 
                'Last Update' AS head2, 
                d.contactfullname AS col1, 
                MAX(u.updatetimestamp) AS col2 
            FROM 
                contactdetails d 
            INNER JOIN 
                updatelog u ON u.recid = d.contactid 
            WHERE 
                d.contactStatus = 'Active' 
                AND d.userid = <cfqueryparam value="#arguments.userId#" cfsqltype="CF_SQL_INTEGER"> 
                AND u.userid = d.userid 
                AND u.compid = <cfqueryparam value="#arguments.compId#" cfsqltype="CF_SQL_INTEGER"> 
            GROUP BY 
                d.contactfullname
        </cfquery>

<cfreturn result>
</cffunction>

<cffunction output="false" name="SELcontactdetails_24683" access="public" returntype="query">
    <cfargument name="userId" type="numeric" required="true">

<cfquery name="result" >
            SELECT 
                d.contactid, 
                d.recordname AS contactname, 
                d.contactStatus 
            FROM 
                contactdetails d 
            INNER JOIN 
                taousers u ON u.userid = d.userid 
            WHERE 
                u.userid = <cfqueryparam value="#arguments.userId#" cfsqltype="CF_SQL_INTEGER"> 
                AND d.contactStatus = <cfqueryparam value="Active" cfsqltype="CF_SQL_VARCHAR"> 
                AND d.contactid IN (
                    SELECT contactid 
                    FROM contactitems 
                    WHERE valuetext = <cfqueryparam value="My Team" cfsqltype="CF_SQL_VARCHAR"> 
                    AND valuecategory = <cfqueryparam value="Tag" cfsqltype="CF_SQL_VARCHAR">
                    and isDeleted = 0
                ) 
            ORDER BY 
                d.contactfullname
        </cfquery>

<cfreturn result>
</cffunction>

<cffunction output="false" name="GetMyTeam" access="public" returntype="query">
    <cfargument name="userId" type="numeric" required="true">

<cfquery name="result" >
            SELECT 
                d.contactid, 
                d.col1 AS card_name,
                d.col4 as card_email,
                d.col3 as card_phone,
                d.col5 as card_company,
               (
        SELECT 
            contactitems.valueText 
        FROM 
            contactitems 
        WHERE 
            contactitems.valueCategory = 'Tag'  
      
            AND contactitems.contactID = d.contactID 
            AND contactitems.itemStatus = 'Active' 
        LIMIT 1
    ) AS card_title
            FROM 
                contacts_ss d 
            INNER JOIN 
                taousers u ON u.userid = d.userid 
            WHERE 
                u.userid = <cfqueryparam value="#arguments.userId#" cfsqltype="CF_SQL_INTEGER"> 
                
                AND d.contactid IN (
                    SELECT contactid 
                    FROM contactitems 
                    WHERE valuetext = <cfqueryparam value="My Team" cfsqltype="CF_SQL_VARCHAR"> 
                    AND valuecategory = <cfqueryparam value="Tag" cfsqltype="CF_SQL_VARCHAR">
                    and isDeleted = 0
                ) 
            ORDER BY 
                d.col1
        </cfquery>

<cfreturn result>
</cffunction>

<cffunction output="false" name="getContactsByAudProject" access="public" returntype="query">
    <cfargument name="audprojectid" type="numeric" required="true">

<cfquery name="result" >
      SELECT distinct 
                d.contactid, 
                d.col1 AS contactname, 
                d.avatar,
                d.hlink,
                d.col1 AS card_name,
                d.col4 as card_email,
                d.col3 as card_phone,
                d.col5 as card_company,
                (
        SELECT 
            contactitems.valueText 
        FROM 
            contactitems 
        WHERE 
            contactitems.valueCategory = 'Tag'  
            AND contactitems.contactID = d.contactID 
            AND contactitems.itemStatus = 'Active' 
        LIMIT 1
    ) AS card_title
       
            FROM 
                contacts_ss d 
            INNER JOIN 
                taousers u ON u.userid = d.userid 
                INNER JOIN 
                audcontacts_auditions_xref x ON x.contactid = d.contactid 
            WHERE 
            x.audprojectid = <cfqueryparam value="#arguments.audprojectid#" cfsqltype="CF_SQL_INTEGER">              
                  AND d.contactid IN (
                    SELECT contactid 
                    FROM contactitems 
                    where valuecategory = 'Tag'
                    and isDeleted = 0
                ) 
      
                
            ORDER BY 
                d.col1
        </cfquery>

<cfreturn result>
</cffunction>

<cffunction output="false" name="getContactForCard" access="public" returntype="query">
    <cfargument name="newContactID" type="numeric" required="true">

<cfquery name="newContact" >
            SELECT 
                d.contactid, 
                d.col1 AS card_name,
                d.col4 as card_email,
                d.col3 as card_phone,
                d.col5 as card_company,
               (
        SELECT 
            contactitems.valueText 
        FROM 
           contactitems 
        WHERE 
            contactitems.valueCategory = 'Tag'  
            AND contactitems.valueText <> 'My Team'
            AND contactitems.contactID = d.contactID 
            AND contactitems.itemStatus = 'Active' 
        LIMIT 1
    ) AS card_title
            FROM 
                contacts_ss d 
            INNER JOIN 
                taousers u ON u.userid = d.userid 
            WHERE 
                u.userid = <cfqueryparam value="#arguments.userId#" cfsqltype="CF_SQL_INTEGER"> 
                
                AND d.contactid IN (
                    SELECT contactid 
                    FROM contactitems 
                    WHERE valuetext = <cfqueryparam value="My Team" cfsqltype="CF_SQL_VARCHAR"> 
                    AND valuecategory = <cfqueryparam value="Tag" cfsqltype="CF_SQL_VARCHAR">
                    and isDeleted = 0
                ) 
            ORDER BY 
                d.col1
        </cfquery>

<cfreturn result>
</cffunction>

<cffunction output="false" name="DETcontactdetails_24685" access="public" returntype="query">
    <cfargument name="rcontactid" type="numeric" required="true">

<cfquery name="result" >
            SELECT 
                d.contactid, 
                d.contacttitle, 
                d.recordname, 
                d.contactmeetingdate, 
                d.contactmeetingloc, 
                d.refer_contact_id, 
                d.contactFullName AS fullname, 
                d.contactNickname, 
                d.contactID, 
                d.userID, 
                d.contactStatus, 
                d.contactCreationDate, 
                d.contactLastUpdated, 
                d.contactphoto, 
                d.contactBirthday, 
                d.contactPronoun, 
                d.newsletter_yn, 
                d.googlealert_yn, 
                d.socialmedia_yn
            FROM contactdetails d
            INNER JOIN taousers u ON u.userid = d.userid
            WHERE d.contactID = <cfqueryparam value="#arguments.rcontactid#" cfsqltype="CF_SQL_INTEGER">
        </cfquery>

<cfreturn result>
</cffunction>
</cfcomponent>
