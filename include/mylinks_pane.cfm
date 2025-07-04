<!--- This ColdFusion page handles the display of site types and their associated links, including modals for adding and updating links and panels. --->



<cfinclude template="/include/qry/sitetypes_535_1.cfm" />
<cfinclude template="/include/qry/mylinks_159_1.cfm" />

<cfoutput>
    <script>
        $(document).ready(function() {
            $("##paneladd").on("show.bs.modal", function(event) {
                <!--- Load the HTML for adding a new panel into the modal body --->
                $(this).find(".modal-body").load("/include/remotePanelAdd.cfm?userid=#userid#&pgrtn=P");
            });
        });
    </script>
</cfoutput>

<cfloop query="sitetypes">
    <cfoutput>
        <script>
            $(document).ready(function() {
                $("##addlink_#sitetypes.sitetypeid#").on("show.bs.modal", function(event) {
                    <!--- Load the HTML for adding a new link into the modal body --->
                    $(this).find(".modal-body").load("/include/remotelinkAdd.cfm?new_sitetypeid=#sitetypes.sitetypeid#&userid=#userid#");
                });
            });
        </script>

        <cfset modalid="addlink_#sitetypes.sitetypeid#" />
        <cfset modaltitle="Add Custom #sitetypes.sitetypename# Link" />
        <cfinclude template="/include/modal.cfm" />

        <script>
            $(document).ready(function() {
                $("##updateheading#sitetypes.sitetypeid#").on("show.bs.modal", function(event) {
                    <!--- Load the HTML for updating the panel title into the modal body --->
                    $(this).find(".modal-body").load("/include/remoteheadingupdate.cfm?new_sitetypeid=#sitetypes.sitetypeid#&userid=#userid#");
                });
            });
        </script>

        <cfset modalid="updateheading#sitetypes.sitetypeid#" />
        <cfset modaltitle="Update Panel Title" />
        <cfinclude template="/include/modal.cfm" />
    </cfoutput>
</cfloop>

<cfloop query="mylinks">
    <cfoutput>
        <script>
            $(document).ready(function() {
                $("##updatelink_#mylinks.id#").on("show.bs.modal", function(event) {
                    <!--- Load the HTML for updating a link into the modal body --->
                    $(this).find(".modal-body").load("/include/remotelinkUpdate.cfm?new_id=#mylinks.id#");
                });
            });
        </script>
    </cfoutput>

    <cfoutput>
        <cfset modalid="updatelink_#mylinks.id#" />
        <cfset modaltitle="#mylinks.sitetypename# Link Update" />
        <cfinclude template="/include/modal.cfm" />
    </cfoutput>
</cfloop>

<cfset modalid="paneladd" />
<cfset modaltitle="Custom Panel Add" />
<cfinclude template="/include/modal.cfm" />

<div class="row">
    <div class="col-xl-12">
        <button type="button" class="btn btn-xs btn-primary waves-effect mb-2 waves-light" href="addlink.cfm" data-bs-remote="true" data-bs-toggle="modal" data-bs-target="#paneladd" title="Add Custom Panel">Add Panel</button>                  
        
        <span class="float-end">
            <a title="Edit" href="dashboardupdate.cfm" data-bs-remote="true" data-bs-toggle="modal" data-bs-target="#dashboardupdate">Dashboard preferences <i class="mdi mdi-square-edit-outline"></i></a>
        </span>

        <div id="accordion" class="mb-1">
            <cfset z=0 />

            <cfloop query="sitetypes">
                <cfset current_sitetypeid=sitetypes.sitetypeid />
                <cfset current_sitetypename=sitetypes.sitetypename />

                <cfoutput>
                    <cfset z=#z# + 1 />
                </cfoutput>

                <cfif #z# is "1">
                    <cfoutput>
                        <cfparam name="target_id" default="#sitetypes.sitetypeid#" />
                    </cfoutput>
                </cfif>

                <cfinclude template="/include/qry/mylinks_user_164_2.cfm" />
                <cfinclude template="/include/qry/mylinks_user_del_164_3.cfm" />
                <cfinclude template="/include/qry/master_164_4.cfm" />

                <cfif #master.recordcount# is "0">
                    <cfset deletable="Y" />
                </cfif>

                <cfif #master.recordcount# is not "0">
                    <cfset deletable="N" />
                </cfif>

                <cfif #sitetypes.sitetypeid# is "#target_id#">
                <Cfoutput>
                    <div class="card mb-1">
                        <div class="card-header" id="heading#sitetypes.sitetypeid#">
                            <h5 class="m-0">
                                <a class="text-dark" data-bs-toggle="collapse" href="##collapse#sitetypes.sitetypeid#" aria-expanded="true">
                                 #sitetypes.sitetypename#
                                </a>
                                <a title="Edit Title" href="" data-bs-remote="true" data-bs-toggle="modal" data-bs-target="##updateheading#sitetypes.sitetypeid#"><i class="mdi mdi-square-edit-outline"></i></a> 

                                <cfif #mylinks_user.recordcount# is "0" and #deletable# is "y">
                                    <a title="Remove #current_sitetypename#" class="pl-1" style="color:red;" href="/include/excludesitetype.cfm?current_sitetypeid=#current_sitetypeid#&target_id=#current_sitetypeid#">
                                        <i class="mdi mdi-trash-can-outline"></i>
                                    </a>
                                </cfif>
                                <a class="text-dark" data-bs-toggle="collapse" href="##collapse#sitetypes.sitetypeid#" aria-expanded="true">
                                    <span class="badge badge-blue badge-pill float-end">#numberformat(mylinks_user.recordcount)#</span>
                                </a>
                            </h5>
                        </div>
                        <!--- end card-header --->
