<!---
Contacts Gallery View - Card-based display for contacts
Depends on: contacts_table, bytag, byimport, gallerysearch, userid, page, pageSize
Uses card.cfm for rendering (same pattern as auditions gallery + team contact data)
--->

<cfparam name="page" default="1" />
<cfparam name="pageSize" default="12" />
<cfparam name="gallerysearch" default="" />

<!--- Fetch contacts --->
<cfinclude template="/include/qry/contacts_gallery.cfm" />

<!--- Initialize pagination --->
<cfscript>
    paginationService = createObject("component", "services.PaginationService").init();
    paginationInfo = paginationService.calculatePagination(
        totalRecords = galleryContacts.recordCount,
        currentPage = val(page),
        pageSize = val(pageSize)
    );
    totalRecords = paginationInfo.totalRecords;
    currentPage = paginationInfo.currentPage;
    totalPages = paginationInfo.totalPages;
    startRow = paginationInfo.startRow;
    endRow = paginationInfo.endRow;
    showAll = paginationInfo.showAll;
</cfscript>

<!--- Build pagination base URL --->
<cfscript>
    urlParams = "view=glry";
    if (isDefined('ctab') and ctab neq "all") urlParams = listAppend(urlParams, "ctab=" & ctab, "&");
    if (isDefined('bytag') and len(trim(bytag))) urlParams = listAppend(urlParams, "bytag=" & urlEncodedFormat(bytag), "&");
    if (isDefined('byimport') and len(trim(byimport))) urlParams = listAppend(urlParams, "byimport=" & urlEncodedFormat(byimport), "&");
    if (isDefined('gallerysearch') and len(trim(gallerysearch))) urlParams = listAppend(urlParams, "gallerysearch=" & urlEncodedFormat(gallerysearch), "&");
    if (isDefined('pageSize')) urlParams = listAppend(urlParams, "pageSize=" & pageSize, "&");
    baseUrl = "/app/contacts/?" & urlParams & "&page=";
</cfscript>

<!--- Search bar --->
<div class="row mb-3">
    <div class="col-lg-6">
        <form action="/app/contacts/" method="get" class="d-flex gap-2">
            <input type="hidden" name="view" value="glry" />
            <cfif isDefined('ctab')><input type="hidden" name="ctab" value="<cfoutput>#ctab#</cfoutput>" /></cfif>
            <cfif isDefined('bytag') and bytag neq ""><input type="hidden" name="bytag" value="<cfoutput>#bytag#</cfoutput>" /></cfif>
            <cfif isDefined('byimport') and byimport neq ""><input type="hidden" name="byimport" value="<cfoutput>#byimport#</cfoutput>" /></cfif>
            <input type="hidden" name="pageSize" value="<cfoutput>#pageSize#</cfoutput>" />
            <div class="input-group">
                <input type="text" class="form-control" name="gallerysearch" value="<cfoutput>#gallerysearch#</cfoutput>" placeholder="Search contacts..." autocomplete="off" />
                <button class="btn btn-primary" type="submit" style="background-color: #406e8e; border-color: #406e8e;">
                    <i class="fe-search"></i>
                </button>
                <cfif len(trim(gallerysearch))>
                    <a href="<cfoutput>/app/contacts/?view=glry<cfif isDefined('ctab') and ctab neq 'all'>&ctab=#ctab#</cfif><cfif bytag neq ''>&bytag=#bytag#</cfif><cfif byimport neq ''>&byimport=#byimport#</cfif></cfoutput>" class="btn btn-outline-secondary" title="Clear search">
                        <i class="mdi mdi-close"></i>
                    </a>
                </cfif>
            </div>
        </form>
    </div>
    <div class="col-lg-6">
        <div class="d-flex justify-content-end align-items-center gap-2">
            <!--- Action buttons --->
            <button class="btn btn-sm btn-primary" onclick="$('#remoteAddName').modal('show');" style="background-color: #406e8e; border-color: #406e8e;">
                <i class="mdi mdi-plus me-1"></i>Add
            </button>
            <button class="btn btn-sm btn-outline-secondary" onclick="$('#searchTagModal').modal('show');">
                <i class="mdi mdi-tag-outline me-1"></i>Search Tag
            </button>
            <a href="/app/contacts-import-v3/" class="btn btn-sm btn-outline-secondary">
                <i class="mdi mdi-import me-1"></i>Import
            </a>
        </div>
    </div>
