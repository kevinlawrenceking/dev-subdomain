<!--- This ColdFusion page handles the display and management of media materials for auditions, including modals for selecting and adding materials. --->

<cfinclude template="/include/qry/audmedia_materials.cfm" />
<cfinclude template="/include/qry/audmedia_picklist.cfm" />
<cfinclude template="/include/qry/types_45_1.cfm" />
<cfinclude template="/include/qry/audlinks_44_2.cfm" />
<cfset modalid="remoteselectheadshot" />
<cfset modaltitle="Select a Headshot" />
<cfinclude template="/include/modal.cfm" />

<cfset modalid="remoteselectmaterial" />
<cfset modaltitle="Select Material" />
<cfinclude template="/include/modal.cfm" />

<div id="linkmediahelp" class="modal fade" tabindex="-1" aria-labelledby="standard-modalLabel" >

    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header" >
                <h4 class="modal-title" id="standard-modalLabel">Link Media</h4>
                <button type="button" class="close" data-bs-dismiss="modal" >

                    <i class="mdi mdi-close-thick"></i>
                </button>
            </div>
            <div class="modal-body">
                <p>There are times when you submit your own monologues, songs, or sides as your audition.</p>
                <p>To add materials in your repertoire to TAO, go to My Account and then Materials.</p>
                <p>Once added, they will appear in this list so you can easily add them to any of your auditions.</p>
            </div>
        </div>
    </div>
</div>

<cfoutput>

    <script>
        $(document).ready(function() {
            $("##remoteselectmaterial").on("show.bs.modal", function(event) {
                
                $(this).find(".modal-body").load("/include/remoteselectmaterial.cfm?selected_eventid=#eventid#&eventid=#eventid#&audprojectid=#audprojectid#&secid=177");
            });
        });
    </script>

    <script>
        $(document).ready(function() {
            $("##remoteadd").on("show.bs.modal", function(event) {
                
                $(this).find(".modal-body").load("/include/remotaudmatadd.cfm?eventid=#eventid#&audprojectid=#audprojectid#&secid=177&new_isshare=0");
            });
        });
    </script>

    <div id="remoteadd" class="modal fade" tabindex="-1" aria-labelledby="standard-modalLabel" >

        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header" >
                    <h4 class="modal-title" id="standard-modalLabel">Add Media</h4>
                    <button type="button" class="close" data-bs-dismiss="modal" >

                        <i class="mdi mdi-close-thick"></i>
                    </button>
                </div>
                <div class="modal-body">
                </div>
            </div>
        </div>
    </div>
</cfoutput>


<cfoutput>
    <h4 class="p-1 d-flex">Materials Submitted
        <span class="ms-auto text-muted">
            <a href="javascript:;" data-bs-remote="true" data-bs-toggle="modal" data-bs-target="##matupdate" data-bs-placement="top" title="Update Materials" data-bs-original-title="Update Materials"> 
            </a>
        </span>
    </h4>
</cfoutput>

<cfset i=0 />

<cfoutput>
    <script>
        $(document).ready(function() {
            $("##remoteaddMaterial").on("show.bs.modal", function(event) {
                
                $(this).find(".modal-body").load("/include/remoteaddMaterial.cfm?userid=#userid#&src=aud&audprojectid=#audprojectid#&new_isshare=0");
            });
        });
    </script>
</cfoutput>

<cfset modalid = "remoteaddMaterial"/>
<cfset modaltitle = "Add Material"/>
<cfinclude template="/include/modal.cfm"/>

<form action="/include/linkmedia.cfm">
    <cfoutput>
        <input type="hidden" name="audprojectid" value="#audprojectid#" />
    </cfoutput>
    <select id="new_mediaid" class="form-control-short" name="new_mediaid" onchange="this.form.submit()">
        <option value="">Link Material</option>
        <cfoutput query="audmedia_picklist">
            <option value="#audmedia_picklist.mediaid#">#audmedia_picklist.mediatype#: #audmedia_picklist.medianame#</option>
        </cfoutput>
    </select>
    <a href="" title="click for details" data-bs-toggle="modal" data-bs-target="#linkmediahelp">
        <i class="fe-info font-14 mr-1"></i>
    </a>
</form>

<cfoutput>
    <div style="padding:10px;">
        <a data-bs-remote="true" data-bs-toggle="modal" data-bs-target="##remoteaddMaterial" 
           data-bs-placement="top" title="Add media" data-bs-original-title="Add material" 
           class="btn btn-xs btn-primary waves-effect waves-light">
            Add Material
        </a>
    </div>
</cfoutput>

