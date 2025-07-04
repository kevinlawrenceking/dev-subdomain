<cfparam name="dbugz" default="N" />

<cfparam name="dbug" default="Y" />

<cfparam name="select_user" default="0" />

<cfparam name="select_contactid" default="0" />

<cfparam name="select_userid" default="0" />

<cfset currentURL=cgi.server_name />

<cfset host=ListFirst(currentURL, "." ) />

<cfif #select_userid# is "0">

    No user
    <cfabort />

</cfif>

<cfoutput>

    <cfset starttime="#timeformat(NOw(),'HHMMSS')#" />

    <cfset dir_media_root="#datasourceMediaPath#' />

    <cfif #dbugz# is "Y">

        <h2>dir_media_root: #dir_media_root#</h2>

    </cfif>

    <cfset browser_media_root="/media-#host#" />

    <cfif #dbugz# is "Y">

        <h2>browser_media_root: #browser_media_root#</h2>

    </cfif>

    <cfset dir_media_root_defaults="#dir_media_root#\defaults" />

    <cfif #dbugz# is "Y">

        <h2>dir_media_root_defaults: #dir_media_root_defaults#</h2>

    </cfif>

    <cfset browser_media_root_defaults="#browser_media_root#/defaults" />

    <cfif #dbugz# is "Y">

        <h2>browser_media_root_defaults: #browser_media_root_defaults#</h2>

    </cfif>

    <cfset dir_missing_avatar_filename="#dir_media_root_defaults#\avatar.jpg" />

    <cfif #dbugz# is "Y">

        <h2>dir_missing_avatar_filename: #dir_missing_avatar_filename#</h2>

    </cfif>

    <cfset browser_missing_avatar_filename="#browser_media_root_defaults#/avatar.jpg" />

    <cfif #dbugz# is "Y">

        <h2>browser_missing_avatar_filename: #browser_missing_avatar_filename#</h2>

    </cfif>

</cfoutput>

<cfoutput>

    <cfif #dbugz# is "Y">

        <h2>User: #select_userid#</h2>

    </cfif>

    <cfset browser_media_root_user="#browser_media_root#/users/#select_userid#" />

    <cfif #dbugz# is "Y">

        <p>browser_media_root_user: #browser_media_root_user#</p>

    </cfif>

    <cfset dir_media_root_user="#dir_media_root#\users\#select_userid#" />

    <cfif #dbugz# is "Y">

        <p>dir_media_root_user: #session.userMediaPath#</p>

    </cfif>

    <cfset session.userAvatarPath="#session.userMediaPath#\avatar.jpg" />

    <cfif #dbugz# is "Y">

        <p>session.userAvatarPath: #session.userAvatarPath#</p>

    </cfif>

    <cfset session.contactAvatarUrl="#browser_media_root_user#/avatar.jpg" />

    <cfif #dbugz# is "Y">

        <p>session.contactAvatarUrl: #session.contactAvatarUrl#</p>

    </cfif>

    <cfif not DirectoryExists("#session.userMediaPath#")>

        <cfdirectory directory="#session.userMediaPath#" action="create" />
        <cfif #dbugz# is "Y">

            <p>dir_media_root_user dir created: #session.contactAvatarUrl#</p>

        </cfif>

    </cfif>

    <cfset browser_media_root_user_contacts="#browser_media_root_user#/contacts" />

    <cfif #dbugz# is "Y">

        <p>browser_media_root_user_contacts: #browser_media_root_user_contacts#</p>

    </cfif>

    <cfset dir_media_root_user_contacts="#session.userMediaPath#\contacts" />

    <cfif #dbugz# is "Y">

        <p>dir_media_root_user_contacts: #dir_media_root_user_contacts#</p>

    </cfif>

    <cfif not DirectoryExists("#dir_media_root_user_contacts#")>

        <cfdirectory directory="#dir_media_root_user_contacts#" action="create" />

        <h3>dir_media_root_user_contacts dir created: #dir_media_root_user_contacts#</h3>

    </cfif>

    <cfset browser_media_root_user_imports="#browser_media_root_user#/imports" />

    <cfif #dbugz# is "Y">

        <p>browser_media_root_user_imports: #browser_media_root_user_imports#</p>

    </cfif>

    <cfset dir_media_root_user_imports="#session.userMediaPath#\imports" />

    <cfif #dbugz# is "Y">

        <p>dir_media_root_user_imports: #dir_media_root_user_imports#</p>

    </cfif>

    <cfif not DirectoryExists("#dir_media_root_user_imports#")>

        <cfdirectory directory="#dir_media_root_user_imports#" action="create" />

        <h3>dir_media_root_user_imports dir created: #dir_media_root_user_imports#</h3>
    </cfif>

    <cfif NOT fileExists(session.userAvatarPath)>

        <cffile action="copy" source="#dir_missing_avatar_filename#" destination="#session.userMediaPath#\" />

        <h3>default avatar moved to: #session.userMediaPath#</h3>

    </cfif>

