<!--- Check if the user has access to the audition module --->
<cfif isauditionmodule eq 0>
  Reports are only available to users who have access to the events module.
  <cfabort>
</cfif>

<!--- Set default parameters --->
<cfset pgcol=3>
<cfparam name="focus_reportid" default="0"/>
<cfparam name="customstart" default="2022-01-01"/>
<cfparam name="customend" default="2100-12-31"/>
<cfparam name="bookratio" default="0"/>
<cfparam name="anchortag" default=""/>
<cfparam name="new_audsourceid" default="0"/>
<cfparam name="new_audsourceidb" default="0"/>
<cfparam name="refresh" default="y"/>

<!--- Refresh the page if needed --->
<cfif refresh eq "y">
  <cflocation url="/include/reportsrefresh.cfm?refresh=n">
</cfif>

<!--- Form for report generation --->
<form action="/include/reportsRefresh.cfm">
  <cfoutput>
    <input type="hidden" name="refresh" value="n"/>
    <input type="hidden" name="anchortag" value=""/>
    <input type="hidden" name="new_audcatid" value="#new_audcatid#"/>
    <input type="hidden" name="new_audsourceid" value="#new_audsourceid#"/>
    <input type="hidden" name="new_audsourceidb" value="#new_audsourceidb#"/>
    <input type="hidden" name="userid" value="#userid#"/>
    <input type="hidden" name="old_rangeid" value="#new_rangeid#"/>
  </cfoutput>
  <div class="row">
    <!--- Date Range Selector --->
    <div class="form-group col-md-2">
      <label for="eventStart">Date Range<span class="text-danger">*</span>
      </label>
  <select id="new_rangeid" name="new_rangeid" class="form-control" onchange="toggleDateDiv(this.value);">
    <cfoutput query="ranges">
      <option value="#ranges.rangeid#" <cfif ranges.rangeid eq new_rangeid>selected</cfif>>#ranges.rangename#</option>
    </cfoutput>
  </select>
    </div>

    <!--- Refresh Button --->
    <div class="form-group col-md-2 align-bottom">
      <br>
        <input type="submit" class="btn btn-primary waves-effect waves-light" value="Refresh" /></div>

        <Cfoutput>
  <!--- Hidden Date Range Div --->
  <div id="hidden_div" style="display: none;">
    <!--- Start Date --->
    <div id="hidden_divx" class="form-group col-md-2">
      <label for="customstart">Start Date</label>
      <input id="customstart" class="form-control" autocomplete="off" value="#customstart#" name="customstart" type="date"  />
    </div>

    <!--- End Date --->
    <div id="hidden_divsx" class="form-group col-md-2">
      <label for="customend">End Date</label>
      <input id="customend" class="form-control" autocomplete="off" value="#customend#" name="customend" type="date"  />
    </div>
  </div>
      </div>
        </cfoutput>
  
    </form>

    <div class="row">
      <!--- Loop through stats query to display statistics --->
      <cfoutput>
        <cfloop query="stats">

          <div class="col-md-#stats.colmd# col-lg">
            <div id="#stats.reportid#" class="widget-rounded-circle card">
              <div class="card-body text-center">
                <cfset bookratio=round(bookratio)>
                <h3 class="text-dark mt-1">
                  <span data-plugin="counterup">#statvalue#</span>
                  <cfif stats.reportid eq 13>(#int(bookratio)#%)</cfif>
                </h3>
                <p class="text-muted mb-1 text-truncate">#stats.reportname#</p>
              </div>
            </div>
          </div>

        </cfloop>

      </cfoutput>
    </div>

    <div class="row">

<cfloop query="reports">
        <cfinclude template="/include/qry/dataset_x_281_4.cfm" />

  <Cfoutput>
    <div id="anchor-#reports.reportid#" class="anchor-offset col-xl-#reports.colxl# col-md-#reports.colmd# col-lg">
      <a>
        <div class="card mb-3" id="#reports.reportid#" style="border: 1px solid ##e5e5e5; border-radius:3px;">
          <div class="card-body" dir="ltr">
            <h6 class="p-1 d-flex header-title">#reports.reportname#
              <span class="ms-auto">
              </cfoutput>
              <!--- Conditional forms based on report ID --->
              <cfif #reports.reportid# is "2" OR #reports.reportid# is "7" OR #reports.reportid# is "8">
                <form action="/app/reportsRefresh/">
                  <cfoutput>
                    <input type="hidden" name="anchortag" value="anchor-#reports.reportid#"/>
                    <input type="hidden" name="new_rangeid" value="#new_rangeid#"/>
                    <input type="hidden" name="new_audsourceid" value="#new_audsourceid#"/>
                    <input type="hidden" name="customstart" value="#customstart#"/>
                    <input type="hidden" name="customend" value="#customend#"/>
                    <input type="hidden" name="userid" value="#userid#"/>
                  </cfoutput>
                  <select name="new_audcatid" onchange="this.form.submit();">
                    <cfoutput query="categories">
                      <option value="#categories.audcatid#" <cfif #categories.audcatid# is "#new_audcatid#">selected</cfif>>#categories.audcatname#</option>
                    </cfoutput>
                  </select>
                </form>
              </cfif>
            </span>
          </h6>
          <Cfoutput>
            <!--- Check if data is available --->
            <cfif dataset_x.recordCount GT 0>
              <canvas id="myChart_#reports.reportid#"></canvas>
            <cfelse>
              <!--- No data available message --->
              <div style="text-align: center; color: grey; font-size: 16px; height: 100px; display: flex; align-items: center; justify-content: center;">
                No data available
              </div>
            </cfif>
          </cfoutput>
        </div>
      </div>
    </a>
  </div>
</cfloop>

</div>

<cfloop query="reports">

 <cfif ListFindNoCase("3,4,6,5,7,8,9,2,4,18", reports.reportid)>

                 <cfinclude template="/include/qry/reportitems_x_281_3.cfm" />
            <cfinclude template="/include/qry/dataset_x_281_4.cfm" />
            <cfinclude template="/include/qry/labels_x_281_5.cfm" />
        <cfset k = 0 />

        <!--- Generate dataset content --->
<cfsavecontent variable="dataset_data">
    <cfloop query="dataset_x">
        <!--- Include necessary query values --->
        <cfinclude template="/include/qry/values_x_281_6.cfm" />
        
        <!--- Generate the item values as a list --->
        <cfoutput>
            <cfset itemvalues = ValueList(values_x.itemValueInt, ',')>
        </cfoutput>

        <!--- Background color logic based on `k` --->
        <cfset k = k + 1 />
        <cfif k EQ 1 OR k EQ 3>
            <cfset bgcolor = "'##406E8E'">
        <cfelse>
            <cfset bgcolor = "'##1ABC9C'">
        </cfif>

        <!--- Handle commas between datasets --->
        <cfif k GT 1>,</cfif>
        
        <!--- Generate dataset output with safe labels --->
        <cfoutput>
        <cfset safelabel = REReplace(dataset_x.itemdataset, "'", "", "all") />
        <cfset safelabel = REReplace(safelabel, "''", "", "all") />
            {
                label: "#safelabel#",
                data: [#itemvalues#]
                <cfif reports.reporttypename NEQ "bar">
                    ,backgroundColor: [#reports.colorscheme#]
                <cfelse>
                    ,backgroundColor: [#bgcolor#]
                </cfif>
            }
        </cfoutput>
    </cfloop>
</cfsavecontent>




        <!--- Prepare data for the chart --->
        <cfscript>
            reportlabels = QuotedValueList(labels_x.itemLabel, ",");
            reportvalues = QuotedValueList(reportitems_x.itemValueInt, ",");
        </cfscript>

        <cfoutput>
            <cfset reportvalues = "#reportvalues#">
            <cfset reportlabels = "#reportlabels#">

 

    <cfset safeReportLabels = reportlabels>
    <cfset safeDatasetData = dataset_data>
    <cfset scalesConfig = "" />
    
    <cfif reports.reportid EQ 4>
        <cfset scalesConfig = "{ x: { stacked: true }, y: { stacked: true } }">
    </cfif>
    <cfif reports.reportid EQ 9>
        <cfset scalesConfig = "{ x: { stacked: true }, y: { stacked: true, ticks: { precision: 0 } } }">
    </cfif>

    <script>
        const chart_#reports.reportid# = document.getElementById('myChart_#reports.reportid#');
        new Chart(chart_#reports.reportid#, {
            type: '#reports.reporttypename#',
            data: {
                labels: [#safeReportLabels#],
                datasets: [#safeDatasetData#]
            },
            options: {
                responsive: true
                <cfif Len(scalesConfig) GT 0>, scales: #scalesConfig#</cfif>
            }
        });
    </script>
</cfoutput>
    </cfif>

</cfloop>








<script>
  function toggleDateDiv(selectedValue) {
    const customDiv = document.getElementById("hidden_div");
    if (selectedValue === "7") { // Assuming "y" is the value for "Custom"
      customDiv.style.display = "block";
      document.getElementById("customstart").required = true;
      document.getElementById("customend").required = true;
    } else {
      customDiv.style.display = "none";
      document.getElementById("customstart").required = false;
      document.getElementById("customend").required = false;
    }
  }

  // On page load, ensure the div is hidden unless the value is "Custom"
  document.addEventListener("DOMContentLoaded", function() {
    const selectElement = document.getElementById("new_rangeid");
    toggleDateDiv(selectElement.value);
  });
</script>