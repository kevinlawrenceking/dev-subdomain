<!---
    PURPOSE: Download CSV template for audition import
    Headers match the importer's most common auto-mapped fields.
    Column mapping is flexible -- headers only need to be close; users can
    remap on the Map Columns step.
--->

<cfsetting enablecfoutputonly="true">

<cfheader name="Content-Disposition" value="attachment; filename=audition_import_template.csv">
<cfheader name="Content-Type" value="text/csv">
<cfcontent type="text/csv" reset="true"><cfoutput>Project Name,Role,Casting Director,Audition Date,Audition Time,Location,Category,Contact Name,Contact Email,Notes
,,,,,,,,,</cfoutput>
<cfabort>
