<!--- /include/myteam_pane.cfm --->
<cfinclude template="/include/qry/getMyTeam.cfm" />

<link href="https://cdn.materialdesignicons.com/6.5.95/css/materialdesignicons.min.css" rel="stylesheet">

<h4>My Team</h4>

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
  <div class="col-12 col-md-6 mb-2">
    <p class="fw-semibold">Or select an existing relationship:</p>
    <form class="sel_client" action="/app/myaccount/?new_pgid=122" method="POST">
      <input type="hidden" name="ctaction" value="addmember" />
      <div class="input-group">
        <input type="text" 
               class="form-control" 
               required="required" 
               placeholder="Search..." 
               name="topsearch_myteam" 
               id="autocomplete2" 
               autocomplete="off" />
        <button id="select_contact" 
                type="submit" 
                class="btn btn-xs btn-primary waves-effect waves-light"
                style="background-color: #406e8e; border: #406e8e;">
          <i class="fe-plus"></i> Select
        </button>
      </div>
    </form>
  </div>
</div>

<!--- Card Grid Container (left-aligned) --->
<div class="container">
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

        <!--- This style was in original code (for ribbon-straight) --->
        <style>
          .ribbon-straight {
            bottom: 44px; /* Moves up slightly to remove extra space */
          }
        </style>

        <!--- Finally, include the actual card display template --->
        <cfinclude template="/include/card.cfm" />

      </div> <!--- End .col --->
    </cfloop>
  </div> <!--- End .row --->
</div> <!--- End .container --->

<!--- Team Share Section with extra top margin for spacing --->
<div class="mt-5">
  <h4>Team Share</h4>
  <cfoutput>
    <p>
      You can share with your team using the team share link:
      <strong>
        <a href="https://#host#.theactorsoffice.com/share/?uid=#uid#" 
           target="U"
           title="View Teamshare">
          https://#host#.theactorsoffice.com/share/?uid=#uid#
        </a>
      </strong>
      <br>
      If you click on the button you will see your report.
    </p>
  </cfoutput>
</div>

<!--- JavaScript for deleting a team member via fetch() --->
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
</script>
