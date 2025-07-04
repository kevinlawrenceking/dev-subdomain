<cfparam name="refresh_yn" default="N"/>
<cfparam name="NEW_USERID" default="0"/>
<cfparam name="TAOVERSION" default="0"/>
<cfinclude template="pgload.cfm"/>

<!DOCTYPE html>
<html lang="en">

  <head>
    <cfoutput>
      <meta charset="utf-8"/>
      <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <meta http-equiv="X-UA-Compatible" content="IE=edge"/>
        <title>
          #appName# #shares.recordcount#| #pgTitle#</title>
        <meta content="#appDescription#" name="description"/>
        <meta content="#appAuthor#" name="author"/>
      </cfoutput>
      <style>
        @import url('https://fonts.googleapis.com/css2?family=Source+Sans+Pro:wght@300&display=swap');
      </style>
      <cfloop query="FindLinksT">
        <cfoutput>
          <cfif "#findlinkst.linktype#" is "script">
            <script src="#findlinkst.linkurl#"></script>
          </cfif>

          <cfif "#findlinkst.linktype#" is "script_include">
            <script>
              <cfinclude template="#findlinkst.linkurl#?rev=#rand()#">
            </script>
          </cfif>
          <cfif "#findlinkst.linktype#" is "css" or "#findlinkst.linktype#" is "text/css" or "#findlinkst.linktype#" is "ico">
            <link href="#findlinkst.linkurl#?rev=#rand()#" <cfif #findlinkst.rel# is not "">
                rel="#rel#"

            </cfif> type="text/css" <cfif #findlinkst.hrefid# is not "">id="#findlinkst.hrefid#"</cfif>/>

          </cfif>
        </cfoutput>
      </cfloop>

    </head>

    <body class="loading">

      <div id="wrapper">
        <cfif #host# is "dev">
          <div class="navbar-custom" style="background-color: #8b0000 !important;">
          <cfelse>
            <div class="navbar-custom" style="background-color: <cfoutput>#colorTopBar#</cfoutput> !important;">
            </cfif>
            <div class="container-fluid">
              <cfinclude template="topmenu_main.cfm"/>
              <div class="logo no-hover-effect-box">
                <a href="/app/" class="logo no-hover-effect logo-dark text-center">
                  <span class="logo no-hover-effect-sm">
                    <img src="<cfoutput>#application.imagesUrl#</cfoutput>/logo-sm.png" alt="" height="30">
                      <!--- <span class="logo no-hover-effect-lg-text-light">UBold</span> --->
                    </span>
                    <span class="logo no-hover-effect-lg">
                      <img src="<cfoutput>#application.imagesUrl#</cfoutput>/logo-sm.png" alt="" height="30">
                        <!--- <span class="logo no-hover-effect-lg-text-light">U</span> --->
                      </span>
                    </a>

                    <a href="/app/" class="logo no-hover-effect logo-light text-center">
                      <span class="logo no-hover-effect-sm">
                        <img src="<cfoutput>#application.imagesUrl#</cfoutput>/logo-sm.png" alt="" height="30"></span>
                        <span class="logo no-hover-effect-lg">
                          <img src="<cfoutput>#application.imagesUrl#</cfoutput>/logo-light.png" alt="" height="30"></span>
                        </a>
                      </div>

                    </div>
                    <div class="content-pag">
                      <div class="content" STYLE="margin-top:35px;">
                        <div class="container-fluid">

                          <cfinclude template="share.cfm"/>
                        </div>
                      </div>
                      <cfparam name="pgdir" default="">
                      <cfparam name="pgid" default="0"/>
                    </div>
                  </div>
                  <cfloop query="FindLinksB">
                    <cfoutput>
                      <cfif "#findlinksb.linktype#" is "script">
                        <script src="#findlinksb.linkurl#?ver=#rand()#"></script>

                      </cfif>
                      <cfif "#findlinksb.linktype#" is "script_include">

                        <cfinclude template="#findlinksb.linkurl#">

                      </cfif>
                      <cfif "#findlinksb.linktype#" is "css" or "#findlinksb.linktype#" is "text/css" or "#findlinksb.linktype#" is "ico">
                        <link href="#findlinksb.linkurl#" <cfif #findlinksb.rel# is not ""> rel="#findlinksb.rel#"
            </cfif> type="text/css" <cfif #findlinksb.hrefid# is not "">

                id="#findlinksb.hrefid#"

            </cfif>/>

                      </cfif>
                    </cfoutput>
                  </cfloop>

                  <cfloop query="shares">

                    <script>
                      $(document).ready(function () {
                        $("#remoteShareViewC<cfoutput>#shares.contactid#</cfoutput>").on("show.bs.modal", function (event) {
                          $(this)
                            .find(".modal-body")
                            .load("remoteShareViewC.cfm?contactid=<cfoutput>#shares.contactid#</cfoutput>");
                        });
                      });
                    </script>

                    <div id="remoteShareViewC<cfoutput>#shares.contactid#</cfoutput>" class="modal modal-lg fade" tabindex="-1" role="dialog">

                      <div class="modal-dialog">

                        <div class="modal-content">

                          <div class="modal-header">

                            <h4 class="modal-title">
                              <CFOUTPUT>
                                #shares.name#</CFOUTPUT>

                            </h4>

                            <button type="button" class="close" data-bs-dismiss="modal">
                              <i class="mdi mdi-close-thick"></i>
                            </button>

                          </div>

                          <div class="modal-body"></div>

                        </div>

                      </div>

                    </div>

                  </cfloop>

                </body>

              </html>
