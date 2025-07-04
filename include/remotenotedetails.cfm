<!--- This ColdFusion page includes a details query and outputs the noted details HTML. --->

<script>
document.addEventListener("DOMContentLoaded", function() {
  const hiddenDiv = document.querySelector(".ql-tooltip.ql-hidden");
  if (hiddenDiv) {
    hiddenDiv.style.display = "none";
  }
});
</script>

<cfinclude template="/include/qry/notes_21_1.cfm" />   

<!--- Output the noted details HTML from the query results. --->
<cfoutput>
    #notes.notedetailshtml#
</cfoutput>

