<cfparam name="select_userid"  default = "792" />
            
               <cfquery result="result"  name="x" datasource="abo">
        SELECT sitetypeid,sitetypename,sitetypedescription from sitetypes_user where userid = #select_userid#
    </cfquery>
            
            <Cfloop query="x">

<cfoutput>
             <Cfset new_pntitle = "#x.sitetypename# Links" />
                <cfset new_sitetypeid = x.sitetypeid />
</cfoutput>

<cfquery result="result" name="Findtotal"   maxrows="1" datasource="abo">  
     Select p.pnOrderno + 1 as new_pnOrderNo
        
        from pgpanels_user p 
 
        where p.userid = #select_userid#
        order by p.pnOrderno desc
    </cfquery> 

<cfquery name="add" datasource="abo"  result="PN">    
    INSERT INTO pgpanels_user (pnTitle,pnFilename,pnorderno,pncolxl,pncolMd,pnDescription,IsDeleted,IsVisible,userid)
    VALUES ('#new_pnTitle#','mylinks_user.cfm',#Findtotal.new_pnOrderNo#,3,3,'',0,1,#select_userid#)
    </cfquery>    

    <cfset new_pnid = PN.generated_key />
      <cfquery result="result" name="add" datasource="abo"> 
    update sitetypes_user
    set pnid = #new_pnid# where sitetypeid = #new_sitetypeid#
               </cfquery>
            
</cfloop>

