<!--- This ColdFusion page handles image uploads by decoding base64 image data and saving it to a specified directory. --->

<cfset uploadDir = cookie.uploadDir>
<cfset data = form.image>

<!--- Extract the type and base64 data from the input string --->
<cfset typeAndData = listToArray(data, ';')>
<cfset type = typeAndData[1]>
<cfset base64Data = listToArray(typeAndData[2], ',')[2]>

<!--- Decode the base64 data --->
<cfset decodedData = binaryDecode(base64Data, "utf-8")>

<!--- Generate a unique image name based on the current timestamp --->
<cfset imageName = createDateTime(now()) & ".png">

<!--- Save the decoded image data to the specified upload directory --->
<cfset fileWrite(uploadDir & imageName, decodedData)>
