<cfparam name="total_records" default="0"/>
<cfquery result="result" name="x">
Select * from contactsimport where status = 'Pending'
</cfquery>

<cfset total_records = x.recordcount />

<!--- WO-4.1: Pre-load all users by email in one batch query (was N+1: 1 query per import row) --->
<cfif x.recordcount GT 0>
    <cfset emailList = valueList(x.userEmail) />
    <cfquery name="allUsers">
        SELECT userid, useremail FROM taousers
        WHERE useremail IN (<cfqueryparam cfsqltype="cf_sql_varchar" value="#emailList#" list="true" />)
    </cfquery>
    <cfset userMap = structNew() />
    <cfloop query="allUsers">
        <cfset userMap[lcase(trim(allUsers.useremail))] = allUsers.userid />
    </cfloop>

    <!--- WO-4.1: Pre-load all system definitions once (was N+1: up to 2 queries per row) --->
    <cfquery name="allSystems">
        SELECT systemid, systemtype, systemscope FROM fusystems
        WHERE systemtype IN (
            <cfqueryparam cfsqltype="cf_sql_varchar" value="Targeted List" />,
            <cfqueryparam cfsqltype="cf_sql_varchar" value="Maintenance List" />
        )
    </cfquery>
    <cfset systemMap = structNew() />
    <cfloop query="allSystems">
        <cfset systemMap[allSystems.systemtype & "|" & allSystems.systemscope] = allSystems.systemid />
    </cfloop>
</cfif>

<cfloop query="x">

<cfset new_id = x.id />

<!--- Batch lookup: user by email from pre-loaded map --->
<cfset emailKey = lcase(trim(x.userEmail)) />
<cfif structKeyExists(userMap, emailKey)>

    <cfset new_userid = userMap[emailKey] />

    <!--- Contact duplicate check: stays per-row but parameterized --->
    <cfquery result="result" name="findcontact">
    SELECT * FROM contactdetails
    WHERE contactfullname = <cfqueryparam cfsqltype="cf_sql_varchar" value="#trim(x.fname)# #trim(x.lname)#" />
    AND contactStatus = 'Active'
    AND userid = <cfqueryparam cfsqltype="cf_sql_integer" value="#new_userid#" />
    </cfquery>

    <cfif findcontact.recordcount is "0">

<cfquery name="add" result="result">
        INSERT INTO contactdetails_tbl (userid, contactfullname, contactstatus)
        VALUES (
            <cfqueryparam cfsqltype="cf_sql_integer" value="#new_userid#" />,
            <cfqueryparam cfsqltype="cf_sql_varchar" value="#trim(x.fname)# #trim(x.lname)#" />,
            <cfqueryparam cfsqltype="cf_sql_varchar" value="Pending" />
        )
        </cfquery>

        <cfset new_contactid = result.generated_key />
         <cfset contactid = result.generated_key />

<cfquery result="result" name="update">
        UPDATE contactdetails
        SET contactstatus = 'Working'
        <cfif x.contactMeetingLoc is not "">
           ,contactmeetingloc = <cfqueryparam cfsqltype="cf_sql_varchar" value="#trim(x.contactMeetingLoc)#" />
            </cfif>

           <cfif x.contactMeetingDate is not "">
           ,contactMeetingDate = <cfqueryparam cfsqltype="cf_sql_date" value="#x.contactMeetingDate#" />
            </cfif>

            <cfif x.birthday_month is not "0">
                <cfset new_birthday_mm = numberformat(x.birthday_month,'99') />
            ,birthday_mm = <cfqueryparam cfsqltype="cf_sql_varchar" value="#new_birthday_mm#" />
            </cfif>

            <cfif x.birthday_day is not "0">
                <cfset new_birthday_dd = numberformat(x.birthday_day,'99') />
            ,birthday_dd = <cfqueryparam cfsqltype="cf_sql_varchar" value="#new_birthday_dd#" />
            </cfif>

WHERE contactid = <cfqueryparam cfsqltype="cf_sql_integer" value="#new_contactid#" />
        </cfquery>

<!--- Add tag --->

        <CFIF X.TAG IS NOT "">

                <cfset new_valuetext = trim(x.tag) />
                <cfset new_valuecategory = "Tag" />
                <cfset new_valuetype = "Tags" />

<cfquery name="add" result="result">
                INSERT INTO contactitems (contactid,valuetype,itemStatus,valueCategory,valuetext)
                VALUES (
                <cfqueryparam cfsqltype="cf_sql_integer" value="#new_contactid#" />
                ,<cfqueryparam cfsqltype="cf_sql_varchar" value="#trim(new_valuetype)#" />
                ,<cfqueryparam cfsqltype="cf_sql_varchar" value="Active" />
                ,<cfqueryparam cfsqltype="cf_sql_varchar" value="#trim(new_valuecategory)#" />
                ,<cfqueryparam cfsqltype="cf_sql_varchar" value="#trim(new_valuetext)#" />
                    )
                </cfquery>
        </CFIF>

