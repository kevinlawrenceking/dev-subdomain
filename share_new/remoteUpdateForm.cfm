

<script src="/app/assets/js/jquery.bootstrap-touchspin.js"></script>   

<cfsilent>

<cfinclude template="rpg_load.cfm" />
<cfparam name="details_pgid" default="" />
    
<cfparam name="t1" default="0" />

<cfparam name="t2" default="0" />

<cfparam name="t3" default="0" />

<cfparam name="t4" default="0" />

<cfquery result="result" name="FindModalTitle" >
    SELECT p.pgTitle,
    c.compname
    FROM pgpages p
    INNER JOIN pgcomps c ON c.compID = p.compID
    INNER JOIN pgapps a ON a.appID = c.appid
    WHERE p.pgid = #rpgid#
</cfquery>

<cfinclude template="/include/qry/update.cfm" />

</cfsilent>
<cfset cur_icon="">

    <cfset headcols=3 />
    <cfset valuecols=9 />

<cfquery result="result" name="find" >
        Select recordname
        FROM #rpg_compTable#
        Where #Fid# = #recid#
    </cfquery>
    <h5>
        <cfoutput>#RPGUpdate.compname#: #find.recordname#</cfoutput>
    </h5>

    <p>Enter the information below and press the update button to continue.</p>
    <form action="/include/remoteUpdateFormUpdate.cfm" method="post" class="needs-validation" novalidate>
        <cfoutput><input type="hidden" name="rpgid" value="#rpgid#" />
            <input type="hidden" name="details_pgid" value="#details_pgid#" />
          
                           <input type="hidden" name="t1" value="#t1#" />
                     <input type="hidden" name="t2" value="#t2#" />
                     <input type="hidden" name="t3" value="#t3#" />
                     <input type="hidden" name="t4" value="#t4#" />

<input type="hidden" name="pgdir" value="#pgdir#" />

<input type="hidden" name="details_recid" value="#details_recid#" />

<input type="hidden" name="pgid" value="#pgid#" />
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

          <cfif #isdefined('dbugz')#>  <BR>
              <cfoutput>fname: #RPGUpdate.fname# update_yn: #RPGUpdate.update_yn#</cfoutput></cfif>

            <cfif #RPGUpdate.update_yn# is "Y">

                <cfquery result="result" name="FindValue" >
                    Select #RPGUpdate.fname# as fvalue
                    FROM #rpg_compTable#
                    Where #Fid# = #recid#
                </cfquery>

                <cfif #isdefined('dbug')#><cfoutput> - updatetype: #RPGUpdate.updatetype#</cfoutput></cfif>

<cfif #RPGUpdate.updatetype# is "input">

                    <cfoutput>
                        <div class="form-group col-md-12">
                            <label for="#RPGUpdate.fname#">#RPGUpdate.updatename#</label>
                            <input class="form-control" type="text" id="#RPGUpdate.fname#" name="new_#RPGUpdate.fname#" value="#FindValue.fvalue#" <cfif #RPGUpdate.required_yn# is "Y" >
required
                </cfif> placeholder="#RPGUpdate.updatename#">

                <div class="invalid-feedback">
                    Please enter a #RPGUpdate.updatename#.
                </div>
                </div>
                </cfoutput>

<cfelseif #RPGUpdate.updatetype# is "number">

                    <cfoutput>
                        <div class="form-group col-md-6">
                            <label for="#RPGUpdate.fname#">#RPGUpdate.updatename# (#RPGUpdate.num_min#-#RPGUpdate.num_max#</label>
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
       data-bts-button-up-class="btn btn-secondary"
        />
                            
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
required
            </cfif> placeholder="#RPGUpdate.updatename#">

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

                        <cfset datevalue="#dateformat('#findvalue.fvalue#','YYYY-MM-DD')#" />

                        <div class="form-group col-md-6">
                            <label for="#RPGUpdate.fname#">#RPGUpdate.updatename#</label>
                            <input class="form-control" id="#RPGUpdate.fname#" name="new_#RPGUpdate.fname#" value="#datevalue#" type="date" />

                            <div class="invalid-feedback">
                                Please choose a #RPGUpdate.updatename#.
                            </div>

</div>

                    </cfoutput>

