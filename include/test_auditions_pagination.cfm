<!---
    PURPOSE: Test file for auditions gallery pagination
    AUTHOR: Kevin King
    DATE: 2025-07-24
    USAGE: Test pagination functionality in development environment
--->

<!--- Mock data for testing pagination --->
<cfscript>
    // Create mock results query for testing
    mockData = queryNew("recid,col1,col2,col3,col4,col5,projdate,audsubcatname,isbooked,ispin,isredirect,iscallback,aud_cat_icon,castingfullname,audroletype", "integer,date,varchar,varchar,varchar,varchar,date,varchar,bit,bit,bit,bit,varchar,varchar,varchar");
    
    // Generate 150 mock audition records
    for (i = 1; i <= 150; i++) {
        queryAddRow(mockData);
        querySetCell(mockData, "recid", i);
        querySetCell(mockData, "col1", dateAdd("d", -rand() * 365, now()));
        querySetCell(mockData, "col2", "Audition Project " & i);
        querySetCell(mockData, "col3", "Character " & i);
        querySetCell(mockData, "col4", "Production Company " & (i mod 10 + 1));
        querySetCell(mockData, "col5", "Source " & (i mod 5 + 1));
        querySetCell(mockData, "projdate", dateAdd("d", rand() * 30, now()));
        querySetCell(mockData, "audsubcatname", "Category " & (i mod 8 + 1));
        querySetCell(mockData, "isbooked", i mod 15 eq 0 ? 1 : 0);
        querySetCell(mockData, "ispin", i mod 10 eq 0 ? 1 : 0);
        querySetCell(mockData, "isredirect", i mod 8 eq 0 ? 1 : 0);
        querySetCell(mockData, "iscallback", i mod 6 eq 0 ? 1 : 0);
        querySetCell(mockData, "aud_cat_icon", "mdi-drama-masks");
        querySetCell(mockData, "castingfullname", "Casting Director " & (i mod 12 + 1));
        querySetCell(mockData, "audroletype", i mod 3 eq 0 ? "Lead" : (i mod 3 eq 1 ? "Supporting" : "Background"));
    }
    
    // Set as results for testing
    results = mockData;
    
    // Initialize pagination service
    paginationService = createObject("component", "services.PaginationService").init();
    
    // Set test parameters
    page = isDefined('url.page') ? url.page : 1;
    pageSize = isDefined('url.pageSize') ? url.pageSize : 12;
    view = "glry";
    
    // Calculate pagination
    paginationInfo = paginationService.calculatePagination(
        totalRecords = results.recordCount,
        currentPage = page,
        pageSize = pageSize
    );
    
    // Build mock URL parameters
    urlParams = {
        view: view,
        pageSize: pageSize
    };
    
    baseUrl = paginationService.buildPaginationUrl("/test/auditions_test.cfm", urlParams);
