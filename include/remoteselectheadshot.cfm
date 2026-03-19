<cfset currentURL = cgi.server_name />
<cfset host = ListFirst(currentURL, ".") />
<cfinclude template="/include/qry/headshots_sel_unused.cfm" />
<cfparam name="placeholder" default="" />
<cfinclude template="/include/qry/getAuditionMediaTypes.cfm" />

<div class="row">

    <!--- Loop through the headshots query to display each headshot if it's an image file --->
    <cfloop query="headshots_sel">

        <!--- Check if the media file is an image --->
        <cfif IsImageFile("https://#host#.theactorsoffice.com/#session.userMediaUrl#/#headshots_sel.mediaFileName#")>
            <cfoutput>

                <div class="col-sm-12 text-center mb-3">

                    <a href="/include/remoteselectedheadshot2.cfm?selected_eventid=#selected_eventid#&mediaid=#headshots_sel.mediaid#&eventid=#eventid#&audprojectid=#audprojectid#">
                        <img src="https://#host#.theactorsoffice.com/#session.userMediaUrl#/#headshots_sel.mediaFileName#?v=#rand()#"
                             class="me-2 rounded img-thumbnail img-fluid"
                             title="#headshots_sel.mediaFileName#"
                             alt="#headshots_sel.mediaFileName#">
                    </a>

                    <div class="mt-2">
                        <a href="/include/remoteselectedheadshot2.cfm?eventid=#selected_eventid#&mediaid=#headshots_sel.mediaid#&audprojectid=#audprojectid#"
                           title="Select"
                           class="btn btn-xs btn-primary waves-effect waves-light">Select</a>
                    </div>

                </div>

            </cfoutput>
        </cfif>
    </cfloop>

</div>
