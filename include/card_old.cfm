<!--- Start of card layout --->
<cfoutput>
  <div class="col">
    <div class="tao-card-md ribbon-box">
      
      <!--- Ribbon (if exists) --->
      <cfif card_top_ribbon neq "">
        <div class="ribbon-two ribbon-two-success">
          <span>#card_top_ribbon#</span>
        </div>
      </cfif>

      <!--- Card Header ---> 
      <cfif card_header eq "Yes">
        <div class="tao-card-header">
          <!--- Trash/Delete Icon (Left) ---> 
          <cfif card_delete neq "">
            <a href="#card_delete#" title="Remove from team" class="text-danger trash-icon">
              <i class="mdi mdi-trash-can-outline"></i>
            </a>
          </cfif>
          <!--- View Icon (Top Right) ---> 
          <cfif card_details neq "">
            <a href="#card_details#" class="text-decoration-none view-icon">
              <i class="mdi mdi-eye"></i>
            </a>
          </cfif>
        </div>
      </cfif>

      <!--- Card Body: Two-Column Layout --->
      <div class="tao-card-body d-flex">
        <!--- Left Third: Avatar/Icon ---> 
        <div class="tao-card-avatar-container">
          <cfif card_icon neq "">
            <!--- Audition Category Icon ---> 
            <div class="tao-card-avatar text-center">
              <i class="mdi mdi-#aud_cat_icon#" aria-hidden="true"></i>
            </div>
          </cfif>

          <cfif card_avatar eq "Yes">
            <div class="tao-card-avatar">
              <img src="#card_image#?ver=#rand()#" alt="profile-image">
            </div>
          </cfif>

          <cfif card_image neq "" and card_avatar eq "">
            <div class="tao-card-image">
              <img src="#card_image#?ver=#rand()#" alt="profile-image">
            </div>
          </cfif>
        </div>

        <!--- Right Two-Thirds: Contact Info ---> 
   <!--- Right Two-Thirds: Contact Info --->
<div class="tao-card-info-container">
    <!--- Full Name ---> 
    <cfif card_name neq "">
        <p class="tao-card-name">
            <a href="#card_details#" title="#card_name#">#card_name#</a>
        </p>
    </cfif>


          <!--- Contact Info ---> 
          <div class="tao-card-info">
            <p class="tao-card-title">
              <cfif card_title neq "NULL">#card_title#</cfif>
            </p>

            <p class="tao-card-company">
              <cfif card_company neq "NULL">#card_company#</cfif>
            </p>

            <p class="tao-card-contact">
              <!--- Phone ---> 
              <span>
                <i class="fe-phone me-1 <cfif card_phone neq ''>has-content</cfif>"></i>
                #card_phone#
              </span>

              <!--- Email ---> 
              <span>
                <i class="fe-mail me-1 <cfif card_email neq ''>has-content</cfif>"></i>
                <cfif card_email neq ''>
                  <a href="mailto:#card_email#">#card_email#</a>
                </cfif>
              </span>
            </p>
          </div>
        </div>
      </div>

      <cfif card_ribbon1 neq "">
        <div class="ribbon-card ribbon-Pin float-end">
          <i class="mdi mdi-#ribbon_icon# me-1"></i>#card_ribbon1#
        </div>
      </cfif>

      <cfif card_ribbon2 neq "">
        <div class="ribbon-card ribbon-pin float-end">
          <i class="mdi mdi-#ribbon_icon# me-1"></i>#card_ribbon2#
        </div>
      </cfif>

      <!--- Card Footer ---> 
      <cfif card_footer eq "Yes">
        <div class="tao-card-footer">
          <cfif card_footer_text neq "">#card_footer_text#</cfif>

          <cfif card_social eq "Yes">
            <div class="tao-card-social">
              <cfloop query="profiles">
                <cfif profiles.valuetext neq "NULL">
                  <a href="#profiles.valuetext#" target="_blank" title="#profiles.valuetype#">
                    <cfif profiles.typeicon neq "">
                      <img src="#application.retinaIcons14Url#/#profiles.typeicon#" alt="#profiles.valuetype#">
                    <cfelse>
                      <img src="#application.retinaIcons14Url#/customlink.png" alt="#profiles.valuetype#">
                    </cfif>
                  </a>
                </cfif>
              </cfloop>

              <cfif profiles.recordcount eq 0>
                <div class="tao-card-social-placeholder">
                  <img src="#application.retinaIcons14Url#/placeholder.png" alt="placeholder">
                  <img src="#application.retinaIcons14Url#/placeholder.png" alt="placeholder">
                  <img src="#application.retinaIcons14Url#/placeholder.png" alt="placeholder">
                </div>
              </cfif>
            </div>
          </cfif>
        </div>
      </cfif>

    </div> <!--- End tao-card-md --->
  </div> <!--- End col --->
</cfoutput>
