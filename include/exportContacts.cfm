<!--- 
    PURPOSE: Export contact information to Excel file
    AUTHOR: System
    DATE: 2025-10-09
    PARAMETERS: idlist (comma-separated contact IDs)
    RETURNS: Excel file download
--->

<cftry>
    <!--- Parameter definitions --->
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

    <!--- Validate required parameters --->
    <cfif not isDefined('idlist') or idlist eq "0" or len(trim(idlist)) eq 0>
        <cfthrow message="No contacts selected for export. Please select contacts from the list and try again." type="validation">
    </cfif>

    <!--- Validate user session --->
    <cfif not isDefined('session.userMediaPath') or len(trim(session.userMediaPath)) eq 0>
        <cfthrow message="User session invalid. Please log in again." type="session">
    </cfif>

    <!--- Execute export initialization queries --->
    <cfinclude template="/include/qry/AddExport_115_1.cfm" />
    <cfinclude template="/include/qry/x_115_2.cfm" />

    <!--- Validate we have contacts to export --->
    <cfif not isDefined('x') or x.recordcount eq 0>
        <cfthrow message="No contact records found for the selected IDs. Please check your selection and try again." type="data">
    </cfif>

    <!--- Loop through the query results to process each contact --->
    <cfloop query="x">    <cfset new_Tag1 = "" />
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

<cftry>
    <!--- Validate we have data to export --->
    <cfif not isDefined('export_ac') or export_ac.recordcount eq 0>
        <cfthrow message="No data found to export. Please select contacts and try again." type="validation">
    </cfif>

    <cfoutput>
        <!--- Create safe file paths --->
        <cfset app_direct = session.userMediaPath />
        <cfset sub_name_c = dateFormat(now(), "YYYYMMDD") />
        <cfset sub_name_d = timeFormat(now(), "HHMMSS") />
        <cfset fileName = "contacts_export_#sub_name_c#_#sub_name_d#.xlsx" />
        <cfset fullFilePath = "#app_direct#/#fileName#" />

        <!--- Ensure directory exists --->
        <cfif not directoryExists(app_direct)>
            <cfdirectory action="create" directory="#app_direct#" mode="755">
        </cfif>

        <!--- Create Excel file --->
        <cfspreadsheet 
            action="write" 
            filename="#fullFilePath#" 
            query="export_ac" 
            overwrite="true"
            format="xlsx"
            sheetname="Contacts Export">

        <!--- Verify file was created --->
        <cfif not fileExists(fullFilePath)>
            <cfthrow message="Failed to create export file. Please check permissions and try again." type="file">
        </cfif>

        <!--- Send file to browser --->
        <cfheader name="Content-Disposition" value="attachment; filename=#fileName#">
        <cfheader name="Content-Type" value="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet">
        <cfcontent file="#fullFilePath#" type="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet" deletefile="false">
    </cfoutput>

    <cfcatch>
        <!--- Error handling with user-friendly messages --->
        <cfif cfcatch.type eq "validation">
            <cfoutput>
                <script>
                    alert('Export Error: #cfcatch.message#');
                    window.history.back();
                </script>
            </cfoutput>
        <cfelse>
            <cfoutput>
                <script>
                    alert('Export failed: #cfcatch.message#\n\nPlease contact support if this problem persists.');
                    window.history.back();
                </script>
            </cfoutput>
            <!--- Log the error for debugging --->
            <cflog file="contact_export_errors" text="Export Error: #cfcatch.message# | Detail: #cfcatch.detail# | User: #session.userid#">
        </cfif>
    </cfcatch>
</cftry>

<cfcatch>
    <!--- Handle any uncaught errors in the main process --->
    <cfoutput>
        <script>
            alert('Export process failed: #cfcatch.message#\n\nPlease try again or contact support.');
            window.history.back();
        </script>
    </cfoutput>
    <cflog file="contact_export_errors" text="Main Export Error: #cfcatch.message# | Detail: #cfcatch.detail# | User: #session.userid# | IDList: #idlist#">
</cfcatch>
</cftry>
