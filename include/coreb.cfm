<!--- This ColdFusion page includes necessary scripts and styles, sets up the layout, and manages modals for user interaction. --->

<cfinclude template="/include/pgload.cfm" />
<cfinclude template="/include/pgload.cfm" />

<!DOCTYPE html>

<html lang="en">

<head>

    <cfoutput>
        <meta charset="utf-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <meta http-equiv="X-UA-Compatible" content="IE=edge" />
        <title>#appName# | #pgTitle#</title>
        <meta content="#appDescription#" name="description" />
        <meta content="#appAuthor#" name="author" />
    </cfoutput>

    <style>
        @import url('https://fonts.googleapis.com/css2?family=Source+Sans+Pro:wght@300&display=swap');
    </style>

    <!--- Loop through FindLinksT query to include scripts and styles --->
    <cfloop query="FindLinksT">
        <cfoutput>
            <cfif "#findlinkst.linktype#" is "script">
                <script src="#findlinkst.linkurl#"></script>
            <cfelseif "#findlinkst.linktype#" is "script_include"> 
                <cfinclude template="#findlinkst.linkurl#">  
            <cfelse>
                <link href="#findlinkst.linkurl#?rev=#rev#" 
                      <cfif #findlinkst.rel# is not ""> rel="#rel#"</cfif> 
                      type="text/css" 
                      <cfif #findlinkst.hrefid# is not ""> id="#findlinkst.hrefid#"</cfif> />
            </cfif>
        </cfoutput>
    </cfloop>

    <!--- Check session variable for ftom and show modal if necessary --->
    <cfif #isdefined('session.ftom')#>
        <cfif session.ftom is "Y">
            <script type="text/javascript">
                $(window).on('load', function() {
                    $('#showmaint').modal('show');
                });
            </script>
            <cfset session.ftom="N" />
        </cfif>
    </cfif>

</head>

