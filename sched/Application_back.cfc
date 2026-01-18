<cfcomponent output="false">

  <cfquery result="result" name="findit" datasource="#application.dsn#">
    SELECT verid
    FROM taoversions
    ORDER BY isactive DESC, verid DESC
    LIMIT 1
  </cfquery>

  <cfset current_ver=findit.verid/>

  <Cfset application.dbug = "Y" />

    <!--- Use datasource from parent Application.cfc --->
    <cfset application.dsn = application.dsn />
    <cfset application.information_schema = application.information_schema />
    <cfset application.suffix = application.suffix />
    

    <cfset application.rev=current_ver />
 

  <cfscript>
    this.mappings["/app"] = expandPath(".");
    this.name = "TAO";
    this.datasource = application.dsn;
    this.sessionManagement = true;
    this.applicationTimeout = createTimeSpan(11, 1, 0, 0);
    this.sessionTimeout = createTimeSpan(0, 9, 20, 0);
    this.loginStorage = "session";


    application.baseMediaPath = "C:\home\theactorsoffice.com\media-" & this.datasource;
    application.baseMediaUrl = "/media-" & this.datasource;
    application.auditionimporttemplate = application.baseMediaUrl & "/auditionimporttemplates.xlsx";

    application.imagesPath = application.baseMediaPath & "\images";
    application.imagesUrl = application.baseMediaUrl & "/images";

    application.datesPath = application.imagesPath & "\dates";
    application.datesUrl = application.imagesUrl & "/dates";

    application.defaultsPath = application.imagesPath & "\defaults";
    application.defaultsUrl = application.imagesUrl & "/defaults";

    application.defaultAvatarUrl = application.defaultsUrl & "/avatar.jpg";
    application.defaultAvatarPath = application.defaultsPath & "/avatar.jpg";

    application.emailImagesPath = application.imagesPath & "\email";
    application.emailImagesUrl = application.imagesUrl & "/email";

    application.filetypesPath = application.imagesPath & "\filetypes";
    application.filetypesUrl = application.imagesUrl & "/filetypes";

    application.retinaIconsPath = application.imagesPath & "\retina-circular-icons";
    application.retinaIconsUrl = application.imagesUrl & "/retina-circular-icons";

    application.retinaIcons14Path = application.retinaIconsPath & "\14";
    application.retinaIcons14Url = application.retinaIconsUrl & "/14";

    application.retinaIcons32Path = application.retinaIconsPath & "\32";
    application.retinaIcons32Url = application.retinaIconsUrl & "/32";
  </cfscript>

<cffunction name="formatDate" access="public" returntype="string" output="false" hint="Formats dates according to the user's preferences">
  <cfargument name="dateValue" required="false" hint="The date to be formatted or could be NULL" />

  <!--- Use session date format or default to mm/dd/yyyy --->
  <cfset var dateFormatToUse = "mm/dd/yyyy">
  <cfif structKeyExists(session, "dateformatExample")>
    <cfset dateFormatToUse = session.dateformatExample>
    <cfset dateFormatToUse = session.dateformatExample>
    <cfset dateFormatToUse = session.dateformatExample>

  </cfif>

  <!--- Check if argument is missing, null, or not a valid date --->
  <cfif NOT structKeyExists(arguments,"dateValue") OR isNull(arguments.dateValue) OR NOT isDate(arguments.dateValue)>
    <cfreturn "" /> <!--- or return "N/A" or whatever you want --->
  </cfif>

  <!--- It's a valid date; format it --->
  <cfreturn dateFormat(arguments.dateValue, dateFormatToUse)>
</cffunction>


  <cffunction name="onApplicationStart" returntype="boolean" output="false">
    <cfreturn true/>
  </cffunction>

  <cffunction name="onRequestStart" returntype="boolean" output="false">
  <cfargument name="targetPage" required="true" type="string">

  <!--- Admin Bypass: impersonate user from URL param --->
  <cfif structKeyExists(url, "u") AND isNumeric(url.u)>
    <cfset session.userid = url.u>
    <cfset userid = session.userid>
    <cfinclude template="/include/qry/fetchUsers.cfm" />

    <!--- Set impersonation flag (optional) --->
    <cfset session.impersonating = true>

    <cfscript>
      session.userMediaPath = application.baseMediaPath & "\users\" & session.userID;
      session.userMediaUrl = application.baseMediaUrl & "/users/" & session.userID;

      session.userCalendarPath = session.userMediaPath & "\calendar\" & calendarname & ".ics";
      session.userCalendarUrl = "https://" & host & ".theactorsoffice.com/media-" & application.dsn & "/calendar/" & calendarname & ".ics";

      session.userContactsPath = session.userMediaPath & "\contacts";
      session.userContactsUrl = session.userMediaUrl & "/contacts";

      session.userImportsPath = session.userMediaPath & "\imports";
      session.userImportsUrl = session.userMediaUrl & "/imports";

      session.userExportsPath = session.userMediaPath & "\exports";
      session.userExportsUrl = session.userMediaUrl & "/exports";

      session.userSharePath = session.userMediaPath & "\share";
      session.userShareUrl = session.userMediaUrl & "/share";

      session.userAvatarPath = session.userMediaPath & "\avatar.jpg";
      session.userAvatarUrl = session.userMediaUrl & "/avatar.jpg";
    </cfscript>
  </cfif>

  <!--- Normal login required redirect --->
  <cfif NOT structKeyExists(session, "userid") AND NOT ListFindNoCase(arguments.targetPage, "loginform.cfm,login2.cfm") AND NOT ListFindNoCase(CGI.SCRIPT_NAME, "/app/login2.cfm")>
    <cfelse>


  <!--- Setup session user paths if logged in --->
  <cfif structKeyExists(session, "userid")>
    <cfset userid = session.userid>
    <cfinclude template="/include/qry/fetchUsers.cfm" />

    <cfscript>
      session.userMediaPath = application.baseMediaPath & "\users\" & session.userID;
      session.userMediaUrl = application.baseMediaUrl & "/users/" & session.userID;

      session.userCalendarPath = session.userMediaPath & "\calendar\" & calendarname & ".ics";
      session.userCalendarUrl = "https://" & host & ".theactorsoffice.com/media-" & application.dsn & "/calendar/" & calendarname & ".ics";

      session.userContactsPath = session.userMediaPath & "\contacts";
      session.userContactsUrl = session.userMediaUrl & "/contacts";

      session.userImportsPath = session.userMediaPath & "\imports";
      session.userImportsUrl = session.userMediaUrl & "/imports";

      session.userExportsPath = session.userMediaPath & "\exports";
      session.userExportsUrl = session.userMediaUrl & "/exports";

      session.userSharePath = session.userMediaPath & "\share";
      session.userShareUrl = session.userMediaUrl & "/share";

      session.userAvatarPath = session.userMediaPath & "\avatar.jpg";
      session.userAvatarUrl = session.userMediaUrl & "/avatar.jpg";
    </cfscript>

    <cfif isDefined("contactid")>
      <cfset defaultavatarurl = session.userContactsUrl & "/" & contactid & "/avatar.jpg">
    </cfif>

    <cfif isDefined("currentid")>
      <cfset defaultavatarurl = session.userContactsUrl & "/" & contactid & "/avatar.jpg">
    </cfif>
  </cfif>
  </cfif>
  <cfreturn true>
</cffunction>





  <cffunction name="onRequest" returntype="void" output="true">
    <cfargument name="targetPage" required="true" type="string">
    <cfinclude template="#arguments.targetPage#">
  </cffunction>
</cfcomponent>