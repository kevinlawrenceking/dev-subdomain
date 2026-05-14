<!--- Audition Submission Sites sub-pane: per-user audition submission
      platforms. Extracted from prefs_pane.cfm as part of the My Account
      tab consolidation. No content changes. --->
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
                            <div class="site-actions">
                                <i class="mdi mdi-square-edit-outline edit-indicator"></i>
                            </div>
                        </div>
                        <div class="site-card-body">
                            <h6 class="site-name">#subsites.submitsitename#</h6>
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
