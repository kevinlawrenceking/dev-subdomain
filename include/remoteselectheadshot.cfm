<cfset currentURL = cgi.server_name />
<cfset host = ListFirst(currentURL, ".") />
<cfinclude template="/include/qry/headshots_sel_unused.cfm" />
<cfparam name="placeholder" default="" />
<cfinclude template="/include/qry/types_45_1.cfm" />
<CfaborT>
<div class="row" />

    <!--- Loop through the headshots query to display each headshot if it's an image file --->
    <cfloop query="headshots_sel">
        
        <!--- Check if the media file is an image --->
        <cfif IsImageFile("https://#host#.theactorsoffice.com/#session.userMediaUrl#/#headshots_sel.mediaFileName#")> 
            <Cfoutput>
                
                <div class="col-sm-12">
                    
                    <center>
                        <a href="/include/remoteselectedheadshot2.cfm?selected_eventid=#selected_eventid#&mediaid=#headshots_sel.mediaid#&eventid=#eventid#&audprojectid=#audprojectid#"> 
                            <img src="https://#host#.theactorsoffice.com/#session.userMediaUrl#/#headshots_sel.mediaFileName#?ver=#rand()#" 
                                 class="mr-2 rounded-square gambar img-thumbnail img-fluid p-0 m-0" 
                                 title="User ID: 30" 
                                 alt="profile-image" 
                                 id="item-img-output">
                        </a>
                    </center>
                    
                    <p class="p-0" style="padding:10px;">
                        <center>
                            <a href="/include/remoteselectedheadshot2.cfm?eventid=#selected_eventid#&mediaid=#headshots_sel.mediaid#&audprojectid=#audprojectid#" 
                               title="Select" 
                               data-bs-original-title="Add media" 
                               class="btn btn-xs btn-primary waves-effect waves-light">Select</a>
                        </center>
                        <br/>
                    </p>

                    <span class="p-3">&nbsp;</span> 
                    <span class="p-3">&nbsp;</span>
                </div>

            </Cfoutput>
        </cfif>
    </cfloop>
    
</div>

