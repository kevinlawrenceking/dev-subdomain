<!--- This ColdFusion page displays toast notifications based on the presence of data in the 'toasts' query. --->
<cfinclude template="/include/qry/toasts_306_1.cfm" />
<cfinclude template="/include/qry/toastmenu_306_2.cfm" />

<!--- Check if 'bringtoast' is defined --->
<cfif #isdefined('bringtoast')#>
    <!--- Check if there are any records in the 'toasts' query --->
    <cfif #toasts.recordcount# is not "0">
        <div aria-live="polite" aria-atomic="true" data-delay="2000" style="z-index: 99">
            <div style="position: absolute; top: 4.5rem; right: 0;">
                <!--- Loop through each record in the 'toasts' query --->
                <cfloop query="toasts">
                    <cfoutput>
                        <div class="toast fade show" role="alert" aria-live="assertive" aria-atomic="true" data-bs-toggle="toast">
                            <div class="toast-header">
                                <img src="..<cfoutput>#application.imagesUrl#</cfoutput>/logo-sm.png" alt="brand-logo" height="12" class="mr-1" />
                                <strong class="mr-auto">#toasts.notiftitle#</strong>
                                <button type="button" class="ml-2 mb-1 close" data-bs-dismiss="toast" aria-label="Close">
                                    <span >
&times;</span>
                                </button>
                            </div>
                            <div class="toast-body">
                                <A Href="#toasts.notifurl#">
                                    <small class="text-muted">#toasts.subtitle# </small>
                                </A>
                                <BR/>
                                <center>
                                    <A Href="#toasts.notifurl#">
                                        <small class="text-muted"><i class="mdi mdi-square-edit-outline"></i></small>
                                    </A>
                                </center>
                            </div>
                        </div>
                    </cfoutput>
                </cfloop>
            </div>
        </div>
    </cfif>
</cfif>
