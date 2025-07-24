<!--- 
===========================================================================================
AUDITIONS MAIN INTERFACE
===========================================================================================

Purpose: 
- Main interface for managing auditions in the TAO Relationship System
- Provides comprehensive view of audition projects with filtering, searching, and export capabilities
- Supports both table and gallery view modes for audition data display

Part of TAO Relationship System:
- Audition Tracking and Management Module
- Integrates with Contact Management for casting director information
- Supports audition workflow tracking (Audition → Callback → Redirect → Pin/Avail → Booking)

Database Tables/Components:
- audprojects (main audition project data)
- audroles (audition role information)
- audcategories (audition categories)
- audsteps (audition workflow steps)
- audtypes (audition types)
- events_tbl (audition events and appointments)
- contactdetails (casting director information)
- AuditionProjectService (main service component)
- AuditionStepService (workflow step management)
- AuditionTypeService (audition type management)

Key Features:
- Dual view modes (table/gallery)
- Advanced filtering (status, category, casting director, company)
- Search functionality
- Export capabilities
- Direct booking support
- Modal-based audition entry
- Responsive card-based gallery display

===========================================================================================
--->

<!--- Export handling --->
<cfif isdefined('isexport') and isexport EQ "Y">
    <cfset session.projectlist = projectlist />
    <cflocation url="/include/export_auditions.cfm" />
</cfif>

<!--- Core includes and security check --->
<cfinclude template="/include/audition_check.cfm"/>
<cfinclude template="/include/qry/audcategories_sel.cfm"/>

<!--- Parameter definitions --->
<cfparam name="isexport" default="N"/>
<cfparam name="sel_audcatid" default="%"/>
<!--- Pagination parameters --->
<cfparam name="page" default="1"/>
<cfparam name="pageSize" default="12"/>
<cfparam name="totalRecords" default="0"/>

<!--- JavaScript for modal functionality --->
<style>
    /* Enhanced pagination styling */
    .pagination-rounded .page-link {
        border-radius: 50px;
        margin: 0 2px;
        border: 1px solid #dee2e6;
        color: #6c757d;
        font-weight: 500;
        transition: all 0.15s ease-in-out;
    }
    
    .pagination-rounded .page-item.active .page-link {
        background-color: #007bff;
        border-color: #007bff;
        color: white;
        font-weight: 600;
    }
    
    .pagination-rounded .page-link:hover:not(.disabled) {
        background-color: #e9ecef;
        border-color: #adb5bd;
        color: #495057;
        transform: translateY(-1px);
    }
    
    .pagination-rounded .page-item.disabled .page-link {
        color: #adb5bd;
        background-color: transparent;
        border-color: #dee2e6;
    }
    
    /* Gallery pagination specific styling */
    .gallery-pagination {
        background: linear-gradient(135deg, #f8f9fa 0%, #e9ecef 100%);
        border-radius: 10px;
        padding: 20px;
        margin-top: 30px;
        box-shadow: 0 2px 10px rgba(0,0,0,0.1);
    }
    
    /* Card animation for page transitions */
    .tao-card-row .col {
        animation: fadeInUp 0.6s ease-out;
    }
    
    @keyframes fadeInUp {
        from {
            opacity: 0;
            transform: translateY(30px);
        }
        to {
            opacity: 1;
            transform: translateY(0);
        }
    }
    
    /* Page size selector styling */
    .form-select-sm {
        font-size: 0.875rem;
        padding: 0.25rem 0.5rem;
    }
    
    /* Quick jump input styling */
    #jumpToPage {
        text-align: center;
    }
    
    /* Loading state for pagination */
    .pagination-loading {
        pointer-events: none;
        opacity: 0.6;
    }
    
    /* Responsive pagination adjustments */
    @media (max-width: 768px) {
        .pagination-rounded {
            flex-wrap: wrap;
            justify-content: center;
        }
        
        .pagination-rounded .page-link {
            margin: 1px;
            padding: 0.375rem 0.75rem;
        }
    }
</style>

<script>
    $(document).ready(function () {
        <!--- Remote audition add modal --->
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

        <!--- Remote direct booking modal --->
        $("#remoteaudadddirect").on("show.bs.modal", function (event) {
            $(this).find(".modal-body").load("/include/remoteaudadd.cfm?userid=<cfoutput>#userid#</cfoutput>&isdirect=1");
        });
    });
</script>

