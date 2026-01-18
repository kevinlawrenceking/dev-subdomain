<!---
    PURPOSE: Page Title Service - Manages page-specific configurations and actions
    AUTHOR: Kevin King  
    DATE: 2025-07-24
    PARAMETERS: Various page context variables
    DEPENDENCIES: None
--->

<cfcomponent displayname="PageTitleService" hint="Handles page title configuration and action management">

    <cffunction name="init" access="public" returntype="PageTitleService" output="false">
        <cfreturn this />
    </cffunction>

    <cffunction name="getPageConfiguration" access="public" returntype="struct" output="false">
        <cfargument name="pgid" type="string" required="true">
        <cfargument name="ctaction" type="string" required="false" default="view">
        <cfargument name="contextVars" type="struct" required="false" default="#structNew()#">
        
        <cfscript>
            var config = structNew();
            var pgidStr = toString(arguments.pgid);
            
            // Define configurations for specific pages
            switch(pgidStr) {
                case "89": // Dashboard
                    config = {
                        sessionVar: "pgrtn=D",
                        actions: [
                            {
                                type: "modal",
                                target: "panelAdd", 
                                icon: "fe-plus-circle",
                                title: "Add Custom Panel"
                            }
                        ],
                        conditionalActions: [
                            {
                                condition: arguments.ctaction NEQ "view",
                                type: "link",
                                url: "/app/dashboard_new/?ctaction=view",
                                icon: "mdi mdi-cog-outline", 
                                title: "View Configuration",
                                extraContent: '<span class="config-notice">Drag your panels to reorder and press the button.</span>'
                            }
                        ]
                    };
                    break;
                    
                case "117": // Contact Details
                    config = {
                        actions: [
                            {
                                type: "modal",
                                target: "remoteDeleteForm" & (structKeyExists(arguments.contextVars, 'contactid') ? arguments.contextVars.contactid : ''),
                                icon: "fe-trash-2",
                                title: "Delete Contact",
                                class: "btn-danger-outline"
                            }
                        ]
                    };
                    break;
                    
                case "175": // Project Details  
                    var titleSuffix = "";
                    var targetSuffix = "";
                    
                    if (structKeyExists(arguments.contextVars, 'projectDetails')) {
                        titleSuffix = ": " & arguments.contextVars.projectDetails.projName;
                        targetSuffix = arguments.contextVars.projectDetails.audProjectId;
                    }
                    
                    config = {
                        titleSuffix: titleSuffix,
                        actions: [
                            {
                                type: "modal",
                                target: "remoteDeleteFormAudproject" & targetSuffix,
                                icon: "fe-trash-2", 
                                title: "Delete Project",
                                class: "btn-danger-outline"
                            }
                        ]
                    };
                    break;
                    
                case "189": // Range Display
                    config = {
                        titleSuffix: structKeyExists(arguments.contextVars, 'rangeDisplay') ? "(" & arguments.contextVars.rangeDisplay & ")" : ""
                    };
                    break;
                    
                case "5": // Calendar Appointments
                    var rcontactid = structKeyExists(arguments.contextVars, 'rcontactid') ? arguments.contextVars.rcontactid : 0;
                    
                    config = {
                        sessionVar: "pgrtn=D",
                        actions: [
                            {
                                type: "link",
                                url: "/app/appoint-add/?returnurl=calendar-appoint&rcontactid=" & rcontactid & "&pgrtn=D",
                                icon: "fe-plus-circle",
                                title: "Add Appointment"
                            }
                        ]
                    };
                    break;
                    
                default:
                    config = structNew();
            }
            
            return config;
        </cfscript>
    </cffunction>

    <cffunction name="buildBreadcrumbs" access="public" returntype="array" output="false">
        <cfargument name="appName" type="string" required="true">
        <cfargument name="compName" type="string" required="false" default="">
        <cfargument name="compDir" type="string" required="false" default="">
        <cfargument name="pgName" type="string" required="true">
        <cfargument name="home" type="string" required="false" default="/app/dashboard">
        
        <cfscript>
            var breadcrumbs = arrayNew(1);
            
            // Always start with app home
            arrayAppend(breadcrumbs, {
                name: arguments.appName,
                url: arguments.home,
                active: false
            });
            
            // Add component level if available
            if (len(trim(arguments.compDir))) {
                arrayAppend(breadcrumbs, {
                    name: arguments.compName,
                    url: "/app/" & arguments.compDir,
                    active: false
                });
            } else if (len(trim(arguments.compName))) {
                // Fallback without proper URL
                arrayAppend(breadcrumbs, {
                    name: arguments.compName,
                    url: "javascript:void(0);",
                    onclick: "history.back();",
                    active: false
                });
            }
            
            // Add current page
            arrayAppend(breadcrumbs, {
                name: arguments.pgName,
                url: "",
                active: true
            });
            
            return breadcrumbs;
        </cfscript>
    </cffunction>

    <cffunction name="renderActions" access="public" returntype="string" output="false">
        <cfargument name="actions" type="array" required="true">
        
        <cfset var output = "" />
        <cfset var action = "" />
        
        <cfloop array="#arguments.actions#" index="action">
            <cfswitch expression="#action.type#">
                <cfcase value="modal">
                    <cfset output &= '<a href="javascript:;" data-bs-remote="true" data-bs-toggle="modal" data-bs-target="##' & action.target & '" title="' & action.title & '"' />
                    <cfif structKeyExists(action, 'class')>
                        <cfset output &= ' class="' & action.class & '"' />
                    </cfif>
                    <cfset output &= '><i class="' & action.icon & '"></i></a>' />
                </cfcase>
                <cfcase value="link">
                    <cfset output &= '<a href="' & action.url & '" title="' & action.title & '"' />
                    <cfif structKeyExists(action, 'class')>
                        <cfset output &= ' class="' & action.class & '"' />
                    </cfif>
                    <cfset output &= '><i class="' & action.icon & '"></i></a>' />
                </cfcase>
            </cfswitch>
        </cfloop>
        
        <cfreturn output />
    </cffunction>

</cfcomponent>