<body class="loading">

    <div id="wrapper">

        <!--- Set navbar background color based on host environment --->
        <cfif #host# is "dev">
            <div class="navbar-custom" style="background-color: #8b0000 !important;">
        <cfelse>
            <div class="navbar-custom" style="background-color: <cfoutput>#colorTopBar#</cfoutput> !important;">
        </cfif>

        <div class="container-fluid">

            <cfinclude template="/include/topmenu_main.cfm" />

            <div class="logo no-hover-effect-box">
                <a href="<cfoutput>#home#</cfoutput>" class="logo no-hover-effect logo-dark text-center">
                    <span class="logo no-hover-effect-sm">
                        <span class="logo no-hover-effect-lg-text-light">
                            <cfoutput>#appname#</cfoutput>
                        </span>
                    </span>
                    <span class="logo no-hover-effect-lg">
                        <span class="logo no-hover-effect-lg-text-light"></span>
                    </span>
                </a>

                <a href="<cfoutput>#home#</cfoutput>" class="logo no-hover-effect logo-light text-center">
                    <span class="logo no-hover-effect-sm">
                        <img src="<cfoutput>#application.imagesUrl#</cfoutput>/logo-sm.png" alt="" height="22">
                    </span>
                    <span class="logo no-hover-effect-lg" style="min-width:200px !important;">
                        <span class="logo no-hover-effect-sm-text-light"></span>
                        <img src="<cfoutput>#application.imagesUrl#</cfoutput>/<cfoutput>#findPage.appLogoName#?ver=5</cfoutput>" alt="" height="30">
                    </span>
                </a>
            </div>

            <ul class="list-unstyled topnav-menu topnav-menu-left m-0">
                <li>
                    <button class="button-menu-mobile waves-effect waves-light">
                        <i class="fe-menu"></i>
                    </button>
                </li>
                <li>
                    <a class="navbar-toggle nav-link" data-toggle="collapse" data-target="#topnav-menu-content">
                        <div class="lines">
                            <span></span>
                            <span></span>
                            <span></span>
                        </div>
                    </a>
                </li>
            </ul>

        </div>
        <div class="clearfix"></div>

        <div class="left-side-menu" style="background-color: <cfoutput>#colorLeftSideBar#</cfoutput> !important;">
            <div class="h-100" data-simplebar>
                <div id="sidebar-menu">
                    <cfinclude template="/include/sidebar_menu_main.cfm" />
                </div>
                <div class="clearfix"></div>
            </div>
        </div>

        <!--- Set content page style based on pgFilename --->
        <div class="content-page" <cfif #pgFilename# is "comingsoon.cfm">
            style="background-image: url('#application.imagesUrl#/comingsoon_<cfoutput>#pgid#</cfoutput>.png?ver=293');background-position: top;background-repeat: no-repeat;background-size: cover;"
            </cfif>>
            <div class="content">
                <div class="container-fluid">
                    <cfif #pgFilename# is not "comingsoon.cfm">
                        <div class="row">
                            <div class="col-12">
                                <div class="page-title-box">
                                    <div class="page-title-right">
                                        <ol class="breadcrumb m-0">
                                            <li class="breadcrumb-item">
                                                <a href="<cfoutput>#home#/</cfoutput>">
                                                    <cfoutput>#appName# </cfoutput>
                                                </a>
                                            </li>
                                            <li class="breadcrumb-item">
                                                <a href="<cfoutput>/app/#compdir#</cfoutput>">
                                                    <cfoutput>#compName# </cfoutput>
                                                </a>
                                            </li>
                                            <li class="breadcrumb-item active">
                                                <cfoutput>#pgName#</cfoutput>
                                            </li>
                                        </ol>
                                    </div>
                                    <h4 class="page-title">
                                        <cfoutput>
                                            <cfif #userid# is "30">#pgid# </cfif>#pgHeading# 
                                            <A href="" data-toggle="modal" data-target="##custom-modal-diagnostic"></A>
                                            
                                            <cfif #pgid# is "89">
                                                <cfset session.pgrtn = "D" />
                                                <span style="font-size:14px;">
                                                    <a style="color: ##406e8e !important;" data-remote="true" data-toggle="modal" data-target="##paneladd" title="Add Custom Panel">
                                                        <i class="fe-plus-circle"></i>
                                                    </a>
                                                </span>
                                            </cfif>
                                            
                                            <cfif #pgid# is "5">
                                                <cfparam name="rcontactid" default="0" />
                                                <cfset session.pgrtn = "D" />
                                                <span style="font-size:14px;">
                                                    <a href="/app/appoint-add/?returnurl=calendar-appoint&amp;rcontactid=#rcontactid#" style="color: ##406e8e !important;" title="Add Appointment">
                                                        <i class="fe-plus-circle"></i>
                                                    </a>
                                                </span>
                                            </cfif>
                                        </cfoutput>
                                    </h4>
                                </div>
                            </div>
                        </div>
                    </cfif>

                    <!--- Include the specified page template if pgFilename is not empty --->
                    <cfif #pgFilename# is not "">
                        <cfinclude template="/include/#pgFilename#" />
                    </cfif>

                </div>
            </div>

            <cfparam name="pgdir" default="">
            <cfparam name="pgid" default="0" />
            <script>
                $(document).ready(function() {
                    $("#remoteSupportForm").on("show.bs.modal", function(event) {
                        
                        $(this).find(".modal-body").load("/include/RemoteSupportForm.cfm<cfoutput>?pgid=#pgid#&pgdir=#pgdir#&qstring=#cgi.query_string#&userrole=#userrole#</cfoutput>");
                    });
                });
            </script>

            <div id="remoteSupportForm" class="modal fade" tabindex="-1" role="dialog" aria-labelledby="standard-modalLabel" >

                <div class="modal-dialog">
                    <div class="modal-content">
                        <div class="modal-header" >
                            <h4 class="modal-title" id="standard-modalLabel">Support Center</h4>
                            <button type="button" class="close" data-bs-dismiss="modal" >
</button>
                        </div>
                        <div class="modal-body">
                        </div>
                    </div>
                </div>
            </div>

            <cfif #pgFilename# is not "comingsoon.cfm">
                <p>&nbsp;</p>
                <!--- Footer Start --->
                <!--- <cfinclude template="/include/footer_main.cfm" />
                end Footer --->
            </cfif>
        </div>
    </div>

    <!--- Loop through FindLinksB query to include additional scripts and styles --->
    <cfloop query="FindLinksB">
        <cfoutput>
            <cfif "#findlinksb.linktype#" is "script">
                <script src="#findlinksb.linkurl#?ver=#rev#"></script>
            <cfelseif "#findlinksb.linktype#" is "script_include">    
                <cfinclude template="#findlinksb.linkurl#">   
            <cfelse>
                <link href="#findlinksb.linkurl#" 
                      <cfif #findlinksb.rel# is not ""> rel="#findlinksb.rel#"</cfif> 
                      type="text/css" 
                      <cfif #findlinksb.hrefid# is not ""> id="#findlinksb.hrefid#"</cfif> />
            </cfif>
        </cfoutput>
    </cfloop>

    <cfinclude template="/include/autocomplete.cfm" />

    <script>
        $("#remoteSupportForm").draggable({
            handle: ".modal-header"
        });
    </script>

</body>

</html>