</cfscript>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <title>Auditions Gallery Pagination Test</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    
    <!--- Bootstrap 5 CSS --->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    
    <!--- Material Design Icons --->
    <link href="https://cdn.jsdelivr.net/npm/@mdi/font@6.5.95/css/materialdesignicons.min.css" rel="stylesheet">
    
    <style>
        /* Pagination styling from auditions.cfm */
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
        
        .mock-card {
            border: 1px solid #dee2e6;
            border-radius: 0.375rem;
            padding: 1rem;
            margin-bottom: 1rem;
            background: white;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
            transition: transform 0.15s ease-in-out;
        }
        
        .mock-card:hover {
            transform: translateY(-2px);
            box-shadow: 0 4px 8px rgba(0,0,0,0.15);
        }
        
        .card-animation {
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
    </style>
</head>
<body>

<div class="container py-4">
    <h1 class="mb-4">Auditions Gallery Pagination Test</h1>
    <p class="lead">Testing the pagination implementation with mock data.</p>
    
    <!--- Results summary and page size selector --->
    <div class="d-flex justify-content-between align-items-center mb-3">
        <div>
            <cfoutput>
                <strong>#paginationInfo.totalRecords#</strong> auditions found
                <cfif paginationInfo.totalPages gt 1>
                    (Page #paginationInfo.currentPage# of #paginationInfo.totalPages#, showing #paginationInfo.startRow#-#paginationInfo.endRow#)
                </cfif>
            </cfoutput>
        </div>
        
        <cfif paginationInfo.totalRecords gt 12>
            <div class="d-flex align-items-center">
                <label for="pageSize" class="form-label me-2 mb-0">Show:</label>
                <select id="pageSize" class="form-select form-select-sm" style="width: auto;" onchange="changePageSize(this.value)">
                    <cfloop array="#paginationService.getPageSizeOptions(pageSize)#" index="option">
                        <cfoutput>
                            <option value="#option.value#" <cfif option.selected>selected</cfif>>#option.label#</option>
                        </cfoutput>
                    </cfloop>
                </select>
            </div>
        </cfif>
    </div>
    
    <!--- Mock gallery display --->
    <div class="row row-cols-1 row-cols-sm-2 row-cols-md-3 row-cols-lg-4 g-3">
        <cfloop query="results" startrow="#paginationInfo.startRow#" endrow="#paginationInfo.endRow#">
            <cfoutput>
                <div class="col card-animation">
                    <div class="mock-card">
                        <h6 class="card-title">#results.col2#</h6>
                        <p class="card-text">
                            <strong>Character:</strong> #results.col3#<br>
                            <strong>Company:</strong> #results.col4#<br>
                            <strong>Source:</strong> #results.col5#<br>
                            <strong>Status:</strong> 
                            <cfif results.isbooked>
                                <span class="badge bg-success">Booked</span>
                            <cfelseif results.ispin>
                                <span class="badge bg-warning">Pin</span>
                            <cfelseif results.isredirect>
                                <span class="badge bg-info">Redirect</span>
                            <cfelseif results.iscallback>
                                <span class="badge bg-primary">Callback</span>
                            <cfelse>
                                <span class="badge bg-secondary">Audition</span>
                            </cfif>
                        </p>
                        <small class="text-muted">Record ##results.recid#</small>
                    </div>
                </div>
            </cfoutput>
        </cfloop>
    </div>
    
    <!--- Pagination controls --->
    <cfif paginationInfo.totalPages gt 1>
        <div class="d-flex justify-content-center mt-4">
            <cfoutput>
                #paginationService.renderPaginationControls(paginationInfo, baseUrl)#
            </cfoutput>
        </div>
        
        <!--- Pagination info and quick jump --->
        <div class="d-flex justify-content-between align-items-center mt-3">
            <div>
                <cfoutput>
                    #paginationService.renderPageInfo(paginationInfo)#
                </cfoutput>
            </div>
            
            <cfif paginationInfo.totalPages gt 10>
                <div class="d-flex align-items-center">
                    <label for="jumpToPage" class="form-label me-2 mb-0 small">Go to page:</label>
                    <input type="number" id="jumpToPage" class="form-control form-control-sm" 
                           style="width: 80px;" min="1" max="<cfoutput>#paginationInfo.totalPages#</cfoutput>" 
                           placeholder="<cfoutput>#paginationInfo.currentPage#</cfoutput>"
                           onkeypress="if(event.key==='Enter') jumpToPage(this.value)">
                    <button type="button" class="btn btn-sm btn-outline-secondary ms-1" 
                            onclick="jumpToPage(document.getElementById('jumpToPage').value)">Go</button>
                </div>
            </cfif>
        </div>
    </cfif>
    
    <!--- Test information --->
    <div class="alert alert-info mt-4">
        <h5>Test Information:</h5>
        <ul>
            <li>Total mock records: <cfoutput>#results.recordCount#</cfoutput></li>
            <li>Current page size: <cfoutput>#pageSize#</cfoutput></li>
            <li>Current page: <cfoutput>#paginationInfo.currentPage#</cfoutput></li>
            <li>Total pages: <cfoutput>#paginationInfo.totalPages#</cfoutput></li>
            <li>URL structure: <cfoutput>#baseUrl#[pageNumber]</cfoutput></li>
        </ul>
    </div>
</div>

<!--- Bootstrap 5 JS --->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>

<script>
    // Test pagination functions
    function changePageSize(newSize) {
        const currentUrl = new URL(window.location.href);
        currentUrl.searchParams.set('pageSize', newSize);
        currentUrl.searchParams.set('page', '1');
        window.location.href = currentUrl.toString();
    }

    function jumpToPage(pageNum) {
        const page = parseInt(pageNum);
        const maxPages = <cfoutput>#paginationInfo.totalPages#</cfoutput>;
        
        if (isNaN(page) || page < 1 || page > maxPages) {
            alert('Please enter a valid page number between 1 and ' + maxPages);
            return;
        }
        
        const currentUrl = new URL(window.location.href);
        currentUrl.searchParams.set('page', page);
        window.location.href = currentUrl.toString();
    }

    // Smooth scroll animation
    $(document).on('click', '.pagination .page-link', function(e) {
        if ($(this).closest('.page-item').hasClass('disabled') || $(this).closest('.page-item').hasClass('active')) {
            e.preventDefault();
            return false;
        }
    });
    
    console.log('Pagination test loaded successfully');
    console.log('Total records:', <cfoutput>#paginationInfo.totalRecords#</cfoutput>);
    console.log('Current page:', <cfoutput>#paginationInfo.currentPage#</cfoutput>);
    console.log('Total pages:', <cfoutput>#paginationInfo.totalPages#</cfoutput>);
</script>

</body>
</html>
