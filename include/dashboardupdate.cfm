<!--- This ColdFusion page generates a form for updating visibility settings based on dashboard data. --->
<cfinclude template="/include/qry/dashboardzz_93_1.cfm" />

<form action="/include/dashboardupdate2.cfm" method="post" class="needs-validation" validate id="profile-form">
    <div class="row">

        <!--- Loop through the dashboard query to generate checkboxes for each item --->
        <cfloop query="dashboardzz">
            <!--- Check if the item is visible --->
            <cfif dashboardzz.isvisible eq 1>
                <cfoutput>
                    <div class="form-group col-md-6">
                        <div class="custom-control custom-checkbox">
                            <input type="checkbox" class="custom-control-input" id="newpnid_#dashboardzz.pnid#" checked value="#dashboardzz.pnid#" name="new_isvisible" />
                            <label class="custom-control-label" for="newpnid_#dashboardzz.pnid#">#dashboardzz.pnTitle#</label>
                        </div>
                    </div>
                </cfoutput>
            <cfelse>
                <cfoutput>
                    <div class="form-group col-md-6">
                        <div class="custom-control custom-checkbox">
                            <input type="checkbox" class="custom-control-input" id="newpnid_#dashboardzz.pnid#" value="#dashboardzz.pnid#" name="new_isvisible" />
                            <label class="custom-control-label" for="newpnid_#dashboardzz.pnid#">#dashboardzz.pnTitle#</label>
                        </div>
                    </div>
                </cfoutput>
            </cfif>
        </cfloop>

        <div class="form-group text-center col-md-12">
            <button class="btn btn-primary editable-submit btn-sm waves-effect waves-light" type="submit" style="background-color: #406e8e; border: ##406e8e;">Update</button>
        </div>

    </div>
</form>
