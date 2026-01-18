<cfparam name="dbug" default="Y" />
<cfparam name="dbugdbug" default="YY" />
<cfparam name="select_user" default="0" />
<cfparam name="select_contactid" default="0" />
<cfparam name="select_userid" default="0" />

<!--- Set current URL and host --->
<cfset currentURL=cgi.server_name />
<cfset host=ListFirst(currentURL, "." ) />

<!--- Check if select_userid is zero --->
<cfif #select_userid# is "0">
    No user <CFABORT>
</cfif>

<cfoutput>
    <!--- Initialize variables and debug outputs --->
    <cfset starttime="#timeformat(NOw(),'HHMMSS')#" />
    <cfset dir_media_root="#datasourceMediaPath#" />

    <cfif #dbugdbug# is "YY">
        <p>dir_media_root: #dir_media_root#</p>
    </cfif>

    <cfset browser_media_root="/media-#host#" />

    <cfif #dbugdbug# is "YY">
        <p>browser_media_root: #browser_media_root#</p>
    </cfif>

    <cfset dir_media_root_defaults="#dir_media_root#\defaults" />

    <cfif #dbugdbug# is "YY">
        <p>dir_media_root_defaults: #dir_media_root_defaults#</p>
    </cfif>

    <cfset browser_media_root_defaults="#browser_media_root#/defaults" />

    <cfif #dbugdbug# is "YY">
        <p>browser_media_root_defaults: #browser_media_root_defaults#</p>
    </cfif>

    <cfset dir_missing_avatar_filename="#dir_media_root_defaults#\avatar.jpg" />

    <cfif #dbugdbug# is "YY">
        <p>dir_missing_avatar_filename: #dir_missing_avatar_filename#</p>
    </cfif>

    <cfset browser_missing_avatar_filename="#browser_media_root_defaults#/avatar.jpg" />

    <cfif #dbugdbug# is "YY">
        <p>browser_missing_avatar_filename: #browser_missing_avatar_filename#</p>
    </cfif>
</cfoutput>

<!--- Include user query --->
<cfinclude template="/include/qry/users_318_1.cfm" />