<!--- Modal definitions --->
<!--- Add Audition Modal --->
<div id="remoteaudadd" class="modal fade" tabindex="-1" aria-labelledby="standard-modalLabel">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <h4 class="modal-title" id="standard-modalLabel">Audition Type</h4>
                <button type="button" class="close" data-bs-dismiss="modal">
                    <i class="mdi mdi-close-thick"></i>
                </button>
            </div>
            <div class="modal-body"></div>
        </div>
    </div>
</div>

<!--- Direct Booking Modal --->
<div id="remoteaudadddirect" class="modal fade" tabindex="-1" aria-labelledby="standard-modalLabel">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <h4 class="modal-title" id="standard-modalLabel">Direct Booking Type</h4>
                <button type="button" class="close" data-bs-dismiss="modal">
                    <i class="mdi mdi-close-thick"></i>
                </button>
            </div>
            <div class="modal-body"></div>
        </div>
    </div>
</div>

<!--- View type determination --->
<cfif #viewtypeid# is "1">
    <cfparam name="view" default="tbl"/>
<cfelse>
    <cfparam name="view" default="glry"/>
</cfif>

<!--- Data queries --->
<cfinclude template="/include/qry/up_31_1.cfm" />
<cfinclude template="/include/qry/audsteps_sel_31_2.cfm" />
<cfinclude template="/include/qry/audtypes_sel_31_3.cfm" />
<cfinclude template="/include/qry/auditions.cfm" />

<!--- Pagination logic for gallery view --->
<cfscript>
    // Calculate pagination variables
    totalRecords = results.recordCount;
    currentPage = val(page);
    if (currentPage lt 1) currentPage = 1;
    
    // Calculate total pages
    totalPages = ceiling(totalRecords / pageSize);
    if (currentPage gt totalPages and totalPages gt 0) currentPage = totalPages;
    
    // Calculate start and end row for current page
    startRow = ((currentPage - 1) * pageSize) + 1;
    endRow = min(startRow + pageSize - 1, totalRecords);
    
    // Build pagination URL parameters
    urlParams = "";
    if (isDefined('sel_audstepid') and sel_audstepid neq "%") urlParams = listAppend(urlParams, "sel_audstepid=" & sel_audstepid, "&");
    if (isDefined('sel_audcatid') and sel_audcatid neq "%") urlParams = listAppend(urlParams, "sel_audcatid=" & sel_audcatid, "&");
    if (isDefined('sel_contactid') and sel_contactid neq "%") urlParams = listAppend(urlParams, "sel_contactid=" & sel_contactid, "&");
    if (isDefined('sel_coname') and sel_coname neq "%") urlParams = listAppend(urlParams, "sel_coname=" & urlEncodeForURL(sel_coname), "&");
    if (isDefined('audsearch') and len(trim(audsearch))) urlParams = listAppend(urlParams, "audsearch=" & urlEncodeForURL(audsearch), "&");
    if (isDefined('view')) urlParams = listAppend(urlParams, "view=" & view, "&");
    if (isDefined('materials')) urlParams = listAppend(urlParams, "materials=" & materials, "&");
    
    // Add pagination parameter placeholder
    baseUrl = "/app/auditions/?" & urlParams;
    if (len(urlParams)) {
        baseUrl = baseUrl & "&page=";
    } else {
        baseUrl = baseUrl & "page=";
    }
</cfscript>

