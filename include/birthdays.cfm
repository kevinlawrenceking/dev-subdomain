<!--- This ColdFusion page displays a dashboard card for upcoming birthdays, fetching data from the BirthdayService and rendering it in a structured format. --->

<style>
/* Birthday Styles - scoped to birthday container only */
#birthdaysContainer .birthday-row {
    border: 1px solid #e9ecef;
    border-radius: 6px;
    padding: 8px 12px;
    margin-bottom: 8px;
    background-color: #ffffff;
    transition: all 0.3s ease;
    word-wrap: break-word;
    overflow: hidden;
    position: relative;
    min-height: 48px;
}

#birthdaysContainer .birthday-row:hover {
    border-color: #adb5bd;
    box-shadow: 0 2px 4px rgba(0,0,0,0.05);
}

#birthdaysContainer .birthday-avatar-container {
    display: flex;
    align-items: center;
    margin-right: 12px;
    min-width: 32px;
    height: 32px;
}

#birthdaysContainer .birthday-avatar {
    max-width: 32px;
    max-height: 32px;
    width: 32px;
    height: 32px;
    border-radius: 50%;
    object-fit: cover;
}

#birthdaysContainer .birthday-content {
    display: flex;
    flex-direction: column;
    justify-content: center;
    min-height: 32px;
}

#birthdaysContainer .birthday-name {
    font-weight: 600;
    color: #495057;
    font-size: 14px;
    line-height: 1.3;
}

#birthdaysContainer .birthday-date {
    color: #6c757d;
    font-size: 12px;
    margin-top: 2px;
    line-height: 1.3;
}

#birthdaysContainer .birthday-actions .btn {
    padding: 2px 6px;
    font-size: 11px;
    border-radius: 3px;
    margin-left: 4px;
}

#birthdaysContainer .birthday-actions .btn i {
    font-size: 10px;
}

#birthdaysContainer .birthdays-empty {
    text-align: center;
    padding: 20px;
    color: #6c757d;
    font-style: italic;
}

#birthdaysContainer {
    overflow: hidden;
}
</style>

<!--- Initialize BirthdayService --->
<cfset birthdayService = createObject("component", "services.BirthdayService")>

<!--- Fetch birthdays for the dashboard --->
<cfset birthdays = birthdayService.getBirthdaysForDashboard(userid)>

<!--- Card for Birthdays --->
<cfoutput>
    <div class="card grid-item loaded" data-id="#dashboards.pnid#">
        <div class="card-header" id="heading_system_#dashboards.currentrow#">
            <h5 class="m-0">
                <a class="text-dark collapsed" data-bs-toggle="collapse" href="##collapse_system_#dashboards.currentrow#">
                    #dashboards.pnTitle#
                </a>
            </h5>
        </div>

        <div class="card-body">
            <!--- Container for birthdays with similar styling to reminders --->
            <div id="birthdaysContainer">
                <!--- Check if there are birthdays to display --->
                <cfif birthdays.recordcount eq 0>
                    <div class="birthdays-empty">
                        <center>No upcoming birthdays</center>
                    </div>
                <cfelse>
                    <!--- Loop through birthdays and display --->
                    <cfloop query="birthdays">
                        <!--- Generate paths and URLs for avatars --->
                        <cfset contactAvatarUrl = session.userContactsUrl & "/" & birthdays.contactid & "/avatar.jpg">
                        <cfset avatarPath = session.userContactsPath & "/" & birthdays.contactid & "/avatar.jpg">
                        <cfset defaultAvatarUrl = application.defaultAvatarUrl>

                        <!--- Check and handle avatar existence --->
                        <cfif NOT fileExists(avatarPath)>
                            <!--- Ensure the directory exists --->
                            <cfif NOT directoryExists(session.userContactsPath & "/" & birthdays.contactid)>
                                <cfdirectory action="create" directory="#session.userContactsPath & "/" & birthdays.contactid#">
                            </cfif>

                            <!--- Copy default avatar to contact directory --->
                            <cftry>
                                <cffile action="copy" source="#defaultAvatarUrl#" destination="#avatarPath#">
                                <cfcatch type="any">
                                    <!--- Log or handle error --->
                                    <cfset application.errorLog = "Failed to copy default avatar for contact ID " & birthdays.contactid & ": " & cfcatch.message>
                                </cfcatch>
                            </cftry>
                        </cfif>

                        <!--- Birthday card row --->
                        <div class="birthday-row d-flex align-items-center" data-contact-id="#birthdays.contactid#">
                            <!--- Avatar on the left --->
                            <div class="birthday-avatar-container">
                                <cfif fileExists(avatarPath)>
                                    <img class="birthday-avatar" 
                                         src="#contactAvatarUrl#?rev=#rand()#" 
                                         alt="#birthdays.col1#" />
                                <cfelse>
                                    <img class="birthday-avatar" 
                                         src="#defaultAvatarUrl#" 
                                         alt="#birthdays.col1#" />
                                </cfif>
                            </div>
                            
                            <!--- Name and date in the middle --->
                            <div class="flex-grow-1 birthday-content">
                                <div class="birthday-name">#birthdays.col1#</div>
                                <div class="birthday-date">#birthdays.col2#</div>
                            </div>
                            
                            <!--- View button on the right --->
                            <div class="birthday-actions">
                                <a href="/app/contact/?contactid=#birthdays.contactid#&t1=1" 
                                   class="btn btn-primary btn-xs" 
                                   title="View #birthdays.col1#'s contact details">
                                    <i class="fas fa-eye"></i>
                                </a>
                            </div>
                        </div>
                    </cfloop>
                </cfif>
            </div>
        </div><!--- card-body end --->
    </div><!--- end card --->

    <!--- Include script name --->
    <cfset script_name_include = "/include/#ListLast(GetCurrentTemplatePath(), ' \')#" />
</cfoutput>
