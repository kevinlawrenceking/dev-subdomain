<h4>Systems - Customization</h4>

<cfinclude template="/include/qry/mysystems_295_1.cfm" />




<div class="row">

  <div class="col-xl-12">

    <div id="accordion_systems" class="mb-3">

      <cfset y=0>

      <cfparam name="target_id_system" default="0">

      <cfloop query="mysystems">

               <cfinclude template="/include/qry/action_user_295_2.cfm" />
                <cfinclude template="/include/qry/action_user_del_295_3.cfm" />

<cfif #mysystems.systemid# is "#target_id_system#">
          <div class="card mb-1">
            <div class="card-header" id="<cfoutput>heading_system_#mysystems.systemid#</cfoutput>">
              <h5 class="m-0">
                <a class="text-dark" data-bs-toggle="collapse" href="#collapse_system_<cfoutput>#mysystems.systemid#</cfoutput>" aria-expanded="true">

                  <cfoutput>
                    #mysystems.systemname#<span class="badge badge-success badge-pill float-end">
                      #numberformat(action_user.recordcount)#</span>
                  </cfoutput>
                </a>
              </h5>
            </div>

            <div id="collapse_system_<cfoutput>#mysystems.systemid#</cfoutput>" class="collapse show" aria-labelledby="<cfoutput>heading_system_#mysystems.systemid#</cfoutput>" data-bs-parent="#accordion_systems" style="">

            <cfelse>

              <div class="card mb-1">
                <div class="card-header" id="<cfoutput>heading_system_#mysystems.systemid#</cfoutput>">
                  <h5 class="m-0">
                    <a class="text-dark text-dark collapsed" data-bs-toggle="collapse" href="#collapse_system_<cfoutput>#mysystems.systemid#</cfoutput>" aria-expanded="false">

                      <cfoutput>
                        #mysystems.systemname#<span class="badge badge-success badge-pill float-end">
                          #numberformat(action_user.recordcount)#</span>
                      </cfoutput>
                    </a>
                  </h5>
                </div>

                <div id="collapse_system_<cfoutput>#mysystems.systemid#</cfoutput>" class="collapse" aria-labelledby="<cfoutput>heading_system_#mysystems.systemid#</cfoutput>" data-bs-parent="#accordion_systems" style="">

                </cfif>

                <div class="card-body">

                  <p>
                    <cfoutput>
                      #mysystems.systemdescript#</cfoutput>
                  </p>

                  <cfoutput>
                    <A href="/include/restoreaction.cfm?target_id_system=#mysystems.systemid#">
                      <button type="button" class="btn btn-xs btn-primary waves-effect mb-2 waves-light" style="background-color: ##406e8e; border: ##406e8e">
                        Restore to Default</button>
                    </a>
                  </cfoutput>

                  <div class="row">

                    <cfloop query="action_user">


                               <cfoutput>
                            <script>
                                $(document).ready(function() {
                                    $("##updateaction_#action_user.id#").on("show.bs.modal", function(event) {
                                        
                                        $(this).find(".modal-body").load("/include/remoteactionUpdate.cfm?id=#action_user.id#");
                                    });
                                });
                            </script>
                        </cfoutput>

                        <cfoutput>
                            <div id="updateaction_#action_user.id#" class="modal fade" tabindex="-1" aria-labelledby="standard-modalLabel" >

                                <div class="modal-dialog">
                                    <div class="modal-content">
                                        <div class="modal-header" >
                                            <h4 class="modal-title" id="standard-modalLabel">#action_user.systemName# Action Update</h4>
                                            <button type="button" class="close" data-bs-dismiss="modal" >
<i class="mdi mdi-close-thick"></i></button>
                                        </div>
                                        <div class="modal-body"></div>
                                    </div>
                                </div>
                            </div>
                        </cfoutput>


                      <div class="col-md-12">
                        <cfoutput>
                          <h5>
                            <a title="Edit" href="updateactionlink.cfm" data-bs-remote="true" data-bs-toggle="modal" data-bs-target="##updateaction_#action_user.id#">

#action_user.currentrow# - #action_user.actiontitle#

                              <i class="mdi mdi-square-edit-outline"></i>
                            </a>
                          </h5>

                          <p>
                            #action_user.actiondetails#.<BR>
                              <cfif #action_user.actiondaysno# is "0">
                                Starts<strong>
                                  immediately</strong>
                              <cfelse>
                                Starts in<strong>
                                  #action_user.actiondaysno# day<cfif #action_user.actiondaysno# is not "1">s</cfif>
                                </strong>
                              </cfif>
                              <cfif #numberformat(action_user.actiondaysrecurring)# is not "0">
                                , repeating every<strong>
                                  #action_user.actiondaysrecurring# days</strong>
                              </cfif>
                              

                            </p>
                          </div>

                        </Cfoutput>

                      </cfloop>

                    </div>

                    <cfif #action_user_del.recordcount# is not "0">

                      <form action="/app/myaccount/?t7=1&target_id_system=#mysystems.systemid#">
                        <cfoutput>
                      
                          <input type="hidden" name="t7" value="1" />
                            <input type="hidden" name="ctaction" value="includeaction" />
                              <input type="hidden" name="target_id_system" value="#mysystems.systemid#" />
                              </cfoutput>
                              <h5>
                                Restore:
                                <select name="new_id" id="<cfoutput>new_id_system_#mysystems.systemid#</cfoutput>" required="" onchange='this.form.submit()'>
                                  <option value=""></option>
                                  <cfoutput query="action_user_del">
                                    <option value="#action_user_del.id#">
                                      #action_user_del.actiontitle#</option>

                                  </cfoutput>
                                </select>

                              </h5>
                            </form>
                          </cfif>

                        </div>

                      </div>

                    </div>

                  </cfloop>

                </div>

              </div>

            </div>
