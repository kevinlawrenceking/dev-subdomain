<cfparam name="mock_yn" default="N" />

<cfparam name="BROWSER_USER_AVATAR_FILENAME" default="N" />
<cfif #mock_yn# is "Y" and #mocktoday# is not "">

    <cfset cookie.mocktoday=mocktoday />
    <cfelse>

        <cfcookie name="mocktoday" expires="#now()#">

</cfif>

<div class="left-side-menu">

    <div class="h-100" data-simplebar>

<!--- Sidemenu --->
        <div id="sidebar-menu">

                <ul id="side-menu">
                <li>
                    <div class="user-lg text-center">
                       <center> <a href="/app/image-upload/?ref_pgid=7" style="text-align:center;">
                            <cfoutput>
                                <img src="#session.userAvatarUrl#?ver=#rand()#" alt="user-image" id="mobile" class="rounded-circle avatar-md text-center" />
                                <br />
                                <span class="pro-user-name ml-1 text-center">#avatarname#</span>
                            </cfoutput>
                        </a></center>
                    </div>
                </li>
                
                <Cfoutput query="menuItemsU">
                    <li>
                        <a href="/app/#menuItemsU.compDir#/">
                            <i data-feather="#menuitemsU.compicon#"></i>
                            <span>#menuItemsU.compName# </span>
                        </a>
                    </li>

                </Cfoutput>

                <!---

                           <li>
                        <a href="/app/auditions/">
                            <i data-feather="<i data-feather="film"></i>
                            <span>Auditions </span>
                        </a>
                    </li>

--->
                <cfif #userrole# is "Administrator">

<li>
                                <a href="#sidebara" data-bs-toggle="collapse">
                                <i data-feather="sliders"></i>
                                    <span> Relationships - Admin </span>
                                    <span class="menu-arrow"></span>
                                </a>
<div class="collapse" id="sidebara">
    <style>
        #sidebara .nav-second-level {
            list-style-type: disc !important;
            padding-left: 30px; /* Indents bullets */
        }

        #sidebara .nav-second-level a {
            color: #f8f8ff;
            margin-left: 5px;
        }

        #sidebara .nav-second-level a:hover,
        #sidebara .nav-second-level a:active {
            color: #dece8e !important;
        }
    </style>
    <ul class="nav-second-level">
        <cfoutput query="menuItemsa">    
            <li>&nbsp;&nbsp;&nbsp;
                <a href="/app/#menuItemsA.compDir#/" >
                    <span>#menuItemsA.compName#</span>
                </a>
            </li>
        </cfoutput>
    </ul>
</div>




                            </li>

<li>
                                <a href="#sidebarEmail" data-bs-toggle="collapse">
                                      <i data-feather="sliders"></i>
                                    <span> Audition - Admin </span>
                                    <span class="menu-arrow"></span>
                                </a>
                    



                    <div class="collapse" id="sidebarEmail">
    <style>
        #3#sidebarEmail .nav-second-level {
            list-style-type: disc !important;
            padding-left: 30px; /* Indents bullets */
        }

        #sidebarEmail .nav-second-level a {
            color: #f8f8ff;
            margin-left: 5px;
        }

        #sidebarEmail .nav-second-level a:hover,
        #sidebarEmail .nav-second-level a:active {
            color: #dece8e !important;
        }
    </style>
    <ul class="nav-second-level">
        <cfoutput query="menuItemsaud">    
            <li>&nbsp;&nbsp;&nbsp;
                <a href="/app/#menuItemsAud.compDir#/">
                    <span>#menuItemsAud.compName#</span>
                </a>
            </li>
        </cfoutput>
    </ul>
</div>

                            </li>

</cfif>

<cfparam name="userisbetatester" default="0" />

<cfif #userIsBetaTester# is "1">
                    <li>
                        <a href="/app/Testings/">
                            <i data-feather="list"></i>
                            <span> Testing Log</span>
                        </a>
                    </li>

                </cfif>

</ul>

        </div>

<div class="clearfix"></div>

    </div>
    <!--- Sidebar left --->

</div>