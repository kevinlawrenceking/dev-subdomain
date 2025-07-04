<cfif isdefined('isexport') and isexport EQ "Y">
<Cfset session.projectlist = projectlist />
<Cflocation url="/include/export_auditions.cfm" />
</cfif>


<cfinclude template="/include/audition_check.cfm"/>
<cfinclude template="/include/qry/audcategories_sel.cfm"/>

<cfparam name="isexport" default="N"/>
<cfparam name="sel_audcatid" default="%"/>

<script>
    $(document).ready(function () {

        $("#remoteaudadd").on("show.bs.modal", function (event) {
            var $modal = $(this);
            var cacheBuster = new Date().getTime(); 
            var loadUrl = "/include/remoteaudadd.cfm?userid=<cfoutput>#userid#</cfoutput>&isdirect=0&_=" + cacheBuster;

            $modal.find(".modal-body").html("<p>Loading...</p>");

           $modal.find(".modal-body").load(loadUrl, function (response, status, xhr) {
                if (status === "error") {
                     $modal.find(".modal-body").html("<p>Error loading content. Please try again.</p>");
                } else {
                 
                    $modal.find(".modal-body").focus();
                }
            });
        });
    });
</script>

<div id="remoteaudadd" class="modal fade" tabindex="-1" aria-labelledby="standard-modalLabel" >

    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header" >
                <h4 class="modal-title" id="standard-modalLabel">Audition Type</h4>
                <button type="button" class="close" data-bs-dismiss="modal" >

                    <i class="mdi mdi-close-thick"></i>
                </button>
            </div>
            <div class="modal-body"></div>
        </div>
    </div>
</div>

<script>
    $(document).ready(function () {
        
        $("#remoteaudadddirect").on("show.bs.modal", function (event) {
            
            $(this).find(".modal-body").load("/include/remoteaudadd.cfm?userid=<cfoutput>#userid#</cfoutput>&isdirect=1");
        });
    });
</script>

<div id="remoteaudadddirect" class="modal fade" tabindex="-1" aria-labelledby="standard-modalLabel" >

    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header" >
                <h4 class="modal-title" id="standard-modalLabel">Direct Booking Type</h4>
                <button type="button" class="close" data-bs-dismiss="modal" >

                    <i class="mdi mdi-close-thick"></i>
                </button>
            </div>
            <div class="modal-body"></div>
        </div>
    </div>
</div>

<!--- Determine view type based on viewtypeid --->
<cfif #viewtypeid# is "1">
    <cfparam name="view" default="tbl"/>
<cfelse>
    <cfparam name="view" default="glry"/>
</cfif>

<cfinclude template="/include/qry/up_31_1.cfm" />
<cfinclude template="/include/qry/audsteps_sel_31_2.cfm" />
<cfinclude template="/include/qry/audtypes_sel_31_3.cfm" />

