<cfset host = ListFirst(cgi.server_name, ".") />

<cfif host eq "app" or host eq "uat">
    <cfset dsn = "abo" />
<cfelse>
    <cfset dsn = "abod" />
</cfif>

<cfparam name="dbugz" default="N" />

<cfparam name="dbug" default="Y" />

<cfparam name="select_user" default="0" />

<cfparam name="select_contactid" default="0" />

<cfparam name="select_userid" default="0" />

<cfif select_userid is "0">
    No user
    <cfabort />
</cfif>

        <cfscript>
           userid = select_userid;

    baseMediaPath = "C:\home\theactorsoffice.com\media-" & dsn;
    baseMediaUrl = "/media-" & dsn;

            imagesPath = baseMediaPath & "\images";
            application.imagesUrl = baseMediaUrl & "/images";

            application.datesPath = imagesPath & "\dates";
            application.datesUrl = application.imagesUrl & "/dates";

            application.defaultsPath = imagesPath & "\defaults";
            defaultsUrl = application.imagesUrl & "/defaults";
              application.defaultAvatarPath = application.defaultsPath & "/avatar.jpg";
                    application.defaultAvatarUrl = defaultsUrl & "/avatar.jpg";

            application.emailImagesPath = imagesPath & "\email";
            emailapplication.imagesUrl = application.imagesUrl & "/email";

            application.application.application.filetypesPath = imagesPath & "\filetypes";
            application.application.application.filetypesUrl = application.imagesUrl & "/filetypes";

            application.application.retinaIconsPath = imagesPath & "\retina-circular-icons";
            application.application.retinaIconsUrl = application.imagesUrl & "/retina-circular-icons";

                    application.retinaIcons14Path = application.application.retinaIconsPath & "\14";
                    application.retinaIcons14Url = application.application.retinaIconsUrl & "/14";

                    retinaIcons32Path = application.application.retinaIconsPath & "\32";
                    retinaIcons32Url = application.application.retinaIconsUrl & "/32";

        session.userMediaPath = baseMediaPath & "\users\" & userID;
        session.userMediaUrl = baseMediaUrl & "/users/" & userID;

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

<cfset starttime = timeFormat(Now(), 'HHMMSS') />

<cfif not DirectoryExists(session.userMediaPath)>
    <cfdirectory directory="#session.userMediaPath#" action="create" />
</cfif>

<cfif not DirectoryExists(session.userContactsPath)>
    <cfdirectory directory="#session.userContactsPath#" action="create" />
</cfif>

<cfif not DirectoryExists(session.userImportsPath)>
    <cfdirectory directory="#session.userImportsPath#" action="create" />
</cfif>

<cfif not DirectoryExists(session.userExportsPath)>
    <cfdirectory directory="#session.userExportsPath#" action="create" />
</cfif>

<cfif not DirectoryExists(session.userSharePath)>
    <cfdirectory directory="#session.userSharePath#" action="create" />
</cfif>

<cfif NOT fileExists(session.userAvatarPath)>
    <cffile action="copy" source="#application.defaultAvatarPath#" destination="#session.userAvatarPath#" />
</cfif>

<cfquery result="result" datasource="#dsn#" name="C">
    SELECT contactid, recordname
    FROM contactdetails
    WHERE userid = <cfqueryparam value="#select_userid#" cfsqltype="CF_SQL_INTEGER">
    <cfif select_contactid neq 0>
        AND contactid = <cfqueryparam value="#select_contactid#" cfsqltype="CF_SQL_INTEGER">
    </cfif>
    ORDER BY contactid
</cfquery>

