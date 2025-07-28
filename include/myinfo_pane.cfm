<!--- 
    PURPOSE: Modern user information display with avatar and contact details
    AUTHOR: Kevin King
    DATE: 2025-07-27
    FEATURES: Professional styling, responsive design, modern UI elements
--->

<!-- Custom Styles for Modern Look -->
<style>
    .user-info-card {
        background: #ffffff;
        border: 1px solid #dee2e6;
        border-radius: 8px;
        box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        transition: all 0.3s ease;
        padding: 1.5rem;
        margin-bottom: 1.5rem;
    }
    
    .user-info-card:hover {
        box-shadow: 0 4px 8px rgba(0,0,0,0.15);
    }
    
    .user-avatar-container {
        position: relative;
        display: inline-block;
        margin-bottom: 1rem;
    }
    
    .user-avatar {
        width: 120px;
        height: 120px;
        border-radius: 50%;
        border: 3px solid #406e8e;
        box-shadow: 0 4px 8px rgba(0,0,0,0.1);
        transition: all 0.3s ease;
        object-fit: cover;
        cursor: pointer;
    }
    
    .user-avatar:hover {
        transform: scale(1.05);
        box-shadow: 0 6px 12px rgba(0,0,0,0.15);
        border-color: #2d4a5f;
    }
    
    .avatar-edit-overlay {
        position: absolute;
        bottom: 0;
        right: 0;
        background: #406e8e;
        color: white;
        border-radius: 50%;
        width: 32px;
        height: 32px;
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 14px;
        transition: all 0.3s ease;
        border: 2px solid white;
        box-shadow: 0 2px 4px rgba(0,0,0,0.2);
    }
    
    .avatar-edit-overlay:hover {
        background: #2d4a5f;
        transform: scale(1.1);
    }
    
    .user-name-header {
        color: #2c3e50;
        font-weight: 600;
        margin-bottom: 1.5rem;
        font-size: 1.5rem;
        display: flex;
        align-items: center;
        justify-content: space-between;
    }
    
    .edit-account-btn {
        color: #406e8e;
        font-size: 1.2rem;
        transition: all 0.3s ease;
        padding: 0.5rem;
        border-radius: 6px;
        background: transparent;
        border: none;
    }
    
    .edit-account-btn:hover {
        color: #2d4a5f;
        background: rgba(64, 110, 142, 0.1);
        transform: scale(1.1);
    }
    
    .avatar-name {
        font-size: 0.9rem;
        color: #6c757d;
        font-weight: 500;
        margin-top: 0.5rem;
        text-align: center;
    }
    
    .btn-change-password {
        background: linear-gradient(135deg, #406e8e, #2d4a5f);
        border: none;
        color: white;
        padding: 0.6rem 1.2rem;
        border-radius: 6px;
        font-weight: 500;
        transition: all 0.3s ease;
        box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        font-size: 0.85rem;
        width: 100%;
    }
    
    .btn-change-password:hover {
        background: linear-gradient(135deg, #2d4a5f, #1a2f3a);
        transform: translateY(-1px);
        box-shadow: 0 4px 8px rgba(0,0,0,0.15);
        color: white;
    }
    
    .user-details {
        background: #f8f9fa;
        border-radius: 6px;
        padding: 1.5rem;
    }
    
    .detail-row {
        margin-bottom: 1rem;
        padding-bottom: 1rem;
        border-bottom: 1px solid #e9ecef;
    }
    
    .detail-row:last-child {
        margin-bottom: 0;
        padding-bottom: 0;
        border-bottom: none;
    }
    
    .detail-label {
        font-weight: 600;
        color: #495057;
        font-size: 0.9rem;
        text-transform: uppercase;
        letter-spacing: 0.5px;
        margin-bottom: 0.3rem;
    }
    
    .detail-value {
        color: #2c3e50;
        font-size: 1rem;
        line-height: 1.4;
    }
    
    .address-block {
        white-space: pre-line;
    }
    
    .avatar-section {
        text-align: center;
        padding: 1rem;
        background: #f8f9fa;
        border-radius: 6px;
        margin-bottom: 1rem;
    }
    
    .password-section {
        margin-top: 1.5rem;
        padding-top: 1.5rem;
        border-top: 1px solid #dee2e6;
    }
    
    /* Responsive adjustments */
    @media (max-width: 768px) {
        .user-info-card {
            padding: 1rem;
        }
        
        .user-name-header {
            font-size: 1.3rem;
            flex-direction: column;
            gap: 0.5rem;
            text-align: center;
        }
        
        .user-avatar {
            width: 100px;
            height: 100px;
        }
        
        .avatar-edit-overlay {
            width: 28px;
            height: 28px;
            font-size: 12px;
        }
        
        .detail-label {
            font-size: 0.8rem;
        }
        
        .detail-value {
            font-size: 0.9rem;
        }
    }
    
    /* Fade in animation */
    .fade-in {
        animation: fadeIn 0.5s ease-in;
    }
    
    @keyframes fadeIn {
        from { opacity: 0; transform: translateY(10px); }
        to { opacity: 1; transform: translateY(0); }
    }
</style>

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