</div>

<!--- Results info and page size --->
<cfif galleryContacts.recordCount gt 0>
    <div class="d-flex justify-content-between align-items-center gallery-info-compact mb-2">
        <small class="text-muted mb-0">
            <cfoutput>#paginationService.renderPageInfo(paginationInfo)#</cfoutput>
        </small>
        <cfif totalRecords gt 12>
            <div class="d-flex align-items-center">
                <label for="contactPageSize" class="form-label me-2 mb-0" style="font-size:13px;">Show:</label>
                <select id="contactPageSize" class="form-select form-select-sm" style="width: auto; font-size:13px;" onchange="changeContactPageSize(this.value)">
                    <cfoutput>#paginationService.getPageSizeOptions(pageSize)#</cfoutput>
                </select>
            </div>
        </cfif>
    </div>

    <!--- Top pagination --->
    <cfif totalPages gt 1 and not showAll>
        <div class="d-flex justify-content-center mb-3">
            <nav aria-label="Contacts pagination">
                <ul class="pagination pagination-rounded mb-0">
                    <cfoutput>
                        <li class="page-item <cfif currentPage eq 1>disabled</cfif>">
                            <cfif currentPage eq 1>
                                <span class="page-link"><i class="mdi mdi-chevron-left"></i></span>
                            <cfelse>
                                <a class="page-link" href="#baseUrl##currentPage-1#"><i class="mdi mdi-chevron-left"></i></a>
                            </cfif>
                        </li>
                        <cfset startPage = max(1, currentPage - 2) />
                        <cfset endPage = min(totalPages, currentPage + 2) />
                        <cfif startPage gt 1>
                            <li class="page-item"><a class="page-link" href="#baseUrl#1">1</a></li>
                            <cfif startPage gt 2><li class="page-item disabled"><span class="page-link">...</span></li></cfif>
                        </cfif>
                        <cfloop from="#startPage#" to="#endPage#" index="i">
                            <li class="page-item <cfif i eq currentPage>active</cfif>">
                                <cfif i eq currentPage><span class="page-link">#i#</span>
                                <cfelse><a class="page-link" href="#baseUrl##i#">#i#</a></cfif>
                            </li>
                        </cfloop>
                        <cfif endPage lt totalPages>
                            <cfif endPage lt totalPages - 1><li class="page-item disabled"><span class="page-link">...</span></li></cfif>
                            <li class="page-item"><a class="page-link" href="#baseUrl##totalPages#">#totalPages#</a></li>
                        </cfif>
                        <li class="page-item <cfif currentPage eq totalPages>disabled</cfif>">
                            <cfif currentPage eq totalPages>
                                <span class="page-link"><i class="mdi mdi-chevron-right"></i></span>
                            <cfelse>
                                <a class="page-link" href="#baseUrl##currentPage+1#"><i class="mdi mdi-chevron-right"></i></a>
                            </cfif>
                        </li>
                    </cfoutput>
                </ul>
            </nav>
        </div>
    </cfif>

    <!--- Gallery card grid --->
    <div class="container">
        <div class="row tao-card-row row-cols-1 row-cols-sm-2 row-cols-md-2 row-cols-lg-2 row-cols-xl-3 g-3">
            <cfloop query="galleryContacts" startrow="#startRow#" endrow="#endRow#">
                <cfoutput>
                    <cfset contactid = galleryContacts.contactid />
                    <cfset currentid = galleryContacts.contactid />

                    <!--- Card variable setup (contact style like team gallery) --->
                    <cfset card_id              = galleryContacts.contactid />
                    <cfset card_view_icon_yn    = "Y" />
                    <cfset card_avatar          = "Yes" />
                    <cfset card_badge_yn        = "N" />
                    <cfset card_casting         = "" />
                    <cfset card_company         = galleryContacts.col5 />
                    <cfset card_delete          = "Y" />
                    <cfset card_delete_value    = galleryContacts.contactid />
                    <cfset card_delete_target   = "##contactdelete" />
                    <cfset card_delete_msg      = "" />
                    <cfset card_remove          = "" />
                    <cfset card_remove_msg      = "" />
                    <cfset card_remove_value    = "" />
                    <cfset card_details         = "/app/contact/?contactid=" & galleryContacts.contactid />
                    <cfset card_email           = galleryContacts.col4 />
                    <cfset card_footer_text     = "" />
                    <cfset card_footer_type     = "social" />
                    <cfset card_footer_yn       = "Y" />
                    <cfset card_header_text     = galleryContacts.col1 />
                    <cfset card_name            = "" />
                    <cfset card_header_yn       = "Y" />
                    <cfset card_icon            = "" />
                    <cfset card_icon_yn         = "N" />
                    <cfset card_image_type      = "avatar" />
                    <cfset card_image_yn        = "Y" />
                    <cfset card_image           = "" />
                    <cfset card_phone           = galleryContacts.col3 />
                    <cfset card_reminder        = "" />
                    <cfset card_ribbon1         = "" />
                    <cfset card_ribbon2         = "" />
                    <cfset card_ribbon_straight  = "" />
                    <cfset card_social_yn       = "Y" />
                    <cfset card_source          = "" />
                    <cfset card_subtitle        = "" />
                    <cfset card_title           = galleryContacts.col5 />
                    <cfset card_top_ribbon      = "" />
                    <cfset namecolor            = "medium" />
                    <cfset ribbon_icon          = "" />
                    <cfset aud_cat_icon         = "" />

                    <!--- Tags display as subtitle --->
                    <cfif galleryContacts.col2b neq "">
                        <cfset card_subtitle = galleryContacts.col2b />
                    </cfif>

                    <!--- Avatar detection --->
                    <cfif isImageFile("#session.userContactsPath#/#galleryContacts.contactid#/avatar.jpg")>
                        <cfset card_image = session.userContactsUrl & "/" & galleryContacts.contactid & "/avatar.jpg?ver=#rand()#" />
                    <cfelse>
                        <cfset card_image = application.defaultAvatarUrl />
                    </cfif>

                    <!--- Social icons for footer --->
                    <cfinclude template="/include/qry/getSocialIcons.cfm" />

                    <!--- Render the card --->
                    <cfinclude template="/include/card.cfm" />
                </cfoutput>
            </cfloop>
        </div>
    </div>

    <!--- Bottom pagination --->
    <cfif totalPages gt 1 and not showAll>
        <div class="text-center mt-4 py-3">
            <nav aria-label="Bottom pagination">
                <ul class="pagination pagination-sm justify-content-center mb-0">
                    <cfoutput>
                        <li class="page-item <cfif currentPage eq 1>disabled</cfif>">
                            <cfif currentPage eq 1>
                                <span class="page-link"><i class="mdi mdi-chevron-left"></i></span>
                            <cfelse>
                                <a class="page-link" href="#baseUrl##currentPage-1#"><i class="mdi mdi-chevron-left"></i></a>
                            </cfif>
                        </li>
                        <li class="page-item active"><span class="page-link">#currentPage#</span></li>
                        <li class="page-item <cfif currentPage eq totalPages>disabled</cfif>">
                            <cfif currentPage eq totalPages>
                                <span class="page-link"><i class="mdi mdi-chevron-right"></i></span>
                            <cfelse>
                                <a class="page-link" href="#baseUrl##currentPage+1#"><i class="mdi mdi-chevron-right"></i></a>
                            </cfif>
                        </li>
                    </cfoutput>
                </ul>
            </nav>
            <div class="text-muted small mt-2">
                <cfoutput>Page #currentPage# of #totalPages#</cfoutput>
            </div>
        </div>
    </cfif>

<cfelse>
    <p class="text-muted">No contacts found<cfif len(trim(gallerysearch))> matching "<cfoutput>#gallerysearch#</cfoutput>"</cfif>.</p>
</cfif>

<!--- Gallery JavaScript --->
<script>
function changeContactPageSize(newSize) {
    var url = new URL(window.location);
    url.searchParams.set('pageSize', newSize);
    url.searchParams.set('page', '1');
    window.location.href = url.toString();
}
</script>