<cfloop query="C">
    <cfset new_contactid = C.contactid />

    <cfif not DirectoryExists(session.userContactsPath & "\" & new_contactid)>
        <cfdirectory directory="#session.userContactsPath#\#new_contactid#" action="create" />
    </cfif>

    <cfset contactPath = session.userContactsPath & "\" & new_contactid />
    <cfset contactAvatarPath = contactPath & "\avatar.jpg" />

    <cfif NOT fileExists(contactAvatarPath)>
        <cffile action="copy" source="#dir_missing_avatar_filename#" destination="#contactAvatarPath#" />
    </cfif>
</cfloop>

<cfquery result="result" datasource="#dsn#" name="update_tags">
    UPDATE tags_user
    SET IsTeam = 1
    WHERE userid = <cfqueryparam value="#select_userid#" cfsqltype="CF_SQL_INTEGER"> and tagname IN (
    select tagname FROM tags WHERE isteam = 1)
</cfquery>

<cfset n=0 />

<cfquery result="result" datasource="#dsn#" name="x">
    SELECT auddialectid,
    auddialect,
    audcatid,
    isDeleted
    FROM auddialects
    WHERE isdeleted = <cfqueryparam value="0" cfsqltype="CF_SQL_BIT">
</cfquery>

<cfloop query="x">

    <cfquery result="result" datasource="#dsn#" name="find">
        Select * from auddialects_user
        where auddialect = '#x.auddialect#' and userid = <cfqueryparam value="#select_userid#" cfsqltype="CF_SQL_INTEGER">
    </cfquery>

    <cfif find.recordcount is "0">

        <cfoutput>
            <cfset n=n + 1 />
            <cfif n is "1">
                <h3>auddialects_user</h3>
            </cfif>
        </cfoutput>

        <cfquery result="result" datasource="#dsn#" name="insert">
            INSERT INTO auddialects_user (auddialect, audcatid, userid)
            VALUES ('#x.auddialect#','#x.audcatid#',<cfqueryparam value="#select_userid#" cfsqltype="CF_SQL_INTEGER">);
        </cfquery>

        <cfoutput>
            auddialects added: #x.auddialect# (user #select_userid#)<br />
        </cfoutput>
    </cfif>
</cfloop>

<cfset n=0 />

<cfquery result="result" datasource="#dsn#" name="x">
    select audgenreid,
    audgenre,
    audcatid,
    isDeleted
    FROM audgenres
    where isdeleted = <cfqueryparam value="0" cfsqltype="CF_SQL_BIT">
</cfquery>

<cfloop query="x">
    <cfquery result="result" datasource="#dsn#" name="find">
        Select * from audgenres_user
        where audgenre = '#x.audgenre#' and userid = <cfqueryparam value="#select_userid#" cfsqltype="CF_SQL_INTEGER">
    </cfquery>

    <cfif find.recordcount is "0">
        <cfoutput>
            <cfset n=n + 1 />
            <cfif n is "1">
                <h3>audgenres_user</h3>
            </cfif>
        </cfoutput>

        <cfquery result="result" datasource="#dsn#" name="insert">
            INSERT INTO audgenres_user (audgenre, audcatid, userid)
            VALUES ('#x.audgenre#','#x.audcatid#',<cfqueryparam value="#select_userid#" cfsqltype="CF_SQL_INTEGER">);
        </cfquery>

        <cfif dbug is "Y">
            <cfoutput>
                audgenres added: #x.audgenre#<br />
            </cfoutput>
        </cfif>
    </cfif>
</cfloop>

<cfset n=0 />

<cfquery result="result" datasource="#dsn#" name="x">
    select networkid,
    network,
    audcatid,
    isDeleted
    FROM audnetworks
    where isdeleted = <cfqueryparam value="0" cfsqltype="CF_SQL_BIT">
</cfquery>

<cfloop query="x">
    <cfquery result="result" datasource="#dsn#" name="find">
        Select * from audnetworks_user
        where network = '#x.network#' and userid = <cfqueryparam value="#select_userid#" cfsqltype="CF_SQL_INTEGER">
    </cfquery>

    <cfif find.recordcount is "0">
        <cfoutput>
            <cfset n=n + 1 />
            <cfif n is "1">
                <h3>audnetworks_user</h3>
            </cfif>
        </cfoutput>

        <cfquery result="result" datasource="#dsn#" name="insert">
            INSERT INTO audnetworks_user (network, audcatid, userid)
            VALUES ('#x.network#','#x.audcatid#',<cfqueryparam value="#select_userid#" cfsqltype="CF_SQL_INTEGER">);
        </cfquery>

        <cfif dbug is "Y">
            <cfoutput>
                audnetworks added: #x.network#<br />
            </cfoutput>
        </cfif>
    </cfif>
</cfloop>

<cfset n=0 />

<cfquery result="result" datasource="#dsn#" name="x">
    select opencallname FROM audopencalloptions WHERE isdeleted = <cfqueryparam value="0" cfsqltype="CF_SQL_BIT">
</cfquery>

<cfloop query="x">
    <cfquery result="result" datasource="#dsn#" name="find">
        select opencallname
        FROM audopencalloptions_user
        where opencallname = '#x.opencallname#' and userid = <cfqueryparam value="#select_userid#" cfsqltype="CF_SQL_INTEGER">
    </cfquery>

    <cfif find.recordcount is "0">
        <cfoutput>
            <cfset n=n + 1 />
            <cfif n is "1">
                <h3>audopencalloptions_user</h3>
            </cfif>
        </cfoutput>

        <cfquery result="result" datasource="#dsn#" name="insert">
            INSERT INTO audopencalloptions_user (opencallname, userid)
            VALUES ('#x.opencallname#', <cfqueryparam value="#select_userid#" cfsqltype="CF_SQL_INTEGER">);
        </cfquery>

        <cfif dbug is "Y">
            <cfoutput>opencallname_user: #x.opencallname# added</cfoutput><br />
        </cfif>
    </cfif>
</cfloop>

<cfset n=0 />

<cfquery result="result" datasource="#dsn#" name="x">
    select audplatformid,
    audplatform,
    isDeleted
    FROM audplatforms
</cfquery>

<cfloop query="x">
    <cfquery result="result" datasource="#dsn#" name="find">
        Select * from audplatforms_user
        where audplatform = '#x.audplatform#' and userid = <cfqueryparam value="#select_userid#" cfsqltype="CF_SQL_INTEGER">
    </cfquery>

    <cfif find.recordcount is "0">
        <cfoutput>
            <cfset n=n + 1 />
            <cfif n is "1">
                <h3>audplatforms_user</h3>
            </cfif>
        </cfoutput>

        <cfquery result="result" datasource="#dsn#" name="insert">
            INSERT INTO audplatforms_user (audplatform, userid)
            VALUES ('#x.audplatform#',<cfqueryparam value="#select_userid#" cfsqltype="CF_SQL_INTEGER">);
        </cfquery>

        <cfif dbug is "Y">
            <cfoutput>
                audplatforms added: #x.audplatform#<br />
            </cfoutput>
        </cfif>
    </cfif>
</cfloop>

<cfset n=0 />

<cfquery result="result" datasource="#dsn#" name="x">
    SELECT * FROM audquestions_default where isdeleted = <cfqueryparam value="0" cfsqltype="CF_SQL_BIT">
</cfquery>

<cfloop query="x">
    <cfquery result="result" datasource="#dsn#" name="find">
        Select * from audquestions_user
        where isdeleted is false and qorder = #x.qorder# and userid = <cfqueryparam value="#select_userid#" cfsqltype="CF_SQL_INTEGER">
    </cfquery>

    <cfif find.recordcount is "0">
        <cfoutput>
            <cfset n=n + 1 />
            <cfif n is "1">
                <h3>audquestions_user</h3>
            </cfif>
        </cfoutput>

        <cfquery result="result" datasource="#dsn#" name="insert">
            INSERT INTO audquestions_user (qtypeid, qtext, qorder, userid)
            VALUES (#x.qtypeid#, '#x.qtext#', #x.qorder#, <cfqueryparam value="#select_userid#" cfsqltype="CF_SQL_INTEGER">);
        </cfquery>

        <cfif dbug is "Y">
            <cfoutput>Audquestions_user added: #x.qtext#</cfoutput><br />
        </cfif>
    </cfif>
</cfloop>

<cfset n=0 />

<cfquery result="result" datasource="#dsn#" name="x">
    SELECT submitsitename,catlist FROM audsubmitsites
</cfquery>

<cfloop query="x">
    <cfquery result="result" datasource="#dsn#" name="find">
        Select * from audsubmitsites_user
        where submitsitename = '#x.submitsitename#' and userid = <cfqueryparam value="#select_userid#" cfsqltype="CF_SQL_INTEGER">
    </cfquery>

    <cfif find.recordcount is "0">
        <cfoutput>
            <cfset n=n + 1 />
            <cfif n is "1">
                <h3>audsubmitsites_user</h3>
            </cfif>
        </cfoutput>

        <cfquery result="result" datasource="#dsn#" name="insert">
            INSERT INTO audsubmitsites_user (submitsitename, catlist, userid)
            VALUES ('#x.submitsitename#','#x.catlist#',<cfqueryparam value="#select_userid#" cfsqltype="CF_SQL_INTEGER">);
        </cfquery>

        <cfif dbug is "Y">
            <cfoutput>audsubmitsites_user added: #x.submitsitename#</cfoutput><br />
        </cfif>
    </cfif>
</cfloop>

<cfset n=0 />

<cfquery result="result" datasource="#dsn#" name="x">
    select toneid,
    tone,
    audcatid,
    isDeleted
    FROM audtones
    where isdeleted = <cfqueryparam value="0" cfsqltype="CF_SQL_BIT">
</cfquery>

<cfloop query="x">
    <cfquery result="result" datasource="#dsn#" name="find">
        Select * from audtones_user
        where tone = '#x.tone#' and userid = <cfqueryparam value="#select_userid#" cfsqltype="CF_SQL_INTEGER">
    </cfquery>

    <cfif find.recordcount is "0">
        <cfoutput>
            <cfset n=n + 1 />
            <cfif n is "1">
                <h3>audtones_user</h3>
            </cfif>
        </cfoutput>

        <cfquery result="result" datasource="#dsn#" name="insert">
            INSERT INTO audtones_user (tone, audcatid, userid)
            VALUES ('#x.tone#','#x.audcatid#',<cfqueryparam value="#select_userid#" cfsqltype="CF_SQL_INTEGER">);
        </cfquery>

        <cfoutput>
            audtones added: #x.tone#<br />
        </cfoutput>
    </cfif>
</cfloop>

<cfset n=0 />

<cfquery result="result" datasource="#dsn#" name="x">
    select eventTypeName,
    eventtypedescription,
    eventtypecolor
    FROM eventtypes
    where isdeleted = <cfqueryparam value="0" cfsqltype="CF_SQL_BIT">
</cfquery>

<cfloop query="x">
    <cfquery result="result" datasource="#dsn#" name="find">
        select eventTypeName,
        eventtypedescription,
        eventtypecolor
        FROM eventtypes_user
        where eventTypeName = '#x.eventtypeName#' and userid = <cfqueryparam value="#select_userid#" cfsqltype="CF_SQL_INTEGER">
    </cfquery>

    <cfif find.recordcount is "0">
        <cfoutput>
            <cfset n=n + 1 />
            <cfif n is "1">
                <h3>eventtypes_user</h3>
            </cfif>
        </cfoutput>

        <cfquery result="result" datasource="#dsn#" name="insert">
            INSERT INTO eventtypes_user (eventTypeName, eventtypedescription, eventtypecolor, userid)
            VALUES ('#x.eventTypeName#', '#x.eventtypedescription#', '#x.eventtypecolor#', <cfqueryparam value="#select_userid#" cfsqltype="CF_SQL_INTEGER">);
        </cfquery>

        <cfif dbug is "Y">
            <cfoutput>eventtypes_user: #x.eventTypeName# added</cfoutput><br />
        </cfif>
    </cfif>
</cfloop>

<cfset n=0 />

<cfquery result="result" datasource="#dsn#" name="x">
    SELECT genderpronoun, genderpronounplural FROM genderpronouns where isdeleted = <cfqueryparam value="0" cfsqltype="CF_SQL_BIT">
</cfquery>

<cfloop query="x">
    <cfquery result="result" datasource="#dsn#" name="find">
        Select * from genderpronouns_users
        where genderpronoun = '#x.genderpronoun#' and userid = <cfqueryparam value="#select_userid#" cfsqltype="CF_SQL_INTEGER">
    </cfquery>

    <cfif find.recordcount is "0">
        <cfoutput>
            <cfset n=n + 1 />
            <cfif n is "1">
                <h3>genderpronouns_users</h3>
            </cfif>
        </cfoutput>

        <cfquery result="result" datasource="#dsn#" name="insert">
            INSERT INTO genderpronouns_users (genderpronoun, genderpronounplural, userid)
            VALUES ('#x.genderpronoun#','#x.genderpronounplural#',<cfqueryparam value="#select_userid#" cfsqltype="CF_SQL_INTEGER">);
        </cfquery>

        <cfif dbug is "Y">
            <cfoutput>genderpronouns_users: #x.genderpronoun# added</cfoutput><br />
        </cfif>
    </cfif>
</cfloop>

<cfset n=0 />

<cfquery result="result" datasource="#dsn#" name="x">
    select typeid, valuetype, typeicon FROM itemtypes
</cfquery>

<cfloop query="x">
    <cfquery result="result" datasource="#dsn#" name="find">
        Select * from itemtypes_user
        where valuetype = '#x.valuetype#' and userid = <cfqueryparam value="#select_userid#" cfsqltype="CF_SQL_INTEGER">
    </cfquery>

    <cfif find.recordcount is "0">
        <cfoutput>
            <cfset n=n + 1 />
            <cfif n is "1">
                <h3>itemtypes_user</h3>
            </cfif>
        </cfoutput>

        <cfquery result="result" datasource="#dsn#" name="insert">
            INSERT INTO itemtypes_user (valuetype, typeicon, userid)
            VALUES ('#x.valuetype#', '#x.typeicon#', <cfqueryparam value="#select_userid#" cfsqltype="CF_SQL_INTEGER">);
        </cfquery>

        <cfif dbug is "Y">
            <cfoutput>itemtypes_user: #x.valuetype# added</cfoutput><br />
        </cfif>
    </cfif>
</cfloop>

<cfset n=0 />

<cfquery result="result" datasource="#dsn#" name="x">
    select DISTINCT c.catid, i.valuetype
    FROM itemcategory c
    inner join itemcatxref x ON x.catid = c.catid
    INNER JOIN itemtypes i ON i.typeid = x.typeid
    WHERE c.isdeleted = <cfqueryparam value="0" cfsqltype="CF_SQL_BIT"> AND i.isdeleted = <cfqueryparam value="0" cfsqltype="CF_SQL_BIT">
    ORDER BY c.catid, i.valuetype
</cfquery>

<cfloop query="x">
    <cfset new_catid=x.catid />

    <cfquery result="result" datasource="#dsn#" name="find">
        Select typeid from itemtypes_user
        where valuetype = '#x.valuetype#' and userid = <cfqueryparam value="#select_userid#" cfsqltype="CF_SQL_INTEGER">
    </cfquery>

    <cfset new_typeid=find.typeid />

    <cfquery result="result" datasource="#dsn#" name="check">
        select * from itemcatxref_user where userid = <cfqueryparam value="#select_userid#" cfsqltype="CF_SQL_INTEGER"> and typeid = #new_typeid# and catid = #new_catid#
    </cfquery>

    <cfif check.recordcount is "0">
        <cfoutput>
            <cfset n=n + 1 />
            <cfif n is "1">
                <h3>itemcatxref_user</h3>
            </cfif>
        </cfoutput>

        <cfquery result="result" datasource="#dsn#" name="insert">
            INSERT INTO itemcatxref_user (typeid, catid, userid)
            VALUES (#new_typeid#, #new_catid#, <cfqueryparam value="#select_userid#" cfsqltype="CF_SQL_INTEGER">);
        </cfquery>

        <cfif dbug is "Y">
            <cfoutput>itemcatxref_user: (#new_typeid#, #new_catid#, #select_userid# added</cfoutput><br />
        </cfif>
    </cfif>
</cfloop>

<cfset n=0 />

<cfquery result="result" datasource="#dsn#" name="x">
    SELECT * FROM pgpanels_master
</cfquery>

<cfloop query="x">
    <cfquery result="result" datasource="#dsn#" name="find">
        SELECT * FROM pgpanels_user where userid = <cfqueryparam value="#select_userid#" cfsqltype="CF_SQL_INTEGER"> and pnFilename = '#x.pnFilename#' and isdeleted = <cfqueryparam value="0" cfsqltype="CF_SQL_BIT">
    </cfquery>

    <cfif find.recordcount is "0">
        <cfoutput>
            <cfset n=n + 1 />
            <cfif n is "1">
                <h3>pgpanels_user</h3>
            </cfif>
        </cfoutput>

        <cfquery result="result" datasource="#dsn#" name="insert">
            INSERT INTO pgpanels_user (userid, pnTitle, pnFilename, pnOrderNo, pnColXl, pnColMd, pnDescription, IsVisible)
            VALUES (#select_userid#, '#x.pntitle#', '#x.pnfilename#', #x.pnOrderNo#, #x.pnColXl#, #x.pnColMd#, '#x.pnDescription#', 1);
        </cfquery>
    </cfif>
</cfloop>

<cfset n=0 />

<cfquery result="result" datasource="#dsn#" name="x">
    SELECT * FROM tags
</cfquery>

<cfloop query="x">
    <cfquery result="result" datasource="#dsn#" name="find">
        Select * from tags_user
        where tagname = '#x.tagname#' and userid = <cfqueryparam value="#select_userid#" cfsqltype="CF_SQL_INTEGER">
    </cfquery>

    <cfif find.recordcount is "0">
        <cfoutput>
            <cfset n=n + 1 />
            <cfif n is "1">
                <h3>tags_user</h3>
            </cfif>
        </cfoutput>

        <cfquery result="result" datasource="#dsn#" name="insert">
            INSERT INTO tags_user (tagname, userid)
            VALUES ('#x.tagname#', <cfqueryparam value="#select_userid#" cfsqltype="CF_SQL_INTEGER">);
        </cfquery>

        <cfif dbug is "Y">
            <cfoutput>tags_user: #x.tagname# added</cfoutput><br />
        </cfif>
    </cfif>
</cfloop>

<cfquery result="result" datasource="#dsn#" name="x">
    SELECT tagname, isteam, iscasting, tagtype FROM tags
</cfquery>

<cfloop query="x">
    <cfquery result="result" datasource="#dsn#" name="insert">
        update tags_user
        set isteam = #x.isteam#, iscasting = #x.iscasting#, tagtype = '#x.tagtype#'
        where tagname = '#x.tagname#'
    </cfquery>
</cfloop>

<Cfset n=0 />

<cfquery result="result" datasource="#dsn#" name="x">
    select sitetypename, sitetypedescription from sitetypes_master
</cfquery>

<cfloop query="x">
    <cfquery result="result" datasource="#dsn#" name="find">
        Select * from sitetypes_user
        where sitetypename = '#x.sitetypename#' and userid = <cfqueryparam value="#select_userid#" cfsqltype="CF_SQL_INTEGER">
    </cfquery>

    <cfif find.recordcount is "0">
        <cfoutput>
            <cfset n=n + 1 />
            <cfif n is "1">
                <h3>sitetypes_user</h3>
            </cfif>
        </cfoutput>

        <cfquery result="result" datasource="#dsn#" name="insert">
            INSERT INTO sitetypes_user (siteTypeName, siteTypeDescription, userid)
            VALUES ('#x.sitetypename#', '#x.sitetypedescription#', <cfqueryparam value="#select_userid#" cfsqltype="CF_SQL_INTEGER">);
        </cfquery>

        <cfoutput>
            sitetypes_user added: #x.sitetypename#<br />
        </cfoutput>
    </cfif>
</cfloop>

<cfset n=0 />

<cfquery result="result" datasource="#dsn#" name="x">
    SELECT
        s.id,
        s.sitename,
        s.siteURL,
        s.siteicon,
        s.sitetypeid,
        t.sitetypename
    FROM
        sitelinks_master s
        INNER JOIN sitetypes_master t ON t.sitetypeid = s.siteTypeid
    ORDER BY
        s.sitename
</cfquery>

<cfloop query="x">
    <cfquery result="result" datasource="#dsn#" name="find">
        SELECT sitetypeid
        FROM sitetypes_user
        WHERE sitetypename = <cfqueryparam value="#x.sitetypename#" cfsqltype="CF_SQL_VARCHAR">
        AND userid = <cfqueryparam value="#select_userid#" cfsqltype="CF_SQL_INTEGER">
    </cfquery>

    <cfif dbug eq "Y">
        <cfoutput>
            SELECT sitetypeid FROM sitetypes_user
            WHERE sitetypename = '#x.sitetypename#' AND userid = #select_userid# (#find.recordcount#)<br/>
        </cfoutput>
    </cfif>

    <cfif find.recordcount eq 1>
        <cfoutput>
            <cfset n = n + 1 />
            <cfif n eq 1>
                <h3>sitelinks_user</h3>
            </cfif>
        </cfoutput>

        <cfset new_sitetypeid = find.sitetypeid />

        <cfif dbug eq "Y">
            <cfoutput>
                <h3>new_sitetypeid: #new_sitetypeid#</h3>
            </cfoutput>
        </cfif>

        <cfquery result="result" datasource="#dsn#" name="find2">
            SELECT *
            FROM sitelinks_user
            WHERE sitename = <cfqueryparam value="#x.sitename#" cfsqltype="CF_SQL_VARCHAR">
            AND userid = <cfqueryparam value="#select_userid#" cfsqltype="CF_SQL_INTEGER">
        </cfquery>

        <cfif dbug eq "Y">
            <cfoutput>
                SELECT * FROM sitelinks_user WHERE sitename = '#x.sitename#' AND userid = #select_userid#<br/>
            </cfoutput>
        </cfif>

        <cfif find2.recordcount eq 0>
            <cfif dbug eq "Y">
                <cfoutput>
                    INSERT INTO sitelinks_user_tbl (siteName, siteURL, siteicon, siteTypeid, userid)
                    VALUES ('#x.sitename#', '#x.siteurl#', '#x.siteicon#', #new_sitetypeid#, #select_userid#)<br/>
                </cfoutput>
            </cfif>

            <cfquery result="result" datasource="#dsn#" name="insert">
                INSERT INTO sitelinks_user_tbl (siteName, siteURL, siteicon, siteTypeid, userid)
                VALUES (
                    <cfqueryparam value="#x.sitename#" cfsqltype="CF_SQL_VARCHAR">,
                    <cfqueryparam value="#x.siteurl#" cfsqltype="CF_SQL_VARCHAR">,
                    <cfqueryparam value="#x.siteicon#" cfsqltype="CF_SQL_VARCHAR">,
                    <cfqueryparam value="#new_sitetypeid#" cfsqltype="CF_SQL_INTEGER">,
                    <cfqueryparam value="#select_userid#" cfsqltype="CF_SQL_INTEGER">
                )
            </cfquery>

            <cfif dbug eq "Y">
                <cfoutput>
                    sitelinks_user_tbl: #x.sitename# added<br />
                </cfoutput>
            </cfif>
        </cfif>
    </cfif>
</cfloop>

<cfset n = 0 />

<cfquery result="result" datasource="#dsn#" name="x">
    SELECT sitetypeid, sitetypename, sitetypedescription from sitetypes_user where userid = <cfqueryparam value="#select_userid#" cfsqltype="CF_SQL_INTEGER">
</cfquery>

<cfloop query="x">
    <cfoutput>
        <cfset new_pntitle = "#x.sitetypename# Links" />
        <cfset new_sitetypeid = x.sitetypeid />
    </cfoutput>

    <cfquery result="result" name="Findtotal" maxrows="1" datasource="#dsn#">
        Select p.pnOrderno + 1 as new_pnOrderNo
        from pgpanels_user p 
        where p.userid = <cfqueryparam value="#select_userid#" cfsqltype="CF_SQL_INTEGER">
        order by p.pnOrderno desc
    </cfquery> 

    <cfquery name="add" datasource="#dsn#" result="PN">    
        INSERT INTO pgpanels_user (pnTitle, pnFilename, pnorderno, pncolxl, pncolMd, pnDescription, IsDeleted, IsVisible, userid)
        VALUES ('#new_pnTitle#', 'mylinks_user.cfm', #Findtotal.new_pnOrderNo#, <cfqueryparam value="3" cfsqltype="CF_SQL_INTEGER">, <cfqueryparam value="3" cfsqltype="CF_SQL_INTEGER">, '', 0, 1, <cfqueryparam value="#select_userid#" cfsqltype="CF_SQL_INTEGER">)
    </cfquery>

    <cfset new_pnid = PN.generated_key />

    <cfquery result="result" name="add" datasource="#dsn#"> 
        update sitetypes_user
        set pnid = <cfqueryparam value="#new_pnid#" cfsqltype="CF_SQL_INTEGER"> where sitetypeid = <cfqueryparam value="#new_sitetypeid#" cfsqltype="CF_SQL_INTEGER">
    </cfquery>
</cfloop>
        
        
        
        <cfquery result="result" name="loginQuery" datasource="#dsn#" >
  SELECT * FROM taousers where contactid is null
</cfquery> 
 
<cfloop query="loginQuery">
<cfif #loginQuery.contactid# is "">

            <cfquery name="InsertContact"  datasource="#dsn#"  result="result">  
                INSERT INTO contactdetails (contactfullname,userid,user_yn)
                values ('#loginQuery.userfirstname# #loginQuery.userlastname#',#loginQuery.userid#,'Y')
            </cfquery>
    
            <cfset new_contactid = result.generatedkey />
    
            <cfquery result="result" name="InsertContact"  datasource="#dsn#" >  
            update taousers
            set contactid = #new_contactid#
            where userid = #loginQuery.userid#
            </cfquery>     
        
        </cfif> 

</cfloop>
