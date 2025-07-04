<CFINCLUDE template="remote_load.cfm" />
<cfparam name="u" default="434F6AD485112F73A9" />

<cfparam name="pgaction" default="view" />

<cfparam name="subdomain" default="app" />

<cfparam name="thispage2" default="" />

<cfparam name="rpgid" default="0" />

<cfset currentURL=cgi.server_name />

<cfset host=ListFirst(currentURL, "." ) />

<cfoutput>

    <cfset thisPath=ExpandPath("*.*") />

    <cfset thisDirectory="#GetDirectoryFromPath(thisPath)#" />
</cfoutput>


<cfparam name="catArea_UCB" default="C" />

<cfparam name="contactid" default="0" />

<Cfset userAvatarUrl = "/media-" & "dsn" & "/users/" & userid & "/avatar.jpg" />


<cfquery datasource="#dsn#" name="FindUser">
    SELECT
    u.userid
    ,u.recordname
    ,u.userFirstName
    ,u.userLastName
    ,u.userEmail
    ,u.contactid
    ,u.userRole
    ,u.IsBetaTester
    ,u.defRows
    ,u.defCountry
    ,u.defState
    ,u.calstarttime
    ,u.calendtime
    ,u.avatarname
    ,u.contactid AS userContactID
    ,u.tzid
    ,t.tzname
    ,u.customerid
    FROM taousers u
    LEFT join timezones t on t.tzid = u.tzid
    WHERE LEFT(u.passwordhash,10) = '#u#'
</cfquery>

<cfoutput>
    <cfif #finduser.recordcount# is not "1">
        
      
    Not found!<cfabort>
 
    </cfif>



</cfoutput>





<cfquery datasource="#dsn#" name="FindPage">
    SELECT
    a.appname
    ,a.appAuthor
    ,c.compname
    ,p.pgname
    ,a.appId
    ,a.appDescription
    ,a.appLogoName
    ,a.colorTopBar
    ,a.colorLeftSideBar
    ,a.mocktoday
    ,a.mock_yn
    ,c.compid
    ,c.compDir
    ,c.compTable
    ,c.compowner
    ,c.compIcon
    ,c.menuYN
    ,c.menuOrder
    ,c.compInner
    ,c.compRecordName
    ,c.compActive
    ,p.pgid
    ,p.pgDir
    ,p.pgTitle
    ,p.pgHeading
    ,p.pgFilename
    ,p.datatables_YN
    ,p.fullcalendar_YN
    ,p.editable_YN
    ,p.newdatatables_YN
    ,p.pk
    ,p.update_type
    FROM pgpages p
    INNER JOIN pgcomps c ON c.compID = p.compID
    INNER JOIN pgapps a ON a.appID = c.appid
    WHERE p.pgDir = 'share'
</cfquery>





<cfquery datasource="#dsn#" name="FindFields">
    SELECT
    a.appname
    ,c.compname
    ,p.pgname
    ,f.fname
    ,a.appId
    ,a.appName
    ,a.appDescription
    ,a.appLogoName
    ,a.colorTopBar
    ,a.colorLeftSideBar
    ,c.compid
    ,c.compDir
    ,c.compTable
    ,c.compowner
    ,c.compIcon
    ,c.menuYN
    ,c.menuOrder
    ,c.compInner
    ,c.compRecordName
    ,c.compActive
    ,p.pgid
    ,p.pgDir
    ,p.pgTitle
    ,p.pgHeading
    ,p.pgFilename
    ,p.datatables_YN
    ,p.fullcalendar_YN
    ,p.editable_YN
    ,p.newdatatables_YN
    ,p.pk
    ,f.fieldid
    ,f.pgid
    ,f.ftype
    ,f.ftypefull
    ,f.update_yn
    ,f.updatename
    ,f.updatetype
    ,f.fkey
    ,f.num_min
    ,f.num_max
    FROM pgpages p
    INNER JOIN pgcomps c ON c.compID = p.compID
    INNER JOIN pgapps a ON a.appID = c.appid
    INNER join pgfields f on f.pgid = p.pgid
    WHERE p.pgDir = 'share'
</cfquery>

