<cfoutput>
    <div class="tao-card-photo">
       
 <!-- TRASH ICON (top-left) -->
        <div class="tao-card-photo-header">
            <i class="mdi mdi-trash-can-outline" 
               style="color:red;" 
               data-bs-toggle="modal" 
               data-bs-target="##remoteDeleteaudmedia#currentid#">
            </i>
        </div>

        <!-- DOWNLOAD ICON (top-right) -->
        <div class="tao-card-photo-header header-right" 
             >
            <a href="/include/download_media.cfm?mediaid=#currentid#"
               style="color: inherit;">
                <i class="mdi mdi-cloud-download-outline"></i>
            </a>
        </div>

        <!-- Card Body: Image + Overlay -->
        <div class="tao-card-photo-body">
            <img src="#card_image#" alt="#card_name#">
            
            <!-- Magnifying Glass Icon (Opens Lightbox) -->
            <div class="image-overlay">
                <a href="#card_image#" data-lightbox="headshots" data-title="#card_name#">
                    <i class="mdi mdi-magnify"></i>
                </a>
            </div>
        </div>

        <!-- Footer with Editable Name & Edit Icon -->
        <div class="tao-card-photo-footer">
            <div class="photo-name" data-id="#currentid#">#card_name#</div>
            <i class="mdi mdi-square-edit-outline edit-icon" title="Edit Name" style="color:##1d80c2;"></i>
        </div>
    </div>
</cfoutput>


<!-- AJAX Script -->
<script>
document.addEventListener("DOMContentLoaded", function () {
    document.body.addEventListener("click", function (event) {
        if (event.target.classList.contains("edit-icon")) {
            let element = event.target.previousElementSibling; // Target the name div
            let icon = event.target; // Store the edit icon reference

            if (!element || element.querySelector("input")) return; // Prevent multiple inputs

            let mediaId = element.getAttribute("data-id");
            let lastValidText = element.innerText.trim(); // Store the last valid name
            let input = document.createElement("input");
            input.type = "text";
            input.value = lastValidText;
            input.classList.add("edit-input");

            element.innerHTML = ""; // Clear existing content
            element.appendChild(input);
            icon.style.visibility = "hidden"; // Hide the edit icon
            input.focus();

            // Handle save on Enter key
            input.addEventListener("keypress", function (e) {
                if (e.key === "Enter") {
                    let newText = input.value.trim();
                    if (newText) {
                        element.innerText = newText; // Update UI immediately
                        icon.style.visibility = "visible"; // Show the icon again

                        fetch("/include/update_media_name.cfm", {
                            method: "POST",
                            headers: { "Content-Type": "application/x-www-form-urlencoded" },
                            body: `mediaid=${mediaId}&medianame=${encodeURIComponent(newText)}`
                        })
                        .catch(error => console.error("Update failed:", error)); // Log errors but don't revert UI
                    } else {
                        element.innerText = lastValidText; // Restore last valid name if empty
                        icon.style.visibility = "visible"; // Show the icon again
                    }
                }
            });

            // If user clicks away without entering a valid name, restore last valid name
            input.addEventListener("blur", function () {
                let newText = input.value.trim();
                element.innerText = newText || lastValidText; // Keep last valid name if empty
                icon.style.visibility = "visible"; // Show the icon again
            });
        }
    });
});

</script>

<style>
.photo-name {
    cursor: default;
    display: inline-block;
    font-weight: bold;
    margin-right: 8px;
}
.edit-input {
    width: 100%; /* Ensures it fills the div properly */
    font-size: inherit;
    padding: 3px;
    border: 1px solid #6c757d; /* Ensures all borders are visible */
    border-radius: 3px;
    box-sizing: border-box; /* Prevents border from shifting layout */
}

.edit-icon {
    cursor: pointer;
    font-size: 16px;
    transition: 0.2s;
    visibility: visible; /* Default visibility */
}

.edit-icon:hover {
    color: #0056b3;
}

</style>