<div class="container px-1">
    <div class="row">
        <div class="col-12">
            <div class="card mb-3">
                <div class="card-body">

                    <cfset i=0>

                    <form action="/app/auditions/">

                        <cfoutput>
                            <input type="hidden" name="view" value="#view#"/>
                        </cfoutput>

                        <div class="row">
                            <div class="col-lg-4 pb-1">
                                <a href="" class="btn btn-primary waves-effect waves-light" data-bs-remote="true" data-bs-toggle="modal" data-bs-target="#remoteaudadd" data-bs-placement="top" title="Add Audition" data-bs-original-title="Add Audition">
                                    Add Audition
                                </a>

                                <a href="" class="btn btn-success waves-effect waves-light" data-bs-remote="true" data-bs-toggle="modal" data-bs-target="#remoteaudadddirect" data-bs-placement="top" title="Add Direct booking" data-bs-original-title="Add Direct Booking">
                                    Direct Booking
                                </a>
                            </div>

                            <div class="col-lg-4 pb-1">
                                <select id="audstepid" name="sel_audstepid" class="form-control" onchange="this.form.submit()">
                                    <option value="%">All Statuses</option>
                                    <option value="1" <cfif #sel_audstepid# is "1"> Selected </cfif>>Audition</option>
                                    <option value="2" <cfif #sel_audstepid# is "2"> Selected </cfif>>Callback</option>
                                    <option value="3" <cfif #sel_audstepid# is "3"> Selected </cfif>>Redirect</option>
                                    <option value="4" <cfif #sel_audstepid# is "4"> Selected </cfif>>Pin/Avail</option>
                                    <option value="5" <cfif #sel_audstepid# is "5"> Selected </cfif>>Booking</option>
                                    <option value="999" <cfif #sel_audstepid# is "999"> Selected </cfif>>Direct Booking</option>
                                </select>
                            </div>

                            <div class="col-lg-4 pb-1">
                                <select id="audcatid" class="form-control" name="sel_audcatid" onchange="this.form.submit()">
                                    <option value="%">All Categories</option>
                                    <cfoutput query="audcategories_sel">
                                        <cfif #audcategories_sel.id# is "#sel_audcatid#">
                                            <option value="#audcategories_sel.id#" Selected="Selected">#audcategories_sel.name#</option>
                                        <cfelse>
                                            <option value="#audcategories_sel.id#">#audcategories_sel.name#</option>
                                        </cfif>
                                    </cfoutput>
                                </select>
                            </div>

                            <div class="col-lg-4 d-flex">
                                <span>
                                    <Cfif #view# is "tbl">
                                        <cfset table_button="btn-secondary"/>
                                        <cfset gallery_button="btn-outline-secondary"/>
                                    </Cfif>

                                    <Cfif #view# is "glry">
                                        <cfset table_button="btn-outline-secondary"/>
                                        <cfset gallery_button="btn-secondary"/>
                                    </Cfif>

                                    <a href="<cfoutput>/app/auditions/?sel_audstepid=#sel_audstepid#&sel_audtype=#sel_audtype#&sel_contactid=#sel_contactid#&sel_coname=#sel_coname#&auddate=#auddate#&audsearch=#audsearch#&view=tbl&materials=#materials#" class="btn btn-xs #table_button# waves-effect waves-light</cfoutput>">
                                        <i class="mdi mdi-menu fa-2x"></i>
                                    </a>
                                    &nbsp;

                                    <a href="<cfoutput>/app/auditions/?sel_audstepid=#sel_audstepid#&sel_audtype=#sel_audtype#&sel_contactid=#sel_contactid#&sel_coname=#sel_coname#&auddate=#auddate#&audsearch=#audsearch#&view=glry&materials=#materials#" class="btn btn-xs #gallery_button# waves-effect waves-light</cfoutput>">
                                        <i class="mdi mdi-drag fa-2x"></i>
                                    </a>

                                    &nbsp;&nbsp;

                                    <a href="<cfoutput>/app/auditions/?sel_audstepid=#sel_audstepid#&sel_audtype=#sel_audtype#&sel_contactid=#sel_contactid#&sel_coname=#sel_coname#&auddate=#auddate#&audsearch=#audsearch#&view=#view#&isexport=y&materials=#materials#" class="btn btn-xs btn-outline-secondary waves-effect waves-light</cfoutput>" title="Export Auditions">
                                        <i class="mdi mdi-export fa-2x"></i>
                                    </a>

                                    &nbsp;&nbsp;

                                    <a href="<cfoutput>/app/auditions-import/" class="btn btn-xs btn-outline-secondary waves-effect waves-light</cfoutput>" title="Import Auditions">
                                        <i class="mdi mdi-import fa-2x"></i>
                                    </a>
                                </span>
                            </div>

<input type="hidden" name="auddate" value="%"/>

<cfinclude template="/include/qry/cds_31_4.cfm" />
                            <cfinclude template="/include/qry/cos_31_5.cfm" />
                            <cfparam name="sel_coname" default="%"/>

                            <div class="col-lg-4 pb-1">
                                <select id="sel_contactid" name="sel_contactid" class="form-control" onchange="this.form.submit()">
                                    <option value="%">All Casting Directors</option>
                                    <cfoutput query="cds">
                                        <option value="#cds.contactid#" <cfif "#cds.contactid#" is "#sel_contactid#">selected</cfif>>#cds.cd#</option>
                                    </cfoutput>
                                </select>
                            </div>

                            <div class="col-lg-4 pb-1">
                                <select id="sel_coname" name="sel_coname" class="form-control" onchange="this.form.submit()">
                                    <option value="%">All Companies</option>
                                    <cfoutput query="cos">
                                        <option value="#cos.valueCompany#" <cfif "#cos.valueCompany#" is "#sel_coname#" >Selected</cfif>>#cos.valueCompany#</option>
                                    </cfoutput>
                                </select>
                            </div>

                            <div class="col-lg-4 pb-1"></div>

                            <div class="col-lg-8 pb-1">
                                <div class="app-search-box dropdown">
                                    <div class="input-group">
                                        <input type="text" class="form-control" name="audsearch" value="<cfoutput>#audsearch#</cfoutput>" id="audsearch" placeholder="Search..." autocomplete="off">
                                        &nbsp;
                                        <div class="input-group-append">
                                            <button class="btn btn-xs btn-primary waves-effect waves-light" id="mybtn" style="height:100%;" type="submit">
                                                <i class="fe-search"></i>
                                            </button>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </form>
                    </div>
                </div>
