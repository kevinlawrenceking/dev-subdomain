<!--- This ColdFusion page displays modal dialogs for role updates and essence help, along with various details about audition roles and genres. --->

<div id="essencehelp" class="modal fade" tabindex="-1" aria-labelledby="standard-modalLabel" >

    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header" >
                <h4 class="modal-title" id="standard-modalLabel">Essences</h4>
                <button type="button" class="close" data-bs-dismiss="modal" >

                    <i class="mdi mdi-close-thick"></i>
                </button>
            </div>
            <div class="modal-body">
                <p>Branding is the identification and articulation of your unique, 3-dimensional essence. It is the key to getting your foot in the door and being remembered.</p>
                <p>Being able to track your auditionz through the lens of your brand essences will give you vital data on how you're perceived, what you do best, and your niche. I recommend using 3-5 brand essences here.</p>
                <p>Examples:<br>
                    <ul>
                        <li>Wealthy and manipulative narcissistic milf</li>
                        <li>Ambitious, strong truth seeker</li>
                        <li>Neurotic and Type-A mom who means well</li>
                        <li>Sensitive voice of reason everyone loves</li>
                    </ul>
                </p>
                <p>If you need support in identifying your brand and your essences, check out <a href="https://www.theactorsbrandingsystem.com/" target="new">The Actor's Branding System</a>.</p>
            </div>
        </div>
    </div>
</div>

<cfinclude template="/include/qry/audessences_audtion_xref_49_1.cfm" />

<cfoutput>
    <script>
        $(document).ready(function() {
            $("##roleupdate").on("show.bs.modal", function(event) {
                
                $(this).find(".modal-body").load("/include/roleupdateform.cfm?audprojectid=#audprojectid#&audroleid=#roledetails.audroleid#&new_audcatid=#projectDetails.audcatid#&pgdir=audition");
            });
        });
    </script>
    
    <!--- Modal for Role Update --->
    <div id="roleupdate" class="modal fade" tabindex="-1" aria-labelledby="standard-modalLabel" >

        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header" >
                    <h4 class="modal-title" id="standard-modalLabel">Role Update</h4>
                    <button type="button" class="close" data-bs-dismiss="modal" >

                        <i class="mdi mdi-close-thick"></i>
                    </button>
                </div>
                <div class="modal-body">
                </div>
            </div>
        </div>
    </div>
</cfoutput>

