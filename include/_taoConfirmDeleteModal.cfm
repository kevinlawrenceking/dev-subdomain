<!--- Global TAO confirm-delete modal. Included once from /include/core.cfm so
      every authenticated page has it available. Any element with class
      "tao-confirm-delete" will trigger this modal on click; the click handler
      reads data-confirm-message and the element's href, populates the modal,
      and opens it. The Delete button is itself an <a> with the original href,
      so confirming = navigating. Use BS5 (loaded site-wide via vendor.min.js)
      for styling, positioning, and backdrop. --->
<div id="taoConfirmDeleteModal" class="modal fade" tabindex="-1" role="dialog" aria-labelledby="taoConfirmDeleteLabel" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content">
            <div class="modal-header">
                <h4 class="modal-title" id="taoConfirmDeleteLabel">Confirm Delete</h4>
                <button type="button" class="close" data-bs-dismiss="modal" aria-label="Close">
                    <i class="mdi mdi-close-thick"></i>
                </button>
            </div>
            <div class="modal-body">
                <p id="taoConfirmDeleteMessage" class="mb-0">Are you sure?</p>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                <a href="##" id="taoConfirmDeleteAction" class="btn btn-danger">Delete</a>
            </div>
        </div>
    </div>
</div>

<script>
    // taoConfirmDelete(message, onConfirm) — programmatic API for callers that
    // can't use the <a class="tao-confirm-delete"> link pattern (e.g. POST
    // fetch flows). Pops the BS5 modal with the given message; runs onConfirm
    // when the user clicks Delete. The action button is cloned on every call
    // so prior listeners (or stale anchor href values) cannot leak across
    // invocations.
    window.taoConfirmDelete = function(message, onConfirm) {
        var modalEl = document.getElementById('taoConfirmDeleteModal');
        var oldBtn = document.getElementById('taoConfirmDeleteAction');
        document.getElementById('taoConfirmDeleteMessage').textContent = message || 'Are you sure?';

        var newBtn = oldBtn.cloneNode(true);
        newBtn.setAttribute('href', '##');
        oldBtn.parentNode.replaceChild(newBtn, oldBtn);

        newBtn.addEventListener('click', function(e) {
            e.preventDefault();
            if (typeof bootstrap !== 'undefined' && bootstrap.Modal) {
                var inst = bootstrap.Modal.getInstance(modalEl);
                if (inst) inst.hide();
            }
            if (typeof onConfirm === 'function') onConfirm();
        }, { once: true });

        if (typeof bootstrap !== 'undefined' && bootstrap.Modal) {
            bootstrap.Modal.getOrCreateInstance(modalEl).show();
        } else if (window.confirm(message)) {
            if (typeof onConfirm === 'function') onConfirm();
        }
    };

    // Click on any <a class="tao-confirm-delete"> intercepts navigation,
    // routes through taoConfirmDelete() so anchor and programmatic flows
    // share one code path. Delegated on document so it works for content
    // re-rendered into AJAX panes.
    $(document).on('click', '.tao-confirm-delete', function(e) {
        e.preventDefault();
        var url = this.getAttribute('href');
        var message = this.getAttribute('data-confirm-message') || 'Are you sure?';
        window.taoConfirmDelete(message, function() {
            window.location.href = url;
        });
    });
</script>
