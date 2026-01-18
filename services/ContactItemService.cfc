<cfcomponent displayname="ContactItemService" hint="Handles operations for ContactItem table" > 

<cffunction name="getContactTagStatus" access="public" returntype="string" output="false" hint="Checks contact tags and returns the appropriate system scope">
    <cfargument name="contactid" type="numeric" required="true" hint="The ID of the contact">
    <cfargument name="userid" type="numeric" required="true" hint="The ID of the user">

    <cfset var result = "" />

    <cfquery name="tagCheck" maxrows="1" >
       SELECT count(itemid) as totaltags
FROM contactitems
        WHERE valuecategory = <cfqueryparam value="Tag" cfsqltype="CF_SQL_VARCHAR">
          AND contactid = <cfqueryparam value="#arguments.contactid#" cfsqltype="CF_SQL_INTEGER">
          AND itemstatus = <cfqueryparam value="Active" cfsqltype="CF_SQL_VARCHAR">
          AND valuetext IN (
              SELECT tagname
              FROM tags_user
              WHERE userid = <cfqueryparam value="#arguments.userid#" cfsqltype="CF_SQL_INTEGER">
              AND tagtype = <cfqueryparam value="C" cfsqltype="CF_SQL_CHAR">
          )
    </cfquery>

<Cfif #tagcheck.totaltags# is "1">
<Cfset result = "Casting Director" />
<cfelse>
<Cfset result = "Industry" />
</cfif>


    <cfreturn result />
</cffunction>



<cffunction name="addTeam" access="public" returntype="void" output="false">
    <cfargument name="userid" type="numeric" required="true">
    <cfargument name="topsearch_myteam" type="string" required="true">
    <cfquery>
        INSERT INTO contactitems (contactid, valuetype, valuecategory, valuetext, itemstatus, primary_yn)
        SELECT 
            contactid,
            'Tags',
            'Tag',
            'My Team',
            'Active',
            'Y'
        FROM contacts_ss
        WHERE 
            userid = <cfqueryparam value="#arguments.userid#" cfsqltype="CF_SQL_INTEGER">
            AND col1 = <cfqueryparam value="#arguments.topsearch_myteam#" cfsqltype="CF_SQL_VARCHAR">
        LIMIT 1
    </cfquery>
</cffunction>
<cffunction name="deleteAudContact" access="public" returntype="void" output="false">
    <cfargument name="contactid" type="numeric" required="true">
     <cfargument name="audprojectid" type="numeric" required="true">
    <cfquery>
           DELETE from audcontacts_auditions_xref
            WHERE contactid = <cfqueryparam value="#arguments.contactid#" cfsqltype="CF_SQL_INTEGER">
            AND audprojectid = <cfqueryparam value="#arguments.audprojectid#" cfsqltype="CF_SQL_INTEGER">
    </cfquery>
</cffunction>

<cffunction name="deleteTeam" access="public" returntype="void" output="false">
    <cfargument name="contactid" type="numeric" required="true">
    <cfquery>
           DELETE from contactitems_tbl
            WHERE contactid = <cfqueryparam value="#arguments.contactid#" cfsqltype="CF_SQL_INTEGER">
            AND valuetext = 'My Team'
    </cfquery>
</cffunction>
<cffunction output="false" name="itemsByCatActive" access="public" returntype="struct">
    <!--- Define required arguments --->
    <cfargument name="contactid" type="numeric" required="true">
    <cfargument name="valueCategory" type="string" required="true">
    <cfargument name="catArea_UCB" type="string" required="true">

<!--- Query to fetch items by category with active status --->
    <cfquery result="result" name="itemsbycatActive">
        SELECT 
            i.itemID,
            i.valueType,
            i.valueCategory,
            i.valuetext,
            i.valueCompany,
            i.valuedepartment,
            i.valuetitle,
            i.valueStreetAddress,
            i.valueExtendedAddress,
            i.valueCity,
            i.valueRegion,
            i.itemDate,
            i.itemNotes,
            i.itemStatus,
            i.itemCreationDate,
            i.itemLastUpdated,
            i.valueCountry,
            c.catfieldset,
            c.caticon,
            i.valuepostalcode,
            i.primary_yn
        FROM contactitems i
        INNER JOIN itemcategory c ON c.valueCategory = i.valuecategory
        WHERE i.contactID = <cfqueryparam value="#arguments.contactid#" cfsqltype="cf_sql_integer">
          AND c.valuecategory = <cfqueryparam value="#arguments.valueCategory#" cfsqltype="cf_sql_varchar">
          AND i.itemstatus = 'Active'
          AND i.valuecategory <> 'Tag'
          AND c.catArea_UCB IN ('B', <cfqueryparam value="#arguments.catArea_UCB#" cfsqltype="cf_sql_varchar">)
        ORDER BY i.valuetext
    </cfquery>

<!--- Create struct to hold query and record count --->
    <cfset var resultStruct = structNew()>
    <cfset resultStruct.itemsbycatActive = itemsbycatActive>
    <cfset resultStruct.recordcount = itemsbycatActive.recordcount>

<cfreturn resultStruct>
</cffunction>

<!--- Function to retrieve active categories --->
    <cffunction output="false" name="getActiveCategories" access="remote" returntype="query"  hint="Get a list of active categories.">
        <cfquery result="result" name="ActiveCategories">
            SELECT 'Relationship' AS valueCategory, 'fe-users' AS caticon,'text' AS catFieldSet, 0 AS catid, 0 AS finalorder
            UNION
            SELECT DISTINCT
                c.valueCategory,
                c.caticon,
                c.catfieldset,
                c.catid,
                c.catOrder AS finalorder
            FROM itemcategory c
            WHERE c.valuecategory <> 'Tag'
            ORDER BY finalorder
        </cfquery>
        <!--- Return the query result --->
        <cfreturn ActiveCategories />
    </cffunction>

<!--- Function to retrieve inactive categories --->
    <cffunction output="false" name="getInactiveCategories" access="remote" returntype="query"  hint="Get a list of inactive categories.">
        <cfquery result="result" name="InactiveCategories">
            SELECT 'Relationship' AS valueCategory, 'fe-users' AS caticon,'text' AS catFieldSet, 0 AS catid, 0 AS finalorder
            UNION
            SELECT DISTINCT
                c.valueCategory,
                c.caticon,
                c.catfieldset,
                c.catid,
                c.catOrder AS finalorder
            FROM itemcategory c
            WHERE c.valuecategory <> 'Tag' AND c.catid = 0
            ORDER BY finalorder
        </cfquery>
        <!--- Return the query result --->
        <cfreturn InactiveCategories />
    </cffunction>

<cffunction output="false" name="SELfindscope_24712" access="public" returntype="string">
    <cfargument name="contactid" type="numeric" required="true">
    <cfargument name="userid" type="numeric" required="true">

<cfquery result="result" name="findscope"  maxrows="1">
        SELECT 
            CASE 
                WHEN EXISTS (
                    SELECT 1 
                    FROM contactitems 
                    WHERE valuecategory = 'Tag' 
                      AND contactid = <cfqueryparam value="#arguments.contactid#" cfsqltype="cf_sql_integer"> 
                      AND itemstatus = 'Active' 
                      AND valuetext IN (
                        SELECT tagname 
                        FROM tags_user 
                        WHERE userid = <cfqueryparam value="#arguments.userid#" cfsqltype="cf_sql_integer"> 
                          AND tagtype = 'C'
                      )
                ) THEN 'Casting Director'
                ELSE 'Industry'
            END AS new_systemscope
    </cfquery>

<cfreturn findscope.new_systemscope[1]>
</cffunction>

<cffunction output="false" name="SELcontactitems" access="public" returntype="query">
    <cfargument name="contactId" type="numeric" required="true">

<cfquery name="result" >
            SELECT 
                contactid, 
                itemid, 
                CONCAT(' <span class=''badge badge-blue''>', contactitems.valueText, '</span>') AS tag, 
                contactitems.valuetext
            FROM 
                contactitems
            WHERE 
                contactid = <cfqueryparam value="#arguments.contactId#" cfsqltype="CF_SQL_INTEGER"> 
                AND valueCategory = <cfqueryparam value="Tag" cfsqltype="CF_SQL_VARCHAR"> 
                AND valuetext <> ''
        </cfquery>

<cfreturn result>
</cffunction>
<cffunction output="false" name="SELcontactitems_23758" access="public" returntype="query">
    <cfargument name="contactID" type="numeric" required="true">

<cfquery name="result" >
            SELECT contactitems.valueText AS phone
            FROM contactitems
            WHERE contactitems.valueCategory = <cfqueryparam value="Phone" cfsqltype="CF_SQL_VARCHAR">
            AND contactitems.contactID = <cfqueryparam value="#arguments.contactID#" cfsqltype="CF_SQL_INTEGER">
            AND contactitems.itemStatus = <cfqueryparam value="Active" cfsqltype="CF_SQL_VARCHAR">
            ORDER BY contactitems.primary_YN DESC
            LIMIT 1
        </cfquery>

<cfreturn result>
</cffunction>
<cffunction output="false" name="SELcontactitems_23759" access="public" returntype="query">
    <cfargument name="contactID" type="numeric" required="true">

<cfquery name="result" >
            SELECT contactitems.valueText AS email
            FROM contactitems
            WHERE contactitems.valueCategory = <cfqueryparam value="Email" cfsqltype="CF_SQL_VARCHAR">
            AND contactitems.contactID = <cfqueryparam value="#arguments.contactID#" cfsqltype="CF_SQL_INTEGER">
            AND contactitems.itemStatus = <cfqueryparam value="Active" cfsqltype="CF_SQL_VARCHAR">
            ORDER BY contactitems.primary_YN DESC
            LIMIT 1
        </cfquery>

