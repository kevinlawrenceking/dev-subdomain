<cfparam name="dbug" default="Y" /> 
<cfparam name="select_user" default="0" />
<cfparam name="select_contactid" default="0" />
<cfparam name="select_userid" default="0" />

    <cfset currentURL = cgi.server_name />
    <cfset host = ListFirst(currentURL, ".") />
    
    <cfif #select_userid# is "0">
    No user <CFABORT>
    </cfif>

<cfoutput>
    <cfset starttime = "#timeformat(NOw(),'HHMMSS')#" />

<cfoutput>

<cfset browser_media_root_user="#session.userMediaUrl#" />

        <cfif #dbug# is "Y">

            <p>browser_media_root_user: #browser_media_root_user#</p>

        </cfif>

<cfset dir_media_root_user="#session.userMediaPath#" />

        <cfif #dbug# is "Y">

            <p>dir_media_root_user: #session.userMediaPath#</p>

        </cfif>

<cfset session.contactAvatarUrl="#session.userAvatarUrl#" />

        <cfif #dbug# is "Y">

            <p>session.contactAvatarUrl: #session.contactAvatarUrl#</p>

        </cfif>

        <CFIF not DirectoryExists("#session.userMediaPath#")>

            <CFDIRECTORY directory="#session.userMediaPath#" action="create">

<h3>dir_media_root_user dir created: #session.contactAvatarUrl#</h3>

</CFIF>

        <cfset browser_media_root_user_contacts="#session.userContactsUrl#" />

        <cfif #dbug# is "Y">

            <p>browser_media_root_user_contacts: #browser_media_root_user_contacts#</p>

        </cfif>

        <cfset dir_media_root_user_contacts="#session.userContactsPath#" />

        <cfif #dbug# is "Y">

            <p>dir_media_root_user_contacts: #dir_media_root_user_contacts#</p>

        </cfif>

        <CFIF not DirectoryExists("#dir_media_root_user_contacts#")>

            <CFDIRECTORY directory="#dir_media_root_user_contacts#" action="create">

<h3>dir_media_root_user_contacts dir created: #dir_media_root_user_contacts#</h3>

</CFIF>

<cfset browser_media_root_user_imports="#session.userImportsUrl#" />

        <cfif #dbug# is "Y">

            <p>browser_media_root_user_imports: #browser_media_root_user_imports#</p>

        </cfif>

        <cfset dir_media_root_user_imports="#session.userImportsPath#" />

        <cfif #dbug# is "Y">

            <p>dir_media_root_user_imports: #dir_media_root_user_imports#</p>

        </cfif>

        <CFIF not DirectoryExists("#dir_media_root_user_imports#")>

            <CFDIRECTORY directory="#dir_media_root_user_imports#" action="create">

<h3>dir_media_root_user_imports dir created: #dir_media_root_user_imports#</h3>

</CFIF>

        <cfif NOT fileExists(session.userAvatarPath)>

            <cffile action="copy" source="#dir_missing_avatar_filename#" destination="#session.userMediaPath#\" />

<h3>default avatar moved to: #session.userMediaPath#</h3>

</cfif>

    </cfoutput>

<cfquery result="result"  name="C"  >
        SELECT contactid,recordname
        from contactdetails
        where userid = #u.userid#
        <cfif #select_contactid# is not "0">
        and contactid = #select_contactid#
        </cfif>
        order by contactid
    </cfquery>

    <cfif #dbug# is "Y">
        <cfoutput>
            <h3> #u.userid#: Creating folders for #c.recordcount# contacts</h3>

        </cfoutput>

    </cfif>
    <cfloop query="C">

        <cfoutput>

<cfset new_contactid="#C.contactid#" />

            <cfif #dbug# is "Y">
                <h3>#c.recordname#: Contact ID #new_contactid#</h3>
            </cfif>

            <cfset dir_media_root_user_contacts_folder="#dir_media_root_user_contacts#\#new_contactid#" />

<CFIF not DirectoryExists("#dir_media_root_user_contacts_folder#")>

                <CFDIRECTORY directory="#dir_media_root_user_contacts_folder#" action="create">

<h3>dir_media_root_user_contacts_folder dir created: #dir_media_root_user_contacts_folder#</h3>

</cfif>

<cfset dir_media_root_user_contacts_folder_attachements="#dir_media_root_user_contacts_folder#\attachments" />

<CFIF not DirectoryExists("#dir_media_root_user_contacts_folder_attachements#")>

                <CFDIRECTORY directory="#dir_media_root_user_contacts_folder_attachements#" action="create">

<h3>dir_media_root_user_contacts_folder_attachements dir created: #dir_media_root_user_contacts_folder_attachements#</h3>

</cfif>

<cfset dir_contact_avatar_filename="#dir_media_root_user_contacts_folder#\avatar.jpg" />

            <cfif #dbug# is "Y">

                <p>dir_contact_avatar_filename: #dir_contact_avatar_filename#</p>

            </cfif>

