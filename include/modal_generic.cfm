<!---
    PURPOSE: Generic Bootstrap Modal Structure
    AUTHOR: GitHub Copilot / Kevin King
    DATE: 2025-07-26
    PARAMETERS: modalid, modaltitle (expected to be set in the calling template)
    DEPENDENCIES: Bootstrap 4/5 CSS/JS
--->
<div class="modal fade" id="#modalid#" tabindex="-1" aria-labelledby="#modalid#Label" aria-hidden="true">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title" id="#modalid#Label">#modaltitle#</h5>
                <button type="button" class="close" data-bs-dismiss="modal" aria-label="Close">
                     <i class="mdi mdi-close-thick"></i>
                </button>
            </div>
            <div class="modal-body">
                <!-- Content will be loaded here via JavaScript -->
                <div class="text-center p-4">
                    <div class="spinner-border" role="status">
                        <span class="visually-hidden">Loading...</span>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>
