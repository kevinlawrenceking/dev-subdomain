<!--- This ColdFusion page displays a diagnostics modal and a footer with device information and links. --->
<div id="diagnostics" class="modal fade" tabindex="-1" role="dialog" >

    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <h4 class="modal-title">
                    <cfoutput>Diagnostics</cfoutput>
                </h4>
                <button type="button" class="close" data-bs-dismiss="modal" >

                    <i class="mdi mdi-close-thick"></i>
                </button>
            </div>
            <div class="modal-body">
                <cfoutput>
                    <cfsavecontent variable="diagnostics">
                        <!--- Check if pgid is defined and output its value --->
                        <cfif #isdefined('pgid')#>
                            pgid: #pgid#<br />
                        </cfif>
                        <!--- Check if ref_pgid is defined and output its value --->
                        <cfif #isdefined('ref_pgid')#>
                            ref_pgid: #ref_pgid#<br />
                        </cfif>
                        <!--- Check if userid is defined and output its value --->
                        <cfif #isdefined('userid')#>
                            userid: #userid#<br />
                        </cfif>
                        <!--- Check if cookie.uploadDir is defined and output its value --->
                        <cfif #isdefined('cookie.uploadDir')#>
                            cookie.uploadDir: #cookie.uploadDir#<br />
                        </cfif>
                        <!--- Check if cookie.return_url is defined and output its value --->
                        <cfif #isdefined('cookie.return_url')#>
                            cookie.return_url: #cookie.return_url#<br />
                        </cfif>
                        <!--- Check if browser_contact_avatar_loc is defined and output its value --->
                        <cfif #isdefined('browser_contact_avatar_loc')#>
                            browser_contact_avatar_loc: #browser_contact_avatar_loc#<br />
                        </cfif>
                        <!--- Check if image_url is defined and output its value --->
                        <cfif #isdefined('image_url')#>
                            image_url: #image_url#<br />
                        </cfif>
                    </cfsavecontent>
                    <p>#diagnostics#</p>
                </cfoutput>
            </div>
        </div>
    </div>
</div>

<footer class="footer">
    <div class="container-fluid">
        <div class="row">
            <div class="col-md-6">
                <cfoutput>
                    #devicetype# version. #this.formatDate('#now()#','YYYY')# 
                    <!--- Check if userid is "30" and if currentStartDate is defined, output the current date --->
                    <cfif #userid# is "30">
                        <cfif #isdefined('currentStartDate')#>
                            current date: #this.formatDate('#currentstartdate#')#
                        </cfif>
                    </cfif>
                </cfoutput>&reg; The Actor's Office LLC - All rights reserved
            </div>
            <div class="col-md-6">
                <div class="text-md-end footer-links d-none d-sm-block">
                    <a href="https://www.theactorsoffice.com" target="_blank">TAO Website</a>
                    <a href="javascript:;" data-bs-remote="true" data-bs-toggle="modal" data-bs-target="#diagnostics" data-bs-placement="top" title="Diagnostics">Diagnostics</a>
                </div>
            </div>
        </div>
    </div>
</footer>
