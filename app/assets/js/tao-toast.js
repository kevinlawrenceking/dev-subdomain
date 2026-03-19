/* ==========================================================================
   tao-toast.js  --  Shared toast notification utility for TAO
   ==========================================================================
   Uses Bootstrap 5 Toast API (no jQuery dependency).
   Dynamically creates toast elements since app.min.js auto-init only
   runs at DOMContentLoaded.

   Usage:
     taoToast('Contact saved successfully');                       // default success
     taoToast('Something went wrong', 'error');                    // sticky error
     taoToast('Check your input', 'warning', { duration: 6000 }); // custom duration

   Types: success | error | warning | info
   ========================================================================== */

(function () {
    'use strict';

    /* ------------------------------------------------------------------
       Config per type
       ------------------------------------------------------------------ */
    var TYPES = {
        success: { icon: 'mdi mdi-check-circle',        bg: '#0acf97', autohide: true,  delay: 5000 },
        error:   { icon: 'mdi mdi-alert-circle-outline', bg: '#fa5c7c', autohide: false, delay: 0    },
        warning: { icon: 'mdi mdi-alert',                bg: '#ffbc00', autohide: true,  delay: 8000 },
        info:    { icon: 'mdi mdi-information',          bg: '#39afd1', autohide: true,  delay: 5000 }
    };

    /* ------------------------------------------------------------------
       Ensure a single toast container exists (top-right, above modals)
       ------------------------------------------------------------------ */
    var containerId = 'tao-toast-container';

    function getContainer() {
        var el = document.getElementById(containerId);
        if (!el) {
            el = document.createElement('div');
            el.id = containerId;
            el.setAttribute('aria-live', 'polite');
            el.style.cssText =
                'position:fixed;top:4.5rem;right:1rem;z-index:1090;' +
                'display:flex;flex-direction:column;gap:.5rem;pointer-events:none;';
            document.body.appendChild(el);
        }
        return el;
    }

    /* ------------------------------------------------------------------
       Build and show a toast
       ------------------------------------------------------------------ */
    function taoToast(message, type, options) {
        type    = type && TYPES[type] ? type : 'success';
        options = options || {};

        var cfg      = TYPES[type];
        var duration = typeof options.duration === 'number' ? options.duration : cfg.delay;
        var autohide = type === 'error' ? false : cfg.autohide;

        // Outer toast element
        var toast = document.createElement('div');
        toast.className = 'toast align-items-center border-0 show';
        toast.setAttribute('role', 'alert');
        toast.setAttribute('aria-live', 'assertive');
        toast.setAttribute('aria-atomic', 'true');
        toast.style.cssText =
            'pointer-events:auto;color:#fff;background-color:' + cfg.bg +
            ';min-width:280px;max-width:380px;border-radius:.375rem;' +
            'box-shadow:0 .25rem .75rem rgba(0,0,0,.15);';

        // Inner layout
        var inner = document.createElement('div');
        inner.className = 'd-flex';

        var body = document.createElement('div');
        body.className = 'toast-body d-flex align-items-center gap-2';
        body.style.cssText = 'font-size:.875rem;';
        body.innerHTML = '<i class="' + cfg.icon + '" style="font-size:1.1rem;"></i> ' +
                          escapeHtml(message);

        var closeBtn = document.createElement('button');
        closeBtn.type = 'button';
        closeBtn.className = 'btn-close btn-close-white me-2 m-auto';
        closeBtn.setAttribute('aria-label', 'Close');

        inner.appendChild(body);
        inner.appendChild(closeBtn);
        toast.appendChild(inner);

        var container = getContainer();
        container.appendChild(toast);

        // Bootstrap Toast instance (handles auto-dismiss)
        var bsToast = new bootstrap.Toast(toast, {
            autohide: autohide,
            delay: duration
        });
        bsToast.show();

        // Close button
        closeBtn.addEventListener('click', function () {
            bsToast.hide();
        });

        // Cleanup DOM after hidden
        toast.addEventListener('hidden.bs.toast', function () {
            if (toast.parentNode) {
                toast.parentNode.removeChild(toast);
            }
        });
    }

    /* ------------------------------------------------------------------
       Minimal HTML escape
       ------------------------------------------------------------------ */
    function escapeHtml(str) {
        var div = document.createElement('div');
        div.appendChild(document.createTextNode(str));
        return div.innerHTML;
    }

    /* ------------------------------------------------------------------
       Expose globally
       ------------------------------------------------------------------ */
    window.taoToast = taoToast;
})();
