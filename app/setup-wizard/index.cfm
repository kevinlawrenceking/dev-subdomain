<!---
    P11: Onboarding Wizard Shell
    Single-page AJAX shell that loads step content dynamically.
    Lives under /app/ to inherit TAO session scope and auth gate.

    MIGRATE: In Go/Flutter, this becomes a multi-screen onboarding flow
    with the same 7 steps as Flutter widgets.
--->

<!--- Auth gate: require authenticated session --->
<cfif NOT structKeyExists(session, "userid")>
    <cflocation url="/loginform.cfm" addToken="false" />
</cfif>

<!--- Determine current step from session (set by fetchUsers.cfm) --->
<cfparam name="session.setup_step" default="0" />
<cfset currentStep = val(session.setup_step) + 1>
<cfif currentStep GT 7>
    <cfset currentStep = 7>
</cfif>

<!--- Allow url.step to resume after re-login (session timeout recovery) --->
<cfparam name="url.step" default="0" />
<cfif val(url.step) GTE 1 AND val(url.step) LTE 7>
    <cfset currentStep = val(url.step)>
</cfif>

<!--- TECH-DEBT: isauditionmodule gating removed per product decision 2026-04. Audition module is universal. --->
<cfset showAuditionStep = true>

<!--- Build step list (conditionally exclude step 4) --->
<cfset stepLabels = ["Account", "Reps", "Contacts", "Auditions", "Reminders", "Links", "Complete"]>
<cfif NOT showAuditionStep>
    <!--- Visual steps exclude auditions: 1,2,3,5,6,7 mapped to visual 1-6 --->
    <cfset visibleSteps = [1,2,3,5,6,7]>
<cfelse>
    <cfset visibleSteps = [1,2,3,4,5,6,7]>
</cfif>

<cfset IMAGESURL = "/media-" & application.dsn & "/images">

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta http-equiv="X-UA-Compatible" content="IE=edge" />
    <title>Setup Wizard | The Actors Office</title>
    <meta name="robots" content="noindex">

    <link rel="shortcut icon" href="/media/shared/images/favicon.ico">

    <!--- CSRF token for AJAX posts (Application.cfc validates globally) --->
    <cfif structKeyExists(session, "csrfToken")>
        <cfoutput><meta name="csrf-token" content="#session.csrfToken#"></cfoutput>
    </cfif>

    <!--- Core CSS --->
    <link href="/app/assets/css/app.min.css" rel="stylesheet" type="text/css" />
    <link href="/app/assets/css/icons.min.css" rel="stylesheet" type="text/css" />
    <link href="/app/assets/css/tao-components.css" rel="stylesheet" type="text/css" />
    <link href="https://cdnjs.cloudflare.com/ajax/libs/croppie/2.6.5/croppie.min.css" rel="stylesheet" />
    <link href="/app/assets/css/setup-wizard.css" rel="stylesheet" type="text/css" />

    <!--- Core JS --->
    <script src="/app/assets/js/jquery-3.6.0.min.js"></script>
    <script src="/app/assets/js/bootstrap.bundle.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/croppie/2.6.5/croppie.min.js"></script>
</head>

<body class="wizard-wrapper">

    <!--- Header bar --->
    <div class="wizard-header">
        <div class="wizard-brand">
            <div class="wizard-brand-title">The Actors Office</div>
            <div class="wizard-brand-subtitle">Career Management Platform</div>
        </div>
    </div>

    <!--- Main wizard card --->
    <div class="wizard-card">

        <!--- Progress stepper --->
        <div class="wizard-stepper" id="wizard-stepper">
            <cfoutput>
            <cfloop from="1" to="#arrayLen(visibleSteps)#" index="vi">
                <cfset realStep = visibleSteps[vi]>
                <cfset stepClass = "">
                <cfif realStep LT currentStep>
                    <cfset stepClass = "completed">
                <cfelseif realStep EQ currentStep>
                    <cfset stepClass = "active">
                </cfif>

                <div class="step-item #stepClass#" data-step="#realStep#">
                    <span class="step-circle">
                        <cfif realStep LT currentStep>
                            <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3" stroke-linecap="round" stroke-linejoin="round"><polyline points="20 6 9 17 4 12"/></svg>
                        <cfelse>
                            #vi#
                        </cfif>
                    </span>
                    <span class="step-label">#stepLabels[realStep]#</span>
                </div>

                <cfif vi LT arrayLen(visibleSteps)>
                    <span class="step-arrow">&rsaquo;</span>
                </cfif>
            </cfloop>
            </cfoutput>
        </div>

        <!--- Step content container (loaded via AJAX) --->
        <div class="wizard-step-content" id="wizard-step-content">
            <div class="wizard-loading">
                <div class="spinner-border spinner-border-sm text-secondary me-2" role="status"></div>
                Loading...
            </div>
        </div>

        <!--- Navigation footer --->
        <div class="wizard-footer" id="wizard-footer">
            <div>
                <button type="button" class="btn btn-outline-secondary btn-sm" id="btn-back" style="display:none;">
                    <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="me-1"><line x1="19" y1="12" x2="5" y2="12"/><polyline points="12 19 5 12 12 5"/></svg>
                    Back
                </button>
            </div>
            <div>
                <a href="javascript:void(0)" class="btn-skip" id="btn-skip" style="display:none;">
                    I'll do this later
                </a>
            </div>
            <div>
                <button type="button" class="btn btn-primary btn-sm" id="btn-next">
                    Next
                    <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="ms-1"><line x1="5" y1="12" x2="19" y2="12"/><polyline points="12 5 19 12 12 19"/></svg>
                </button>
            </div>
        </div>

    </div>

    <!--- Toast container --->
    <script src="/app/assets/js/tao-toast.js"></script>

    <!--- Parsley for form validation --->
    <script src="/app/assets/js/libs/parsleyjs/parsley.min.js"></script>

    <!--- Wizard config (server-side values for JS) --->
    <cfoutput>
    <script>
        window.TAO_WIZARD = {
            currentStep: #currentStep#,
            showAuditionStep: #showAuditionStep ? 'true' : 'false'#,
            visibleSteps: #serializeJSON(visibleSteps)#,
            csrfToken: document.querySelector('meta[name="csrf-token"]')
                       ? document.querySelector('meta[name="csrf-token"]').getAttribute('content')
                       : '',
            userId: #session.userid#
        };
    </script>
    </cfoutput>

    <!--- Wizard navigation JS --->
    <script src="/app/assets/js/setup-wizard.js"></script>

</body>
</html>