</cfoutput>

<cfquery result="result"  name="C">
    select contactid,recordname
    from contactdetails
    where userid = #select_userid#
    <cfif #select_contactid# is not "0">
        and contactid = #select_contactid#
    </cfif>
    order by contactid
</cfquery>

<cfif #dbug# is "Y">

    <cfoutput>

        <h3> #select_userid#: Creating folders for #c.recordcount# contacts</h3>

    </cfoutput>

</cfif>

<cfloop query="C">

    <cfoutput>

        <cfset new_contactid="#C.contactid#" />

        <cfif #dbug# is "Y">

            #c.recordname#: Contact ID #new_contactid#<br />

        </cfif>

        <cfset dir_media_root_user_contacts_folder="#dir_media_root_user_contacts#\#new_contactid#" />

        <cfif not DirectoryExists("#dir_media_root_user_contacts_folder#")>

            <cfdirectory directory="#dir_media_root_user_contacts_folder#" action="create" />

            <cfif #dbugz# is "Y">

                <h3>#c.recordname#: dir_media_root_user_contacts_folder dir created: #dir_media_root_user_contacts_folder#</h3>

            </cfif>

        </cfif>

        <cfset dir_media_root_user_contacts_folder_attachements="#dir_media_root_user_contacts_folder#\attachments" />

        <cfif not DirectoryExists("#dir_media_root_user_contacts_folder_attachements#")>

            <cfdirectory directory="#dir_media_root_user_contacts_folder_attachements#" action="create" />

            <cfif #dbugz# is "Y">

                <h3>dir_media_root_user_contacts_folder_attachements dir created: #dir_media_root_user_contacts_folder_attachements#</h3>

            </cfif>

        </cfif>

        <cfset dir_contact_avatar_filename="#dir_media_root_user_contacts_folder#\avatar.jpg" />

        <cfif #dbugz# is "Y">

            <p>dir_contact_avatar_filename: #dir_contact_avatar_filename#</p>

        </cfif>

        <cfif NOT fileExists(dir_contact_avatar_filename)>

            <cffile action="copy" source="#dir_missing_avatar_filename#" destination="#dir_media_root_user_contacts_folder#\" />

            <cfif #dbugz# is "Y">

                <h3>default contact avatar moved to: #dir_media_root_user_contacts_folder#</h3>

            </cfif>

        </cfif>

    </cfoutput>

</cfloop>

<cfquery result="result"  name="update_tags">
    UPDATE tags_user
    SET IsTeam = 1
    WHERE userid = #select_userid# and tagname IN (
    select tagname FROM tags WHERE isteam = 1)
</cfquery>

<cfset n=0 />
<cfquery result="result"  name="x">
    SELECT auddialectid,
    auddialect,
    audcatid,
    isDeleted
    FROM auddialects
    WHERE ISdeleted = 0
</cfquery>

