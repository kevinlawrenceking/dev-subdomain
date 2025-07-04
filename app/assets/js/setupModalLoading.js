// Reusable modal loading function
function setupModalLoading(modalId, loadUrlBase, queryParams) {
    $("#" + modalId).on("show.bs.modal", function (event) {
      var $modal = $(this);
      var cacheBuster = new Date().getTime(); // Prevent caching
      var loadUrl = loadUrlBase + "?" + queryParams + "&_=" + cacheBuster;
  
      // Show a loading indicator while content is loading
      $modal.find(".modal-body").html("<p>Loading...</p>");
  
      // Load the content
      $modal.find(".modal-body").load(loadUrl, function (response, status, xhr) {
        if (status === "error") {
          // Handle error case: display an error message
          $modal.find(".modal-body").html("<p>Error loading content. Please try again.</p>");
        } else {
          // Optionally, focus on the modal or perform additional actions after loading
          $modal.find(".modal-body").focus();
        }
      });
    });
  }
  