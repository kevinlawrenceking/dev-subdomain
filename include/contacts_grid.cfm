
<cfset defrows = defrows />
<cfparam name="card_image" default="test.jpg">

<div class="view-toggle d-flex mb-3">
    <button id="toggle-table" class="btn btn-primary me-2">
        <i class="mdi mdi-menu fa-1x"></i>
    </button>
    <button id="toggle-gallery" class="btn btn-secondary">
        <i class="mdi mdi-drag fa-1x"></i>
    </button>
</div>

<!-- DataTable View -->
<div id="<cfoutput>#contacts_table#_container</cfoutput>">
    <table id="<cfoutput>#contacts_table#</cfoutput>" class="table table-striped">
        <thead>
            <tr>
                <th>Name</th>
                <th>Title</th>
                <th>Company</th>
                <th>Email</th>
                <th>Phone</th>
            </tr>
        </thead>
    </table>
</div>

<!-- Gallery View -->
<div id="contacts-gallery-container" class="container-fluid d-none">
    <div class="row row-cols-1 row-cols-sm-2 row-cols-md-3 row-cols-lg-4 g-3" id="contacts-gallery">
        <!--- Cards will be dynamically inserted here --->
    </div>
</div>









