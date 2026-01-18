<!--- This ColdFusion page handles the update of RPG details through a form submission. --->

<script src="/app/assets/js/jquery.bootstrap-touchspin.js"></script>

<cfsilent>
    <!--- Include necessary templates and set default parameters --->
    <cfinclude template="rpg_load.cfm" />
    <cfparam name="details_pgid" default="" />
    <cfparam name="t1" default="0" />
    <cfparam name="t2" default="0" />
    <cfparam name="t3" default="0" />
    <cfparam name="t4" default="0" />
    <cfinclude template="/include/qry/FindModalTitle_265_1.cfm" />
    <cfinclude template="/include/qry/update.cfm" />
</cfsilent>

<cfset cur_icon="">
<cfset headcols=3 />
<cfset valuecols=9 />
<cfinclude template="/include/qry/find_265_2.cfm" />

<p>Enter the information below and press the update button to continue.</p>
<form action="/include/remoteUpdateFormUpdate.cfm" method="post" class="needs-validation" novalidate>
    <cfoutput>
        <input type="hidden" name="rpgid" value="#rpgid#" />
        <input type="hidden" name="details_pgid" value="#details_pgid#" />
        <input type="hidden" name="t1" value="#t1#" />
        <input type="hidden" name="t2" value="#t2#" />
        <input type="hidden" name="t3" value="#t3#" />
        <input type="hidden" name="t4" value="#t4#" />
        <input type="hidden" name="pgdir" value="#pgdir#" />
        <input type="hidden" name="details_recid" value="#details_recid#" />
        <input type="hidden" name="pgid" value="#pgid#" />
        <input type="hidden" name="recid" value="#recid#" />

        <!--- Check for contactid and userid and include them as hidden inputs --->
        <cfif isdefined('contactid')>
            <input type="hidden" name="contactid" value="#contactid#" />
        </cfif>
        <cfif isdefined('userid')>
            <input type="hidden" name="userid" value="#userid#" />
        </cfif>
    </cfoutput>

    <div class="row" />
    <cfloop query="RPGUpdate">
        <!--- Debugging output for RPGUpdate fields --->
        <cfif isdefined('dbugz')>
            <br>
            <cfoutput>fname: #RPGUpdate.fname# update_yn: #RPGUpdate.update_yn#</cfoutput>
        </cfif>

        <!--- Check if the update is required --->
        <cfif RPGUpdate.update_yn is "Y">
            <cfinclude template="/include/qry/FindValue_265_3.cfm" />
            <cfif isdefined('dbug')>
                <cfoutput> - updatetype: #RPGUpdate.updatetype#</cfoutput>
            </cfif>

            <!--- Handle different update types --->
            <cfif RPGUpdate.updatetype is "input">
                <cfoutput>
                    <div class="form-group col-md-12">
                        <label for="#RPGUpdate.fname#">#RPGUpdate.updatename#</label>
                        <input class="form-control" type="text" id="#RPGUpdate.fname#" name="new_#RPGUpdate.fname#" value="#FindValue.fvalue#" 
                            <cfif RPGUpdate.required_yn is "Y">required</cfif> placeholder="#RPGUpdate.updatename#">
                        <div class="invalid-feedback">
                            Please enter a #RPGUpdate.updatename#.
                        </div>
                    </div>
                </cfoutput>

            <cfelseif RPGUpdate.updatetype is "number">
                <cfoutput>
                    <div class="form-group col-md-6">
                        <label for="#RPGUpdate.fname#">#RPGUpdate.updatename# (#RPGUpdate.num_min#-#RPGUpdate.num_max#)</label>
                        <input id="new_#RPGUpdate.fname#" type="text" value="#FindValue.fvalue#" name="new_#RPGUpdate.fname#"
                            data-bts-min="#RPGUpdate.num_min#"
                            data-bts-max="#RPGUpdate.num_max#"
                            data-bts-init-val="#FindValue.fvalue#"
                            data-bts-step="1"
                            data-bts-decimal="0"
                            data-bts-step-interval="100"
                            data-bts-force-step-divisibility="round"
                            data-bts-step-interval-delay="500"
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

            <cfelseif RPGUpdate.updatetype is "password">
                <cfoutput>
                    <div class="form-group col-md-12">
                        <label for="#RPGUpdate.fname#">#RPGUpdate.updatename#</label>
                        <input class="form-control" type="password" id="#RPGUpdate.fname#" name="new_#RPGUpdate.fname#" value="#FindValue.fvalue#" 
                            <cfif RPGUpdate.required_yn is "Y">required</cfif> placeholder="#RPGUpdate.updatename#">
                        <div class="invalid-feedback">
                            Please add a valid #RPGUpdate.updatename#.
                        </div>
                    </div>
                </cfoutput>

            <cfelseif RPGUpdate.updatetype is "textarea">
                <cfoutput>
                    <div class="form-group col-md-12">
                        <label for="#RPGUpdate.fname#">#RPGUpdate.updatename#</label>
                        <textarea class="form-control" id="#RPGUpdate.fname#" name="new_#RPGUpdate.fname#" 
                            <cfif RPGUpdate.required_yn is "Y">required</cfif> placeholder="#RPGUpdate.updatename#" rows="1">#TRIM(FindValue.fvalue)#</textarea>
                        <div class="invalid-feedback">
                            Please enter a #RPGUpdate.updatename#.
                        </div>
                    </div>
                </cfoutput>

            <cfelseif RPGUpdate.updatetype is "calendar">
                <cfoutput>
                    <cfset datevalue="#this.formatDate(findvalue.fvalue)#" />
                    <div class="form-group col-md-6">
                        <label for="#RPGUpdate.fname#">#RPGUpdate.updatename#</label>
                        <input class="form-control" id="#RPGUpdate.fname#" name="new_#RPGUpdate.fname#" value="#datevalue#" type="date" />
                        <div class="invalid-feedback">
                            Please choose a #RPGUpdate.updatename#.
                        </div>
                    </div>
                </cfoutput>

            <cfelseif RPGUpdate.updatetype is "select_id">
                <cfinclude template="/include/qry/FindValue_265_4.cfm" />
                <cfinclude template="/include/qry/selects_265_5.cfm" />
                <cfoutput>
                    <div class="form-group col-md-6">
                        <label for="#RPGUpdate.fname#">#RPGUpdate.updatename#</label>
                        <select class="form-control" name="new_#RPGUpdate.fname#" id="#RPGUpdate.fname#">
                </cfoutput>
                <cfloop query="selects">
                    <cfoutput>
                        <option value="#selects.value#" <cfif selects.value is "#FindValue.fvalue#"> selected </cfif> >
                            #selects.text#</option>
                    </cfoutput>
                </cfloop>
                </select>
                <div class="invalid-feedback">
                    Please select a <cfoutput>#RPGUpdate.updatename#</cfoutput>.
                </div>
                </div>

            <cfelseif RPGUpdate.updatetype is "select_id_bycat">
                <cfinclude template="/include/qry/FindValue_265_6.cfm" />
                <cfinclude template="/include/qry/selects_265_7.cfm" />
                <cfoutput>
                    <div class="form-group col-md-6">
                        <label for="#RPGUpdate.fname#">#RPGUpdate.updatename#</label>
                        <select class="form-control" name="new_#RPGUpdate.fname#" id="#RPGUpdate.fname#">
                </cfoutput>
                <cfloop query="selects">
                    <cfoutput>
                        <option value="#selects.value#" <cfif selects.value is "#FindValue.fvalue#"> selected </cfif> >
                            #selects.text#</option>
                    </cfoutput>
                </cfloop>
                </select>
                <div class="invalid-feedback">
                    Please select a <cfoutput>#RPGUpdate.updatename#</cfoutput>.
                </div>
                </div>

            <cfelseif RPGUpdate.updatetype is "select_distinct">
                <cfinclude template="/include/qry/FindValue_265_8.cfm" />
                <cfoutput>#rpgupdate.tableselect#</cfoutput>
                <cfinclude template="/include/qry/selects_265_9.cfm" />
                <cfoutput>
                    <div class="form-group col-md-6">
                        <label for="#RPGUpdate.fname#">#RPGUpdate.updatename#</label>
                        <select class="form-control" name="new_#RPGUpdate.fname#" id="#RPGUpdate.fname#">
                </cfoutput>
                <cfloop query="selects">
                    <cfoutput>
                        <option value="#selects.value#" <cfif selects.value is "#FindValue.fvalue#"> selected </cfif> >
                            #selects.text#</option>
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

            <cfelseif RPGUpdate.updatetype is "delete">
                <div class="custom-group custom-checkbox">
                    <div style="margin-left:25px;">
                        <label class="custom-control-label">
                            <input type="checkbox" class="custom-control-input" id="deleteitem" value="1" name="new_isDeleted" />
                            <span class="custom-control-label" for="deleteitem">Delete</span>
                        </label>
                    </div>
                </div>

            <cfelseif RPGUpdate.updatetype is "select_fieldvalue">
                <cfinclude template="/include/qry/FindValue_265_10.cfm" />
                <cfinclude template="/include/qry/selects_265_11.cfm" />
                <cfoutput>
                    <div class="form-group col-md-6">
                        <label for="#RPGUpdate.fname#">#RPGUpdate.updatename#</label>
                        <select class="form-control" name="new_#RPGUpdate.fname#" id="#RPGUpdate.fname#">
                </cfoutput>
                <cfloop query="selects">
                    <cfoutput>
                        <option value="#selects.value#" <cfif selects.value is "#FindValue.fvalue#"> selected </cfif> >
                            #selects.text#</option>
                    </cfoutput>
                </cfloop>
                </select>
                <div class="invalid-feedback">
                    Please select a <cfoutput>#RPGUpdate.updatename#</cfoutput>.
                </div>
                </div>

            <cfelseif RPGUpdate.updatetype is "time">
                <cfoutput>
                    <div class="form-group col-md-6">
                        <label for="#RPGUpdate.fname#">#RPGUpdate.updatename#</label>
                        <input class="form-control" id="#RPGUpdate.fname#" value="#FindValue.fvalue#" name="new_#RPGUpdate.fname#" type="time" />
                        <div class="invalid-feedback">
                            Please choose a #RPGUpdate.updatename#.
                        </div>
                    </div>
                </cfoutput>

            <cfelseif RPGUpdate.updatetype is "select">
                <cfinclude template="/include/qry/selects_107_12.cfm" />
                <cfoutput>
                    <div class="form-group col-md-6">
                        <label for="#RPGUpdate.fname#">#RPGUpdate.updatename#</label>
                        <select class="form-control" name="new_#RPGUpdate.fname#" id="#RPGUpdate.fname#">
                </cfoutput>
                <cfloop query="selects">
                    <cfoutput>
                        <option value="#selects.value#" <cfif selects.value is ""> selected </cfif> >
                            #selects.text#</option>
                    </cfoutput>
                </cfloop>
                </select>
                <div class="invalid-feedback">
                    Please select a <cfoutput>#RPGUpdate.updatename#</cfoutput>.
                </div>
                </div>

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