<div class="row">
    <cfoutput>
        <h4 class="p-1 d-flex">Role type: #roledetails.audroletype#
            <span class="ms-auto text-muted">
                <a href="javascript:;" data-bs-remote="true" data-bs-toggle="modal" data-bs-target="##roleupdate" data-bs-placement="top" title="Update Role" data-bs-original-title="Update Role">
                    <i class="mdi mdi-square-edit-outline"></i>
                </a>
            </span>
        </h4>

        <div class="col-md-12 col-lg-6 col-xl-4 p-1 text-nowrap"><strong>Role Name: </strong>#roledetails.audRoleName#</div>
        <div class="col-md-12 p-1"><strong>Character Description: </strong>#roledetails.charDescription#</div>
    </cfoutput>

    <div class="col-md-12 p-1 text-nowrap">
        <strong>Age Range: </strong>
        <cfif #audageranges_audtion_xref.recordcount# is not "0">
            <cfloop query="audageranges_audtion_xref">
                <cfoutput>
                    <a href="javascript:;" data-bs-remote="true" data-bs-toggle="modal" data-bs-target="##remoteUpdateTag" data-bs-placement="top" title="Update Tag" data-bs-original-title="Update Tag">
                        <span class="badge badge-blue" style="font-size: 12px; font-weight: 500;">#audageranges_audtion_xref.rangename#</span>
                    </a>
                </cfoutput>
            </cfloop>
        </cfif>
    </div>

    <div class="col-md-12 p-1 text-nowrap">
        <strong>
            <a href="" title="click for details" data-bs-toggle="modal" data-bs-target="#essencehelp">Essences
                <i class="fe-info font-14 mr-1"></i>
            </a>:
        </strong>
        <cfif #audessences_audtion_xref.recordcount# is not "0">
            <cfloop query="audessences_audtion_xref">
                <cfoutput>
                    <a href="javascript:;" data-bs-remote="true" data-bs-toggle="modal" data-bs-target="##remoteUpdateessence" data-bs-placement="top" title="Update Tag" data-bs-original-title="Update Tag">
                        <span class="badge badge-blue" style="font-size: 12px; font-weight: 500;">#audessences_audtion_xref.essencename#</span>
                    </a>
                </cfoutput>
            </cfloop>
        </cfif>
    </div>

    <cfinclude template="/include/qry/findit_49_2.cfm" />

    <cfif #int(findit.recordcount)# is not "0">
        <cfif #audcatid# is not "5">
            <cfinclude template="/include/qry/audgenres_audition_xref.cfm" />
            <div class="col-md-12 p-1 text-nowrap">
                <strong>Genre:</strong>
                <cfif #audgenres_audition_xref.recordcount# is not "0">
                    <cfloop query="audgenres_audition_xref">
                        <cfoutput>
                            <a href="javascript:;" data-bs-remote="true" data-bs-toggle="modal" data-bs-target="##remoteUpdategenre" data-bs-placement="top" title="Update Genre" data-bs-original-title="Update Genre">
                                <span class="badge badge-blue" style="font-size: 12px; font-weight: 500;">#audgenres_audition_xref.audgenre#</span>
                            </a>
                        </cfoutput>
                    </cfloop>
                </cfif>
            </div>
        </cfif>

        <cfif #audcatid# is "5" and #new_audsubcatid# is "34">
            <cfinclude template="/include/qry/audgenres_audition_xref.cfm" />
            <div class="col-md-12 p-1 text-nowrap">
                <strong>Genre:</strong>
                <cfif #audgenres_audition_xref.recordcount# is not "0">
                    <cfloop query="audgenres_audition_xref">
                        <cfoutput>
                            <a href="javascript:;" data-bs-remote="true" data-bs-toggle="modal" data-bs-target="##remoteUpdategenre" data-bs-placement="top" title="Update Genre" data-bs-original-title="Update Genre">
                                <span class="badge badge-blue" style="font-size: 12px; font-weight: 500;">#audgenres_audition_xref.audgenre#</span>
                            </a>
                        </cfoutput>
                    </cfloop>
                </cfif>
            </div>
        </cfif>
    </cfif>

    <cfif #audcatid# is "5">
        <cfoutput>
            <div class="col-md-12 col-lg-6 col-xl-4 p-1 text-nowrap"><strong>Dialect: </strong>#roledetails.auddialect#</div>
        </cfoutput>
    </cfif>

    <cfoutput>
        <div class="col-md-12 col-lg-6 col-xl-4 p-1 text-nowrap"><strong>Source: </strong>
            <cfif #roledetails.audsource# is "My Team" and #roledetails.contactname# is not "">
                #roledetails.contactname# (My Team)
            <cfelseif #roledetails.audsource# is "Referral" and #roledetails.contactname# is not "">
                #roledetails.contactname# (Referral)
            <cfelseif #roledetails.audsource# is "Open Call" and #roledetails.opencallid# is not "">
                Open Call (#roledetails.opencallname#)
            <cfelse>
                #roledetails.audsource# <cfif #roledetails.submitsitename# is not "">(#roledetails.submitsitename#)</cfif>
            </cfif>
        </div>
    </cfoutput>

    <cfif #new_audsubcatid# is "34">
       <cfinclude template="/include/qry/audvocaltypes_audition_xref.cfm" />
        <div class="col-md-12 p-1">
            <strong>Vocal Quality: </strong>
          <!---  <cfif #audvocaltypes_audition_xref.recordcount# is not "0"> --->
                <cfloop query="audvocaltypes_audition_xref">
                    <cfoutput>
                        <a href="javascript:;" data-bs-remote="true" data-bs-toggle="modal" data-bs-target="##remoteUpdateTag" data-bs-placement="top" title="Update Tag" data-bs-original-title="Update Tag">
                            <span class="badge badge-blue" style="font-size: 12px; font-weight: 500;">#audvocaltypes_audition_xref.vocaltype#</span>
                        </a>
                    </cfoutput>
                </cfloop>
            <!---   </cfif> --->
        </div>
    </cfif>

</div>
