<!--- This ColdFusion page handles the display and update of child records, including viewing details and updating information. --->

<script src="/app/assets/js/jquery.bootstrap-touchspin.js"></script>
<cfset pgcol = 3 />

<cfinclude template="/include/qry/Findchild_107_1.cfm" />

<cfoutput>
    <cfset details_pgid = "#pgid#" />
    <cfset details_recid = "#recid#" />
</cfoutput>

<cfif #pgaction# is "view">
    <!--- Check if the action is to view details --->
    <div class="row">
        <div class="col-12">
            <div class="card mb-3">
                <div class="card-body">
                    <h4 class="header-title">
                        <cfoutput> #pgHeading#: #details.recordname#</cfoutput>
                      
                    </h4>

                    <div class="d-flex justify-content-between">
                        <div class="float-left">
                            <cfinclude template="/include/qry/FindDetails_107_2.cfm" />
                            <cfif #findDetails.recordcount# is "1">
                                <cfoutput>
                                    <a title="View All" href="/app/#finddetails.pgdir#/">
                                        <i class="mdi mdi-eye-outline"></i> View All
                                    </a>
                                </cfoutput>
                            </cfif>
                        </div>

                        <div class="dropdown float-end">
                            <A HREF="<cfoutput>/app/#pgdir#/?recid=#details_recid#&pgaction=update</cfoutput>" class="btn btn-xs btn-primary waves-effect mb-2 waves-light" style="background-color: #406e8e; border: #406e8e;margin-bottom: 10px;">
                                Update
                            </A>
                        </div>
                    </div>

                    <div class="row">
                        <cfset n = 0 />
                        <Cfoutput query="details">
                            <cfloop index="i" from="1" to="#findresults.recordcount#">
                                <div class="col-#EVALUATE('pgcol#i#')#">
                                    <p class="mt-2 mb-0 font-weight-bold">#EVALUATE('head#i#')#</p>
                                    <div class="media">
                                        <div class="media-body">
                                            <div class="mt-0 font-size-12">
                                                #EVALUATE('col#i#')#
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </cfloop>
                        </Cfoutput>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <cfif #Findchild.recordcount# is "1">
        <!--- Check if there is one child record found --->
        <cfset rpgid = Findchild.pgid />
        <cfinclude template="rpg_load.cfm">
        <cfset comptable = "#rpg_compTable#" />
        <cfoutput>
            <cfset pgid = #rpg_pgid# />
            <cfset filter = " and t.#FindKey.fname# = #recid#" />
        </cfoutput>
        <cfset compid = "#rpg_compid#" />
        <cfset compname = "#rpg_compname#" />
        <cfset pgheading = "#rpg_pgHeading#" />
        <cfinclude template="qry/results.cfm" />
        <cfset child_yn = "Y" />
        <cfset pgdir = "#rpg_pgDir#" />
        <cfinclude template="/include/results.cfm" />
    </cfif>

    <div class="modal fade" id="confirm-delete" tabindex="-1" role="dialog" aria-labelledby="myModalLabel" >

        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header">
                    <button type="button" class="close" data-bs-dismiss="modal" >
&times;</button>
                    <h4 class="modal-title" id="myModalLabel">Confirm Delete</h4>
                </div>
                <div class="modal-body">
                    <p>You are about to delete one track, this procedure is irreversible.</p>
                    <p>Do you want to proceed?</p>
                    <p class="debug-url"></p>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-default" data-bs-dismiss="modal">Cancel</button>
                    <a class="btn btn-danger btn-ok">Delete</a>
                </div>
            </div>
        </div>
    </div>

    <script>
        $('#confirm-delete').on('show.bs.modal', function(e) {
            $(this).find('.btn-ok').attr('href', $(e.relatedTarget).data('href'));
            $('.debug-url').html('Delete URL: <strong>' + $(this).find('.btn-ok').attr('href') + '</strong>');
        });
    </script>

