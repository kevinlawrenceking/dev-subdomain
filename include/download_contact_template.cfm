<!---
    PURPOSE: Download handler for contact import template
    AUTHOR: Kevin King
    DATE: 2025-10-09
    RETURNS: Excel file download
--->

<cfsetting enablecfoutputonly="true">

<cftry>
    <!--- Set possible template paths --->
    <cfset templatePath = "">
    
    <!--- Check multiple possible locations for the template --->
    <cfif fileExists(expandPath("./ImportTemplate2.xlsx"))>
        <cfset templatePath = expandPath("./ImportTemplate2.xlsx")>
    <cfelseif fileExists(expandPath("../assets/templates/contact_import_template.xlsx"))>
        <cfset templatePath = expandPath("../assets/templates/contact_import_template.xlsx")>
    <cfelseif fileExists(expandPath("../assets/ImportTemplate2.xlsx"))>
        <cfset templatePath = expandPath("../assets/ImportTemplate2.xlsx")>
    <cfelseif fileExists(expandPath("./templates/contact_import_template.xlsx"))>
        <cfset templatePath = expandPath("./templates/contact_import_template.xlsx")>
    <cfelse>
        <!--- If no template file found, create a simple CSV template instead --->
        <cfheader name="Content-Disposition" value="attachment; filename=contact_import_template.csv">
        <cfheader name="Content-Type" value="text/csv">
        <cfcontent type="text/csv">
        
        <cfoutput>First Name,Last Name,Phone Number,Email Address,Company,Title
John,Doe,(555) 123-4567,john.doe@email.com,Sample Company,Sample Title
Jane,Smith,(555) 987-6543,jane.smith@email.com,Another Company,Another Title</cfoutput>
        <cfabort>
    </cfif>
    
    <!--- Check if file exists --->
    <cfif NOT fileExists(templatePath)>
        <cfthrow message="Template file not found at: #templatePath#">
    </cfif>
    
    <!--- Set appropriate headers for Excel download --->
    <cfheader name="Content-Disposition" value="attachment; filename=contact_import_template.xlsx">
    <cfheader name="Content-Type" value="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet">
    
    <!--- Stream the file --->
    <cfcontent file="#templatePath#" type="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet">

    <cfcatch>
        <!--- If there's an error, provide a fallback CSV template --->
        <cfheader statuscode="200" statustext="OK">
        <cfheader name="Content-Disposition" value="attachment; filename=contact_import_template.csv">
        <cfheader name="Content-Type" value="text/csv">
        <cfcontent type="text/csv" reset="true">
        
        <cfoutput>First Name,Last Name,Phone Number,Email Address,Company,Title
John,Doe,(555) 123-4567,john.doe@email.com,Sample Company,Sample Title
Jane,Smith,(555) 987-6543,jane.smith@email.com,Another Company,Another Title</cfoutput>
    </cfcatch>
</cftry>