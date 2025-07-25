<!--- This ColdFusion page displays a dashboard card with team member information and avatars. --->

<style>
/* Team Styles - scoped to team container only */
#teamContainer .team-row {
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

#teamContainer .team-row:hover {
    border-color: #adb5bd;
    box-shadow: 0 2px 4px rgba(0,0,0,0.05);
}

#teamContainer .team-avatar-container {
    display: flex;
    align-items: center;
    margin-right: 12px;
    min-width: 32px;
    height: 32px;
}

#teamContainer .team-avatar {
    max-width: 32px;
    max-height: 32px;
    width: 32px;
    height: 32px;
    border-radius: 50%;
    object-fit: cover;
}

#teamContainer .team-content {
    display: flex;
    flex-direction: column;
    justify-content: center;
    min-height: 32px;
}

#teamContainer .team-name {
    font-weight: 600;
    color: #495057;
    font-size: 14px;
    line-height: 1.3;
}

#teamContainer .team-tag {
    color: #6c757d;
    font-size: 12px;
    margin-top: 2px;
    line-height: 1.3;
}

#teamContainer .team-actions .btn {
    padding: 2px 6px;
    font-size: 11px;
    border-radius: 3px;
    margin-left: 4px;
}

#teamContainer .team-actions .btn i {
    font-size: 10px;
}

#teamContainer .team-empty {
    text-align: center;
    padding: 20px;
    color: #6c757d;
    font-style: italic;
}

#teamContainer {
    overflow: hidden;
}
</style>

<cfinclude template="/include/qry/myteam_499_1.cfm"/>

<cfoutput>

  <div class="card grid-item loaded" data-id="#dashboards.pnid#">

    <div class="card-header" id="heading_system_#dashboards.currentrow#">

      <h5 class="m-0">

        <a class="text-dark collapsed" data-bs-toggle="collapse" href="##collapse_system_#dashboards.currentrow#">

          #dashboards.pnTitle#

        </a>

      </h5>

    </div>

  </cfoutput>

  <div class="card-body">
    <!--- Container for team with similar styling to reminders --->
    <div id="teamContainer">
        <cfinclude template="/include/qry/findtag_97_1.cfm"/>
        
        <!--- Check if there are team members to display --->
        <cfif myteam.recordcount eq 0>
            <div class="team-empty">
                <center>No team members</center>
            </div>
        <cfelse>
            <!--- Loop through team members and display --->
            <cfloop query="myteam">
                <!--- Construct paths and URLs for avatar --->
                <cfset contactAvatarUrl = session.userContactsUrl & "/" & myteam.contactid & "/avatar.jpg">
                <cfset avatarPath = session.userContactsPath & "/" & myteam.contactid & "/avatar.jpg">
                <cfset defaultAvatarUrl = application.defaultAvatarUrl>

                <!--- Ensure avatar file existence and copy default if missing --->
                <cfif NOT fileExists(avatarPath)>
                    <!--- Ensure directory exists --->
                    <cfif NOT directoryExists(session.userContactsPath & "/" & myteam.contactid)>
                        <cfdirectory action="create" directory="#session.userContactsPath & "/" & myteam.contactid#">
                    </cfif>

                    <!--- Copy default avatar to user's contact directory --->
                    <cftry>
                        <cffile action="copy" source="#defaultAvatarUrl#" destination="#avatarPath#">
                        <cfcatch type="any">
                            <!--- Log or handle error --->
                            <cfset application.errorLog = "Failed to copy default avatar for contact ID " & myteam.contactid & ": " & cfcatch.message>
                        </cfcatch>
                    </cftry>
                </cfif>

                <cfoutput>
                    <!--- Team member card row --->
                    <div class="team-row d-flex align-items-center" data-contact-id="#myteam.contactid#">
                        <!--- Avatar on the left --->
                        <div class="team-avatar-container">
                            <cfif fileExists(avatarPath)>
                                <img class="team-avatar" 
                                     src="#contactAvatarUrl#?rev=#rand()#" 
                                     alt="#myteam.contactname#" />
                            <cfelse>
                                <img class="team-avatar" 
                                     src="#defaultAvatarUrl#" 
                                     alt="#myteam.contactname#" />
                            </cfif>
                        </div>
                        
                        <!--- Name and tag in the middle --->
                        <div class="flex-grow-1 team-content">
                            <div class="team-name">#myteam.contactname#</div>
                            <div class="team-tag">#findtag.tag#</div>
                        </div>
                        
                        <!--- View button on the right --->
                        <div class="team-actions">
                            <a href="/app/contact/?contactid=#myteam.contactid#&t1=1" 
                               class="btn btn-primary btn-xs" 
                               title="View #myteam.contactname#'s contact details">
                                <i class="fas fa-eye"></i>
                            </a>
                        </div>
                    </div>
                </cfoutput>
            </cfloop>
        </cfif>
    </div>
  </div><!--- card-body end --->

  <div class="card-footer bg-light d-flex justify-content-left">
    <a href="/app/myaccount/?t2=1" class="btn btn-sm btn-outline-secondary">
        <i class="mdi mdi-square-edit-outline"></i> Edit Team
    </a>
  </div>
</div>

<!--- end card --->