<cfelseif #pgaction# is "update">
    <!--- Check if the action is to update details --->
    <div class="row">
        <div class="col-12">
            <div class="card mb-3">
                <div class="card-body">
                    <h4 class="header-title">Update Form </h4>

                    <cfsilent>
                        <cfset rpgid = pgid />
                        <cfinclude template="rpg_load.cfm" />
                        <cfparam name="t1" default="0" />
                        <cfparam name="t2" default="0" />
                        <cfparam name="t3" default="0" />
                        <cfparam name="t4" default="0" />
                        <cfinclude template="/include/qry/FindModalTitle_107_3.cfm" />
                        <cfinclude template="/include/qry/update.cfm" />
                    </cfsilent>

                    <cfset cur_icon = "" />
                    <cfset headcols = 3 />
                    <cfset valuecols = 9 />
                    <cfinclude template="/include/qry/find_107_4.cfm" />

                    <h5>
                        <cfoutput>#RPGUpdate.compname#: #find.recordname#</cfoutput>
                    </h5>

                    <p>Enter the information below and press the update button to continue.</p>
                    <form action="/include/UpdateFormUpdate.cfm" method="post" class="needs-validation" novalidate>
                        <cfoutput>
                            <input type="hidden" name="rpgid" value="#rpgid#" />
                            <input type="hidden" name="pgid" value="#rpgid#" />
                            <input type="hidden" name="t1" value="#t1#" />
                            <input type="hidden" name="t2" value="#t2#" />
                            <input type="hidden" name="t3" value="#t3#" />
                            <input type="hidden" name="t4" value="#t4#" />
                            <input type="hidden" name="pgdir" value="#pgdir#" />
                            <input type="hidden" name="recid" value="#recid#" />

                            <cfif #isdefined('contactid')#>
                                <input type="hidden" name="contactid" value="#contactid#" />
                            </cfif>

                            <cfif #isdefined('userid')#>
                                <input type="hidden" name="userid" value="#userid#" />
                            </cfif>
                        </cfoutput>

                        <div class="row" />
                        <cfloop query="RPGUpdate">
                            <cfif #isdefined('dbugz')#>
                                <BR>
                                <cfoutput>fname: #RPGUpdate.fname# update_yn: #RPGUpdate.update_yn#</cfoutput>
                            </cfif>

                            <cfif #RPGUpdate.update_yn# is "Y">
                                <cfinclude template="/include/qry/FindValue_107_5.cfm" />

                                <cfif #isdefined('dbug')#>
                                    <cfoutput> - updatetype: #RPGUpdate.updatetype#</cfoutput>
                                </cfif>

                                <cfif #RPGUpdate.updatetype# is "input">
                                    <cfoutput>
                                        <div class="form-group col-md-12">
                                            <label for="#RPGUpdate.fname#">#RPGUpdate.updatename#</label>
                                            <input class="form-control" type="text" id="#RPGUpdate.fname#" name="new_#RPGUpdate.fname#" value="#FindValue.fvalue#" <cfif #RPGUpdate.required_yn# is "Y" >
required</cfif> placeholder="#RPGUpdate.updatename#">
                                            <div class="invalid-feedback">
                                                Please enter a #RPGUpdate.updatename#.
                                            </div>
                                        </div>
                                    </cfoutput>

                                <cfelseif #RPGUpdate.updatetype# is "number">
                                    <cfoutput>
                                        <div class="form-group col-md-6">
                                            <label for="#RPGUpdate.fname#">#RPGUpdate.updatename# (#RPGUpdate.num_min#-#RPGUpdate.num_max#)</label>
                                            <input id="new_#RPGUpdate.fname#"  
                                                   type="text"
                                                   value="#FindValue.fvalue#"
                                                   name="new_#RPGUpdate.fname#"
                                                   data-bts-min="#RPGUpdate.num_min#"
                                                   data-bts-max="#RPGUpdate.num_max#"
                                                   data-bts-init-val="#FindValue.fvalue#"
                                                   data-bts-step="1"
                                                   data-bts-decimal="0"
                                                   data-bts-step-interval="100"
                                                   data-bts-force-step-divisibility="round"
                                                   data-bts-step-interval-delay="500"
                                                   data-bts-prefix=""
                                                   data-bts-postfix=""
                                                   data-bts-prefix-extra-class=""
                                                   data-bts-postfix-extra-class=""
                                                   data-bts-booster="true"
                                                   data-bts-boostat="10"
                                                   data-bts-max-boosted-step="false"
                                                   data-bts-mousewheel="true"
                                                   data-bts-button-down-class="btn btn-secondary"
                                                   data-bts-button-up-class="btn btn-secondary" />
                                            <script>
                                                $("input[name='new_#RPGUpdate.fname#']").TouchSpin();
                                            </script>
                                        </div>
                                    </cfoutput>

                                <cfelseif #RPGUpdate.updatetype# is "password">
                                    <cfoutput>
                                        <div class="form-group form-group col-md-12">
                                            <label for="#RPGUpdate.fname#">#RPGUpdate.updatename#</label>
                                            <input class="form-control" type="password" id="#RPGUpdate.fname#" name="new_#RPGUpdate.fname#" value="#FindValue.fvalue#" <cfif #RPGUpdate.required_yn# is "Y" >
