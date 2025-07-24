<!---
    PURPOSE: Enhanced page title and breadcrumb component with service layer
    AUTHOR: Kevin King
    DATE: 2025-07-24
    PARAMETERS: ctaction, pgid, and various page/component variables
    DEPENDENCIES: services.PageTitleService, Bootstrap 5, Feather Icons
--->

<cfparam name="ctaction" default="view">

<!--- Initialize page title service --->
<cfset pageTitleService = createObject("component", "services.PageTitleService").init() />

<!--- Gather context variables for service --->
<cfscript>
    contextVars = {
        contactid: isDefined('contactid') ? contactid : '',
        rcontactid: isDefined('rcontactid') ? rcontactid : 0,
        rangeDisplay: isDefined('rangeDisplay') ? rangeDisplay : '',
        projectDetails: isDefined('projectDetails') ? projectDetails : structNew()
    };
    
    // Get page configuration from service
    pageConfig = pageTitleService.getPageConfiguration(
        pgid = toString(pgid),
        ctaction = ctaction, 
        contextVars = contextVars
    );
    
    // Build breadcrumb navigation
    breadcrumbItems = pageTitleService.buildBreadcrumbs(
        appName = appName,
        compName = isDefined('compName') ? compName : '',
        compDir = isDefined('compDir') ? compDir : '',
        pgName = pgName,
        home = isDefined('home') ? home : '/app/dashboard'
    );
</cfscript>

<div class="col-12">
    <div class="page-title-box">
        <div class="page-title-right">
            <ol class="breadcrumb m-0">
                <cfloop array="#breadcrumbItems#" index="item">
                    <cfoutput>
                        <li class="breadcrumb-item<cfif item.active> active</cfif>">
                            <cfif item.active>
                                #item.name#
                            <cfelseif structKeyExists(item, 'onclick')>
                                <a href="#item.url#" onclick="#item.onclick#" title="Go back" role="button">
                                    #item.name#
                                </a>
                            <cfelse>
                                <a href="#item.url#" title="Go to #item.name#">
                                    #item.name#
                                </a>
                            </cfif>
                        </li>
                    </cfoutput>
                </cfloop>
            </ol>
        </div>

        <h4 class="page-title">
            <cfoutput>
                #pgHeading#
                
                <!--- Add page-specific title suffix --->
                <cfif structKeyExists(pageConfig, 'titleSuffix') AND len(trim(pageConfig.titleSuffix))>
                    #pageConfig.titleSuffix#
                </cfif>
                
                <!--- Set session variables if needed --->
                <cfif structKeyExists(pageConfig, 'sessionVar')>
                    <cfset session.pgrtn = listLast(pageConfig.sessionVar, "=") />
                </cfif>
                
                <!--- Render standard actions --->
                <cfif structKeyExists(pageConfig, 'actions')>
                    <cfloop array="#pageConfig.actions#" index="action">
                        <cfswitch expression="#action.type#">
                            <cfcase value="modal">
                                <a href="javascript:;" 
                                   data-bs-remote="true" 
                                   data-bs-toggle="modal" 
                                   data-bs-target="###action.target#" 
                                   title="#action.title#"
                                   role="button"
                                   aria-label="#action.title#"
                                   <cfif structKeyExists(action, 'class')>class="#action.class#"</cfif>>
                                    <i class="#action.icon#" aria-hidden="true"></i>
                                </a>
                            </cfcase>
                            <cfcase value="link">
                                <a href="#action.url#" 
                                   title="#action.title#"
                                   aria-label="#action.title#"
                                   <cfif structKeyExists(action, 'class')>class="#action.class#"</cfif>>
                                    <i class="#action.icon#" aria-hidden="true"></i>
                                </a>
                            </cfcase>
                        </cfswitch>
                    </cfloop>
                </cfif>
                
                <!--- Render conditional actions --->
                <cfif structKeyExists(pageConfig, 'conditionalActions')>
                    <cfloop array="#pageConfig.conditionalActions#" index="action">
                        <cfif evaluate(action.condition)>
                            <cfswitch expression="#action.type#">
                                <cfcase value="link">
                                    <a href="#action.url#" 
                                       title="#action.title#"
                                       aria-label="#action.title#"
                                       <cfif structKeyExists(action, 'class')>class="#action.class#"</cfif>>
                                        <i class="#action.icon#" aria-hidden="true"></i>
                                    </a>
                                    <cfif structKeyExists(action, 'extraContent')>
                                        #action.extraContent#
                                    </cfif>
                                </cfcase>
                            </cfswitch>
                        </cfif>
                    </cfloop>
                </cfif>
            </cfoutput>
        </h4>
    </div>
</div>
