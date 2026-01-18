<cfset contactItemService = createObject("component", "services.ContactItemService")>

<!--- Define the address struct dynamically --->
<cfparam name="contactid" default="0">
<cfparam name="address" default="">
<cfparam name="address_second" default="">
<cfparam name="city" default="">
<cfparam name="state" default="">
<cfparam name="zip" default="">
<cfparam name="country" default="">

<cfset new_address = {
    contactid = val(address.contactid), <!--- Ensure numeric value for contactid --->
    address = trim(address.address),
    address_second = trim(address.address_second),
    city = trim(address.city),
    state = trim(address.state),
    zip = trim(address.zip),
    country = trim(address.country)
}>



<!--- Call the function --->
<cfset result = contactItemService.INScontactitems_24424(new_address=new_address)>


