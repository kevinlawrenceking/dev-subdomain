<!---
    PURPOSE: Navigation top bar with search, help menu, and user profile
    AUTHOR: Kevin King
    DATE: 2025-08-07
    DEPENDENCIES: Bootstrap 5, Feather Icons
--->

<div class="navbar-custom">
    <div class="container-fluid">
        <!-- Right Side Menu Items -->
        <ul class="list-unstyled topnav-menu float-end mb-0">
            
            <!-- Desktop Search -->
            <li class="d-none d-lg-block">
                <form class="app-search" id="submitform" action="/include/process.cfm" method="POST">
                    <div class="app-search-box dropdown">
                        <div class="input-group">
                            <input 
                                type="text" 
                                required 
                                class="form-control" 
                                name="topsearch" 
                                id="autocomplete" 
                                placeholder="Search contacts..." 
                                autocomplete="off" 
                                aria-label="Search contacts"
                            />
                            <input type="hidden" name="selectedId" id="selectedId" />
                            <input type="hidden" name="category" id="category" />
                            <div class="input-group-append">
                                <button class="btn btn-light" id="mybtn" type="submit" aria-label="Search">
                                    <i class="fe-search"></i>
                                </button>
                            </div>
                        </div>
                        <ul id="contact-suggestions" class="dropdown-menu" role="listbox"></ul>
                    </div>
                </form>
            </li>


            <!-- Mobile Search -->
            <li class="dropdown d-inline-block d-lg-none">
                <a class="nav-link dropdown-toggle arrow-none waves-effect waves-light" 
                   data-bs-toggle="dropdown" 
                   href="#" 
                   role="button" 
                   aria-haspopup="false" 
                   aria-expanded="false"
                   aria-label="Mobile search">
                    <i class="fe-search noti-icon"></i>
                </a>
                <div class="dropdown-menu dropdown-lg dropdown-menu-end p-0">
                    <form class="p-3" id="submitform_mobile" action="/include/process.cfm" method="POST">
                        <input 
                            type="search" 
                            class="form-control" 
                            name="topsearch" 
                            id="autocomplete_mobile" 
                            placeholder="Search contacts..." 
                            aria-label="Search contacts"
                        />
                        <input type="hidden" name="selectedId" id="selectedId_mobile" />
                        <input type="hidden" name="category" id="category_mobile" />
                    </form>
                </div>
            </li>

            <!-- Help & Support Menu -->
            <li class="dropdown d-none d-lg-inline-block topbar-dropdown">
                <a class="nav-link dropdown-toggle arrow-none waves-effect waves-light" 
                   data-bs-toggle="dropdown" 
                   href="#" 
                   role="button" 
                   aria-haspopup="false" 
                   aria-expanded="false"
                   aria-label="Help and support">
                    <i class="fe-help-circle noti-icon"></i>
                </a>
                <div class="dropdown-menu dropdown-lg dropdown-menu-end">
                    <div class="dropdown-header">
                        <h6 class="text-overflow m-0">Help & Support</h6>
                    </div>
                    <div class="p-2">
                        <div class="row g-0">
                            <div class="col-6">
                                <cfoutput>
                                    <a class="dropdown-icon-item text-center py-2" 
                                       href="https://theactorsoffice.helpwise.help/" 
                                       target="_blank"
                                       rel="noopener noreferrer">
                                        <img src="#application.imagesUrl#/faq.png?ver=3" alt="" class="mb-1" />
                                        <small class="d-block">FAQ</small>
                                    </a>
                                </cfoutput>
                            </div>
                            <div class="col-6">
                                <cfoutput>
                                    <a class="dropdown-icon-item text-center py-2" 
                                       href="https://www.facebook.com/groups/taousercommunity" 
                                       target="_blank"
                                       rel="noopener noreferrer">
                                        <img src="#application.imagesUrl#/usercom.png?ver=3" alt="" class="mb-1" />
                                        <small class="d-block">Community</small>
                                    </a>
                                </cfoutput>
                            </div>
                            <cfif isDefined('userRole') AND userRole EQ "Administrator">
                                <div class="col-6">
                                    <cfoutput>
                                        <a href="remoteSupportForm.cfm" 
                                           data-bs-remote="true" 
                                           data-bs-toggle="modal" 
                                           data-bs-target="##remoteSupportForm" 
                                           class="dropdown-icon-item text-center py-2">
                                            <img src="#application.imagesUrl#/feedback.png?ver=3" alt="" class="mb-1" />
                                            <small class="d-block">Create Ticket</small>
                                        </a>
                                    </cfoutput>
                                </div>
                            </cfif>
                            <div class="col-6">
                                <cfoutput>
                                    <a class="dropdown-icon-item text-center py-2" 
                                       href="mailto:support@theactorsoffice.com?subject=Support%20Request%20for%20TAO">
                                        <img src="#application.imagesUrl#/contact.png?ver=3" alt="" class="mb-1" />
                                        <small class="d-block">Contact</small>
                                    </a>
                                </cfoutput>
                            </div>
                        </div>
                    </div>
                </div>
            </li>

            <!-- User Profile Menu -->
            <li class="dropdown notification-list topbar-dropdown">
                <a class="nav-link dropdown-toggle nav-user me-0 waves-effect waves-light" 
                   data-bs-toggle="dropdown" 
                   href="#" 
                   role="button" 
                   aria-haspopup="false" 
                   aria-expanded="false"
                   aria-label="User menu">
                    <i class="fe-user noti-icon"></i>
                </a>
                <div class="dropdown-menu dropdown-menu-end profile-dropdown">
                    <div class="dropdown-header noti-title">
                        <h6 class="text-overflow m-0">Welcome!</h6>
                    </div>
                    <a href="/app/myaccount/" class="dropdown-item notify-item">
                        <i class="fe-user me-2"></i>
                        <span>My Account</span>
                    </a>
                    <div class="dropdown-divider"></div>
                    <a href="/app/logout.cfm" class="dropdown-item notify-item">
                        <i class="fe-log-out me-2"></i>
                        <span>Logout</span>
                    </a>
                </div>
            </li>
        </ul>

        <!-- Logo Section -->
        <cfoutput>
            <div class="logo-box">
                <a href="/app/" class="logo logo-dark text-center" aria-label="Home">
                    <span class="logo-sm">
                        <img src="#application.imagesUrl#/logo-sm.png" alt="TAO Logo" height="30" />
                    </span>
                    <span class="logo-lg">
                        <img src="#application.imagesUrl#/logo-sm.png" alt="TAO Logo" height="30" />
                    </span>
                </a>
                
                <a href="/app/" class="logo logo-light text-center" aria-label="Home">
                    <span class="logo-sm">
                        <img src="#application.imagesUrl#/logo-sm.png" alt="TAO Logo" height="30" />
                    </span>
                    <span class="logo-lg">
                        <img src="#application.imagesUrl#/logo-light.png" alt="TAO Logo" height="30" />
                    </span>
                </a>
            </div>
        </cfoutput>

        <!-- Left Side Menu Controls -->
        <ul class="list-unstyled topnav-menu topnav-menu-left m-0">
            <li>
                <button class="button-menu-mobile waves-effect waves-light" 
                        aria-label="Toggle mobile menu">
                    <i class="fe-menu"></i>
                </button>
            </li>
            <li>
                <a class="navbar-toggle nav-link" 
                   data-bs-toggle="collapse" 
                   data-bs-target="#topnav-menu-content"
                   aria-label="Toggle navigation menu">
                    <div class="lines">
                        <span></span>
                        <span></span>
                        <span></span>
                    </div>
                </a>
            </li>
        </ul>

        <div class="clearfix"></div>
    </div>
</div>