<cfif #FindPage.RecordCount# is "1">


    <cfquery datasource="#dsn#" name="FindLinksT">
        SELECT

        l.linkid
        ,l.linkurl
        ,l.linkname
        ,l.linktype
        ,l.link_no
        ,l.linkloc_tb
        ,l.pluginname
        ,l.rel
        ,l.hrefid


        FROM pgapplinks l

        INNER JOIN pgplugins p ON p.pluginName = l.pluginname
        INNER JOIN pgpagespluginsxref x ON x.pluginid = p.pluginid
        INNER JOIN pgpages g ON g.pgid = x.pgid


        WHERE g.pgid = 11 AND l.linkloc_tb = 't'

        ORDER BY l.link_no
    </cfquery>


    <cfquery datasource="#dsn#" name="FindLinksB">
        SELECT

        l.linkid
        ,l.linkurl
        ,l.linkname
        ,l.linktype
        ,l.link_no
        ,l.linkloc_tb
        ,l.pluginname
        ,l.rel
        ,l.hrefid


        FROM pgapplinks l

        INNER JOIN pgplugins p ON p.pluginName = l.pluginname
        INNER JOIN pgpagespluginsxref x ON x.pluginid = p.pluginid
        INNER JOIN pgpages g ON g.pgid = x.pgid


        WHERE g.pgid = 11 AND l.linkloc_tb = 'b' and l.linkname NOT like '%calendar - custom%'
and l.linktype <> 'css'
        ORDER BY l.link_no
    </cfquery>


    <cfquery datasource="#dsn#" name="FindLinksExtra">
        SELECT distinct
        l.pluginname

        FROM pgapplinks l

        INNER JOIN pgplugins p ON p.pluginName = l.pluginname
        INNER JOIN pgpagespluginsxref x ON x.pluginid = p.pluginid
        INNER JOIN pgpages g ON g.pgid = x.pgid

        WHERE g.pgid = 11 AND l.linkloc_tb = 'b'
        and l.pluginname <> 'global'
            ORDER BY l.link_no
    </cfquery>


    <!--- Application variables --->

    <cfset appName=FindPage.appName />
    <cfset appDescription=FindPage.appDescription />
    <cfset appAuthor=FindPage.appAuthor />
    <cfset appLogoName=FindPage.appLogoName />
    <cfif #host# is "uat">
        <cfset colorTopBar="Purple" />
        <cfelse>
            <cfset colorTopBar=FindPage.colorTopBar />
    </cfif>
    <cfset colorLeftSideBar=FindPage.colorLeftSideBar />
    <cfset home="/app/dashboard" />
    <cfset mocktoday=FindPage.mocktoday />
    <cfset mock_yn=FindPage.mock_yn />
    <!--- Component variables --->

    <cfset compid=FindPage.compid />
    <cfset compname=FindPage.compname />
    <cfset compDir=FindPage.compDir />
    <cfset compTable=FindPage.compTable />
    <cfset compowner=FindPage.compowner />

    <!--- Page variables --->

    <cfset pgid=FindPage.pgid />
    <cfset cookie.pgid=FindPage.pgid />
    <cfset pgname=FindPage.pgname />
    <cfset pgDir=FindPage.pgDir />
    <cfset pgTitle=FindPage.pgTitle />
    <cfset pgHeading=FindPage.pgHeading />
    <cfset pgFilename=FindPage.pgFilename />
    <cfset update_type=FindPage.update_type />
    <!--- User variables --->

<cfset userid=FindUser.userid />
    <cfset userContactid=FindUser.userContactID />
    <cfset userCalStarttime=FindUser.calstarttime />
    <cfset userCalendtime=FindUser.calendtime />
    <cfset useravatarname=FindUser.avatarname />
    <cfset userIsBetaTester=FindUser.IsBetaTester />
    <cfset userdefRows=FindUser.defRows + 1 />
    <cfset userdefCountry=FindUser.defCountry />
    <cfset userdefState=FindUser.defState />
    <cfset usertzid=FindUser.tzid />
    <cfset usercustomerid=FindUser.customerid />

    <cfif "#usercontactid#" is "#contactid#">
        <Cfset catArea_UCB="U" />
    </cfif>


 



    <cfset userFirstName=FindUser.userFirstName />
    <cfset userLastName=FindUser.userLastName />
    <cfset userEmail=FindUser.userEmail />
    <cfset userRole=FindUser.userRole />

    <cfoutput>
        <cfset pageTitle="#appName# | #pgTitle#" />

    </cfoutput>


    <cfelse>


        <cfoutput> No record!#trim(thispage)#</cfoutput>

</cfif>