<cfelseif #RPGUpdate.updatetype# is "select_id">
                        
                <cfquery result="result" name="FindValue" >
                    Select #RPGUpdate.fname# as fvalue
                    FROM #rpg_compTable#
                    Where #Fid# = #recid#
                </cfquery>

<cfquery result="result" name="selects" >
                            select #rpgupdate.fname# as value, recordname as text from #RPgupdate.tableSelect# order by recordname
                        </cfquery>
                        
                        <cfoutput>
                            <div class="form-group col-md-6">
                                <label for="#RPGUpdate.fname#">#RPGUpdate.updatename#</label>
                                <select class="form-control" name="new_#RPGUpdate.fname#" id="#RPGUpdate.fname#">

                        </cfoutput>

                        <cfloop query="selects">
                            <cfoutput>
                                <option value="#selects.value#" <cfif #selects.value# is "#FindValue.fvalue#"> selected </cfif> >

#selects.text#</option>

                            </cfoutput>
                        </cfloop>
                        </select>

                        <div class="invalid-feedback">
                            Please select a <cfoutput>#RPGUpdate.updatename#</cfoutput>.
                        </div>

                        </div>

<cfelseif #RPGUpdate.updatetype# is "select_distinct">
                        
                <cfquery result="result" name="FindValue" >
                    Select #RPGUpdate.fname# as fvalue
                    FROM #rpg_compTable#
                    Where #Fid# = #recid#
                </cfquery>
                        
                        <cfoutput>#rpgupdate.tableselect#</cfoutput>

                        <cfquery result="result" name="selects" >
                            select #rpgupdate.fname# as value, recordname as text from #RPgupdate.tableSelect# order by recordname
                        </cfquery>
                        
                        <cfoutput>
                            <div class="form-group  col-md-6">
                                <label for="#RPGUpdate.fname#">#RPGUpdate.updatename#</label>
                                <select class="form-control" name="new_#RPGUpdate.fname#" id="#RPGUpdate.fname#">

                        </cfoutput>

                        <cfloop query="selects">
                            <cfoutput>
                                <option value="#selects.value#" <cfif #selects.value# is "#FindValue.fvalue#"> selected </cfif> >

#selects.text#</option>

                            </cfoutput>
                        </cfloop>
                        </select>

                        <div class="invalid-feedback">
                            Please select a <cfoutput>#RPGUpdate.updatename#</cfoutput>.
                        </div>

                        </div>

<cfelseif #RPGUpdate.updatetype# is "select_fieldvalue">
             
                     <cfquery result="result" name="FindValue" >
                    Select #RPGUpdate.fname# as fvalue
                    FROM #rpg_compTable#
                    Where #Fid# = #recid#
                </cfquery>

<cfquery result="result" name="selects" >
                            select fieldvalue as value, fieldtext as text from #RPgupdate.tableSelect# order by fieldtext
                        </cfquery>
                        <cfoutput>
                            <div class="form-group col-md-6">
                                <label for="#RPGUpdate.fname#">#RPGUpdate.updatename#</label>
                                <select class="form-control" name="new_#RPGUpdate.fname#" id="#RPGUpdate.fname#">

                        </cfoutput>

                        <cfloop query="selects">
                            <cfoutput>
                                <option value="#selects.value#" <cfif #selects.value# is "#FindValue.fvalue#"> selected </cfif> >

#selects.text#</option>

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

                                <cfquery result="result" name="selects" >
                                    select recordname as value, recordname as text from #RPgupdate.tableSelect# order by recordname
                                </cfquery>
                                <cfoutput>
                                    <div class="form-group col-md-6">
                                        <label for="#RPGUpdate.fname#">#RPGUpdate.updatename#</label>
                                        <select class="form-control" name="new_#RPGUpdate.fname#" id="#RPGUpdate.fname#">

                                </cfoutput>

                                <cfloop query="selects">
                                    <cfoutput>
                                        <option value="#selects.value#" <cfif #selects.value# is ""> selected </cfif> >

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

<div class="form-group text-center  col-md-12">
            <button class="btn btn-xs btn-primary waves-effect mb-2 waves-light" style="background-color: #406e8e; border: #406e8e;"  type="submit">Update</button>
        </div>

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