<cfif NOT fileExists(dir_contact_avatar_filename)>

                <cffile action="copy" source="#dir_missing_avatar_filename#" destination="#dir_media_root_user_contacts_folder#\" />

<h3>default contact avatar moved to: #dir_media_root_user_contacts_folder#</h3>

</cfif>

</cfoutput>

</cfloop>

 

<cfoutput><cfset endtime = "#timeformat(NOw(),'HHMMSS')#" />

<cfset dur = endtime - starttime />
       <cfif #dbug# is "Y">  
           <h1>Completed: <cfoutput>#dur# second(s)</cfoutput></h1></cfif>
    
            </cfoutput>

<cfquery result="result"  name="users"  >
select userid from taousers 
             <cfif #select_userid# is not "0">
            where userid = #select_userid#
            </cfif>
</cfquery>

<cfloop query="users">

<cfset newuserid = users.userid />

<cfquery result="result"  name="panels"  >
select pnid from pgpanels
</cfquery>

<cfloop query="panels">

<cfset newpnid = panels.pnid />
    
    <cfquery result="result"  name="Find"  >
    Select * from pgpanels_user_xref where pnid = #newpnid# and userid = #newuserid#
    </cfquery>
    
    <cfif #find.recordcount# is "0">
<cfquery result="result"  name="insert"  >
Insert into pgpanels_user_xref (pnid,userid) values (#newpnid#,#newuserid#)
</cfquery>
<cfif #dbug# is "Y">
   <cfoutput> PNID #newpnid# and userid #newuserid# added</cfoutput><BR>                
</cfif>
</cfif>
</cfloop>

</cfloop>

<cfquery result="result"  name="u"  >
        SELECT * from taousers     <cfif #select_userid# is not "0">
        where userid = #select_userid#</cfif>
    </cfquery>

    <cfloop query="u">

        <cfquery result="result"  name="x"  >
            SELECT sitetypename,sitetypedescription from sitetypes_master
        </cfquery>

<cfloop query="x">
            
            <cfquery result="result"  name="find"  >
            Select * from sitetypes_user 
            where sitetypename = '#x.sitetypename#' and userid = #u.userid#
            </cfquery>
            
            <cfif #find.recordcount# is "0">
            
                <cfquery result="result"  name="insert"  >
                    
                    INSERT INTO `sitetypes_user` (`siteTypeName`, `siteTypeDescription`, `userid`) 
                    VALUES ('#x.sitetypename#','#x.sitetypedescription#',#u.userid#);
          
                </cfquery>
                
                <cfoutput>           
                    INSERT INTO `sitetypes_user` (`siteTypeName`, `siteTypeDescription`, `userid`) 
                    VALUES ('#x.sitetypename#','#x.sitetypedescription#',#u.userid#);
                    
                    <BR>
                    
                    </cfoutput>
            </cfif>

        </cfloop>

</cfloop>

<cfquery result="result"  name="u"  >
        SELECT * from taousers 
        <cfif #select_userid# is not "0">
    where userid = #select_userid#
    </cfif>
    </cfquery>

    <cfloop query="u">

        <cfquery result="result"  name="x"  >
            SELECT 

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
            
            <cfquery result="result"  name="find"  >
                Select sitetypeid from sitetypes_user 
                where sitetypename = '#x.sitetypename#' and userid = #u.userid#

            </cfquery>
            
            <cfif #find.recordcount# is "1">
                
                <cfset new_sitetypeid = find.sitetypeid />
                
                      <cfquery result="result"  name="find2"  >
            Select * from sitelinks_user_tbl where sitename = '#x.sitename#' and userid = #u.userid#
                </cfquery>
                
                <cfif #find2.recordcount# is "0">
                <cfquery result="result"  name="insert"  >
                    
                    INSERT INTO `sitelinks_user_tbl` (`siteName`,`siteURL`,`siteicon`,`siteTypeid`,`userid`) 
                    VALUES ('#x.sitename#','#x.siteurl#','#x.siteicon#', #new_sitetypeid#, #u.userid#);

</cfquery>
                
                <cfif #dbug# is "Y">
                <CFOUTPUT>       INSERT INTO `sitelinks_user_tbl` (`siteName`,`siteURL`,`siteicon`,`siteTypeid`,`userid`) 
                    VALUES ('#x.sitename#','#x.siteurl#','#x.siteicon#', #new_sitetypeid#, #u.userid#);</CFOUTPUT><BR>
                </cfif>
                </cfif>
            </cfif>

        </cfloop>

</cfloop>

<cfquery result="result"  name="u"  >
        SELECT * from taousers  
        </cfquery>

    <cfloop query="u">

        <cfquery result="result"  name="x"  >
        SELECT eventTypeName
,eventtypedescription
,eventtypecolor
 FROM eventtypes
        </cfquery>

        <cfloop query="x">

<cfquery result="result"  name="find"  >
            SELECT eventTypeName
            ,eventtypedescription
            ,eventtypecolor
             FROM eventtypes_user
            where eventTypeName = '#x.eventtypeName#' and userid = #u.userid#
            </cfquery>
            
            <cfif #find.recordcount# is "0">
            
                <cfquery result="result"  name="insert"  >
                    INSERT INTO `eventtypes_user` (`eventTypeName`,`eventtypedescription`,`eventtypecolor`,`userid`) 
                    VALUES ('#x.eventTypeName#', '#x.eventtypedescription#','#x.eventtypecolor#', #u.userid#);
                </cfquery>
     
            </cfif>

        </cfloop>

</cfloop>

<cfquery result="result"    name="u"  >
        SELECT * from taousers     
    </cfquery>

    <cfloop query="u">

         <cfquery result="result"  name="x"  >
            SELECT toneid,
tone,
audcatid,
isDeleted
 FROM audtones
        </cfquery>

<cfloop query="x">
            
             <cfquery result="result"  name="find"  >
            Select * from audtones_user
            where tone = '#x.tone#' and userid = #u.userid#
            </cfquery>
            
            <cfif #find.recordcount# is "0">
            
                 <cfquery result="result"  name="insert"  >
                    
                    INSERT INTO `audtones_user` (`tone`, `audcatid`, `userid`) 
                    VALUES ('#x.tone#','#x.audcatid#',#u.userid#);
          
                </cfquery>
                
                <cfoutput>           
                 audtones added: #x.tone# (user #u.userid#)<BR>
                </cfoutput>
            </cfif>

        </cfloop>

</cfloop>

<cfquery result="result"  name="u"  >
        SELECT * from taousers  where userid = #select_userid#
    </cfquery>

    <cfloop query="u">

        <cfquery result="result"  name="x"  >
        SELECT * FROM tags
        </cfquery>

<cfloop query="x">
            
            <cfquery result="result"  name="find"  >
            Select * from tags_user 
            where tagname = '#x.tagname#' and userid = #u.userid#
            </cfquery>
            
            <cfif #find.recordcount# is "0">
            
                <cfquery result="result"  name="insert"  >
                    
                    INSERT INTO `tags_user` (`tagname`,  `userid`) 
                    VALUES ('#x.tagname#',#u.userid#);
          
                </cfquery>

</cfif>

        </cfloop>

</cfloop>

<cfquery result="result"  name="update_tags"  >
        UPDATE tags_user 
            SET IsTeam = 1 
            WHERE userid = #select_userid# and tagname IN (
            SELECT tagname FROM tags WHERE isteam = 1)
        </cfquery>

<cfquery result="result"  name="u"  >
        SELECT * from taousers  where userid = #select_userid#
    </cfquery>

    <cfloop query="u">

        <cfquery result="result"  name="x"  >
      SELECT typeid,valuetype,typeicon FROM itemtypes
        </cfquery>

<cfloop query="x">
            
            <cfquery result="result"  name="find"  >
            Select * from itemtypes_user 
            where valuetype = '#x.valuetype#' and userid = #u.userid#
            </cfquery>
            
            <cfif #find.recordcount# is "0">
            
                <cfquery result="result"  name="insert"  >
                    
                    INSERT INTO `itemtypes_user` (`valuetype`, `typeicon`, `userid`) 
                    VALUES ('#x.valuetype#','#x.typeicon#',#u.userid#);
          
                </cfquery>

</cfif>

        </cfloop>

</cfloop>

<cfquery result="result"  name="u"  >
        SELECT * from taousers where userid = #select_userid#
    </cfquery>

    <cfloop query="u">
        
        <cfset new_userid = u.userid />
        
          <cfquery result="result"  name="x"  >
SELECT DISTINCT c.catid,i.valuetype
FROM itemcategory c

inner join itemcatxref x ON x.catid = c.catid

INNER JOIN itemtypes i ON i.typeid = x.typeid

ORDER BY c.catid,i.valuetype
        </cfquery>

<cfloop query="x">
            
            <cfset new_catid = x.catid />

<cfquery result="result"  name="find"  >
            Select typeid from itemtypes_user
            where valuetype = '#x.valuetype#' and userid = #new_userid#
            </cfquery>
            
            <cfset new_typeid = find.typeid />

<cfquery result="result"  name="check"  >
        select * from itemcatxref_user where userid = #new_userid# and typeid = #new_typeid# and catid = #new_catid#
            </cfquery>

<cfif #check.recordcount# is "0">
            
                <cfquery result="result"  name="insert"  >
                    
                    INSERT INTO `itemcatxref_user` (`typeid`, `catid`, `userid`) 
                    VALUES (#new_typeid#,#new_catid#,#new_userid#);
          
                </cfquery>

</cfif>

        </cfloop>

</cfloop>

