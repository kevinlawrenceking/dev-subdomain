<cfcomponent displayname="ContactImportService" hint="Handles operations for ContactImport table" >

<cffunction name="UPDCONTACTSIMPORT" access="public" returntype="void" output="false">
    <!--- Arguments --->
    <cfargument name="new_status" type="string" required="true">
    <cfargument name="new_contactid" type="numeric" required="true">
    <cfargument name="id" type="numeric" required="true">


        <cfquery  name="update">
            UPDATE CONTACTSIMPORT
            SET status = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.new_status#">,
                contactid = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.new_contactid#">
            WHERE id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.id#">
        </cfquery>

</cffunction>



<cffunction name="DETcontactsimport" access="public" returntype="query" output="false">

    <cfargument name="uploadid" type="numeric" required="true">


    <cfquery name="result" >
        SELECT contactid
        FROM contactsimport
        WHERE uploadid = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.uploadid#">
          AND status = <cfqueryparam cfsqltype="cf_sql_varchar" value="Added">
    </cfquery>
 --->
    <cfreturn result>
</cffunction>



<cffunction name="SELcontactsimport_24409" access="public" returntype="query" output="false">
    <!--- Arguments --->
    <cfargument name="uploadid" type="numeric" required="true">

    <!--- Local variable to hold the query result --->
    <cfset var result = "">

    <!--- Query to fetch data with additional filters --->
    <cfquery name="result" >
        SELECT 
            ID, fname, lname, tag, business_email, personal_email, 
            work_phone, mobile_phone, home_phone, company, address, 
            address_second, city, state, zip, country, maintenance_or_target, 
            contactMeetingDate, contactMeetingLoc, birthday, website, status, 
            contactid, uploadnotes, timestamp, uploadid, tag1, tag2, tag3, notes
        FROM contactsimport
        WHERE uploadid = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.uploadid#">
        and status = 'Added'
        and business_email <> '' and business_email is not null
    </cfquery>

    <!--- Return the query result --->
    <cfreturn result>
</cffunction>

<cffunction name="SELcontactsimport_f" access="public" returntype="query" output="false">
    <!--- Arguments --->
    <cfargument name="uploadid" type="numeric" required="true">

    <!--- Local variable to hold the query result --->
    <cfset var result = "">

    <!--- Query to fetch data with additional filters --->
    <cfquery name="result" >
        SELECT 
            ID, fname, lname, tag, business_email, personal_email, 
            work_phone, mobile_phone, home_phone, company, address, 
            address_second, city, state, zip, country, maintenance_or_target, 
            contactMeetingDate, contactMeetingLoc, birthday, website, status, 
            contactid, uploadnotes, timestamp, uploadid, tag1, tag2, tag3, notes
        FROM contactsimport
        WHERE uploadid = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.uploadid#">
        and status = 'Added'
        and personal_email <> '' and personal_email is not null
    </cfquery>

    <!--- Return the query result --->
    <cfreturn result>
</cffunction>

<cffunction name="SELcontactsimport_g" access="public" returntype="query" output="false">
    <!--- Arguments --->
    <cfargument name="uploadid" type="numeric" required="true">

    <!--- Local variable to hold the query result --->
    <cfset var result = "">

    <!--- Query to fetch data with additional filters --->
    <cfquery name="result" >
        SELECT 
            ID, fname, lname, tag, business_email, personal_email, 
            work_phone, mobile_phone, home_phone, company, address, 
            address_second, city, state, zip, country, maintenance_or_target, 
            contactMeetingDate, contactMeetingLoc, birthday, website, status, 
            contactid, uploadnotes, timestamp, uploadid, tag1, tag2, tag3, notes
        FROM contactsimport
        WHERE uploadid = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.uploadid#">
        and status = 'Added'
        and work_phone <> '' and work_phone is not null
    </cfquery>

    <!--- Return the query result --->
    <cfreturn result>
</cffunction>

<cffunction name="SELcontactsimport_h" access="public" returntype="query" output="false">
    <!--- Arguments --->
    <cfargument name="uploadid" type="numeric" required="true">

    <!--- Local variable to hold the query result --->
    <cfset var result = "">

    <!--- Query to fetch data with additional filters --->
    <cfquery name="result" >
        SELECT 
            ID, fname, lname, tag, business_email, personal_email, 
            work_phone, mobile_phone, home_phone, company, address, 
            address_second, city, state, zip, country, maintenance_or_target, 
            contactMeetingDate, contactMeetingLoc, birthday, website, status, 
            contactid, uploadnotes, timestamp, uploadid, tag1, tag2, tag3, notes
        FROM contactsimport
        WHERE uploadid = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.uploadid#">
        and status = 'Added'
        and mobile_phone <> '' and mobile_phone is not null
    </cfquery>

    <!--- Return the query result --->
    <cfreturn result>
