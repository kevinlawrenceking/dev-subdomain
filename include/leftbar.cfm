<!---
    PURPOSE: Left navigation sidebar for the application
    AUTHOR: Kevin King
    DATE: 2025-08-06
    DEPENDENCIES: Bootstrap 5, Feather Icons, session variables
--->

<cfparam name="mock_yn" default="N" />
<cfparam name="BROWSER_USER_AVATAR_FILENAME" default="N" />

<!--- Mock date handling for testing --->
<cfif mock_yn IS "Y" AND len(trim(mocktoday))>
    <cfset cookie.mocktoday = mocktoday />
<cfelse>
    <cfcookie name="mocktoday" expires="#now()#" />
</cfif>

<div class="left-side-menu left-side-menu-light">
    <div class="h-100" data-simplebar>
        <!--- Sidemenu --->
        <div id="sidebar-menu">
            <ul id="side-menu">
                <!--- User Profile Section --->
                <li>
                    <div class="user-lg text-center" >
                        <a href="/app/image-upload/?ref_pgid=7" class="text-center">
                            <cfoutput>
                                <img src="#session.userAvatarUrl#?ver=#rand()#" 
                                     alt="user-image" 
                                     class="rounded-circle avatar-md" />
                                <br />
                                <span class="pro-user-name mt-2 d-block">#avatarname#</span>
                            </cfoutput>
                        </a>
                    </div>
                </li>
                
                <!--- Main Menu Items --->
                <cfoutput query="menuItemsU">
                    <li>
                        <a href="/app/#menuItemsU.compDir#/">
                            <i data-feather="#menuItemsU.compicon#"></i>
                            <span>#menuItemsU.compName#</span>
                        </a>
                    </li>
                </cfoutput>

                
                <!--- Administrator Menu Sections --->
                <cfif userrole IS "Administrator">
                    <!--- Relationships Admin Section --->
                    <li>
                        <a href="#sidebara" data-bs-toggle="collapse" aria-expanded="false">
                            <i data-feather="users"></i>
                            <span>Relationships - Admin</span>
                            <span class="menu-arrow"></span>
                        </a>
                        <div class="collapse" id="sidebara">
                            <ul class="nav-second-level">
                                <cfoutput query="menuItemsa">    
                                    <li>
                                        <a href="/app/#menuItemsA.compDir#/">
                                            <span>#menuItemsA.compName#</span>
                                        </a>
                                    </li>
                                </cfoutput>
                            </ul>
                        </div>
                    </li>

                    <!--- Audition Admin Section --->
                    <li>
                        <a href="#sidebarAudition" data-bs-toggle="collapse" aria-expanded="false">
                            <i data-feather="film"></i>
                            <span>Audition - Admin</span>
                            <span class="menu-arrow"></span>
                        </a>
                        <div class="collapse" id="sidebarAudition">
                            <ul class="nav-second-level">
                                <cfoutput query="menuItemsaud">    
                                    <li>
                                        <a href="/app/#menuItemsAud.compDir#/">
                                            <span>#menuItemsAud.compName#</span>
                                        </a>
                                    </li>
                                </cfoutput>
                            </ul>
                        </div>
                    </li>
                </cfif>

                <!--- Beta Tester Menu Item --->
                <cfparam name="userIsBetaTester" default="0" />
                <cfif userIsBetaTester IS "1">
                    <li>
                        <a href="/app/Testings/">
                            <i data-feather="clipboard"></i>
                            <span>Testing Log</span>
                        </a>
                    </li>
                </cfif>
            </ul>
        </div>
        
        <div class="clearfix"></div>
    </div>
    <!--- End Sidebar --->
</div>

<!--- Sidebar Styles --->
<style>
    /* Alternative Light Theme for Left Sidebar */
    .left-side-menu-light {
        background-color: #E9EAEC !important;
    }
    
    .left-side-menu-light .pro-user-name {
        color: #2c3e50 !important;
    }
    
    .left-side-menu-light #side-menu > li > a {
        color: #2c3e50 !important;
        border-bottom: 1px solid #d0d1d3 !important;
    }
    
    .left-side-menu-light #side-menu > li > a:hover,
    .left-side-menu-light #side-menu > li > a:focus,
    .left-side-menu-light #side-menu > li > a.active {
        color: #1a252f !important;
        background-color: #dce0e3 !important;
    }
    
    .left-side-menu-light #side-menu > li > a i {
        color: #495057 !important;
    }
    
    .left-side-menu-light #side-menu > li > a:hover i,
    .left-side-menu-light #side-menu > li > a:focus i,
    .left-side-menu-light #side-menu > li > a.active i {
        color: #1a252f !important;
    }
    
    .left-side-menu-light .menu-arrow {
        color: #495057 !important;
    }
    
    .left-side-menu-light .nav-second-level a {
        color: #495057 !important;
        border-bottom: 1px solid #d0d1d3 !important;
    }
    
    .left-side-menu-light .nav-second-level a:hover,
    .left-side-menu-light .nav-second-level a:active {
        color: #1a252f !important;
        background-color: #dce0e3 !important;
        text-decoration: none;
    }

    /* Original Dark Theme Styles (default) */
    .nav-second-level {
        list-style-type: none !important;
        padding-left: 0;
        margin-left: 20px;
    }

    .nav-second-level li {
        margin: 5px 0;
    }

    .nav-second-level a {
        color: #f8f8ff;
        font-size: 0.9em;
        padding: 5px 10px;
        border-radius: 4px;
        transition: all 0.2s ease-in-out;
    }

    .nav-second-level a:hover,
    .nav-second-level a:active {
        color: #dece8e !important;
        background-color: rgba(222, 206, 142, 0.1);
        text-decoration: none;
    }

    .pro-user-name {
        font-size: 0.9em;
        font-weight: 500;
    }

    .user-lg .avatar-md {
        width: 60px;
        height: 60px;
        margin-bottom: 10px;
    }

    /* Add space between user profile and menu */
    .user-lg {
        margin-bottom: 20px;
        padding-bottom: 15px;
        border-bottom: 1px solid rgba(255, 255, 255, 0.1);
    }
    
    .left-side-menu-light .user-lg {
        border-bottom: 1px solid #d0d1d3;
    }

    #side-menu .menu-arrow {
        float: right;
        margin-top: 2px;
    }
</style>