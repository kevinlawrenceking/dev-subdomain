<cfcomponent displayname="LookupService" hint="Handles operations for lookups">

    <!--- Function to fetch tags based on a search term --->
    <cffunction name="getTags" access="public" returntype="query" output="false" hint="Fetches tags for a given user ID and search term.">
        <cfargument name="userid" type="numeric" required="true" hint="The user ID to filter tags.">
        <cfargument name="searchTerm" type="string" required="true" hint="The term to search for in tag names.">

        <cfquery name="tagData">
            SELECT 
                tagname AS col1, 
                tagname AS id
            FROM 
                tags_user
            WHERE 
                userid = <cfqueryparam value="#arguments.userid#" cfsqltype="CF_SQL_INTEGER">
                AND LOWER(tagname) LIKE LOWER(<cfqueryparam value="%#arguments.searchTerm#%" cfsqltype="CF_SQL_VARCHAR">)
            ORDER BY 
                tagname
        </cfquery>

        <cfreturn tagData>
    </cffunction>

    <!--- Function to fetch contacts based on a search term --->
    <cffunction name="getContacts" access="public" returntype="query" output="false" hint="Fetches contacts for a given user ID and search term.">
        <cfargument name="userid" type="numeric" required="true" hint="The user ID to filter contacts.">
        <cfargument name="searchTerm" type="string" required="true" hint="The term to search for in contact names.">

        <cfquery name="contactData">
            SELECT 
                recordname AS col1, 
                contactid AS id
            FROM 
                contactdetails
            WHERE 
                userid = <cfqueryparam value="#arguments.userid#" cfsqltype="CF_SQL_INTEGER">
                AND LOWER(recordname) LIKE LOWER(<cfqueryparam value="%#arguments.searchTerm#%" cfsqltype="CF_SQL_VARCHAR">)
            ORDER BY 
                recordname
        </cfquery>

        <cfreturn contactData>
    </cffunction>

        <!--- Function to fetch contacts based on a search term --->
    <cffunction name="getContactsNotTeam" access="public" returntype="query" output="false" hint="Fetches contacts for a given user ID and search term.">
        <cfargument name="userid" type="numeric" required="true" hint="The user ID to filter contacts.">
        <cfargument name="searchTerm" type="string" required="true" hint="The term to search for in contact names.">

        <cfquery name="contactData">
            SELECT 
                recordname AS col1, 
                contactid AS id
            FROM 
                contactdetails
            WHERE 
                userid = <cfqueryparam value="#arguments.userid#" cfsqltype="CF_SQL_INTEGER">
                AND LOWER(recordname) LIKE LOWER(<cfqueryparam value="%#arguments.searchTerm#%" cfsqltype="CF_SQL_VARCHAR">)
          AND contactid NOT in 

          (
select contactitems.contactid 
FROM 
            contactitems 
            inner  join contactdetails d on d.contactid = contactitems.contactid 
        WHERE 
            contactitems.valueCategory = 'Tag'  
            AND contactitems.valueText = 'My Team'
            AND contactitems.contactID = d.contactID 
            AND contactitems.itemStatus = 'Active'
            and d.userid =  <cfqueryparam value="#arguments.userid#" cfsqltype="CF_SQL_INTEGER">

          )
          
            ORDER BY 
                recordname
        </cfquery>

        <cfreturn contactData>
    </cffunction>

    <!--- Function to fetch upcoming events based on a search term --->
    <cffunction name="getAppointments" access="public" returntype="query" output="false" hint="Fetches upcoming events for a given user ID and search term.">
        <cfargument name="userid" type="numeric" required="true" hint="The user ID to filter events.">
        <cfargument name="searchTerm" type="string" required="true" hint="The term to search for in contact names associated with events.">

        <cfquery name="appointmentData">
            SELECT 
                e.eventid AS id, 
                CONCAT(DATE_FORMAT(e.eventstart, '%m/%d/%Y'), ": ", c.recordname, " - ", e.eventtitle) AS col1
            FROM 
                events e
            INNER JOIN 
                eventtypes_user t ON t.eventtypename = e.eventtypename
            INNER JOIN 
                eventcontactsxref x ON x.eventID = e.eventid
            INNER JOIN 
                contactdetails c ON c.contactid = x.contactid
            WHERE 
                e.userid = <cfqueryparam value="#arguments.userid#" cfsqltype="CF_SQL_INTEGER">
                AND t.userid = <cfqueryparam value="#arguments.userid#" cfsqltype="CF_SQL_INTEGER">
                AND e.eventstart >= CURDATE()
                AND LOWER(c.recordname) LIKE LOWER(<cfqueryparam value="%#arguments.searchTerm#%" cfsqltype="CF_SQL_VARCHAR">)
        </cfquery>

        <cfreturn appointmentData>
    </cffunction>

</cfcomponent>
