<!--- /incl<!--- Team Actions Section --->
<div class="team-actions-section">
  <div class="row g-3">
    <!--- Add New Person Column --->
    <div class="col-12 col-md-6">
      <div class="action-card add-person-card">
        <div class="action-icon">
          <i class="fas fa-user-plus"></i>
        </div>
        <div class="action-content">
          <h6 class="action-title">Add New Person</h6>
          <p class="action-subtitle">Create a new contact and add them to your team</p>
          <a href="remoteAddContact.cfm?src=account" 
             data-bs-remote="true" 
             data-bs-toggle="modal" 
             data-bs-target="#remoteAddContact"
             class="btn btn-primary btn-action">
            <i class="fas fa-plus me-2"></i>Add New
          </a>
        </div>
      </div>
    </div>cfm --->
<cfinclude template="/include/qry/getMyTeam.cfm" />

<link href="https://cdn.materialdesignicons.com/6.5.95/css/materialdesignicons.min.css" rel="stylesheet">

<div class="team-management-container">
  <div class="team-header">
    <h4 class="team-title">My Team</h4>
    <p class="team-description">Manage your professional team members and relationships</p>
  </div>

<!--- Single row with two columns: “Add New Person” on the left, “Select Existing Relationship” on the right --->
<div class="row mb-3">
  <!--- Add New Person Column --->
  <div class="col-12 col-md-6 mb-2">
    <p class="fw-semibold">Add a new person to your team:</p>
    <a href="remoteAddContact.cfm?src=account" 
       data-bs-remote="true" 
       data-bs-toggle="modal" 
       data-bs-target="#remoteAddContact">
      <button type="button" 
              class="btn btn-sm btn-primary waves-effect waves-light"
              style="background-color: #406e8e; border: #406e8e;">
        Add
      </button>
    </a>
  </div>

    <!--- Select Existing Relationship Column --->
    <div class="col-12 col-md-6">
      <div class="action-card select-person-card">
        <div class="action-icon">
          <i class="fas fa-users"></i>
        </div>
        <div class="action-content">
          <h6 class="action-title">Add Existing Contact</h6>
          <p class="action-subtitle">Select from your existing relationships</p>
          <form class="sel_client team-search-form" action="/app/myaccount/?new_pgid=122" method="POST">
            <input type="hidden" name="ctaction" value="addmember" />
            <div class="search-input-group">
              <input type="text" 
                     class="form-control search-input" 
                     required="required" 
                     placeholder="Search contacts..." 
                     name="topsearch_myteam" 
                     id="autocomplete2" 
                     autocomplete="off" />
              <button id="select_contact" 
                      type="submit" 
                      class="btn btn-primary btn-select">
                <i class="fas fa-arrow-right"></i>
              </button>
            </div>
          </form>
        </div>
      </div>
    </div>
  </div>
