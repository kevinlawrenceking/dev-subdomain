<cfoutput>
  <div class="col" id="card-#card_id#">

    <div class="tao-card-md ribbon-box">
      
      <!--- Clickable Card (Only Wrap Image) --->
      <cfif card_details neq "" and card_view_icon_yn eq "N">
        <a href="#card_details#" title="View Details">
      </cfif>

      <!--- Top Ribbon (e.g., "Booked") ---> 
      <cfif card_top_ribbon neq "">
        <div class="ribbon-three ribbon-two-success"><span>#card_top_ribbon#!</span></div>
      </cfif>

      <!--- Header --->
      <cfif card_header_yn eq "Y">
        <div class="tao-card-header tao-card-header-#namecolor#">

          <!--- Remove  --->
          <cfif card_remove neq "">
            <a href="javascript:void(0);" 
               class="trash-icon" title="Remove Contact from Team"
               onclick="confirmRemove(#card_remove_value#);">
              <i class="mdi mdi-minus-circle" ></i>
            </a>
          </cfif>

     


          <cfif card_header_text neq "">
            <span class="tao-card-header-text">#card_header_text#</span>
          </cfif>
                          <cfif card_details neq "" and card_view_icon_yn eq "Y">
            <a href="#card_details#" class="text-decoration-none view-icon" title="View Details">
              <i class="mdi mdi-eye"></i>
            </a>
          </cfif>
        </div>
      </cfif>

 
      <!--- Card Body (Avatar & Contact Info) --->
      <div class="tao-card-body">

        <cfif card_image_yn eq "Y">
          <div class="tao-card-image-container">
            <div class="tao-card-#card_image_type#">
              <img src="#card_image#" alt="profile-image" class="tao-card-#card_image_type#">

              <!--- Show Year if Calendar Type --->
              <cfif card_image_type eq "calendar">
          <cfif isDefined("cardYear")>
    <div class="calendar-year">#cardYear#</div>
</cfif>

              </cfif>
            </div>
          </div>
        </cfif>

        <!--- Right Section: Contact Info --->
        <div class="tao-card-info-avatar">
          <!--- Title Badge --->
          <p class="tao-card-title">
            <cfif card_badge_yn eq "Y">
              <span class="badge badge-blue">
                <cfif card_title neq "NULL">#card_title#<cfelse>&nbsp;</cfif>
              </span>
            <cfelse>
              #card_title#
              <cfif card_subtitle neq "">
                <br><span class="tao-card-subtitle">#card_subtitle#</span>
              </cfif>
            </cfif>
          </p>

          <!--- Company Name --->
          <p class="tao-card-company">
            <cfif card_company neq "NULL">#card_company#</cfif>
          </p>

          <!--- Contact Details --->
          <p class="tao-card-contact">
            <cfif card_source neq "">
              <span class="contact-item">
                <i class="mdi mdi-pin <cfif card_source neq ''>has-content</cfif>"></i>
                <cfif card_source neq ''>#card_source#<cfelse>&nbsp;</cfif>
              </span>
            </cfif>
            <cfif card_casting neq "">
              <span class="contact-item">
                <i class="mdi mdi-clipboard-account <cfif card_casting neq ''>has-content</cfif>"></i>
                <cfif card_casting neq ''>#card_casting#<cfelse>&nbsp;</cfif>
              </span>
            </cfif>
            <cfif card_phone neq "">
              <span class="contact-item">
                <i class="fe-phone me-1 <cfif card_phone neq ''>has-content</cfif>"></i>
                <cfif card_phone neq ''>#card_phone#<cfelse>&nbsp;</cfif>
              </span>
            </cfif>
          <!---  <cfif card_reminder neq "">
              <span class="contact-item">
                <i class="mdi mdi-account-multiple <cfif card_reminder neq ''>has-content</cfif>"></i>
                <cfif card_reminder neq ''>#card_reminder#<cfelse>&nbsp;</cfif>
              </span>
            </cfif> --->
          </p>
        </div>
      </div>
      <!--- End Card Body --->

      <cfif card_footer_yn eq "Y">
        <!--- Footer (Social Icons / Text) --->
        <div class="tao-card-footer">
          <div class="tao-card-social">
            <cfif card_footer_type eq "social">
              <cfif card_email neq "">
                <a href="mailto:#card_email#" target="_blank" title="#card_email#">
                  <i class="fe-mail"></i>
                </a>
              </cfif>
              <cfloop query="profiles">
                <cfif profiles.valuetext neq "NULL">
                  <a href="#profiles.valuetext#" target="_blank" title="#profiles.valuetype#">
                    <i class="mdi #profiles.typeiconmdi#"></i>
                  </a>
                </cfif>
              </cfloop>
            <cfelseif card_footer_type eq "text">
              <span>#card_footer_text#</span>
            </cfif>
          </div>
        </div>
      </cfif>





<!--- Ribbons (Properly Closed) --->
<cfif card_ribbon_straight neq "">
    <div class="ribbon-straight-box">

        <!--- Loop through each value in the list --->
        <cfloop list="#card_ribbon_straight#" index="ribbonType">
            <cfif ribbonType eq "Pin">
                <div class="ribbon-straight ribbon-straight-pin">
                    <i class="mdi mdi-map-marker"></i> &nbsp; Pin
                </div>
            </cfif>

            <cfif ribbonType eq "Redirect">
                <div class="ribbon-straight ribbon-straight-redirect">
                    <i class="mdi mdi-swap-horizontal"></i> &nbsp; Redirect
                </div>
            </cfif>

            <cfif ribbonType eq "Callback">
                <div class="ribbon-straight ribbon-straight-callback">
                    <i class="mdi mdi-phone-incoming"></i> &nbsp; Callback
                </div>
            </cfif>

            <cfif ribbonType eq "Follow Up">
                <div class="ribbon-straight ribbon-straight-pin">
                    <i class="mdi mdi-map-marker"></i> &nbsp; Follow-Up
                </div>
            </cfif>

            <cfif ribbonType eq "Targeted List">
                <div class="ribbon-straight ribbon-straight-redirect">
                    <i class="mdi mdi-bullseye-arrow"></i> &nbsp; Targeted
                </div>
            </cfif>

            <cfif ribbonType eq "Maintenance List">
                <div class="ribbon-straight ribbon-straight-callback">
                    <i class="mdi mdi-wrench"></i> &nbsp; Maintenance
                </div>
            </cfif>
        </cfloop>

    </div>
</cfif>




 
    </div>
    <!--- End tao-card-md --->
     <cfif card_details neq "" and card_view_icon_yn eq "N"></a></cfif>
  </div>
  <!--- End col --->
</cfoutput>