</cffunction>

<cffunction name="SELcontactsimport_i" access="public" returntype="query" output="false">
    <!--- Arguments --->
    <cfargument name="uploadid" type="numeric" required="true">

    <!--- Local variable to hold the query result --->
    <cfset var result = "">

    <!--- Query to fetch data with additional filters --->
    <cfquery name="result" >
        SELECT 
            ID, fname, lname, tag, business_email, personal_email, 
            work_phone, mobile_phone, home_phone, company, address, 
            address_second, city, state, zip, country, maintenance_or_target, 
            contactMeetingDate, contactMeetingLoc, birthday, website, status, 
            contactid, uploadnotes, timestamp, uploadid, tag1, tag2, tag3, notes
        FROM contactsimport
        WHERE uploadid = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.uploadid#">
        and status = 'Added'
        and home_phone <> '' and home_phone is not null
    </cfquery>

    <!--- Return the query result --->
    <cfreturn result>
</cffunction>

<cffunction name="SELcontactsimport_j" access="public" returntype="query" output="false">
    <!--- Arguments --->
    <cfargument name="uploadid" type="numeric" required="true">

    <!--- Local variable to hold the query result --->
    <cfset var result = "">

    <!--- Query to fetch data with additional filters --->
    <cfquery name="result" >
        SELECT 
            ID, fname, lname, tag, business_email, personal_email, 
            work_phone, mobile_phone, home_phone, company, address, 
            address_second, city, state, zip, country, maintenance_or_target, 
            contactMeetingDate, contactMeetingLoc, birthday, website, status, 
            contactid, uploadnotes, timestamp, uploadid, tag1, tag2, tag3, notes
        FROM contactsimport
        WHERE uploadid = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.uploadid#">
        and status = 'Added'
        and Company <> '' and Company is not null
    </cfquery>

    <!--- Return the query result --->
    <cfreturn result>
</cffunction>

<cffunction name="SELcontactsimport_u" access="public" returntype="query" output="false">
    <!--- Arguments --->
    <cfargument name="uploadid" type="numeric" required="true">

    <!--- Local variable to hold the query result --->
    <cfset var result = "">

    <!--- Query to fetch data with additional filters --->
    <cfquery name="result" >
        SELECT 
            ID, fname, lname, tag, business_email, personal_email, 
            work_phone, mobile_phone, home_phone, company, address, 
            address_second, city, state, zip, country, maintenance_or_target, 
            contactMeetingDate, contactMeetingLoc, birthday, website, status, 
            contactid, uploadnotes, timestamp, uploadid, tag1, tag2, tag3, notes
        FROM contactsimport
        WHERE uploadid = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.uploadid#">
        and status = 'Added'
        and website <> '' and website is not null
    </cfquery>

    <!--- Return the query result --->
    <cfreturn result>
</cffunction>

<cffunction name="SELcontactsimport_address" access="public" returntype="query" output="false">
    <!--- Arguments --->
    <cfargument name="uploadid" type="numeric" required="true">

    <!--- Local variable to hold the query result --->
    <cfset var result = "">

    <!--- Query to fetch data with additional filters --->
    <cfquery name="result" >
        SELECT 
            ID, fname, lname, tag, business_email, personal_email, 
            work_phone, mobile_phone, home_phone, company, address, 
            address_second, city, state, zip, country, maintenance_or_target, 
            contactMeetingDate, contactMeetingLoc, birthday, website, status, 
            contactid, uploadnotes, timestamp, uploadid, tag1, tag2, tag3, notes
        FROM contactsimport
        WHERE uploadid = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.uploadid#">
        and status = 'Added'
    </cfquery>

    <!--- Return the query result --->
    <cfreturn result>
</cffunction>

