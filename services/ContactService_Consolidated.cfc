<cfcomponent displayname="ContactService" hint="Consolidated service for contact operations">

<!--- Core CRUD functions --->

<cffunction name="create" access="public" returntype="numeric" output="false" hint="Create a contact with flexible parameters">
    <cfargument name="data" type="struct" required="true" hint="Contact data structure">
    
    <!--- Apply defaults if missing --->
    <cfparam name="arguments.data.isDeleted" default="false">
    
    <!--- Validate required fields --->
    <cfif NOT structKeyExists(arguments.data, "userid") OR NOT structKeyExists(arguments.data, "contactFullName")>
        <cfthrow message="Missing required fields: userid and contactFullName are required">
    </cfif>
    
    <!--- Build dynamic query --->
    <cfset var columns = []>
    <cfset var values = []>
    <cfset var sqlTypes = {}>
    
    <!--- Define field mappings and types --->
    <cfset var fieldMappings = {
        "userid": "CF_SQL_INTEGER",
        "contactFullName": "CF_SQL_VARCHAR",
        "contactMeetingLoc": "CF_SQL_VARCHAR",
        "contactPronoun": "CF_SQL_VARCHAR",
        "contactBirthday": "CF_SQL_DATE",
        "contactMeetingDate": "CF_SQL_DATE",
        "refer_contact_id": "CF_SQL_INTEGER",
        "user_yn": "CF_SQL_CHAR",
        "isDeleted": "CF_SQL_BIT"
    }>
    
    <!--- Process each field --->
    <cfloop collection="#arguments.data#" item="field">
        <cfif structKeyExists(fieldMappings, field) AND isDefined("arguments.data.#field#")>
            <cfset arrayAppend(columns, field)>
            <cfset arrayAppend(values, arguments.data[field])>
            <cfset sqlTypes[field] = fieldMappings[field]>
        </cfif>
    </cfloop>
    
    <!--- Execute dynamic insert --->
    <cftry>
        <cfquery name="qCreate" result="result">
            INSERT INTO contactdetails (
                #arrayToList(columns)#
            ) VALUES (
                <cfloop from="1" to="#arrayLen(values)#" index="i">
                    <cfif i gt 1>,</cfif>
                    <cfqueryparam value="#values[i]#" cfsqltype="#sqlTypes[columns[i]]#" 
                        null="#not isSimpleValue(values[i]) OR (isSimpleValue(values[i]) AND not len(trim(values[i])))#">
                </cfloop>
            )
        </cfquery>
        
        <cfcatch type="any">
            <cflog file="contactService" text="Error in create(): #cfcatch.message#">
            <cfthrow message="Failed to create contact" detail="#cfcatch.message#">
        </cfcatch>
    </cftry>
    
    <cfreturn result.generatedKey>
</cffunction>

<cffunction name="read" access="public" returntype="query" output="false" hint="Get contact details by ID">
    <cfargument name="contactid" type="numeric" required="true" hint="Contact ID">
    <cfargument name="includeFields" type="string" default="*" hint="Comma separated list of fields to include">
    
    <cftry>
        <cfquery name="qRead">
            SELECT #arguments.includeFields#
            FROM contactdetails
            WHERE contactid = <cfqueryparam value="#arguments.contactid#" cfsqltype="CF_SQL_INTEGER">
        </cfquery>
        
        <cfcatch type="any">
            <cflog file="contactService" text="Error in read(): #cfcatch.message#">
            <cfthrow message="Failed to read contact" detail="#cfcatch.message#">
        </cfcatch>
    </cftry>
    
    <cfreturn qRead>
</cffunction>