required</cfif> placeholder="#RPGUpdate.updatename#">
                                            <div class="invalid-feedback">
                                                Please add a valid #RPGUpdate.updatename#.
                                            </div>
                                        </div>
                                    </cfoutput>

                                <cfelseif #RPGUpdate.updatetype# is "textarea">
                                    <cfoutput>
                                        <div class="form-group col-md-12">
                                            <label for="#RPGUpdate.fname#">#RPGUpdate.updatename#</label>
                                            <textarea class="form-control" type="text" id="#RPGUpdate.fname#" name="new_#RPGUpdate.fname#" <cfif #RPGUpdate.required_yn# is "Y">required </cfif> placeholder="#RPGUpdate.updatename#" rows="1">#TRIM(FindValue.fvalue)#</textarea>
                                            <div class="invalid-feedback">
                                                Please enter a #RPGUpdate.updatename#.
                                            </div>
                                        </div>
                                    </cfoutput>

                                <cfelseif #RPGUpdate.updatetype# is "calendar">
                                    <cfoutput>
                                        <cfset datevalue="#Dateformat(findvalue.fvalue)#" />
                                        <div class="form-group col-md-6">
                                            <label for="#RPGUpdate.fname#">#RPGUpdate.updatename#</label>
                                            <input class="form-control" id="#RPGUpdate.fname#" name="new_#RPGUpdate.fname#" value="#datevalue#" type="date" />
                                            <div class="invalid-feedback">
                                                Please choose a #RPGUpdate.updatename#.
                                            </div>
                                        </div>
                                    </cfoutput>

                                <cfelseif #RPGUpdate.updatetype# is "select_id">
                                    <cfinclude template="/include/qry/FindValue_107_6.cfm" />
                                    <cfinclude template="/include/qry/selects_107_7.cfm" />
                                    <cfoutput>
                                        <div class="form-group col-md-6">
                                            <label for="#RPGUpdate.fname#">#RPGUpdate.updatename#</label>
                                            <select class="form-control" name="new_#RPGUpdate.fname#" id="#RPGUpdate.fname#">
                                    </cfoutput>
                                    <cfloop query="selects">
                                        <cfoutput>
                                            <option value="#selects.value#" <cfif #selects.value# is "#FindValue.fvalue#"> selected </cfif> >
                                                #selects.text#
                                            </option>
                                        </cfoutput>
                                    </cfloop>
                                    </select>
                                    <div class="invalid-feedback">
                                        Please select a <cfoutput>#RPGUpdate.updatename#</cfoutput>.
                                    </div>
                                    </div>

                                <cfelseif #RPGUpdate.updatetype# is "select_distinct">
                                    <cfinclude template="/include/qry/FindValue_107_8.cfm" />
                                    <cfoutput>#rpgupdate.tableselect#</cfoutput>
                                    <cfinclude template="/include/qry/selects_107_9.cfm" />
                                    <cfoutput>
                                        <div class="form-group col-md-6">
                                            <label for="#RPGUpdate.fname#">#RPGUpdate.updatename#</label>
                                            <select class="form-control" name="new_#RPGUpdate.fname#" id="#RPGUpdate.fname#">
                                    </cfoutput>
                                    <cfloop query="selects">
                                        <cfoutput>
                                            <option value="#selects.value#" <cfif #selects.value# is "#FindValue.fvalue#"> selected </cfif> >
                                                #selects.text#
                                            </option>
                                        </cfoutput>
                                    </cfloop>
                                    </select>
                                    <div class="invalid-feedback">
                                        Please select a <cfoutput>#RPGUpdate.updatename#</cfoutput>.
                                    </div>
                                    </div>

                                <cfelseif #RPGUpdate.updatetype# is "delete">
                                    <div class="custom-group custom-checkbox">
                                        <div style="margin-left:25px;">
                                            <label class="custom-control-label">
                                                <input type="checkbox" class="custom-control-input" id="deleteitem" value="1" name="new_isDeleted" />
                                                <span class="custom-control-label" for="deleteitem">Delete</span>
                                            </label>
                                        </div>
                                    </div>

                                <cfelseif #RPGUpdate.updatetype# is "select_fieldvalue">
                                    <cfinclude template="/include/qry/FindValue_107_5.cfm" />
                                    <cfinclude template="/include/qry/selects_107_11.cfm" />
                                    <cfoutput>
                                        <div class="form-group col-md-6">
                                            <label for="#RPGUpdate.fname#">#RPGUpdate.updatename#</label>
                                            <select class="form-control" name="new_#RPGUpdate.fname#" id="#RPGUpdate.fname#">
                                    </cfoutput>
                                    <cfloop query="selects">
                                        <cfoutput>
                                            <option value="#selects.value#" <cfif #selects.value# is "#FindValue.fvalue#"> selected </cfif> >
                                                #selects.text#
                                            </option>
                                        </cfoutput>
                                    </cfloop>
                                    </select>
                                    <div class="invalid-feedback">
                                        Please select a <cfoutput>#RPGUpdate.updatename#</cfoutput>.
                                    </div>
                                    </div>

                                <cfelseif #RPGUpdate.updatetype# is "time">
                                    <cfoutput>
                                        <div class="form-group col-md-6">
                                            <label for="#RPGUpdate.fname#">#RPGUpdate.updatename#</label>
                                            <input class="form-control" id="#RPGUpdate.fname#" name="new_#RPGUpdate.fname#" type="time" />
                                            <div class="invalid-feedback">
                                                Please choose a #RPGUpdate.updatename#.
                                            </div>
                                        </div>
                                    </cfoutput>

                                <cfelseif #RPGUpdate.updatetype# is "select">
                                    <cfinclude template="/include/qry/selects_107_12.cfm" />
                                    <cfoutput>
                                        <div class="form-group col-md-6">
                                            <label for="#RPGUpdate.fname#">#RPGUpdate.updatename#</label>
                                            <select class="form-control" name="new_#RPGUpdate.fname#" id="#RPGUpdate.fname#">
                                    </cfoutput>
                                    <cfloop query="selects">
                                        <cfoutput>
                                            <option value="#selects.value#" <cfif #selects.value# is ""> selected </cfif> >
                                                #selects.text#
                                            </option>
                                        </cfoutput>
                                    </cfloop>
                                    </select>
                                    <div class="invalid-feedback">
                                        Please select a <cfoutput>#RPGUpdate.updatename#</cfoutput>.
                                    </div>
                                    </div>

                                            <cfelseif RPGUpdate.updatetype is "yn">
                <cfoutput>
                    <div class="custom-group custom-checkbox">
                        <div style="margin-left:25px;">
                            <label class="custom-control-label">
                                <input type="checkbox" class="custom-control-input" id="#RPGUpdate.fname#" value="1" name="new_#RPGUpdate.fname#" 
                                    <cfif FindValue.fvalue is "1">checked</cfif> >
                                <span class="custom-control-label" for="#RPGUpdate.fname#">#RPGUpdate.updatename#</span>
                            </label>
                        </div>
                    </div>
                </cfoutput>

<cfelse>
                                    <cfoutput>
                                        <input type="hidden" name="new_#RPGUpdate.fname#" value="" />
                                    </cfoutput>
                                </cfif>
                            </cfif>
                        </cfloop>

                        <div class="form-group text-center col-md-12">
                            <button class="btn btn-xs btn-primary waves-effect mb-2 waves-light" style="background-color: #406e8e; border: #406e8e;" type="submit">Update</button>
                        </div>
                    </form>

                    <script>
                        // Example starter JavaScript for disabling form submissions if there are invalid fields
                        (function() {
                            'use strict'
                            // Fetch all the forms we want to apply custom Bootstrap validation styles to
                            var forms = document.querySelectorAll('.needs-validation')

                            // Loop over them and prevent submission
                            Array.prototype.slice.call(forms)
                                .forEach(function(form) {
                                    form.addEventListener('submit', function(event) {
                                        if (!form.checkValidity()) {
                                            event.preventDefault()
                                            event.stopPropagation()
                                        }
                                        form.classList.add('was-validated')
                                    }, false)
                                })
                        })()
                    </script>
                </div>
            </div>
        </div>
    </div>
</cfif>

