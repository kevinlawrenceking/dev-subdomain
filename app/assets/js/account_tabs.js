(function () {
    'use strict';

    var tabCache = {};
    var inflight = {};

    function getCsrfToken() {
        var meta = document.querySelector('meta[name="csrf-token"]');
        return meta ? meta.getAttribute('content') : '';
    }

    function renderError(paneEl, refMessage) {
        var html =
            '<div class="alert alert-danger" data-tab-error="1">' +
                '<strong>Couldn\'t load this tab.</strong>' +
                '<div class="small text-muted">Reference: ' + refMessage + '</div>' +
                '<button type="button" class="btn btn-sm btn-outline-secondary mt-2 tao-tab-retry">Retry</button>' +
            '</div>';
        $(paneEl).html(html);
        paneEl.setAttribute('data-loaded', 'error');
    }

    function loadPane(paneEl) {
        if (!paneEl) return;
        var url = paneEl.getAttribute('data-tab-url');
        if (!url) return;

        var loaded = paneEl.getAttribute('data-loaded');
        if (loaded === '1') return;

        if (inflight[url]) return;

        if (Object.prototype.hasOwnProperty.call(tabCache, url)) {
            $(paneEl).html(tabCache[url]);
            paneEl.setAttribute('data-loaded', '1');
            return;
        }

        inflight[url] = true;

        fetch(url, {
            method: 'GET',
            credentials: 'same-origin',
            headers: {
                'X-Requested-With': 'XMLHttpRequest',
                'X-CSRF-Token': getCsrfToken(),
                'Accept': 'text/html'
            }
        })
        .then(function (response) {
            return response.text().then(function (body) {
                return { ok: response.ok, status: response.status, body: body };
            });
        })
        .then(function (res) {
            delete inflight[url];
            var looksLikeError = res.body.indexOf('data-tab-error="1"') !== -1;
            if (!res.ok || looksLikeError) {
                if (looksLikeError && res.body) {
                    $(paneEl).html(res.body);
                    paneEl.setAttribute('data-loaded', 'error');
                } else {
                    renderError(paneEl, 'HTTP ' + res.status);
                }
                return;
            }
            tabCache[url] = res.body;
            $(paneEl).html(res.body);
            paneEl.setAttribute('data-loaded', '1');
        })
        .catch(function (err) {
            delete inflight[url];
            console.error('account_tabs loadPane failed', err);
            renderError(paneEl, 'Network error');
        });
    }

    // Bootstrap 5 dispatches show.bs.tab as a NATIVE CustomEvent. jQuery's
    // $(document).on('show.bs.tab', ...) parses the name as type=show + ns=.bs.tab
    // and binds addEventListener('show', ...), which never matches BS5's literal
    // 'show.bs.tab' event type. Use a native listener instead.
    document.addEventListener('show.bs.tab', function (e) {
        var trigger = e.target;
        if (!trigger || trigger.nodeType !== 1) return;
        if (!(trigger.matches && trigger.matches('[data-bs-toggle="tab"]'))) return;
        var targetSel = trigger.getAttribute('data-bs-target') || trigger.getAttribute('href');
        if (!targetSel) return;
        var paneEl = document.querySelector(targetSel);
        if (paneEl && paneEl.hasAttribute('data-tab-url')) {
            loadPane(paneEl);
        }
    });

    $(document).on('click', '.tao-tab-retry', function () {
        var paneEl = this.closest('.tab-pane');
        if (!paneEl) return;
        var url = paneEl.getAttribute('data-tab-url');
        if (url) {
            delete tabCache[url];
        }
        paneEl.setAttribute('data-loaded', '0');
        loadPane(paneEl);
    });

    document.addEventListener('DOMContentLoaded', function () {
        var actives = document.querySelectorAll('.tab-pane.show.active[data-tab-url]');
        for (var i = 0; i < actives.length; i++) {
            loadPane(actives[i]);
        }
    });
})();
