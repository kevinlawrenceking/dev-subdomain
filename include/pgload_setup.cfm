<!--- This ColdFusion page handles user session management, retrieves user data, and includes various query templates to display user-related information. --->
<cfif NOT #isdefined('userid')# >
    <!--- Redirect to login if user is not defined --->
    <cflocation url="/loginform.cfm" />
</cfif>

<cfparam name="catArea_UCB" default="C" />
<cfparam name="contactid" default="0" />

<!--- Include user query template --->
<cfinclude template="/include/qry/FindUser_188_1.cfm" />

<cfoutput>
    <!--- Output user record count --->
    finduser.recordcount: #FindUser.recordcount#<BR>
    
    <!--- Set user media paths --->
    <cfset session.userMediaPath = "c:\home\theactorsoffice.com\wwwroot\#host#-subdomain\media-#host#\users\#finduser.userid#" />   
    <cfset session.userAvatarPath = "#session.userMediaPath#\avatar.jpg" />
    <cfset session.userMediaUrl = "/media-#host#/users/#finduser.userid#" />  
    <cfset session.contactAvatarUrl = "#session.userMediaUrl#/avatar.jpg" />
    <cfset dir_user_imports_loc = "#session.userMediaPath#\imports" />     
    <cfset dir_contact_avatar_loc = "c:\home\theactorsoffice.com\wwwroot\#host#-subdomain\media-#host#\users\#finduser.userid#\contacts\#contactid#" /> 
    <cfset dir_contact_avatar_filename = "#dir_contact_avatar_loc#\avatar.jpg" />
    <cfset browser_contact_avatar_loc = "/media-#host#/users/#finduser.userid#/contacts/#contactid#" />   
    <cfset browser_contact_avatar_filename = "#browser_contact_avatar_loc#/avatar.jpg" />
    
    <!--- Prepare calendar names and URLs --->
    <cfset calendar_name3 = "#FindUser.userfirstname##FindUser.userlastname#" />
    <cfset calendar_name2 = #REReplace(calendar_name3, "[^0-9A-Za-z ]", "", "all")# />
    <cfset calendar_name = #replace(calendar_name2, " ", "", "all")# />
    <cfset calendar_dir = "#cal_root_dir##calendar_name#.ics" />      
    <cfset calendar_url = "#cal_root_url##calendar_name#.ics" />   
    
    <!--- Output avatar name --->
    finduser.avatarname: #FindUser.avatarname#<BR>
</cfoutput>

<cfif #FindUser.avatarname# is "">
    <!--- Include template to insert contact if avatar name is empty --->
    <cfinclude template="/include/qry/InsertContact_188_2.cfm" />   
</cfif>

<cfif #FindUser.contactid# is "">
    <!--- Include template to insert contact if contact ID is empty --->
    <cfinclude template="/include/qry/InsertContact_188_3.cfm" />
    <cfinclude template="/include/qry/InsertContact_188_4.cfm" />     
    <cfinclude template="/include/qry/FindUser_188_5.cfm" />
</cfif>

<!--- Include page query template --->
<cfinclude template="/include/qry/FindPage_188_6.cfm" />
<cfoutput>  
    FindPage.recordcount: #FindPage.recordcount#<BR>
</cfoutput>

<!--- Include fields query template --->
<cfinclude template="/include/qry/FindFields_188_7.cfm" />
<cfoutput>  
    pgid: #findpage.pgid#<BR>
    FindFields.FindFields: #FindFields.recordcount#<BR>
</cfoutput>

<cfif #FindPage.RecordCount# is "1">
    <!--- Include links templates if record count is 1 --->
    <cfinclude template="/include/qry/FindLinksT_188_8.cfm" />
    <cfoutput>  
        Findlinkst.recordcount: #findlinkst.recordcount#
    </cfoutput>
    <cfinclude template="/include/qry/FindLinksB_188_9.cfm" />
    <cfoutput>  
        Findlinksb.recordcount: #findlinksb.recordcount#
    </cfoutput>
    <cfinclude template="/include/qry/FindLinksExtra_188_10.cfm" />
    
    <!--- Application variables --->
    <cfset appName = FindPage.appName />
    <cfset appDescription = FindPage.appDescription />  
    <cfset appAuthor = FindPage.appAuthor />  
    <cfset appLogoName = FindPage.appLogoName />
    <cfset colorTopBar = FindPage.colorTopBar />
    <cfset colorLeftSideBar = FindPage.colorLeftSideBar />
    <cfset home = "/app/dashboard" />
    <cfset mocktoday = FindPage.mocktoday />
    <cfset mock_yn = FindPage.mock_yn />
    
    <!--- Component variables --->
    <cfset compid = FindPage.compid />
    <cfset compname = FindPage.compname /> 
    <cfset compDir = FindPage.compDir />
    <cfset compTable = FindPage.compTable />
    <cfset compowner = FindPage.compowner />
    
    <!--- Page variables --->
    <cfset pgid = FindPage.pgid />
    <cfset cookie.pgid = pgid />   
    <cfset pgname = FindPage.pgname />    
    <cfset pgDir = FindPage.pgDir />
    <cfset pgTitle = FindPage.pgTitle />
    <cfset pgHeading = FindPage.pgHeading />
    <cfset pgFilename = FindPage.pgFilename />
    <cfset update_type = FindPage.update_type />
    
    <!--- User variables --->
    <cfset userid = userid />
    <cfset userContactid = FindUser.userContactID />
    <cfset userCalStarttime = FindUser.calstarttime />
    <cfset userCalendtime = FindUser.calendtime />    
    <cfset avatarname = FindUser.avatarname />  
    <cfset isbetatester = FindUser.IsBetaTester />  
    <cfset defrows = FindUser.defRows + 1 />  
    <cfset defcountry = FindUser.defCountry />  
    <cfset defState = FindUser.defState />  
    <cfset tzid = FindUser.tzid />
    <cfset customerid = FindUser.customerid /> 
        
    <cfif "#usercontactid#" is "#contactid#" >
        <cfset catArea_UCB = "U" />
    </cfif>

    <cfset userFirstName = FindUser.userFirstName />
    <cfset userLastName = FindUser.userLastName />
    <cfset userEmail = FindUser.userEmail />
    <cfset userRole = FindUser.userRole />
    
    <cfoutput>
        <cfset pageTitle = "#appName# | #pgTitle#" />
    </cfoutput>

    <cfif #pgfilename# is not "">
        <cfoutput>  
            pgfilename: #pgfilename#
        </cfoutput>
    </cfif>
    
<cfelse>               
    <!--- Output message if no record found --->
    <cfoutput>         
        No record! #trim(thispage)#
    </cfoutput> 
</cfif>