<!--- Add Business Email --->

        <CFIF X.BUSINESS_EMAIL IS NOT "">

                <cfset new_valuetext = trim(x.BUSINESS_EMAIL) />
                <cfset new_valuecategory = "Email" />
                <cfset new_valuetype = "Business" />

<cfquery name="add" result="result">
                INSERT INTO contactitems (contactid,valuetype,itemStatus,valueCategory,valuetext)
                VALUES (
                <cfqueryparam cfsqltype="cf_sql_integer" value="#new_contactid#" />
                ,<cfqueryparam cfsqltype="cf_sql_varchar" value="#trim(new_valuetype)#" />
                ,<cfqueryparam cfsqltype="cf_sql_varchar" value="Active" />
                ,<cfqueryparam cfsqltype="cf_sql_varchar" value="#trim(new_valuecategory)#" />
                ,<cfqueryparam cfsqltype="cf_sql_varchar" value="#trim(new_valuetext)#" />
                    )
                </cfquery>

        </CFIF>

        <CFIF X.PERSONAL_EMAIL IS NOT "">

                <cfset new_valuetext = trim(x.PERSONAL_EMAIL) />
                <cfset new_valuecategory = "Email" />
                <cfset new_valuetype = "Personal" />

<cfquery name="add" result="result">
                INSERT INTO contactitems (contactid,valuetype,itemStatus,valueCategory,valuetext)
                VALUES (
                <cfqueryparam cfsqltype="cf_sql_integer" value="#new_contactid#" />
                ,<cfqueryparam cfsqltype="cf_sql_varchar" value="#trim(new_valuetype)#" />
                ,<cfqueryparam cfsqltype="cf_sql_varchar" value="Active" />
                ,<cfqueryparam cfsqltype="cf_sql_varchar" value="#trim(new_valuecategory)#" />
                ,<cfqueryparam cfsqltype="cf_sql_varchar" value="#trim(new_valuetext)#" />
                    )
                </cfquery>

        </CFIF>

<CFIF X.WORK_PHONE IS NOT "">

                <cfset new_valuetext = trim(x.WORK_PHONE) />
                <cfset new_valuecategory = "Phone" />
                <cfset new_valuetype = "Work" />

<cfquery name="add" result="result">
                INSERT INTO contactitems (contactid,valuetype,itemStatus,valueCategory,valuetext)
                VALUES (
                <cfqueryparam cfsqltype="cf_sql_integer" value="#new_contactid#" />
                ,<cfqueryparam cfsqltype="cf_sql_varchar" value="#trim(new_valuetype)#" />
                ,<cfqueryparam cfsqltype="cf_sql_varchar" value="Active" />
                ,<cfqueryparam cfsqltype="cf_sql_varchar" value="#trim(new_valuecategory)#" />
                ,<cfqueryparam cfsqltype="cf_sql_varchar" value="#trim(new_valuetext)#" />
                    )
                </cfquery>

        </CFIF>

        <CFIF X.MOBILE_PHONE IS NOT "">

                <cfset new_valuetext = trim(x.MOBILE_PHONE) />
                <cfset new_valuecategory = "Phone" />
                <cfset new_valuetype = "Mobile" />

<cfquery name="add" result="result">
                INSERT INTO contactitems (contactid,valuetype,itemStatus,valueCategory,valuetext)
                VALUES (
                <cfqueryparam cfsqltype="cf_sql_integer" value="#new_contactid#" />
                ,<cfqueryparam cfsqltype="cf_sql_varchar" value="#trim(new_valuetype)#" />
                ,<cfqueryparam cfsqltype="cf_sql_varchar" value="Active" />
                ,<cfqueryparam cfsqltype="cf_sql_varchar" value="#trim(new_valuecategory)#" />
                ,<cfqueryparam cfsqltype="cf_sql_varchar" value="#trim(new_valuetext)#" />
                    )
                </cfquery>

        </CFIF>

<CFIF X.HOME_PHONE IS NOT "">

                <cfset new_valuetext = trim(x.HOME_PHONE) />
                <cfset new_valuecategory = "Phone" />
                <cfset new_valuetype = "Home" />

<cfquery name="add" result="result">
                INSERT INTO contactitems (contactid,valuetype,itemStatus,valueCategory,valuetext)
                VALUES (
                <cfqueryparam cfsqltype="cf_sql_integer" value="#new_contactid#" />
                ,<cfqueryparam cfsqltype="cf_sql_varchar" value="#trim(new_valuetype)#" />
                ,<cfqueryparam cfsqltype="cf_sql_varchar" value="Active" />
                ,<cfqueryparam cfsqltype="cf_sql_varchar" value="#trim(new_valuecategory)#" />
                ,<cfqueryparam cfsqltype="cf_sql_varchar" value="#trim(new_valuetext)#" />
                    )
                </cfquery>

        </CFIF>

<CFIF X.COMPANY IS NOT "">

                <cfset new_valuetext = trim(x.COMPANY) />
                <cfset new_valuecategory = "Company" />
                <cfset new_valuetype = "Company" />

