

<!--- Dynamically use the determined datasource in the cfapplication tag --->
<cfapplication 
    name="TAO_dev" 
    sessionmanagement="true" 
    applicationtimeout="#createTimeSpan(1, 0, 0, 0)#" 
    sessiontimeout="#createTimeSpan(0, 1, 0, 0)#" 
    datasource="#datasourceName#"
    setclientcookies="true">


<cfinclude template="/include/qry/fetchUsers.cfm" />

<cfif structKeyExists(variables, "userid")>
    <cfscript>
    session.userid = userid;

        application.baseMediaPath = "C:\home\theactorsoffice.com\media-" & datasourceName;
        application.baseMediaUrl = "/media-" & datasourceName;

        defaultAvatarPath = application.imagesPath & "\defaults\avatar.jpg";

        application.imagesPath = application.baseMediaPath & "\images";
        application.imagesUrl = application.baseMediaUrl & "/images";

        application.datesPath = application.imagesPath & "\dates";
        application.datesUrl = application.imagesUrl & "/dates";

        application.defaultsPath = application.imagesPath & "\defaults";
        application.defaultsUrl = application.imagesUrl & "/defaults";

        application.defaultAvatarUrl = application.defaultsUrl & "/avatar.jpg";

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

        session.userMediaPath = application.baseMediaPath & "\users\" & session.userID;
        session.userMediaUrl = application.baseMediaUrl & "/users/" & session.userID;

        session.userCalendarPath = session.userMediaPath;
        session.userCalendarUrl = "https://" & host & ".theactorsoffice.com/" & session.userMediaUrl;

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

    <!--- Handle contactid if defined --->
    <cfif structKeyExists(variables, "contactid")>
        <cfscript>
            defaultavatarurl = session.userContactsUrl & "/" & contactid & "/avatar.jpg";
        </cfscript>
    </cfif>

    <!--- Handle currentid if defined --->
    <cfif structKeyExists(variables, "currentid")>
        <cfscript>
            defaultavatarurl = session.userContactsUrl & "/" & currentid & "/avatar.jpg";
        </cfscript>
    </cfif>
</cfif>