<cffunction name="update" access="public" returntype="void" output="false" hint="Update contact with flexible parameters">
    <cfargument name="contactid" type="numeric" required="true" hint="Contact ID to update">
    <cfargument name="data" type="struct" required="true" hint="Contact data structure">
    
    <!--- Build dynamic query --->
    <cfset var updates = []>
    <cfset var fieldMappings = {
        "contactFullName": "CF_SQL_VARCHAR",
        "contactMeetingLoc": "CF_SQL_VARCHAR",
        "contactPronoun": "CF_SQL_VARCHAR",
        "contactBirthday": "CF_SQL_DATE",
        "contactMeetingDate": "CF_SQL_DATE",
        "refer_contact_id": "CF_SQL_INTEGER",
        "user_yn": "CF_SQL_CHAR",
        "isDeleted": "CF_SQL_BIT"
    }>
    
    <cftry>
        <cfquery>
            UPDATE contactdetails
            SET 
                <cfloop collection="#arguments.data#" item="field">
                    <cfif structKeyExists(fieldMappings, field) AND isDefined("arguments.data.#field#")>
                        <cfif arrayLen(updates) GT 0>,</cfif>
                        #field# = <cfqueryparam value="#arguments.data[field]#" 
                                    cfsqltype="#fieldMappings[field]#"
                                    null="#not isSimpleValue(arguments.data[field]) OR 
                                          (isSimpleValue(arguments.data[field]) AND not len(trim(arguments.data[field])))#">
                        <cfset arrayAppend(updates, field)>
                    </cfif>
                </cfloop>
            WHERE contactid = <cfqueryparam value="#arguments.contactid#" cfsqltype="CF_SQL_INTEGER">
        </cfquery>
        
        <cfcatch type="any">
            <cflog file="contactService" text="Error in update(): #cfcatch.message#">
            <cfthrow message="Failed to update contact" detail="#cfcatch.message#">
        </cfcatch>
    </cftry>
</cffunction>

<cffunction name="list" access="public" returntype="query" output="false" hint="List contacts with flexible filtering">
    <cfargument name="filters" type="struct" default="#structNew()#" hint="Filter parameters">
    <cfargument name="sortField" type="string" default="contactFullName" hint="Field to sort by">
    <cfargument name="sortDirection" type="string" default="ASC" hint="Sort direction">
    <cfargument name="includeFields" type="string" default="*" hint="Fields to include">
    <cfargument name="maxRows" type="numeric" default="0" hint="Maximum rows to return (0 for all)">
    
    <cfset var whereClause = "">
    <cfset var params = []>
    
    <!--- Build WHERE clause dynamically --->
    <cfloop collection="#arguments.filters#" item="field">
        <cfif len(whereClause)>
            <cfset whereClause &= " AND ">
        </cfif>
        
        <cfif field EQ "search">
            <cfset whereClause &= "(contactFullName LIKE ? OR recordname LIKE ?)">
            <cfset arrayAppend(params, {value="%#arguments.filters[field]#%", cfsqltype="CF_SQL_VARCHAR"})>
            <cfset arrayAppend(params, {value="%#arguments.filters[field]#%", cfsqltype="CF_SQL_VARCHAR"})>
        <cfelse>
            <cfset whereClause &= "#field# = ?">
            <cfset arrayAppend(params, {value=arguments.filters[field], cfsqltype=getSqlType(field)})>
        </cfif>
    </cfloop>
    
    <cftry>
        <cfquery name="qList" maxrows="#arguments.maxRows#">
            SELECT #arguments.includeFields#
            FROM contactdetails
            <cfif len(whereClause)>WHERE #preserveSingleQuotes(whereClause)#</cfif>
            ORDER BY #arguments.sortField# #arguments.sortDirection#
            
            <!--- Bind parameters --->
            <cfloop array="#params#" index="param">
                <cfqueryparam value="#param.value#" cfsqltype="#param.cfsqltype#">
            </cfloop>
        </cfquery>
        
        <cfcatch type="any">
            <cflog file="contactService" text="Error in list(): #cfcatch.message#">
            <cfthrow message="Failed to list contacts" detail="#cfcatch.message#">
        </cfcatch>
    </cftry>
    
    <cfreturn qList>
</cffunction>

