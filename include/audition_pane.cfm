<!--- Audition tab content. Five sub-pills consolidate the previous
      top-level Essence, Headshots, Materials tabs with the moved
      Submission Sites and Unions cards from the Preferences tab.
      auditionSubpill is set by include/tab_check_account.cfm and is
      one of: essence | headshots | materials | submitsites | unions.
      Any other value is treated as essence by the cfif chain below. --->

<!--- Give the sub-pills a defined chip look (white fill, light grey
      border) so inactive tabs no longer read as floating text. The
      active pill keeps the theme green from --ct-component-active-bg. --->
<style>
#audition-subnav .nav-link {
    background-color: #fff;
    border: 1px solid #dee2e6;
    color: #6c757d;
    margin: 0 5px;
}
#audition-subnav .nav-item:first-child .nav-link {
    margin-left: 0;
}
#audition-subnav .nav-link:hover {
    background-color: #f8f9fa;
    border-color: #ced4da;
}
#audition-subnav .nav-link.active,
#audition-subnav .show > .nav-link {
    background-color: var(--ct-component-active-bg);
    border-color: var(--ct-component-active-bg);
    color: var(--ct-component-active-color);
}
</style>

<ul class="nav nav-pills mb-3" id="audition-subnav" role="tablist">
    <li class="nav-item" role="presentation">
        <a class="nav-link<cfif auditionSubpill eq 'essence'> active</cfif>"
           id="audition-essence-tab"
           href="#audition-essence"
           data-bs-toggle="pill"
           role="tab"
           aria-controls="audition-essence"
           aria-selected="<cfif auditionSubpill eq 'essence'>true<cfelse>false</cfif>">
            Essence
        </a>
    </li>
    <li class="nav-item" role="presentation">
        <a class="nav-link<cfif auditionSubpill eq 'headshots'> active</cfif>"
           id="audition-headshots-tab"
           href="#audition-headshots"
           data-bs-toggle="pill"
           role="tab"
           aria-controls="audition-headshots"
           aria-selected="<cfif auditionSubpill eq 'headshots'>true<cfelse>false</cfif>">
            Headshots
        </a>
    </li>
    <li class="nav-item" role="presentation">
        <a class="nav-link<cfif auditionSubpill eq 'materials'> active</cfif>"
           id="audition-materials-tab"
           href="#audition-materials"
           data-bs-toggle="pill"
           role="tab"
           aria-controls="audition-materials"
           aria-selected="<cfif auditionSubpill eq 'materials'>true<cfelse>false</cfif>">
            Materials
        </a>
    </li>
    <li class="nav-item" role="presentation">
        <a class="nav-link<cfif auditionSubpill eq 'submitsites'> active</cfif>"
           id="audition-submitsites-tab"
           href="#audition-submitsites"
           data-bs-toggle="pill"
           role="tab"
           aria-controls="audition-submitsites"
           aria-selected="<cfif auditionSubpill eq 'submitsites'>true<cfelse>false</cfif>">
            Submission Sites
        </a>
    </li>
    <li class="nav-item" role="presentation">
        <a class="nav-link<cfif auditionSubpill eq 'unions'> active</cfif>"
           id="audition-unions-tab"
           href="#audition-unions"
           data-bs-toggle="pill"
           role="tab"
           aria-controls="audition-unions"
           aria-selected="<cfif auditionSubpill eq 'unions'>true<cfelse>false</cfif>">
            Unions
        </a>
    </li>
</ul>

<div class="tab-content" id="audition-subcontent">
    <div class="tab-pane fade<cfif auditionSubpill eq 'essence'> show active</cfif>"
         id="audition-essence"
         role="tabpanel"
         aria-labelledby="audition-essence-tab">
        <cfinclude template="/include/mybrand_pane.cfm" />
    </div>
    <div class="tab-pane fade<cfif auditionSubpill eq 'headshots'> show active</cfif>"
         id="audition-headshots"
         role="tabpanel"
         aria-labelledby="audition-headshots-tab">
        <cfinclude template="/include/myheadshots_pane.cfm" />
    </div>
    <div class="tab-pane fade<cfif auditionSubpill eq 'materials'> show active</cfif>"
         id="audition-materials"
         role="tabpanel"
         aria-labelledby="audition-materials-tab">
        <cfinclude template="/include/mymaterials_pane.cfm" />
    </div>
    <div class="tab-pane fade<cfif auditionSubpill eq 'submitsites'> show active</cfif>"
         id="audition-submitsites"
         role="tabpanel"
         aria-labelledby="audition-submitsites-tab">
        <cfinclude template="/include/aud_submitsites_pane.cfm" />
    </div>
    <div class="tab-pane fade<cfif auditionSubpill eq 'unions'> show active</cfif>"
         id="audition-unions"
         role="tabpanel"
         aria-labelledby="audition-unions-tab">
        <cfinclude template="/include/aud_unions_pane.cfm" />
    </div>
</div>
