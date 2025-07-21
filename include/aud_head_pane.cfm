<!--- This ColdFusion page handles the display and management of media headshots, including modals for selection and deletion. --->

<cfinclude template="/include/qry/audmedia.cfm" />
<cfinclude template="/include/qry/types_44_1.cfm" />
<cfinclude template="/include/qry/audlinks_44_2.cfm" />

<div id="remoteselectheadshot" class="modal fade" tabindex="-1" aria-labelledby="headshotModalLabel">
    <div class="modal-dialog modal-lg"> <!--- Large modal for better viewing --->
        <div class="modal-content">
            <div class="modal-header">
                <h4 class="modal-title" id="headshotModalLabel">Select a Headshot</h4>
                <button type="button" class="close" data-bs-dismiss="modal">
                    <i class="mdi mdi-close-thick"></i>
                </button>
            </div>
            <div class="modal-body">
                <!--- Content will be loaded dynamically --->
                <div id="headshotGalleryContainer">
                    <p class="text-center">Loading headshots...</p>
                </div>
            </div>
        </div>
    </div>
</div>



<cfset modalid="remoteselectmaterial" />
<cfset modaltitle="Select Material" />
<cfinclude template="/include/modal.cfm" />

<cfoutput>

<script>
        $(document).ready(function() {
            $("##remoteadd").on("show.bs.modal", function(event) {
                <!--- Load media addition modal content --->
                $(this).find(".modal-body").load("/include/remotaudmatadd.cfm?eventid=#eventid#&audprojectid=#audprojectid#&secid=196");
            });
        });
    </script>


    <div id="remoteadd" class="modal fade" tabindex="-1" aria-labelledby="standard-modalLabel" >

        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header" >
                    <h4 class="modal-title" id="standard-modalLabel">Upload Media</h4>
                    <button type="button" class="close" data-bs-dismiss="modal" >
<i class="mdi mdi-close-thick"></i></button>
                </div>
                <div class="modal-body">
                </div>
            </div>
        </div>
    </div>
 

<cfset i=0 />
    <h4 class="p-1 d-flex">My Headshots

    </h4>
 
    <div class="col-md-12 col-lg-12 col-xl-12 p-1 d-flex">
        <center>
 
    <a data-bs-remote="true" 
       data-bs-toggle="modal" 
       data-bs-target="##remoteselectheadshot" 
       data-audprojectid="#audprojectid#"
       data-bs-placement="top" 
       title="Select Headshots" 
       data-bs-original-title="Add media" 
       class="btn btn-xs btn-primary waves-effect waves-light"
       data-audprojectid="#audprojectid#">
        My Headshots
    </a>
</cfoutput>
        </center>

 




  <div class="container">
    <!--- Start of card grid container --->
    <div class="row row-cols-2 row-cols-sm-2 row-cols-md-2 row-cols-lg-3 row-cols-xl-4 g-3">
      <!--- Loop through the myteam query --->


    <cfloop query="headshots">

     <cfset card_image=session.userMediaUrl & "/" & headshots.mediaFileName/>
        <cfset card_name=headshots.medianame/>

        <cfset currentid=headshots.mediaid/>

        <cfoutput>
          <script>
            $(document).ready(function () {
              $("##remoteDeleteaudmedia#currentid#").on("show.bs.modal", function (event) {
                <!--- Load the HTML for deleting a headshot into the modal body --->

                $(this)
                  .find(".modal-body")
                  .load("/include/remoteDeleteheadshots_auditions_xref.cfm?mediaid=#currentid#&secid=196&audprojectid=#audprojectid#");
              });
            });
          </script>

          <div id="remoteDeleteaudmedia#currentid#" class="modal fade" tabindex="-1" role="dialog">

            <div class="modal-dialog">
              <div class="modal-content">
                <div class="modal-header" style="background-color: red;">
                  <h4 class="modal-title">Delete Headshot</h4>
                  <button type="button" class="close" data-bs-dismiss="modal">
                    <i class="mdi mdi-close-thick"></i>
                  </button>
                </div>
                <div class="modal-body"></div>
              </div>
            </div>
          </div>
        </cfoutput>

        <cfinclude template="/include/card_photo.cfm"/>

      </cfloop>


</div>


 </div>
  </div>


<script>
$(document).ready(function() {
    // Load headshot gallery when the modal opens
    $("a[data-bs-target='#remoteselectheadshot']").click(function() {
        var audprojectid = $(this).data("audprojectid");  
        $("#headshotGalleryContainer").html('<p class="text-center">Loading headshots...</p>');  
        $("#headshotGalleryContainer").load("/include/load_headshot_gallery.cfm?audprojectid=" + audprojectid);
    });

    // Handle headshot selection click
    $(document).on("click", ".select-headshot", function() {
        var mediaid = $(this).data("mediaid");
        var audprojectid = $(this).data("audprojectid");
        updateSelectedHeadshot(mediaid, audprojectid);
    });
});

function updateSelectedHeadshot(mediaid, audprojectid) {
    console.log("Updating headshot for:", mediaid, audprojectid);

    $.post("/include/update_selected_headshot.cfm", 
        { mediaid: mediaid, audprojectid: audprojectid }, 
        function(response) {
            console.log("Response received:", response);
            let jsonResponse = JSON.parse(response);

            if (jsonResponse.status === "success") {
                alert(jsonResponse.message);

                // Refresh the page to show the newly added headshot
                window.location.href = "/app/audition/?audprojectid=" + audprojectid + "&secid=196";
            } else {
                alert("Error: " + jsonResponse.message);
            }
        }
    ).fail(function(jqXHR, textStatus, errorThrown) {
        console.error("AJAX error:", textStatus, errorThrown);
        alert("Error updating headshot. Check console.");
    });
}


// Function to reload headshot gallery after update
function reloadHeadshotGallery(audprojectid) {
    console.log("Reloading headshot gallery for audprojectid:", audprojectid);
    
    // Append a timestamp to bypass caching
    $.get("/include/load_headshot_gallery.cfm", 
        { audprojectid: audprojectid, t: new Date().getTime() }, 
        function(response) {
            $("#headshotGalleryContainer").html(response);
        }
    ).fail(function(jqXHR, textStatus, errorThrown) {
        console.error("AJAX error:", textStatus, errorThrown);
        alert("Error loading updated headshot gallery.");
    });
}

</script>


<link href="https://cdnjs.cloudflare.com/ajax/libs/lightbox2/2.11.3/css/lightbox.min.css" rel="stylesheet">
  <script src="https://cdnjs.cloudflare.com/ajax/libs/lightbox2/2.11.3/js/lightbox.min.js"></script>
