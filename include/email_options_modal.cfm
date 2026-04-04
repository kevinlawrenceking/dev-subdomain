<!--- Shared Email Options Modal - renders once per request via guard variable --->
<cfif NOT isDefined("request.taoEmailModalRendered")>
<cfset request.taoEmailModalRendered = true>

<div id="taoEmailModal" class="modal fade" tabindex="-1" role="dialog">
    <div class="modal-dialog modal-sm modal-dialog-centered">
        <div class="modal-content">
            <div class="modal-header py-2">
                <h5 class="modal-title" id="taoEmailModalTitle">Email</h5>
                <button type="button" class="close" data-bs-dismiss="modal"><i class="mdi mdi-close-thick"></i></button>
            </div>
            <div class="modal-body p-0">
                <div class="list-group list-group-flush">
                    <a href="javascript:;" id="taoEmailGmail" class="list-group-item list-group-item-action d-flex align-items-center">
                        <i class="mdi mdi-google font-18 me-2 text-danger"></i> Gmail
                    </a>
                    <a href="javascript:;" id="taoEmailOutlook" class="list-group-item list-group-item-action d-flex align-items-center">
                        <i class="mdi mdi-microsoft-outlook font-18 me-2 text-primary"></i> Outlook
                    </a>
                    <a href="javascript:;" id="taoEmailYahoo" class="list-group-item list-group-item-action d-flex align-items-center">
                        <i class="mdi mdi-yahoo font-18 me-2 text-purple"></i> Yahoo Mail
                    </a>
                    <a href="javascript:;" id="taoEmailDefault" class="list-group-item list-group-item-action d-flex align-items-center">
                        <i class="fe-mail font-18 me-2 text-secondary"></i> Default Mail App
                    </a>
                    <a href="javascript:;" id="taoEmailCopy" class="list-group-item list-group-item-action d-flex align-items-center">
                        <i class="mdi mdi-content-copy font-18 me-2 text-muted"></i> Copy Email Address
                    </a>
                </div>
            </div>
        </div>
    </div>
</div>

<script>
$(document).ready(function() {
    var taoEmailModal = document.getElementById('taoEmailModal');
    if (taoEmailModal) {
        taoEmailModal.addEventListener('show.bs.modal', function(event) {
            var trigger = event.relatedTarget;
            var email = trigger.getAttribute('data-email');
            var body = encodeURIComponent('\n\nPowered by The Actors Office');

            document.getElementById('taoEmailModalTitle').textContent = 'Email ' + email;

            document.getElementById('taoEmailGmail').onclick = function() {
                window.open('https://mail.google.com/mail/?view=cm&to=' + encodeURIComponent(email) + '&body=' + body, '_blank');
                $('#taoEmailModal').modal('hide');
            };
            document.getElementById('taoEmailOutlook').onclick = function() {
                window.open('https://outlook.live.com/mail/0/deeplink/compose?to=' + encodeURIComponent(email) + '&body=' + body, '_blank');
                $('#taoEmailModal').modal('hide');
            };
            document.getElementById('taoEmailYahoo').onclick = function() {
                window.open('https://compose.mail.yahoo.com/?to=' + encodeURIComponent(email) + '&body=' + body, '_blank');
                $('#taoEmailModal').modal('hide');
            };
            document.getElementById('taoEmailDefault').onclick = function() {
                window.location.href = 'mailto:' + email + '?body=' + body;
                $('#taoEmailModal').modal('hide');
            };
            document.getElementById('taoEmailCopy').onclick = function() {
                navigator.clipboard.writeText(email);
                var el = this;
                el.innerHTML = '<i class="mdi mdi-check font-18 me-2 text-success"></i> Copied!';
                setTimeout(function() {
                    $('#taoEmailModal').modal('hide');
                    el.innerHTML = '<i class="mdi mdi-content-copy font-18 me-2 text-muted"></i> Copy Email Address';
                }, 800);
            };
        });
    }
});
</script>

</cfif>
