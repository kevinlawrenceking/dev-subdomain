<!--- This ColdFusion page displays a detail view and allows editing of details via a modal. --->

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Detail Page</title>
    <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.3.1/css/bootstrap.min.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/include/libs/toastr.js/latest/toastr.min.css">
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <script src="https://cdnjs.cloudflare.com/include/libs/toastr.js/latest/toastr.min.js"></script>
</head>
<body>

<!--- Include details query template --->
<cfinclude template="/include/qry/details_106_1.cfm" />

<div class="container">
    <h1>Detail Page</h1>
    <p id="detailText">#details.valueText#</p>
    <button class="btn btn-primary" id="editButton" data-itemid="#details.itemid#">Edit</button>
</div>

<!--- Edit Modal --->
<div class="modal fade" id="editModal" tabindex="-1" role="dialog" aria-labelledby="editModalLabel" >

    <div class="modal-dialog" role="document">
        <div class="modal-content" id="modalContent">
            <!--- Modal content will be loaded here --->
        </div>
    </div>
</div>

<script>
$(document).ready(function() {
    
    <!--- Event handler for edit button click --->
    $('#editButton').on('click', function() {
        var itemid = $(this).data('itemid');
        
        <!--- Load modal content dynamically --->
        $.ajax({
            url: '/include/getModalContent.cfm',
            type: 'GET',
            data: { itemid: itemid },
            success: function(response) {
                $('#modalContent').html(response);
                $('#editModal').modal('show');
            },
            error: function(xhr, status, error) {
                toastr.error('Failed to load modal content: ' + error);
            }
        });
    });

    <!--- AJAX form submission --->
    $(document).on('submit', '#updateForm', function(event) {
        event.preventDefault(); // Prevent default form submission

        <!--- Validate form using Parsley.js --->
        if ($(this).parsley().isValid()) {
            $.ajax({
                url: '/include/remoteUpdateCUpdate.cfm', // Server script to process data
                type: 'POST',
                data: $(this).serialize(), // Serialize form data
                success: function(response) {
                    <!--- Handle success - update the detail section --->
                    $('#detailText').text($('#valueText').val());
                    toastr.success('Details updated successfully');
                    $('#editModal').modal('hide');
                },
                error: function(xhr, status, error) {
                    <!--- Handle error - show an error message --->
                    toastr.error('Update failed: ' + error);
                }
            });
        }
    });
});
</script>

<script src="https://stackpath.bootstrapcdn.com/bootstrap/4.3.1/js/bootstrap.bundle.min.js"></script>

</body>
</html>
