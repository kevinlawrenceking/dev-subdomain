<!---
    PURPOSE: Test file demonstrating optimized core_title.cfm functionality
    AUTHOR: Kevin King
    DATE: 2025-07-24
    USAGE: Include this in a test environment to verify all functionality
--->

<!--- Mock application variables for testing --->
<cfscript>
    // Simulate common application variables
    appName = "The Actor's Office";
    compName = "Dashboard";
    compDir = "dashboard";
    pgName = "Main Dashboard";
    pgHeading = "Dashboard Overview";
    home = "/app/dashboard";
    
    // Test different page configurations
    testCases = [
        {
            pgid: "89",
            ctaction: "view",
            description: "Dashboard with panel actions"
        },
        {
            pgid: "89", 
            ctaction: "edit",
            description: "Dashboard in edit mode"
        },
        {
            pgid: "117",
            contactid: "123",
            description: "Contact details with delete action"
        },
        {
            pgid: "175",
            projectDetails: {
                projName: "Test Project",
                audProjectId: "456"
            },
            description: "Project details with delete action"
        },
        {
            pgid: "189",
            rangeDisplay: "Jan 2025 - Dec 2025",
            description: "Page with range display"
        },
        {
            pgid: "5",
            rcontactid: "789",
            description: "Calendar appointments"
        },
        {
            pgid: "999",
            description: "Unknown page ID (default behavior)"
        }
    ];
</cfscript>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <title>Core Title Component Test</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    
    <!--- Bootstrap 5 CSS --->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    
    <!--- Feather Icons --->
    <link href="https://unpkg.com/feather-icons@4.28.0/dist/feather.css" rel="stylesheet">
    
    <!--- Material Design Icons --->
    <link href="https://cdn.jsdelivr.net/npm/@mdi/font@6.5.95/css/materialdesignicons.min.css" rel="stylesheet">
    
    <!--- Custom core title styles --->
    <link href="css/core_title.css" rel="stylesheet">
    
    <style>
        body { padding: 2rem; }
        .test-case { 
            margin-bottom: 3rem; 
            padding: 1.5rem;
            border: 1px solid #dee2e6;
            border-radius: 0.375rem;
        }
        .test-case h3 {
            color: #495057;
            border-bottom: 1px solid #dee2e6;
            padding-bottom: 0.5rem;
            margin-bottom: 1rem;
        }
        .code-preview {
            background: #f8f9fa;
            border: 1px solid #dee2e6;
            border-radius: 0.25rem;
            padding: 1rem;
            margin-top: 1rem;
            font-family: 'Courier New', monospace;
            font-size: 0.875rem;
        }
    </style>
</head>
<body>

<div class="container-fluid">
    <h1 class="mb-4">Core Title Component Test Cases</h1>
    <p class="lead">This page demonstrates the optimized core_title.cfm component with various page configurations.</p>
    
    <cfloop array="#testCases#" index="testCase">
        <cfoutput>
            <div class="test-case">
                <h3>Test Case: #testCase.description#</h3>
                
                <!--- Set up test variables --->
                <cfset pgid = testCase.pgid />
                <cfset ctaction = structKeyExists(testCase, 'ctaction') ? testCase.ctaction : 'view' />
                
                <!--- Set context variables if they exist --->
                <cfif structKeyExists(testCase, 'contactid')>
                    <cfset contactid = testCase.contactid />
                </cfif>
                <cfif structKeyExists(testCase, 'projectDetails')>
                    <cfset projectDetails = testCase.projectDetails />
                </cfif>
                <cfif structKeyExists(testCase, 'rangeDisplay')>
                    <cfset rangeDisplay = testCase.rangeDisplay />
                </cfif>
                <cfif structKeyExists(testCase, 'rcontactid')>
                    <cfset rcontactid = testCase.rcontactid />
                </cfif>
                
                <!--- Include the optimized component --->
                <div class="row">
                    <cfinclude template="core_title.cfm" />
                </div>
                
                <!--- Show configuration details --->
                <div class="code-preview">
                    <strong>Configuration:</strong><br>
                    pgid: #testCase.pgid#<br>
                    ctaction: #ctaction#<br>
                    <cfif structKeyExists(testCase, 'contactid')>
                        contactid: #testCase.contactid#<br>
                    </cfif>
                    <cfif structKeyExists(testCase, 'projectDetails')>
                        projectDetails: {projName: "#testCase.projectDetails.projName#", audProjectId: "#testCase.projectDetails.audProjectId#"}<br>
                    </cfif>
                    <cfif structKeyExists(testCase, 'rangeDisplay')>
                        rangeDisplay: #testCase.rangeDisplay#<br>
                    </cfif>
                    <cfif structKeyExists(testCase, 'rcontactid')>
                        rcontactid: #testCase.rcontactid#<br>
                    </cfif>
                </div>
            </div>
        </cfoutput>
    </cfloop>
    
    <div class="alert alert-info">
        <h4>Testing Notes:</h4>
        <ul>
            <li>Check that breadcrumbs render correctly with proper links</li>
            <li>Verify action buttons appear for appropriate page types</li>
            <li>Test responsive behavior by resizing the browser</li>
            <li>Verify accessibility with keyboard navigation</li>
            <li>Check that modals trigger correctly (may need backend setup)</li>
        </ul>
    </div>
</div>

<!--- Bootstrap 5 JS --->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>

</body>
</html>
