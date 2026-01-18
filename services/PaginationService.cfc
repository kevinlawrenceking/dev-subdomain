<!---
    PURPOSE: Pagination Service - Handles pagination logic and URL generation
    AUTHOR: Kevin King
    DATE: 2025-07-24
    PARAMETERS: Various pagination-related parameters
    DEPENDENCIES: None
--->

<cfcomponent displayname="PaginationService" hint="Handles pagination calculations and URL generation">

    <cffunction name="init" access="public" returntype="PaginationService" output="false">
        <cfreturn this />
    </cffunction>

    <cffunction name="calculatePagination" access="public" returntype="struct" output="false">
        <cfargument name="totalRecords" type="numeric" required="true">
        <cfargument name="currentPage" type="numeric" required="false" default="1">
        <cfargument name="pageSize" type="any" required="false" default="12">
        
        <cfscript>
            var result = structNew();
            
            // Handle "All" pageSize string or convert to numeric
            var numericPageSize = arguments.pageSize;
            if (isSimpleValue(arguments.pageSize) and arguments.pageSize eq "All") {
                numericPageSize = 999999;
            } else {
                numericPageSize = val(arguments.pageSize);
            }
            
            // Validate and sanitize inputs
            result.totalRecords = max(0, arguments.totalRecords);
            result.pageSize = max(1, numericPageSize);
            result.currentPage = max(1, arguments.currentPage);
            
            // Check if "Show All" is selected (999999 or any large number)
            result.showAll = result.pageSize >= 999999;
            
            if (result.showAll) {
                // Show all records on one page
                result.pageSize = result.totalRecords;
                result.totalPages = result.totalRecords > 0 ? 1 : 1;
                result.currentPage = 1;
                result.startRow = 1;
                result.endRow = result.totalRecords;
            } else {
                // Normal pagination logic
                result.totalPages = ceiling(result.totalRecords / result.pageSize);
                if (result.totalPages eq 0) result.totalPages = 1;
                
                // Ensure current page is within valid range
                if (result.currentPage gt result.totalPages) result.currentPage = result.totalPages;
                
                // Calculate start and end rows
                result.startRow = ((result.currentPage - 1) * result.pageSize) + 1;
                result.endRow = min(result.startRow + result.pageSize - 1, result.totalRecords);
            }
            
            // Calculate pagination range for display (only relevant when not showing all)
            result.startPage = max(1, result.currentPage - 2);
            result.endPage = min(result.totalPages, result.currentPage + 2);
            
            // Flags for pagination controls
            result.hasPrevious = result.currentPage gt 1 and not result.showAll;
            result.hasNext = result.currentPage lt result.totalPages and not result.showAll;
            result.showFirstPage = result.startPage gt 1 and not result.showAll;
            result.showLastPage = result.endPage lt result.totalPages and not result.showAll;
            result.showFirstEllipsis = result.startPage gt 2 and not result.showAll;
            result.showLastEllipsis = result.endPage lt result.totalPages - 1 and not result.showAll;
            
            return result;
        </cfscript>
    </cffunction>

    <cffunction name="buildPaginationUrl" access="public" returntype="string" output="false">
        <cfargument name="baseUrl" type="string" required="true">
        <cfargument name="currentParams" type="struct" required="false" default="#structNew()#">
        <cfargument name="excludeParams" type="string" required="false" default="page">
        
        <cfscript>
            var url = arguments.baseUrl;
            var params = arrayNew(1);
            var excludeList = listToArray(arguments.excludeParams);
            
            // Add all current parameters except excluded ones
            for (var key in arguments.currentParams) {
                if (not arrayFind(excludeList, key) and len(trim(arguments.currentParams[key])) and arguments.currentParams[key] neq "%") {
                    arrayAppend(params, key & "=" & urlEncodedFormat(arguments.currentParams[key]));
                }
            }
            
            // Build final URL
            if (arrayLen(params)) {
                url = url & "?" & arrayToList(params, "&") & "&page=";
            } else {
                url = url & "?page=";
            }
            
            return url;
        </cfscript>
    </cffunction>

    <cffunction name="renderPaginationControls" access="public" returntype="string" output="false">
        <cfargument name="paginationInfo" type="struct" required="true">
        <cfargument name="baseUrl" type="string" required="true">
        <cfargument name="cssClass" type="string" required="false" default="pagination pagination-rounded">
        
        <cfset var html = "" />
        <cfset var info = arguments.paginationInfo />
        
        <cfsavecontent variable="html">
            <cfoutput>
                <nav aria-label="Page navigation">
                    <ul class="#arguments.cssClass# mb-0">
                        <!--- Previous button --->
                        <li class="page-item <cfif not info.hasPrevious>disabled</cfif>">
                            <cfif info.hasPrevious>
                                <a class="page-link" href="#arguments.baseUrl##info.currentPage-1#" aria-label="Previous">
                                    <i class="mdi mdi-chevron-left"></i>
                                </a>
                            <cfelse>
                                <span class="page-link">
                                    <i class="mdi mdi-chevron-left"></i>
                                </span>
                            </cfif>
                        </li>

                        <!--- First page if not in range --->
                        <cfif info.showFirstPage>
                            <li class="page-item">
                                <a class="page-link" href="#arguments.baseUrl#1">1</a>
                            </li>
                            <cfif info.showFirstEllipsis>
                                <li class="page-item disabled">
                                    <span class="page-link">...</span>
                                </li>
                            </cfif>
                        </cfif>
                        
                        <!--- Current range of pages --->
                        <cfloop from="#info.startPage#" to="#info.endPage#" index="i">
                            <li class="page-item <cfif i eq info.currentPage>active</cfif>">
                                <cfif i eq info.currentPage>
                                    <span class="page-link">#i#</span>
                                <cfelse>
                                    <a class="page-link" href="#arguments.baseUrl##i#">#i#</a>
                                </cfif>
                            </li>
                        </cfloop>
                        
                        <!--- Last page if not in range --->
                        <cfif info.showLastPage>
                            <cfif info.showLastEllipsis>
                                <li class="page-item disabled">
                                    <span class="page-link">...</span>
                                </li>
                            </cfif>
                            <li class="page-item">
                                <a class="page-link" href="#arguments.baseUrl##info.totalPages#">#info.totalPages#</a>
                            </li>
                        </cfif>

                        <!--- Next button --->
                        <li class="page-item <cfif not info.hasNext>disabled</cfif>">
                            <cfif info.hasNext>
                                <a class="page-link" href="#arguments.baseUrl##info.currentPage+1#" aria-label="Next">
                                    <i class="mdi mdi-chevron-right"></i>
                                </a>
                            <cfelse>
                                <span class="page-link">
                                    <i class="mdi mdi-chevron-right"></i>
                                </span>
                            </cfif>
                        </li>
                    </ul>
                </nav>
            </cfoutput>
        </cfsavecontent>
        
        <cfreturn html />
    </cffunction>

    <cffunction name="renderPageInfo" access="public" returntype="string" output="false">
        <cfargument name="paginationInfo" type="struct" required="true">
        
        <cfset var info = arguments.paginationInfo />
        <cfset var html = "" />
        
        <cfsavecontent variable="html">
            <cfoutput>
                <cfif info.totalRecords eq 0>
                    <span class="text-muted">No results found</span>
                <cfelse>
                    <span class="text-muted">
                        <cfif info.showAll>
                            Showing all #info.totalRecords# results
                        <cfelse>
                            Showing #info.startRow# to #info.endRow# of #info.totalRecords# results
                            <cfif info.totalPages gt 1>
                                (Page #info.currentPage# of #info.totalPages#)
                            </cfif>
                        </cfif>
                    </span>
                </cfif>
            </cfoutput>
        </cfsavecontent>
        
        <cfreturn html />
    </cffunction>

    <cffunction name="getPageSizeOptions" access="public" returntype="string" output="false">
        <cfargument name="currentPageSize" type="any" required="false" default="12">
        
        <cfset var html = "" />
        <cfset var currentSize = arguments.currentPageSize />
        
        <cfsavecontent variable="html">
            <cfoutput>
                <option value="12"<cfif currentSize eq 12> selected</cfif>>12</option>
                <option value="24"<cfif currentSize eq 24> selected</cfif>>24</option>
                <option value="48"<cfif currentSize eq 48> selected</cfif>>48</option>
                <option value="96"<cfif currentSize eq 96> selected</cfif>>96</option>
                <option value="999999"<cfif currentSize eq "All" or currentSize eq 999999> selected</cfif>>All</option>
            </cfoutput>
        </cfsavecontent>
        
        <cfreturn html />
    </cffunction>

</cfcomponent>