<cfreturn result>
</cffunction>
<cffunction output="false" name="INScontactitems" access="public" returntype="numeric">
    <cfargument name="new_contactid" type="numeric" required="true">
    <cfargument name="cdtype" type="string" required="true">

<cfquery result="result" >
            INSERT INTO CONTACTITEMS (CONTACTID, VALUETYPE, VALUECATEGORY, VALUETEXT, ITEMSTATUS)
            VALUES (
                <cfqueryparam value="#arguments.new_contactid#" cfsqltype="CF_SQL_INTEGER">,
                <cfqueryparam value="Tags" cfsqltype="CF_SQL_VARCHAR">,
                <cfqueryparam value="Tag" cfsqltype="CF_SQL_VARCHAR">,
                <cfqueryparam value="#arguments.cdtype#" cfsqltype="CF_SQL_VARCHAR">,
                <cfqueryparam value="Active" cfsqltype="CF_SQL_VARCHAR">
            )
        </cfquery>
        <cfreturn result.generatedKey>
</cffunction>
<cffunction output="false" name="INScontactitems_23771" access="public" returntype="numeric">
    <cfargument name="new_contactid" type="numeric" required="true">
    <cfargument name="cdco" type="string" required="true">

<cfquery result="result" >
            INSERT INTO CONTACTITEMS (CONTACTID, VALUETYPE, VALUECATEGORY, ValueCompany, ITEMSTATUS)
            VALUES (
                <cfqueryparam value="#arguments.new_contactid#" cfsqltype="CF_SQL_INTEGER">,
                <cfqueryparam value="Company" cfsqltype="CF_SQL_VARCHAR">,
                <cfqueryparam value="Company" cfsqltype="CF_SQL_VARCHAR">,
                <cfqueryparam value="#arguments.cdco#" cfsqltype="CF_SQL_VARCHAR">,
                <cfqueryparam value="Active" cfsqltype="CF_SQL_VARCHAR">
            )
        </cfquery>
<cfreturn result.generatedKey>
</cffunction>
<cffunction output="false" name="SELcontactitems_23840" access="public" returntype="query">
    <cfargument name="currentid" type="numeric" required="true">

<cfquery name="result" >
            SELECT i.itemid, c.catid, c.valuecategory
            FROM contactitems i
            INNER JOIN itemcategory c ON c.valuecategory = i.valuecategory
            WHERE contactid = <cfqueryparam value="#arguments.currentid#" cfsqltype="CF_SQL_INTEGER">
        </cfquery>

<cfreturn result>
</cffunction>
<cffunction output="false" name="SELcontactitems_23855" access="public" returntype="query">
    <cfargument name="contactid" type="numeric" required="true">

<cfquery name="result" >
            SELECT contactid, itemid, `contactitems`.`valueText` AS tag
            FROM contactitems
            WHERE contactid = <cfqueryparam value="#arguments.contactid#" cfsqltype="CF_SQL_INTEGER">
            AND valuetext <> <cfqueryparam value="My Team" cfsqltype="CF_SQL_VARCHAR">
            AND valuecategory = <cfqueryparam value="Tag" cfsqltype="CF_SQL_VARCHAR">
        </cfquery>



<cfreturn result>
</cffunction>
<cffunction output="false" name="DETcontactitems" access="public" returntype="query">
    <cfargument name="itemid" type="numeric" required="true">

<cfset var queryResult = "">

<cfquery result="result" name="queryResult" >
            SELECT 
                i.itemid, 
                i.contactid, 
                i.valueText 
            FROM 
                contactitems i 
            WHERE 
                i.itemid = <cfqueryparam value="#arguments.itemid#" cfsqltype="cf_sql_integer">
        </cfquery>

<cfreturn queryResult>
</cffunction>
<cffunction output="false" name="SELcontactitems_23889" access="public" returntype="query">
    <cfargument name="new_contactid" type="numeric" required="true">
    <cfset var queryResult = "">

<cfquery result="result" name="queryResult" >
            SELECT valuetext AS new_website 
            FROM contactitems 
            WHERE valuetype = <cfqueryparam cfsqltype="cf_sql_varchar" value="Company Website" />
            AND contactid = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.new_contactid#" />
            AND itemstatus = <cfqueryparam cfsqltype="cf_sql_varchar" value="Active" />
            AND valuecategory = <cfqueryparam cfsqltype="cf_sql_varchar" value="URL" />
        </cfquery>

<cfreturn queryResult>
</cffunction>
<cffunction output="false" name="SELcontactitems_23890" access="public" returntype="query">
    <cfargument name="new_contactid" type="numeric" required="true">

<cfquery name="result" >
            SELECT valuetext AS new_businessEmail 
            FROM contactitems 
            WHERE valuetype = <cfqueryparam cfsqltype="cf_sql_varchar" value="Business" /> 
            AND contactid = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.new_contactid#" /> 
            AND itemstatus = <cfqueryparam cfsqltype="cf_sql_varchar" value="Active" /> 
            AND valuecategory = <cfqueryparam cfsqltype="cf_sql_varchar" value="Email" />
        </cfquery>

<cfreturn result>
</cffunction>
<cffunction output="false" name="SELcontactitems_23891" access="public" returntype="query">
    <cfargument name="new_contactid" type="numeric" required="true">

<cfquery name="result" >
            SELECT valuetext AS new_PersonalEmail
            FROM contactitems
            WHERE valuetype = <cfqueryparam cfsqltype="cf_sql_varchar" value="Personal" />
            AND contactid = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.new_contactid#" />
            AND itemstatus = <cfqueryparam cfsqltype="cf_sql_varchar" value="Active" />
            AND valuecategory = <cfqueryparam cfsqltype="cf_sql_varchar" value="Email" />
        </cfquery>

<cfreturn result>
</cffunction>
<cffunction output="false" name="SELcontactitems_23892" access="public" returntype="query">
    <cfargument name="contactId" type="numeric" required="true">

<cfquery name="result" >
            SELECT valuecompany AS new_Company
            FROM contactitems
            WHERE contactid = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.contactId#" />
            AND itemstatus = <cfqueryparam cfsqltype="cf_sql_varchar" value="Active" />
            AND valuecategory = <cfqueryparam cfsqltype="cf_sql_varchar" value="Company" />
        </cfquery>

<cfreturn result>
</cffunction>
<cffunction output="false" name="SELcontactitems_23893" access="public" returntype="query">
    <cfargument name="new_contactid" type="numeric" required="true">

<cfquery name="result" >
            SELECT valuetext AS new_WorkPhone
            FROM contactitems
            WHERE valuetype = <cfqueryparam cfsqltype="cf_sql_varchar" value="Work" />
            AND contactid = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.new_contactid#" />
            AND itemstatus = <cfqueryparam cfsqltype="cf_sql_varchar" value="Active" />
            AND valuecategory = <cfqueryparam cfsqltype="cf_sql_varchar" value="Phone" />
        </cfquery>

<cfreturn result>
</cffunction>
<cffunction output="false" name="SELcontactitems_23894" access="public" returntype="query">
    <cfargument name="new_contactid" type="numeric" required="true">

<cfquery name="result" >
            SELECT valuetext AS new_mobilePhone 
            FROM contactitems 
            WHERE valuetype = <cfqueryparam cfsqltype="cf_sql_varchar" value="mobile" />
            AND contactid = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.new_contactid#" />
            AND itemstatus = <cfqueryparam cfsqltype="cf_sql_varchar" value="Active" />
            AND valuecategory = <cfqueryparam cfsqltype="cf_sql_varchar" value="Phone" />
        </cfquery>

<cfreturn result>
</cffunction>
<cffunction output="false" name="SELcontactitems_23895" access="public" returntype="query">
    <cfargument name="new_contactid" type="numeric" required="true">
    <cfset var queryResult = "">

<cfquery result="result" name="queryResult" >
            SELECT valuetext AS new_homePhone 
            FROM contactitems 
            WHERE valuetype = <cfqueryparam cfsqltype="cf_sql_varchar" value="home" /> 
            AND contactid = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.new_contactid#" /> 
            AND itemstatus = <cfqueryparam cfsqltype="cf_sql_varchar" value="Active" /> 
            AND valuecategory = <cfqueryparam cfsqltype="cf_sql_varchar" value="Phone" />
        </cfquery>

<cfreturn queryResult>
</cffunction>
<cffunction output="false" name="SELcontactitems_23896" access="public" returntype="query">
    <cfargument name="new_contactid" type="numeric" required="true">

<cfquery name="result" >
            SELECT 
                valuestreetaddress AS new_address, 
                valueextendedaddress AS new_address2, 
                valuecity AS new_city, 
                valueregion AS new_state, 
                valuepostalcode AS new_zip 
            FROM 
                contactitems 
            WHERE 
                valuetype = <cfqueryparam cfsqltype="cf_sql_varchar" value="Business" /> 
                AND contactid = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.new_contactid#" /> 
                AND itemstatus = <cfqueryparam cfsqltype="cf_sql_varchar" value="Active" /> 
                AND valuecategory = <cfqueryparam cfsqltype="cf_sql_varchar" value="Address" />
        </cfquery>

<cfreturn result>
</cffunction>
<cffunction output="false" name="SELcontactitems_23897" access="public" returntype="query">
    <cfargument name="new_contactid" type="numeric" required="true">

