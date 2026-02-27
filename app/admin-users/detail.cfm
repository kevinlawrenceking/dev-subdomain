<!--- Redirect to framework path --->
<cfparam name="url.userid" default="0">
<cflocation url="/app/admin-users-detail/?userid=#val(url.userid)#" addtoken="false">
