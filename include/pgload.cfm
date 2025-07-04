<cfparam name="TIMETITLE" default="" />
<cfparam name="pgaction" default="view" />
<cfparam name="subdomain" default="app" />
<cfparam name="thispage2" default="" />
<cfparam name="rpgid" default="0" />
<cfparam name="usercontactid" default="0" />
<cfparam name="catArea_UCB" default="C" />
<cfparam name="contactid" default="0" />
<cfparam name="userid" default="#session.userid#" />
<cfparam name="BROWSER_CONTACT_AVATAR_FILENAME" default="" />
<Cfparam name="session.userCalendarPath" default="" />
<Cfparam name="session.userCalendarUrl" default="" />
<cfscript>
    currentURL = cgi.server_name;
    host = ListFirst(currentURL, ".");
    thisPath = ExpandPath("*.*");
    thisDirectory = GetDirectoryFromPath(thisPath);
    thispage = ListLast(thisDirectory, "\"); 
    currentpage = cgi.script_name & "?" & cgi.query_string;
    returnpage = cgi.script_name & "?" & cgi.query_string;
</cfscript>

<cfinclude template="/include/toast.cfm" />

<cfif isdefined('dn')>
    <!--- Include update script if 'dn' is defined. --->
    <cfinclude template="/include/qry/update_187_1.cfm" />
</cfif>

<cfif isdefined('ca') AND ca EQ "Y">
    <!--- Include second update script if 'ca' is defined and equals 'Y'. --->
    <cfinclude template="/include/qry/update_187_2.cfm" />
    <cfset StructDelete(Variables, "ca") />
</cfif>

<!--- Set calendar root directory and URL from session variables. --->
<Cfset Cal_root_dir = session.userCalendarPath />
<Cfset cal_root_url = session.userCalendarUrl />
<Cfset cookie.userid = userid />

<cfinclude template="/include/qry/fetchusers.cfm" />
<cfinclude template="/include/fetchPageService.cfm" />

<cfif pgFilename NEQ "">
    <!--- Define the full path of the file you want to check. --->
    <cfset filePath = expandPath("/include/qry/#pgFilename#")>

    <!--- Check if the file exists and only include if it does. --->
    <cfif fileExists(filePath)>
        <cfinclude template="/include/qry/#pgFilename#" />
    </cfif>
</cfif>
