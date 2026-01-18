<!--- This ColdFusion page handles the display and submission of a form for adding RPG-related information. --->

<script src="/app/assets/js/jquery.bootstrap-touchspin.js"></script>  
<cfsilent> 

<cfinclude template="rpg_load.cfm" />

<cfparam name="t1" default="0" />
<cfparam name="t2" default="0" />
<cfparam name="t3" default="0" />
<cfparam name="t4" default="0" />

<cfset cur_icon = "" />
<cfset headcols = 3 />
<cfset valuecols = 9 />

</cfsilent>

<form action="/include/remoteNewFormAdd.cfm" method="post" class="needs-validation" novalidate>
        <cfoutput>
            <input type="hidden" name="rpgid" value="#rpgid#" />
            <input type="hidden" name="pgdir" value="#pgdir#" />
            <input type="hidden" name="t1" value="#t1#" />
            <input type="hidden" name="t2" value="#t2#" />
            <input type="hidden" name="t3" value="#t3#" />
            <input type="hidden" name="t4" value="#t4#" />
            <cfif isdefined('contactid')>
                <input type="hidden" name="contactid" value="#contactid#" />
            </cfif>
            <cfif isdefined('userid')>
                <input type="hidden" name="userid" value="#userid#" />
            </cfif>
        </cfoutput>

        <div class="row">
            <!--- Loop through the RPGAdd query to generate form fields based on the type. --->
            <cfloop query="RPGAdd">
                <cfif RPGAdd.add_yn is "Y">
                    <cfif RPGAdd.updatetype is "input">
                        <cfoutput>
                            <div class="form-group col-md-12">
                                <label for="#RPGAdd.fname#">#RPGAdd.updatename#</label>
                                <input class="form-control" type="text" id="#RPGAdd.fname#" name="#RPGAdd.fname#" <cfif RPGAdd.required_yn is "Y" >
required</cfif> placeholder="#RPGAdd.updatename#">
                                <div class="invalid-feedback">
                                    Please enter a #RPGAdd.updatename#.
                                </div>
                            </div>
                        </cfoutput>

                    <cfelseif RPGAdd.updatetype is "number">
                        <cfoutput>
                            <div class="form-group col-md-6">
                                <label for="#RPGAdd.fname#">#RPGAdd.updatename# (#RPGAdd.num_min#-#RPGAdd.num_max#)</label>
                                <input id="new_#RPGAdd.fname#"  
                                       type="text"
                                       name="#RPGAdd.fname#"
                                       data-bts-min="#RPGAdd.num_min#"
                                       data-bts-max="#RPGAdd.num_max#"
                                       data-bts-init-val="0"
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
                                    $("input[name='new_#RPGAdd.fname#']").TouchSpin();
                                </script>
                            </div>
                        </cfoutput>

                    <cfelseif RPGAdd.updatetype is "password">  
                        <cfoutput>
                            <div class="form-group col-md-12">
                                <label for="#RPGAdd.fname#">#RPGAdd.updatename#</label>
                                <input class="form-control" type="password" id="#RPGAdd.fname#" name="#RPGAdd.fname#" <cfif RPGAdd.required_yn is "Y" >
required</cfif> placeholder="#RPGAdd.updatename#">
                                <div class="invalid-feedback">
                                    Please add a valid #RPGAdd.updatename#.
                                </div>
                            </div>
                        </cfoutput>

                    <cfelseif RPGAdd.updatetype is "textarea">  
                        <cfoutput>
                            <div class="form-group col-md-12">
                                <label for="#RPGAdd.fname#">#RPGAdd.updatename#</label>
                                <textarea class="form-control" id="#RPGAdd.fname#" name="#RPGAdd.fname#" <cfif RPGAdd.required_yn is "Y">required</cfif> placeholder="#RPGAdd.updatename#" rows="1"></textarea>
                                <div class="invalid-feedback">
                                    Please enter a #RPGAdd.updatename#.
                                </div>
                            </div>
                        </cfoutput>

                    <cfelseif RPGAdd.updatetype is "calendar">  
                        <cfoutput>
                            <div class="form-group col-md-6">
                                <label for="#RPGAdd.fname#">#RPGAdd.updatename#</label>
                                <input class="form-control" id="#RPGAdd.fname#" name="#RPGAdd.fname#" type="date" />
                                <div class="invalid-feedback">
                                    Please choose a #RPGAdd.updatename#.
                                </div>
                            </div>
                        </cfoutput>

                    <cfelseif RPGAdd.updatetype is "select_id">
                        <cfinclude template="/include/qry/selects_245_1.cfm" />
                        <cfoutput>
                            <div class="form-group col-md-6">
                                <label for="#RPGAdd.fname#">#RPGAdd.updatename#</label>
                                <select class="form-control" name="#RPGAdd.fname#" id="#RPGAdd.fname#">
                        </cfoutput>

                        <cfloop query="selects">
                            <cfoutput>
                                <option value="#selects.value#">#selects.text#</option>
                            </cfoutput>
                        </cfloop>
                                </select>
                                <div class="invalid-feedback">
                                    Please select a <cfoutput>#RPGAdd.updatename#</cfoutput>.
                                </div>
                            </div>

                    <cfelseif RPGAdd.updatetype is "time">  
                        <cfoutput>
                            <div class="form-group col-md-6">
                                <label for="#RPGAdd.fname#">#RPGAdd.updatename#</label>
                                <input class="form-control" id="#RPGAdd.fname#" name="#RPGAdd.fname#" type="time" />
                                <div class="invalid-feedback">
                                    Please choose a #RPGAdd.updatename#.
                                </div>
                            </div>
                        </cfoutput>

                    <cfelseif RPGAdd.updatetype is "select">  
                        <cfinclude template="/include/qry/selects_245_2.cfm" />
                        <cfoutput>
                            <div class="form-group col-md-6">
                                <label for="#RPGAdd.fname#">#RPGAdd.updatename#</label>
                                <select class="form-control" name="#RPGAdd.fname#" id="#RPGAdd.fname#">
                        </cfoutput>

                        <cfloop query="selects">
                            <cfoutput>
                                <option value="#selects.value#">#selects.text#</option>
                            </cfoutput>
                        </cfloop>
                                </select>
                                <div class="invalid-feedback">
                                    Please select a #RPGAdd.updatename#.
                                </div>
                            </div>
                    </cfif>
                <cfelse>
                    <cfoutput>
                        <input type="hidden" name="#RPGAdd.fname#" value="" />
                    </cfoutput>
                </cfif>  
            </cfloop>
        </div>

        <div class="form-group text-center">
            <button class="btn btn-xs btn-primary waves-effect mb-2 waves-light" style="background-color: ##406e8e; border: ##406e8e;" type="submit">Add</button>
        </div>
    </form>

    <script>
        // Example starter JavaScript for disabling form submissions if there are invalid fields
        (function () {
            'use strict'
            // Fetch all the forms we want to apply custom Bootstrap validation styles to
            var forms = document.querySelectorAll('.needs-validation')

            // Loop over them and prevent submission
            Array.prototype.slice.call(forms)
                .forEach(function (form) {
                    form.addEventListener('submit', function (event) {
                        if (!form.checkValidity()) {
                            event.preventDefault()
                            event.stopPropagation()
                        }
                        form.classList.add('was-validated')
                    }, false)
                })
        })()
    </script>
