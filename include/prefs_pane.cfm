
<link href="https://cdn.materialdesignicons.com/6.5.95/css/materialdesignicons.min.css" rel="stylesheet">

<div class="preferences-container">
    <div class="preferences-header">
        <h4 class="preferences-title">Preferences</h4>
        <p class="preferences-description">Manage your default settings and preferences</p>
    </div>

    <!--- Default Settings Section --->
    <div class="preferences-section">
        <div class="section-header">
            <h5 class="section-title">
                <i class="mdi mdi-cog-outline me-2"></i>Default Settings
            </h5>
            <button class="btn btn-outline-primary btn-sm edit-settings-btn" 
                    title="Update calendar settings" 
                    data-bs-toggle="modal" 
                    data-bs-target="#updatecal">
                <i class="mdi mdi-pencil me-1"></i>Edit Settings
            </button>
        </div>
        
        <div class="settings-grid">
            <div class="setting-item">
                <div class="setting-label">
                    <i class="mdi mdi-clock-start me-2 text-muted"></i>
                    <strong>Start Time</strong>
                </div>
                <div class="setting-value">
                    <cfoutput>
                        <a href="" title="Start time for your Calendar Day" 
                           data-bs-toggle="modal" data-bs-target="##updatecal" 
                           class="setting-link">#calstarttime#</a>
                    </cfoutput>
                </div>
            </div>

            <div class="setting-item">
                <div class="setting-label">
                    <i class="mdi mdi-clock-end me-2 text-muted"></i>
                    <strong>End Time</strong>
                </div>
                <div class="setting-value">
                    <cfoutput>
                        <a href="" title="End time for your Calendar Day" 
                           data-bs-toggle="modal" data-bs-target="##updatecal" 
                           class="setting-link">#calendtime#</a>
                    </cfoutput>
                </div>
            </div>

            <div class="setting-item">
                <div class="setting-label">
                    <i class="mdi mdi-table-row me-2 text-muted"></i>
                    <strong>Rows Per Page</strong>
                </div>
                <div class="setting-value">
                    <cfoutput>
                        <a href="" title="Default Rows for Relationships Table" 
                           data-bs-toggle="modal" data-bs-target="##updatecal" 
                           class="setting-link">#defRows#</a>
                    </cfoutput>
                </div>
            </div>

            <div class="setting-item">
                <div class="setting-label">
                    <i class="mdi mdi-earth me-2 text-muted"></i>
                    <strong>Time Zone</strong>
                </div>
                <div class="setting-value">
                    <cfoutput>
                        <a href="" title="Default State for your Contacts" 
                           data-bs-toggle="modal" data-bs-target="##updatecal" 
                           class="setting-link">#tzgeneral#</a>
                    </cfoutput>
                </div>
            </div>

            <div class="setting-item">
                <div class="setting-label">
                    <i class="mdi mdi-calendar me-2 text-muted"></i>
                    <strong>Date Format</strong>
                </div>
                <div class="setting-value">
                    <cfoutput>
                        <a href="" title="Date format" 
                           data-bs-toggle="modal" data-bs-target="##updatecal" 
                           class="setting-link">#session.dateformatExample#</a>
                    </cfoutput>
                </div>
            </div>
        </div>
    </div>

    <!--- Newsletter Section --->
    <div class="preferences-section">
        <div class="section-header">
            <h5 class="section-title">
                <i class="mdi mdi-email-newsletter me-2"></i>My Newsletter
            </h5>
            <button class="btn btn-outline-primary btn-sm edit-settings-btn" 
                    title="Update newsletter settings" 
                    data-bs-toggle="modal" 
                    data-bs-target="#updatenewsletter">
                <i class="mdi mdi-pencil me-1"></i>Edit Newsletter
            </button>
        </div>
        
        <div class="newsletter-grid">
            <div class="setting-item">
                <div class="setting-label">
                    <i class="mdi mdi-toggle-switch me-2 text-muted"></i>
                    <strong>Newsletter Active</strong>
                </div>
                <div class="setting-value">
                    <a href="" title="Update newsletter settings" 
                       data-bs-toggle="modal" data-bs-target="#updatenewsletter" 
                       class="setting-link">
                        <cfif nletter_yn is "Y">
                            <span class="badge bg-success">Yes</span>
                        <cfelse>
                            <span class="badge bg-secondary">No</span>
                        </cfif>
                    </a>
                </div>
            </div>

            <div class="setting-item">
                <div class="setting-label">
                    <i class="mdi mdi-link-variant me-2 text-muted"></i>
                    <strong>Newsletter Link</strong>
                </div>
                <div class="setting-value">
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
                                <a href="#new_nletter_link#" target="external" class="newsletter-link">
                                    <i class="mdi mdi-open-in-new me-1"></i>#nletter_link#
                                </a>
                            </cfoutput>
                        <cfelse>
                            <span class="text-muted">
                                <i class="mdi mdi-alert-circle me-1"></i>Please add your newsletter link
                            </span>
                        </cfif>
                    <cfelse>
                        <span class="text-muted">
                            <i class="mdi mdi-minus-circle me-1"></i>Newsletter not active
                        </span>
                    </cfif>
                </div>
            </div>
        </div>
    </div>
</div>



<!--- Submission Sites Section --->
<cfinclude template="/include/qry/subsites_189_1.cfm" />

<div class="preferences-section submission-sites-section">
    <div class="section-header">
        <div class="section-title-group">
            <h4 class="section-title">
                <i class="mdi mdi-web me-2"></i>My Submission Sites
            </h4>
            <p class="section-subtitle">Manage your audition submission platforms</p>
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

        <button class="btn btn-primary add-site-btn" 
                data-bs-remote="true" 
                data-bs-toggle="modal" 
                data-bs-target="#remoteaddaudsubmitsite"
                title="Add new submission site">
            <i class="mdi mdi-plus me-2"></i>Add Site
        </button>
    </div>

    <div class="submission-sites-grid">
        <cfif subsites.recordCount GT 0>
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

                    <div class="submission-site-card" 
                         data-bs-toggle="modal" 
                         data-bs-target="##remoteUpdateaudsubmitsite_#subsites.submitsiteid#"
                         title="Click to edit this submission site">
                        <div class="site-card-header">
                            <div class="site-icon">
                                <i class="mdi mdi-web"></i>
                            </div>
                            <div class="site-actions">
                                <i class="mdi mdi-pencil-outline edit-indicator"></i>
                            </div>
                        </div>
                        <div class="site-card-body">
                            <h6 class="site-name">#subsites.submitsitename#</h6>
                            <p class="site-hint">
                                <i class="mdi mdi-cursor-pointer me-1"></i>Click to edit
                            </p>
                        </div>
                    </div>
                </cfoutput>
            </cfloop>
        <cfelse>
            <div class="no-sites-message">
                <div class="empty-state">
                    <i class="mdi mdi-web-plus empty-icon"></i>
                    <h6 class="empty-title">No Submission Sites</h6>
                    <p class="empty-description">Add your first submission site to get started</p>
                    <button class="btn btn-primary" 
                            data-bs-remote="true" 
                            data-bs-toggle="modal" 
                            data-bs-target="#remoteaddaudsubmitsite">
                        <i class="mdi mdi-plus me-2"></i>Add Your First Site
                    </button>
                </div>
            </div>
        </cfif>
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
