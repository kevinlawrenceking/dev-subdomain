<!--- This ColdFusion page displays a dashboard card for upcoming birthdays, fetching data from the BirthdayService and rendering it in a structured format. --->
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
            <div class="row">
                <!--- Check if there are birthdays to display --->
                <cfif birthdays.recordcount eq 0>
                    <div class="col-12">
                        <p class="text-center">No birthdays to show.</p>
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

    <!--- Display contact information --->
    <div class="col-md-2 col-lg-2" style="margin-top:7px;margin-left:7px;">
        <a href="/app/contact/?contactid=#birthdays.contactid#&t1=1" title="#birthdays.col1#">
            <!--- Display avatar or fallback to default --->
            <cfif fileExists(avatarPath)>
                <img src="#contactAvatarUrl#?rev=#rand()#" class="img-fluid" alt="#birthdays.col1#" style="width: 30px;" />
            <cfelse>
                <img src="#defaultAvatarUrl#" class="img-fluid" alt="#birthdays.col1#" style="width: 30px;" />
            </cfif>
        </a>
    </div>

    <!--- Birthday Information --->
    <div class="col-md-9 col-lg-9">
        <a href="/app/contact/?contactid=#birthdays.contactid#&t1=1" title="#birthdays.col1#">
            #birthdays.col1#
        </a>
        <br>
        <small>#birthdays.col2#</small>
    </div>

    <!--- Spacing between entries --->
    <div class="col-12 mb-2"></div>
</cfloop>

                </cfif>
            </div>
        </div>
    </div>

    <!--- Include script name --->
    <cfset script_name_include = "/include/#ListLast(GetCurrentTemplatePath(), ' \')#" />
</cfoutput>