<div class="container p-3">
                <div class="row">


<cfif view eq "glry">

    <!--- Display Message if No Events Found --->
    <cfif results.recordcount eq 0>
        <p>No events found</p>
    <cfelse>
        <p>
            <cfoutput>
                <strong>#results.recordcount#</strong> audition<cfif results.recordcount neq 1>s</cfif> found
            </cfoutput>
        </p>

             
    
        <!--- Audition Gallery Container --->
        <div class="container">
            <div class="row tao-card-row row-cols-1 row-cols-sm-2 row-cols-md-2 row-cols-lg-2 row-cols-xl-3 g-3">

                
                <cfloop query="results">

        <cfset card_id=results.recid/>
        <cfset aud_cat_icon=""/>
        <cfset card_avatar="Yes"/>
        <Cfset card_casting=results.castingfullname/>
        <Cfset card_source=results.col5 />
      <cfif results.audroletype neq "">
    <cfset card_company = results.col4 & " (" & results.audroletype & ")" />
<cfelse>
    <cfset card_company = results.col4 />
</cfif>
<cfif results.projdate is not "">
<cfset cardYear = year(results.projdate) />
<cfelse>
<cfset cardYear = "n/a">
</cfif>
  <cfset card_view_icon_yn = "N">
        <cfset card_delete_msg=""/>
        <cfset card_delete=""/>
        <cfset card_details="/app/audition/?audprojectid=" & results.recid/>
        <cfset card_email=""/>
        <cfset card_name = ""/>
        <Cfset card_footer_text=""/>
        <cfset card_footer_type=""/>
        <cfset card_footer_yn="N"/>
        <cfset card_header_text=results.col2/>
        <cfset card_header_yn="Y"/>
        <cfset card_icon_yn="Y"/>
        <cfset card_image="#application.datesUrl#/#DateFormat('#results.col1#','mm-dd')#.png"/>
        <Cfset namecolor = "dark"/>
        <cfset card_phone=""/>
        <cfset card_ribbon1=""/>
        <cfset card_ribbon2=""/>
        <cfset card_social_yn="N"/>
        <cfset card_title = results.col3 />
        <cfset card_subtitle = results.audsubcatname />
        <cfset card_top_ribbon="Yes"/>
        <cfset ribbon_icon=""/>
        <cfset card_reminder=""/>
        <cfset card_remove = ""/>
        <cfset card_remove_msg = ""/>
        <cfset card_image_type = "calendar"/>
        <cfset card_image_yn = "Y"/>
        <cfset card_badge_yn = "N" />
        <cfset card_ribbon_straight_body = "" />

<cfoutput>

                        <!--- Determine Audition Status --->
                        <cfset col6 = "Audition">

    <cfset col6 = "">

<cfif results.isbooked eq "1">
    <cfset col6 = listAppend(col6, "Booked")>
</cfif>

<cfif results.ispin eq "1">
    <cfset col6 = listAppend(col6, "Pin")>
</cfif>

<cfif results.isredirect eq "1">
    <cfset col6 = listAppend(col6, "Redirect")>
</cfif>

<cfif results.iscallback eq "1">
    <cfset col6 = listAppend(col6, "Callback")>
</cfif>


    <cfset card_ribbon_straight = col6 />

                        <!--- Card Layout --->
                <div class="col">

  <!--- Set Card Variables --->
 
 
  <cfif col6 neq "Booked" and col6 neq "Audition">
    <cfset card_footer_text=col6/>
  <cfelse>
    <cfset card_footer_text="">
  </cfif>
  <cfset card_ribbon2=""/>
  <Cfset card_delete=""/>
 
  <Cfset card_icon=results.aud_cat_icon/>
  <cfif results.isbooked eq "1">

    <Cfset card_top_ribbon="Booked"/>
    <Cfelse>
    <Cfset card_top_ribbon=""/>
  </cfif>
<cfset card_id = results.recid />


  <!--- Include the Card Template --->
  <cfinclude template="/include/card.cfm"/>
</div>

                    </cfoutput>
                </cfloop>

            </div> <!--- End Row --->
        </div> <!--- End Container --->

        <!--- Placeholder for Pagination (if needed) --->
        <div class="pagination-container text-center mt-4">
            <!-- Pagination will be added dynamically -->
        </div>

    </cfif>