<cffunction name="delete" access="public" returntype="void" output="false" hint="Soft delete a contact">
    <cfargument name="contactid" type="any" required="true" hint="Contact ID or list of IDs">
    <cfargument name="hardDelete" type="boolean" default="false" hint="If true, permanently delete record">
    
    <cftry>
        <cfif arguments.hardDelete>
            <cfquery>
                DELETE FROM contactdetails
                WHERE contactid <cfif isArray(arguments.contactid) OR listLen(arguments.contactid) GT 1>
                    IN (<cfqueryparam value="#arguments.contactid#" cfsqltype="CF_SQL_INTEGER" list="true">)
                <cfelse>
                    = <cfqueryparam value="#arguments.contactid#" cfsqltype="CF_SQL_INTEGER">
                </cfif>
            </cfquery>
        <cfelse>
            <cfquery>
                UPDATE contactdetails
                SET isDeleted = 1
                WHERE contactid <cfif isArray(arguments.contactid) OR listLen(arguments.contactid) GT 1>
                    IN (<cfqueryparam value="#arguments.contactid#" cfsqltype="CF_SQL_INTEGER" list="true">)
                <cfelse>
                    = <cfqueryparam value="#arguments.contactid#" cfsqltype="CF_SQL_INTEGER">
                </cfif>
            </cfquery>
        </cfif>
        
        <cfcatch type="any">
            <cflog file="contactService" text="Error in delete(): #cfcatch.message#">
            <cfthrow message="Failed to delete contact" detail="#cfcatch.message#">
        </cfcatch>
    </cftry>
</cffunction>

<!--- Helper function to determine SQL type --->
<cffunction name="getSqlType" access="private" returntype="string" output="false">
    <cfargument name="fieldName" type="string" required="true">
    
    <cfset var typeMap = {
        "contactid": "CF_SQL_INTEGER",
        "userid": "CF_SQL_INTEGER",
        "contactFullName": "CF_SQL_VARCHAR",
        "contactMeetingLoc": "CF_SQL_VARCHAR",
        "contactPronoun": "CF_SQL_VARCHAR",
        "contactBirthday": "CF_SQL_DATE",
        "contactMeetingDate": "CF_SQL_DATE",
        "refer_contact_id": "CF_SQL_INTEGER",
        "isDeleted": "CF_SQL_BIT",
        "user_yn": "CF_SQL_CHAR"
    }>
    
    <cfreturn structKeyExists(typeMap, arguments.fieldName) ? typeMap[arguments.fieldName] : "CF_SQL_VARCHAR">
</cffunction>

<!--- Legacy function mappings with deprecation warnings --->

<!--- Example of migrated function with deprecation warning --->
<cffunction name="INScontactdetails_23839" access="public" returntype="numeric" output="false" hint="[DEPRECATED] Use create() instead">
    <cfargument name="userid" type="numeric" required="true">
    <cfargument name="contactfullname" type="string" default="Unknown">

    <cflog file="contactService" text="DEPRECATED: INScontactdetails_23839 called. Use create() instead.">
    
    <cfreturn create({
        "userid": arguments.userid,
        "contactFullName": arguments.contactfullname
    })>
</cffunction>

<!--- Example of another migrated function --->
<cffunction name="SELcontactdetails_23843" access="public" returntype="query" output="false" hint="[DEPRECATED] Use list() instead">
    <cfargument name="userid" type="numeric" required="true">
    <cfargument name="select_contactid" type="numeric" default="0">

    <cflog file="contactService" text="DEPRECATED: SELcontactdetails_23843 called. Use list() instead.">
    
    <cfif arguments.select_contactid NEQ 0>
        <cfreturn read(arguments.select_contactid, "contactid, recordname")>
    <cfelse>
        <cfreturn list({
            "userid": arguments.userid
        }, "contactid", "ASC", "contactid, recordname")>
    </cfif>
</cffunction>

<!--- Keep the existing functions you need --->

<!--- Existing function references... --->

</cfcomponent>
