<!--- This ColdFusion page displays a modal for subscription URL information.
     TAO-CAL-01: on modal open, call /ajax/calendar-subscription-url.cfm to
     regenerate the .ics synchronously and refresh the displayed URL. --->
<div id="subscription" class="modal fade" tabindex="-1" aria-labelledby="standard-modalLabel">
  <div class="modal-dialog">

    <div class="modal-content">
      <div class="modal-header">
        <h4 class="modal-title" id="standard-modalLabel">Subscription URL</h4>
        <button type="button" class="close" data-bs-dismiss="modal">
          <i class="mdi mdi-close-thick"></i>
        </button>
      </div>
      <div class="modal-body">
        <center>
          <!--- Output the subscription calendar URL (refreshed on modal open) --->
          <cfoutput>
            <h5 id="p1">#session.userCalendarUrl#</h5>
          </cfoutput>
        </center>
        <p>&nbsp;</p>
      </div>
    </div>
  </div>
</div>

<cfset tao_cal01_csrf = structKeyExists(session, "csrfToken") ? session.csrfToken : "">
<cfoutput>
<script>
(function () {
    var modalEl = document.getElementById('subscription');
    if (!modalEl || modalEl.dataset.taoCal01Bound === '1') return;
    modalEl.dataset.taoCal01Bound = '1';

    var csrfToken = '#encodeForJavaScript(tao_cal01_csrf)#';

    modalEl.addEventListener('show.bs.modal', function () {
        var urlEl = document.getElementById('p1');
        if (urlEl) urlEl.textContent = 'Generating subscription link...';

        fetch('/ajax/calendar-subscription-url.cfm', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'X-CSRF-Token': csrfToken,
                'X-Requested-With': 'XMLHttpRequest'
            },
            body: '{}'
        })
        .then(function (r) { return r.json(); })
        .then(function (data) {
            if (urlEl) {
                if (data && data.success && data.url) {
                    urlEl.textContent = data.url;
                } else {
                    urlEl.textContent = (data && data.message) ? data.message : 'Subscription link unavailable';
                }
            }
        })
        .catch(function () {
            if (urlEl) urlEl.textContent = 'Subscription link unavailable';
        });
    });
})();
</script>
</cfoutput>
