<!---
    PURPOSE: Download handler for contact import template
    AUTHOR: Kevin King
    DATE: 2025-10-09
    UPDATED: 2025-11-26 - Phase 1: Added CSV format support
    RETURNS: Excel (.xlsx) or CSV file download based on format parameter
--->

<cfsetting enablecfoutputonly="true">

<!--- Allow user to specify format via URL parameter --->
<cfparam name="url.format" default="xlsx">

<!--- Define template column names (must match upload.cfm expectations) --->
<cfset templateColumns = "FirstName,LastName,Tag1,Tag2,Tag3,BusinessEmail,PersonalEmail,WorkPhone,MobilePhone,HomePhone,Company,Address,Address2,City,State,Zip,Country,contactMeetingDate,contactMeetingLoc,Birthday,website,Notes">

<!--- Sample data for template --->
<cfset sampleRow1 = 'John,Doe,Casting Director,,,john@example.com,johndoe@gmail.com,(555) 123-4567,(555) 123-4568,,ABC Casting,"123 Main St",Suite 100,Los Angeles,CA,90001,USA,2025-01-15,Starbucks on Sunset,1985-03-20,https://example.com,"Met at industry workshop"'>
<cfset sampleRow2 = 'Jane,Smith,Agent,Manager,,jane@agency.com,janesmith@gmail.com,(555) 987-6543,(555) 987-6544,,Smith Talent,"456 Oak Ave",,New York,NY,10001,USA,,,1990-06-15,,"Referral from Mike"'>

<cftry>
    <!--- ========================================
          CSV FORMAT DOWNLOAD
         ======================================== --->
    <cfif url.format EQ "csv">
        <!--- Set CSV headers --->
        <cfheader name="Content-Disposition" value="attachment; filename=contact_import_template.csv">
        <cfheader name="Content-Type" value="text/csv; charset=utf-8">
        <cfcontent type="text/csv" reset="true">

        <!--- Output CSV content --->
        <cfoutput>#templateColumns#
#sampleRow1#
#sampleRow2#</cfoutput>
        <cfabort>

    <!--- ========================================
          XLSX FORMAT DOWNLOAD
         ======================================== --->
    <cfelseif url.format EQ "xlsx">
        <cfset templatePath = "">

        <!--- Check multiple possible locations for the XLSX template --->
        <cfif fileExists(expandPath("./ImportTemplate2.xlsx"))>
            <cfset templatePath = expandPath("./ImportTemplate2.xlsx")>
        <cfelseif fileExists(expandPath("../assets/templates/contact_import_template.xlsx"))>
            <cfset templatePath = expandPath("../assets/templates/contact_import_template.xlsx")>
        <cfelseif fileExists(expandPath("../assets/ImportTemplate2.xlsx"))>
            <cfset templatePath = expandPath("../assets/ImportTemplate2.xlsx")>
        <cfelseif fileExists(expandPath("./templates/contact_import_template.xlsx"))>
            <cfset templatePath = expandPath("./templates/contact_import_template.xlsx")>
        </cfif>

        <!--- If XLSX template found, stream it --->
        <cfif templatePath NEQ "" AND fileExists(templatePath)>
            <cfheader name="Content-Disposition" value="attachment; filename=contact_import_template.xlsx">
            <cfheader name="Content-Type" value="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet">
            <cfcontent file="#templatePath#" type="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet">
            <cfabort>
        <cfelse>
            <!--- XLSX template not found, fall back to CSV --->
            <cfheader name="Content-Disposition" value="attachment; filename=contact_import_template.csv">
            <cfheader name="Content-Type" value="text/csv; charset=utf-8">
            <cfcontent type="text/csv" reset="true">

            <cfoutput>#templateColumns#
#sampleRow1#
#sampleRow2#</cfoutput>
            <cfabort>
        </cfif>

    <!--- ========================================
          INVALID FORMAT - DEFAULT TO CSV
         ======================================== --->
    <cfelse>
        <cfheader name="Content-Disposition" value="attachment; filename=contact_import_template.csv">
        <cfheader name="Content-Type" value="text/csv; charset=utf-8">
        <cfcontent type="text/csv" reset="true">

        <cfoutput>#templateColumns#
#sampleRow1#
#sampleRow2#</cfoutput>
        <cfabort>
    </cfif>

    <cfcatch>
        <!--- If there's an error, provide a fallback CSV template --->
        <cfheader statuscode="200" statustext="OK">
        <cfheader name="Content-Disposition" value="attachment; filename=contact_import_template.csv">
        <cfheader name="Content-Type" value="text/csv; charset=utf-8">
        <cfcontent type="text/csv" reset="true">

        <cfoutput>#templateColumns#
#sampleRow1#
#sampleRow2#</cfoutput>
    </cfcatch>
</cftry>