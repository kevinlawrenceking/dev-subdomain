<!--- Audition Unions sub-pane: per-user country preferences for the
      audition union dropdown. Extracted from prefs_pane.cfm as part of
      the My Account tab consolidation. Header renamed from
      "Audition Union Countries" to "Unions" since the parent context
      is now the Audition tab. --->
<cfinclude template="/include/qry/audunion_countries_sel.cfm" />

<div class="preferences-section">
    <div class="section-header">
        <h5 class="section-title">
            <i class="mdi mdi-flag-variant me-2"></i>Unions
        </h5>
        <button class="btn btn-outline-primary btn-sm edit-settings-btn"
                title="Choose which countries' unions appear in your audition dropdowns"
                data-bs-toggle="modal"
                data-bs-target="#updatePrefCountries">
            <i class="mdi mdi-square-edit-outline"></i>
        </button>
    </div>

    <div class="settings-grid">
        <div class="setting-item">
            <div class="setting-label">
                <i class="mdi mdi-earth me-2 text-muted"></i>
                <strong>Selected Countries</strong>
            </div>
            <div class="setting-value">
                <cfoutput>
                    <a href="" title="Update your union countries"
                       data-bs-toggle="modal" data-bs-target="##updatePrefCountries"
                       class="setting-link">
                        <cfset prefCountryNames = "" />
                        <cfloop query="audunion_countries_sel">
                            <cfif listFindNoCase(prefCountryIDList, audunion_countries_sel.countryid)>
                                <cfset prefCountryNames = listAppend(prefCountryNames, audunion_countries_sel.countryname, ", ") />
                            </cfif>
                        </cfloop>
                        <cfif len(prefCountryNames)>
                            #prefCountryNames#
                        <cfelse>
                            <span class="text-muted">None selected</span>
                        </cfif>
                    </a>
                </cfoutput>
            </div>
        </div>
    </div>
</div>

<!--- Edit modal for union country preferences --->
<div id="updatePrefCountries" class="modal fade" tabindex="-1" role="dialog" aria-labelledby="updatePrefCountriesLabel">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <h4 class="modal-title" id="updatePrefCountriesLabel">Unions</h4>
                <button type="button" class="close" data-bs-dismiss="modal">
                    <i class="mdi mdi-close-thick"></i>
                </button>
            </div>
            <div class="modal-body">
                <p class="text-muted">Check the countries whose unions you want to see in your audition project dropdowns.</p>

                <form action="/app/myaccount/update_pref_countries.cfm" method="post" id="prefCountriesForm">
                    <div class="row">
                        <cfoutput query="audunion_countries_sel">
                            <div class="col-md-6">
                                <div class="form-check mb-2">
                                    <input class="form-check-input" type="checkbox"
                                           name="pref_countries"
                                           id="pref_country_#audunion_countries_sel.countryid#"
                                           value="#audunion_countries_sel.countryid#"
                                           <cfif listFindNoCase(prefCountryIDList, audunion_countries_sel.countryid)>checked</cfif> />
                                    <label class="form-check-label" for="pref_country_#audunion_countries_sel.countryid#">
                                        #audunion_countries_sel.countryname# <span class="text-muted small">(#audunion_countries_sel.countryid#)</span>
                                    </label>
                                </div>
                            </div>
                        </cfoutput>
                    </div>

                    <div class="form-group text-center col-md-12 mt-3">
                        <button class="btn btn-primary editable-submit btn-sm waves-effect waves-light" type="submit"
                                style="background-color: ##406e8e; border: ##406e8e;">Update</button>
                    </div>
                </form>
            </div>
        </div>
    </div>
</div>