<cfquery name="result" >
            SELECT 
                valuestreetaddress AS new_address, 
                valueextendedaddress AS new_address2, 
                valuecity AS new_city, 
                valueregion AS new_state, 
                valuepostalcode AS new_zip, 
                valueCountry AS new_country 
            FROM 
                contactitems 
            WHERE 
                contactid = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.new_contactid#" /> 
                AND itemstatus = <cfqueryparam cfsqltype="cf_sql_varchar" value="Active" /> 
                AND valuecategory = <cfqueryparam cfsqltype="cf_sql_varchar" value="Address" />
        </cfquery>

<cfreturn result>
</cffunction>
<cffunction output="false" name="SELcontactitems_23898" access="public" returntype="query">
    <cfargument name="contactID" type="numeric" required="true">

<cfquery name="result" >
            SELECT valuetext AS tag
            FROM contactitems
            WHERE valueCategory = <cfqueryparam cfsqltype="cf_sql_varchar" value="Tag" />
            AND itemstatus = <cfqueryparam cfsqltype="cf_sql_varchar" value="Active" />
            AND contactID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.contactID#" />
        </cfquery>

<cfreturn result>
</cffunction>
<cffunction output="false" name="DETcontactitems_23910" access="public" returntype="query">
    <cfargument name="itemid" type="numeric" required="true">

<cfset var queryResult = "">

<cfquery result="result" name="queryResult" >
            SELECT i.itemid, i.valueText
            FROM contactitems i
            WHERE i.itemid = <cfqueryparam value="#arguments.itemid#" cfsqltype="cf_sql_integer">
        </cfquery>

<cfreturn queryResult>
</cffunction>
<cffunction output="false" name="REScontactitems" access="public" returntype="query">
    <cfargument name="userid" type="numeric" required="true">
    <cfargument name="uploadid" type="numeric" required="true">

<cfquery name="result" >
            SELECT 
                d.contactid, 
                'Name' AS head1, 
                'Tags' AS head2, 
                'Phone' AS head3, 
                'Email' AS head4, 
                'Company' AS head5, 
                'Status' AS head6, 
                c.status, 
                d.contactfullname AS col1,
                (SELECT GROUP_CONCAT(CONCAT("<span class='badge badge-blue'>", valueText, "</span>") SEPARATOR ' ') 
                 FROM contactitems 
                 WHERE valueCategory = 'Tag' AND contactID = d.ContactID AND itemstatus = 'Active' LIMIT 1) AS col2,
                (SELECT valueText FROM contactitems WHERE valueCategory = 'Phone' AND contactID = d.ContactID AND itemstatus = 'Active' LIMIT 1) AS col3,
                (SELECT valueText FROM contactitems WHERE valueCategory = 'Email' AND contactID = d.ContactID AND itemstatus = 'Active' LIMIT 1) AS col4,
                (SELECT valueCompany FROM contactitems WHERE contactID = d.ContactID AND valueCategory = 'Company' AND itemstatus = 'active' LIMIT 1) AS col5
            FROM 
                contactdetails d
            INNER JOIN 
                contactsimport c ON c.contactid = d.contactid
            WHERE 
                d.contactStatus = 'Active'
                AND d.userid = <cfqueryparam value="#arguments.userid#" cfsqltype="CF_SQL_INTEGER">
                AND c.uploadid = <cfqueryparam value="#arguments.uploadid#" cfsqltype="CF_SQL_INTEGER">
            ORDER BY 
                d.contactfullname
        </cfquery>

<cfreturn result>

</cffunction>
<cffunction name="getContactDetails" access="public" returntype="query" output="false">
    <cfargument name="uploadid" type="numeric" required="true">

<cfquery name="result">
        SELECT 
            d.contactid, 
            'Name' AS head1, 
            'Tags' AS head2, 
            'Phone' AS head3, 
            'Email' AS head4, 
            'Company' AS head5, 
            'Status' AS head6, 
            c.status, 
            d.contactfullname AS col1,
            (SELECT GROUP_CONCAT(CONCAT('<span class=''badge badge-blue''>', valueText, '</span>') SEPARATOR ' ') 
             FROM contactitems 
             WHERE valueCategory = 'Tag' AND contactID = d.ContactID AND itemstatus = 'Active' LIMIT 1) AS col2,
            (SELECT valueText 
             FROM contactitems 
             WHERE valueCategory = 'Phone' AND contactID = d.ContactID AND itemstatus = 'Active' LIMIT 1) AS col3,
            (SELECT valueText 
             FROM contactitems 
             WHERE valueCategory = 'Email' AND contactID = d.ContactID AND itemstatus = 'Active' LIMIT 1) AS col4,
            (SELECT valueCompany 
             FROM contactitems 
             WHERE contactID = d.ContactID AND valueCategory = 'Company' AND itemstatus = 'active' LIMIT 1) AS col5
        FROM 
            contactdetails d
        INNER JOIN 
            contactsimport c ON c.contactid = d.contactid
        WHERE 
            c.uploadid = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#arguments.uploadid#">
        ORDER BY 
            d.contactfullname
    </cfquery>

<cfreturn result>
</cffunction>

<cffunction output="false" name="INScontactitems_23947" access="public" returntype="numeric">
    <cfargument name="new_contactid" type="numeric" required="true">

<cfquery result="result" name="insertQuery" >
            INSERT INTO contactitems (
                contactid, 
                valuetype, 
                valuecategory, 
                valuetext, 
                itemstatus, 
                primary_yn
            ) VALUES (
                <cfqueryparam value="#arguments.new_contactid#" cfsqltype="CF_SQL_INTEGER">,
                <cfqueryparam value="Tags" cfsqltype="CF_SQL_VARCHAR">,
                <cfqueryparam value="Tag" cfsqltype="CF_SQL_VARCHAR">,
                <cfqueryparam value="My Team" cfsqltype="CF_SQL_VARCHAR">,
                <cfqueryparam value="Active" cfsqltype="CF_SQL_VARCHAR">,
                <cfqueryparam value="Y" cfsqltype="CF_SQL_CHAR">
            )
        </cfquery>

<cfreturn result.generatedKey>
</cffunction>
<cffunction output="false" name="SELcontactitems_23948" access="public" returntype="query">
    <cfargument name="deletecontactid" type="numeric" required="true">

<cfquery name="result" >
            SELECT itemid 
            FROM contactitems 
            WHERE contactid = <cfqueryparam value="#arguments.deletecontactid#" cfsqltype="CF_SQL_INTEGER"> 
            AND valuetext = <cfqueryparam value="My Team" cfsqltype="CF_SQL_VARCHAR">
        </cfquery>

<cfreturn result>
</cffunction>
<cffunction output="false" name="UPDcontactitems" access="public" returntype="void">
    <cfargument name="new_itemid" type="numeric" required="true">

<cfquery result="result" >
            UPDATE contactitems_tbl 
            SET isdeleted = 1 
            WHERE itemid = <cfqueryparam value="#arguments.new_itemid#" cfsqltype="CF_SQL_INTEGER">
        </cfquery>

</cffunction>
<cffunction output="false" name="UPDcontactitems_23952" access="public" returntype="void">
    <cfargument name="itemid" type="numeric" required="true">
    <cfargument name="contactid" type="numeric" required="true">

<cfquery result="result" name="updateQuery" >
            UPDATE contactitems 
            SET isDeleted = 1 
            WHERE itemid = <cfqueryparam value="#arguments.itemid#" cfsqltype="CF_SQL_INTEGER"> 
            AND contactid = <cfqueryparam value="#arguments.contactid#" cfsqltype="CF_SQL_INTEGER">
        </cfquery>

</cffunction>
<cffunction output="false" name="UPDcontactitems_23953" access="public" returntype="void">
    <cfargument name="currentid" type="numeric" required="true">

<cfquery result="result" >
            UPDATE contactitems 
            SET isDeleted = 1 
            WHERE contactid = <cfqueryparam value="#arguments.currentid#" cfsqltype="CF_SQL_INTEGER"> 
            AND itemstatus = <cfqueryparam value="Pending" cfsqltype="CF_SQL_VARCHAR">
        </cfquery>

</cffunction>
<cffunction output="false" name="SELcontactitems_23954" access="public" returntype="query">
    <cfargument name="currentid" type="numeric" required="true">
    <cfargument name="valuecategory" type="string" required="true">

<cfquery name="result" >
            SELECT itemid 
            FROM contactitems 
            WHERE contactid = <cfqueryparam value="#arguments.currentid#" cfsqltype="CF_SQL_INTEGER"> 
            AND valueCategory = <cfqueryparam value="#arguments.valuecategory#" cfsqltype="CF_SQL_VARCHAR"> 
            AND itemStatus = 'Pending'
        </cfquery>

<cfreturn result>
</cffunction>
<cffunction output="false" name="INScontactitems_23955" access="public" returntype="numeric">
    <cfargument name="contactID" type="numeric" required="true">
    <cfargument name="valueTypeDef" type="string" required="true">
    <cfargument name="valuecategory" type="string" required="true">

<cfquery result="result" >
            INSERT INTO contactitems (contactID, valueType, valuecategory, itemStatus) 
            VALUES (
                <cfqueryparam value="#arguments.contactID#" cfsqltype="CF_SQL_INTEGER">,
                <cfqueryparam value="#arguments.valueTypeDef#" cfsqltype="CF_SQL_VARCHAR">,
                <cfqueryparam value="#arguments.valuecategory#" cfsqltype="CF_SQL_VARCHAR">,
                <cfqueryparam value="Pending" cfsqltype="CF_SQL_VARCHAR">
            )
        </cfquery>

</cffunction>
<cffunction output="false" name="SELcontactitems_23962" access="public" returntype="query">
    <cfargument name="contactId" type="numeric" required="true">

