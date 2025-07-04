<!--- This ColdFusion page generates a modal dialog for displaying content dynamically. --->

<cfoutput>
    
    <div id="#modalid#" class="modal" tabindex="-1" role="dialog" aria-labelledby="standard-modalLabel" aria-bs-hidden="true">
        
        <div class="modal-dialog modal-lg">
            
            <div class="modal-content">
                
                <div class="modal-header">
                    
                    <h4 class="modal-title" id="standard-modalLabel">#modaltitle#</h4>
                    
                    <button type="button" class="close" data-bs-dismiss="modal" >

                        <i class="mdi mdi-close-thick"></i>
                    </button>
                    
                </div>
                
                <div class="modal-body">
                    
                </div>
                
            </div>
            
        </div>
        
    </div>
    
</cfoutput>

<!--- End of modal-fullscreen --->