<cffunction name="SELcontactsimport_maints" access="public" returntype="query" output="false">
    <!--- Arguments --->
    <cfargument name="uploadid" type="numeric" required="true">

    <!--- Local variable to hold the query result --->
    <cfset var result = "">

    <!--- Query to fetch data with additional filters --->
    <cfquery name="result" >
        SELECT 
            ID, fname, lname, tag, business_email, personal_email, 
            work_phone, mobile_phone, home_phone, company, address, 
            address_second, city, state, zip, country, maintenance_or_target, 
            contactMeetingDate, contactMeetingLoc, birthday, website, status, 
            contactid, uploadnotes, timestamp, uploadid, tag1, tag2, tag3, notes
        FROM contactsimport
        WHERE uploadid = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.uploadid#">
        and maintenance_or_target = 'Maintenance'
        and status = 'Added'
        and contactid is not null
    </cfquery>

    <!--- Return the query result --->
    <cfreturn result>
</cffunction>

<cffunction name="getContactsImport" access="public" returntype="query" output="false">
    <!--- Arguments --->
    <cfargument name="uploadid" type="numeric" required="true">

    <cfquery name="result" >
        SELECT 
            ID, fname, lname, tag, business_email, personal_email, 
            work_phone, mobile_phone, home_phone, company, address, 
            address_second, city, state, zip, country, maintenance_or_target, 
            contactMeetingDate, contactMeetingLoc, birthday, website, status, 
            contactid, uploadnotes, timestamp, uploadid, tag1, tag2, tag3, notes
        FROM contactsimport
        WHERE uploadid = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.uploadid#">
        and fname <> ''
    </cfquery>

    <cfreturn result>
</cffunction>

<cffunction name="getcontactsImportTag" access="public" returntype="query" output="false">

    <cfargument name="uploadid" type="numeric" required="true">
 <cfargument name="tag_label" type="string" required="true">

    <cfset var result = "">


    <cfquery name="result" >
        SELECT 
            ID, fname, lname, tag, business_email, personal_email, 
            work_phone, mobile_phone, home_phone, company, address, 
            address_second, city, state, zip, country, maintenance_or_target, 
            contactMeetingDate, contactMeetingLoc, birthday, website, status, 
            contactid, uploadnotes, timestamp, uploadid, tag1, tag2, tag3, notes
        FROM contactsimport
        WHERE uploadid = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.uploadid#">
        
          AND #arguments.tag_label# <> ''
          AND  #arguments.tag_label# IS NOT NULL
    </cfquery>

    <cfreturn result>
</cffunction>



<cffunction output="false" name="getImportsByUserID" access="public" returntype="query"  hint="Retrieve import data for a specific user.">
        <cfargument name="userid" type="numeric" required="true" hint="The ID of the user to fetch import data for.">

<cfquery result="result" name="imports">
            SELECT 
                u.uploadid,
                u.`timestamp`,
                u.userid,
                u.uploadstatus,
                i.status,
                COUNT(i.ID) AS total_adds
            FROM 
                contactsimport i 
            INNER JOIN 
                uploads u ON u.uploadid = i.uploadid
            INNER JOIN 
                contactdetails d ON d.contactid = i.contactid
            WHERE 
                u.userid = <cfqueryparam value="#arguments.userid#" cfsqltype="cf_sql_integer">
                AND u.isdeleted = 0
            GROUP BY 
                u.uploadid,
                u.timestamp,
                u.userid,
                u.uploadstatus,
                i.status
        </cfquery>

<cfreturn imports>
    </cffunction>

<cffunction output="false" name="SELcontactsimport_24668" access="public" returntype="query">
        <cfargument name="userid" type="numeric" required="true">

<cfquery name="result">
            SELECT 
                u.uploadid, 
                u.`timestamp`, 
                u.userid, 
                u.uploadstatus, 
                i.status, 
                COUNT(i.ID) AS total_adds
            FROM 
                contactsimport i
            INNER JOIN 
                uploads u ON u.uploadid = i.uploadid
            INNER JOIN 
                contactdetails d ON d.contactid = i.contactid
            WHERE 
                u.userid = <cfqueryparam value="#arguments.userid#" cfsqltype="CF_SQL_INTEGER"> 
                AND u.isdeleted = 0
            GROUP BY 
                u.uploadid, u.timestamp, u.userid, u.uploadstatus, i.status
        </cfquery>

<cfreturn result>
    </cffunction>                                                                                       