<cfquery name="result" >
            SELECT 
                contactid, 
                itemid, 
                concat(' <span class=''badge badge-blue''>', contactitems.valueText, '</span>') as tag, 
                contactitems.valuetext
            FROM 
                contactitems
            WHERE 
                contactid = <cfqueryparam value="#arguments.contactId#" cfsqltype="CF_SQL_INTEGER"> 
                AND valuetext <> <cfqueryparam value="My Team" cfsqltype="CF_SQL_VARCHAR">
                AND valuecategory = <cfqueryparam value="Tag" cfsqltype="CF_SQL_VARCHAR">
                AND valuetext <> <cfqueryparam value="My Rep Team" cfsqltype="CF_SQL_VARCHAR">
        </cfquery>

<cfreturn result>
</cffunction>
<cffunction output="false" name="SELcontactitems_23963" access="public" returntype="query">
    <cfargument name="contactID" type="numeric" required="true">

<cfquery name="result" >
            SELECT contactitems.valueText AS phone
            FROM contactitems
            WHERE contactitems.valueCategory = <cfqueryparam value="Phone" cfsqltype="CF_SQL_VARCHAR">
            AND contactitems.contactID = <cfqueryparam value="#arguments.contactID#" cfsqltype="CF_SQL_INTEGER">
            AND contactitems.itemStatus = <cfqueryparam value="Active" cfsqltype="CF_SQL_VARCHAR">
            ORDER BY contactitems.primary_YN DESC
            LIMIT 1
        </cfquery>

<cfreturn result>
</cffunction>
<cffunction output="false" name="SELcontactitems_23964" access="public" returntype="query">
    <cfargument name="contactID" type="numeric" required="true">

<cfquery name="result" >
            SELECT contactitems.valueText AS email
            FROM contactitems
            WHERE contactitems.valueCategory = <cfqueryparam value="Email" cfsqltype="CF_SQL_VARCHAR">
            AND contactitems.contactID = <cfqueryparam value="#arguments.contactID#" cfsqltype="CF_SQL_INTEGER">
            AND contactitems.itemStatus = <cfqueryparam value="Active" cfsqltype="CF_SQL_VARCHAR">
            ORDER BY contactitems.primary_YN DESC
            LIMIT 1
        </cfquery>

<cfreturn result>
</cffunction>
<cffunction output="false" name="SELcontactitems_24040" access="public" returntype="query">
    <cfargument name="userid" type="numeric" required="true">

<cfquery name="result" >
            SELECT DISTINCT i.valueCompany AS new_valuecompany 
            FROM contactitems i 
            INNER JOIN contactdetails d ON d.contactid = i.contactid 
            WHERE i.VALUEcategory = 'company' 
            AND d.userid = <cfqueryparam value="#arguments.userid#" cfsqltype="cf_sql_integer"> 
            AND i.valuecompany <> '' 
            AND i.valueCompany IS NOT NULL 
            <!--- AND i.valuecompany <> 'Custom' --->
            ORDER BY i.valuecompany
        </cfquery>

<cfreturn result>
</cffunction>
<cffunction output="false" name="INScontactitems_24043" access="public" returntype="numeric">
    <cfargument name="contactid" type="numeric" required="true">
    <cfargument name="valuetype" type="string" required="true">
    <cfargument name="valueCategory" type="string" required="true">
    <cfargument name="valueDepartment" type="string" required="false" default="">
    <cfargument name="valueTitle" type="string" required="false" default="">
    <cfargument name="catid" type="numeric" required="true" default="0">

<cfquery result="result">
        INSERT INTO contactitems (contactid, valuetype, itemStatus, valueCategory
            <cfif arguments.catid EQ 9>, valueTitle, valueDepartment</cfif>
        )
        VALUES (
            <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.contactid#" />,
            <cfqueryparam cfsqltype="cf_sql_varchar" value="#trim(arguments.valuetype)#" />,
            <cfqueryparam cfsqltype="cf_sql_varchar" value="Active" />,
            <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.valueCategory#" />
            <cfif arguments.catid EQ 9>,
                <cfqueryparam cfsqltype="cf_sql_varchar" value="#trim(arguments.valueTitle)#" />,
                <cfqueryparam cfsqltype="cf_sql_varchar" value="#trim(arguments.valueDepartment)#" />
            </cfif>
        )
    </cfquery>

<cfreturn result.generatedKey>
</cffunction>

<cffunction output="false" name="UPDcontactitems_24046" access="public" returntype="void">
    <cfargument name="valuetext" type="string" required="true">
    <cfargument name="catid" type="string" required="true">
    <cfargument name="valuecompany" type="string" required="false" default="">
    <cfargument name="valueDepartment" type="string" required="false" default="">
    <cfargument name="valueTitle" type="string" required="false" default="">
    <cfargument name="valueStreetAddress" type="string" required="false" default="">
    <cfargument name="valueExtendedAddress" type="string" required="false" default="">
    <cfargument name="valueCity" type="string" required="false" default="">
    <cfargument name="new_regionname" type="string" required="false" default="">
    <cfargument name="new_countryname" type="string" required="false" default="">
    <cfargument name="valuePostalCode" type="string" required="false" default="">
    <cfargument name="itemdate" type="date" required="false">
    <cfargument name="itemid" type="numeric" required="true">

<cfquery result="result"  name="updateQuery">
            UPDATE contactitems
            SET valuetext = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#trim(arguments.valuetext)#">
            <cfif arguments.catid EQ "9">
                <cfif len(trim(arguments.valuecompany))>
                    , valueCompany = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#trim(arguments.valuecompany)#">
                </cfif>
                , valueDepartment = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#trim(arguments.valueDepartment)#">
                , valueTitle = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#trim(arguments.valueTitle)#">
            </cfif>
            <cfif arguments.catid EQ "2">
                , valueStreetAddress = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#trim(arguments.valueStreetAddress)#">
                , valueExtendedAddress = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#trim(arguments.valueExtendedAddress)#">
                , valueCity = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#trim(arguments.valueCity)#">
                , valueRegion = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#trim(arguments.new_regionname)#">
                , valueCountry = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#trim(arguments.new_countryname)#">
                , valuePostalCode = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#trim(arguments.valuePostalCode)#">
            </cfif>
            <cfif structKeyExists(arguments, "itemdate") AND IsDate(arguments.itemdate)>
                , itemdate = <cfqueryparam cfsqltype="CF_SQL_DATE" value="#arguments.itemdate#">
            </cfif>
            WHERE itemid = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#arguments.itemid#">
        </cfquery>

</cffunction>
<cffunction output="false" name="INScontactitems_24049" access="public" returntype="numeric">
    <cfargument name="contactID" type="numeric" required="true">
    <cfargument name="tag" type="string" required="true">

<cfquery result="result" >
            INSERT INTO CONTACTITEMS (CONTACTID, VALUETYPE, VALUECATEGORY, VALUETEXT, ITEMSTATUS) 
            VALUES (
                <cfqueryparam value="#arguments.contactID#" cfsqltype="CF_SQL_INTEGER">,
                <cfqueryparam value="Tags" cfsqltype="CF_SQL_VARCHAR">,
                <cfqueryparam value="Tag" cfsqltype="CF_SQL_VARCHAR">,
                <cfqueryparam value="#arguments.tag#" cfsqltype="CF_SQL_VARCHAR">,
                <cfqueryparam value="Active" cfsqltype="CF_SQL_VARCHAR">
            )
        </cfquery>
<cfreturn result.generatedKey>
</cffunction>
<cffunction output="false" name="INScontactitems_24050" access="public" returntype="numeric">
    <cfargument name="contactID" type="numeric" required="true">
    <cfargument name="workEmail" type="string" required="true">

<cfquery result="result" >
            INSERT INTO CONTACTITEMS (CONTACTID, VALUETYPE, VALUECATEGORY, VALUETEXT, ITEMSTATUS)
            VALUES (
                <cfqueryparam value="#arguments.contactID#" cfsqltype="CF_SQL_INTEGER">,
                <cfqueryparam value="Business" cfsqltype="CF_SQL_VARCHAR">,
                <cfqueryparam value="Email" cfsqltype="CF_SQL_VARCHAR">,
                <cfqueryparam value="#arguments.workEmail#" cfsqltype="CF_SQL_VARCHAR">,
                <cfqueryparam value="Active" cfsqltype="CF_SQL_VARCHAR">
            )
        </cfquery>
    <cfreturn result.generatedKey>
</cffunction>
<cffunction output="false" name="INScontactitems_24051" access="public" returntype="numeric">
    <cfargument name="contactID" type="numeric" required="true">
    <cfargument name="workPhone" type="string" required="true">

<cfquery result="result" >
            INSERT INTO CONTACTITEMS (CONTACTID, VALUETYPE, VALUECATEGORY, VALUETEXT, ITEMSTATUS)
            VALUES (
                <cfqueryparam value="#arguments.contactID#" cfsqltype="CF_SQL_INTEGER">,
                <cfqueryparam value="Work" cfsqltype="CF_SQL_VARCHAR">,
                <cfqueryparam value="Phone" cfsqltype="CF_SQL_VARCHAR">,
                <cfqueryparam value="#arguments.workPhone#" cfsqltype="CF_SQL_VARCHAR">,
                <cfqueryparam value="Active" cfsqltype="CF_SQL_VARCHAR">
            )
        </cfquery>
        <cfreturn result.generatedKey>
</cffunction>
<cffunction output="false" name="INScontactitems_24052" access="public" returntype="numeric">
    <cfargument name="CONTACTID" type="numeric" required="true">
    <cfargument name="Company" type="string" required="true">

