<cfinclude template="/include/qry/menuitems.cfm">
<cfinclude template="/include/qry/menuItemsa_496_2.cfm">
<cfinclude template="/include/qry/menuItemsAud_496_3.cfm">

<cfinclude template="/include/pgload.cfm"/>

<cfparam name="devicetype" default="Unknown"/>

<cfset devicetype="Desktop"/>

<!DOCTYPE html>

<html lang="en">
  <head>

    <script> helpwiseSettings = { widget_id: '65958ef4eb602', align: 'right' } </script>

<script src="https://cdn.helpwise.io/assets/js/livechat.js"></script>
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
        <cfset rev="14"/>

<cfloop query="FindLinksT">
            <cfif findlinkst.linktype IS "script">
              <cfoutput><script src="#findlinkst.linkurl#?v=#rev#"></script></cfoutput>
            <cfelseif findlinkst.linktype IS "script_include">
              <!--- Guard against path traversal in database-sourced include path --->
              <cfif find("..", findlinkst.linkurl) EQ 0>
                <cfinclude template="#findlinkst.linkurl#">
              </cfif>
            <cfelse>
              <cfoutput><link href="#findlinkst.linkurl#?v=#rev#" <cfif findlinkst.rel IS NOT "">rel="#findlinkst.rel#" </cfif> type="text/css" <cfif findlinkst.hrefid IS NOT "">id="#findlinkst.hrefid#"</cfif>/></cfoutput>
            </cfif>
        </cfloop>

        <link rel="stylesheet" href="/app/assets/css/tao-components.css" />
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
        <cfif structKeyExists(session, "csrfToken")>
          <cfoutput><meta name="csrf-token" content="#session.csrfToken#"></cfoutput>
        </cfif>
      </head>

      <body>
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

                <cfif #pgFilename# is not "" AND find("..", pgFilename) EQ 0>
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
        <div id="z" class="modal fade" tabindex="-1" role="dialog" aria-labelledby="supportCenterLabel">
          <div class="modal-dialog">
            <div class="modal-content">
              <div class="modal-header" >
                <h4 class="modal-title" id="supportCenterLabel">Support Center</h4>
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


        <div id="remoteSupportForm" class="modal fade" tabindex="-1" role="dialog" aria-labelledby="remoteSupportLabel">
          <div class="modal-dialog">
            <div class="modal-content">
              <div class="modal-header" >
                <h4 class="modal-title" id="remoteSupportLabel">Support Center</h4>
                <button type="button" class="close" data-bs-dismiss="modal"></button>
              </div>
              <div class="modal-body"></div>
            </div>
          </div>
        </div>

        <script>
          window.onerror = function (message, source, lineno, colno, error) {
            // Filter out errors from browser extensions and third-party scripts
            // These are outside our control and don't affect app functionality
            var isThirdPartyError = false;

            // Check for common browser extension patterns in source
            if (source) {
              var extPatterns = [
                'web-client-content-script', // Specific extension causing the error
                'content-script',      // Generic extension content scripts
                'chrome-extension://', // Chrome extensions
                'moz-extension://',    // Firefox extensions
                'safari-extension://', // Safari extensions
                'edge-extension://',   // Edge extensions
                'extension://',        // Generic extension URLs
                'cdn.helpwise.io',     // Helpwise livechat (third-party)
                'livechat'             // Livechat scripts
              ];

              for (var i = 0; i < extPatterns.length; i++) {
                if (source.toLowerCase().indexOf(extPatterns[i].toLowerCase()) !== -1) {
                  isThirdPartyError = true;
                  break;
                }
              }
            }

            // Check for known third-party error messages from extensions
            // These errors originate from extension scripts trying to interact with page content
            if (!isThirdPartyError && message && source) {
              // Specific check for MutationObserver errors from content scripts
              if (message.indexOf('MutationObserver') !== -1 &&
                  message.indexOf('parameter 1 is not of type') !== -1 &&
                  source.indexOf('content-script') !== -1) {
                isThirdPartyError = true;
              }
              // Check for ResizeObserver errors (common with extensions)
              if (!isThirdPartyError &&
                  message.indexOf('ResizeObserver') !== -1 &&
                  source.indexOf('content-script') !== -1) {
                isThirdPartyError = true;
              }
            }

            // Suppress third-party errors silently, log app errors
            if (!isThirdPartyError) {
              console.error('Error: ' + message + '\nSource: ' + source + '\nLine: ' + lineno + '\nColumn: ' + colno + '\nError object: ' + JSON.stringify(error));
            }

            return true; // Prevents the default browser error handling
          };
        </script>

        <!--- Loop through FindLinksB query to include additional scripts and styles --->
        <cfloop query="FindLinksB">
            <cfif findlinksb.linktype IS "script">
              <cfoutput><script src="#findlinksb.linkurl#?v=#rev#"></script></cfoutput>
            <cfelseif findlinksb.linktype IS "script_include">
              <cfif find("..", findlinksb.linkurl) EQ 0>
                <cfinclude template="#findlinksb.linkurl#">
              </cfif>
            <cfelse>
              <cfoutput><link href="#findlinksb.linkurl#?v=#rev#" <cfif findlinksb.rel IS NOT ""> rel="#findlinksb.rel#"</cfif> type="text/css" <cfif findlinksb.hrefid IS NOT ""> id="#findlinksb.hrefid#"</cfif>/></cfoutput>
            </cfif>
        </cfloop>

        <script src="/app/assets/js/libs/devbridge-autocomplete/jquery.autocomplete.min.js?v=<cfoutput>#rev#</cfoutput>"></script>
        <cfinclude template="/include/autocomplete.cfm"/>
        <script src="/app/assets/js/tao-toast.js?v=<cfoutput>#rev#</cfoutput>"></script>

        <script>
          (function(){
            var token = document.querySelector('meta[name="csrf-token"]');
            if (token && typeof jQuery !== 'undefined') {
              jQuery.ajaxSetup({
                beforeSend: function(xhr, settings) {
                  if (settings.type && settings.type !== 'GET') {
                    xhr.setRequestHeader('X-CSRF-Token', token.getAttribute('content'));
                  }
                }
              });
            }
            if (token) {
              document.addEventListener('submit', function(e) {
                var form = e.target;
                if (form.tagName === 'FORM' && form.method && form.method.toLowerCase() === 'post') {
                  if (!form.querySelector('input[name="csrfToken"]')) {
                    var input = document.createElement('input');
                    input.type = 'hidden';
                    input.name = 'csrfToken';
                    input.value = token.getAttribute('content');
                    form.appendChild(input);
                  }
                }
              });
            }
          })();
        </script>

      </body>
    </html>
