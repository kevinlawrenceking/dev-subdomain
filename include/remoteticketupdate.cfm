<!--- This ColdFusion page handles the form submission for updating remote ticket information. --->

<form action="/include/remoteticketupdate2.cfm" method="post" class="parsley-examples"  
      data-parsley-excluded="input[type=button], input[type=submit], input[type=reset], input[type=hidden], [disabled], :hidden"
      data-parsley-trigger="keyup" 
      data-parsley-validate 
      id="actinglinks_update">

    <!--- Form container for the update action --->
    <div class="row"></div>

    <div class="form-group text-center col-md-12">
        <!--- Submit button for updating the ticket --->
        <button class="btn btn-primary editable-submit btn-sm waves-effect waves-light" 
                type="submit" 
                style="background-color: #406e8e; border: #406e8e;">
            Update
        </button>
    </div>

</form>

<!--- jQuery document ready function to initialize Parsley validation --->
<script>      
    $(document).ready(function() {
        $(".parsley-examples").parsley();
    });
</script>
