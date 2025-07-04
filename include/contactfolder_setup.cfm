<!--- This ColdFusion page manages user media directories and avatars for contacts. --->

<cfset dbug="N" />

<cfparam name="select_userid" default="0" />
<cfparam name="select_contactid" default="0" />

<!--- Set current URL and host variables --->
<cfset currentURL = cgi.server_name />
<cfset host = ListFirst(currentURL, ".") />

<cfoutput>
    <!--- Store the start time for processing --->
    <cfset starttime = "#timeformat(NOw(),'HHMMSS')#" />
</cfoutput>

<!--- Include the first query template --->
<cfinclude template="/include/qry/U_73_1.cfm" />

<!--- Loop through user query results --->
<cfloop query="U">
    <cfoutput>
        <!--- Debug output for user ID --->
        <cfif #dbug# is "Y">
            <h2>User: #u.userid#</h2>
        </cfif>

        <!--- Set user media root URL --->
        <cfset browser_media_root_user = "#session.userMediaUrl#" />
        <cfset session.contactAvatarUrl = "#browser_media_root_user#/avatar.jpg" />

        <!--- Debug output for contact avatar URL --->
        <cfif #dbug# is "Y">
            <p>session.contactAvatarUrl: #session.contactAvatarUrl#</p>
        </cfif>

        <!--- Create user media directory if it doesn't exist --->
        <CFIF not DirectoryExists("#session.userMediaPath#")>
            <CFDIRECTORY directory="#session.userMediaPath#" action="create">
            <h3>dir_media_root_user dir created: #session.contactAvatarUrl#</h3>
        </CFIF>

        <!--- Set contacts media root URL --->
        <cfset browser_media_root_user_contacts = "#browser_media_root_user#/contacts" />

        <!--- Debug output for contacts media root URL --->
        <cfif #dbug# is "Y">
            <p>browser_media_root_user_contacts: #browser_media_root_user_contacts#</p>
        </cfif>

        <cfset dir_media_root_user_contacts = "#session.userMediaPath#\contacts" />

        <!--- Debug output for contacts media directory --->
        <cfif #dbug# is "Y">
            <p>dir_media_root_user_contacts: #dir_media_root_user_contacts#</p>
        </cfif>

        <!--- Create contacts media directory if it doesn't exist --->
        <CFIF not DirectoryExists("#dir_media_root_user_contacts#")>
            <CFDIRECTORY directory="#dir_media_root_user_contacts#" action="create">
            <h3>dir_media_root_user_contacts dir created: #dir_media_root_user_contacts#</h3>
        </CFIF>

        <!--- Set imports media root URL --->
        <cfset browser_media_root_user_imports = "#browser_media_root_user#/imports" />

        <!--- Debug output for imports media root URL --->
        <cfif #dbug# is "Y">
            <p>browser_media_root_user_imports: #browser_media_root_user_imports#</p>
        </cfif>

        <cfset dir_media_root_user_imports = "#session.userMediaPath#\imports" />

        <!--- Debug output for imports media directory --->
        <cfif #dbug# is "Y">
            <p>dir_media_root_user_imports: #dir_media_root_user_imports#</p>
        </cfif>

        <!--- Create imports media directory if it doesn't exist --->
        <CFIF not DirectoryExists("#dir_media_root_user_imports#")>
            <CFDIRECTORY directory="#dir_media_root_user_imports#" action="create">
            <h3>dir_media_root_user_imports dir created: #dir_media_root_user_imports#</h3>
        </CFIF>

        <!--- Check if user avatar exists, if not, copy default avatar --->
        <cfif NOT fileExists(session.userAvatarPath)>
            <cffile action="copy" source="#application.defaultAvatarUrl#" destination="#session.userMediaPath#\" />
            <h3>default avatar moved to: #session.userMediaPath#</h3>
        </cfif>
    </cfoutput>

    <!--- Include the second query template --->
    <cfinclude template="/include/qry/C_73_2.cfm" />

    <!--- Debug output for creating folders for contacts --->
    <cfif #dbug# is "Y">
        <cfoutput>
            <h3>#u.userid#: Creating folders for #c.recordcount# contacts</h3>
        </cfoutput>
    </cfif>

    <!--- Loop through contact query results --->
    <cfloop query="C">
        <cfoutput>
            <cfset new_contactid = "#C.contactid#" />

            <!--- Debug output for contact ID --->
            <cfif #dbug# is "Y">
                <h3>#c.recordname#: Contact ID #new_contactid#</h3>
            </cfif>

            <cfset dir_media_root_user_contacts_folder = "#dir_media_root_user_contacts#\#new_contactid#" />

            <!--- Create contact media directory if it doesn't exist --->
            <CFIF not DirectoryExists("#dir_media_root_user_contacts_folder#")>
                <CFDIRECTORY directory="#dir_media_root_user_contacts_folder#" action="create">
                <h3>dir_media_root_user_contacts_folder dir created: #dir_media_root_user_contacts_folder#</h3>
            </CFIF>

            <!--- Set attachments directory for contact --->
            <cfset dir_media_root_user_contacts_folder_attachements = "#dir_media_root_user_contacts_folder#\attachments" />

            <!--- Create attachments directory if it doesn't exist --->
            <CFIF not DirectoryExists("#dir_media_root_user_contacts_folder_attachements#")>
                <CFDIRECTORY directory="#dir_media_root_user_contacts_folder_attachements#" action="create">
                <h3>dir_media_root_user_contacts_folder_attachements dir created: #dir_media_root_user_contacts_folder_attachements#</h3>
            </CFIF>

            <!--- Set contact avatar filename --->
            <cfset dir_contact_avatar_filename = "#dir_media_root_user_contacts_folder#\avatar.jpg" />

            <!--- Debug output for contact avatar filename --->
            <cfif #dbug# is "Y">
                <p>dir_contact_avatar_filename: #dir_contact_avatar_filename#</p>
            </cfif>

            <!--- Check if contact avatar exists, if not, copy default avatar --->
            <cfif NOT fileExists(dir_contact_avatar_filename)>
                <cffile action="copy" source="#Application.defaultAvatarPath#" destination="#dir_media_root_user_contacts_folder#\" />
                <h3>default contact avatar moved to: #dir_media_root_user_contacts_folder#</h3>
            </cfif>
        </cfoutput>
    </cfloop>
</cfloop>

<cfoutput>
    <!--- Store the end time for processing and calculate duration --->
    <cfset endtime = "#timeformat(NOw(),'HHMMSS')#" />
    <cfset dur = endtime - starttime />

    <!--- Debug output for processing completion --->
    <cfif #dbug# is "Y">  
        <h1>Completed: <cfoutput>#dur# second(s)</cfoutput></h1>
    </cfif>
</cfoutput>
