<!--- This ColdFusion page contains the navigation bar and search functionality for the  --->

<div class="navbar-custom">
    <div class="container-fluid">
        <ul class="list-unstyled topnav-menu float-end mb-0">
<li class="d-none d-lg-block">
    <!--- Search Form for Desktop with Autocomplete --->
    <form class="app-search" id="submitform" action="/include/process.cfm" method="POST">
        <div class="app-search-box dropdown">
            <div class="input-group">
                <!--- Autocomplete Input Field --->
                <input 
                    type="text" 
                    required="required" 
                    class="form-control" 
                    name="topsearch" 
                    id="autocomplete" 
                    placeholder="Search..." 
                    autocomplete="off" 
                />
                <!--- Hidden fields for ID and Category --->
                <input type="hidden" name="selectedId" id="selectedId" />
                <input type="hidden" name="category" id="category" />
                <div class="input-group-append">
                    <button class="btn" id="mybtn" type="submit">
                        <i class="fe-search"></i>
                    </button>
                </div>
            </div>
            <!--- Autocomplete Suggestions Dropdown --->
            <ul id="contact-suggestions" class="dropdown-menu"></ul>
        </div>
    </form>
</li>


            <li class="dropdown d-inline-block d-lg-none">
                <!--- Mobile Search Dropdown --->
                <a class="nav-link dropdown-toggle arrow-none waves-effect waves-light" data-bs-toggle="dropdown" href="#" role="button" aria-haspopup="false" aria-expanded="false">
                    <i class="fe-search noti-icon"></i>
                </a>
                <div class="dropdown-menu dropdown-lg dropdown-menu-end p-0">
                    <form class="p-3" id="submitform_mobile" action="/include/process.cfm" method="POST">
                        <input type="search" class="form-control" name="topsearch" id="autocomplete_mobile" placeholder="Search..." />
                    </form>
                </div>
            </li>

            <li class="dropdown d-none d-lg-inline-block topbar-dropdown">
                <!--- Help and Support Dropdown --->
                <a class="nav-link dropdown-toggle arrow-none waves-effect waves-light" data-bs-toggle="dropdown" href="#" role="button" aria-haspopup="false" aria-expanded="false">
                    <i class="fe-help-circle noti-icon"></i>
                </a>
                <div class="dropdown-menu dropdown-lg dropdown-menu-end">
                    <div class="p-lg-1">
                        <div class="row no-gutters">
                            <div class="col">
                                <cfoutput>
                                    <a class="dropdown-icon-item" href="https://theactorsoffice.helpwise.help/" target="FAQ">
                                        <img src="#application.imagesUrl#/faq.png?ver=3" alt="FAQ" />
                                        <span>FAQ</span>
                                    </a>
                                </cfoutput>
                            </div>
                            <div class="col">
                                <cfoutput>
                                    <a class="dropdown-icon-item" href="https://www.facebook.com/groups/taousercommunity" target="usercommunity">
                                        <img src="#application.imagesUrl#/usercom.png?ver=3" alt="User Community" />
                                        <span>User Community</span>
                                    </a>
                                </cfoutput>
                            </div>
                            <cfif userRole EQ "Administrator">
                                <div class="col">
                                    <cfoutput>
                                        <a href="remoteSupportForm.cfm" data-bs-remote="true" data-bs-toggle="modal" data-bs-target="##remoteSupportForm" class="dropdown-icon-item">
                                            <img src="#application.imagesUrl#/feedback.png?ver=3" alt="Feedback" />
                                            <span>Create a Ticket</span>
                                        </a>
                                    </cfoutput>
                                </div>
                            </cfif>
                            <div class="col">
                                <cfoutput>
                                    <a class="dropdown-icon-item" href="mailto:support@theactorsoffice.com?subject=I%20Need%20Some%20Support%20with%20TAO">
                                        <img src="#application.imagesUrl#/contact.png?ver=3" alt="Contact Support" />
                                        <span>Contact Support</span>
                                    </a>
                                </cfoutput>
                            </div>
                        </div>
                    </div>
                </div>
            </li>

            <li class="dropdown notification-list topbar-dropdown">
                <!--- User Profile Dropdown --->
                <a class="nav-link dropdown-toggle nav-user me-0 waves-effect waves-light" data-bs-toggle="dropdown" href="#" role="button" aria-haspopup="false" aria-expanded="false">
                    <i class="fe-user noti-icon"></i>
                </a>
                <div class="dropdown-menu dropdown-menu-end profile-dropdown">
                    <div class="dropdown-header noti-title">
                        <h6 class="text-overflow m-0">Welcome!</h6>
                    </div>
                    <a href="/app/myaccount/" class="dropdown-item notify-item">
                        <i class="fe-user"></i>
                        <span>My Account</span>
                    </a>
                    <a href="/app/logout.cfm" class="dropdown-item notify-item">
                        <i class="fe-log-out"></i>
                        <span>Logout</span>
                    </a>
                </div>
            </li>
        </ul>

        <Cfoutput>
                <div class="logo-box">
            <a href="/app/" class="logo logo-dark text-center">
                <span class="logo-sm">
               <img src="#application.imagesUrl#/logo-sm.png" alt="" height="30" />
              
                </span>
                <span class="logo-lg">
                 <img src="#application.imagesUrl#/logo-sm.png" alt="" height="30" />
          
                </span>
            </a>
    
            <a href="/app/" class="logo logo-light text-center">
                <span class="logo-sm">
                     <img src="#application.imagesUrl#/logo-sm.png" alt="" height="30" />
                </span>
                <span class="logo-lg">
                   <img src="#application.imagesUrl#/logo-light.png" alt="" height="30" />
                </span>
            </a>
        </div>
        </cfoutput>

        <ul class="list-unstyled topnav-menu topnav-menu-left m-0">
            <li>
                <!--- Mobile Menu Button --->
                <button class="button-menu-mobile waves-effect waves-light">
                    <i class="fe-menu"></i>
                </button>
            </li>
            <li>
                <!--- Mobile Menu Toggle (Horizontal Layout) --->
                <a class="navbar-toggle nav-link" data-bs-toggle="collapse" data-bs-target="#topnav-menu-content">
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