<!--- Loop through users --->
<cfloop query="users">
    <cfoutput>
        <!--- Initialize user status --->
        <cfset userstatus="No Change" />

        <!--- Debug output for user information --->
        <cfif #dbug# is "Y">
            <cfsavecontent variable="user_output">
                <p>User: #users.userid# - #users.userfirstname# #users.userlastname#</p>
            </cfsavecontent>
        </cfif>

        <!--- Set media root paths for user --->
        <cfset browser_media_root_user="#browser_media_root#/users/#users.userid#" />

        <cfif #dbugdbug# is "YY">
            <p>browser_media_root_user: #browser_media_root_user#</p>
        </cfif>

        <cfset dir_media_root_user="#dir_media_root#\users\#users.userid#" />

        <cfif #dbugdbug# is "YY">
            <p>dir_media_root_user: #session.userMediaPath#</p>
        </cfif>

        <cfset session.userAvatarPath="#session.userMediaPath#\avatar.jpg" />

        <cfif #dbugdbug# is "YY">
            <p>session.userAvatarPath: #session.userAvatarPath#</p>
        </cfif>

        <cfset session.contactAvatarUrl="#browser_media_root_user#/avatar.jpg" />

        <cfif #dbugdbug# is "YY">
            <p>session.contactAvatarUrl: #session.contactAvatarUrl#</p>
        </cfif>

        <!--- Check if user media directory exists --->
        <cfif not DirectoryExists("#session.userMediaPath#")>
            <cfset userstatus="Fixed" />

            <cfif #dbug# is "Y">
                <cfsavecontent variable="user_output">
                    #user_output#
                    <p>Directory [#session.userMediaPath#] does not exist. Creating...</p>
                </cfsavecontent>
            </cfif>

            <cfdirectory directory="#session.userMediaPath#" action="create" />

            <cfif #dbug# is "Y">
                <cfsavecontent variable="user_output">
                    #user_output#
                    <p>Directory [#session.contactAvatarUrl#] created.</p>
                </cfsavecontent>
            </cfif>
        </cfif>

        <!--- Set paths for user contacts --->
        <cfset browser_media_root_user_contacts="#browser_media_root_user#/contacts" />

        <cfif #dbugdbug# is "YY">
            <p>browser_media_root_user_contacts: #browser_media_root_user_contacts#</p>
        </cfif>

        <cfset dir_media_root_user_contacts="#session.userMediaPath#\contacts" />

        <cfif #dbugdbug# is "YY">
            <p>dir_media_root_user_contacts: #dir_media_root_user_contacts#</p>
        </cfif>

        <!--- Check if user contacts directory exists --->
        <cfif not DirectoryExists("#dir_media_root_user_contacts#")>
            <cfset userstatus="Fixed" />

            <cfif #dbug# is "Y">
                <cfsavecontent variable="user_output">
                    #user_output#
                    <p>Directory [#dir_media_root_user_contacts#] does not exist. Creating...</p>
                </cfsavecontent>
            </cfif>

            <CFDIRECTORY directory="#dir_media_root_user_contacts#" action="create" />

            <cfif #dbug# is "Y">
                <cfsavecontent variable="user_output">
                    #user_output#
                    <p>Directory [#dir_media_root_user_contacts#] CREATED.</p>
                </cfsavecontent>
            </cfif>
        </cfif>

        <!--- Set paths for user imports --->
        <cfset browser_media_root_user_imports="#browser_media_root_user#/imports" />

        <cfif #dbugdbug# is "YY">
            <p>browser_media_root_user_imports: #browser_media_root_user_imports#</p>
        </cfif>

        <cfset dir_media_root_user_imports="#session.userMediaPath#\imports" />

        <cfif #dbugdbug# is "YY">
            <p>dir_media_root_user_imports: #dir_media_root_user_imports#</p>
        </cfif>

        <!--- Check if user imports directory exists --->
        <cfif not DirectoryExists("#dir_media_root_user_imports#")>
            <cfset userstatus="Fixed" />

            <cfif #dbug# is "Y">
                <cfsavecontent variable="user_output">
                    #user_output#
                    <p>Directory [#dir_media_root_user_imports#] does not exist. Creating...</p>
                </cfsavecontent>
            </cfif>

            <CFDIRECTORY directory="#dir_media_root_user_imports#" action="create">
                <cfif #dbug# is "Y">
                    <cfsavecontent variable="user_output">
                        #user_output#
                        <p>Directory [#dir_media_root_user_imports#] CREATED.</p>
                    </cfsavecontent>
                </cfif>
            </CFDIRECTORY>
        </cfif>

        <!--- Check if avatar file exists --->
        <cfif NOT fileExists(session.userAvatarPath)>
            <cfset userstatus="Fixed" />
            <cffile action="copy" source="#dir_missing_avatar_filename#" destination="#session.userMediaPath#\" />

            <cfif #dbug# is "Y">
                <cfsavecontent variable="user_output">
                    #user_output#
                    <p>default avatar moved to: #session.userMediaPath#</p>
                </cfsavecontent>
            </cfif>
        </cfif>
    </cfoutput>

    <!--- Include contacts query --->
    <cfinclude template="/include/qry/C_318_2.cfm" />

    <!--- Debug output for creating folders for contacts --->
    <cfif #dbug# is "Y">
        <cfoutput>
            <cfsavecontent variable="user_output">
                #user_output#
                <p> #users.recordname#: Creating folders for #c.recordcount# contacts</p>
            </cfsavecontent>
        </cfoutput>
    </cfif>

    <!--- Loop through contacts --->
    <cfloop query="C">
        <cfoutput>
            <cfset new_contactid="#C.contactid#" />
            <cfset dir_media_root_user_contacts_folder="#dir_media_root_user_contacts#\#new_contactid#" />

            <!--- Check if contact folder exists --->
            <cfif not DirectoryExists("#dir_media_root_user_contacts_folder#")>
                <cfset userstatus="Fixed" />

                <cfif #dbug# is "Y">
                    <cfsavecontent variable="user_output">
                        #user_output#
                        <p>#c.recordname# Directory [#dir_media_root_user_contacts_folder#] does not exist. Creating...</p>
                    </cfsavecontent>
                </cfif>

                <CFDIRECTORY directory="#dir_media_root_user_contacts_folder#" action="create" />
                <cfif #dbug# is "Y">
                    <cfsavecontent variable="user_output">
                        #user_output#
                        <p>Directory [#dir_media_root_user_contacts_folder#] CREATED.</p>
                    </cfsavecontent>
                </cfif>
            </cfif>

            <!--- Set attachments folder for contact --->
            <cfset dir_media_root_user_contacts_folder_attachements="#dir_media_root_user_contacts_folder#\attachments" />

            <!--- Check if attachments folder exists --->
            <cfif not DirectoryExists("#dir_media_root_user_contacts_folder_attachements#")>
                <cfset userstatus="Fixed" />

                <cfif #dbug# is "Y">
                    <cfsavecontent variable="user_output">
                        #user_output#
                        <p>#c.recordname# Directory [#dir_media_root_user_contacts_folder_attachements#] does not exist. Creating...</p>
                    </cfsavecontent>
                </cfif>

                <CFDIRECTORY directory="#dir_media_root_user_contacts_folder_attachements#" action="create" />
                <cfif #dbug# is "Y">
                    <cfsavecontent variable="user_output">
                        #user_output#
                        <p>Directory [#dir_media_root_user_contacts_folder_attachements#] CREATED.</p>
                    </cfsavecontent>
                </cfif>
            </cfif>

            <!--- Set contact avatar filename --->
            <cfset dir_contact_avatar_filename="#dir_media_root_user_contacts_folder#\avatar.jpg" />

            <cfif #dbugdbug# is "YY">
                <p>dir_contact_avatar_filename: #dir_contact_avatar_filename#</p>
            </cfif>

            <!--- Check if contact avatar file exists --->
            <cfif NOT fileExists(dir_contact_avatar_filename)>
                <cfset userstatus="Fixed" />

                <cfif #dbug# is "Y">
                    <cfsavecontent variable="user_output">
                        #user_output#
                        <p>#c.recordname# filename [#dir_missing_avatar_filename#] does not exist. Moving default...</p>
                    </cfsavecontent>
                </cfif>

                <cffile action="copy" source="#dir_missing_avatar_filename#" destination="#dir_media_root_user_contacts_folder#\" />

                <cfif #dbug# is "Y">
                    <cfsavecontent variable="user_output">
                        #user_output#
                        <p>Default contact avatar moved to: #dir_media_root_user_contacts_folder#\#dir_missing_avatar_filename#.</p>
                    </cfsavecontent>
                </cfif>
            </cfif>
        </cfoutput>
    </cfloop>

    <!--- Include additional queries for contacts --->
    <cfinclude template="/include/qry/m_318_3.cfm" />

    <cfloop query="m">
        <cfinclude template="/include/qry/FIND_318_4.cfm" />

        <!--- Check if find record count is zero --->
        <cfif #find.recordcount# is "0">
            <cfinclude template="/include/qry/insert_318_5.cfm" />
        </cfif>
    </cfloop>

    <cfinclude template="/include/qry/x_318_6.cfm" />

    <cfloop query="x">
        <cfoutput>
            <cfinclude template="/include/qry/find_318_7.cfm" />

            <!--- Check if find record count is zero --->
            <cfif #find.recordcount# is "0">
                <cfset userstatus="Fixed" />

                <cfif #dbug# is "Y">
                    <cfsavecontent variable="user_output">
                        #user_output#
                        <p>#users.recordname# has no custom sitetypes. Adding....</p>
                    </cfsavecontent>
                </cfif>

                <cfinclude template="/include/qry/insert_318_8.cfm" />
                <cfset new_sitetypeid = result.generated_key />

                <cfoutput>
                    <Cfset new_pntitle = "#x.sitetypename# Links" />
                </cfoutput>

                <cfinclude template="/include/qry/Findtotal_318_9.cfm" />
                <cfinclude template="/include/qry/add_318_10.cfm" />
                <cfset new_pnid = PN.generated_key />
                <cfinclude template="/include/qry/add_249_6.cfm" />

                <cfsavecontent variable="user_output">
                    #user_output#
                    <p>INSERT INTO `sitetypes_user` (`siteTypeName`, `siteTypeDescription`, `userid`)
                        VALUES ('#x.sitetypename#','#x.sitetypedescription#',#users.userid#);</p>
                </cfsavecontent>
            </cfif>
        </cfoutput>
    </cfloop>

    <cfinclude template="/include/qry/x_318_12.cfm" />

    <cfloop query="x">
        <cfoutput>
            <cfinclude template="/include/qry/find_318_13.cfm" />

            <!--- Check if find record count is zero --->
            <cfif #find.recordcount# is "0">
                <cfset userstatus="Fixed" />

                <cfif #dbug# is "Y">
                    <cfsavecontent variable="user_output">
                        #user_output#
                        <p>#users.recordname# has no custom gender pronouns. Adding....</p>
                    </cfsavecontent>
                </cfif>

                <cfinclude template="/include/qry/insert_318_14.cfm" />
                <cfsavecontent variable="user_output">
                    #user_output#
                    <p> INSERT INTO `genderpronouns_users` (`genderpronoun`, `genderpronounplural`, `userid`)
                        VALUES ('#x.genderpronoun#','#x.genderpronounplural#',#users.userid#);
                    </p>
                </cfsavecontent>
            </cfif>
        </cfoutput>
    </cfloop>

    <cfinclude template="/include/qry/x_318_15.cfm" />

    <cfloop query="x">
        <cfoutput>
            <cfinclude template="/include/qry/find_318_16.cfm" />

            <!--- Check if find record count is one --->
            <cfif #find.recordcount# is "1">
                <cfset new_sitetypeid=find.sitetypeid />
                <cfinclude template="/include/qry/find2_318_17.cfm" />

                <!--- Check if find2 record count is zero --->
                <cfif #find2.recordcount# is "0">
                    <cfset userstatus="Fixed" />

                    <cfif #dbug# is "Y">
                        <cfsavecontent variable="user_output">
                            #user_output#
                            <p>#users.recordname# has no custom sitelinks_user_tbl. Adding....</p>
                        </cfsavecontent>
                    </cfif>

                    <cfinclude template="/include/qry/insert_318_18.cfm" />

                    <cfif #dbug# is "Y">
                        <cfsavecontent variable="user_output">
                            #user_output#
                            <p>
                                INSERT INTO `sitelinks_user_tbl` (`siteName`,`siteURL`,`siteicon`,`siteTypeid`,`userid`)
                                VALUES ('#x.sitename#','#x.siteurl#','#x.siteicon#', #new_sitetypeid#, #users.userid#);
                            </p>
                        </cfsavecontent>
                    </cfif>
                </cfif>
            </cfif>
        </cfoutput>
    </cfloop>

    <cfinclude template="/include/qry/xs_318_19.cfm" />

    <cfloop query="xs">
        <cfoutput>
            <cfinclude template="/include/qry/find_318_20.cfm" />

            <!--- Check if find record count is zero --->
            <cfif #find.recordcount# is "0">
                <cfset userstatus="Fixed" />

                <cfif #dbug# is "Y">
                    <cfsavecontent variable="user_output">
                        #user_output#
                        <p>#users.recordname# has no custom event types. Adding....</p>
                    </cfsavecontent>
                </cfif>

                <cfinclude template="/include/qry/insert_318_21.cfm" />
                <cfif #dbug# is "Y">
                    <cfsavecontent variable="user_output">
                        #user_output#
                        <p>INSERT INTO `eventtypes_user` (`eventTypeName`,`eventtypedescription`,`eventtypecolor`,`userid`)
                            VALUES ('#xs.eventTypeName#', '#xs.eventtypedescription#','#xs.eventtypecolor#', #users.userid#);</p>
                    </cfsavecontent>
                </cfif>
            </cfif>
        </cfoutput>
    </cfloop>

    <cfinclude template="/include/qry/xs_318_22.cfm" />

    <cfloop query="xs">
        <cfoutput>
            <cfinclude template="/include/qry/getActionUsers.cfm" />

            <!--- Check if find record count is zero --->
            <cfif #find.recordcount# is "0">
                <cfset userstatus="Fixed" />

                <cfif #dbug# is "Y">
                    <cfsavecontent variable="user_output">
                        #user_output#
                        <p>#users.recordname# has no custom event types. Adding....</p>
                    </cfsavecontent>
                </cfif>

                <cfinclude template="/include/qry/insert_318_24.cfm" />

                <cfif #dbug# is "Y">
                    <cfsavecontent variable="user_output">
                        #user_output#
                        <p>INSERT INTO `actionusers_tbl` (`actionid`,`userid`,`actiondaysno`<cfif #xs.actiondaysrecurring# is not "">,`actiondaysrecurring`</cfif>,`IsDeleted`)
                            VALUES (#xs.actionid#, #users.userid#,#xs.actiondaysno#<cfif #xs.actiondaysrecurring# is not "">,#actiondaysrecurring#</cfif>, 0);</p>
                    </cfsavecontent>
                </cfif>
            </cfif>
        </cfoutput>
    </cfloop>

    <cfinclude template="/include/qry/x_318_25.cfm" />

    <cfloop query="x">
        <cfoutput>
            <cfinclude template="/include/qry/find_318_26.cfm" />

            <!--- Check if find record count is zero --->
            <cfif #find.recordcount# is "0">
                <cfset userstatus="Fixed" />

                <cfif #dbug# is "Y">
                    <cfsavecontent variable="user_output">
                        #user_output#
                        <p>#users.recordname# has no custom tags_user. Adding....</p>
                    </cfsavecontent>
                </cfif>

                <cfinclude template="/include/qry/insert_318_27.cfm" />
                <cfif #dbug# is "Y">
                    <cfsavecontent variable="user_output">
                        #user_output#
                        <p> INSERT INTO `tags_user` (`tagname`, `userid`, `tagtype`)
                            VALUES ('#x.tagname#',#users.userid#, '#x.tagtype#');</p>
                    </cfsavecontent>
                </cfif>
            </cfif>
        </cfoutput>
    </cfloop>

    <cfinclude template="/include/qry/update_tags_318_28.cfm" />
    <cfinclude template="/include/qry/update_Iscasting_318_29.cfm" />
    <cfinclude template="/include/qry/u_318_30.cfm" />
    <cfinclude template="/include/qry/x_318_31.cfm" />

    <cfloop query="x">
        <cfoutput>
            <cfinclude template="/include/qry/find_318_32.cfm" />

            <!--- Check if find record count is zero --->
            <cfif #find.recordcount# is "0">
                <cfset userstatus="Fixed" />

                <cfif #dbug# is "Y">
                    <cfsavecontent variable="user_output">
                        #user_output#
                        <p>#users.recordname# has no custom itemtypes_user. Adding....</p>
                    </cfsavecontent>
                </cfif>

                <cfinclude template="/include/qry/insert_318_33.cfm" />

                <cfif #dbug# is "Y">
                    <cfsavecontent variable="user_output">
                        #user_output#
                        <p> INSERT INTO `itemtypes_user` (`valuetype`, `typeicon`, `userid`)
                            VALUES ('#x.valuetype#','#x.typeicon#',#users.userid#);</p>
                    </cfsavecontent>
                </cfif>
            </cfif>
        </cfoutput>
    </cfloop>

    <cfinclude template="/include/qry/x_318_34.cfm" />

    <cfloop query="x">
        <cfoutput>
            <cfset new_catid=x.catid />
            <cfinclude template="/include/qry/find_318_35.cfm" />
            <cfset new_typeid=find.typeid />
            <cfinclude template="/include/qry/check_318_36.cfm" />

            <!--- Check if check record count is zero --->
            <cfif #check.recordcount# is "0">
                <cfset userstatus="Fixed" />

                <cfif #dbug# is "Y">
                    <p>#users.recordname# has no custom itemcatxref_user. Adding....</p>
                </cfif>

                <cfinclude template="/include/qry/insert_318_37.cfm" />

                <cfif #dbug# is "Y">
                    <cfsavecontent variable="user_output">
                        #user_output#
                        <p> INSERT INTO `itemcatxref_user` (`typeid`, `catid`, `userid`)
                            VALUES (#new_typeid#,#new_catid#,#select_userid#);</p>
                    </cfsavecontent>
                </cfif>
            </cfif>
        </cfoutput>
    </cfloop>

    <cfoutput>
        <!--- Calculate duration and debug output --->
        <cfset endtime="#timeformat(NOw(),'HHMMSS')#" />
        <cfset dur=endtime - starttime />

        <cfif #dbug# is "Y">
            <cfsavecontent variable="user_output">
                #user_output#
                <p>Completed: #dur# second(s)</p>
            </cfsavecontent>
        </cfif>

        <!--- Check if user status is fixed --->
        <cfif #userstatus# is "Fixed">
            <cfmail to="kevinking7135@gmail.com" from="support@theactorsoffice.com" subject="#users.recordname# Fixed" type="html">
                #user_output#
            </cfmail>

            <cfset user_output="" />
        </cfif>

        #user_output#
    </cfoutput>
</cfloop>

