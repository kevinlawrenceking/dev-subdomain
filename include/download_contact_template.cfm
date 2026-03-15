<!---
    PURPOSE: Download CSV template for V3 contact import
    Headers match V3 importer field definitions for auto-mapping
--->

<cfsetting enablecfoutputonly="true">

<cfheader name="Content-Disposition" value="attachment; filename=contact_import_template.csv">
<cfheader name="Content-Type" value="text/csv">
<cfcontent type="text/csv" reset="true"><cfoutput>First Name,Last Name,Email,Phone,Company,Title,Address,City,State,Zip,Country,Tag,Notes
,,,,,,,,,,,,</cfoutput>
<cfabort>