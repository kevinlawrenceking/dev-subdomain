<!--- This ColdFusion page handles the addition of audition relationships and displays existing contacts with their details. --->
<cfparam name="dbug" default="N" />
<cfparam name="audprojectid" default="0" />

<script>
    $(document).ready(function() {
        $("#remoteAddContactAud").on("show.bs.modal", function(event) {
            <!--- Load the modal content for adding a contact --->
            $(this).find(".modal-body").load("<cfoutput>/include/remoteAddContactAud.cfm?userid=#userid#&audprojectid=#audprojectid#&src=audition&tagtypes=all</cfoutput>");
        });
    });
</script>

<cfset modalid="remoteAddContactAud" />

<cfset modaltitle="Add Contact" />

<cfinclude template="/include/modal.cfm" />

<cfinclude template="/include/qry/getContactsByAudProject.cfm" />

<cfinclude template="/include/qry/audcontacts_sel_349_2.cfm" />

<h4>Audition Relationships</h4>

<!--- Single row with two columns: “Add New Person” on the left, “Select Existing Relationship” on the right --->
<div class="row mb-3">
  <!--- Add New Person Column --->
  <div class="col-12 col-md-6 mb-2">
    <p class="fw-semibold">Add a new relationship to your audition:</p>
     <a href="remoteAddContact.cfm?src=account" 
     data-bs-remote="true" data-bs-toggle="modal" 
     data-bs-target="#remoteAddContactAud">

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
    <form class="sel_client" action="/app/audition/?secid=175" method="POST">
       <cfoutput>  
        <input type="hidden" name="ctaction" value="addmember" />
        <input type="hidden" name="audprojectid" value="#audprojectid#" />
    </cfoutput>
      <div class="input-group">
         <select class="form-control" name="autocomplete_aud" id="autocomplete_audx">
                    <option value="">Select Contact...</option>
                    <!--- Loop through the audcontacts query to populate the select list --->
                    <cfloop query="audcontacts_sel">
                        <cfoutput>
                            <option value="#contactname#">#contactname#</option>
                        </cfoutput>
                    </cfloop>
                </select>
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






    <!--- Check if there are any events without booking --->
    <cfif events_nobooking.recordcount gt 0>
        <cfset events_list_nobooking = valuelist(events_nobooking.eventid) />
    <cfelse>
        <cfset events_list_nobooking = 0 />
    </cfif>
    <cfoutput>
        <input type="hidden" name="events_list_nobooking" value="#events_list_nobooking#" />
    </cfoutput>
</form>

<div class="container">
           <div class="row tao-card-row row-cols-1 row-cols-sm-2 row-cols-md-2 row-cols-lg-2 row-cols-xl-3 g-3">
        <!--- Loop through the audcontacts to display each contact's details --->
        <cfloop query="audcontacts">
            <cfinclude template="/include/qry/mytags_48_1.cfm" />
            <cfinclude template="/include/qry/Findphone_48_2.cfm" />
            <cfset new_phone = Findphone.phone />
            <cfinclude template="/include/qry/Findemail_48_3.cfm" />
            <cfset new_email = Findemail.email />



 <div class="col" id="<cfoutput>card-#audcontacts.contactid#</cfoutput>">
<Cfoutput>
    <!--- If there's an avatar file, use it; otherwise use defaultAvatarUrl --->
        <cfif isImageFile("#session.userContactsPath#/#audcontacts.contactid#/avatar.jpg")>
          <cfset card_image = session.userContactsUrl & "/" & audcontacts.contactid & "/avatar.jpg?ver=#rand()#" />
        <cfelse>
          <cfset card_image = application.defaultAvatarUrl />
        </cfif>

</cfoutput>

        <!--- All the variable assignments that card.cfm depends on --->
        <cfset aud_cat_icon           = "" />
        <cfset card_view_icon_yn      = "Y" />
        <cfset card_avatar            = "Yes" />
        <cfset card_badge_yn          = "Y" />
        <cfset card_casting           = "" />
        <cfset card_company           = "" />
        <cfset card_delete            = "" />
        <cfset card_delete_msg        = "" />
        <cfset card_remove            = "/app/audition/?audprojectid=" & audprojectid & "&ctaction=deleteContact&amp;deletecontactid=" & audcontacts.contactid & "&secid=175" />
        <cfset card_remove_msg        = "Are you sure you want to remove this person from this audition?" />
        <cfset card_remove_value      = "'" & audcontacts.contactid & "','" & audprojectid & "'" />
        <cfset card_details           = "/app/contact/?contactid=" & audcontacts.contactid /> 
        <cfset card_email             = new_email />
        <cfset card_footer_text       = "" />
        <cfset card_footer_type       = "social" />
        <cfset card_footer_yn         = "Y" />
        <cfset card_header_text       = audcontacts.contactname  />
        <cfset card_name              = "" />
        <cfset card_header_yn         = "Y" />
        <cfset card_icon              = "" />
        <cfset card_icon_yn           = "Y" />
        <cfset card_id                = audcontacts.contactid />
        <cfset card_image_type        = "avatar" />
        <cfset card_image_yn          = "Y" />
        <cfset card_image             = "" />
        <cfset card_phone             = new_phone />
        <cfset card_reminder          = "" />
        <cfset card_ribbon1           = "" />
        <cfset card_ribbon2           = "" />
        <cfset card_ribbon_straight   = "" />
        <cfset card_social_yn         = "Y" />
        <cfset card_source            = "" />
        <cfset card_subtitle          = "" />
        <cfset card_title             = audcontacts.card_title />
        <cfset card_top_ribbon        = "" />
        <cfset namecolor              = "medium" />
        <cfset ribbon_icon            = "" />
        <cfset currentid              = audcontacts.contactid />



      <!--- Optionally retrieve social icons or reminders for this contact --->
        <cfinclude template="/include/qry/getSocialIcons.cfm"/>
        <cfinclude template="/include/qry/getRemindersByRelationship.cfm"/>

    <cfif isImageFile("#session.userContactsPath#/#audcontacts.contactid#/avatar.jpg")>
          <cfset card_image = session.userContactsUrl & "/" & audcontacts.contactid & "/avatar.jpg?ver=#rand()#" />
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
    </div>

    <p>&nbsp;</p><!--- end card-box --->
</div><br>


<!--- JavaScript for deleting a contact via fetch() --->
<script>
function confirmRemove(contactId, audProjectId) {
    if (confirm("Are you sure you want to remove this contact from your project?")) {
        fetch('/include/delete_audcontact.cfm', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/x-www-form-urlencoded'
            },
            body: 'contactid=' + encodeURIComponent(contactId) + 
                  '&audprojectid=' + encodeURIComponent(audProjectId)
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