<cffunction output="false" name="INScontactsimport" access="public" returntype="numeric">
    <!--- Arguments --->
    <cfargument name="importdata" type="query" required="true">
    <cfargument name="newuploadid" type="numeric" required="true">

    <!--- Local variables --->
    <cfset var rowCount = 0>
    <cfset var optionalFields = "" />
    <cfset var optionalValues = "" />
    <cfset var sqlStatement = "" />

        <!--- Loop through the import data query starting from row 2 ---> 
        <cfloop query="#arguments.importdata#" startrow="2">
            <!--- Validate row data: Ensure FirstName is present --->
            <cfif len(trim(importdata.FirstName))>

 
            

                <!--- Insert row into the database ---> 
                <cfquery name="insertContact">
                    INSERT INTO contactsimport (
                        uploadid, fname, lname, tag1, tag2, tag3,
                        business_email, personal_email, work_phone, 
                        mobile_phone, home_phone, company, address, 
                        address_second, city, state, zip, country,
                        website, status, notes
                     
      <cfif len(trim(importdata.contactMeetingDate))>
                        ,contactMeetingDate
</cfif>

      <cfif len(trim(importdata.contactMeetingLoc))>
                        , contactMeetingLoc
</cfif>

               <cfif len(trim(importdata.birthday))>            
                     , birthday
                     </cfif>
                    )
                    VALUES (
                        <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.newuploadid#">,
                        <cfqueryparam cfsqltype="cf_sql_varchar" maxlength="100" value="#trim(importdata.FirstName)#">,
                        <cfqueryparam cfsqltype="cf_sql_varchar" maxlength="100" value="#trim(importdata.LastName)#">,
                        <cfqueryparam cfsqltype="cf_sql_varchar" maxlength="100" value="#trim(importdata.Tag1)#">,
                        <cfqueryparam cfsqltype="cf_sql_varchar" maxlength="100" value="#trim(importdata.Tag2)#">,
                        <cfqueryparam cfsqltype="cf_sql_varchar" maxlength="100" value="#trim(importdata.Tag3)#">,
                        <cfqueryparam cfsqltype="cf_sql_varchar" maxlength="100" value="#trim(importdata.BusinessEmail)#">,
                        <cfqueryparam cfsqltype="cf_sql_varchar" maxlength="100" value="#trim(importdata.PersonalEmail)#">,
                        <cfqueryparam cfsqltype="cf_sql_varchar" maxlength="100" value="#trim(importdata.WorkPhone)#">,
                        <cfqueryparam cfsqltype="cf_sql_varchar" maxlength="100" value="#trim(importdata.MobilePhone)#">,
                        <cfqueryparam cfsqltype="cf_sql_varchar" maxlength="100" value="#trim(importdata.HomePhone)#">,
                        <cfqueryparam cfsqltype="cf_sql_varchar" maxlength="200" value="#trim(importdata.Company)#">,
                        <cfqueryparam cfsqltype="cf_sql_varchar" maxlength="200" value="#trim(importdata.Address)#">,
                        <cfqueryparam cfsqltype="cf_sql_varchar" maxlength="100" value="#trim(importdata.Address2)#">,
                        <cfqueryparam cfsqltype="cf_sql_varchar" maxlength="100" value="#trim(importdata.City)#">,
                        <cfqueryparam cfsqltype="cf_sql_varchar" maxlength="100" value="#trim(importdata.State)#">,
                        <cfqueryparam cfsqltype="cf_sql_varchar" maxlength="100" value="#trim(importdata.Zip)#">,
                        <cfqueryparam cfsqltype="cf_sql_varchar" maxlength="100" value="#trim(importdata.Country)#">,
                        <cfqueryparam cfsqltype="cf_sql_varchar" maxlength="200" value="#trim(importdata.website)#">,
                        <cfqueryparam cfsqltype="cf_sql_varchar" value="Pending">,
                        <cfqueryparam cfsqltype="cf_sql_longvarchar" value="#trim(importdata.Notes)#">

      <cfif len(trim(importdata.contactMeetingDate))>
                        ,'#dateformat(importdata.contactMeetingDate, "yyyy-mm-dd")#'
</cfif>

      <cfif len(trim(importdata.contactMeetingLoc))>
                        ,'#trim(importdata.contactMeetingLoc)#'
</cfif>

      <cfif len(trim(importdata.birthday))>
                        ,'#dateformat(importdata.birthday, "yyyy-mm-dd")#'
</cfif>


                    )
                </cfquery>

                <!--- Increment the row count ---> 
                <cfset rowCount++>
            </cfif>
        </cfloop>

        <!--- Return the number of successfully inserted rows ---> 
        <cfreturn rowCount>
 
</cffunction>



</cfcomponent>