<div class="row pt-3 pb-3">
    <table id="materials_tbl" class="table dt-responsive nowrap w-100 table-striped" role="grid">
  
        <thead>
            <tr class="#rowtype#">
                <th width="50">Action</th>
                <th>Type</th>
                <th>Name</th>
                <th>Filename</th>
                <th>URL</th>
                <th>Created</th>
            </tr>
        </thead>
        <tbody>
            <cfloop query="audmedia">
                <cfoutput>
                    <script>
                        $(document).ready(function() {
                            $("##remoteDeleteaudmedia#audmedia.mediaid#").on("show.bs.modal", function(event) {
                                
                                $(this).find(".modal-body").load("/include/remoteDeleteaudmedia.cfm?mediaid=#audmedia.mediaid#&secid=177");
                            });
                        });
                    </script>

                    <div id="remoteDeleteaudmedia#audmedia.mediaid#" class="modal fade" tabindex="-1" role="dialog" >

                        <div class="modal-dialog">
                            <div class="modal-content">
                                <div class="modal-header" style="background-color: red;">
                                    <h4 class="modal-title">Delete Material</h4>
                                    <button type="button" class="close" data-bs-dismiss="modal" >

                                        <i class="mdi mdi-close-thick"></i>
                                    </button>
                                </div>
                                <div class="modal-body"></div>
                            </div>
                        </div>
                    </div>

                    <script>
                        $(document).ready(function() {
                            $("##remoteRemoveaudmedia#audmedia.mediaid#").on("show.bs.modal", function(event) {
                                
                                $(this).find(".modal-body").load("/include/remoteRemoveaudmedia.cfm?mediaid=#audmedia.mediaid#&audprojectid=#audprojectid#&secid=196");
                            });
                        });
                    </script>

                    <div id="remoteRemoveaudmedia#audmedia.mediaid#" class="modal fade" tabindex="-1" role="dialog" >

                        <div class="modal-dialog">
                            <div class="modal-content">
                                <div class="modal-header" style="background-color: red;">
                                    <h4 class="modal-title">Remove Material</h4>
                                    <button type="button" class="close" data-bs-dismiss="modal" >

                                        <i class="mdi mdi-close-thick"></i>
                                    </button>
                                </div>
                                <div class="modal-body"></div>
                            </div>
                        </div>
                    </div>

                    <script>
                        $(document).ready(function() {
                            $("##remoteupdatematerial#audmedia.mediaid#").on("show.bs.modal", function(event) {
                                
                                $(this).find(".modal-body").load("/include/remoteupdatematerial.cfm?mediaid=#audmedia.mediaid#&src=aud&dir=aud&audprojectid=#audprojectid#");
                            });
                        });
                    </script>

                    <div id="remoteupdatematerial#audmedia.mediaid#" class="modal fade" tabindex="-1" role="dialog" >

                        <div class="modal-dialog">
                            <div class="modal-content">
                                <div class="modal-header">
                                    <h4 class="modal-title">Update Material</h4>
                                    <button type="button" class="close" data-bs-dismiss="modal" >

                                        <i class="mdi mdi-close-thick"></i>
                                    </button>
                                </div>
                                <div class="modal-body"></div>
                            </div>
                        </div>
                    </div>

                    <tr role="row">
                        <td>
                            <a title="Edit" data-bs-toggle="modal" data-bs-target="##remoteupdatematerial#audmedia.mediaid#">
                                <i class="mdi mdi-square-edit-outline"></i>
                            </a>
                            <a class="pt-0" data-bs-remote="true" data-bs-toggle="modal" data-bs-target="##remoteRemoveaudmedia#audmedia.mediaid#" data-bs-placement="top" title="Remove media" data-bs-original-title="Remove media">
                                <i class="mdi mdi-trash-can-outline"></i>
                            </a>
                        </td>
                        <td class="text-nowrap">#audmedia.mediaType#</td>
                        <td class="text-nowrap">#audmedia.mediaName#</td>
                        <td class="text-nowrap">
                            <a href="##" style="text-decoration: underline; color: blue;" id="downloadLink_#audmedia.mediaid#">#audmedia.mediaFilename#</a>
                        </td>
                        <td class="text-nowrap">
                            <cfif #audmedia.mediaurl# is not "" and #audmedia.mediaurl# is not "https://">
                                <a href="#audmedia.mediaurl#" target="new" style="text-decoration: underline; color: blue;">#audmedia.mediaurl#</a>
                            </cfif>
                        </td>
                        <td class="text-nowrap">#this.formatDate('#audmedia.mediacreated#')#<br />#timeformat('#audmedia.mediacreated#','medium')#</td>
                    </tr>

                    <script type="text/javascript">
                        document.getElementById('downloadLink_#audmedia.mediaid#').addEventListener('click', function(e) {
                            e.preventDefault();
                            
                            const host = '#host#';
                            const userid = '#userid#';
                            const mediafilename = '#audmedia.mediafilename#';
                            window.location.href = '/include/mediadownload.cfm?host=' + host + '&userid=' + userid + '&mediafilename=' + mediafilename;
                        });
                    </script>
                </cfoutput>
            </cfloop>
        </tbody>
    </table>
</div>

<script>
$(document).ready(function(){
    var table = $('#materials_tbl').DataTable({
         responsive: true,
         ordering: true,
         searching: true
    });
    
    // If the table is in a Bootstrap tab, adjust columns when the tab is shown
    $('a[data-bs-toggle="tab"]').on('shown.bs.tab', function(e) {
        table.columns.adjust();
    });
});
</script>
