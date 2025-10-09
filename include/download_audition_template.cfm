<!---
    PURPOSE: Download handler for audition import template
    AUTHOR: Kevin King
    DATE: 2025-10-09
    RETURNS: Excel file download
--->

<cfsetting enablecfoutputonly="true">

<cftry>
    <!--- Set the file path (adjust as needed based on your file location) --->
    <cfset templatePath = expandPath("../assets/templates/audition_import_template.xlsx")>
    
    <!--- Alternative: Check if the application variable points to a valid file --->
    <cfif isDefined("application.auditionimporttemplate") AND fileExists(expandPath(application.auditionimporttemplate))>
        <cfset templatePath = expandPath(application.auditionimporttemplate)>
    <cfelseif fileExists(expandPath("../assets/audition_import_template.xlsx"))>
        <cfset templatePath = expandPath("../assets/audition_import_template.xlsx")>
    <cfelseif fileExists(expandPath("./templates/audition_import_template.xlsx"))>
        <cfset templatePath = expandPath("./templates/audition_import_template.xlsx")>
    <cfelse>
        <!--- If no template file found, create a simple CSV template instead --->
        <cfheader name="Content-Disposition" value="attachment; filename=audition_import_template.csv">
        <cfheader name="Content-Type" value="text/csv">
        <cfcontent type="text/csv">
        
        <cfoutput>Project Date,Project Name,Role Name,Category,Source,CD First Name,CD Last Name,Callback,Redirect,Pin,Booked,Project Description,Character Description,Notes
01/01/2025,Sample Project,Sample Role,Film,Casting Director,John,Doe,N,N,N,N,Sample project description,Sample character description,Sample notes</cfoutput>
        <cfabort>
    </cfif>
    
    <!--- Check if file exists --->
    <cfif NOT fileExists(templatePath)>
        <cfthrow message="Template file not found at: #templatePath#">
    </cfif>
    
    <!--- Set appropriate headers for Excel download --->
    <cfheader name="Content-Disposition" value="attachment; filename=audition_import_template.xlsx">
    <cfheader name="Content-Type" value="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet">
    
    <!--- Stream the file --->
    <cfcontent file="#templatePath#" type="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet">

    <cfcatch>
        <!--- If there's an error, provide a fallback CSV template --->
        <cfheader statuscode="200" statustext="OK">
        <cfheader name="Content-Disposition" value="attachment; filename=audition_import_template.csv">
        <cfheader name="Content-Type" value="text/csv">
        <cfcontent type="text/csv" reset="true">
        
        <cfoutput>Project Date,Project Name,Role Name,Category,Source,CD First Name,CD Last Name,Callback,Redirect,Pin,Booked,Project Description,Character Description,Notes
01/01/2025,Sample Project,Sample Role,Film,Casting Director,John,Doe,N,N,N,N,Sample project description,Sample character description,Sample notes</cfoutput>
    </cfcatch>
</cftry>