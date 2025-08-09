<!--- This ColdFusion page displays a modal for subscription URL information. --->
<div id="subscription" class="modal fade" tabindex="-1" aria-labelledby="standard-modalLabel">
  <div class="modal-dialog">
    <script src="https://ajax.googleapis.com/include/libs/jquery/1.11.1/jquery.min.js"></script>
    <div class="modal-content">
      <div class="modal-header">
        <h4 class="modal-title" id="standard-modalLabel">Subscription URL</h4>
        <button type="button" class="close" data-bs-dismiss="modal">
          <i class="mdi mdi-close-thick"></i>
        </button>
      </div>
      <div class="modal-body">
        <center>
          <!--- Output the subscription calendar URL --->
          <cfoutput>
            <h5 id="p1">#session.userCalendarUrl#</h5>
          </cfoutput>
        </center>
        <p>&nbsp;</p>
      </div>
    </div>
  </div>
</div>
