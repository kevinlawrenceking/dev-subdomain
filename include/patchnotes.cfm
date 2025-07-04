<!--- This ColdFusion page includes a query for notes and displays them in a list format. --->
<cfinclude template="/include/qry/notes_186_1.cfm" />

<div class="row">
    <div style="padding:15px;">
        <ul>
            <!--- Output each note from the query results --->
            <cfoutput query="notes">
                <li>#notes.patchnote#</li>
            </cfoutput>
        </ul>
    </div>
</div>
