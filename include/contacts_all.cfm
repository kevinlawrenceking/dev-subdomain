<!--- This ColdFusion page handles the display and management of contact relationships, including modals for adding relationships and updating tags. --->

<cfparam name="test" default="yes" />
<cfparam name="contact_expand" default="true" />
<cfparam name="a" default="0" />
<cfparam name="d" default="0" />
<cfparam name="s" default="0" />
<cfparam name="contactcheckvisible" default="false" />
<cfparam name="maintenance_expand" default="false" />
<cfparam name="bytag" default="" />
<cfparam name="target_expand" default="false" />
<cfparam name="followup_expand" default="false" />
<cfparam name="all_expand" default="false" />
<cfparam name="pgaction" default="view" />

<!--- Set default page action in session if not defined --->
<cfif NOT #isdefined('session.pgaction')#>
    <cfset session.pgaction="view">
</cfif>

<cfinclude template="/include/qry/lastupdates.cfm" />

<script>
    $(document).ready(function() {
        $("#remoteAddName").on("show.bs.modal", function(event) {
            
            $(this).find(".modal-body").load("/include/remoteAddName.cfm");
        });
    });
</script>

<div id="remoteAddName" class="modal fade" tabindex="-1" role="dialog" >

    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <h4 class="modal-title">Add A Relationship</h4>
                <button type="button" class="close" data-bs-dismiss="modal" >
<i class="mdi mdi-close-thick"></i></button>
            </div>
            <div class="modal-body">
            </div>
        </div>
    </div>
</div>

<!--- Check if the page action is "bulk" and handle bulk actions accordingly --->
<cfif #session.pgaction# is "bulk">
    <cfset session.pgaction="view" />
    <script>
        $(document).ready(function() {
            $("#bulkModal").modal('show');
        });
    </script>

    <script>
        var table = $("#contacts_ss");
        var btn = $('#btnSelectedRows');

        function enableBtn() {
            btn.prop("disabled", table.find("input:checked").length === 0)
        }

        table.on("change", "input", enableBtn);
        enableBtn();
    </script>

    <div id="bulkModal" class="modal fade">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title">Selected Updated Summary</h5>
                    <button type="button" class="close" data-bs-dismiss="modal" >
<i class="mdi mdi-close-thick"></i></button>
                </div>
                <div class="modal-body">
                    <cfif #a# is not "0">
                        <p>
                            <cfoutput>#a# #bt#<cfif #a# is not "1">s</cfif> added.</cfoutput>
                        </p>
                    </cfif>
                    <cfif #d# is not "0">
                        <p>
                            <cfoutput>#d# #bt#<cfif #d# is not "1">s</cfif> removed.</cfoutput>
                        </p>
                    </cfif>
                    <cfif #s# is not "0">
                        <p>
                            <cfoutput>#s# relationship<cfif #s# is not "1">s</cfif> skipped.</cfoutput>
                        </p>
                    </cfif>

                    <div class="form-group text-center col-md-12">
                        <A href="/app/contacts/">
                            <button class="btn btn-primary waves-effect waves-light" type="button" style="background-color: #406e8e; border: #406e8e;">Continue</button>
                        </A>
                    </div>
                </div>
            </div>
        </div>
    </div>
</cfif>

<!--- If the page action is not "bulk", hide the bulk modal --->
<cfif #session.pgaction# is not "bulk">
    <script>
        $(document).ready(function() {
            $("#bulkModal").modal('hide');
        });
    </script>
</cfif>

<div class="row">
    <div class="col-lg-12">
        <div class="card mb-3">
            <div class="card-body">
                <div class="row">
                    <div class="btn-group mb-2 col-xs-12">
                        <button type="button" class="btn btn-primary btn-lg dropdown-toggle" data-bs-toggle="dropdown" aria-haspopup="true" aria-expanded="false" title="Click to change view">                                                    
                            <Cfoutput>#pgname# </Cfoutput><i class="fe-menu"></i>
                        </button>

                        <div class="dropdown-menu">
                            <cfloop query="FindOptions">
                                <cfoutput>
                                    <a class="dropdown-item" href="/app/#pgDir#/?new_pgid=#FindOptions.pgid#">#FindOptions.pgname#</a> 
                                </cfoutput>
                            </cfloop>
                        </div>
                    </div>
                </div>

                <!--- Display tag information if bytag is set --->
                <cfif #bytag# is not "">
                    <cfoutput>
                        <div style="padding-top:10px;padding-bottom:10px">
                            <cfset bytag="#bytag#">
                            <A HREF="/app/contacts/">
                                <span class="badge badge-blue">#bytag# X</span>
                            </A>
                        </div>
                    </cfoutput>
                <cfelse>
                    <div style="padding-top:10px;padding-bottom:10px">&nbsp;</div>    
                </cfif>

                <!--- Set contacts table based on pgid --->
                <cfif #pgid# is "113">
                    <cfset contacts_table="contacts_ss" />
                </cfif>
                <cfif #pgid# is "114">
                    <cfset contacts_table="contacts_ss_target" />
                </cfif>
                <cfif #pgid# is "115">
                    <cfset contacts_table="contacts_ss_followup" />
                </cfif>
                <cfif #pgid# is "116">
                    <cfset contacts_table="contacts_ss_maint" />
                </cfif>

                <cfinclude template="/include/contacts_table.cfm" />
            </div>
        </div>
    </div>
</div>

<cfinclude template="/include/qry/tags_76_1.cfm" />

<div class="modal fade" id="exampleModal2" tabindex="-1" role="dialog" aria-labelledby="exampleModalLabel2" >

    <div class="modal-dialog modal-dialog-slideout modal-sm" role="document">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title" id="exampleModalLabel">Tag Selector</h5>
                <button type="button" class="close" data-bs-dismiss="modal" aria-label="Close">
                    <span >
