<!--- This ColdFusion page allows users to select a new system type for their contacts based on their relationship status. --->
<cfinclude template="/include/qry/reldetails_271_1.cfm" />        

<!--- Check if the suid is not "0" --->
<cfif #suid# is not "0">
    
    <!--- Set old_systemtype from reldetails --->
    <cfset old_systemtype = reldetails.systemtype />
    
<cfelse>
    
    <!--- Default old_systemtype to "None" --->
    <cfset old_systemtype = "None" />
</cfif>

<p>
    <form action="/include/systemchange.cfm"> 
        
        <cfoutput>
            <input type="hidden" name="suid" value="#suid#" />
            <input type="hidden" name="contactid" value="#contactid#" />
        </cfoutput>
        
        <center>
            <div class="radio radio-info form-check-inline">
                <input type="radio" id="N" value="None" name="new_systemtype" <cfif #old_systemtype# is "None" >
checked="checked" </cfif>>
                <label for="N"> None </label>
            </div>
            
            <div class="radio form-check-inline">
                <input type="radio" id="T" value="Targeted List" name="new_systemtype" <cfif #old_systemtype# is "Targeted List" >
checked="checked" </cfif>>
                <label for="T"> Targeted List </label>
            </div>
            
            <div class="radio form-check-inline">
                <input type="radio" id="F" value="Follow Up" name="new_systemtype" <cfif #old_systemtype# is "Follow Up" >
checked="checked" </cfif>>
                <label for="F"> Follow Up </label>
            </div>
            
            <div class="radio form-check-inline">
                <input type="radio" id="M" value="Maintenance List" name="new_systemtype" <cfif #old_systemtype# is "Maintenance List" >
checked="checked" </cfif>>
                <label for="M"> Maintenance List </label>
            </div>
        </center>
        
        <p>&nbsp;</p>
        <div>
            <center>
                <input name="submit" type="submit" value="Update" class="btn btn-xs btn-primary waves-effect mb-2 waves-light" />
            </center>
        </div>
        
    </form>
</p>
<p>&nbsp;</p>

<p>
    The Actor's Office has <strong>Automated Relationship Reminder Systems</strong> for all your industry contacts - CD's, directors, writers, producers, etc. You select which system to use based on how well you know your Contact.
</p>

<p>
    We don't want your relationships to fall through the cracks whether you're creating, building or maintaining them. <strong><i>Checking one of these boxes is vital!</i></strong>
</p>

<ul>
    <li>
        <strong>Targeted List</strong>: These are all the people in the industry that you are targeting. These are the folks you want to work with, that tell the stories you tell, BUT you don't have a relationship with them...yet.
    </li>
    <li>
        <strong>Follow-Up List</strong>: These are all the industry people you JUST met whether that be over coffee, at an event, or an audition. Now you get to follow up with them to make sure you're beginning this relationship off right.
    </li>
    <li>
        <strong>Maintenance List</strong>: These are all the people in the industry that you've met and followed up with after the audition or meeting, and now you want to continually maintain that relationship and stay top of mind.
    </li>
</ul>
