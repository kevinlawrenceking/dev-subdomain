<!--- This ColdFusion page displays a card with a quote of the day. --->
<cfset quotesService = createObject("component", "services.QuotesService")>
<cfset quoteOfTheDay = quotesService.getQuoteOfTheDay()>

<cfoutput>
    <div class="card grid-item loaded" data-id="#dashboards.pnid#">
        <div class="card-header" id="heading_system_#dashboards.currentrow#">
            <h5 class="m-0">
                <a class="text-dark collapsed" data-bs-toggle="collapse" href="##collapse_system_#dashboards.currentrow#">
                    #dashboards.pnTitle#
                </a>
            </h5>
        </div>
</cfoutput>

    <div class="card-body">
        <div class="row">
            <div class="col-md-12 col-lg-12">&nbsp;</div>
            
            <cfoutput>
                <div class="col-md-12 col-lg-12" style="text-align:center;">
                    <h5>"#quoteOfTheDay.quotename#"</h5>
                    <br>
                    <h6>-#quoteOfTheDay.quoteauthor#</h6>
                </div>
            </cfoutput>
        </div>
    </div>
</div>