<cfloop query="x">

    <cfquery result="result"  name="find">
        Select * from auddialects_user
        where auddialect = '#x.auddialect#' and userid = #select_userid#
    </cfquery>

    <cfif #find.recordcount# is "0">
        <cfoutput>
            <cfset n=#n# + 1 />
            <cfif #n# is "1">
                <h3>auddialects_user</h3>
            </cfif>
        </cfoutput>

        <cfquery result="result"  name="insert">

            INSERT INTO `auddialects_user` (`auddialect`, `audcatid`, `userid`)
            VALUES ('#x.auddialect#','#x.audcatid#',#select_userid#);

        </cfquery>

        <cfoutput>
            auddialects added: #x.auddialect# (user #select_userid#)<BR>
        </cfoutput>
    </cfif>

</cfloop>

<cfset n=0 />

<cfquery result="result"  name="x">
    select audgenreid,
    audgenre,
    audcatid,
    isDeleted
    FROM audgenres
    where isdeleted = 0
</cfquery>

<cfloop query="x">

    <cfquery result="result"  name="find">
        Select * from audgenres_user
        where audgenre = '#x.audgenre#' and userid = #select_userid#
    </cfquery>

    <cfif #find.recordcount# is "0">
        <cfoutput>
            <cfset n=#n# + 1 />
            <cfif #n# is "1">
                <h3>audgenres_user</h3>
            </cfif>
        </cfoutput>

        <cfquery result="result"  name="insert">
            INSERT INTO `audgenres_user` (`audgenre`, `audcatid`, `userid`)
            VALUES ('#x.audgenre#','#x.audcatid#',#select_userid#);
        </cfquery>
        <cfif #dbug# is "Y">
            <cfoutput>
                audgenres added: #x.audgenre# <br />
            </cfoutput>
        </cfif>
    </cfif>

</cfloop>

<cfset n=0 />

<cfquery result="result"  name="x">
    select networkid,
    network,
    audcatid,
    isDeleted
    FROM audnetworks
    where isdeleted = 0
</cfquery>

<cfloop query="x">

    <cfquery result="result"  name="find">
        Select * from audnetworks_user
        where network = '#x.network#' and userid = #select_userid#
    </cfquery>

    <cfif #find.recordcount# is "0">
        <cfoutput>
            <cfset n=#n# + 1 />
            <cfif #n# is "1">
                <h3>audnetworks_user</h3>
            </cfif>
        </cfoutput>

        <cfquery result="result"  name="insert">
            INSERT INTO `audnetworks_user` (`network`, `audcatid`, `userid`)
            VALUES ('#x.network#','#x.audcatid#',#select_userid#);
        </cfquery>
        <cfif #dbug# is "Y">
            <cfoutput>
                audnetworks added: #x.network# <br />
            </cfoutput>
        </cfif>
    </cfif>

</cfloop>

<cfset n=0 />

<cfquery result="result"  name="x">
    select opencallname FROM audopencalloptions WHERE isdeleted = 0
</cfquery>

<cfloop query="x">

    <cfquery result="result"  name="find">
        select opencallname
        FROM audopencalloptions_user
        where opencallname = '#x.opencallname#' and userid = #select_userid#
    </cfquery>

    <cfif #find.recordcount# is "0">
        <cfoutput>
            <cfset n=#n# + 1 />
            <cfif #n# is "1">
                <h3>audopencalloptions_user</h3>
            </cfif>
        </cfoutput>

        <cfquery result="result"  name="insert">
            INSERT INTO `audopencalloptions_user` (`opencallname`,`userid`)
            VALUES ('#x.opencallname#', #select_userid#);
        </cfquery>

        <cfif #dbug# is "Y">
            <CFOUTPUT> opencallname_user: #x.opencallname# added</CFOUTPUT><br />
        </cfif>

    </cfif>
</cfloop>

<cfset n=0 />

<cfquery result="result"  name="x">
    select audplatformid,
    audplatform,
    isDeleted
    FROM audplatforms
</cfquery>

<cfloop query="x">

    <cfquery result="result"  name="find">
        Select * from audplatforms_user
        where audplatform = '#x.audplatform#' and userid = #select_userid#
    </cfquery>

    <cfif #find.recordcount# is "0">
        <cfoutput>
            <cfset n=#n# + 1 />
            <cfif #n# is "1">
                <h3>audplatforms_user</h3>
            </cfif>
        </cfoutput>

        <cfquery result="result"  name="insert">
            INSERT INTO `audplatforms_user` (`audplatform`, `userid`)
            VALUES ('#x.audplatform#',#select_userid#);
        </cfquery>
        <cfif #dbug# is "Y">
            <cfoutput>
                audplatforms added: #x.audplatform# <br />
            </cfoutput>
        </cfif>
    </cfif>

</cfloop>

<cfset n=0 />

<cfquery result="result"  name="x">
    SELECT * FROM audquestions_default where isdeleted = 0
</cfquery>

<cfloop query="x">

    <cfquery result="result"  name="find">
        Select * from audquestions_user
        where isdeleted is false and qorder = #x.qorder# and userid = #select_userid#
    </cfquery>

    <cfif #find.recordcount# is "0">
        <cfoutput>
            <cfset n=#n# + 1 />
            <cfif #n# is "1">
                <h3>audquestions_user</h3>
            </cfif>
        </cfoutput>

<cfquery result="result"  name="insert">

            INSERT INTO `audquestions_user` (`qtypeid`, `qtext`, `qorder`, `userid`)
            VALUES (#x.qtypeid#, '#x.qtext#', #x.qorder#, #select_userid#);

        </cfquery>
        <cfif #dbug# is "Y">
            <CFOUTPUT>Audquestions_user added: #x.qtext#</CFOUTPUT><BR>
        </cfif>

</cfif>

</cfloop>

<cfset n=0 />

<cfquery result="result"  name="x">
    SELECT submitsitename,catlist FROM audsubmitsites
</cfquery>

<cfloop query="x">

<cfquery result="result"  name="find">
        Select * from audsubmitsites_user
        where submitsitename = '#x.submitsitename#' and userid = #select_userid#
    </cfquery>

    <cfif #find.recordcount# is "0">
        <cfoutput>
            <cfset n=#n# + 1 />
            <cfif #n# is "1">
                <h3>audsubmitsites_user</h3>
            </cfif>
        </cfoutput>

<cfquery result="result"  name="insert">

            INSERT INTO `audsubmitsites_user` (`submitsitename`, `catlist`, `userid`)
            VALUES ('#x.submitsitename#','#x.catlist#',#select_userid#);

        </cfquery>
        <cfif #dbug# is "Y">

            <CFOUTPUT>audsubmitsites_user added: #x.submitsitename#</CFOUTPUT><br />

        </cfif>

    </cfif>

</cfloop>

<cfset n=0 />

<cfquery result="result"  name="x">
    select toneid,
    tone,
    audcatid,
    isDeleted
    FROM audtones
    where isdeleted =0
</cfquery>

<cfloop query="x">

    <cfquery result="result"  name="find">
        Select * from audtones_user
        where tone = '#x.tone#' and userid = #select_userid#
    </cfquery>

    <cfif #find.recordcount# is "0">
        <cfoutput>
            <cfset n=#n# + 1 />
            <cfif #n# is "1">
                <h3>audtones_user</h3>
            </cfif>
        </cfoutput>

        <cfquery result="result"  name="insert">
            INSERT INTO `audtones_user` (`tone`, `audcatid`, `userid`)
            VALUES ('#x.tone#','#x.audcatid#',#select_userid#);
        </cfquery>

        <cfoutput>
            audtones added: #x.tone# <br />
        </cfoutput>

    </cfif>

</cfloop>

<cfset n=0 />

<cfquery result="result"  name="x">
    select eventTypeName
    ,eventtypedescription
    ,eventtypecolor
    FROM eventtypes
    where isdeleted = 0
</cfquery>

<cfloop query="x">

    <cfquery result="result"  name="find">
        select eventTypeName
        ,eventtypedescription
        ,eventtypecolor
        FROM eventtypes_user
        where eventTypeName = '#x.eventtypeName#' and userid = #select_userid#
    </cfquery>

    <cfif #find.recordcount# is "0">
        <cfoutput>
            <cfset n=#n# + 1 />
            <cfif #n# is "1">
                <h3>Eventtypes_user</h3>
            </cfif>
        </cfoutput>

        <cfquery result="result"  name="insert">
            INSERT INTO `eventtypes_user` (`eventTypeName`,`eventtypedescription`,`eventtypecolor`,`userid`)
            VALUES ('#x.eventTypeName#', '#x.eventtypedescription#','#x.eventtypecolor#', #select_userid#);
        </cfquery>

        <cfif #dbug# is "Y">

            <CFOUTPUT> eventtypes_user: #x.eventTypeName# added</CFOUTPUT><br />

        </cfif>

    </cfif>

</cfloop>

<cfset n=0 />

<cfquery result="result"  name="x">
    SELECT genderpronoun,genderpronounplural FROM genderpronouns where isdeleted = 0
</cfquery>

<cfloop query="x">

    <cfquery result="result"  name="find">
        Select * from genderpronouns_users
        where genderpronoun = '#x.genderpronoun#' and userid = #select_userid#
    </cfquery>

    <cfif #find.recordcount# is "0">
        <cfoutput>
            <cfset n=#n# + 1 />
            <cfif #n# is "1">
                <h3>genderpronouns_users</h3>
            </cfif>
        </cfoutput>

        <cfquery result="result"  name="insert">

            INSERT INTO `genderpronouns_users` (`genderpronoun`, `genderpronounplural`, `userid`)
            VALUES ('#x.genderpronoun#','#x.genderpronounplural#',#select_userid#);

        </cfquery>

        <cfif #dbug# is "Y">

            <CFOUTPUT> genderpronouns_users: #x.genderpronoun# added</CFOUTPUT><br />

        </cfif>
    </cfif>
</cfloop>

<cfset n=0 />

<cfquery result="result"  name="x">
    select typeid,valuetype,typeicon FROM itemtypes
</cfquery>

<cfloop query="x">

    <cfquery result="result"  name="find">
        Select * from itemtypes_user
        where valuetype = '#x.valuetype#' and userid = #select_userid#
    </cfquery>

    <cfif #find.recordcount# is "0">
        <cfoutput>
            <cfset n=#n# + 1 />
            <cfif #n# is "1">
                <h3>itemtypes_user</h3>
            </cfif>
        </cfoutput>

        <cfquery result="result"  name="insert">
            INSERT INTO `itemtypes_user` (`valuetype`, `typeicon`, `userid`)
            VALUES ('#x.valuetype#','#x.typeicon#',#select_userid#);
        </cfquery>

        <cfif #dbug# is "Y">

            <CFOUTPUT>itemtypes_user: #x.valuetype# added</CFOUTPUT><br />

        </cfif>

    </cfif>

</cfloop>

<cfset n=0 />

<cfquery result="result"  name="x">
    select DISTINCT c.catid,i.valuetype
    FROM itemcategory c
    inner join itemcatxref x ON x.catid = c.catid
    INNER JOIN itemtypes i ON i.typeid = x.typeid

    WHERE c.isdeleted = 0 AND i.isdeleted = 0
    ORDER BY c.catid,i.valuetype
</cfquery>

<cfloop query="x">

    <cfset new_catid=x.catid />

    <cfquery result="result"  name="find">
        Select typeid from itemtypes_user
        where valuetype = '#x.valuetype#' and userid = #select_userid#
    </cfquery>

    <cfset new_typeid=find.typeid />

    <cfquery result="result"  name="check">
        select * from itemcatxref_user where userid = #select_userid# and typeid = #new_typeid# and catid = #new_catid#
    </cfquery>

    <cfif #check.recordcount# is "0">

        <cfoutput>
            <cfset n=#n# + 1 />
            <cfif #n# is "1">
                <h3>itemcatxref_user</h3>
            </cfif>
        </cfoutput>

        <cfquery result="result"  name="insert">
            INSERT INTO `itemcatxref_user` (`typeid`, `catid`, `userid`)
            VALUES (#new_typeid#,#new_catid#,#select_userid#);
        </cfquery>

        <cfif #dbug# is "Y">
            <CFOUTPUT>itemcatxref_user: (#new_typeid#,#new_catid#,#select_userid#) added</CFOUTPUT><br />
        </cfif>

    </cfif>

</cfloop>

<cfset n=0 />

<cfquery result="result"  name="x">
    SELECT * FROM pgpanels_master
</cfquery>

<cfloop query="x">

    <cfquery result="result"  name="FIND">
        SELECT * FROM pgpanels_user where userid = #select_userid# and pnFilename = '#x.pnFilename#' and isdeleted = 0
    </cfquery>

    <cfif #find.recordcount# is "0">
        <cfoutput>
            <cfset n=#n# + 1 />
            <cfif #n# is "1">
                <h3>pgpanels_user</h3>
            </cfif>
        </cfoutput>
        <cfquery result="result"  name="insert">

            INSERT INTO `pgpanels_user` (`userid`,`pnTitle`, `pnFilename`, `pnOrderNo`, `pnColXl`, `pnColMd`, `pnDescription`,`IsVisible`)
            VALUES
            (#select_userid#,'#x.pntitle#', '#x.pnfilename#', #x.pnOrderNo#, #x.pnColXl#, #x.pnColMd#, '#x.pnDescription#',1);

        </cfquery>

</cfif>

</cfloop>

<cfset n=0 />

<cfquery result="result"  name="x">
    select sitetypename,sitetypedescription from sitetypes_master
</cfquery>

<cfloop query="x">

    <cfquery result="result"  name="find">
        Select * from sitetypes_user
        where sitetypename = '#x.sitetypename#' and userid = #select_userid#
    </cfquery>

    <cfif #find.recordcount# is "0">
        <cfoutput>
            <cfset n=#n# + 1 />
            <cfif #n# is "1">
                <h3>SiteTypes</h3>
            </cfif>
        </cfoutput>
        <cfquery result="result"  name="insert">
            INSERT INTO `sitetypes_user` (`siteTypeName`, `siteTypeDescription`, `userid`)
            VALUES ('#x.sitetypename#','#x.sitetypedescription#',#select_userid#);
        </cfquery>

        <cfoutput>
            Sitetypes_user added: #x.sitetypename#<br />
        </cfoutput>

    </cfif>

</cfloop>

<cfset n=0 />

<cfquery result="result"  name="x">
    select
    s.id
    ,s.sitename
    ,s.siteURL
    ,s.siteicon
    ,s.sitetypeid
    ,t.sitetypename
    FROM sitelinks_master s INNER JOIN sitetypes_master t ON t.sitetypeid = s.siteTypeid
    ORDER BY s.sitename
</cfquery>

<cfloop query="x">

    <cfquery result="result"  name="find">
        Select sitetypeid from sitetypes_user
        where sitetypename = '#x.sitetypename#' and userid = #select_userid#
    </cfquery>

<cfif #find.recordcount# is "0">

<cfoutput>
            <cfset n=#n# + 1 />
            <cfif #n# is "1">
                <h3>sitelinks_user</h3>
            </cfif>
        </cfoutput>

        <cfset new_sitetypeid=find.sitetypeid />

        <cfquery result="result"  name="find2">
            Select * from sitelinks_user_tbl where sitename = '#x.sitename#' and userid = #select_userid#
        </cfquery>

        <cfif #find2.recordcount# is "0">

            <cfquery result="result"  name="insert">
                INSERT INTO `sitelinks_user_tbl` (`siteName`,`siteURL`,`siteicon`,`siteTypeid`,`userid`)
                VALUES ('#x.sitename#','#x.siteurl#','#x.siteicon#', #new_sitetypeid#, #select_userid#);
            </cfquery>

            <cfif #dbug# is "Y">

                <CFOUTPUT> sitelinks_user_tbl: #x.sitename# added</CFOUTPUT><br />

            </cfif>

        </cfif>

    </cfif>

</cfloop>

<cfset n=0 />

<cfquery result="result"  name="x">
    SELECT * FROM tags
</cfquery>

<cfloop query="x">

    <cfquery result="result"  name="find">
        Select * from tags_user
        where tagname = '#x.tagname#' and userid = #select_userid#
    </cfquery>

    <cfif #find.recordcount# is "0">
        <cfoutput>
            <cfset n=#n# + 1 />
            <cfif #n# is "1">
                <h3>tags_user</h3>
            </cfif>
        </cfoutput>

        <cfquery result="result"  name="insert">
            INSERT INTO `tags_user` (`tagname`, `userid`)
            VALUES ('#x.tagname#',#select_userid#);
        </cfquery>

        <cfif #dbug# is "Y">
            <CFOUTPUT>tags_user: #x.tagname# added</CFOUTPUT><br />
        </cfif>

    </cfif>

</cfloop>
