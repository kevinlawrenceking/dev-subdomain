<cfset dbug="N" />

<cfparam name="focusid" default="" />

<!--- Include necessary scripts and templates --->
<script src="/app/assets/js/selectize.min.js"></script>
<cfinclude template="/include/qry/audition.cfm" />

<cfinclude template="/include/qry/essence_sel_470_1.cfm" />
<cfinclude template="/include/qry/audroletypes_sel.cfm" />
<cfinclude template="/include/qry/myteam_499_1.cfm" />
<cfinclude template="/include/qry/auddialects_user_sel_358_1.cfm" />
<cfinclude template="/include/qry/audsources_sel_499_2.cfm" />
<script src="/app/assets/js/jquery.chained.js"></script>

<p>Enter the information below and press the update button to continue.</p>

<!--- Form for updating role information --->
<form action="/include/roleupdateform2.cfm" method="post" class="parsley-examples" name="event-form" id="form-event" data-parsley-excluded="input[type=button], input[type=submit], input[type=reset], input[type=hidden], [disabled], :hidden" data-parsley-trigger="keyup" data-parsley-validate>
    <cfoutput>
        <input type="hidden" name="audprojectid" value="#audprojectid#" />
        <input type="hidden" name="new_catid" value="#new_audcatid#" />
        <input type="hidden" name="new_audroleid" value="#audroleid#" />
        <input type="hidden" name="secid" value="176" />
        <input type="hidden" name="userid" value="#userid#" />
        <div class="row" />
        
        <div class="form-group col-md-6 col-sm-12">
            <label for="new_audrolename">Role Name <span class="text-danger">*</span></label>
            <input class="form-control" type="text" id="new_audrolename" autocomplete="off" required data-parsley-required data-parsley-error-message="Role Name is required" name="new_audrolename" value="#roledetails.audrolename#" placeholder="Role Name" />
        </div>
    </cfoutput>

    <div class="form-group col-md-6 col-sm-12">
        <!--- Check if category ID is 5 and set role type accordingly --->
        <cfif #new_audcatid# IS "5">
            <input type="hidden" name="new_audroletypeid" value="33" />
        <cfelse>
            <label for="new_audroletypeid">Role Type <span class="text-danger">*</span></label>
            <select id="new_audroletypeid" name="new_audroletypeid" class="form-control" data-parsley-required data-parsley-error-message="Role Type is required">
                <option value="">--</option>
                <cfoutput query="audroletypes_sel">
                    <cfif #audroletypes_sel.id# is "#roledetails.audroletypeid#">
                        <option value="#audroletypes_sel.id#" selected>#audroletypes_sel.name#</option>
                    <cfelse>
                        <option value="#audroletypes_sel.id#">#audroletypes_sel.name#</option>
                    </cfif>
                </cfoutput>
            </select>
        </cfif>
    </div>

    <cfoutput>
        <div class="form-group col-md-12">
            <label for="projDescription">Character Description </label>
            <textarea class="form-control" type="text" id="new_projcharDescription" name="new_charDescription" placeholder="Character Description  ">#roledetails.charDescription#</textarea>
            <div class="invalid-feedback">
                Please enter a Character Description
            </div>
        </div>
    </cfoutput>

<!--- Check if there are dialects available for the user --->
<cfif #auddialects_user_sel.recordcount# is "0">
    <cfoutput>
        <input type="hidden" name="new_auddialectid" value="#roledetails.auddialectid#" />
    </cfoutput>
<cfelse>
    <div class="form-group col-md-6">
        <label for="new_auddialectid">Dialect</label>
        <select 
            class="form-control" 
            name="new_auddialectid" 
            id="new_auddialectid" 
            onchange="
                const customDialectDiv = document.getElementById('CustomDialects');
                const customDialectInput = document.getElementById('CustomDialect');
                if (this.value === 'CustomDialect') {
                    customDialectDiv.style.display = 'block';
                    customDialectInput.required = true;
                } else {
                    customDialectDiv.style.display = 'none';
                    customDialectInput.required = false;
                }
            "
        >
            <option value="">--</option>
            <option value="CustomDialect">***ADD CUSTOM</option>
            <cfoutput query="auddialects_user_sel">
                <cfif #roledetails.auddialectid# is "#auddialects_user_sel.id#">
                    <option value="#auddialects_user_sel.id#" Selected data-chained="#auddialects_user_sel.audcatid#">
                        #auddialects_user_sel.name#
                    </option>
                <cfelse>
                    <option value="#auddialects_user_sel.id#" data-chained="#auddialects_user_sel.audcatid#">
                        #auddialects_user_sel.name#
                    </option>
                </cfif>
            </cfoutput>
        </select>
        <div class="invalid-feedback">
            Please select a Dialect.
        </div>
    </div>
    
    <div class="form-group col-md-6" id="CustomDialects" style="display:none;">
        <label for="CustomDialect">Custom Dialect</label>
        <input 
            class="form-control" 
            type="text" 
            id="CustomDialect" 
            name="CustomDialect" 
            value="" 
            placeholder="Enter a Custom Dialect" 
        />
    </div>