<cfquery name="add" result="result">
                INSERT INTO contactitems (contactid,valuetype,itemStatus,valueCategory,valuetext)
                VALUES (
                <cfqueryparam cfsqltype="cf_sql_integer" value="#new_contactid#" />
                ,<cfqueryparam cfsqltype="cf_sql_varchar" value="#trim(new_valuetype)#" />
                ,<cfqueryparam cfsqltype="cf_sql_varchar" value="Active" />
                ,<cfqueryparam cfsqltype="cf_sql_varchar" value="#trim(new_valuecategory)#" />

                ,<cfqueryparam cfsqltype="cf_sql_varchar" value="#trim(new_valuetext)#" />

)
                </cfquery>

        </CFIF>

         <CFIF X.ADDRESS IS NOT "">

                <cfset new_valuetext = trim(x.ADDRESS) />
                <cfset new_valuecategory = "Address" />
                <cfset new_valuetype = "Work" />

<cfquery name="add" result="result">
                INSERT INTO contactitems (contactid,valuetype,itemStatus,valueCategory,valuetext,valueStreetAddress,valueExtendedAddress,valueCity,valueRegion,valueCountry,valuePostalCode)
                VALUES (
                <cfqueryparam cfsqltype="cf_sql_integer" value="#new_contactid#" />
                ,<cfqueryparam cfsqltype="cf_sql_varchar" value="#trim(new_valuetype)#" />
                ,<cfqueryparam cfsqltype="cf_sql_varchar" value="Active" />
                ,<cfqueryparam cfsqltype="cf_sql_varchar" value="#trim(new_valuecategory)#" />
                ,<cfqueryparam cfsqltype="cf_sql_varchar" value="#trim(x.address)#" />
                ,<cfqueryparam cfsqltype="cf_sql_varchar" value="#trim(x.address_second)#" />
                ,<cfqueryparam cfsqltype="cf_sql_varchar" value="#trim(x.city)#" />
                ,<cfqueryparam cfsqltype="cf_sql_varchar" value="#trim(x.state)#" />
                ,<cfqueryparam cfsqltype="cf_sql_varchar" value="#trim(x.country)#" />
                ,<cfqueryparam cfsqltype="cf_sql_varchar" value="#trim(x.zip)#" />
                    )
                </cfquery>

        </CFIF>

    <cfif x.maintenance_or_target is "Target" >

<cfset NEW_SYSTEMTYPE = "Targeted List" />

<!--- WO-4.1: Tag check stays per-row (depends on just-inserted contactid) but parameterized --->
<cfquery result="result" name="findscope">
SELECT * FROM contactitems
WHERE valuecategory = 'Tag' AND valuetext = 'Casting Director'
AND contactid = <cfqueryparam cfsqltype="cf_sql_integer" value="#contactid#" />
AND itemstatus = 'Active'
</cfquery>

<cfif findscope.recordcount is "1">
<cfset new_systemscope = "Casting Director" />
<cfelse>
   <cfset new_systemscope = "Industry" />
</cfif>

<!--- WO-4.1: System lookup from pre-loaded map instead of per-row query --->
<cfset sysKey = NEW_SYSTEMTYPE & "|" & new_systemscope />
<cfif structKeyExists(systemMap, sysKey)>
            <cfset systemid = systemMap[sysKey] />
                <cfinclude template="add_system.cfm" />
</cfif>

       </cfif>

<cfif x.maintenance_or_target is "Maintenance" >

<cfset NEW_SYSTEMTYPE = "Maintenance List" />

<cfquery result="result" name="findscope">
SELECT * FROM contactitems
WHERE valuecategory = 'Tag' AND valuetext = 'Casting Director'
AND contactid = <cfqueryparam cfsqltype="cf_sql_integer" value="#contactid#" />
AND itemstatus = 'Active'
</cfquery>

<cfif findscope.recordcount is "1">
<cfset new_systemscope = "Casting Director" />
<cfelse>
   <cfset new_systemscope = "Industry" />
</cfif>

<!--- WO-4.1: System lookup from pre-loaded map instead of per-row query --->
<cfset sysKey = NEW_SYSTEMTYPE & "|" & new_systemscope />
<cfif structKeyExists(systemMap, sysKey)>
            <cfset systemid = systemMap[sysKey] />
                <cfinclude template="add_system.cfm" />
</cfif>

       </cfif>

<cfset select_userid = new_userid />
<cfset select_contactid = new_contactid />
<cfinclude template="folder_setup.cfm" />

<cfquery result="result" name="update">
        UPDATE contactdetails
        SET contactstatus = 'Active'
        WHERE contactid = <cfqueryparam cfsqltype="cf_sql_integer" value="#contactid#" />
        </cfquery>

<cfquery result="result" name="update">
        UPDATE contactsimport
        SET status = 'Completed'
        WHERE id = <cfqueryparam cfsqltype="cf_sql_integer" value="#new_id#" />
        </cfquery>

        <cfelse>
         <cfquery result="result" name="update">
        UPDATE contactsimport
        SET status = 'Duplicate'
        WHERE id = <cfqueryparam cfsqltype="cf_sql_integer" value="#new_id#" />
        </cfquery>

</cfif>

</cfif>

</cfloop>
