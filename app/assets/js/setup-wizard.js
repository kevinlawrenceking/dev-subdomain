/**
 * P11: Onboarding Wizard -- Navigation & AJAX Controller
 *
 * Manages step loading, saving, skipping, browser history,
 * and progress stepper updates for the 7-step wizard.
 *
 * MIGRATE: In Flutter, this becomes a PageView/Stepper widget
 * with the same step definitions.
 */
(function($) {
    'use strict';

    var W = window.TAO_WIZARD;
    var step = W.currentStep;
    var saving = false;
    var $content = $('#wizard-step-content');
    var $btnNext = $('#btn-next');
    var $btnBack = $('#btn-back');
    var $btnSkip = $('#btn-skip');
    var $stepper = $('#wizard-stepper');

    // ---- Helpers ----

    function getCsrf() {
        var meta = document.querySelector('meta[name="csrf-token"]');
        return meta ? meta.getAttribute('content') : W.csrfToken;
    }

    function ajaxPost(url, data) {
        data.csrfToken = getCsrf();
        return $.ajax({
            url: url,
            type: 'POST',
            data: data,
            dataType: 'json',
            headers: { 'X-CSRF-Token': getCsrf() }
        });
    }

    function ajaxPostJSON(url, payload) {
        return $.ajax({
            url: url,
            type: 'POST',
            data: JSON.stringify(payload),
            contentType: 'application/json; charset=utf-8',
            dataType: 'json',
            headers: { 'X-CSRF-Token': getCsrf() }
        });
    }

    // Determine the next logical step (skips step 4 if audition module off)
    function nextStep(current) {
        var next = current + 1;
        if (!W.showAuditionStep && next === 4) next = 5;
        return Math.min(next, 7);
    }

    // Determine previous logical step
    function prevStep(current) {
        var prev = current - 1;
        if (!W.showAuditionStep && prev === 4) prev = 3;
        return Math.max(prev, 1);
    }

    // ---- Stepper UI ----

    function updateStepper(currentStep) {
        $stepper.find('.step-item').each(function() {
            var $item = $(this);
            var s = parseInt($item.data('step'), 10);
            $item.removeClass('active completed');
            if (s < currentStep) {
                $item.addClass('completed');
                $item.find('.step-circle').html(
                    '<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3" stroke-linecap="round" stroke-linejoin="round"><polyline points="20 6 9 17 4 12"/></svg>'
                );
            } else if (s === currentStep) {
                $item.addClass('active');
                // Find visual index for circle number
                var idx = W.visibleSteps.indexOf(s);
                $item.find('.step-circle').text(idx >= 0 ? idx + 1 : s);
            } else {
                var idx2 = W.visibleSteps.indexOf(s);
                $item.find('.step-circle').text(idx2 >= 0 ? idx2 + 1 : s);
            }
        });

        // Update arrows
        $stepper.find('.step-arrow').each(function() {
            var $arrow = $(this);
            var $prev = $arrow.prev('.step-item');
            if ($prev.hasClass('completed') || $prev.hasClass('active')) {
                $arrow.css('color', '#406e8e');
            } else {
                $arrow.css('color', '#dee2e6');
            }
        });
    }

    // ---- Footer buttons ----

    function updateButtons(currentStep) {
        // Back: hidden on step 1
        $btnBack.toggle(currentStep > 1);

        // Skip: hidden on steps 1 and 7
        $btnSkip.toggle(currentStep > 1 && currentStep < 7);

        // Next: label changes on step 7
        if (currentStep === 7) {
            $btnNext.html('Go to My Dashboard <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="ms-1"><line x1="5" y1="12" x2="19" y2="12"/><polyline points="12 5 19 12 12 19"/></svg>');
        } else if (currentStep === 6) {
            $btnNext.html('Finish Setup <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="ms-1"><line x1="5" y1="12" x2="19" y2="12"/><polyline points="12 5 19 12 12 19"/></svg>');
        } else {
            $btnNext.html('Next <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="ms-1"><line x1="5" y1="12" x2="19" y2="12"/><polyline points="12 5 19 12 12 19"/></svg>');
        }

        // Re-enable
        $btnNext.prop('disabled', false);
    }

    // ---- Form persistence (sessionStorage) ----

    function cacheKey(stepNum) { return 'wizard_step_' + stepNum; }

    function cacheStepData(stepNum) {
        var vals = {};
        $content.find('input, select, textarea').each(function() {
            var $el = $(this);
            var key = $el.attr('name') || $el.attr('data-field');
            if (!key) return;
            if ($el.is(':checkbox') || $el.is(':radio')) {
                if ($el.is(':checked')) vals[key] = $el.val();
            } else {
                vals[key] = $el.val();
            }
        });
        try { sessionStorage.setItem(cacheKey(stepNum), JSON.stringify(vals)); } catch(e) {}
    }

    function restoreStepCache(stepNum) {
        var raw;
        try { raw = sessionStorage.getItem(cacheKey(stepNum)); } catch(e) {}
        if (!raw) return;
        var vals;
        try { vals = JSON.parse(raw); } catch(e) { return; }
        $.each(vals, function(key, val) {
            var $el = $content.find('[name="' + key + '"], [data-field="' + key + '"]');
            if (!$el.length) return;
            $el.each(function() {
                var $field = $(this);
                if ($field.is('select')) {
                    var serverVal = $field.val();
                    if (serverVal && serverVal !== '' && serverVal !== '0') {
                        return;
                    }
                }
                if ($field.is(':checkbox') || $field.is(':radio')) {
                    $field.prop('checked', $field.val() === val);
                } else {
                    $field.val(val);
                }
            });
        });
    }

    function clearStepCache(stepNum) {
        try { sessionStorage.removeItem(cacheKey(stepNum)); } catch(e) {}
    }

    // ---- Step loading ----

    function loadStep(stepNum) {
        step = stepNum;
        $content.html(
            '<div class="wizard-loading">' +
            '<div class="spinner-border spinner-border-sm text-secondary me-2" role="status"></div>' +
            'Loading...</div>'
        );
        updateStepper(step);
        updateButtons(step);

        $.ajax({
            url: '/ajax/setup-wizard/load-step.cfm',
            type: 'GET',
            data: { step: step },
            dataType: 'html',
            success: function(html) {
                $content.html(html);
                // Initialize Parsley on any forms in the loaded content
                $content.find('form[data-parsley-validate]').parsley();
                // Restore cached form values (back-navigation persistence)
                restoreStepCache(step);
                // Auto-cache form changes
                $content.on('input change', 'input, select, textarea', function() {
                    cacheStepData(step);
                });
                // Push browser history state
                history.pushState({ step: step }, '', '/app/setup-wizard/?step=' + step);
            },
            error: function(xhr) {
                if (xhr.status === 401) {
                    window.location.href = '/loginform.cfm?returnUrl=' + encodeURIComponent('/app/setup-wizard/?step=' + step);
                    return;
                }
                $content.html('<div class="text-center text-danger py-5">Failed to load step. <a href="javascript:void(0)" onclick="window.TAO_WIZARD_RELOAD()">Try again</a></div>');
                taoToast('Failed to load step content', 'error');
            }
        });
    }

    window.TAO_WIZARD_RELOAD = function() { loadStep(step); };

    // ---- Collect form data from current step ----

    /**
     * Each step's HTML can define a global function window.wizardCollectStepData
     * that returns the data object to POST, or null to indicate validation failure.
     * If not defined, default behavior is to serialize the first form found.
     */
    function collectStepData() {
        if (typeof window.wizardCollectStepData === 'function') {
            return window.wizardCollectStepData();
        }
        var $form = $content.find('form').first();
        if ($form.length) {
            // Run Parsley validation
            if ($form.data('parsley') && !$form.parsley().isValid()) {
                $form.parsley().validate();
                return null;
            }
            var data = {};
            $form.serializeArray().forEach(function(item) {
                data[item.name] = item.value;
            });
            return data;
        }
        return {};
    }

    // ---- Event handlers ----

    // Next / Save
    $btnNext.on('click', function() {
        if (saving) return;

        var data = collectStepData();
        if (data === null) return; // validation failed

        saving = true;
        $btnNext.prop('disabled', true);

        ajaxPost('/ajax/setup-wizard/save-step' + step + '.cfm', data)
            .done(function(resp) {
                if (resp.success) {
                    clearStepCache(step);
                    if (step === 7) {
                        // Wizard complete -- redirect to dashboard
                        sessionStorage.setItem('taoWizardComplete', 'true');
                        window.location.href = resp.redirect || '/app/';
                        return;
                    }
                    loadStep(nextStep(step));
                } else {
                    taoToast(resp.message || 'Save failed', 'error');
                    $btnNext.prop('disabled', false);
                }
            })
            .fail(function(xhr) {
                if (xhr.status === 401) {
                    window.location.href = '/loginform.cfm?returnUrl=' + encodeURIComponent('/app/setup-wizard/?step=' + step);
                    return;
                }
                var msg = 'Save failed';
                try { msg = JSON.parse(xhr.responseText).message || msg; } catch(e) {}
                taoToast(msg, 'error');
                $btnNext.prop('disabled', false);
            })
            .always(function() {
                saving = false;
            });
    });

    // Back
    $btnBack.on('click', function() {
        if (saving) return;
        loadStep(prevStep(step));
    });

    // Complete-step (step 7) summary "Edit" links jump back to the relevant
    // wizard step. They previously pointed at /app/* routes, which the
    // Setup-status guard in Application.cfc redirects back to the wizard
    // (apparent no-op page reload). Delegated from $content because the step
    // markup is injected after load. Items with no step render no Edit link.
    $content.on('click', '.summary-edit', function(e) {
        e.preventDefault();
        var s = parseInt($(this).attr('data-edit-step'), 10);
        if (s) { loadStep(s); }
    });

    // Skip
    $btnSkip.on('click', function() {
        if (saving) return;
        saving = true;
        $btnSkip.css('pointer-events', 'none');

        ajaxPost('/ajax/setup-wizard/skip-step.cfm', { step: step })
            .done(function(resp) {
                if (resp.success) {
                    loadStep(resp.nextStep);
                } else {
                    taoToast(resp.message || 'Skip failed', 'error');
                }
            })
            .fail(function(xhr) {
                if (xhr.status === 401) {
                    window.location.href = '/loginform.cfm?returnUrl=' + encodeURIComponent('/app/setup-wizard/?step=' + step);
                    return;
                }
                taoToast('Skip failed', 'error');
            })
            .always(function() {
                saving = false;
                $btnSkip.css('pointer-events', '');
            });
    });

    // Browser back/forward
    window.addEventListener('popstate', function(e) {
        if (e.state && e.state.step) {
            loadStep(e.state.step);
        }
    });

    // ---- Welcome toast on dashboard after wizard completion ----
    if (window.location.pathname.indexOf('/setup-wizard') === -1
        && sessionStorage.getItem('taoWizardComplete')) {
        sessionStorage.removeItem('taoWizardComplete');
        setTimeout(function() {
            if (typeof taoToast === 'function') {
                taoToast("You're all set! Your first reminders will appear here.", 'success');
            }
        }, 500);
    }

    // ---- Initial load ----
    loadStep(step);

})(jQuery);
