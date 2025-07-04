
<h4>Preferences</h4>

<h5>
    Default Settings 
    <a title="Edit" href="" title="Update calendar settings" data-bs-toggle="modal" data-bs-target="#updatecal">
        <i class="mdi mdi-square-edit-outline"></i>
    </a>
</h5>

<div class="row" style="margin: auto;">
    <div class="col-md-2 p-2">
        <strong>Start time:</strong>
    </div>
    <div class="col-md-10 p-2">
        <cfoutput>
            <a href="" title="Start time for your Calendar Day" data-bs-toggle="modal" data-bs-target="##updatecal">#calstarttime#</a>
        </cfoutput>
    </div>

    <div class="col-md-2 p-2">
        <strong>End time:</strong>
    </div>
    <div class="col-md-10 p-2">
        <cfoutput>
            <a href="" title="End time for your Calendar Day" data-bs-toggle="modal" data-bs-target="##updatecal">#calendtime#</a>
        </cfoutput>
    </div>
</div>

<div class="row" style="margin: auto;">
    <div class="col-md-2 p-2">
        <strong>Rows Per Page:</strong>
    </div>
    <div class="col-md-10 p-2">
        <cfoutput>
            <a href="" title="Default Rows for Relationships Table" data-bs-toggle="modal" data-bs-target="##updatecal">#defRows#</a>
        </cfoutput>
    </div>

    <div class="col-md-2 p-2">
        <strong>Time Zone:</strong>
    </div>
    <div class="col-md-10 p-2">
        <cfoutput>
            <a href="" title="Default State for your Contacts" data-bs-toggle="modal" data-bs-target="##updatecal">#tzgeneral#</a>
        </cfoutput>
    </div>

    <div class="col-md-2 p-2">
        <strong>Date Format:</strong>
    </div>
    <div class="col-md-10 p-2">
        <cfoutput>
<a href="" title="Date format" data-bs-toggle="modal" data-bs-target="##updatecal">#session.dateformatExample#</a>
        </cfoutput>
    </div>
</div>

<h5>
    My Newsletter
    <a href="" title="Update newsletter settings" data-bs-toggle="modal" data-bs-target="#updatenewsletter">
        <i class="mdi mdi-square-edit-outline"></i>
    </a>
</h5>

<div class="row" style="margin: auto;">
    <div class="col-md-2 p-2">
        <strong>Newsletter?</strong>
    </div>
    <div class="col-md-10 p-2">
        <a href="" title="Update newsletter settings" data-bs-toggle="modal" data-bs-target="#updatenewsletter">
            <cfif nletter_yn is "Y">Yes
            <cfelse>No</cfif>
        </a>
    </div>
</div>
<div class="row" style="margin: auto;">
    <div class="col-md-2 p-2">
        <strong>Newsletter Link</strong>
    </div>
    <div class="col-md-10 p-2">
        <cfif #nletter_yn# is "Y">
            <cfif #nletter_link# is not "">
                <cfif #left('#nletter_link#','4')# is "http">
                    <cfoutput>
                        <cfset new_nletter_link="#nletter_link#" />
                    </cfoutput>
                </cfif>
                <cfif #left('#nletter_link#','4')# is not "http">
                    <cfoutput>
                        <cfset new_nletter_link="http://#nletter_link#" />
                    </cfoutput>
                </cfif>
                <cfoutput>
                    <A HREF="#new_nletter_link#" target="external">#nletter_link#</A>
                </cfoutput>
            </cfif>
            <cfif #nletter_link# is "">
                <i>Please add your newsletter link.</i>
            </cfif>
        </cfif>
    </div>
</div>



