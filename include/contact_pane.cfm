<!--- Contact Card View (Optimized) --->
<div id="contact-card-view2" class="d-flex flex-wrap mx-auto mt-3 px-2">

    <!--- Loop through active categories --->
    <cfloop query="ActiveCategories">

        <cfif catid neq "0">

            <!--- Include query for items in the current category --->
            <cfinclude template="/include/qry/itemsbycatActive.cfm" />

            <div class="flexit">
                <div class="contact-info-section mb-4 position-relative ps-5">

                    <cfoutput>
                        <!--- Icon for category --->
                        <i class="#ActiveCategories.caticon# <cfif result.itemsbycatActive.recordcount eq 0>text-muted font-weight-lighter</cfif> font-26 position-absolute top-0 start-0"></i>

                        <!--- Check for active items --->
                        <cfif result.itemsbycatActive.recordcount gt 0>
                            <!--- Loop through items by category --->
                            <cfloop query="result.itemsbycatActive">
                                
                                
                                <!--- Address Category --->
                                <cfif ActiveCategories.catfieldset is "address">
                                    <h5 class="mb-2">
                                        #valuestreetaddress#
                                        <a href="javascript:;" class="ms-2" data-bs-toggle="modal" data-bs-target="##remoteUpdateC#itemid#" title="Update">
                                            <i class="mdi mdi-square-edit-outline"></i>
                                        </a>
                             
                                        <cfif #ActiveCategories.catfieldset# is "company">Company!<CFABORT></CFIF>
                                        <cfif valueExtendedaddress neq "">
                                            <br>#valueExtendedaddress#
                                            <a href="javascript:;" class="ms-2" data-bs-toggle="modal" data-bs-target="##remoteUpdateC#itemid#" title="Update">
                                                <i class="mdi mdi-square-edit-outline"></i>
                                            </a>
                                        </cfif>

                                        <cfif valuecity neq "">
                                            <br>#valuecity#
                                            <cfif valueExtendedaddress eq "">
                                                <a href="javascript:;" class="ms-2" data-bs-toggle="modal" data-bs-target="##remoteUpdateC#itemid#" title="Update">
                                                    <i class="mdi mdi-square-edit-outline"></i>
                                                </a>
                                            </cfif>
                                        </cfif>

                                        <cfif valuecity neq "" and valueRegion neq "">
                                            , #valueRegion#
                                            <cfif valueExtendedaddress eq "">
                                                <a href="javascript:;" class="ms-2" data-bs-toggle="modal" data-bs-target="##remoteUpdateC#itemid#" title="Update">
                                                    <i class="mdi mdi-square-edit-outline"></i>
                                                </a>
                                            </cfif>
                                        </cfif>

                                        <cfif valuepostalcode neq "">
                                            &nbsp; #valuepostalcode#
                                        </cfif>
                                    </h5>
                                    <div class="text-uppercase font-13 text-left mb-1">#valuetype#</div>
                                </cfif>
                                
                                <!--- Company Category --->
                                <cfif ActiveCategories.catfieldset is "company">
                                    <h5 class="mb-2">
                                        #valueCompany#
                                        <a href="javascript:;" class="ms-2" data-bs-toggle="modal" data-bs-target="##remoteUpdateC#itemid#" title="Update">
                                            <i class="mdi mdi-square-edit-outline"></i>
                                        </a>
                                        
                                        <cfif valueTitle neq "">
                                            <br>#valueTitle#
                                        </cfif>
                                        
                                        <cfif valueDepartment neq "">
                                            <br>#valueDepartment#
                                        </cfif>
                                    </h5>
                                    <div class="text-uppercase font-13 text-left mb-1">#valuetype#</div>
                                </cfif>

                                <!--- Date Category --->
                                <cfif ActiveCategories.catfieldset is "date">
                                    <h5 class="mb-2">
                                        #Dateformat(itemdate)#
                                        <a href="javascript:;" class="ms-2" data-bs-toggle="modal" data-bs-target="##remoteUpdateC#itemid#" title="Update">
                                            <i class="mdi mdi-square-edit-outline"></i>
                                        </a>
                                    </h5>
                                    <div class="text-uppercase font-13 text-left mb-1">#valuetype#</div>
                                </cfif>

                                <!--- Long Text Category --->
                                <cfif ActiveCategories.catfieldset is "long">
                                    <h5 class="mb-2">#itemnotes#</h5>
                                    <div class="text-uppercase font-13 text-left mb-1">#valuetype#</div>
                                </cfif>

                                <!--- Text Category (Phone or Email) --->
                                <cfif ActiveCategories.catfieldset is "text">
                                    <cfif ActiveCategories.valueCategory is "Phone">
                                        <cfset phonenumber = valuetext />
                                        <cfinclude template="formatPhoneNumber.cfm" />
                                        <h5 class="mb-2">
                                            #formatPhoneNumber#
                                            <a href="javascript:;" class="ms-2" data-bs-toggle="modal" data-bs-target="##remoteUpdateC#itemid#" title="Update Phone">
                                                <i class="mdi mdi-square-edit-outline"></i>
                                            </a>
                                        </h5>     <div class="text-uppercase font-13 text-left mb-1">#valuetype#</div>
                                    </cfif>

                                    <cfif ActiveCategories.valueCategory is "Email">
                                        <h5 class="mb-2">
                                            <a href="mailto:#valuetext#" target="_blank">#valuetext#</a>
                                            <a href="javascript:;" class="ms-2" data-bs-toggle="modal" data-bs-target="##remoteUpdateC#itemid#" title="Update Email">
                                                <i class="mdi mdi-square-edit-outline"></i>
                                            </a>
                                        </h5>     <div class="text-uppercase font-13 text-left mb-1">#valuetype#</div>
                                    </cfif>
<cfif ActiveCategories.valueCategory is "Social Profile" or ActiveCategories.valueCategory is "URL">
    <!--- Ensure the URL starts with http:// --->
    <cfif Left(valuetext, 4) neq "http">
        <cfset valuetext = "http://" & valuetext>
    </cfif>



    <h5 class="mb-2">
        <a href="#valuetext#" target="_blank" title="#valuetype#">
            

                                                    #valuetext#

                                                </a>
     <a href="javascript:;" class="ms-2" data-bs-toggle="modal" data-bs-target="##remoteUpdateC#itemid#" title="Update #ActiveCategories.valueCategory#">
                                                <i class="mdi mdi-square-edit-outline"></i>
                                            </a>
    </h5>
       <div class="text-uppercase font-13 text-left mb-1">#valuetype#</div>
</cfif>


                         

                                </cfif>

                            </cfloop>
                        </cfif>

                        <!--- No items available --->
                        <cfif result.itemsbycatActive.recordcount eq 0>
                            <h5 class="text-muted font-weight-lighter">Add #ActiveCategories.valueCategory#</h5>
                        </cfif>

                        <!--- Add new item link --->
                        <a href="javascript:;" data-bs-toggle="modal" data-bs-target="##remoteAddC#ActiveCategories.catid#" title="Add #ActiveCategories.valueCategory#">
                            <i class="fe-plus-circle"></i>
                        </a>

                    </cfoutput>
                </div>
            </div>

        </cfif>

    </cfloop>

</div>

<cfset script_name_include="/include/#ListLast(GetCurrentTemplatePath(), "")#" />