<!--- Main interface container --->
<div class="container px-1">
    <div class="row">
        <div class="col-12">
            <div class="card mb-3">
                <div class="card-body">
                    <!--- Main filter form --->
                    <form action="/app/auditions/">
                        <cfoutput>
                            <input type="hidden" name="view" value="#view#"/>
                            <input type="hidden" name="auddate" value="%"/>
                            <input type="hidden" name="page" value="1"/>
                            <input type="hidden" name="pageSize" value="#pageSize#"/>
                        </cfoutput>

                        <div class="row">
                            <!--- Action buttons --->
                            <div class="col-lg-4 pb-1">
                                <a href="" class="btn btn-primary waves-effect waves-light" data-bs-remote="true" data-bs-toggle="modal" data-bs-target="#remoteaudadd" data-bs-placement="top" title="Add Audition" data-bs-original-title="Add Audition">
                                    Add Audition
                                </a>
                                <a href="" class="btn btn-success waves-effect waves-light" data-bs-remote="true" data-bs-toggle="modal" data-bs-target="#remoteaudadddirect" data-bs-placement="top" title="Add Direct booking" data-bs-original-title="Add Direct Booking">
                                    Direct Booking
                                </a>
                            </div>

                            <!--- Status filter --->
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

                            <!--- Category filter --->
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

                            <!--- View toggles and export buttons --->
                            <div class="col-lg-4 d-flex">
                                <span>
                                    <cfif #view# is "tbl">
                                        <cfset table_button="btn-secondary"/>
                                        <cfset gallery_button="btn-outline-secondary"/>
                                    </cfif>
                                    <cfif #view# is "glry">
                                        <cfset table_button="btn-outline-secondary"/>
                                        <cfset gallery_button="btn-secondary"/>
                                    </cfif>

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

                            <!--- Additional filters --->
                            <cfinclude template="/include/qry/cds_31_4.cfm" />
                            <cfinclude template="/include/qry/cos_31_5.cfm" />
                            <cfparam name="sel_coname" default="%"/>

                            <!--- Casting director filter --->
                            <div class="col-lg-4 pb-1">
                                <select id="sel_contactid" name="sel_contactid" class="form-control" onchange="this.form.submit()">
                                    <option value="%">All Casting Directors</option>
                                    <cfoutput query="cds">
                                        <option value="#cds.contactid#" <cfif "#cds.contactid#" is "#sel_contactid#">selected</cfif>>#cds.cd#</option>
                                    </cfoutput>
                                </select>
                            </div>

                            <!--- Company filter --->
                            <div class="col-lg-4 pb-1">
                                <select id="sel_coname" name="sel_coname" class="form-control" onchange="this.form.submit()">
                                    <option value="%">All Companies</option>
                                    <cfoutput query="cos">
                                        <option value="#cos.valueCompany#" <cfif "#cos.valueCompany#" is "#sel_coname#" >Selected</cfif>>#cos.valueCompany#</option>
                                    </cfoutput>
                                </select>
                            </div>

                            <div class="col-lg-4 pb-1"></div>

                            <!--- Search functionality --->
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
                        </div>
                    </form>
                </div>
            </div>
        </div>
    </div>
