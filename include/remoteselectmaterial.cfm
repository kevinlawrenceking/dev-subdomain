<!--- This ColdFusion page displays headshots and allows selection of media items for a specific event. --->
<cfinclude template="/include/qry/materials_sel_unused.cfm" />
<cfparam name="placeholder" default="" />
<cfinclude template="/include/qry/types_45_1.cfm" /> 

<div class="row">
    <!--- Loop through the headshots query to display each headshot item --->
    <cfloop query="headshots_sel">
        <cfoutput>
            <div class="col-sm-12">
                <center>
                    <a href="/include/remoteselectedmaterial2.cfm?selected_eventid=#selected_eventid#&mediaid=#headshots_sel.mediaid#&eventid=#eventid#&audprojectid=#audprojectid#"> 
                        <img src="#application.application.application.filetypesUrl#/#headshots_sel.mediaext#.png?ver=#rand()#" 
                             class="mr-2 rounded-square gambar img-thumbnail img-fluid p-0 m-0" 
                             style="width:120px;" 
                             title="User ID: 30" 
                             alt="profile-image" 
                             id="item-img-output">
                    </a>
                </center>
                <center>
                    #headshots_sel.mediatype#<br/>
                    #headshots_sel.medianame#
                </center>
                <p class="p-0" style="padding:10px;">
                    <center>
                        <a href="/include/remoteselectedmaterial2.cfm?eventid=#selected_eventid#&mediaid=#headshots_sel.mediaid#&audprojectid=#audprojectid#" 
                           title="Select" 
                           data-bs-original-title="Add media" 
                           class="btn btn-xs btn-primary waves-effect waves-light">Select</a>
                    </center>
                    <br/>
                </p>
                <span class="p-3">&nbsp;</span> 
                <span class="p-3">&nbsp;</span>
            </div>
        </cfoutput>
    </cfloop>
</div>

