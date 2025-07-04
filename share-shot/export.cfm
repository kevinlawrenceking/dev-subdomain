

<cfset ShareService = createObject("component", "services.ShareService")>
<cfset shares = ShareService.GetShareDetailsByAudition(userid=userid)>


<cfset userService = createObject("component", "services.UserService")>
<cfset x = userService.GetUserDetails(userid=userid) />


<cfoutput>
    
    <cfset sub_name_a = "#x.userfirstname#_#x.userlastname#" />

<cfset sub_name_b = "#Replace(sub_name_a,' ','','all')#" />

<cfset sub_name_c = "#dateformat('#now()#','YYYYMMDD')#" />   
    <cfset sub_name_d = "#timeformat('#now()#','HHMMSS')#" />   

<cfset fileName = "#sub_name_b##sub_name_c##sub_name_d#.xls" />
<Cfset share_dir="C:\home\theactorsoffice.com\media-" & dsn & "\share">
<cfscript>
cfspreadsheet( action="write", fileName="#share_dir#\#fileName#", query="shares", overwrite=true );
    </cfscript>

    <cfheader name="content-disposition"  value="Attachment;filename=#fileName#">
<cfcontent  file="#share_dir#\#fileName#"  type="application/vnd.ms-excel">

    </cfoutput>
