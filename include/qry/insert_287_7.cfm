<cfinclude template="/include/perfcount.cfm" />
<cfset componentPath = "/services/AuditionOpenCallOptionUserService">
<cfset component = createObject("component", componentPath)>
<cfset component.INSaudopencalloptions_user(new_opencallname=new_opencallname, userid=userid)>