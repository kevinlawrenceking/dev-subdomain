<!--- 
    PURPOSE: Modern user information display with avatar and contact details
    AUTHOR: Kevin King
    DATE: 2025-07-27
    FEATURES: Professional styling, responsive design, modern UI elements
--->

<div class="user-info-card fade-in">
    <!-- User Name Header -->
    <div class="user-name-header">
        <cfoutput>#userFirstName# #userlastName#</cfoutput>
        <button type="button" class="edit-account-btn" title="Update Account" data-bs-toggle="modal" data-bs-target="#remoteUserUpdate">
            <i class="mdi mdi-square-edit-outline"></i>
        </button>
    </div>

    <div class="row">
        <!-- Avatar Section: Enhanced with modern styling -->
        <div class="col-md-3">
            <div class="avatar-section">
                <cfoutput>
                    <a href="/app/image-upload/?contactid=#contactid#&ref_pgid=7" class="text-decoration-none">
                        <div class="user-avatar-container">
                            <img src="#session.userAvatarUrl#?ver=#rand()#" 
                                 class="user-avatar" 
                                 title="Click to change avatar (User ID: #userid#)" 
                                 alt="User Profile Image" 
                                 id="user-avatar-img" />
                            <div class="avatar-edit-overlay">
                                <i class="mdi mdi-camera"></i>
                            </div>
                        </div>
                    </a>
                    <div class="avatar-name">#avatarname#</div>
                </cfoutput>
                
                <!-- Password Change Section -->
                <div class="password-section">
                    <form action="/recover/index.cfm" method="post">
                        <cfoutput>
                            <input type="hidden" name="recoverid" value="#userid#" />
                        </cfoutput>
                        <button type="submit" class="btn-change-password">
                            <i class="mdi mdi-lock-reset me-2"></i>Change Password
                        </button>
                    </form>
                </div>
            </div>
        </div>

        <!-- User Details Section: Enhanced with modern layout -->
        <div class="col-md-9">
            <div class="user-details">
                <cfoutput>
                    <div class="detail-row">
                        <div class="detail-label">Email Address</div>
                        <div class="detail-value">
                            <i class="mdi mdi-email me-2 text-muted"></i>#useremail#
                        </div>
                    </div>

                    <div class="detail-row">
                        <div class="detail-label">Address</div>
                        <div class="detail-value address-block">
                            <i class="mdi mdi-map-marker me-2 text-muted"></i><cfif len(trim(add1))>#add1#</cfif><cfif len(trim(add2))>
#add2#</cfif>
                        </div>
                    </div>

                    <div class="row">
                        <div class="col-md-6">
                            <div class="detail-row">
                                <div class="detail-label">City</div>
                                <div class="detail-value">
                                    <i class="mdi mdi-city me-2 text-muted"></i><cfif len(trim(city))>#city#<cfelse><span class="text-muted">Not specified</span></cfif>
                                </div>
                            </div>
                        </div>
                        <div class="col-md-6">
                            <div class="detail-row">
                                <div class="detail-label">Postal Code</div>
                                <div class="detail-value">
                                    <i class="mdi mdi-mailbox me-2 text-muted"></i><cfif len(trim(zip))>#zip#<cfelse><span class="text-muted">Not specified</span></cfif>
                                </div>
                            </div>
                        </div>
                    </div>

                    <div class="row">
                        <div class="col-md-6">
                            <div class="detail-row">
                                <div class="detail-label">State/Region</div>
                                <div class="detail-value">
                                    <i class="mdi mdi-map me-2 text-muted"></i><cfif len(trim(region))>#region#<cfelse><span class="text-muted">Not specified</span></cfif>
                                </div>
                            </div>
                        </div>
                        <div class="col-md-6">
                            <div class="detail-row">
                                <div class="detail-label">Country</div>
                                <div class="detail-value">
                                    <i class="mdi mdi-earth me-2 text-muted"></i><cfif len(trim(countryname))>#countryname#<cfelse><span class="text-muted">Not specified</span></cfif>
                                </div>
                            </div>
                        </div>
                    </div>
                </cfoutput>
            </div>
        </div>
    </div>
</div>