<cfquery result="result" >
            INSERT INTO CONTACTITEMS (CONTACTID, VALUETYPE, VALUECATEGORY, VALUETEXT, ITEMSTATUS) 
            VALUES (
                <cfqueryparam value="#arguments.CONTACTID#" cfsqltype="CF_SQL_INTEGER">,
                <cfqueryparam value="Company" cfsqltype="CF_SQL_VARCHAR">,
                <cfqueryparam value="Company" cfsqltype="CF_SQL_VARCHAR">,
                <cfqueryparam value="#arguments.Company#" cfsqltype="CF_SQL_VARCHAR">,
                <cfqueryparam value="Active" cfsqltype="CF_SQL_VARCHAR">
            )
        </cfquery>
<cfreturn result.generatedKey>
</cffunction>
<cffunction output="false" name="INScontactitems_24057" access="public" returntype="numeric">
    <cfargument name="contactID" type="numeric" required="true">
    <cfargument name="company" type="string" required="true">

<cfquery result="result" >
            INSERT INTO CONTACTITEMS (CONTACTID, VALUETYPE, VALUECATEGORY, valuecompany, ITEMSTATUS)
            VALUES (
                <cfqueryparam value="#arguments.contactID#" cfsqltype="CF_SQL_INTEGER">,
                <cfqueryparam value="Company" cfsqltype="CF_SQL_VARCHAR">,
                <cfqueryparam value="Company" cfsqltype="CF_SQL_VARCHAR">,
                <cfqueryparam value="#arguments.company#" cfsqltype="CF_SQL_VARCHAR">,
                <cfqueryparam value="Active" cfsqltype="CF_SQL_VARCHAR">
            )
        </cfquery>
<cfreturn result.generatedKey>
</cffunction>
<cffunction output="false" name="INScontactitems_24058" access="public" returntype="numeric">
    <cfargument name="CONTACTID" type="numeric" required="true">
    <cfargument name="Company_new" type="string" required="true">

<cfquery result="result" >
            INSERT INTO CONTACTITEMS (CONTACTID, VALUETYPE, VALUECATEGORY, valuecompany, ITEMSTATUS)
            VALUES (
                <cfqueryparam value="#arguments.CONTACTID#" cfsqltype="CF_SQL_INTEGER">,
                <cfqueryparam value="Company" cfsqltype="CF_SQL_VARCHAR">,
                <cfqueryparam value="Company" cfsqltype="CF_SQL_VARCHAR">,
                <cfqueryparam value="#arguments.Company_new#" cfsqltype="CF_SQL_VARCHAR">,
                <cfqueryparam value="Active" cfsqltype="CF_SQL_VARCHAR">
            )
        </cfquery>
      <cfreturn result.generatedKey>
</cffunction>
<cffunction output="false" name="SELcontactitems_24064" access="public" returntype="query">
    <cfargument name="userid" type="numeric" required="true">

<cfquery name="result" >
            SELECT DISTINCT i.valueCompany AS new_valuecompany
            FROM contactitems i
            INNER JOIN contactdetails d ON d.contactid = i.contactid
            WHERE i.VALUEcategory = <cfqueryparam value="company" cfsqltype="CF_SQL_VARCHAR">
            AND d.userid = <cfqueryparam value="#arguments.userid#" cfsqltype="CF_SQL_INTEGER">
            AND i.valuecompany <> ''
            AND i.valueCompany IS NOT NULL
            AND i.valuecompany <> 'Custom'
            ORDER BY i.valuecompany
        </cfquery>

<cfreturn result>
</cffunction>
<cffunction output="false" name="DETcontactitems_24168" access="public" returntype="query">
    <cfargument name="itemid" type="numeric" required="true">

<cfquery name="result" >
            SELECT 
                i.itemid, i.contactid, i.valueType, i.valueCategory, i.valueText, 
                i.valueCompany, i.valueDepartment, i.valueTitle, i.valueStreetAddress, 
                i.valueExtendedAddress, i.valueCity, i.valueRegion, i.itemdate, 
                i.itemnotes, i.itemstatus, i.valueCountry, i.valuePostalCode, 
                c.catid, c.caticon, c.recordname, c.catfieldset
            FROM 
                contactitems i
            INNER JOIN 
                itemcategory c ON c.valuecategory = i.valuecategory
            WHERE 
                i.itemid = <cfqueryparam value="#arguments.itemid#" cfsqltype="cf_sql_integer">
        </cfquery>

<cfreturn result>

</cffunction>
<cffunction output="false" name="UPDcontactitems_24178" access="public" returntype="void">
    <cfargument name="valuetext" type="string" required="false">
    <cfargument name="valuetype" type="string" required="false">
    <cfargument name="catid" type="string" required="true">
    <cfargument name="valuecompany" type="string" required="false" default="">
    <cfargument name="custom" type="string" required="false" default="">
    <cfargument name="valueDepartment" type="string" required="false" default="">
    <cfargument name="valueTitle" type="string" required="false" default="">
    <cfargument name="valueStreetAddress" type="string" required="false" default="">
    <cfargument name="valueExtendedAddress" type="string" required="false" default="">
    <cfargument name="valueCity" type="string" required="false" default="">
    <cfargument name="new_region_id" type="string" required="false" default="">
    <cfargument name="new_countryid" type="string" required="false" default="">
    <cfargument name="valuePostalCode" type="string" required="false" default="">
    <cfargument name="itemdate" type="date" required="false">
    <cfargument name="deleteitem" type="boolean" required="false" default=false>
    <cfargument name="itemid" type="numeric" required="true">

<cfquery result="result">
    UPDATE contactitems 
    SET 
        <!--- Only include valuetext if provided --->
        <cfif structKeyExists(arguments, "valuetext") and len(trim(arguments.valuetext))>
            valuetext = <cfqueryparam cfsqltype="cf_sql_varchar" value="#trim(arguments.valuetext)#">
        </cfif>

<!--- Include valuetype if provided --->
        <cfif structKeyExists(arguments, "valuetype") and len(trim(arguments.valuetype))>
            <cfif structKeyExists(arguments, "valuetext") and len(trim(arguments.valuetext))>,</cfif>
            valuetype = <cfqueryparam cfsqltype="cf_sql_varchar" value="#trim(arguments.valuetype)#">
        </cfif>

<!--- Conditional fields for catid 9 --->
        <cfif arguments.catid eq "9">

<cfif structKeyExists(arguments, "valuecompany")>
    <cfif trim(arguments.valuecompany) eq "custom" and trim(arguments.custom) neq "" and trim(arguments.custom) neq "custom">
        , valueCompany = <cfqueryparam cfsqltype="cf_sql_varchar" value="#trim(arguments.custom)#">
    <cfelse>
        , valueCompany = <cfqueryparam cfsqltype="cf_sql_varchar" value="#trim(arguments.valuecompany)#">
    </cfif>
</cfif>

, valueDepartment = <cfqueryparam cfsqltype="cf_sql_varchar" value="#trim(arguments.valueDepartment)#">
            , valueTitle = <cfqueryparam cfsqltype="cf_sql_varchar" value="#trim(arguments.valueTitle)#">
        </cfif>

<!--- Conditional fields for catid 2 --->
        <cfif arguments.catid eq "2">
            , valueStreetAddress = <cfqueryparam cfsqltype="cf_sql_varchar" value="#trim(arguments.valueStreetAddress)#">
            , valueExtendedAddress = <cfqueryparam cfsqltype="cf_sql_varchar" value="#trim(arguments.valueExtendedAddress)#">
            , valueCity = <cfqueryparam cfsqltype="cf_sql_varchar" value="#trim(arguments.valueCity)#">
            , valueRegion = <cfqueryparam cfsqltype="cf_sql_varchar" value="#trim(arguments.new_region_id)#">
            , valueCountry = <cfqueryparam cfsqltype="cf_sql_varchar" value="#trim(arguments.new_countryid)#">
            , valuePostalCode = <cfqueryparam cfsqltype="cf_sql_varchar" value="#trim(arguments.valuePostalCode)#">
        </cfif>

<!--- Include itemdate only if provided and valid --->
        <cfif structKeyExists(arguments, "itemdate") and isDate(arguments.itemdate)>
            , itemdate = <cfqueryparam cfsqltype="cf_sql_date" value="#arguments.itemdate#">
        </cfif>

<!--- Set isdeleted if deleteitem is true --->
        <cfif structKeyExists(arguments, "deleteitem") and arguments.deleteitem>
            , isdeleted = 1
        </cfif>

WHERE itemid = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#arguments.itemid#">
</cfquery>
</cffunction>

<cffunction output="false" name="UPDcontactitems_24179" access="public" returntype="void">
    <cfargument name="valuetype" type="string" required="true">
    <cfargument name="itemid" type="numeric" required="true">

<cfquery result="result" >
            UPDATE contactitems 
            SET valuetype = <cfqueryparam value="#arguments.valuetype#" cfsqltype="CF_SQL_VARCHAR">
            WHERE itemid = <cfqueryparam value="#arguments.itemid#" cfsqltype="CF_SQL_INTEGER">
        </cfquery>

</cffunction>
<cffunction output="false" name="SELcontactitems_24207" access="public" returntype="query">
    <cfargument name="ContactID" type="numeric" required="true">
    <cfargument name="new_tagname" type="string" required="true">

<cfquery name="result" >
            SELECT valuetext 
            FROM contactitems 
            WHERE valueCategory = <cfqueryparam value="Tag" cfsqltype="CF_SQL_VARCHAR"> 
            AND itemstatus = <cfqueryparam value="Active" cfsqltype="CF_SQL_VARCHAR"> 
            AND contactID = <cfqueryparam value="#arguments.ContactID#" cfsqltype="CF_SQL_INTEGER"> 
            AND valuetext = <cfqueryparam value="#arguments.new_tagname#" cfsqltype="CF_SQL_VARCHAR"> 
            ORDER BY valuetext
        </cfquery>

