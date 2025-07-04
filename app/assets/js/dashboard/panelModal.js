$(document).ready(function() {
    $("#paneladd").on("show.bs.modal", function(event) {
        // Load panel content dynamically
        $(this).find(".modal-body").load("/include/remotePanelAdd.cfm?userid=" + userid + "&pgrtn=Z");
    });
});
