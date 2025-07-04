<!--- This ColdFusion page processes contact information and exports it to an Excel file. --->

<cfparam name="new_exportid" default="" />
<cfparam name="new_contactid" default="" />
<cfparam name="new_FirstName" default="" />
<cfparam name="new_LastName" default="" />
<cfparam name="new_Tag1" default="" />
<cfparam name="new_Tag2" default="" />
<cfparam name="new_Tag3" default="" />
<cfparam name="new_BusinessEmail" default="" />
<cfparam name="new_PersonalEmail" default="" />
<cfparam name="new_WorkPhone" default="" />
<cfparam name="new_MobilePhone" default="" />
<cfparam name="new_HomePhone" default="" />
<cfparam name="new_Company" default="" />
<cfparam name="new_Address" default="" />
<cfparam name="new_Address2" default="" />
<cfparam name="new_City" default="" />
<cfparam name="new_State" default="" />
<cfparam name="new_Zip" default="" />
<cfparam name="new_Country" default="" />
<cfparam name="new_ContactMeetingDate" default="" />
<cfparam name="new_ContactMeetingLocation" default="" />
<cfparam name="new_contactbirthday" default="" />
<cfparam name="new_Website" default="" />
<cfparam name="idlist" default="0" />

<cfinclude template="/include/qry/AddExport_115_1.cfm" />

<cfinclude template="/include/qry/x_115_2.cfm" />

<!--- Loop through the query results to process each contact. --->
<cfloop query="x">

    <cfset new_Tag1 = "" />
    <cfset new_Tag2 = "" />
    <cfset new_Tag3 = "" />
    <cfset new_BusinessEmail = "" />
    <cfset new_PersonalEmail = "" />
    <cfset new_WorkPhone = "" />
    <cfset new_MobilePhone = "" />
    <cfset new_HomePhone = "" />
    <cfset new_Company = "" />
    <cfset new_Address = "" />
    <cfset new_Address2 = "" />
    <cfset new_City = "" />
    <cfset new_State = "" />
    <cfset new_Zip = "" />
    <cfset new_Country = "" />
    <cfset new_Website = "" />
    <cfset new_contactid = x.new_contactid />
    <cfset new_FirstName = x.new_FirstName />
    <cfset new_LastName = x.new_LastName />
    <cfset new_contactmeetingdate = x.new_contactmeetingdate />
    <cfset new_ContactMeetingLoc = x.new_ContactMeetingLoc />
    <cfset new_contactbirthday = x.new_contactbirthday />

    <cfinclude template="/include/qry/find_new_Website_115_3.cfm" />

    <!--- Check if the website exists and set the variable. --->
    <cfif find_new_Website.recordcount eq 1>
        <cfset new_website = find_new_Website.new_website />
    </cfif>

    <cfinclude template="/include/qry/find_new_BusinessEmail_115_4.cfm" />

    <!--- Check if the business email exists and set the variable. --->
    <cfif find_new_BusinessEmail.recordcount eq 1>
        <cfset new_businessEmail = find_new_BusinessEmail.new_businessEmail />
    </cfif>

    <cfinclude template="/include/qry/find_new_PersonalEmail_115_5.cfm" />

    <!--- Check if the personal email exists and set the variable. --->
    <cfif find_new_PersonalEmail.recordcount eq 1>
        <cfset new_PersonalEmail = find_new_PersonalEmail.new_PersonalEmail />
    </cfif>

    <cfinclude template="/include/qry/find_new_Company_115_6.cfm" />

    <!--- Check if the company exists and set the variable. --->
    <cfif find_new_Company.recordcount eq 1>
        <cfset new_Company = find_new_Company.new_Company />
    </cfif>

    <cfinclude template="/include/qry/find_new_WorkPhone_115_7.cfm" />

    <!--- Check if the work phone exists and set the variable. --->
    <cfif find_new_WorkPhone.recordcount eq 1>
        <cfset new_WorkPhone = find_new_WorkPhone.new_WorkPhone />
    </cfif>

    <cfinclude template="/include/qry/find_new_mobilePhone_115_8.cfm" />

    <!--- Check if the mobile phone exists and set the variable. --->
    <cfif find_new_mobilePhone.recordcount eq 1>
        <cfset new_mobilePhone = find_new_mobilePhone.new_mobilePhone />
    </cfif>

    <cfinclude template="/include/qry/find_new_homePhone_115_9.cfm" />

    <!--- Check if the home phone exists and set the variable. --->
    <cfif find_new_homePhone.recordcount eq 1>
        <cfset new_homePhone = find_new_homePhone.new_homePhone />
    </cfif>

    <cfinclude template="/include/qry/find_new_address_115_10.cfm" />

    <!--- Check if the address exists and set the variable. --->
    <cfif find_new_address.recordcount eq 1>
        <cfset new_address = find_new_address.new_address />
        <cfset new_address2 = find_new_address.new_address2 />
        <cfset new_city = find_new_address.new_city />
        <cfset new_state = find_new_address.new_state />
        <cfset new_zip = find_new_address.new_zip />
    </cfif>

    <!--- If no address found, check other addresses. --->
    <cfif find_new_address.recordcount eq 0>
        <cfinclude template="/include/qry/find_new_address_other_115_11.cfm" />

        <!--- Check if the other address exists and set the variable. --->
        <cfif find_new_address_other.recordcount eq 1>
            <cfset new_address = find_new_address_other.new_address />
            <cfset new_address2 = find_new_address_other.new_address2 />
            <cfset new_city = find_new_address_other.new_city />
            <cfset new_state = find_new_address_other.new_state />
            <cfset new_zip = find_new_address_other.new_zip />
            <cfset new_country = find_new_address_other.new_country />
        </cfif>
    </cfif>

    <cfinclude template="/include/qry/find_new_tag_115_12.cfm" />

    <cfset i = 0 />

    <!--- Loop through the tags to assign them. --->
    <cfloop query="find_new_tag">
        <cfoutput>
            <cfset i = #i# + 1 />
        </cfoutput>

        <cfif #i# is "1">
            <cfset new_Tag1 = find_new_tag.tag />
        </cfif>

        <cfif #i# is "2">
            <cfset new_Tag2 = find_new_tag.tag />
        </cfif>

        <cfif #i# is "3">
            <cfset new_Tag3 = find_new_tag.tag />
        </cfif>
    </cfloop>

    <cfinclude template="/include/qry/insert_115_13.cfm" />

</cfloop>

<cfinclude template="/include/qry/updateExport_115_14.cfm" />

<cfinclude template="/include/qry/export_ac_115_15.cfm" />

<cfoutput>
    <cfset app_direct = "#session.userMediaPath#\" />
    <cfset sub_name_c = "#dateformat('#now()#','YYYYMMDD')#" />
    <cfset sub_name_d = "#timeformat('#now()#','HHMMSS')#" />
    <cfset fileName = "export#sub_name_c##sub_name_d#.xls" />

    <cfscript>
        cfspreadsheet(action="write", fileName="#app_direct#\#fileName#", query="export_ac", overwrite=true);
    </cfscript>

    <cfheader name="content-disposition" value="Attachment;filename=#fileName#">
    <cfcontent file="#app_direct#\#fileName#" type="application/vnd.ms-excel">
</cfoutput>