<cfreturn result>
</cffunction>
<cffunction output="false" name="SELcontactitems_24313" access="public" returntype="query">
    <cfargument name="contactid" type="numeric" required="true">

<cfquery name="result" >
            SELECT itemID, contactID, valueType, valueCategory, valueText, valueCompany, valueDepartment, valueTitle, valueStreetAddress, valueExtendedAddress, valueCity, valueRegion, itemDate, itemNotes, itemStatus, itemCreationDate, itemLastUpdated, valueCountry, valuePostalCode, primary_YN, IsDeleted 
            FROM contactitems 
            WHERE valuecategory = <cfqueryparam value="Tag" cfsqltype="CF_SQL_VARCHAR"> 
            AND valuetext = <cfqueryparam value="Casting Director" cfsqltype="CF_SQL_VARCHAR"> 
            AND contactid = <cfqueryparam value="#arguments.contactid#" cfsqltype="CF_SQL_INTEGER"> 
            AND itemstatus = <cfqueryparam value="Active" cfsqltype="CF_SQL_VARCHAR">
        </cfquery>

<cfreturn result>
</cffunction>

<cffunction output="false" name="SELcontactitems_24314" access="public" returntype="query">
    <cfargument name="contactid" type="numeric" required="true">
    <cfargument name="userid" type="numeric" required="true">

<cfquery name="result" >
 
            )
        </cfquery>

<cfreturn result>
</cffunction>
<cffunction output="false" name="DELcontactitems" access="public" returntype="void">
    <cfargument name="contactid" type="numeric" required="true">

<cfquery result="result" >
            DELETE FROM contactitems
            WHERE valuecategory = <cfqueryparam value="Tag" cfsqltype="CF_SQL_VARCHAR">
            AND contactid = <cfqueryparam value="#arguments.contactid#" cfsqltype="CF_SQL_INTEGER">
        </cfquery>

</cffunction>
<cffunction output="false" name="INScontactitems_24327" access="public" returntype="numeric">
    <cfargument name="contactID" type="numeric" required="true">
    <cfargument name="newValueText" type="string" required="true">

<cfquery result="result" name="insertQuery" >
            INSERT INTO CONTACTITEMS (CONTACTID, VALUETYPE, VALUECATEGORY, VALUETEXT, ITEMSTATUS)
            VALUES (
                <cfqueryparam value="#arguments.contactID#" cfsqltype="CF_SQL_INTEGER">,
                <cfqueryparam value="Tags" cfsqltype="CF_SQL_VARCHAR">,
                <cfqueryparam value="Tag" cfsqltype="CF_SQL_VARCHAR">,
                <cfqueryparam value="#left(arguments.newValueText, 40)#" cfsqltype="CF_SQL_VARCHAR">,
                <cfqueryparam value="Active" cfsqltype="CF_SQL_VARCHAR">
            )
        </cfquery>
        <cfreturn result.generatedKey>

</cffunction>
<cffunction output="false" name="SELcontactitems_24329" access="public" returntype="query">
    <cfargument name="userid" type="numeric" required="true">
    <cfargument name="tagname" type="string" required="true">

<cfquery name="result" >
            SELECT *
            FROM contactitems
            WHERE valuecategory = <cfqueryparam value="Tag" cfsqltype="CF_SQL_VARCHAR">
            AND contactid IN (
                SELECT contactid 
                FROM contactdetails 
                WHERE userid = <cfqueryparam value="#arguments.userid#" cfsqltype="CF_SQL_INTEGER">
            )
            AND valueText = <cfqueryparam value="#left(arguments.tagname, 40)#" cfsqltype="CF_SQL_VARCHAR">
        </cfquery>

<cfreturn result>
</cffunction>
<cffunction output="false" name="SELcontactitems_24347" access="public" returntype="query">
    <cfargument name="new_contactid" type="numeric" required="true">
    <cfargument name="new_tagname" type="string" required="true">

<cfquery name="result" >
            SELECT * 
            FROM CONTACTITEMS 
            WHERE contactid = <cfqueryparam value="#arguments.new_contactid#" cfsqltype="CF_SQL_INTEGER"> 
            AND VALUETYPE = <cfqueryparam value="Tags" cfsqltype="CF_SQL_VARCHAR"> 
            AND VALUETEXT = <cfqueryparam value="#arguments.new_tagname#" cfsqltype="CF_SQL_VARCHAR"> 
            AND itemstatus = <cfqueryparam value="Active" cfsqltype="CF_SQL_VARCHAR">
        </cfquery>

<cfreturn result>
</cffunction>
<cffunction output="false" name="INScontactitems_24348" access="public" returntype="numeric">
    <cfargument name="new_contactid" type="numeric" required="true">
    <cfargument name="new_tagname" type="string" required="true">

<cfquery result="result" >
            INSERT INTO CONTACTITEMS (CONTACTID, VALUETYPE, VALUECATEGORY, VALUETEXT, ITEMSTATUS)
            VALUES (
                <cfqueryparam value="#arguments.new_contactid#" cfsqltype="CF_SQL_INTEGER">,
                <cfqueryparam value="Tags" cfsqltype="CF_SQL_VARCHAR">,
                <cfqueryparam value="Tag" cfsqltype="CF_SQL_VARCHAR">,
                <cfqueryparam value="#arguments.new_tagname#" cfsqltype="CF_SQL_VARCHAR">,
                <cfqueryparam value="Active" cfsqltype="CF_SQL_VARCHAR">
            )
        </cfquery>
<cfreturn result.generatedKey>
</cffunction>
<cffunction output="false" name="UPDCONTACTITEMS_24349" access="public" returntype="void">
    <cfargument name="itemid" type="numeric" required="true">
    <cfargument name="new_currentStartDate" type="string" required="true">

<cfquery result="result" name="updateQuery" >
            UPDATE CONTACTITEMS_tbl 
            SET isdeleted = 1, 
                itemnotes = <cfqueryparam value="Delete via Bulk Update - #arguments.new_currentStartDate#" cfsqltype="CF_SQL_VARCHAR">
            WHERE itemid = <cfqueryparam value="#arguments.itemid#" cfsqltype="CF_SQL_INTEGER">
        </cfquery>

</cffunction>
<cffunction output="false" name="addContactItemsTag" access="public" returntype="numeric">
    <cfargument name="contactid" type="numeric" required="true">
    <cfargument name="new_tag" type="string" required="true">

    <cfset var newId = 0>

    <cfquery result="result" name="queryResult">
        INSERT INTO contactitems (contactid, valueType, valueCategory, valueText, itemstatus)
        SELECT 
            <cfqueryparam value="#arguments.contactid#" cfsqltype="CF_SQL_INTEGER">,
            <cfqueryparam value="Tags" cfsqltype="CF_SQL_VARCHAR">,
            <cfqueryparam value="tag" cfsqltype="CF_SQL_VARCHAR">,
            <cfqueryparam value="#arguments.new_tag#" cfsqltype="CF_SQL_VARCHAR">,
            <cfqueryparam value="Active" cfsqltype="CF_SQL_VARCHAR">
        WHERE NOT EXISTS (
            SELECT 1 
            FROM contactitems 
            WHERE contactid = <cfqueryparam value="#arguments.contactid#" cfsqltype="CF_SQL_INTEGER">
            AND valueText = <cfqueryparam value="#arguments.new_tag#" cfsqltype="CF_SQL_VARCHAR">
        )
    </cfquery>


    <!--- If a key is generated, return it --->
    <cfif structKeyExists(result, "generatedKey")>
        <cfset newId = result.generatedKey>
    </cfif>

    <cfreturn newId>
</cffunction>


<cffunction output="false" name="INScontactitems_24410" access="public" returntype="numeric" hint="Inserts a new contact item into the database.">
    <cfargument name="contactid" type="numeric" required="true">
    <cfargument name="business_email" type="string" required="true">

<cfquery result="result" >
            INSERT INTO contactitems (contactid, valueType, valueCategory, valueText, itemstatus)
            VALUES (
                <cfqueryparam value="#arguments.contactid#" cfsqltype="CF_SQL_INTEGER">,
                <cfqueryparam value="Business" cfsqltype="CF_SQL_VARCHAR">,
                <cfqueryparam value="Email" cfsqltype="CF_SQL_VARCHAR">,
                <cfqueryparam value="#arguments.business_email#" cfsqltype="CF_SQL_VARCHAR">,
                <cfqueryparam value="Active" cfsqltype="CF_SQL_VARCHAR">
            )
        </cfquery>
        <cfreturn result.generatedKey>
</cffunction>
<cffunction output="false" name="INScontactitems_24412" access="public" returntype="numeric">
    <cfargument name="contactid" type="numeric" required="true">
    <cfargument name="personal_email" type="string" required="true">

<cfquery result="result" >
            INSERT INTO contactitems (contactid, valueType, valueCategory, valueText, itemstatus)
            VALUES (
                <cfqueryparam value="#arguments.contactid#" cfsqltype="CF_SQL_INTEGER">,
                <cfqueryparam value="Personal" cfsqltype="CF_SQL_VARCHAR">,
                <cfqueryparam value="Email" cfsqltype="CF_SQL_VARCHAR">,
                <cfqueryparam value="#arguments.personal_email#" cfsqltype="CF_SQL_VARCHAR">,
                <cfqueryparam value="Active" cfsqltype="CF_SQL_VARCHAR">
            )
        </cfquery>
       <cfreturn result.generatedKey>
</cffunction>
<cffunction output="false" name="INScontactitems_24414" access="public" returntype="numeric">
    <cfargument name="contactid" type="numeric" required="true">
    <cfargument name="work_phone" type="string" required="true">