X</span>
                </button>
            </div>
            <div class="modal-body">
                <div class="row">
                    <Cfoutput query="tags">
                        <div class="col-md-6">
                            <A HREF="/app/contacts?bytag=#tagname#">
                                <span class="badge badge-blue">#tagname#</span>
                            </A>
                        </div>
                    </Cfoutput>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button>
            </div>
        </div>
    </div>
</div>

<div id="exampleModal3" class="modal fade" tabindex="-1" role="dialog" aria-labelledby="standard-modalLabel" >

    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <h4 class="modal-title" id="standard-modalLabel">System Selected Update</h4>
                <button type="button" class="close" data-bs-dismiss="modal" >
<i class="mdi mdi-close-thick"></i></button>
            </div>
            <div class="modal-body">
                <form method="post" class="parsley-examples demo-default selectize-close-btn" data-parsley-excluded="input[type=button], input[type=submit], input[type=reset], input[type=hidden], [disabled], :hidden" data-parsley-trigger="keyup" data-parsley-validate="" novalidate="" id="myform" name="myform" action="/include/tmpcontactgroups.cfm" method="POST">
                    <div class="form-group col-md-12">
                        <label for="valuetext">Addz System to all selected relationships</label>
                    </div>
                    <div class="form-group col-md-6">
                        <select id="select-system" name="new_systemtype" class="form-control" data-parsley-required="" data-parsley-error-message="System is required" onchange="showDiv('hidden_div', this)">
                            <option value="">Select a System...</option>
                            <cfloop query="systems">
                                <cfset new_systemname=systems.systemname />
                                <cfset new_select="" />
                                <cfoutput>
                                    <option value="#new_systemname#" #new_select#>#new_systemname#</option>
                                </cfoutput>
                            </cfloop>
                        </select>
                    </div>
                    <div class="form-group col-md-12">
                        <label for="valuetext">If a relationship already has an active system:</label>
                    </div>
                    <div class="form-group col-md-12">
                        <div class="form-group col-md-5">
                            <div class="form-check mb-2 form-check-success">
                                <input class="form-check-input" type="radio" name="keeplist" value="skip" id="customradio2" checked="checked" />
                                <label class="form-check-label" for="customradio2">Skip</label>
                            </div>
                        </div>
                        <div class="form-group col-md-6">
                            <div class="form-check mb-2 form-check-danger">
                                <input class="form-check-input" type="radio" name="keeplist" value="replace" id="customradio4" />
                                <label class="form-check-label" for="customradio4">Replace</label>
                            </div>
                        </div>
                    </div>
                    <div class="form-group text-center col-md-12">
                        <button class="btn btn-primary editable-submit waves-effect waves-light" type="submit" style="background-color: #406e8e; border: #406e8e;">Add System</button>
                    </div>
                </form>

                <script>
                    function showDiv(divId, element) {
                        document.getElementById(divId).style.display = element.value == "Custom" ? 'block' : 'none';
                    }
                </script>

                <script>
                    $(document).ready(function() {
                        $(".parsley-examples").parsley()
                    });
                </script>
            </div>
        </div>
    </div>
</div>

<div id="exampleModal4" class="modal fade" tabindex="-1" role="dialog" aria-labelledby="standard-modalLabel" >

    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <h4 class="modal-title" id="standard-modalLabel">Tag Selected Update</h4>
                <button type="button" class="close" data-bs-dismiss="modal" >
<i class="mdi mdi-close-thick"></i></button>
            </div>
            <div class="modal-body">
                <form method="post" class="parsley-examples demo-default selectize-close-btn" data-parsley-excluded="input[type=button], input[type=submit], input[type=reset], input[type=hidden], [disabled], :hidden" data-parsley-trigger="keyup" data-parsley-validate="" novalidate="" id="myformtag" name="myformtag" action="/include/tmpcontacttags.cfm" method="POST">
                    <div class="form-group col-md-12">
                        <label for="valuetext">Select Tag to add or remove from selected relationships</label>
                    </div>
                    <div class="form-group col-md-6">
                        <select id="select-tag" name="new_tagname" class="form-control" data-parsley-required="" data-parsley-error-message="Tag is required">
                            <option value="">Select a Tag...</option>
                            <cfloop query="tags">
                                <cfset new_tagname=tags.tagname />
                                <cfset new_tagselect="" />
                                <cfoutput>
                                    <option value="#new_tagname#" #new_tagselect#>#new_tagname#</option>
                                </cfoutput>
                            </cfloop>
                        </select>
                    </div>
                    <div class="form-group col-md-12">
                        <label for="valuetext">Action:</label>
                    </div>
                    <div class="form-group col-md-12">
                        <div class="form-group col-md-5">
                            <div class="form-check mb-2 form-check-success">
                                <input class="form-check-input" type="radio" name="addremove" value="add" id="add" checked="checked" />
                                <label class="form-check-label" for="customradio2">Add it</label>
                            </div>
                        </div>
                        <div class="form-group col-md-6">
                            <div class="form-check mb-2 form-check-danger">
                                <input class="form-check-input" type="radio" name="addremove" value="remove" id="remove" />
                                <label class="form-check-label" for="customradio4">Remove it</label>
                            </div>
                        </div>
                    </div>
                    <div class="form-group text-center col-md-12">
                        <button class="btn btn-primary editable-submit waves-effect waves-light" type="submit" style="background-color: #406e8e; border: #406e8e;">Continue</button>
                    </div>
                </form>
            </div>
        </div>
    </div>
</div>

<cfset script_name_include="/include/#ListLast(GetCurrentTemplatePath(), " \")#" />