</cfoutput>
                        <div id="collapse<cfoutput>#sitetypes.sitetypeid#</cfoutput>" class="collapse show" aria-labelledby="<cfoutput>heading#sitetypes.sitetypeid#</cfoutput>" data-bs-parent="#accordion" style="">
                </cfif>

                <cfif #sitetypes.sitetypeid# is not "#target_id#">
                    <div class="card mb-1">
                        <div class="card-header" id="<cfoutput>heading#sitetypes.sitetypeid#</cfoutput>">
                            <h5 class="m-0">
                                <cfoutput>
                                    <a class="text-dark collapsed" data-bs-toggle="collapse" href="##collapse<cfoutput>#sitetypes.sitetypeid#</cfoutput>" aria-expanded="false">
                                        #sitetypes.sitetypename#
                                    </a>
                                    <a title="Edit Title" href="" data-bs-remote="true" data-bs-toggle="modal" data-bs-target="##updateheading#sitetypes.sitetypeid#"><i class="mdi mdi-square-edit-outline"></i></a> 

                                    <cfif #mylinks_user.recordcount# is "0" and #deletable# is "y">
                                        <a title="Remove #current_sitetypename#" class="pl-1" style="color:red;" href="/include/excludesitetype.cfm?current_sitetypeid=#current_sitetypeid#&target_id=#current_sitetypeid#"><i class="mdi mdi-trash-can-outline"></i></a>
                                    </cfif>
                                    <a class="text-dark collapsed" data-bs-toggle="collapse" href="##collapse#sitetypes.sitetypeid#" aria-expanded="false">
                                        <span class="badge badge-blue badge-pill float-end">#numberformat(mylinks_user.recordcount)#</span>
                                    </a>
                                </cfoutput>
                            </h5>
                        </div>

                        <div id="collapse<cfoutput>#sitetypes.sitetypeid#</cfoutput>" class="collapse" aria-labelledby="<cfoutput>heading#sitetypes.sitetypeid#</cfoutput>" data-bs-parent="#accordion" style="">
                </cfif>

                <div class="card-body">
                    <cfoutput>
                        <button type="button" class="btn btn-xs btn-primary waves-effect mb-2 waves-light" style="background-color: ##406e8e; border: ##406e8e" href="addlink.cfm" data-bs-remote="true" data-bs-toggle="modal" data-bs-target="##addlink_#sitetypes.sitetypeid#">Add Custom
                        </button>
                    </cfoutput>

                    <div class="row">
                        <cfloop query="mylinks_user">
                            <div class="col-md-6 col-lg-4">
                                <cfoutput>
                                    <h5 id="item#mylinks_user.id#">
                                        <a title="Edit" href="updateuserlink.cfm" data-bs-remote="true" data-bs-toggle="modal" data-bs-target="##updatelink_#mylinks_user.id#">
                                            <img src="#application.retinaIcons14Url#/#mylinks_user.siteicon#" width="14px" /> 
                                            #mylinks_user.sitename# <cfif #mylinks_user.ver# is not ""> (#ver#)</cfif>
                                            <i class="mdi mdi-square-edit-outline"></i>
                                        </a>
                                        <a title="Remove #mylinks_user.sitename#" class="pl-1" style="color:red;" href="/include/excludelink.cfm?new_id=#mylinks_user.id#&target_id=#sitetypes.sitetypeid#"><i class="mdi mdi-trash-can-outline"></i></a>
                                    </h5>
                                </cfoutput>
                            </div><!--- end col-md-6 col-lg-4 --->
                        </cfloop>
                    </div><!--- end row --->

                    <cfif #mylinks_user_del.recordcount# is not "0">
                        <form action="/include/linkinclude.cfm">
                            <cfoutput><input type="hidden" name="target_id" value="#target_id#" /></cfoutput>
                            <h5>Restore:
                                <select name="new_id" id="<cfoutput>new_id_#sitetypes.sitetypeid#</cfoutput>" required="" onchange='this.form.submit()'>
                                    <option value=""></option>
                                    <cfoutput query="mylinks_user_del">
                                        <option value="#mylinks_user_del.id#">#mylinks_user_del.sitename#</option>
                                    </cfoutput>
                                </select>
                            </h5>
                        </form>
                    </cfif>
                </div><!--- end card-body --->
            </div>
            <cfif #sitetypes.sitetypeid# is "#target_id#">
        </div>
        </cfif>
    </div>
</cfloop>
</div>
</div>