<cfquery result="result" >
            INSERT INTO contactitems (contactid, valueType, valueCategory, valueText, itemstatus)
            VALUES (
                <cfqueryparam value="#arguments.contactid#" cfsqltype="CF_SQL_INTEGER">,
                <cfqueryparam value="Work" cfsqltype="CF_SQL_VARCHAR">,
                <cfqueryparam value="Phone" cfsqltype="CF_SQL_VARCHAR">,
                <cfqueryparam value="#arguments.work_phone#" cfsqltype="CF_SQL_VARCHAR">,
                <cfqueryparam value="Active" cfsqltype="CF_SQL_VARCHAR">
            )
        </cfquery>

<cfreturn result.generatedKey>
</cffunction>
<cffunction output="false" name="INScontactitems_24416" access="public" returntype="numeric">
    <cfargument name="contactid" type="numeric" required="true">
    <cfargument name="mobile_phone" type="string" required="true">

<cfquery result="result" >
            INSERT INTO contactitems (contactid, valueType, valueCategory, valueText, itemstatus)
            VALUES (
                <cfqueryparam value="#arguments.contactid#" cfsqltype="CF_SQL_INTEGER">,
                <cfqueryparam value="Mobile" cfsqltype="CF_SQL_VARCHAR">,
                <cfqueryparam value="Phone" cfsqltype="CF_SQL_VARCHAR">,
                <cfqueryparam value="#arguments.mobile_phone#" cfsqltype="CF_SQL_VARCHAR">,
                <cfqueryparam value="Active" cfsqltype="CF_SQL_VARCHAR">
            )
        </cfquery>
      <cfreturn result.generatedKey>
</cffunction>
<cffunction output="false" name="INScontactitems_24418" access="public" returntype="numeric">
    <cfargument name="contactid" type="numeric" required="true">
    <cfargument name="home_phone" type="string" required="true">

<cfquery result="result" >
            INSERT INTO contactitems (contactid, valueType, valueCategory, valueText, itemstatus)
            VALUES (
                <cfqueryparam value="#arguments.contactid#" cfsqltype="CF_SQL_INTEGER">,
                <cfqueryparam value="Home" cfsqltype="CF_SQL_VARCHAR">,
                <cfqueryparam value="Phone" cfsqltype="CF_SQL_VARCHAR">,
                <cfqueryparam value="#arguments.home_phone#" cfsqltype="CF_SQL_VARCHAR">,
                <cfqueryparam value="Active" cfsqltype="CF_SQL_VARCHAR">
            )
        </cfquery>
<cfreturn result.generatedKey>
</cffunction>
<cffunction output="false" name="INScontactitems_24420" access="public" returntype="numeric">
    <cfargument name="contactid" type="numeric" required="true">
    <cfargument name="company" type="string" required="true">

<cfquery result="result" >
            INSERT INTO contactitems (contactid, valueType, valueCategory, valuecompany, itemstatus)
            VALUES (
                <cfqueryparam value="#arguments.contactid#" cfsqltype="CF_SQL_INTEGER">,
                <cfqueryparam value="Company" cfsqltype="CF_SQL_VARCHAR">,
                <cfqueryparam value="Company" cfsqltype="CF_SQL_VARCHAR">,
                <cfqueryparam value="#arguments.company#" cfsqltype="CF_SQL_VARCHAR">,
                <cfqueryparam value="Active" cfsqltype="CF_SQL_VARCHAR">
            )
        </cfquery>
<cfreturn result.generatedKey>
</cffunction>
<cffunction output="false" name="INScontactitems_24422" access="public" returntype="numeric">
    <cfargument name="contactid" type="numeric" required="true">
    <cfargument name="website" type="string" required="true">

<cfquery result="result" >
            INSERT INTO contactitems (contactid, valueType, valueCategory, valuetext, itemstatus)
            VALUES (
                <cfqueryparam value="#arguments.contactid#" cfsqltype="CF_SQL_INTEGER">,
                <cfqueryparam value="Company Website" cfsqltype="CF_SQL_VARCHAR">,
                <cfqueryparam value="URL" cfsqltype="CF_SQL_VARCHAR">,
                <cfqueryparam value="#arguments.website#" cfsqltype="CF_SQL_VARCHAR">,
                <cfqueryparam value="Active" cfsqltype="CF_SQL_VARCHAR">
            )
        </cfquery>
<cfreturn result.generatedKey>
</cffunction>
<cffunction output="false" name="INScontactitems_24424" access="public" returntype="numeric">
    <cfargument name="new_address" type="struct" required="true">

<cfset var queryResult = "">

<cfquery result="result" name="queryResult" >
            INSERT INTO contactitems (
                contactid, 
                valueType, 
                valueCategory, 
                valuestreetaddress, 
                valueextendedaddress, 
                valuecity, 
                valueregion, 
                valuepostalcode, 
                valuecountry, 
                itemstatus
            ) VALUES (
                <cfqueryparam value="#arguments.new_address.contactid#" cfsqltype="CF_SQL_INTEGER">,
                <cfqueryparam value="Work" cfsqltype="CF_SQL_VARCHAR">,
                <cfqueryparam value="Address" cfsqltype="CF_SQL_VARCHAR">,
                <cfqueryparam value="#arguments.new_address.address#" cfsqltype="CF_SQL_VARCHAR">,
                <cfqueryparam value="#arguments.new_address.address_second#" cfsqltype="CF_SQL_VARCHAR">,
                <cfqueryparam value="#arguments.new_address.city#" cfsqltype="CF_SQL_VARCHAR">,
                <cfqueryparam value="#arguments.new_address.state#" cfsqltype="CF_SQL_VARCHAR">,
                <cfqueryparam value="#arguments.new_address.zip#" cfsqltype="CF_SQL_VARCHAR">,
                <cfqueryparam value="#arguments.new_address.country#" cfsqltype="CF_SQL_VARCHAR">,
                <cfqueryparam value="Active" cfsqltype="CF_SQL_VARCHAR">
            )
        </cfquery>
        <cfreturn result.generatedKey>
</cffunction>
<cffunction output="false" name="SELcontactitems_24620" access="public" returntype="query">
    <cfargument name="userid" type="numeric" required="true">

<cfquery name="result" >
            SELECT 
                ci.contactid AS id, 
                concat(c.recordname, ' (', ti.tagname, ')') AS name
            FROM 
                contactitems ci
            INNER JOIN 
                contactdetails c ON c.contactid = ci.contactid
            INNER JOIN 
                tags_user ti ON ti.tagname = ci.valuetext
            WHERE 
                ci.valuecategory = <cfqueryparam value="Tag" cfsqltype="CF_SQL_VARCHAR"> 
                AND ti.userid = <cfqueryparam value="#arguments.userid#" cfsqltype="CF_SQL_INTEGER"> 
                AND c.userid = <cfqueryparam value="#arguments.userid#" cfsqltype="CF_SQL_INTEGER"> 
                AND ti.IsCasting = <cfqueryparam value="1" cfsqltype="CF_SQL_BIT">
            ORDER BY 
                c.recordname
        </cfquery>

<cfreturn result>

</cffunction>
<cffunction output="false" name="SELcontactitems_24657" access="public" returntype="query">
    <cfargument name="currentid" type="numeric" required="true">

<cfquery name="result" maxrows="1">
            SELECT valueText AS email
            FROM contactitems
            WHERE valueCategory = <cfqueryparam value="Email" cfsqltype="CF_SQL_VARCHAR">
            AND contactID = <cfqueryparam value="#arguments.currentid#" cfsqltype="CF_SQL_INTEGER">
            AND itemstatus = <cfqueryparam value="Active" cfsqltype="CF_SQL_VARCHAR">
            ORDER BY primary_yn DESC limit 1
        </cfquery>

<cfreturn result>
</cffunction>
<cffunction output="false" name="SELcontactitems_24663" access="public" returntype="query">
    <cfargument name="currentid" type="numeric" required="true">

<cfquery name="result" >
            SELECT i.valueCompany 
            FROM contactitems i 
            INNER JOIN itemcategory c ON c.valueCategory = i.valuecategory 
            WHERE i.contactID = <cfqueryparam value="#arguments.currentid#" cfsqltype="CF_SQL_INTEGER"> 
            AND c.valuecategory = <cfqueryparam value="Company" cfsqltype="CF_SQL_VARCHAR"> 
            AND i.itemstatus = <cfqueryparam value="Active" cfsqltype="CF_SQL_VARCHAR"> 
            AND i.valuecompany <> '' 
            AND i.valuecompany IS NOT null 
            ORDER BY i.valuetext 
            LIMIT 1
        </cfquery>

'' AND i.valuecompany IS NOT null ORDER BY i.valuetext LIMIT 1">

<cfreturn result>
</cffunction>
<cffunction output="false" name="SELcontactitems_24671" access="public" returntype="query">
    <cfargument name="contactID" type="numeric" required="true">

<cfquery name="result" >
            SELECT 
                i.itemID, 
                i.valueType, 
                i.valueCategory, 
                i.valuetext, 
                i.valuecompany, 
                i.valuedepartment, 
                i.valuetitle, 
                i.valueStreetAddress, 
                i.valueExtendedAddress, 
                i.valueCity, 
                i.valueRegion, 
                i.itemDate, 
                i.itemNotes, 
                i.itemStatus, 
                i.itemCreationDate, 
                i.itemLastUpdated, 
                i.valueCountry, 
                c.caticon
            FROM contactitems i
            INNER JOIN itemcategory c ON c.valueCategory = i.valuecategory
            WHERE i.contactID = <cfqueryparam value="#arguments.contactID#" cfsqltype="CF_SQL_INTEGER">
            AND i.valuetext <> ''
            AND i.itemStatus = 'Active'
        </cfquery>

