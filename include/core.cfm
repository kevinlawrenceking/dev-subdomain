<cfinclude template="/include/qry/menuitems.cfm">
<cfinclude template="/include/qry/menuItemsa_496_2.cfm">
<cfinclude template="/include/qry/menuItemsAud_496_3.cfm">

<cfinclude template="/include/pgload.cfm"/>

<cfparam name="devicetype" default="Unknown"/>

<cfset devicetype="Desktop"/>

<!DOCTYPE html>

<html lang="en">
  <head>
    <cfoutput>
      <meta charset="utf-8"/>
      <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <meta http-equiv="X-UA-Compatible" content="IE=edge"/>
        <title>#appName# | #pgTitle#</title>
        <meta content="#appDescription#" name="description"/>
        <meta content="#appAuthor#" name="author"/>
        <meta name="robots" content="noindex">
        </cfoutput>

        <cfinclude template="/include/qry/FindLinksT.cfm"/>
        <cfinclude template="/include/qry/FindLinksB.cfm"/>
        <cfset rev="13"/>

<cfloop query="FindLinksT">
          <cfoutput>

            <cfif "#findlinkst.linktype#" is "script">
              <script src="#findlinkst.linkurl#?ver=#rev#.4.#rand()#"></script>
            <cfelseif "#findlinkst.linktype#" is "script_include">
              <cfinclude template="#findlinkst.linkurl#">

            <cfelse>
              <link href="#findlinkst.linkurl#?ver=#rev#.3.1.2#rand()#" <cfif #findlinkst.rel# is not "">rel="#rel#" </cfif> type="text/css" <cfif #findlinkst.hrefid# is not "">id="#findlinkst.hrefid#"</cfif>/>
            </cfif>

          </cfoutput>
        </cfloop>

        <style>
          body.authentication-bg {
            background-color: <cfoutput>#hostcolor#</cfoutput>;
            background-size: cover;
            background-position: center;
          }
          .navbar-custom {
            background-color: <cfoutput>#hostcolor#</cfoutput>;
          }
        </style>
      </head>

      <body style="overflow-y: scroll!important;">
        <div id="wrapper">
          <cfinclude template="/include/topbar.cfm"/>
          <cfinclude template="/include/leftbar.cfm"/>

          <div class="content-page">
            <div class="content">
              <!--- Start Content --->
              <div class="container-fluid">
                <!--- Start Page Title --->
                <div class="row">
                  <cfif #pgid# is "17599999">
                    <cfinclude template="/include/core_title_175.cfm"/>
                  <CFELSE>
                    <cfinclude template="/include/core_title.cfm"/>
                  </cfif>
                </div>

                <cfif #pgFilename# is not "">
                  <cfinclude template="/include/#pgFilename#"/>
                </cfif>
              </div>
            </div>

            <cfinclude template="/include/footer.cfm"/>
          </div>
        </div>

        <cfparam name="pgdir" default=""/>
        <cfparam name="pgid" default="0"/>

        <!--- Modal for Support Center --->
        <div id="z" class="modal fade" tabindex="-1" role="dialog" aria-labelledby="standard-modalLabel">
          <div class="modal-dialog">
            <div class="modal-content">
              <div class="modal-header" >
                <h4 class="modal-title" id="standard-modalLabel">Support Center</h4>
                <button type="button" class="close" data-bs-dismiss="modal"></button>
              </div>
              <div class="modal-body">
                Click icon on the bottom right of the TAO program window
              </div>
            </div>
          </div>
        </div>

        <script>
          $(document).ready(function () {
            $("#remoteSupportForm").on("show.bs.modal", function (event) {

              $(this)
                .find(".modal-body")
                .load("/include/RemoteSupportForm.cfm<cfoutput>?pgid=#pgid#&pgdir=#pgdir#&qstring=#cgi.query_string#&userrole=#userrole#</cfoutput>");
            });
          });
        </script>


        <div id="remoteSupportForm" class="modal fade" tabindex="-1" role="dialog" aria-labelledby="standard-modalLabel">
          <div class="modal-dialog">
            <div class="modal-content">
              <div class="modal-header" >
                <h4 class="modal-title" id="standard-modalLabel">Support Center</h4>
                <button type="button" class="close" data-bs-dismiss="modal"></button>
              </div>
              <div class="modal-body"></div>
            </div>
          </div>
        </div>

        <script>
          window.onerror = function (message, source, lineno, colno, error) {
            console.error(`Error: ${message}\nSource: ${source}\nLine: ${lineno}\nColumn: ${colno}\nError object: ${JSON.stringify(error)}`);
            return true; // Prevents the default browser error handling
          };
        </script>

        <!--- Loop through FindLinksB query to include additional scripts and styles --->
        <cfloop query="FindLinksB">
          <cfoutput>
            <cfif "#findlinksb.linktype#" is "script">
              <script src="#findlinksb.linkurl#?ver=#rev#"></script>
            <cfelseif "#findlinksb.linktype#" is "script_include">
              <cfinclude template="#findlinksb.linkurl#">
            <cfelse>
              <link href="#findlinksb.linkurl#?rev=#rev#.7" <cfif #findlinksb.rel# is not ""> rel="#findlinksb.rel#"</cfif> type="text/css" <cfif #findlinksb.hrefid# is not ""> id="#findlinksb.hrefid#"</cfif>/>
            </cfif>
          </cfoutput>
        </cfloop>

        <script src="/app/assets/js/libs/devbridge-autocomplete/jquery.autocomplete.min.js?ver=0.00127548226092"></script>
        <cfinclude template="/include/autocomplete.cfm"/>

      </body>
    </html>
