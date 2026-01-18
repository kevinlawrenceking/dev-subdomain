<cfif #devicetype# is "mobilez">
<div class="card mb-3">

<div class="btn-group col-md-12">

  <button type="button" class="btn btn-primary btn-lg dropdown-toggle" data-bs-toggle="dropdown" aria-haspopup="true" aria-expanded="false">

    <Cfoutput>#pgname#</Cfoutput>
    <i class="fe-menu"></i>

  </button>
  <div class="dropdown-menu">

    <cfloop query="FindOptions">
      <cfoutput>
        <a class="dropdown-item" href="/app/#pgDir#/?new_pgid=#FindOptions.pgid#">#FindOptions.pgname#</a>
      </cfoutput>
    </cfloop>

  </div>
</div>
<!---   <cfif #pgid# is "122">
    <cfinclude template="/include/myteam_pane.cfm"/>
  </cfif>
  --->

<div class="card-body">

  <cfif #pgid# is "121">
    <cfinclude template="/include/mylinks_pane.cfm"/>
  </cfif>


  <cfif #pgid# is "124">
    <cfinclude template="/include/prefs_pane.cfm"/>
  </cfif>

  <cfif #pgid# is "125">
    <cfinclude template="/include/systemprefs_pane.cfm"/>
  </cfif>

</div>
</div>

</cfif>