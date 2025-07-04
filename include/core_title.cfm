<!--- This ColdFusion page handles the display of page titles and actions based on the page ID (pgid) --->
<cfparam name="ctaction" default="view">

<div class="col-12">
    <div class="page-title-box">
        <div class="page-title-right">
            <ol class="breadcrumb m-0">
                <li class="breadcrumb-item">
                    <a href="<cfoutput>#home#</cfoutput>">
                        <cfoutput>#appName#</cfoutput>
                    </a>
                </li>
                <li class="breadcrumb-item">
                    <a href="javascript:void(0);" onclick="history.back();">
                        <cfoutput>#compName#</cfoutput>
                    </a>
                </li>
                <li class="breadcrumb-item active">
                    <cfoutput>#pgName#</cfoutput>
                </li>
            </ol>
        </div>

        <h4 class="page-title">
            <cfoutput>
                #pgHeading#

                <!--- Show range display if pgid is 189 --->
                <cfif pgid EQ "189">(#rangeDisplay#)</cfif>

                <!--- For Project Details (pgid 175) --->
                <cfif pgid EQ "175">: #projectDetails.projName# 
                    <a href="javascript:;" data-bs-remote="true" data-bs-toggle="modal" 
                       data-bs-target="##remoteDeleteFormAudproject#projectDetails.audProjectId#" 
                       title="Delete Project">
                        <i class="fe-trash-2"></i>
                    </a>
                </cfif>

                <!--- For Contact Deletion (pgid 117) --->
                <cfif pgid EQ "117">
                    <a href="javascript:;" data-bs-remote="true" data-bs-toggle="modal" 
                       data-bs-target="##remoteDeleteForm#contactid#" 
                       title="Delete Contact">
                        <i class="fe-trash-2"></i>
                    </a>
                </cfif>

                <!--- Custom Panel for Dashboard (pgid 89) --->
                <cfif pgid EQ "89">
                    <cfset session.pgrtn = "D" />
                    <a href="javascript:;" data-bs-remote="true" data-bs-toggle="modal" 
                       data-bs-target="##panelAdd" 
                       title="Add Custom Panel">
                        <i class="fe-plus-circle"></i>
                    </a>

                    <!--- Edit Configuration Link --->
                    <cfif ctaction NEQ "view">
                        <a href="/app/dashboard_new/?ctaction=view" title="View Configuration">
                            <i class="mdi mdi-cog-outline"></i>
                        </a>
                        <span style="color:green; margin-left: 20px;">
                            Drag your panels to reorder and press the button.
                        </span>
                    </cfif>
                </cfif>

                <!--- Add Appointment (pgid 5) --->
                <cfif pgid EQ "5">
                    <cfparam name="rcontactid" default="0" />
                    <cfset session.pgrtn = "D" />
                    <a href="/app/appoint-add/?returnurl=calendar-appoint&amp;rcontactid=#rcontactid#&pgrtn=D" 
                       title="Add Appointment">
                        <i class="fe-plus-circle"></i>
                    </a>
                </cfif>
            </cfoutput>
        </h4>
    </div>
</div>
