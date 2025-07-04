<!--- This ColdFusion page displays billing information including invoice ID, purchase date, trial end date, product, and plan details. --->

<h4 class="text-nowrap">
    My Billing
</h4>
<div class="row" style="margin: auto;">
    
    <!--- Output billing information --->
    <cfoutput>
        
        <div class="col-md-12 col-lg-6 p-1">
            <strong>Invoice ID: </strong>#invoiceid#
        </div>
        
        <div class="col-md-12 col-lg-6 p-1">
            <strong>Purchase Date: </strong>#this.formatDate(purchasedate)#
        </div>
        
        <!--- Check if trial end date is available --->
        <cfif #trialenddate# is not "">
            <div class="col-md-12 col-lg-6 p-1">
                <strong>Trial End Date: </strong>#this.formatDate(trialenddate)#
            </div>
        </cfif>
        
        <div class="col-md-12 col-lg-6 p-1">
            <strong>Product: </strong>#baseproductlabel#
        </div>
        
        <div class="col-md-12 col-lg-6 p-1">
            <strong>Plan: </strong>#planname#
        </div>
        
    </cfoutput>
    
    <div class="col-md-12 col-lg-6 p-1">
        <strong>Have questions and want to cancel? </strong> 
        <a href="mailto:support@theactorsoffice.com">Email</A> us
    </div>
    
</div>