</cfif>


    <style>
    <cfif roledetails.audsourceid neq 1 >
  #hidden_div{
    display: none
  }
  </cfif>

      <cfif roledetails.audsourceid neq 2 >
  #hidden_divss{
    display: none
  }
  </cfif>

      <cfif roledetails.audsourceid neq 3 >
  #hidden_divs{
    display: none 
  }
  </cfif>

      <cfif roledetails.audsourceid neq 4 >
  #hidden_divx {
    display: none
  }
  </cfif>


   <cfif roledetails.audsourceid eq 1 >
  #hidden_div{
    display: block
  }
  </cfif>

      <cfif roledetails.audsourceid eq 2 >
  #hidden_divss{
    display: block
  }
  </cfif>

      <cfif roledetails.audsourceid eq 3 >
  #hidden_divs{
    display: block 
  }
  </cfif>

      <cfif roledetails.audsourceid eq 4 >
  #hidden_divx {
    display: block
  }
  </cfif>


</style>

 <script>
document.addEventListener("DOMContentLoaded", function () {
    const audSourceId = "<cfoutput>#roledetails.audsourceid#</cfoutput>";

    // Logic to show only the div that corresponds to the audSourceId
    if (audSourceId === "1") {
        document.getElementById("hidden_div").style.display = "block";
    } else if (audSourceId === "2") {
        document.getElementById("hidden_divss").style.display = "block";
    } else if (audSourceId === "3") {
        document.getElementById("hidden_divs").style.display = "block";
    } else if (audSourceId === "4") {
        document.getElementById("hidden_divx").style.display = "block";
    }
});

</script>

