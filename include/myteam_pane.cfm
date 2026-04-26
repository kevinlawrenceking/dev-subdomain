<!--- /include/myteam_pane.cfm --->
<!-- tao-myteam-build: 2026-04-21-ajax-v2 -->
<cfinclude template="/include/qry/getMyTeam.cfm" />

<!--- Add-to-Team flow: AJAX POST with X-CSRF-Token header.
     Replaces the form-POST-to-myaccount pattern which was unreliable under CSRF
     (same class of bug the top-bar search hit — see include/autocomplete.cfm:1-6).
     jQuery UI owns $.fn.autocomplete on this page; we capture ui.item.id and send
     the contactid directly so name-collision ambiguity is also gone. --->
<cfoutput>
<script>
$(function() {
    var $input = $("##autocomplete2");
    if (!$input.length || typeof $input.autocomplete !== 'function') return;
    var $form = $input.closest('form.sel_client');
    var taoUserId = '#jsStringFormat(userid)#';
    var selectedContactId = null;

    function addTeamMember(contactid) {
        var csrfMeta = document.querySelector('meta[name="csrf-token"]');
        var csrfToken = csrfMeta ? csrfMeta.getAttribute('content') : '';
        fetch('/ajax/myteam/add.cfm', {
            method: 'POST',
            credentials: 'same-origin',
            headers: {
                'Content-Type': 'application/x-www-form-urlencoded',
                'X-CSRF-Token': csrfToken,
                'X-Requested-With': 'XMLHttpRequest',
                'Accept': 'application/json'
            },
            body: 'contactid=' + encodeURIComponent(contactid)
        })
        .then(function(r) {
            return r.json().then(function(body){ return { ok: r.ok, body: body }; });
        })
        .then(function(res) {
            if (res.ok && res.body && res.body.success) {
                showTeamToast(res.body.message || 'Team member added.', 'success');
                setTimeout(function() {
                    window.location.href = '/app/myaccount/?new_pgid=122&t2=1';
                }, 500);
            } else {
                showTeamToast((res.body && res.body.message) || 'Unable to add team member.', 'error');
            }
        })
        .catch(function() {
            showTeamToast('Network error. Please try again.', 'error');
        });
    }

    $input.autocomplete({
        minLength: 2,
        source: function(request, response) {
            $.ajax({
                url: '/app/autolookup2.cfm',
                dataType: 'json',
                data: { userid: taoUserId, searchTerm: request.term },
                success: function(data) {
                    response($.map((data && data.suggestions) || [], function(item) {
                        return { label: item.value, value: item.value, id: item.id };
                    }));
                },
                error: function() { response([]); }
            });
        },
        select: function(event, ui) {
            $input.val(ui.item.value);
            selectedContactId = ui.item.id;
            addTeamMember(selectedContactId);
            return false;
        },
        change: function(event, ui) {
            if (!ui.item) selectedContactId = null;
        }
    });

    // Button click / Enter fallback: never let the form POST natively.
    $form.on('submit', function(e) {
        e.preventDefault();
        if (selectedContactId) {
            addTeamMember(selectedContactId);
        } else {
            showTeamToast('Please select a contact from the dropdown.', 'info');
        }
    });
});
</script>
</cfoutput>

<link href="https://cdn.materialdesignicons.com/6.5.95/css/materialdesignicons.min.css" rel="stylesheet">
<style>
    .tao-card-row .col {
        animation: fadeInUp 0.6s ease-out;
    }
    @keyframes fadeInUp {
        from { opacity: 0; transform: translateY(30px); }
        to { opacity: 1; transform: translateY(0); }
    }
</style>