</div>

  <!--- Team Members Grid --->
  <div class="team-members-section">
    <div class="team-members-header">
      <h5 class="section-title">Team Members</h5>
      <p class="section-subtitle">Your current team members and their contact information</p>
    </div>
    
    <div class="team-grid-container">
      <div class="row tao-card-row row-cols-1 row-cols-sm-2 row-cols-md-2 row-cols-lg-2 row-cols-xl-3 g-3">
    
    <!--- Loop through the myteam query to display cards --->
    <cfloop query="myteam">
      <!--- Wrap each card in a col, give it a unique ID for removal logic --->
      <div class="col" id="<cfoutput>card-#myteam.contactid#</cfoutput>">

        <!--- All the variable assignments that card.cfm depends on --->
        <cfset aud_cat_icon           = "" />
        <cfset card_view_icon_yn      = "Y" />
        <cfset card_avatar            = "Yes" />
        <cfset card_badge_yn          = "Y" />
        <cfset card_casting           = "" />
        <cfset card_company           = myteam.card_company />
        <cfset card_delete            = "" />
        <cfset card_delete_msg        = "" />
        <cfset card_remove            = "/app/myaccount/?new_pgid=122&ctaction=deleteitem&deletecontactid=" & myteam.contactid />
        <cfset card_remove_msg        = "Are you sure you want to remove this person from your team?" />
        <cfset card_remove_value      = "'" & myteam.contactid & "'" />
        <cfset card_details           = "/app/contact/?contactid=" & myteam.contactid />
        <cfset card_email             = myteam.card_email />
        <cfset card_footer_text       = "Crd footer text" />
        <cfset card_footer_type       = "social" />
        <cfset card_footer_yn         = "Y" />
        <cfset card_header_text       = myteam.card_name  />
        <cfset card_name              = "" />
        <cfset card_header_yn         = "Y" />
        <cfset card_icon              = "" />
        <cfset card_icon_yn           = "Y" />
        <cfset card_id                = myteam.contactid />
        <cfset card_image_type        = "avatar" />
        <cfset card_image_yn          = "Y" />
        <cfset card_image             = "" />
        <cfset card_phone             = myteam.card_phone />
        <cfset card_reminder          = "" />
        <cfset card_ribbon1           = "" />
        <cfset card_ribbon2           = "" />
        <cfset card_ribbon_straight   = "" />
        <cfset card_social_yn         = "Y" />
        <cfset card_source            = "" />
        <cfset card_subtitle          = "" />
        <cfset card_title             = "" />
        <cfset card_top_ribbon        = "" />
        <cfset namecolor              = "medium" />
        <cfset ribbon_icon            = "" />
        <cfset currentid              = myteam.contactid />

        <!--- Optionally retrieve social icons or reminders for this contact --->
        <cfinclude template="/include/qry/getSocialIcons.cfm"/>
        <cfinclude template="/include/qry/getRemindersByRelationship.cfm"/>

        <!--- If there's an avatar file, use it; otherwise use defaultAvatarUrl --->
        <cfif isImageFile("#session.userContactsPath#/#myteam.contactid#/avatar.jpg")>
          <cfset card_image = session.userContactsUrl & "/" & myteam.contactid & "/avatar.jpg?ver=#rand()#" />
        <cfelse>
          <cfset card_image = application.defaultAvatarUrl />
        </cfif>

        <!--- Finally, include the actual card display template --->
        <cfinclude template="/include/card.cfm" />

      </div> <!--- End .col --->
    </cfloop>
      </div> <!--- End .row --->
    </div> <!--- End .team-grid-container --->
  </div> <!--- End .team-members-section --->

  <!--- Team Share Section --->
  <div class="team-share-section">
    <div class="team-share-card">
      <div class="share-icon">
        <i class="fas fa-share-alt"></i>
      </div>
      <div class="share-content">
        <h5 class="share-title">Team Share Link</h5>
        <p class="share-description">Share your team progress and updates with this secure link</p>
        <cfoutput>
          <div class="share-link-container">
            <div class="share-link">
              <a href="https://#host#.theactorsoffice.com/share/?uid=#uid#" 
                 target="_blank"
                 class="team-share-link"
                 title="View Team Share">
                https://#host#.theactorsoffice.com/share/?uid=#uid#
              </a>
            </div>
            <button class="btn btn-outline-primary btn-copy" onclick="copyToClipboard('https://#host#.theactorsoffice.com/share/?uid=#uid#')">
              <i class="fas fa-copy me-2"></i>Copy Link
            </button>
          </div>
          <p class="share-note">Click the link to preview how your team will see your progress report.</p>
        </cfoutput>
      </div>
    </div>
  </div>
</div> <!--- End .team-management-container --->

<!--- JavaScript for deleting a team member via fetch() and copy functionality --->
<script>
function confirmRemove(contactId) {
    if (confirm("Are you sure you want to remove this person from your team?")) {
        fetch('/include/delete_team.cfm', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/x-www-form-urlencoded'
            },
            body: 'contactid=' + encodeURIComponent(contactId)
        })
        .then(response => response.json())
        .then(data => {
            if (data.success) {
                let cardEl = document.getElementById('card-' + contactId);
                if (cardEl) {
                    cardEl.classList.add('removing'); // Start animation
                    setTimeout(() => {
                        cardEl.remove(); // Fully remove after animation
                    }, 300); // Wait for CSS transition to finish
                }
            } else {
                alert("Error: " + data.message);
            }
        })
        .catch(error => console.error('Error:', error));
    }
}

function copyToClipboard(text) {
    navigator.clipboard.writeText(text).then(function() {
        // Create temporary success message
        const btn = event.target.closest('.btn-copy');
        const originalText = btn.innerHTML;
        btn.innerHTML = '<i class="fas fa-check me-2"></i>Copied!';
        btn.classList.remove('btn-outline-primary');
        btn.classList.add('btn-success');
        
        setTimeout(() => {
            btn.innerHTML = originalText;
            btn.classList.remove('btn-success');
            btn.classList.add('btn-outline-primary');
        }, 2000);
    }).catch(function(err) {
        console.error('Could not copy text: ', err);
        alert('Failed to copy link to clipboard');
    });
}
</script>