<div class="form-group col-md-6">
        <label for="new_audsourceid">Source </label>
        <select class="form-control" name="new_audsourceid" id="new_audsourceid" onChange="showDivx('hidden_divx', this);showDiv('hidden_div', this);showDivs('hidden_divs', this);showDivss('hidden_divss', this);requiredDiv('require_div', this);">
            <option value="">--</option>
            <cfoutput query="audsources_sel">
                <cfif #roledetails.audsourceid# is "#audsources_sel.id#">
                    <option value="#audsources_sel.id#" selected>#audsources_sel.name#</option>
                <cfelse>
                    <option value="#audsources_sel.id#">#audsources_sel.name#</option>
                </cfif>
            </cfoutput>
        </select>
        <div class="invalid-feedback">
            Please select a Source.
        </div>
    </div>

    <div id="hidden_divx" class="form-group col-md-12">
        <div class="col-md-12">
            <cfinclude template="/include/qry/opencalls_286_1.cfm" />
            <div class="form-group">
                <label for="select-opencall">Click in the box to select an open call option OR type a new one:</label>
                <select id="select-opencall" name="new_opencallname" class="demo-default selectize-close-btn w-100" placeholder="Select the option...">
                    <option value="">Select an open call option...</option>
                    <cfloop query="opencalls">
                        <cfif #roledetails.opencallid# is "">
                            <cfset new_opencallid=0 />
                        <cfelse>
                            <cfset new_opencallid=roledetails.opencallid />
                        </cfif>
                        <cfinclude template="/include/qry/findc_286_2.cfm" />
                        <cfif #opencalls.opencallid# is "#roledetails.opencallid#">
                            <cfset new_selectd="selected" />
                        <cfelse>
                            <cfset new_selectd="" />
                        </cfif>
                        <cfoutput>
                            <option value="#opencalls.opencallname#" #new_selectd#>#opencalls.opencallname#</option>
                        </cfoutput>
                    </cfloop>
                </select>
            </div>

            <script>
                $("#select-opencall").selectize({
                    persist: !1,
                    createOnBlur: !0,
                    create: !0,
                    maxItems: 1,
                    plugins: ["remove-button"],
                    delimiter: ",",
                    persist: false,
                    create: function(input) {
                        return {
                            value: input,
                            text: input,
                        };
                    },
                });
            </script>
        </div>
    </div>

    <div id="hidden_div" class="form-group col-md-12">
        <label for="new_contactid">Select referral source from your team </label>
        <select id="new_contactid" class="form-control" name="new_contactid" <cfif #roledetails.audsourceid# is "1">required="true"<cfelse>required="false"</cfif> >
            <option value="">--</option>
            <cfoutput query="myteam">
                <option value="#myteam.contactid#" <cfif #myteam.contactid# is "#roledetails.contactid#"> Selected </cfif> >#myteam.contactname#</option>
            </cfoutput>
        </select>
    </div>

    <div id="hidden_divs" class="form-group col-md-12">
        <div class="col-md-12">
            <cfinclude template="/include/qry/referrals_286_3.cfm" />
            <div class="form-group">
                <label for="select-tag">Click in the box to select a Referral Source OR type a new one:</label>
                <select id="select-referral" name="referral" class="demo-default selectize-close-btn w-100" placeholder="Select the referral...">
                    <option value="">Select a referral...</option>
                    <cfloop query="referrals">
                        <cfif #roledetails.contactid# is "">
                            <cfset role_contactid=0 />
                        <cfelse>
                            <cfset role_contactid=roledetails.contactid />
                        </cfif>
                        <cfinclude template="/include/qry/findc_286_4.cfm" />
                        <cfif #referrals.contactid# is "#roledetails.contactid#">
                            <cfset new_selectc="selected" />
                        <cfelse>
                            <cfset new_selectc="" />
                        </cfif>
                        <cfoutput>
                            <option value="#referrals.recordname#" #new_selectc#>#referrals.recordname#</option>
                        </cfoutput>
                    </cfloop>
                </select>
            </div>

            <script>
                $("#select-referral").selectize({
                    persist: !1,
                    createOnBlur: !0,
                    create: !0,
                    maxItems: 1,
                    plugins: ["remove-button"],
                    delimiter: ",",
                    persist: false,
                    create: function(input) {
                        return {
                            value: input,
                            text: input,
                        };
                    },
                });
            </script>
        </div>
    </div>

    <div id="hidden_divss" class="form-group col-md-12">
        <div class="col-md-12">
            <cfinclude template="/include/qry/subsites_286_5.cfm" />
            <div class="form-group">
                <label for="select-submitsitename">Click in the box to select a Submission Site OR type a new one:</label>
                <select id="select-submitsitename" name="new_submitsitename" class="demo-default selectize-close-btn w-100" placeholder="Select the site...">
                    <option value="">Select the site...</option>
                    <cfloop query="subsites">
                        <cfif "#subsites.submitsiteid#" is "#roledetails.submitsiteid#">
                            <Cfset new_selectd="selected" />
                        <cfelse>
                            <Cfset new_selectd="" />
                        </cfif>
                        <cfoutput>
                            <option value="#subsites.submitsitename#" #new_selectd#>#subsites.submitsitename#</option>
                        </cfoutput>
                    </cfloop>
                </select>
            </div>

            <script>
                $("#select-submitsitename").selectize({
                    persist: !1,
                    createOnBlur: !0,
                    create: !0,
                    maxItems: 1,
                    plugins: ["remove-button"],
                    delimiter: ",",
                    persist: false,
                    create: function(input) {
                        return {
                            value: input,
                            text: input,
                        };
                    },
                });
            </script>
        </div>
    </div>

    <div class="col-md-12">
        <cfinclude template="/include/qry/ranges_286_6.cfm" />
        <div class="form-group mb-3">
            <label for="select-tag">Age Range:</label>
            <select id="select-age" name="rangename" multiple class="demo-default selectize-close-btn w-100" placeholder="Select an age range...">
                <option value="">Select an age range...</option>
                <cfloop query="ranges">
                    <cfset new_rangeid=ranges.rangeid />
                    <cfinclude template="/include/qry/findt_286_7.cfm" />
                    <cfif #findt.recordcount# is "1">
                        <cfset new_select="selected" />
                    <cfelse>
                        <cfset new_select="" />
                    </cfif>
                    <cfoutput>
                        <option value="#ranges.rangeid#" #new_select#>#ranges.rangename#</option>
                    </cfoutput>
                </cfloop>
            </select>
        </div>

        <script>
            function showDiv(divId, element) {
                document.getElementById(divId).style.display = element.value == 1 ? 'block' : 'none';
            }
        </script>

        <script>
            function showDivx(divId, element) {
                document.getElementById(divId).style.display = element.value == 4 ? 'block' : 'none';
            }
        </script>

        <script>
            function requireDiv(require_div, element) {
                document.getElementById(require_div).style.display = element.value == 1 ? 'required' : 'true';
            }
        </script>

        <script>
            function showDivss(divId, element) {
                document.getElementById(divId).style.display = element.value == 2 ? 'block' : 'none';
            }
        </script>

        <script>
            function showDivs(divId, element) {
                document.getElementById(divId).style.display = element.value == 3 ? 'block' : 'none';
            }
        </script>

        <script>
            function showDivsss(divId, element) {
                document.getElementById(divId).style.display = element.value == 1 ? 'block' : 'none';
            }
        </script>

        <script>
            $("#select-age").selectize({
                persist: !1,
                createOnBlur: !0,
                create: !0,
                plugins: ["remove-button"],
                delimiter: ",",
                persist: false,
                create: false
            });
        </script>
    </div>

    <cfif #projectDetails.audcatid# is "5">
        <div class="col-md-12">
            <cfinclude template="/include/qry/vocals_286_8.cfm" />
            <div class="form-group">
                <label for="select-tag">Click in the box to select a Vocal Quality OR type a new one:</label>
                <select id="select-vocal" name="vocaltype" multiple class="demo-default selectize-close-btn w-100" placeholder="Select a vocal type...">
                    <option value="">Click in the box to select a V OR type a new one</option>
                    <cfloop query="vocals">
                        <cfset new_vocaltypeid=vocals.vocaltypeid />
                        <cfinclude template="/include/qry/findt_286_9.cfm" />
                        <cfif #findt.recordcount# is "1">
                            <cfset new_select="selected" />
                        <cfelse>
                            <cfset new_select="" />
                        </cfif>
                        <cfoutput>
                            <option value="#vocals.vocaltypeid#" #new_select#>#vocals.vocaltype#</option>
                        </cfoutput>
                    </cfloop>
                </select>
            </div>

      <script>
    $("#select-vocal").selectize({
        persist: false,
        createOnBlur: false,
        create: false, // Prevents creation of new options
        plugins: ["remove-button"],
        delimiter: ","
    });
