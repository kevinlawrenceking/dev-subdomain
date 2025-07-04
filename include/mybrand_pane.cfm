<!--- This ColdFusion page displays a modal for branding essences and allows users to add or update their essences. --->

<div id="essencehelp" class="modal fade" tabindex="-1" aria-labelledby="standard-modalLabel" >

    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header" >
                <h4 class="modal-title" id="standard-modalLabel">Essences</h4>
                <button type="button" class="close" data-bs-dismiss="modal" >

                    <i class="mdi mdi-close-thick"></i>
                </button>
            </div>

            <div class="modal-body">
                <p>
                    Branding is the identification and articulation of your unique, 3-dimensional essence. It is the key to getting your foot in the door and being remembered.
                </p>
                <p>
                    Being able to track your events through the lens of your brand essences will give you vital data on how you're perceived, what you do best, and your niche. I recommend using 3-5 brand essences here.
                </p>
                <p>Examples:<br>
                    <ul>
                        <li>Wealthy and manipulative narcissistic milf</li>
                        <li>Ambitious, strong truth seeker</li>
                        <li>Neurotic and Type-A mom who means well</li>
                        <li>Sensitive voice of reason everyone loves</li>
                    </ul>
                </p>
                <p>
                    If you need support in identifying your brand and your essences, check out 
                    <a href="https://www.theactorsbrandingsystem.com/" target="new">The Actor's Branding System</a>.
                </p>
            </div>
        </div>
    </div>
</div>

<script>
    $(document).ready(function() {
        // Show modal and load content for adding essence
        $("#remoteAddEssenceContact").on("show.bs.modal", function(event) {
            $(this).find(".modal-body").load("<cfoutput>/include/remoteAddEssenceContact.cfm?userid=#userid#&src=account</cfoutput>");
        });
    });
</script>

<cfset modalid="remoteAddEssenceContact" />
<cfset modaltitle="Add Essence" />
<cfinclude template="/include/modal.cfm" />
<cfinclude template="/include/qry/essence_sel_470_1.cfm" />

<h4>My Essence
    <a href="" title="click for details" data-bs-toggle="modal" data-bs-target="#essencehelp">
        <i class="fe-info font-14 mr-1"></i>
    </a>
</h4>

<p>
    Add an 
    <a href="remoteAddContact.cfm?src=account" data-bs-remote="true" data-bs-toggle="modal" data-bs-target="#remoteAddEssenceContact">
        <strong>Essence</strong>
    </a> or click to edit.
</p>

<div class="container mt-3">
    <div class="row row-cols-lg-2 row-cols-xl-3 row-cols-md-2 row-cols-sm-1 g-3">
        <cfloop query="essence_sel">
<Cfoutput>
                            <script>
                        $(document).ready(function() {
                            // Show modal and load content for updating essence
                            $("##remoteUpdateEssenceContact_#essence_sel.id#").on("show.bs.modal", function(event) {
                                $(this).find(".modal-body").load("/include/remoteUpdateEssenceContact.cfm?userid=#userid#&src=account&essenceid=#essence_sel.id#");
                            });
                        });
                    </script>

                    <cfset modalid="remoteUpdateEssenceContact_#essence_sel.id#" />
                    <cfset modaltitle="Update Essence" />
                    <cfinclude template="/include/modal.cfm" />
                    </cfoutput>


            <div class="col">
               <cfoutput>
    <div class="col">
        <a href="" data-bs-toggle="modal" data-bs-target="##remoteUpdateEssenceContact_#essence_sel.id#">
            <div class="tao-card-small shadow-sm border rounded">
                <div class="card-body text-center">
                    <h5 class="card-title essence-text">#Essence_sel.Name#</h5>
                </div>
            </div>
        </a>
    </div>
</cfoutput>


                </a>

            </div>



            
        </cfloop>
    </div>
</div>


<script>
    function deleteEssence(id) {
        if(confirm("Are you sure you want to delete this essence?")) {
            window.location.href = "/app/myaccount/?ctaction=deleteessence&essenceid=" + id;
        }
    }
</script>

<script>
document.addEventListener("DOMContentLoaded", function () {
    document.querySelectorAll(".tao-card-small .essence-text").forEach(textElement => {
        let textLength = textElement.innerText.trim().length;
        let lengthCategory = Math.min(textLength, 20); // Cap at 20 to avoid tiny text

        // Adjust font size but allow wrapping
        let newFontSize = Math.max(18 - (lengthCategory * 0.6), 12); // Ensures minimum font size of 12px
        textElement.style.fontSize = newFontSize + "px";
    });
});
</script>