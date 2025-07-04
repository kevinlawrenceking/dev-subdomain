<!--- This ColdFusion page displays user information including their name, avatar, and contact details. It also provides an option to update the account and change the password. --->

<h4>
    <cfoutput>#userFirstName# #userlastName#</cfoutput>
    <span class="float-end">
        <a title="Update Account" data-bs-toggle="modal" data-bs-target="#remoteUserUpdate" data-bs-original-title="Update Account">
            <i class="mdi mdi-square-edit-outline"></i>
        </a>
    </span>
</h4>

<div class="row">
    <!--- First Column: 20% Width --->
    <div class="col-md-2">
        <p class="card-text">
            <a  class="no-hover-effect" href="/app/image-upload/?contactid=<cfoutput>#contactid#&ref_pgid=7</cfoutput>"  class="no-hover-effect">
                <center>
                    <figure>
                        <img src="<cfoutput>#session.userAvatarUrl#?ver=#rand()#</cfoutput>" class="mr-2 rounded-circle gambar img-responsive img-thumbnail w-100" title="User ID: <cfoutput>#userid#</cfoutput>" style="max-width:120px" alt="profile-image" id="item-img-output" />
                        <figcaption>
                            <center><cfoutput>#avatarname#</cfoutput></center>
                        </figcaption>
                    </figure>
                </center>
            </a>
        </p>
        <form action="/recover/index.cfm">
            <p class="card-text">
                <center>
                    <cfoutput>
                        <input type="hidden" name="recoverid" value="#userid#" />
                    </cfoutput>
                    <button type="submit" class="btn btn-xs btn-primary waves-effect mb-2 waves-light" style="background-color: #406e8e; border: #406e8e">Change Password</button>
                </center>
            </p>
        </form>
    </div>

    <!--- Second Column: 80% Width --->
    <div class="col-10">
        <cfoutput>
            <dl class="row">
                <dt class="col-sm-3">Email:</dt>
                <dd class="col-sm-9">#useremail#</dd>

                <dt class="col-sm-3">Address:</dt>
                <dd class="col-sm-9">
                    #add1#<br>
                    #add2#
                </dd>

                <dt class="col-sm-3">Town/City:</dt>
                <dd class="col-sm-9">#city#</dd>

                <dt class="col-sm-3">Postal Code:</dt>
                <dd class="col-sm-9">#zip#</dd>

                <dt class="col-sm-3">State/Region:</dt>
                <dd class="col-sm-9">#region#</dd>

                <dt class="col-sm-3">Country:</dt>
                <dd class="col-sm-9">#countryname#</dd>
            </dl>
        </cfoutput>
    </div>
</div>
