<cfquery  name="insert"   >
insert into eventtypes_user (eventtypename,eventtypecolor,iscustom,userid)
values    ('#new_eventtypename#','#new_eventtypecolor#',1,#userid#)
</cfquery>
