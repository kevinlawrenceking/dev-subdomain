<!--- This ColdFusion page displays a dashboard card with team member information and avatars. --->

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

    <div class="row">   <cfinclude template="/include/qry/findtag_97_1.cfm"/>
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

    <!--- Render avatar and contact details --->
    <div class="col-md-2 col-lg-2" style="margin-top:7px;margin-left:7px;">
        <cfoutput>
            <a href="/app/contact/?contactid=#myteam.contactid#&t1=1" class="" title="#myteam.contactname#">
                <!--- Display avatar or fallback to default --->
                <cfif fileExists(avatarPath)>
                    <img src="#contactAvatarUrl#?rev=#rand()#" style="width:30px;" alt="#myteam.contactname#"/>
                <cfelse>
                    <img src="#defaultAvatarUrl#" style="width:30px;" alt="#myteam.contactname#"/>
                </cfif>
            </a>
        </cfoutput>
    </div>

    <div class="col-md-9 col-lg-9">
        <cfoutput>
            <a href="/app/contact/?contactid=#myteam.contactid#&t1=1" class="" title="#myteam.contactname#">
                #myteam.contactname#
            </a>
            <br>
            <small>
                #findtag.tag#
            </small>
        </cfoutput>
    </div>

    <!--- Add spacing between entries --->
    <div class="col-md-12 col-lg-12">
        &nbsp;
    </div>
</cfloop>


      </div>

      <div class="col-md-12 col-lg-12">
        <p style="text-align:center;">
          <a href="/app/myaccount/?t2=1">
            <i class="mdi mdi-square-edit-outline"></i>
          </a>
        </p>
      </div>

    </div>
    <!--end card --->
  </div>
