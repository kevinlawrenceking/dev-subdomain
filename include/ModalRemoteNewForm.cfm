<!--- This ColdFusion page includes a modal for adding a new form with a title from a query. --->

<cfinclude template="/include/qry/FindModalTitle_107_3.cfm" />

<div id="remoteNewForm" class="modal fade" tabindex="-1" role="dialog" aria-labelledby="standard-modalLabel" >

    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header" >
                <h4 class="modal-title" id="standard-modalLabel">
                    <cfoutput>#FindModalTitle.compname#</cfoutput> Add Form
                </h4>
                <button type="button" class="close" data-bs-dismiss="modal" >
x</button>
            </div>
            <div class="modal-body">
                
            </div>
        </div>
        <!--- /.modal-content --->
    </div>
    <!--- /.modal-dialog --->
</div>