</script>
        </div>
    </cfif>

    <div class="col-md-12">
        <cfinclude template="/include/qry/essences_286_10.cfm" />
        <div class="form-group">
            <label for="select-tag">Click in the box to select an Essence OR type a new one:</label>
            <select id="select-essence" name="essence" multiple class="demo-default selectize-close-btn w-100" placeholder="Select an essence...">
                <option value="">Select an essence...</option>
                <cfloop query="essences">
                    <cfinclude template="/include/qry/findg_286_11.cfm" />
                    <cfif #findg.recordcount# is "1">
                        <cfset new_select="selected" />
                    <cfelse>
                        <cfset new_select="" />
                    </cfif>
                    <cfoutput>
                        <option value="#essences.essencename#" #new_select#>#essences.essencename#</option>
                    </cfoutput>
                </cfloop>
            </select>
        </div>

        <script>
            $("#select-essence").selectize({
                persist: !1,
                createOnBlur: !0,
                create: !0,
                plugins: ["remove-button"],
                delimiter: ",",
                persist: false,
                create: function(input) {
                    return {
                        value: input,
                        text: input,
                    };
                },
            });
        </script>
    </div>
    <cfinclude template="/include/qry/findit_286_12.cfm" />
    <Cfset new_subcatid = projectDetails.audsubcatid />

    <cfif #int(findit.recordcount)# is not "0">
        <cfif #new_audcatid# is not "5" or #new_audcatid# is "5" and #new_subcatid# is "34" >
            <div class="col-md-12">
                <cfinclude template="/include/qry/genres_286_13.cfm" />
                <div class="form-group">
                    <label for="select-tag">Click in the box to select a Genre OR type a new one:</label>
                    <select id="select-genre" name="Genre" multiple class="demo-default selectize-close-btn w-100" placeholder="Select a genre...">
                        <option value="">Select a genre...</option>
                        <cfloop query="genres">
                            <cfinclude template="/include/qry/findge_286_14.cfm" />
                            <cfif #findge.recordcount# is "1">
                                <cfset new_select_genre="selected" />
                            <cfelse>
                                <cfset new_select_genre="" />
                            </cfif>
                            <cfoutput>
                                <option value="#genres.audgenre#" #new_select_genre#>#genres.audgenre#</option>
                            </cfoutput>
                        </cfloop>
                    </select>
                </div>

                <script>
                    $("#select-genre").selectize({
                        persist: !1,
                        createOnBlur: !0,
                        plugins: ["remove-button"],
                        delimiter: ",",
                        persist: false,
                        create: true
                    });
                </script>
            </div>
        <cfelse>
            <input type="hidden" name="" value="" />
        </cfif>
    </cfif>

    <div class="form-group text-center col-md-12">
        <button class="btn btn-xs btn-primary waves-effect mb-2 waves-light" style="background-color: #406e8e; border: #406e8e;" type="submit">Update</button>
    </div>
</form>

<script src="/app/assets/js/libs/parsleyjs/parsley.min.js"></script>