<div class="team-management-container">
  <div class="team-header">
    <h4 class="team-title">My Team</h4>
    <p class="team-description">Manage your professional team members and relationships</p>
  </div>

  <!--- Team Actions Section --->
  <div class="team-actions-section">
    <div class="row g-3">
      <!--- Add New Person Column --->
      <div class="col-12 col-md-6">
        <div class="action-card add-person-card">
          <div class="action-icon">
            <i class="mdi mdi-account-plus"></i>
          </div>
          <div class="action-content">
            <h6 class="action-title">Add New Person</h6>
            <p class="action-subtitle">Create a new contact and add them to your team</p>
            <a href="remoteAddContact.cfm?src=account" 
               data-bs-remote="true" 
               data-bs-toggle="modal" 
               data-bs-target="#remoteAddContact"
               class="btn btn-primary btn-action">
              <i class="mdi mdi-plus me-2"></i>Add New
            </a>
          </div>
        </div>
      </div>

      <!--- Select Existing Relationship Column --->
      <div class="col-12 col-md-6">
        <div class="action-card select-person-card">
          <div class="action-icon">
            <i class="mdi mdi-account-group"></i>
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
                  <i class="mdi mdi-arrow-right"></i>
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
            <cfset card_badge_yn          = "N" />
            <cfset card_casting           = "" />
            <cfset card_company           = myteam.card_company />
            <cfset card_delete            = "" />
            <cfset card_delete_msg        = "" />
            <cfset card_remove            = "/app/myaccount/?new_pgid=122&ctaction=deleteitem&deletecontactid=" & myteam.contactid />
            <cfset card_remove_msg        = "Are you sure you want to remove this person from your team?" />
            <cfset card_remove_value      = "'" & myteam.contactid & "'" />
            <cfset card_details           = "/app/contact/?contactid=" & myteam.contactid />
            <cfset card_email             = myteam.card_email />
            <cfset card_footer_text       = "" />
            <cfset card_footer_type       = "social" />
            <cfset card_footer_yn         = "Y" />
            <cfset card_header_text       = myteam.card_name  />
            <cfset card_name              = "" />
            <cfset card_header_yn         = "Y" />
            <cfset card_icon              = "" />
            <cfset card_icon_yn           = "N" />
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
            <cfset card_title             = myteam.card_company />
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
        <i class="mdi mdi-share-variant"></i>
      </div>
      <div class="share-content">
        <h5 class="share-title">Team Share Link</h5>
        <p class="share-description">Share your team progress and updates with this secure link</p>
        <cfoutput>
          <div class="share-link-container">
            <div class="share-link">
              <a href="https://#host#.theactorsoffice.com/share/?shareid=#shareid#" 
                 target="_blank"
                 class="team-share-link"
                 title="View Team Share">
                https://#host#.theactorsoffice.com/share/?shareid=#shareid#
              </a>
            </div>
            <button class="btn btn-outline-primary btn-copy" onclick="copyToClipboard('https://#host#.theactorsoffice.com/share/?shareid=#shareid#', this)">
              <i class="mdi mdi-content-copy me-2"></i>Copy Link
            </button>
          </div>
          <p class="share-note">Click the link to preview how your team will see your progress report.</p>
        </cfoutput>
      </div>
    </div>
  </div>
</div> <!--- End .team-management-container --->