</cfif>






                    <cfif #view# is "tbl">
                        <div class="container">
                            <div class="card pb-3">
                                <div class="card-body">
                                    <cfif #results.recordcount# is "0">
                                        <p>No events found</p>
                                    </cfif>

                                    <cfif #results.recordcount# is not "0">
                                        <p>
                                            <cfoutput>
                                                <strong>#results.recordcount#</strong> audition<cfif #results.recordcount# is not "1">s</cfif> found
                                            </cfoutput>
                                        </p>
                                    </cfif>

                                    <table id="basic-datatable" class="table dt-responsive nowrap w-100 table-striped" role="grid">
                                        <thead>
                                            <cfloop query="results" endrow="1">
                                                <cfoutput>
                                                    <cfif (Results.CurrentRow MOD 2)>
                                                        <Cfset rowtype="Odd"/>
                                                    <cfelse>
                                                        <Cfset rowtype="Even"/>
                                                    </cfif>

                                                    <tr class="#rowtype#">
                                                        <th width="50">Action</th>
                                                        <th>#results.head1#</th>
                                                        <th>#results.head2#</th>
                                                        <th>#results.head3#</th>
                                                        <th>#results.head4#</th>
                                                        <th>#results.head5#</th>
                                                        <th>#results.head6#</th>
                                                    </tr>
                                                </cfoutput>
                                            </cfloop>
                                        </thead>
                                        <tbody>
                                            <cfloop query="results">
                                                <cfoutput>
                                                    <cfif #results.isbooked# is "1">
                                                        <cfset col6="Booked"/>
                                                    <cfelseif #results.ispin# is "1">
                                                        <cfset col6="Pin"/>
                                                    <cfelseif #results.isredirect# is "1">
                                                        <cfset col6="Redirect"/>
                                                    <cfelseif #results.iscallback# is "1">
                                                        <cfset col6="Callback"/>
                                                    <cfelse>
                                                        <cfset col6="Audition"/>
                                                    </cfif>
                                                </cfoutput>
                                                <cfoutput>
                                                    <tr>
                                                        <td>
                                                            <a href="/app/audition/?audprojectid=#results.recid#" class="btn btn-xs btn-primary waves-effect waves-light">
                                                                <i class="mdi mdi-eye-outline"></i>
                                                            </a>
                                                        </td>

                                                        <td style="word-break: break-all;">
                                                            <span>#this.formatDate(results.col1)#</span>
                                                            #this.formatDate(results.col1)#
                                                        </td>

                                                        <td style="word-break: break-all;">#results.col2#</td>
                                                        <td style="word-break: break-all;">
                                                            <cfif #results.col3#is not "">
                                                                <cfif #results.col3# is "My Team" and #results.contactname#is not "">
                                                                    #results.contactname#
                                                                <cfelse>
                                                                    #results.col3#
                                                                </cfif>
                                                            <cfelse>
                                                                TBD
                                                            </cfif>
                                                        </td>
                                                        <td style="word-break: break-all;">#results.col4#</td>
                                                        <td style="word-break: break-all;">#results.col5#</td>
                                                        <td style="word-break: break-all;">#col6#</td>
                                                    </tr>
                                                </cfoutput>
                                            </cfloop>
                                        </tbody>
                                    </table>
                                </div>
                            </div>
                        </div>

                        <SCRIPT>
                            $(document).ready(function () {
                                $("#basic-datatable").DataTable({
                                    "bFilter": false,
                                    "dom": 'rtip',
                                    "pageLength": 100,
                                    responsive: true,
                                    language: {
                                        paginate: {
                                            previous: "<i class='mdi mdi-chevron-left'>",
                                            next: "<i class='mdi mdi-chevron-right'>"
                                        }
                                    },
                                    drawCallback: function () {
                                        $(".dataTables_paginate > .pagination").addClass("pagination-rounded")
                                    }
                                });
                                var a = $("#datatable-buttons").DataTable({
                                    lengthChange: !1,
                                    buttons: [
                                        {
                                            extend: "copy",
                                            className: "btn-light"
                                        }, {
                                            extend: "print",
                                            className: "btn-light"
                                        }, {
                                            extend: "pdf",
                                            className: "btn-light"
                                        }
                                    ],
                                    language: {
                                        paginate: {
                                            previous: "<i class='mdi mdi-chevron-left'>",
                                            next: "<i class='mdi mdi-chevron-right'>"
                                        }
                                    },
                                    drawCallback: function () {
                                        $(".dataTables_paginate > .pagination").addClass("pagination-rounded")
                                    }
                                });
                            });
                        </SCRIPT>
                    </cfif>
               </div>
                </div>
                <!--- end card body --->
            </div>
            <!--- end card --->
        </div>
        <!--- end col --->
    </div>