<cfinclude template="/include/qry/subsites_189_1.cfm" />
&nbsp;<BR>
<div class="d-flex justify-content-between">
    <div class="float-left">
        <h4>My Submission Sites</h4>
    </div>

    <cfoutput>
        <script>
            $(document).ready(function() {
                $("##remoteaddaudsubmitsite").on("show.bs.modal", function(event) {
                    
                    $(this).find(".modal-body").load("/include/remoteaddaudsubmitsite.cfm?userid=#userid#");
                });
            });
        </script>
    </cfoutput>

    <cfset modalid="remoteaddaudsubmitsite" />
    <cfset modaltitle="Add Submission Site" />
    <cfinclude template="/include/modal.cfm" />

    <div class="float-end">
        <a href="" data-bs-remote="true" data-bs-toggle="modal" 
           data-bs-target="#remoteaddaudsubmitsite" class="btn btn-xs btn-primary waves-effect mb-2 waves-light" 
           style="background-color: #406e8e; border: #406e8e;">
            Add
        </a>
    </div>
</div>

<div class="container mt-3">
    <div class="row row-cols-md-3 row-cols-1 g-3">
        <cfloop query="subsites">

   
                <cfoutput>                         
                    <script>
                        $(document).ready(function() {
                            $("##remoteUpdateaudsubmitsite_#subsites.submitsiteid#").on("show.bs.modal", function(event) {
                                
                                $(this).find(".modal-body").load("/include/remoteUpdateaudsubmitsite.cfm?userid=#userid#&src=account&submitsiteid=#subsites.submitsiteid#");
                            });
                        });
                    </script>

                    <cfset modalid="remoteUpdateaudsubmitsite_#subsites.submitsiteid#" />
                    <cfset modaltitle="Update Submission Site" />
                    <cfinclude template="/include/modal.cfm" />

                                <div class="col">
   
                <A href="" data-bs-toggle="modal" data-bs-target="##remoteUpdateaudsubmitsite_#subsites.submitsiteid#">
                    <div class="tao-card-md shadow-sm border rounded p-3" >
                        <div class="card-body text-center">
                            <h5 class="card-title mb-9" >#subsites.submitsitename#</h5>
              
                        </div>
                    </div>
              

                </a>

            </div>

  </cfoutput>
 
        </cfloop>
 </div>
</div>

<div id="updatenewsletter" class="modal fade" tabindex="-1" role="dialog" aria-labelledby="standard-modalLabel" >

            <div class="modal-dialog">
              <div class="modal-content">
                <div class="modal-header" >
                  <h4 class="modal-title" id="standard-modalLabel">Newsletter Update</h4>
                  <button type="button" class="close" data-bs-dismiss="modal" >

                    <i class="mdi mdi-close-thick"></i>
                  </button>
                </div>
                <div class="modal-body">

                  <form action="/app/myaccount/update_newsletter.cfm" method="post" class="parsley-examples" validate="validate" id="newsletter" data-parsley-excluded="input[type=button], input[type=submit], input[type=reset], input[type=hidden], [disabled], :hidden" data-parsley-trigger="keyup" data-parsley-validate="data-parsley-validate">

                    <cfoutput>
                      <input type="hidden" name="ctaction" value="update_newsletter"/>
                      <input type="hidden" name="t4" value="1"/>

                      <div class="form-group col-md-3">
                        <label for="eventTypeName">Newsletter</label>
                        <select class="form-control" name="new_nletter_yn" id="new_nletter_yn">

                          <option value="N" <cfif #details.nletter_yn# is "N"> Selected </cfif>>No</option>

                          <option value="Y" <cfif #details.nletter_yn# is "Y"> Selected </cfif>>Yes</option>

                        </select>
                        <div class="invalid-feedback">
                          Please select Yes or No.
                        </div>

                      </div>

                      <div class="form-group col-md-12">
                        <label for="userLastName">Newsletter Link<span class="text-danger">*</span>
                        </label>

                        <input class="form-control" type="text" id="new_nletter_link" name="new_nletter_link" value="#details.nletter_link#" placeholder="Enter your newsletter link" /></div>

                        <div class="form-group text-center col-md-12">
                          <button class=" btn btn-primary editable-submit btn-sm waves-effect waves-light" type="submit" style="background-color: ##406e8e; border: ##406e8e;">Update</button>
                        </div>
                      </cfoutput>

                    </form>

                  </div>
                </div>

              </div>
            </div>