<!--- Toast notification styles --->
<style>
.tao-toast {
    position: fixed;
    top: 20px;
    right: 20px;
    z-index: 9999;
    min-width: 280px;
    max-width: 400px;
    padding: 14px 20px;
    border-radius: 6px;
    color: #fff;
    font-size: 14px;
    font-weight: 500;
    box-shadow: 0 4px 12px rgba(0,0,0,0.2);
    opacity: 0;
    transform: translateX(100%);
    transition: all 0.4s ease;
    display: flex;
    align-items: center;
    gap: 10px;
}
.tao-toast.show {
    opacity: 1;
    transform: translateX(0);
}
.tao-toast.hiding {
    opacity: 0;
    transform: translateX(100%);
}
.tao-toast-success { background-color: #1abc9c; }
.tao-toast-error { background-color: #f1556c; }
.tao-toast-info { background-color: #4fc6e1; }
.tao-toast i { font-size: 18px; }
</style>

<!--- JavaScript for deleting a team member via fetch() and copy functionality --->
<script>
// Toast notification utility
function showTeamToast(message, type) {
    type = type || 'success';
    var iconClass = type === 'success' ? 'mdi-check-circle' : type === 'error' ? 'mdi-alert-circle' : 'mdi-information';
    var toast = document.createElement('div');
    toast.className = 'tao-toast tao-toast-' + type;
    toast.innerHTML = '<i class="mdi ' + iconClass + '"></i><span>' + message + '</span>';
    document.body.appendChild(toast);
    // Trigger show animation
    requestAnimationFrame(function() {
        toast.classList.add('show');
    });
    // Auto-dismiss after 3 seconds
    setTimeout(function() {
        toast.classList.remove('show');
        toast.classList.add('hiding');
        setTimeout(function() { toast.remove(); }, 400);
    }, 3000);
}

function confirmRemove(contactId) {
    window.taoConfirmDelete("Are you sure you want to remove this person from your team?", function() {
        removeTeamMember(contactId);
    });
}

function removeTeamMember(contactId) {
    // CSRF: /include/delete_team.cfm runs under include/Application.cfc, which
    // rejects POSTs without a valid token and emits a 403 HTML page. Without
    // this header we used to hit .catch() and show a generic red toast.
    var csrfMeta = document.querySelector('meta[name="csrf-token"]');
    var csrfToken = csrfMeta ? csrfMeta.getAttribute('content') : '';

    fetch('/include/delete_team.cfm', {
        method: 'POST',
        credentials: 'same-origin',
        headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
            'X-CSRF-Token': csrfToken,
            'X-Requested-With': 'XMLHttpRequest',
            'Accept': 'application/json'
        },
        body: 'contactid=' + encodeURIComponent(contactId)
    })
    .then(function(r) {
        // Read as text first so a non-JSON error body (e.g. 403 HTML) doesn't throw.
        return r.text().then(function(txt) {
            var body = null;
            try { body = JSON.parse(txt); } catch (e) { /* non-JSON */ }
            return { ok: r.ok, status: r.status, body: body };
        });
    })
    .then(function(res) {
        if (res.ok && res.body && res.body.success) {
            var cardEl = document.getElementById('card-' + contactId);
            if (cardEl) {
                cardEl.classList.add('removing');
                setTimeout(function() { cardEl.remove(); }, 300);
            }
            showTeamToast('Team member removed successfully.', 'success');
        } else {
            var msg = (res.body && res.body.message)
                || (res.status === 403 ? 'Your session expired. Please reload and try again.' : 'Unable to remove team member.');
            showTeamToast(msg, 'error');
        }
    })
    .catch(function(error) {
        console.error('Error:', error);
        showTeamToast('Network error. Please try again.', 'error');
    });
}

function copyToClipboard(text, buttonElement) {
    // Store reference to the button element
    const btn = buttonElement || event.target.closest('.btn-copy');
    
    // Try modern clipboard API first
    if (navigator.clipboard && window.isSecureContext) {
        navigator.clipboard.writeText(text).then(function() {
            showCopySuccess(btn);
        }).catch(function(err) {
            console.warn('Clipboard API failed, using fallback:', err);
            fallbackCopyTextToClipboard(text, btn);
        });
    } else {
        // Use fallback for older browsers or non-secure contexts
        fallbackCopyTextToClipboard(text, btn);
    }
}

function fallbackCopyTextToClipboard(text, btn) {
    // Create a temporary textarea element
    var textArea = document.createElement("textarea");
    textArea.value = text;
    
    // Avoid scrolling to bottom
    textArea.style.top = "0";
    textArea.style.left = "0";
    textArea.style.position = "fixed";
    textArea.style.opacity = "0";
    
    document.body.appendChild(textArea);
    textArea.focus();
    textArea.select();
    
    try {
        var successful = document.execCommand('copy');
        if (successful) {
            showCopySuccess(btn);
        } else {
            showCopyError(btn);
        }
    } catch (err) {
        console.error('Fallback: Unable to copy', err);
        showCopyError(btn);
    }
    
    document.body.removeChild(textArea);
}

function showCopySuccess(btn) {
    if (!btn) return;
    
    const originalText = btn.innerHTML;
    btn.innerHTML = '<i class="mdi mdi-check me-2"></i>Copied!';
    btn.classList.remove('btn-outline-primary');
    btn.classList.add('btn-success');
    
    setTimeout(() => {
        btn.innerHTML = originalText;
        btn.classList.remove('btn-success');
        btn.classList.add('btn-outline-primary');
    }, 2000);
}

function showCopyError(btn) {
    if (!btn) return;
    
    const originalText = btn.innerHTML;
    btn.innerHTML = '<i class="mdi mdi-alert me-2"></i>Copy Failed';
    btn.classList.remove('btn-outline-primary');
    btn.classList.add('btn-danger');
    
    setTimeout(() => {
        btn.innerHTML = originalText;
        btn.classList.remove('btn-danger');
        btn.classList.add('btn-outline-primary');
    }, 2000);
    
    // Show a more helpful message
    alert('Unable to copy automatically. Please manually copy the link:\n\n' + btn.closest('.share-link-container').querySelector('.team-share-link').textContent);
}
</script>

<!--- Show toast on page load if a team action was just performed --->
<cfif isDefined('teamToastMsg') and len(trim(teamToastMsg))>
    <cfoutput>
        <script>
            document.addEventListener('DOMContentLoaded', function() {
                showTeamToast('#jsStringFormat(teamToastMsg)#', '#teamToastType#');
            });
        </script>
    </cfoutput>
</cfif>

<cfinclude template="/include/email_options_modal.cfm" />
