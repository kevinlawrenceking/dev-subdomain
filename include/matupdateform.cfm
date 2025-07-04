<!--- This ColdFusion page handles the update form submission for material updates. --->

<p>Enter the information below and press the update button to continue.</p>

<form action="/include/matupdateform2.cfm" method="post" class="parsley-examples" name="event-form" id="form-event" 
      data-parsley-excluded="input[type=button], input[type=submit], input[type=reset], input[type=hidden], [disabled], :hidden" 
      data-parsley-trigger="keyup" data-parsley-validate>
    
    <div class="form-group text-center col-md-12">
        <!--- Button to submit the update form --->
        <button class="btn btn-xs btn-primary waves-effect mb-2 waves-light" 
                style="background-color: #406e8e; border: #406e8e;" 
                type="submit">Update</button>
    </div>
    
</form>

<!--- Include the Parsley.js library for form validation --->
<script src="/app/assets/js/libs/parsleyjs/parsley.min.js"></script>
