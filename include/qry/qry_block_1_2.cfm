<cfset UserService = createObject("component", "services.UserService")>

<cfset UserService.UPDtaousers_23945(
    userid=userid,
    new_userfirstname=form.new_userfirstname,
    new_userlastname=form.new_userlastname,
    new_avatarname=new_avatarname,
    new_useremail=new_useremail,
    add1=form.add1,
    add2=form.add2,
    city=form.city,
    zip=form.zip,
    region_id=form.region_id,
    countryid=form.countryid
)>