<cfreturn result>
</cffunction>
<cffunction output="false" name="SELcontactitems_24672" access="public" returntype="query">
    <cfargument name="currentid" type="numeric" required="true">
    <cfargument name="catArea_UCB" type="string" required="true">

<cfquery name="result" >
            SELECT 
                i.itemID, i.valueType, i.valueCategory, i.valuetext, 
                i.valuecompany, i.valuedepartment, i.valuetitle, 
                i.valueStreetAddress, i.valueExtendedAddress, 
                i.valuePostalCode, i.valueCity, i.valueRegion, 
                i.itemDate, i.itemNotes, i.itemStatus, 
                i.itemCreationDate, i.itemLastUpdated, 
                i.valueCountry, c.caticon, c.catSelectList, c.catfieldset
            FROM 
                contactitems i
            INNER JOIN 
                itemcategory c ON c.valueCategory = i.valuecategory
            WHERE 
                i.contactID = <cfqueryparam value="#arguments.currentid#" cfsqltype="CF_SQL_INTEGER"> 
                AND c.catArea_UCB IN ('B', <cfqueryparam value="#arguments.catArea_UCB#" cfsqltype="CF_SQL_VARCHAR">)
        </cfquery>

<cfreturn result>
</cffunction>
<cffunction output="false" name="SELcontactitems_24673" access="public" returntype="query">
    <cfargument name="currentid" type="numeric" required="true">
    <cfargument name="activeCategoriesValueCategory" type="string" required="true">
    <cfargument name="catArea_UCB" type="string" required="true">

<cfquery name="result" >
            SELECT 
                i.itemID, i.valueType, i.valueCategory, i.valuetext, i.valueCompany, 
                i.valuedepartment, i.valuetitle, i.valueStreetAddress, i.valueExtendedAddress, 
                i.valueCity, i.valueRegion, i.itemDate, i.itemNotes, i.itemStatus, 
                i.itemCreationDate, i.itemLastUpdated, i.valueCountry, c.catfieldset, 
                c.caticon, i.valuepostalcode, i.primary_yn
            FROM 
                contactitems i
            INNER JOIN 
                itemcategory c ON c.valueCategory = i.valuecategory
            WHERE 
                i.contactID = <cfqueryparam value="#arguments.currentid#" cfsqltype="CF_SQL_INTEGER"> 
                AND c.valuecategory = <cfqueryparam value="#arguments.activeCategoriesValueCategory#" cfsqltype="CF_SQL_VARCHAR"> 
                AND i.itemstatus = <cfqueryparam value='Active' cfsqltype='CF_SQL_VARCHAR'> 
                AND i.valuecategory <> 'Tag' 
                AND c.catArea_UCB IN ('B', <cfqueryparam value="#arguments.catArea_UCB#" cfsqltype="CF_SQL_VARCHAR">)
            ORDER BY 
                i.valuetext
        </cfquery>

<cfreturn result>
</cffunction>
<cffunction output="false" name="SELcontactitems_24682" access="public" returntype="query">
    <cfargument name="userContactID" type="numeric" required="true">

<cfquery name="result" >
            SELECT 
                i.valuetext, 
                i.valuetype, 
                t.typeIcon, 
                i.valuecategory 
            FROM 
                contactitems i 
            INNER JOIN 
                itemtypes t ON i.valueType = t.valueType 
            WHERE 
                i.valueCategory IN (<cfqueryparam value="Acting Links" cfsqltype="CF_SQL_VARCHAR">, <cfqueryparam value="Profile" cfsqltype="CF_SQL_VARCHAR">) 
                AND i.itemstatus = <cfqueryparam value="Active" cfsqltype="CF_SQL_VARCHAR"> 
                AND i.contactid = <cfqueryparam value="#arguments.userContactID#" cfsqltype="CF_SQL_INTEGER"> 
            ORDER BY 
                i.valuetype
        </cfquery>

<cfreturn result>
</cffunction>
<cffunction output="false" name="SELcontactitems_24714" access="public" returntype="query">
    <cfargument name="currentid" type="numeric" required="true">

<cfquery name="result" >
            SELECT valueText as phonenumber 
            FROM contactitems 
            WHERE valueCategory = <cfqueryparam value="Phone" cfsqltype="CF_SQL_VARCHAR"> 
            AND contactID = <cfqueryparam value="#arguments.currentid#" cfsqltype="CF_SQL_INTEGER"> 
            AND itemstatus = <cfqueryparam value="Active" cfsqltype="CF_SQL_VARCHAR"> 
            ORDER BY primary_yn DESC
        </cfquery>

<cfreturn result>
</cffunction>

<cffunction output="false" name="getSocialIcons" access="public" returntype="query">
    <cfargument name="contactid" type="numeric" required="true">
    <cfargument name="userid" type="numeric" required="true">

<cfquery name="result" >
            SELECT DISTINCT 
                i.valuetext, 
                i.valuetype, 
                t.typeIcon,
                m.typeiconmdi 
            FROM 
                contactitems i 
            INNER JOIN 
                itemtypes_user t ON 
                i.valueType = t.valueType 

            inner JOIN itemtypes_tbl m on m.typeicon = t.typeicon
            
            WHERE 
                i.valueCategory = <cfqueryparam value="Social Profile" cfsqltype="CF_SQL_VARCHAR"> 
                AND i.contactID = <cfqueryparam value="#arguments.contactid#" cfsqltype="CF_SQL_INTEGER"> 
                AND i.itemstatus = <cfqueryparam value="Active" cfsqltype="CF_SQL_VARCHAR"> 
                AND t.userid = <cfqueryparam value="#arguments.userid#" cfsqltype="CF_SQL_INTEGER">
                and m.typeicon is not null 
                and m.typeiconmdi is not null
                order by t.typeid
        </cfquery>

<cfreturn result>
</cffunction>


<cffunction output="false" name="SELcontactitems_24715" access="public" returntype="query">
    <cfargument name="contactid" type="numeric" required="true">
    <cfargument name="userid" type="numeric" required="true">

<cfquery name="result" >
            SELECT 
                i.valuetext, 
                i.valuetype, 
                t.typeIcon 
            FROM 
                contactitems i 
            INNER JOIN 
                itemtypes_user t 
            ON 
                i.valueType = t.valueType 
            WHERE 
                i.valueCategory = <cfqueryparam value="Social Profile" cfsqltype="CF_SQL_VARCHAR"> 
                AND i.contactID = <cfqueryparam value="#arguments.contactid#" cfsqltype="CF_SQL_INTEGER"> 
                AND i.itemstatus = <cfqueryparam value="Active" cfsqltype="CF_SQL_VARCHAR"> 
                AND t.userid = <cfqueryparam value="#arguments.userid#" cfsqltype="CF_SQL_INTEGER">
        </cfquery>

<cfreturn result>
</cffunction>
<cffunction output="false" name="DETcontactitems_24719" access="public" returntype="query">
    <cfargument name="itemid" type="numeric" required="true">

<cfset var queryResult = "">

<cfquery result="result" name="queryResult" >
            SELECT 
                i.itemid, i.contactid, i.valueType, i.valueCategory, i.valueText, 
                i.valueCompany, i.valueDepartment, i.valueTitle, i.valueStreetAddress, 
                i.valueExtendedAddress, i.valueCity, i.valueRegion, i.itemdate, 
                i.itemnotes, i.itemstatus, i.valueCountry, i.valuePostalCode, 
                c.catid, c.caticon, c.recordname, c.catfieldset 
            FROM 
                contactitems i 
            INNER JOIN 
                itemcategory c ON c.valuecategory = i.valuecategory 
            WHERE 
                i.itemid = <cfqueryparam value="#arguments.itemid#" cfsqltype="CF_SQL_INTEGER">
        </cfquery>

<cfreturn queryResult>
</cffunction>
<cffunction output="false" name="SELcontactitems_24761" access="public" returntype="query">
    <cfargument name="contactid" type="numeric" required="true">

<cfquery name="result" >
            SELECT * 
            FROM contactitems 
            WHERE valuecategory = <cfqueryparam value="Tag" cfsqltype="CF_SQL_VARCHAR"> 
            AND contactid = <cfqueryparam value="#arguments.contactid#" cfsqltype="CF_SQL_INTEGER"> 
            AND itemstatus = <cfqueryparam value="Active" cfsqltype="CF_SQL_VARCHAR"> 
            AND valuetext IN (
                SELECT tagname AS valuetext 
                FROM tags_user 
                WHERE userid = <cfqueryparam value="#userid#" cfsqltype="CF_SQL_INTEGER"> 
                AND tagtype = <cfqueryparam value="C" cfsqltype="CF_SQL_CHAR">
            )
        </cfquery>

<cfreturn result>
</cffunction>
<cffunction output="false" name="SELcontactitems_24764" access="public" returntype="query">
    <cfargument name="ContactID" type="numeric" required="true">

<cfquery name="result" >
            SELECT 
                CONCAT("<span class='badge badge-blue' style='font-size: 12px; font-weight: 500;'>", valueText, "</span>") AS valuetext, 
                valuetext AS tag 
            FROM 
                contactitems 
            WHERE 
                valueCategory = <cfqueryparam value="Tag" cfsqltype="CF_SQL_VARCHAR"> 
                AND itemstatus = <cfqueryparam value="Active" cfsqltype="CF_SQL_VARCHAR"> 
                AND contactID = <cfqueryparam value="#Arguments.ContactID#" cfsqltype="CF_SQL_INTEGER"> 
            ORDER BY 
                valuetext
        </cfquery>

<cfreturn result>
</cffunction>
</cfcomponent>