</div>
<!--- Results display container --->
<div class="container p-3">
    <div class="row">
        <!--- Gallery view --->
        <cfif view eq "glry">
            <!--- No results message --->
            <cfif results.recordcount eq 0>
                <p>No events found</p>
            <cfelse>
                <!--- Results summary with pagination info --->
                <div class="d-flex justify-content-between align-items-center mb-3">
                    <p class="mb-0">
                        <cfoutput>
                            <strong>#totalRecords#</strong> audition<cfif totalRecords neq 1>s</cfif> found
                            <cfif totalPages gt 1>
                                (Page #currentPage# of #totalPages#, showing #startRow#-#endRow#)
                            </cfif>
                        </cfoutput>
                    </p>
                    
                    <!--- Page size selector --->
                    <cfif totalRecords gt 12>
                        <div class="d-flex align-items-center">
                            <label for="pageSize" class="form-label me-2 mb-0">Show:</label>
                            <select id="pageSize" class="form-select form-select-sm" style="width: auto;" onchange="changePageSize(this.value)">
                                <option value="12" <cfif pageSize eq 12>selected</cfif>>12</option>
                                <option value="24" <cfif pageSize eq 24>selected</cfif>>24</option>
                                <option value="48" <cfif pageSize eq 48>selected</cfif>>48</option>
                                <option value="96" <cfif pageSize eq 96>selected</cfif>>96</option>
                            </select>
                        </div>
                    </cfif>
                </div>

                <!--- Audition gallery container --->
                <div class="container">
                    <div class="row tao-card-row row-cols-1 row-cols-sm-2 row-cols-md-2 row-cols-lg-2 row-cols-xl-3 g-3">
                        <cfloop query="results" startrow="#startRow#" endrow="#endRow#">
                            <!--- Card variable setup --->
                            <cfset card_id = results.recid/>
                            <cfset aud_cat_icon = ""/>
                            <cfset card_avatar = "Yes"/>
                            <cfset card_casting = results.castingfullname/>
                            <cfset card_source = results.col5 />
                            
                            <!--- Company display logic --->
                            <cfif results.audroletype neq "">
                                <cfset card_company = results.col4 & " (" & results.audroletype & ")" />
                            <cfelse>
                                <cfset card_company = results.col4 />
                            </cfif>
                            
                            <!--- Project year logic --->
                            <cfif results.projdate is not "">
                                <cfset cardYear = year(results.projdate) />
                            <cfelse>
                                <cfset cardYear = "n/a">
                            </cfif>

                            <!--- Standard card variables --->
                            <cfset card_view_icon_yn = "N">
                            <cfset card_delete_msg = ""/>
                            <cfset card_delete = ""/>
                            <cfset card_details = "/app/audition/?audprojectid=" & results.recid/>
                            <cfset card_email = ""/>
                            <cfset card_name = ""/>
                            <cfset card_footer_text = ""/>
                            <cfset card_footer_type = ""/>
                            <cfset card_footer_yn = "N"/>
                            <cfset card_header_text = results.col2/>
                            <cfset card_header_yn = "Y"/>
                            <cfset card_icon_yn = "Y"/>
                            <cfset card_image = "#application.datesUrl#/#DateFormat('#results.col1#','mm-dd')#.png"/>
                            <cfset namecolor = "dark"/>
                            <cfset card_phone = ""/>
                            <cfset card_ribbon1 = ""/>
                            <cfset card_ribbon2 = ""/>
                            <cfset card_social_yn = "N"/>
                            <cfset card_title = results.col3 />
                            <cfset card_subtitle = results.audsubcatname />
                            <cfset card_top_ribbon = "Yes"/>
                            <cfset ribbon_icon = ""/>
                            <cfset card_reminder = ""/>
                            <cfset card_remove = ""/>
                            <cfset card_remove_msg = ""/>
                            <cfset card_image_type = "calendar"/>
                            <cfset card_image_yn = "Y"/>
                            <cfset card_badge_yn = "N" />
                            <cfset card_ribbon_straight_body = "" />

                            <cfoutput>
                                <!--- Determine audition status --->
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

                                <!--- Card display --->
                                <div class="col">
                                    <!--- Final card variable setup --->
                                    <cfif col6 neq "Booked" and col6 neq "Audition">
                                        <cfset card_footer_text = col6/>
                                    <cfelse>
                                        <cfset card_footer_text = "">
                                    </cfif>
                                    
                                    <cfset card_ribbon2 = ""/>
                                    <cfset card_delete = ""/>
                                    <cfset card_icon = results.aud_cat_icon/>
                                    
                                    <cfif results.isbooked eq "1">
                                        <cfset card_top_ribbon = "Booked"/>
                                    <cfelse>
                                        <cfset card_top_ribbon = ""/>
                                    </cfif>
                                    
                                    <cfset card_id = results.recid />

                                    <!--- Include the card template --->
                                    <cfinclude template="/include/card.cfm"/>
                                </div>
                            </cfoutput>
                        </cfloop>
                    </div>
                </div>

                <!--- Professional Bootstrap 5 Pagination --->
                <cfif totalPages gt 1>
                    <div class="d-flex justify-content-center mt-4">
                        <nav aria-label="Auditions pagination">
                            <ul class="pagination pagination-rounded mb-0">
                                <cfoutput>
                                    <!--- Previous button --->
                                    <li class="page-item <cfif currentPage eq 1>disabled</cfif>">
                                        <cfif currentPage eq 1>
                                            <span class="page-link">
                                                <i class="mdi mdi-chevron-left"></i>
                                            </span>
                                        <cfelse>
                                            <a class="page-link" href="#baseUrl##currentPage-1#" aria-label="Previous">
                                                <i class="mdi mdi-chevron-left"></i>
                                            </a>
                                        </cfif>
                                    </li>

                                    <!--- Page numbers with smart truncation --->
                                    <cfset startPage = max(1, currentPage - 2) />
                                    <cfset endPage = min(totalPages, currentPage + 2) />
                                    
                                    <!--- First page if not in range --->
                                    <cfif startPage gt 1>
                                        <li class="page-item">
                                            <a class="page-link" href="#baseUrl#1">1</a>
                                        </li>
                                        <cfif startPage gt 2>
                                            <li class="page-item disabled">
                                                <span class="page-link">...</span>
                                            </li>
                                        </cfif>
                                    </cfif>
                                    
                                    <!--- Current range of pages --->
                                    <cfloop from="#startPage#" to="#endPage#" index="i">
                                        <li class="page-item <cfif i eq currentPage>active</cfif>">
                                            <cfif i eq currentPage>
                                                <span class="page-link">#i#</span>
                                            <cfelse>
                                                <a class="page-link" href="#baseUrl##i#">#i#</a>
                                            </cfif>
                                        </li>
                                    </cfloop>
                                    
                                    <!--- Last page if not in range --->
                                    <cfif endPage lt totalPages>
                                        <cfif endPage lt totalPages - 1>
                                            <li class="page-item disabled">
                                                <span class="page-link">...</span>
                                            </li>
                                        </cfif>
                                        <li class="page-item">
                                            <a class="page-link" href="#baseUrl##totalPages#">#totalPages#</a>
                                        </li>
                                    </cfif>

                                    <!--- Next button --->
                                    <li class="page-item <cfif currentPage eq totalPages>disabled</cfif>">
                                        <cfif currentPage eq totalPages>
                                            <span class="page-link">
                                                <i class="mdi mdi-chevron-right"></i>
                                            </span>
                                        <cfelse>
                                            <a class="page-link" href="#baseUrl##currentPage+1#" aria-label="Next">
                                                <i class="mdi mdi-chevron-right"></i>
                                            </a>
                                        </cfif>
                                    </li>
                                </cfoutput>
                            </ul>
                        </nav>
                    </div>

                    <!--- Pagination info and quick jump --->
                    <div class="d-flex justify-content-between align-items-center mt-3">
                        <div class="text-muted small">
                            <cfoutput>
                                Showing #startRow# to #endRow# of #totalRecords# results
                            </cfoutput>
                        </div>
                        
                        <cfif totalPages gt 10>
                            <div class="d-flex align-items-center">
                                <label for="jumpToPage" class="form-label me-2 mb-0 small">Go to page:</label>
                                <input type="number" id="jumpToPage" class="form-control form-control-sm" 
                                       style="width: 80px;" min="1" max="<cfoutput>#totalPages#</cfoutput>" 
                                       placeholder="<cfoutput>#currentPage#</cfoutput>"
                                       onkeypress="if(event.key==='Enter') jumpToPage(this.value)">
                                <button type="button" class="btn btn-sm btn-outline-secondary ms-1" 
                                        onclick="jumpToPage(document.getElementById('jumpToPage').value)">Go</button>
                            </div>
                        </cfif>
                    </div>
                </cfif>
            </cfif>
        </cfif>
        <!--- Table view --->
        <cfif #view# is "tbl">
            <div class="container">
                <div class="card pb-3">
                    <div class="card-body">
                        <!--- Results count display --->
                        <cfif #results.recordcount# is "0">
                            <p>No events found</p>
                        <cfelse>
                            <p>
                                <cfoutput>
                                    <strong>#results.recordcount#</strong> audition<cfif #results.recordcount# is not "1">s</cfif> found
                                </cfoutput>
                            </p>
                        </cfif>

                        <!--- Data table --->
                        <table id="basic-datatable" class="table dt-responsive nowrap w-100 table-striped" role="grid">
                            <thead>
                                <cfloop query="results" endrow="1">
                                    <cfoutput>
                                        <cfif (Results.CurrentRow MOD 2)>
                                            <cfset rowtype="Odd"/>
                                        <cfelse>
                                            <cfset rowtype="Even"/>
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
                                        <!--- Determine status --->
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
                                        
                                        <!--- Table row --->
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
                                                <cfif #results.col3# is not "">
                                                    <cfif #results.col3# is "My Team" and #results.contactname# is not "">
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
        </cfif>
    </div>
</div>

<!--- DataTables initialization --->
<script>
    $(document).ready(function () {
        <!--- Initialize main data table --->
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

        <!--- Initialize buttons data table --->
        var buttonsTable = $("#datatable-buttons").DataTable({
            lengthChange: false,
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

    // Gallery pagination functions
    function changePageSize(newSize) {
        const currentUrl = new URL(window.location.href);
        currentUrl.searchParams.set('pageSize', newSize);
        currentUrl.searchParams.set('page', '1'); // Reset to first page
        window.location.href = currentUrl.toString();
    }

    function jumpToPage(pageNum) {
        const page = parseInt(pageNum);
        const maxPages = <cfoutput>#totalPages#</cfoutput>;
        
        if (isNaN(page) || page < 1 || page > maxPages) {
            alert('Please enter a valid page number between 1 and ' + maxPages);
            return;
        }
        
        const currentUrl = new URL(window.location.href);
        currentUrl.searchParams.set('page', page);
        window.location.href = currentUrl.toString();
    }

    // Smooth scroll to top when pagination links are clicked
    $(document).on('click', '.pagination .page-link', function(e) {
        if ($(this).closest('.page-item').hasClass('disabled') || $(this).closest('.page-item').hasClass('active')) {
            e.preventDefault();
            return false;
        }
        
        // Add a small delay to allow the page to load, then scroll to top
        setTimeout(function() {
            $('html, body').animate({
                scrollTop: $('.tao-card-row').offset().top - 100
            }, 600);
        }, 100);
    });
</script>

