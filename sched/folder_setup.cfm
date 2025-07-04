<cfset dbug="N" />
<cfparam name="select_userid" default="0" />
<cfparam name="select_contactid" default="0" />
<cfoutput>

<cfset currentURL = cgi.server_name />
    <cfset host = ListFirst(currentURL, ".") />

<cfset starttime = "#timeformat(NOw(),'HHMMSS')#" />
    
    <cfset dir_media_root="#datasourceMediaPath#" />

    <cfif #dbug# is "Y">

        <h2>dir_media_root: #dir_media_root#</h2>

    </cfif>

    <cfset browser_media_root="/media-#host#" />

    <cfif #dbug# is "Y">

        <h2>browser_media_root: #browser_media_root#</h2>

    </cfif>

<cfset dir_media_root_defaults="#dir_media_root#\defaults" />

    <cfif #dbug# is "Y">

        <h2>dir_media_root_defaults: #dir_media_root_defaults#</h2>

    </cfif>

    <cfset browser_media_root_defaults="#browser_media_root#/defaults" />

    <cfif #dbug# is "Y">

        <h2>browser_media_root_defaults: #browser_media_root_defaults#</h2>

    </cfif>

    <cfset dir_missing_avatar_filename="#dir_media_root_defaults#\avatar.jpg" />

    <cfif #dbug# is "Y">

        <h2>dir_missing_avatar_filename: #dir_missing_avatar_filename#</h2>

    </cfif>

    <cfset browser_missing_avatar_filename="#browser_media_root_defaults#/avatar.jpg" />

    <cfif #dbug# is "Y">

        <h2>browser_missing_avatar_filename: #browser_missing_avatar_filename#</h2>

    </cfif>

</cfoutput>

<cfquery result="result"  name="U"  >
    SELECT
    u.userid
    ,u.recordname
    ,u.userFirstName
    ,u.userLastName
    ,u.userEmail
    ,u.contactid
    ,u.userRole
    FROM taousers u
    <cfif #select_userid# is not "0">
    where u.userid = #select_userid#
    </cfif>
</cfquery>

<cfloop query="U">

    <cfoutput>

<cfif #dbug# is "Y">

            <h2>User: #u.userid#</h2>

        </cfif>

        <cfset browser_media_root_user="#session.userMediaUrl#" />

        <cfif #dbug# is "Y">

            <p>browser_media_root_user: #browser_media_root_user#</p>

        </cfif>

<cfset dir_media_root_user="#dir_media_root#\users\#u.userid#" />

        <cfif #dbug# is "Y">

            <p>dir_media_root_user: #session.userMediaPath#</p>

        </cfif>

        <cfset session.userAvatarPath="#session.userMediaPath#\avatar.jpg" />

        <cfif #dbug# is "Y">

            <p>session.userAvatarPath: #session.userAvatarPath#</p>

        </cfif>

        <cfset session.contactAvatarUrl="#browser_media_root_user#/avatar.jpg" />

        <cfif #dbug# is "Y">

            <p>session.contactAvatarUrl: #session.contactAvatarUrl#</p>

        </cfif>

        <CFIF not DirectoryExists("#session.userMediaPath#")>

            <CFDIRECTORY directory="#session.userMediaPath#" action="create">

<h3>dir_media_root_user dir created: #session.contactAvatarUrl#</h3>

</CFIF>

        <cfset browser_media_root_user_contacts="#browser_media_root_user#/contacts" />

        <cfif #dbug# is "Y">

            <p>browser_media_root_user_contacts: #browser_media_root_user_contacts#</p>

        </cfif>

        <cfset dir_media_root_user_contacts="#session.userMediaPath#\contacts" />

        <cfif #dbug# is "Y">

            <p>dir_media_root_user_contacts: #dir_media_root_user_contacts#</p>

        </cfif>

        <CFIF not DirectoryExists("#dir_media_root_user_contacts#")>

            <CFDIRECTORY directory="#dir_media_root_user_contacts#" action="create">

<h3>dir_media_root_user_contacts dir created: #dir_media_root_user_contacts#</h3>

</CFIF>

<cfset browser_media_root_user_imports="#browser_media_root_user#/imports" />

        <cfif #dbug# is "Y">

            <p>browser_media_root_user_imports: #browser_media_root_user_imports#</p>

        </cfif>

        <cfset dir_media_root_user_imports="#session.userMediaPath#\imports" />

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

</cfloop>
<cfoutput><cfset endtime = "#timeformat(NOw(),'HHMMSS')#" />
    
    <cfset dur = endtime - starttime />
       <cfif #dbug# is "Y">  
           <h1>Completed: <cfoutput>#dur# second(s)</cfoutput></h1></cfif>
    
            </cfoutput>
