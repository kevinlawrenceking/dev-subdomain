<Cfset projectlist = session.projectlist />
<cfinclude template="/include/qry/export_ac_31_6.cfm">
    <cfset sub_name_c=dateFormat(now(),"YYYYMMDD")>
    <cfset sub_name_d=timeFormat(now(),"HHMMSS")>
    <cfset fileName="export_auditions_#sub_name_c##sub_name_d#.xls">
   
    <cfscript>
        cfspreadsheet(action="write", filename="#session.userMediaPath#\#fileName#", query="export_ac", overwrite=true);
    </cfscript>

     <cfheader name="content-disposition" value="Attachment;filename=#fileName#">
    <cfcontent file="#session.userMediaPath#\#fileName#" type="application/vnd.ms-excel">