<cfcomponent displayname="ExportItemService" hint="Handles operations for ExportItem table" >

<cffunction output="false" name="INSexportitems" access="public" returntype="void">
    <cfargument name="new_exportid" type="numeric" required="true">
    <cfargument name="new_contactid" type="numeric" required="true">
    <cfargument name="new_FirstName" type="string" required="false" default="">
    <cfargument name="new_LastName" type="string" required="false" default="">
    <cfargument name="new_Tag1" type="string" required="false" default="">
    <cfargument name="new_Tag2" type="string" required="false" default="">
    <cfargument name="new_Tag3" type="string" required="false" default="">
    <cfargument name="new_BusinessEmail" type="string" required="false" default="">
    <cfargument name="new_PersonalEmail" type="string" required="false" default="">
    <cfargument name="new_WorkPhone" type="string" required="false" default="">
    <cfargument name="new_MobilePhone" type="string" required="false" default="">
    <cfargument name="new_HomePhone" type="string" required="false" default="">
    <cfargument name="new_Company" type="string" required="false" default="">
    <cfargument name="new_Address" type="string" required="false" default="">
    <cfargument name="new_Address2" type="string" required="false" default="">
    <cfargument name="new_City" type="string" required="false" default="">
    <cfargument name="new_State" type="string" required="false" default="">
    <cfargument name="new_Zip" type="string" required="false" default="">
    <cfargument name="new_Country" type="string" required="false" default="">
    <cfargument name="new_ContactMeetingDate" type="string" required="false">
    <cfargument name="new_ContactMeetingLoc" type="string" required="false">
    <cfargument name="new_contactBirthday" type="string" required="false">
    <cfargument name="new_Website" type="string" required="false">

<cfquery result="result">
            INSERT INTO exportitems (
                exportid, contactid, FirstName, LastName, Tag1, Tag2, Tag3, BusinessEmail, PersonalEmail,
                WorkPhone, MobilePhone, HomePhone, Company, Address, Address2, City, State, Zip, Country,
                ContactMeetingDate, ContactMeetingLoc, contactBirthday, Website
            ) VALUES (
                <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#arguments.new_exportid#" />,
                <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#arguments.new_contactid#" />,
                <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.new_FirstName#" maxlength=1000 null="#NOT len(trim(arguments.new_FirstName))#" />,
                <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.new_LastName#" maxlength=1000 null="#NOT len(trim(arguments.new_LastName))#" />,
                <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.new_Tag1#" maxlength=1000 null="#NOT len(trim(arguments.new_Tag1))#" />,
                <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.new_Tag2#" maxlength=1000 null="#NOT len(trim(arguments.new_Tag2))#" />,
                <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.new_Tag3#" maxlength=1000 null="#NOT len(trim(arguments.new_Tag3))#" />,
                <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.new_BusinessEmail#" maxlength=1000 null="#NOT len(trim(arguments.new_BusinessEmail))#" />,
                <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.new_PersonalEmail#" maxlength=1000 null="#NOT len(trim(arguments.new_PersonalEmail))#" />,
                <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.new_WorkPhone#" maxlength=1000 null="#NOT len(trim(arguments.new_WorkPhone))#" />,
                <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.new_MobilePhone#" maxlength=1000 null="#NOT len(trim(arguments.new_MobilePhone))#" />,
                <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.new_HomePhone#" maxlength=1000 null="#NOT len(trim(arguments.new_HomePhone))#" />,
                <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.new_Company#" maxlength=1000 null="#NOT len(trim(arguments.new_Company))#" />,
                <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.new_Address#" maxlength=1000 null="#NOT len(trim(arguments.new_Address))#" />,
                <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.new_Address2#" maxlength=1000 null="#NOT len(trim(arguments.new_Address2))#" />,
                <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.new_City#" maxlength=1000 null="#NOT len(trim(arguments.new_City))#" />,
                <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.new_State#" maxlength=1000 null="#NOT len(trim(arguments.new_State))#" />,
                <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.new_Zip#" maxlength=1000 null="#NOT len(trim(arguments.new_Zip))#" />,
                <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.new_Country#" maxlength=1000 null="#NOT len(trim(arguments.new_Country))#" />,
                <cfqueryparam cfsqltype="CF_SQL_DATE" value="#arguments.new_ContactMeetingDate#"
                    null = "#NOT isDate(arguments.new_ContactMeetingDate)#"/>,
                <cfqueryparam cfsqltype = "CF_SQL_VARCHAR"
                    value = "#arguments.new_ContactMeetingLoc#"
                    maxlength = 1000
                    null = "#NOT len(trim(arguments.new_ContactMeetingLoc))#"/>,
                <cfqueryparam cfsqltype = "CF_SQL_DATE"
                    value = "#arguments.new_contactBirthday#"
                    null = "#NOT isDate(arguments.new_contactBirthday)#"/>,
                <cfqueryparam cfsqltype = "CF_SQL_VARCHAR"
                    value = "#arguments.new_Website#"
                    maxlength = 1000
                    null = "#NOT len(trim(arguments.new_Website))#"/>
            )
        </cfquery>

</cffunction>

<cffunction output="false" name="SELexportitems" access="public" returntype="query">
    <cfargument name="exportID" type="numeric" required="true">

<cfquery name="result" >
            SELECT 
                contactid AS ID, 
                FirstName, 
                lastname, 
                Tag1, 
                Tag2, 
                Tag3, 
                BusinessEmail, 
                PersonalEmail, 
                WorkPhone, 
                MobilePhone, 
                HomePhone, 
                Company, 
                Address, 
                Address2, 
                City, 
                State, 
                Zip, 
                Country, 
                ContactMeetingDate, 
                ContactMeetingLoc, 
                ContactBirthday, 
                Website
            FROM exportitems
            WHERE exportid = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.exportID#" />
        </cfquery>

<cfreturn result>
</cffunction>
</cfcomponent>
