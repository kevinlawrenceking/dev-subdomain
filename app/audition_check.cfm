<cfif #isAuditionModule# is not "1">
<h5>You do not have access to the auditionz module.</h5>
    
    <form>
 <input type="button" value="Go back!" onclick="history.back()" />
</form>
    <cfabort>

</cfif>
