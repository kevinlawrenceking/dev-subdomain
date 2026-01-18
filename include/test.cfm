<div id="auditionupdate_1423" class="modal fade show" tabindex="-1" aria-labelledby="standard-modalLabel" style="display: block; padding-right: 17px;" aria-modal="true" role="dialog">

            <div class="modal-dialog modal-lg">
                <div class="modal-content">
                    <div class="modal-header">
                        <h4 class="modal-title" id="standard-modalLabel">Appointment Update</h4>
                        <button type="button" class="close" data-bs-dismiss="modal">
<i class="mdi mdi-close-thick"></i></button>
                    </div>
                    <div class="modal-body">




<h4>
    Audition appointment
</h4>


<form method="post" action="/include/remoteaudupdateform2.cfm" class="parsley-examples" name="event-form" id="form-event" data-parsley-excluded="input[type=button], input[type=submit], input[type=reset], input[type=hidden], [disabled], :hidden" data-parsley-trigger="keyup" data-parsley-validate="" novalidate="">

    
        
        <input type="hidden" name="audprojectid" value="617">
        <input type="hidden" name="new_eventid" value="1423">
        <input type="hidden" name="eventid" value="1423">
        <input type="hidden" name="new_audStepID" value="1">
        <input type="hidden" name="new_audcatid" value="1">
        <input type="hidden" name="new_audsubcatid" value="5">
        <input type="hidden" name="new_userid" value="30">
        <input type="hidden" name="secid" value="176">
        <input type="hidden" name="new_audRoleID" value="566">
    

    
    <div class="row">
      <div class="form-group col-md-12">
          <label>
              Category: Film - Reading
          </label>
      </div>
    </div>

    
    <div class="row">
        
            <div class="form-group col-md-6">
                <label for="new_eventStart">Start Date / Due Date <span class="text-danger">*</span></label>
                <input id="new_eventStart" class="form-control" name="new_eventStart" type="date" autocomplete="off" data-parsley-required="" data-parsley-error-message="Start Date is required" value="2025-01-23">
            </div>
        

        
        <div class="form-group col-md-6">
            <label for="new_eventStartTime">Start Time / Due Time <span class="text-danger">*</span></label>
            <select class="form-control" name="new_eventStartTime" autocomplete="off" id="new_eventStartTime" data-parsley-required="" data-parsley-error-message="Start Time is required">

                <option value="">Select a Start/Due Time</option>
                
                
                
                    <option value="09:00:00">
                      9:00 AM
                    </option>
                  
                    <option value="09:15:00">
                      9:15 AM
                    </option>
                  
                    <option value="09:30:00">
                      9:30 AM
                    </option>
                  
                    <option value="09:45:00">
                      9:45 AM
                    </option>
                  
                    <option value="10:00:00">
                      10:00 AM
                    </option>
                  
                    <option value="10:15:00">
                      10:15 AM
                    </option>
                  
                    <option value="10:30:00">
                      10:30 AM
                    </option>
                  
                    <option value="10:45:00">
                      10:45 AM
                    </option>
                  
                    <option value="11:00:00" selected="">
                      11:00 AM
                    </option>
                  
                    <option value="11:15:00">
                      11:15 AM
                    </option>
                  
                    <option value="11:30:00">
                      11:30 AM
                    </option>
                  
                    <option value="11:45:00">
                      11:45 AM
                    </option>
                  
                    <option value="12:00:00">
                      12:00 PM
                    </option>
                  
                    <option value="12:15:00">
                      12:15 PM
                    </option>
                  
                    <option value="12:30:00">
                      12:30 PM
                    </option>
                  
                    <option value="12:45:00">
                      12:45 PM
                    </option>
                  
                    <option value="13:00:00">
                      1:00 PM
                    </option>
                  
                    <option value="13:15:00">
                      1:15 PM
                    </option>
                  
                    <option value="13:30:00">
                      1:30 PM
                    </option>
                  
                    <option value="13:45:00">
                      1:45 PM
                    </option>
                  
                    <option value="14:00:00">
                      2:00 PM
                    </option>
                  
                    <option value="14:15:00">
                      2:15 PM
                    </option>
                  
                    <option value="14:30:00">
                      2:30 PM
                    </option>
                  
                    <option value="14:45:00">
                      2:45 PM
                    </option>
                  
                    <option value="15:00:00">
                      3:00 PM
                    </option>
                  
                    <option value="15:15:00">
                      3:15 PM
                    </option>
                  
                    <option value="15:30:00">
                      3:30 PM
                    </option>
                  
                    <option value="15:45:00">
                      3:45 PM
                    </option>
                  
                    <option value="16:00:00">
                      4:00 PM
                    </option>
                  
                    <option value="16:15:00">
                      4:15 PM
                    </option>
                  
                    <option value="16:30:00">
                      4:30 PM
                    </option>
                  
                    <option value="16:45:00">
                      4:45 PM
                    </option>
                  
                    <option value="17:00:00">
                      5:00 PM
                    </option>
                  
                    <option value="17:15:00">
                      5:15 PM
                    </option>
                  
                    <option value="17:30:00">
                      5:30 PM
                    </option>
                  
            </select>
        </div>
    </div>

    
    <div class="row">
      <div class="form-group col-md-6">
          <label for="new_durid">Duration</label>
          <select class="form-control" name="new_durid" id="new_durid">
              
                  <option value="0">
                    Unknown
                  </option>
              
                  <option value="1">
                    15 mins
                  </option>
              
                  <option value="2">
                    30 mins
                  </option>
              
                  <option value="3">
                    45 mins
                  </option>
              
                  <option value="4" selected="">
                    1 hr
                  </option>
              
                  <option value="5">
                    1.25 hrs
                  </option>
              
                  <option value="6">
                    1.5 hrs
                  </option>
              
                  <option value="7">
                    1.75 hrs
                  </option>
              
                  <option value="8">
                    2 hrs
                  </option>
              
                  <option value="9">
                    2.25 hrs
                  </option>
              
                  <option value="10">
                    2.5 hrs
                  </option>
              
                  <option value="11">
                    2.75 hrs
                  </option>
              
                  <option value="12">
                    3 hrs
                  </option>
              
                  <option value="13">
                    3.25 hrs
                  </option>
              
                  <option value="14">
                    3.5 hrs
                  </option>
              
                  <option value="15">
                    3.75 hrs
                  </option>
              
                  <option value="16">
                    4 hrs
                  </option>
              
                  <option value="17">
                    4.25 hrs
                  </option>
              
                  <option value="18">
                    4.5 hrs
                  </option>
              
                  <option value="19">
                    4.75 hrs
                  </option>
              
                  <option value="20">
                    5 hrs
                  </option>
              
                  <option value="21">
                    5.25 hrs
                  </option>
              
                  <option value="22">
                    5.5 hrs
                  </option>
              
                  <option value="23">
                    5.75 hrs
                  </option>
              
                  <option value="24">
                    6 hrs
                  </option>
              
                  <option value="25">
                    6.25 hrs
                  </option>
              
                  <option value="26">
                    6.5 hrs
                  </option>
              
                  <option value="27">
                    6.75 hrs
                  </option>
              
                  <option value="28">
                    7 hrs
                  </option>
              
                  <option value="29">
                    7.25 hrs
                  </option>
              
                  <option value="30">
                    7.5 hrs
                  </option>
              
                  <option value="31">
                    7.75 hrs
                  </option>
              
                  <option value="32">
                    8 hrs
                  </option>
              
                  <option value="33">
                    8.25 hrs
                  </option>
              
                  <option value="34">
                    8.5 hrs
                  </option>
              
                  <option value="35">
                    8.75 hrs
                  </option>
              
                  <option value="36">
                    9 hrs
                  </option>
              
                  <option value="37">
                    9.25 hrs
                  </option>
              
                  <option value="38">
                    9.5 hrs
                  </option>
              
                  <option value="39">
                    9.75 hrs
                  </option>
              
                  <option value="40">
                    10 hrs
                  </option>
              
                  <option value="41">
                    10.25 hrs
                  </option>
              
                  <option value="42">
                    10.5 hrs
                  </option>
              
                  <option value="43">
                    10.75 hrs
                  </option>
              
                  <option value="44">
                    11 hrs
                  </option>
              
                  <option value="45">
                    11.25 hrs
                  </option>
              
                  <option value="46">
                    11.5 hrs
                  </option>
              
                  <option value="47">
                    11.75 hrs
                  </option>
              
                  <option value="48">
                    12 hrs
                  </option>
              
          </select>
      </div>

      
      
          
          <input type="hidden" name="new_callbacktypeid" value="#old_callbacktypeid#">
      
    </div>

    <div class="row">
      
      <div class="form-group col-md-6">
          <label for="audtypeid">Type <span class="text-danger">*</span></label>
          <select id="audtypeid" name="new_audtypeid" class="form-control" data-parsley-required="" data-parsley-error-message="Type is required" onchange="handleSelectChange(this);">
              <option value="">--</option>
              
                  <option value="1">
                    In Person
                  </option>
              
                  <option value="2">
                    Online
                  </option>
              
                  <option value="3" selected="">
                    Self Tape
                  </option>
              
          </select>
      </div>

      
      
    </div>

    
    <div class="row" id="hiddenLocation" style="display: block;">
    
        <div class="form-group col-md-12">
            <label for="new_parkingDetails">Parking Details</label>
            <input class="form-control" type="text" id="new_parkingDetails" name="new_parkingDetails" placeholder="Parking details" value="">
        </div>

        <div class="form-group col-md-12">
          <div class="form-check">
            <input type="checkbox" class="form-check-input" id="trackmileage" value="1" name="new_trackmileage">
            <label class="form-check-label" for="trackmileage">
              Track Mileage
            </label>
          </div>
        </div>

        
        <div class="form-group col-md-12 d-flex align-items-center">
            <label for="eventLocation" class="mb-0 flex-grow-1">
                Location Name <span class="text-danger">*</span>
            </label>
            
                <button type="button" class="btn btn-primary btn-sm ml-auto" id="populateFieldsButton">
                    Same
                </button>
            
        </div>

        <div class="form-group col-md-12">
            <input class="form-control" type="text" id="eventLocation" name="new_eventLocation" placeholder="Location Name" data-parsley-error-message="Location Name is required" value="" required="required" data-parsley-required="true">
        </div>

        <div class="form-group col-md-12">
            <label for="audlocadd1">Address</label>
            <input class="form-control" type="text" id="audlocadd1" name="new_audlocadd1" placeholder="Address" value="">
        </div>

        <div class="form-group col-md-12">
            <label for="audlocadd2">Extended Address</label>
            <input class="form-control" type="text" id="audlocadd2" name="new_audlocadd2" placeholder="APT 101" value="">
        <div data-lastpass-icon-root="" style="position: relative !important; height: 0px !important; width: 0px !important; float: left !important;"></div></div>

        <div class="form-group col-md-6">
            <label for="audcity">Town/City</label>
            <input class="form-control" type="text" id="audcity" name="new_audcity" placeholder="Enter City" value="">
        </div>

        <div class="form-group col-md-6">
            <label for="audzip">Postal Code</label>
            <input class="form-control" type="text" id="audzip" name="new_audzip" placeholder="Enter Postal Code" value="">
        </div>

        
        <div class="form-group col-md-6">
            <label for="region_id">State/Region <span class="text-danger">*</span></label>
            <select id="region_id" name="new_region_id" class="form-control">
                <option value="">--</option>
                
                    <option value="571" data-chained="CH">
                        Aargau </option>
                
                    <option value="1343" data-chained="GE">
                        Abashis Raioni </option>
                
                    <option value="597" data-chained="CI">
                        Abengourou </option>
                
                    <option value="1283" data-chained="GB">
                        Aberdeen City </option>
                
                    <option value="1284" data-chained="GB">
                        Aberdeenshire </option>
                
                    <option value="2606" data-chained="NG">
                        Abia </option>
                
                    <option value="641" data-chained="CI">
                        Abidjan </option>
                
                    <option value="1344" data-chained="GE">
                        Abkhazia </option>
                
                    <option value="642" data-chained="CI">
                        Aboisso </option>
                
                    <option value="2865" data-chained="PH">
                        Abra </option>
                
                    <option value="1826" data-chained="IT">
                        Abruzzi </option>
                
                    <option value="135" data-chained="AZ">
                        Abseron </option>
                
                    <option value="8" data-chained="AE">
                        Abu Dhabi </option>
                
                    <option value="2583" data-chained="NG">
                        Abuja Capital Territory </option>
                
                    <option value="4105" data-chained="YE">
                        Abyan </option>
                
                    <option value="1646" data-chained="ID">
                        Aceh </option>
                
                    <option value="466" data-chained="BS">
                        Acklins and Crooked Islands </option>
                
                    <option value="3493" data-chained="SM">
                        Acquaviva </option>
                
                    <option value="430" data-chained="BR">
                        Acre </option>
                
                    <option value="2802" data-chained="OM">
                        Ad Dakhiliyah </option>
                
                    <option value="980" data-chained="EG">
                        Ad Daqahliyah </option>
                
                    <option value="3110" data-chained="QA">
                        Ad Dawhah </option>
                
                    <option value="672" data-chained="CM">
                        Adamaoua </option>
                
                    <option value="2597" data-chained="NG">
                        Adamawa </option>
                
                    <option value="3784" data-chained="TR">
                        Adana </option>
                
                    <option value="1026" data-chained="ET">
                        Addis Abeba </option>
                
                    <option value="643" data-chained="CI">
                        Adiake </option>
                
                    <option value="1345" data-chained="GE">
                        Adigenis Raioni </option>
                
                    <option value="1031" data-chained="ET">
                        Adis Abeba </option>
                
                    <option value="3716" data-chained="TR">
                        Adiyaman </option>
                
                    <option value="3876" data-chained="UG">
                        Adjumani </option>
                
                    <option value="2413" data-chained="MR">
                        Adrar </option>
                
                    <option value="914" data-chained="DZ">
                        Adrar </option>
                
                    <option value="3162" data-chained="RU">
                        Adygeya, Republic of </option>
                
                    <option value="599" data-chained="CI">
                        Adzope </option>
                
                    <option value="1030" data-chained="ET">
                        Afar </option>
                
                    <option value="3717" data-chained="TR">
                        Afyon </option>
                
                    <option value="2575" data-chained="NE">
                        Agadez </option>
                
                    <option value="2175" data-chained="MA">
                        Agadir </option>
                
                    <option value="2431" data-chained="MU">
                        Agalega Islands </option>
                
                    <option value="600" data-chained="CI">
                        Agboville </option>
                
                    <option value="136" data-chained="AZ">
                        Agcabadi </option>
                
                    <option value="137" data-chained="AZ">
                        Agdam </option>
                
                    <option value="138" data-chained="AZ">
                        Agdas </option>
                
                    <option value="3163" data-chained="RU">
                        Aginsky Buryatsky AO </option>
                
                    <option value="3718" data-chained="TR">
                        Agri </option>
                
                    <option value="139" data-chained="AZ">
                        Agstafa </option>
                
                    <option value="140" data-chained="AZ">
                        Agsu </option>
                
                    <option value="2480" data-chained="MX">
                        Aguascalientes </option>
                
                    <option value="2866" data-chained="PH">
                        Agusan del Norte </option>
                
                    <option value="2867" data-chained="PH">
                        Agusan del Sur </option>
                
                    <option value="3684" data-chained="TM">
                        Ahal </option>
                
                    <option value="3540" data-chained="SV">
                        Ahuachapan </option>
                
                    <option value="1868" data-chained="JP">
                        Aichi </option>
                
                    <option value="4095" data-chained="WS">
                        Aiga-i-le-Tai </option>
                
                    <option value="915" data-chained="DZ">
                        Ain Defla </option>
                
                    <option value="916" data-chained="DZ">
                        Ain Temouchent </option>
                
                    <option value="655" data-chained="CL">
                        Aisen del General Carlos Ibanez del Campo </option>
                
                    <option value="1497" data-chained="GR">
                        Aitolia kai Akarnania </option>
                
                    <option value="2683" data-chained="NR">
                        Aiwo </option>
                
                    <option value="2126" data-chained="LV">
                        Aizkraukles </option>
                
                    <option value="1346" data-chained="GE">
                        Ajaria </option>
                
                    <option value="2159" data-chained="LY">
                        Ajdabiya </option>
                
                    <option value="3340" data-chained="SI">
                        Ajdovscina </option>
                
                    <option value="9" data-chained="AE">
                        Ajman </option>
                
                    <option value="2697" data-chained="NZ">
                        Akaroa </option>
                
                    <option value="2650" data-chained="NO">
                        Akershus </option>
                
                    <option value="1504" data-chained="GR">
                        Akhaia </option>
                
                    <option value="1347" data-chained="GE">
                        Akhalgoris Raioni </option>
                
                    <option value="1348" data-chained="GE">
                        Akhalk'alak'is Raioni </option>
                
                    <option value="1349" data-chained="GE">
                        Akhalts'ikhis Raioni </option>
                
                    <option value="1350" data-chained="GE">
                        Akhmetis Raioni </option>
                
                    <option value="1869" data-chained="JP">
                        Akita </option>
                
                    <option value="2868" data-chained="PH">
                        Aklan </option>
                
                    <option value="1789" data-chained="IS">
                        Akranes </option>
                
                    <option value="3778" data-chained="TR">
                        Aksaray </option>
                
                    <option value="1790" data-chained="IS">
                        Akureyri </option>
                
                    <option value="2585" data-chained="NG">
                        Akwa Ibom </option>
                
                    <option value="2150" data-chained="LY">
                        Al </option>
                
                    <option value="2000" data-chained="KW">
                        Al Ahmadi </option>
                
                    <option value="1743" data-chained="IQ">
                        Al Anbar </option>
                
                    <option value="3261" data-chained="SA">
                        Al Bahah </option>
                
                    <option value="981" data-chained="EG">
                        Al Bahr al Ahmar </option>
                
                    <option value="1860" data-chained="JO">
                        Al Balqa' </option>
                
                    <option value="1744" data-chained="IQ">
                        Al Basrah </option>
                
                    <option value="2803" data-chained="OM">
                        Al Batinah </option>
                
                    <option value="4115" data-chained="YE">
                        Al Bayda' </option>
                
                    <option value="982" data-chained="EG">
                        Al Buhayrah </option>
                
                    <option value="2160" data-chained="LY">
                        Al Fatih </option>
                
                    <option value="983" data-chained="EG">
                        Al Fayyum </option>
                
                    <option value="984" data-chained="EG">
                        Al Gharbiyah </option>
                
                    <option value="3111" data-chained="QA">
                        Al Ghuwariyah </option>
                
                    <option value="365" data-chained="BH">
                        Al Hadd </option>
                
                    <option value="3554" data-chained="SY">
                        Al Hasakah </option>
                
                    <option value="2176" data-chained="MA">
                        Al Hoceima </option>
                
                    <option value="4109" data-chained="YE">
                        Al Hudaydah </option>
                
                    <option value="3270" data-chained="SA">
                        Al Hudud ash Shamaliyah </option>
                
                    <option value="985" data-chained="EG">
                        Al Iskandariyah </option>
                
                    <option value="986" data-chained="EG">
                        Al Isma'iliyah </option>
                
                    <option value="3304" data-chained="SD">
                        Al Istiwa'iyah </option>
                
                    <option value="2161" data-chained="LY">
                        Al Jabal al Akhdar </option>
                
                    <option value="2003" data-chained="KW">
                        Al Jahra </option>
                
                    <option value="4116" data-chained="YE">
                        Al Jawf </option>
                
                    <option value="3262" data-chained="SA">
                        Al Jawf </option>
                
                    <option value="987" data-chained="EG">
                        Al Jizah </option>
                
                    <option value="2151" data-chained="LY">
                        Al Jufrah </option>
                
                    <option value="3112" data-chained="QA">
                        Al Jumaliyah </option>
                
                    <option value="1862" data-chained="JO">
                        Al Karak </option>
                
                    <option value="3305" data-chained="SD">
                        Al Khartum </option>
                
                    <option value="3113" data-chained="QA">
                        Al Khawr </option>
                
                    <option value="2162" data-chained="LY">
                        Al Khums </option>
                
                    <option value="2152" data-chained="LY">
                        Al Kufrah </option>
                
                    <option value="2001" data-chained="KW">
                        Al Kuwayt </option>
                
                    <option value="3555" data-chained="SY">
                        Al Ladhiqiyah </option>
                
                    <option value="3263" data-chained="SA">
                        Al Madinah </option>
                
                    <option value="1863" data-chained="JO">
                        Al Mafraq </option>
                
                    <option value="3694" data-chained="TN">
                        Al Mahdiyah </option>
                
                    <option value="4106" data-chained="YE">
                        Al Mahrah </option>
                
                    <option value="4110" data-chained="YE">
                        Al Mahwit </option>
                
                    <option value="366" data-chained="BH">
                        Al Manamah </option>
                
                    <option value="370" data-chained="BH">
                        Al Mintaqah al Gharbiyah </option>
                
                    <option value="373" data-chained="BH">
                        Al Mintaqah al Wusta </option>
                
                    <option value="372" data-chained="BH">
                        Al Mintaqah ash Shamaliyah </option>
                
                    <option value="988" data-chained="EG">
                        Al Minufiyah </option>
                
                    <option value="989" data-chained="EG">
                        Al Minya </option>
                
                    <option value="367" data-chained="BH">
                        Al Muharraq </option>
                
                    <option value="3695" data-chained="TN">
                        Al Munastir </option>
                
                    <option value="1745" data-chained="IQ">
                        Al Muthanna </option>
                
                    <option value="1746" data-chained="IQ">
                        Al Qadisiyah </option>
                
                    <option value="990" data-chained="EG">
                        Al Qahirah </option>
                
                    <option value="991" data-chained="EG">
                        Al Qalyubiyah </option>
                
                    <option value="3265" data-chained="SA">
                        Al Qasim </option>
                
                    <option value="3689" data-chained="TN">
                        Al Qasrayn </option>
                
                    <option value="3690" data-chained="TN">
                        Al Qayrawan </option>
                
                    <option value="3556" data-chained="SY">
                        Al Qunaytirah </option>
                
                    <option value="3266" data-chained="SA">
                        Al Qurayyat </option>
                
                    <option value="992" data-chained="EG">
                        Al Wadi al Jadid </option>
                
                    <option value="3117" data-chained="QA">
                        Al Wakrah </option>
                
                    <option value="3303" data-chained="SD">
                        Al Wusta </option>
                
                    <option value="2804" data-chained="OM">
                        Al Wusta </option>
                
                    <option value="3906" data-chained="US">
                        Alabama </option>
                
                    <option value="431" data-chained="BR">
                        Alagoas </option>
                
                    <option value="741" data-chained="CR">
                        Alajuela </option>
                
                    <option value="3905" data-chained="US">
                        Alaska </option>
                
                    <option value="3120" data-chained="RO">
                        Alba </option>
                
                    <option value="2869" data-chained="PH">
                        Albay </option>
                
                    <option value="519" data-chained="CA">
                        Alberta </option>
                
                    <option value="644" data-chained="CI">
                        Alepe </option>
                
                    <option value="889" data-chained="DZ">
                        Alger </option>
                
                    <option value="141" data-chained="AZ">
                        Ali Bayramli </option>
                
                    <option value="409" data-chained="BN">
                        Alibori </option>
                
                    <option value="2435" data-chained="MV">
                        Aliff </option>
                
                    <option value="2012" data-chained="KZ">
                        Almaty </option>
                
                    <option value="2013" data-chained="KZ">
                        Almaty City </option>
                
                    <option value="1075" data-chained="FR">
                        Alsace </option>
                
                    <option value="1518" data-chained="GT">
                        Alta Verapaz </option>
                
                    <option value="3165" data-chained="RU">
                        Altaisky krai </option>
                
                    <option value="3109" data-chained="PY">
                        Alto Paraguay </option>
                
                    <option value="3091" data-chained="PY">
                        Alto Parana </option>
                
                    <option value="2127" data-chained="LV">
                        Aluksnes </option>
                
                    <option value="3311" data-chained="SE">
                        Alvsborgs Lan </option>
                
                    <option value="2113" data-chained="LT">
                        Alytaus Apskritis </option>
                
                    <option value="3092" data-chained="PY">
                        Amambay </option>
                
                    <option value="432" data-chained="BR">
                        Amapa </option>
                
                    <option value="1032" data-chained="ET">
                        Amara </option>
                
                    <option value="3719" data-chained="TR">
                        Amasya </option>
                
                    <option value="2820" data-chained="PE">
                        Amazonas </option>
                
                    <option value="4003" data-chained="VE">
                        Amazonas </option>
                
                    <option value="433" data-chained="BR">
                        Amazonas </option>
                
                    <option value="708" data-chained="CO">
                        Amazonas </option>
                
                    <option value="1351" data-chained="GE">
                        Ambrolauris Raioni </option>
                
                    <option value="4081" data-chained="VU">
                        Ambrym </option>
                
                    <option value="3909" data-chained="US">
                        American Samoa </option>
                
                    <option value="1023" data-chained="ET">
                        Amhara </option>
                
                    <option value="3587" data-chained="TG">
                        Amlame </option>
                
                    <option value="1867" data-chained="JO">
                        Amman </option>
                
                    <option value="2069" data-chained="LK">
                        Amparai </option>
                
                    <option value="3166" data-chained="RU">
                        Amur </option>
                
                    <option value="2698" data-chained="NZ">
                        Amuri </option>
                
                    <option value="4045" data-chained="VN">
                        An Giang </option>
                
                    <option value="1759" data-chained="IQ">
                        An Najaf </option>
                
                    <option value="2163" data-chained="LY">
                        An Nuqat al Khams </option>
                
                    <option value="2684" data-chained="NR">
                        Anabar </option>
                
                    <option value="2589" data-chained="NG">
                        Anambra </option>
                
                    <option value="2821" data-chained="PE">
                        Ancash </option>
                
                    <option value="1013" data-chained="ES">
                        Andalucia </option>
                
                    <option value="1708" data-chained="IN">
                        Andaman and Nicobar Islands </option>
                
                    <option value="1709" data-chained="IN">
                        Andhra Pradesh </option>
                
                    <option value="3984" data-chained="UZ">
                        Andijon </option>
                
                    <option value="6" data-chained="AD">
                        Andorra la Vella </option>
                
                    <option value="3588" data-chained="TG">
                        Aneho </option>
                
                    <option value="2685" data-chained="NR">
                        Anetan </option>
                
                    <option value="3641" data-chained="TH">
                        Ang Thong </option>
                
                    <option value="2935" data-chained="PH">
                        Angeles </option>
                
                    <option value="1285" data-chained="GB">
                        Angus </option>
                
                    <option value="677" data-chained="CN">
                        Anhui </option>
                
                    <option value="2686" data-chained="NR">
                        Anibare </option>
                
                    <option value="1954" data-chained="KM">
                        Anjouan </option>
                
                    <option value="3771" data-chained="TR">
                        Ankara </option>
                
                    <option value="917" data-chained="DZ">
                        Annaba </option>
                
                    <option value="1460" data-chained="GQ">
                        Annobon </option>
                
                    <option value="3281" data-chained="SC">
                        Anse aux Pins </option>
                
                    <option value="3282" data-chained="SC">
                        Anse Boileau </option>
                
                    <option value="3283" data-chained="SC">
                        Anse Etoile </option>
                
                    <option value="3284" data-chained="SC">
                        Anse Louis </option>
                
                    <option value="3285" data-chained="SC">
                        Anse Royale </option>
                
                    <option value="2047" data-chained="LC">
                        Anse-la-Raye </option>
                
                    <option value="3720" data-chained="TR">
                        Antalya </option>
                
                    <option value="2232" data-chained="MG">
                        Antananarivo </option>
                
                    <option value="709" data-chained="CO">
                        Antioquia </option>
                
                    <option value="2870" data-chained="PH">
                        Antique </option>
                
                    <option value="656" data-chained="CL">
                        Antofagasta </option>
                
                    <option value="1257" data-chained="GB">
                        Antrim </option>
                
                    <option value="2228" data-chained="MG">
                        Antsiranana </option>
                
                    <option value="279" data-chained="BE">
                        Antwerpen </option>
                
                    <option value="2070" data-chained="LK">
                        Anuradhapura </option>
                
                    <option value="4004" data-chained="VE">
                        Anzoategui </option>
                
                    <option value="4082" data-chained="VU">
                        Aoba </option>
                
                    <option value="1870" data-chained="JP">
                        Aomori </option>
                
                    <option value="4005" data-chained="VE">
                        Apure </option>
                
                    <option value="2822" data-chained="PE">
                        Apurimac </option>
                
                    <option value="2014" data-chained="KZ">
                        Aqmola </option>
                
                    <option value="1054" data-chained="FR">
                        Aquitaine </option>
                
                    <option value="3557" data-chained="SY">
                        Ar Raqqah </option>
                
                    <option value="3114" data-chained="QA">
                        Ar Rayyan </option>
                
                    <option value="375" data-chained="BH">
                        Ar Rifa </option>
                
                    <option value="3267" data-chained="SA">
                        Ar Riyad </option>
                
                    <option value="2234" data-chained="MK">
                        Aracinovo </option>
                
                    <option value="3121" data-chained="RO">
                        Arad </option>
                
                    <option value="66" data-chained="AM">
                        Aragatsotn </option>
                
                    <option value="1014" data-chained="ES">
                        Aragon </option>
                
                    <option value="4006" data-chained="VE">
                        Aragua </option>
                
                    <option value="67" data-chained="AM">
                        Ararat </option>
                
                    <option value="710" data-chained="CO">
                        Arauca </option>
                
                    <option value="657" data-chained="CL">
                        Araucania </option>
                
                    <option value="1753" data-chained="IQ">
                        Arbil </option>
                
                    <option value="1782" data-chained="IR">
                        Ardabil </option>
                
                    <option value="3789" data-chained="TR">
                        Ardahan </option>
                
                    <option value="1258" data-chained="GB">
                        Ards </option>
                
                    <option value="2823" data-chained="PE">
                        Arequipa </option>
                
                    <option value="3122" data-chained="RO">
                        Arges </option>
                
                    <option value="1502" data-chained="GR">
                        Argolis </option>
                
                    <option value="1286" data-chained="GB">
                        Argyll and Bute </option>
                
                    <option value="2381" data-chained="MN">
                        Arhangay </option>
                
                    <option value="834" data-chained="DK">
                        Arhus </option>
                
                    <option value="3711" data-chained="TN">
                        Ariana </option>
                
                    <option value="3797" data-chained="TT">
                        Arima </option>
                
                    <option value="3910" data-chained="US">
                        Arizona </option>
                
                    <option value="1507" data-chained="GR">
                        Arkadhia </option>
                
                    <option value="3908" data-chained="US">
                        Arkansas </option>
                
                    <option value="3167" data-chained="RU">
                        Arkhangel'sk </option>
                
                    <option value="1259" data-chained="GB">
                        Armagh </option>
                
                    <option value="68" data-chained="AM">
                        Armavir </option>
                
                    <option value="3903" data-chained="US">
                        Armed Forces Americas </option>
                
                    <option value="3904" data-chained="US">
                        Armed Forces Europe, Middle East, &amp; Canada </option>
                
                    <option value="3907" data-chained="US">
                        Armed Forces Pacific </option>
                
                    <option value="1791" data-chained="IS">
                        Arnessysla </option>
                
                    <option value="1486" data-chained="GR">
                        Arta </option>
                
                    <option value="1599" data-chained="HT">
                        Artibonite </option>
                
                    <option value="3965" data-chained="UY">
                        Artigas </option>
                
                    <option value="3721" data-chained="TR">
                        Artvin </option>
                
                    <option value="3882" data-chained="UG">
                        Arua </option>
                
                    <option value="1733" data-chained="IN">
                        Arunachal Pradesh </option>
                
                    <option value="3813" data-chained="TZ">
                        Arusha </option>
                
                    <option value="1747" data-chained="IQ">
                        As Sulaymaniyah </option>
                
                    <option value="3558" data-chained="SY">
                        As Suwayda' </option>
                
                    <option value="994" data-chained="EG">
                        As Suways </option>
                
                    <option value="3337" data-chained="SH">
                        Ascension </option>
                
                    <option value="3306" data-chained="SD">
                        Ash Shamaliyah </option>
                
                    <option value="3264" data-chained="SA">
                        Ash Sharqiyah </option>
                
                    <option value="993" data-chained="EG">
                        Ash Sharqiyah </option>
                
                    <option value="3307" data-chained="SD">
                        Ash Sharqiyah </option>
                
                    <option value="2805" data-chained="OM">
                        Ash Sharqiyah </option>
                
                    <option value="2153" data-chained="LY">
                        Ash Shati' </option>
                
                    <option value="1408" data-chained="GH">
                        Ashanti </option>
                
                    <option value="2699" data-chained="NZ">
                        Ashburton </option>
                
                    <option value="1352" data-chained="GE">
                        Aspindzis Raioni </option>
                
                    <option value="2409" data-chained="MR">
                        Assaba </option>
                
                    <option value="1710" data-chained="IN">
                        Assam </option>
                
                    <option value="2015" data-chained="KZ">
                        Astana </option>
                
                    <option value="142" data-chained="AZ">
                        Astara </option>
                
                    <option value="3168" data-chained="RU">
                        Astrakhan' </option>
                
                    <option value="1011" data-chained="ES">
                        Asturias </option>
                
                    <option value="995" data-chained="EG">
                        Aswan </option>
                
                    <option value="996" data-chained="EG">
                        Asyut </option>
                
                    <option value="1755" data-chained="IQ">
                        At Ta'mim </option>
                
                    <option value="1864" data-chained="JO">
                        At Tafilah </option>
                
                    <option value="658" data-chained="CL">
                        Atacama </option>
                
                    <option value="393" data-chained="BJ">
                        Atakora </option>
                
                    <option value="3589" data-chained="TG">
                        Atakpame </option>
                
                    <option value="711" data-chained="CO">
                        Atlantico </option>
                
                    <option value="1559" data-chained="HN">
                        Atlantida </option>
                
                    <option value="394" data-chained="BJ">
                        Atlantique </option>
                
                    <option value="2028" data-chained="LA">
                        Attapu </option>
                
                    <option value="1501" data-chained="GR">
                        Attiki </option>
                
                    <option value="4096" data-chained="WS">
                        Atua </option>
                
                    <option value="2016" data-chained="KZ">
                        Atyrau </option>
                
                    <option value="2995" data-chained="PH">
                        Aurora </option>
                
                    <option value="572" data-chained="CH">
                        Ausser-Rhoden </option>
                
                    <option value="2651" data-chained="NO">
                        Aust-Agder </option>
                
                    <option value="127" data-chained="AU">
                        Australian Capital Territory </option>
                
                    <option value="1792" data-chained="IS">
                        Austur-Bardastrandarsysla </option>
                
                    <option value="1793" data-chained="IS">
                        Austur-Hunavatnssysla </option>
                
                    <option value="1794" data-chained="IS">
                        Austur-Skaftafellssysla </option>
                
                    <option value="1055" data-chained="FR">
                        Auvergne </option>
                
                    <option value="3071" data-chained="PT">
                        Aveiro </option>
                
                    <option value="1085" data-chained="GB">
                        Avon </option>
                
                    <option value="2164" data-chained="LY">
                        Awbari </option>
                
                    <option value="2824" data-chained="PE">
                        Ayacucho </option>
                
                    <option value="3722" data-chained="TR">
                        Aydin </option>
                
                    <option value="2806" data-chained="OM">
                        Az Zahirah </option>
                
                    <option value="1865" data-chained="JO">
                        Az Zarqa </option>
                
                    <option value="2165" data-chained="LY">
                        Az Zawiyah </option>
                
                    <option value="3003" data-chained="PK">
                        Azad Kashmir </option>
                
                    <option value="1761" data-chained="IR">
                        Azarbayjan-e Bakhtari </option>
                
                    <option value="1762" data-chained="IR">
                        Azarbayjan-e Khavari </option>
                
                    <option value="2177" data-chained="MA">
                        Azilal </option>
                
                    <option value="3090" data-chained="PT">
                        Azores </option>
                
                    <option value="859" data-chained="DO">
                        Azua </option>
                
                    <option value="938" data-chained="EC">
                        Azuay </option>
                
                    <option value="4055" data-chained="VN">
                        Ba Ria-Vung Tau </option>
                
                    <option value="2445" data-chained="MV">
                        Baa </option>
                
                    <option value="1748" data-chained="IQ">
                        Babil </option>
                
                    <option value="2235" data-chained="MK">
                        Bac </option>
                
                    <option value="4028" data-chained="VN">
                        Bac Thai </option>
                
                    <option value="3123" data-chained="RO">
                        Bacau </option>
                
                    <option value="2936" data-chained="PH">
                        Bacolod </option>
                
                    <option value="1607" data-chained="HU">
                        Bacs-Kiskun </option>
                
                    <option value="15" data-chained="AF">
                        Badakhshan </option>
                
                    <option value="814" data-chained="DE">
                        Baden-WÃ¼rttemberg </option>
                
                    <option value="16" data-chained="AF">
                        Badghis </option>
                
                    <option value="3601" data-chained="TG">
                        Badou </option>
                
                    <option value="2071" data-chained="LK">
                        Badulla </option>
                
                    <option value="1540" data-chained="GW">
                        Bafata </option>
                
                    <option value="3590" data-chained="TG">
                        Bafilo </option>
                
                    <option value="221" data-chained="BD">
                        Bagerhat </option>
                
                    <option value="1749" data-chained="IQ">
                        Baghdad </option>
                
                    <option value="1353" data-chained="GE">
                        Baghdat'is Raioni </option>
                
                    <option value="17" data-chained="AF">
                        Baghlan </option>
                
                    <option value="2669" data-chained="NP">
                        Bagmati </option>
                
                    <option value="2937" data-chained="PH">
                        Bago </option>
                
                    <option value="2938" data-chained="PH">
                        Baguio </option>
                
                    <option value="434" data-chained="BR">
                        Bahia </option>
                
                    <option value="3308" data-chained="SD">
                        Bahr al Ghazal </option>
                
                    <option value="3286" data-chained="SC">
                        Baie Lazare </option>
                
                    <option value="3287" data-chained="SC">
                        Baie Sainte Anne </option>
                
                    <option value="2939" data-chained="PH">
                        Bais </option>
                
                    <option value="2687" data-chained="NR">
                        Baiti </option>
                
                    <option value="2481" data-chained="MX">
                        Baja California </option>
                
                    <option value="2482" data-chained="MX">
                        Baja California Sur </option>
                
                    <option value="1519" data-chained="GT">
                        Baja Verapaz </option>
                
                    <option value="3696" data-chained="TN">
                        Bajah </option>
                
                    <option value="1771" data-chained="IR">
                        Bakhtaran </option>
                
                    <option value="143" data-chained="AZ">
                        Baki </option>
                
                    <option value="3512" data-chained="SO">
                        Bakool </option>
                
                    <option value="2475" data-chained="MW">
                        Balaka </option>
                
                    <option value="144" data-chained="AZ">
                        Balakan </option>
                
                    <option value="302" data-chained="BF">
                        Bale </option>
                
                    <option value="1647" data-chained="ID">
                        Bali </option>
                
                    <option value="3723" data-chained="TR">
                        Balikesir </option>
                
                    <option value="3685" data-chained="TM">
                        Balkan </option>
                
                    <option value="41" data-chained="AF">
                        Balkh </option>
                
                    <option value="1260" data-chained="GB">
                        Ballymena </option>
                
                    <option value="1261" data-chained="GB">
                        Ballymoney </option>
                
                    <option value="2999" data-chained="PK">
                        Balochistan </option>
                
                    <option value="2217" data-chained="MD">
                        Balti </option>
                
                    <option value="2128" data-chained="LV">
                        Balvu </option>
                
                    <option value="2058" data-chained="LI">
                        Balzers </option>
                
                    <option value="291" data-chained="BF">
                        Bam </option>
                
                    <option value="2357" data-chained="ML">
                        Bamako </option>
                
                    <option value="18" data-chained="AF">
                        Bamian </option>
                
                    <option value="544" data-chained="CF">
                        Bamingui-Bangoran </option>
                
                    <option value="3513" data-chained="SO">
                        Banaadir </option>
                
                    <option value="1262" data-chained="GB">
                        Banbridge </option>
                
                    <option value="216" data-chained="BD">
                        Bandarban </option>
                
                    <option value="532" data-chained="CD">
                        Bandundu </option>
                
                    <option value="2166" data-chained="LY">
                        Banghazi </option>
                
                    <option value="621" data-chained="CI">
                        Bangolo </option>
                
                    <option value="560" data-chained="CF">
                        Bangui </option>
                
                    <option value="997" data-chained="EG">
                        Bani Suwayf </option>
                
                    <option value="1420" data-chained="GM">
                        Banjul </option>
                
                    <option value="3481" data-chained="SK">
                        Banska Bystrica </option>
                
                    <option value="1673" data-chained="ID">
                        Banten </option>
                
                    <option value="303" data-chained="BF">
                        Banwa </option>
                
                    <option value="3697" data-chained="TN">
                        Banzart </option>
                
                    <option value="860" data-chained="DO">
                        Baoruco </option>
                
                    <option value="861" data-chained="DO">
                        Barahona </option>
                
                    <option value="1608" data-chained="HU">
                        Baranya </option>
                
                    <option value="47" data-chained="AG">
                        Barbuda </option>
                
                    <option value="145" data-chained="AZ">
                        Barda </option>
                
                    <option value="224" data-chained="BD">
                        Barguna </option>
                
                    <option value="3514" data-chained="SO">
                        Bari </option>
                
                    <option value="1549" data-chained="GY">
                        Barima-Waini </option>
                
                    <option value="4007" data-chained="VE">
                        Barinas </option>
                
                    <option value="215" data-chained="BD">
                        Barisal </option>
                
                    <option value="1108" data-chained="GB">
                        Barking and Dagenham </option>
                
                    <option value="1109" data-chained="GB">
                        Barnet </option>
                
                    <option value="1110" data-chained="GB">
                        Barnsley </option>
                
                    <option value="3790" data-chained="TR">
                        Bartin </option>
                
                    <option value="539" data-chained="CD">
                        Bas-Congo </option>
                
                    <option value="573" data-chained="CH">
                        Basel-Landschaft </option>
                
                    <option value="574" data-chained="CH">
                        Basel-Stadt </option>
                
                    <option value="3169" data-chained="RU">
                        Bashkortostan </option>
                
                    <option value="2886" data-chained="PH">
                        Basilan </option>
                
                    <option value="2940" data-chained="PH">
                        Basilan City </option>
                
                    <option value="1827" data-chained="IT">
                        Basilicata </option>
                
                    <option value="3591" data-chained="TG">
                        Bassar </option>
                
                    <option value="545" data-chained="CF">
                        Basse-Kotto </option>
                
                    <option value="1056" data-chained="FR">
                        Basse-Normandie </option>
                
                    <option value="2871" data-chained="PH">
                        Bataan </option>
                
                    <option value="2872" data-chained="PH">
                        Batanes </option>
                
                    <option value="2873" data-chained="PH">
                        Batangas </option>
                
                    <option value="2941" data-chained="PH">
                        Batangas City </option>
                
                    <option value="1949" data-chained="KH">
                        Batdambang </option>
                
                    <option value="1111" data-chained="GB">
                        Bath and North East Somerset </option>
                
                    <option value="3573" data-chained="TD">
                        Batha </option>
                
                    <option value="1930" data-chained="KG">
                        Batken </option>
                
                    <option value="3779" data-chained="TR">
                        Batman </option>
                
                    <option value="890" data-chained="DZ">
                        Batna </option>
                
                    <option value="2072" data-chained="LK">
                        Batticaloa </option>
                
                    <option value="2607" data-chained="NG">
                        Bauchi </option>
                
                    <option value="2129" data-chained="LV">
                        Bauskas </option>
                
                    <option value="3515" data-chained="SO">
                        Bay </option>
                
                    <option value="2700" data-chained="NZ">
                        Bay of Islands </option>
                
                    <option value="2383" data-chained="MN">
                        Bayan-Olgiy </option>
                
                    <option value="2382" data-chained="MN">
                        Bayanhongor </option>
                
                    <option value="3780" data-chained="TR">
                        Bayburt </option>
                
                    <option value="2613" data-chained="NG">
                        Bayelsa </option>
                
                    <option value="815" data-chained="DE">
                        Bayern </option>
                
                    <option value="2018" data-chained="KZ">
                        Bayqonyr </option>
                
                    <option value="304" data-chained="BF">
                        Bazega </option>
                
                    <option value="3288" data-chained="SC">
                        Beau Vallon </option>
                
                    <option value="918" data-chained="DZ">
                        Bechar </option>
                
                    <option value="1112" data-chained="GB">
                        Bedfordshire </option>
                
                    <option value="697" data-chained="CN">
                        Beijing </option>
                
                    <option value="3072" data-chained="PT">
                        Beja </option>
                
                    <option value="900" data-chained="DZ">
                        Bejaia </option>
                
                    <option value="1609" data-chained="HU">
                        Bekes </option>
                
                    <option value="1632" data-chained="HU">
                        Bekescsaba </option>
                
                    <option value="3289" data-chained="SC">
                        Bel Air </option>
                
                    <option value="3290" data-chained="SC">
                        Bel Ombre </option>
                
                    <option value="410" data-chained="BN">
                        Belait </option>
                
                    <option value="2236" data-chained="MK">
                        Belcista </option>
                
                    <option value="1263" data-chained="GB">
                        Belfast </option>
                
                    <option value="3170" data-chained="RU">
                        Belgorod </option>
                
                    <option value="513" data-chained="BZ">
                        Belize </option>
                
                    <option value="3341" data-chained="SI">
                        Beltinci </option>
                
                    <option value="2178" data-chained="MA">
                        Ben Slimane </option>
                
                    <option value="4029" data-chained="VN">
                        Ben Tre </option>
                
                    <option value="1648" data-chained="ID">
                        Bengkulu </option>
                
                    <option value="92" data-chained="AO">
                        Bengo </option>
                
                    <option value="77" data-chained="AO">
                        Benguela </option>
                
                    <option value="2874" data-chained="PH">
                        Benguet </option>
                
                    <option value="2179" data-chained="MA">
                        Beni Mellal </option>
                
                    <option value="1029" data-chained="ET">
                        Benishangul </option>
                
                    <option value="2590" data-chained="NG">
                        Benue </option>
                
                    <option value="622" data-chained="CI">
                        Beoumi </option>
                
                    <option value="2041" data-chained="LB">
                        Beqaa </option>
                
                    <option value="54" data-chained="AL">
                        Berat </option>
                
                    <option value="2103" data-chained="LS">
                        Berea </option>
                
                    <option value="1086" data-chained="GB">
                        Berkshire </option>
                
                    <option value="829" data-chained="DE">
                        Berlin </option>
                
                    <option value="575" data-chained="CH">
                        Bern </option>
                
                    <option value="2237" data-chained="MK">
                        Berovo </option>
                
                    <option value="2537" data-chained="NA">
                        Bethanien </option>
                
                    <option value="1113" data-chained="GB">
                        Bexley </option>
                
                    <option value="1426" data-chained="GN">
                        Beyla </option>
                
                    <option value="146" data-chained="AZ">
                        Beylaqan </option>
                
                    <option value="2043" data-chained="LB">
                        Beyrouth </option>
                
                    <option value="2670" data-chained="NP">
                        Bheri </option>
                
                    <option value="222" data-chained="BD">
                        Bhola </option>
                
                    <option value="3006" data-chained="PL">
                        Biala Podlaska </option>
                
                    <option value="3007" data-chained="PL">
                        Bialystok </option>
                
                    <option value="601" data-chained="CI">
                        Biankouma </option>
                
                    <option value="78" data-chained="AO">
                        Bie </option>
                
                    <option value="3008" data-chained="PL">
                        Bielsko </option>
                
                    <option value="1737" data-chained="IN">
                        Bihar </option>
                
                    <option value="3124" data-chained="RO">
                        Bihor </option>
                
                    <option value="147" data-chained="AZ">
                        Bilasuvar </option>
                
                    <option value="3724" data-chained="TR">
                        Bilecik </option>
                
                    <option value="3574" data-chained="TD">
                        Biltine </option>
                
                    <option value="457" data-chained="BS">
                        Bimini </option>
                
                    <option value="3701" data-chained="TN">
                        Bin </option>
                
                    <option value="3725" data-chained="TR">
                        Bingol </option>
                
                    <option value="4056" data-chained="VN">
                        Binh Dinh </option>
                
                    <option value="4057" data-chained="VN">
                        Binh Thuan </option>
                
                    <option value="1033" data-chained="ET">
                        Binshangul Gumuz </option>
                
                    <option value="659" data-chained="CL">
                        Bio-Bio </option>
                
                    <option value="1461" data-chained="GQ">
                        Bioko Norte </option>
                
                    <option value="1462" data-chained="GQ">
                        Bioko Sur </option>
                
                    <option value="1548" data-chained="GW">
                        Biombo </option>
                
                    <option value="1114" data-chained="GB">
                        Birmingham </option>
                
                    <option value="1923" data-chained="KG">
                        Bishkek </option>
                
                    <option value="901" data-chained="DZ">
                        Biskra </option>
                
                    <option value="1547" data-chained="GW">
                        Bissau </option>
                
                    <option value="2238" data-chained="MK">
                        Bistrica </option>
                
                    <option value="3125" data-chained="RO">
                        Bistrita-Nasaud </option>
                
                    <option value="3726" data-chained="TR">
                        Bitlis </option>
                
                    <option value="2239" data-chained="MK">
                        Bitola </option>
                
                    <option value="1577" data-chained="HR">
                        Bjelovarsko-Bilogorska </option>
                
                    <option value="2422" data-chained="MU">
                        Black River </option>
                
                    <option value="1115" data-chained="GB">
                        Blackburn with Darwen </option>
                
                    <option value="1116" data-chained="GB">
                        Blackpool </option>
                
                    <option value="1316" data-chained="GB">
                        Blaenau Gwent </option>
                
                    <option value="337" data-chained="BG">
                        Blagoevgrad </option>
                
                    <option value="785" data-chained="CZ">
                        Blansko </option>
                
                    <option value="2473" data-chained="MW">
                        Blantyre </option>
                
                    <option value="2240" data-chained="MK">
                        Blatec </option>
                
                    <option value="3342" data-chained="SI">
                        Bled </option>
                
                    <option value="3312" data-chained="SE">
                        Blekinge Lan </option>
                
                    <option value="902" data-chained="DZ">
                        Blida </option>
                
                    <option value="763" data-chained="CV">
                        Boa Vista </option>
                
                    <option value="2619" data-chained="NI">
                        Boaco </option>
                
                    <option value="645" data-chained="CI">
                        Bocanda </option>
                
                    <option value="2810" data-chained="PA">
                        Bocas del Toro </option>
                
                    <option value="2688" data-chained="NR">
                        Boe </option>
                
                    <option value="2539" data-chained="NA">
                        Boesmanland </option>
                
                    <option value="1427" data-chained="GN">
                        Boffa </option>
                
                    <option value="2241" data-chained="MK">
                        Bogdanci </option>
                
                    <option value="2242" data-chained="MK">
                        Bogomila </option>
                
                    <option value="2243" data-chained="MK">
                        Bogovinje </option>
                
                    <option value="223" data-chained="BD">
                        Bogra </option>
                
                    <option value="3343" data-chained="SI">
                        Bohinj </option>
                
                    <option value="2875" data-chained="PH">
                        Bohol </option>
                
                    <option value="1428" data-chained="GN">
                        Boke </option>
                
                    <option value="1543" data-chained="GW">
                        Bolama </option>
                
                    <option value="4008" data-chained="VE">
                        Bolivar </option>
                
                    <option value="939" data-chained="EC">
                        Bolivar </option>
                
                    <option value="737" data-chained="CO">
                        Bolivar </option>
                
                    <option value="1354" data-chained="GE">
                        Bolnisis Raioni </option>
                
                    <option value="1117" data-chained="GB">
                        Bolton </option>
                
                    <option value="3727" data-chained="TR">
                        Bolu </option>
                
                    <option value="623" data-chained="CI">
                        Bondoukou </option>
                
                    <option value="2093" data-chained="LR">
                        Bong </option>
                
                    <option value="613" data-chained="CI">
                        Bongouanou </option>
                
                    <option value="3093" data-chained="PY">
                        Boqueron </option>
                
                    <option value="919" data-chained="DZ">
                        Bordj Bou Arreridj </option>
                
                    <option value="1795" data-chained="IS">
                        Borgarfjardarsysla </option>
                
                    <option value="3498" data-chained="SM">
                        Borgo Maggiore </option>
                
                    <option value="395" data-chained="BJ">
                        Borgou </option>
                
                    <option value="1355" data-chained="GE">
                        Borjomis Raioni </option>
                
                    <option value="3575" data-chained="TD">
                        Borkou-Ennedi-Tibesti </option>
                
                    <option value="835" data-chained="DK">
                        Bornholm </option>
                
                    <option value="2591" data-chained="NG">
                        Borno </option>
                
                    <option value="3344" data-chained="SI">
                        Borovnica </option>
                
                    <option value="1610" data-chained="HU">
                        Borsod-Abauj-Zemplen </option>
                
                    <option value="2244" data-chained="MK">
                        Bosilovo </option>
                
                    <option value="3126" data-chained="RO">
                        Botosani </option>
                
                    <option value="624" data-chained="CI">
                        Bouafle </option>
                
                    <option value="625" data-chained="CI">
                        Bouake </option>
                
                    <option value="561" data-chained="CG">
                        Bouenza </option>
                
                    <option value="305" data-chained="BF">
                        Bougouriba </option>
                
                    <option value="903" data-chained="DZ">
                        Bouira </option>
                
                    <option value="2180" data-chained="MA">
                        Boulemane </option>
                
                    <option value="306" data-chained="BF">
                        Boulgou </option>
                
                    <option value="292" data-chained="BF">
                        Boulkiemde </option>
                
                    <option value="920" data-chained="DZ">
                        Boumerdes </option>
                
                    <option value="602" data-chained="CI">
                        Bouna </option>
                
                    <option value="603" data-chained="CI">
                        Boundiali </option>
                
                    <option value="1057" data-chained="FR">
                        Bourgogne </option>
                
                    <option value="1118" data-chained="GB">
                        Bournemouth </option>
                
                    <option value="3345" data-chained="SI">
                        Bovec </option>
                
                    <option value="738" data-chained="CO">
                        Boyaca </option>
                
                    <option value="280" data-chained="BE">
                        Brabant </option>
                
                    <option value="288" data-chained="BE">
                        Brabant Wallon </option>
                
                    <option value="1119" data-chained="GB">
                        Bracknell Forest </option>
                
                    <option value="1120" data-chained="GB">
                        Bradford </option>
                
                    <option value="3073" data-chained="PT">
                        Braga </option>
                
                    <option value="3074" data-chained="PT">
                        Braganca </option>
                
                    <option value="225" data-chained="BD">
                        Brahmanbaria </option>
                
                    <option value="3127" data-chained="RO">
                        Braila </option>
                
                    <option value="2411" data-chained="MR">
                        Brakna </option>
                
                    <option value="824" data-chained="DE">
                        Brandenburg </option>
                
                    <option value="3128" data-chained="RO">
                        Brasov </option>
                
                    <option value="3482" data-chained="SK">
                        Bratislava </option>
                
                    <option value="764" data-chained="CV">
                        Brava </option>
                
                    <option value="570" data-chained="CG">
                        Brazzaville </option>
                
                    <option value="3346" data-chained="SI">
                        Brda </option>
                
                    <option value="786" data-chained="CZ">
                        Breclav </option>
                
                    <option value="816" data-chained="DE">
                        Bremen </option>
                
                    <option value="1121" data-chained="GB">
                        Brent </option>
                
                    <option value="506" data-chained="BY">
                        Brestskaya Voblasts' </option>
                
                    <option value="1058" data-chained="FR">
                        Bretagne </option>
                
                    <option value="3347" data-chained="SI">
                        Brezice </option>
                
                    <option value="3348" data-chained="SI">
                        Brezovica </option>
                
                    <option value="1317" data-chained="GB">
                        Bridgend </option>
                
                    <option value="1122" data-chained="GB">
                        Brighton and Hove </option>
                
                    <option value="1123" data-chained="GB">
                        Bristol, City of </option>
                
                    <option value="520" data-chained="CA">
                        British Columbia </option>
                
                    <option value="1578" data-chained="HR">
                        Brodsko-Posavska </option>
                
                    <option value="3528" data-chained="SR">
                        Brokopondo </option>
                
                    <option value="1124" data-chained="GB">
                        Bromley </option>
                
                    <option value="1409" data-chained="GH">
                        Brong-Ahafo </option>
                
                    <option value="2701" data-chained="NZ">
                        Bruce </option>
                
                    <option value="411" data-chained="BN">
                        Brunei and Muara </option>
                
                    <option value="289" data-chained="BE">
                        Brussels Hoofdstedelijk Gewest </option>
                
                    <option value="2245" data-chained="MK">
                        Brvenica </option>
                
                    <option value="3171" data-chained="RU">
                        Bryansk </option>
                
                    <option value="2689" data-chained="NR">
                        Buada </option>
                
                    <option value="378" data-chained="BI">
                        Bubanza </option>
                
                    <option value="1125" data-chained="GB">
                        Buckinghamshire </option>
                
                    <option value="3129" data-chained="RO">
                        Bucuresti </option>
                
                    <option value="1611" data-chained="HU">
                        Budapest </option>
                
                    <option value="94" data-chained="AR">
                        Buenos Aires </option>
                
                    <option value="3877" data-chained="UG">
                        Bugiri </option>
                
                    <option value="377" data-chained="BI">
                        Bujumbura </option>
                
                    <option value="3985" data-chained="UZ">
                        Bukhoro </option>
                
                    <option value="2876" data-chained="PH">
                        Bukidnon </option>
                
                    <option value="2877" data-chained="PH">
                        Bulacan </option>
                
                    <option value="4147" data-chained="ZW">
                        Bulawayo </option>
                
                    <option value="2400" data-chained="MN">
                        Bulgan </option>
                
                    <option value="2702" data-chained="NZ">
                        Buller </option>
                
                    <option value="478" data-chained="BT">
                        Bumthang </option>
                
                    <option value="998" data-chained="EG">
                        Bur Sa'id </option>
                
                    <option value="3728" data-chained="TR">
                        Burdur </option>
                
                    <option value="338" data-chained="BG">
                        Burgas </option>
                
                    <option value="118" data-chained="AT">
                        Burgenland </option>
                
                    <option value="3634" data-chained="TH">
                        Buriram </option>
                
                    <option value="3729" data-chained="TR">
                        Bursa </option>
                
                    <option value="379" data-chained="BI">
                        Bururi </option>
                
                    <option value="1126" data-chained="GB">
                        Bury </option>
                
                    <option value="3172" data-chained="RU">
                        Buryat </option>
                
                    <option value="1774" data-chained="IR">
                        Bushehr </option>
                
                    <option value="3878" data-chained="UG">
                        Busia </option>
                
                    <option value="2652" data-chained="NO">
                        Buskerud </option>
                
                    <option value="3865" data-chained="UG">
                        Busoga </option>
                
                    <option value="3251" data-chained="RW">
                        Butare </option>
                
                    <option value="2104" data-chained="LS">
                        Butha-Buthe </option>
                
                    <option value="2942" data-chained="PH">
                        Butuan </option>
                
                    <option value="3130" data-chained="RO">
                        Buzau </option>
                
                    <option value="3009" data-chained="PL">
                        Bydgoszcz </option>
                
                    <option value="3252" data-chained="RW">
                        Byumba </option>
                
                    <option value="3094" data-chained="PY">
                        Caaguazu </option>
                
                    <option value="3095" data-chained="PY">
                        Caazapa </option>
                
                    <option value="3541" data-chained="SV">
                        Cabanas </option>
                
                    <option value="2943" data-chained="PH">
                        Cabanatuan </option>
                
                    <option value="79" data-chained="AO">
                        Cabinda </option>
                
                    <option value="2527" data-chained="MZ">
                        Cabo Delgado </option>
                
                    <option value="148" data-chained="AZ">
                        Cabrayil </option>
                
                    <option value="1544" data-chained="GW">
                        Cacheu </option>
                
                    <option value="2944" data-chained="PH">
                        Cadiz </option>
                
                    <option value="1318" data-chained="GB">
                        Caerphilly </option>
                
                    <option value="2878" data-chained="PH">
                        Cagayan </option>
                
                    <option value="2945" data-chained="PH">
                        Cagayan de Oro </option>
                
                    <option value="2218" data-chained="MD">
                        Cahul </option>
                
                    <option value="2246" data-chained="MK">
                        Cair </option>
                
                    <option value="2825" data-chained="PE">
                        Cajamarca </option>
                
                    <option value="1828" data-chained="IT">
                        Calabria </option>
                
                    <option value="3159" data-chained="RO">
                        Calarasi </option>
                
                    <option value="2946" data-chained="PH">
                        Calbayog </option>
                
                    <option value="739" data-chained="CO">
                        Caldas </option>
                
                    <option value="1127" data-chained="GB">
                        Calderdale </option>
                
                    <option value="3911" data-chained="US" selected="">
                        California </option>
                
                    <option value="149" data-chained="AZ">
                        Calilabad </option>
                
                    <option value="2826" data-chained="PE">
                        Callao </option>
                
                    <option value="2947" data-chained="PH">
                        Caloocan </option>
                
                    <option value="752" data-chained="CU">
                        Camaguey </option>
                
                    <option value="2879" data-chained="PH">
                        Camarines Norte </option>
                
                    <option value="2880" data-chained="PH">
                        Camarines Sur </option>
                
                    <option value="1128" data-chained="GB">
                        Cambridgeshire </option>
                
                    <option value="1129" data-chained="GB">
                        Camden </option>
                
                    <option value="2881" data-chained="PH">
                        Camiguin </option>
                
                    <option value="1829" data-chained="IT">
                        Campania </option>
                
                    <option value="2483" data-chained="MX">
                        Campeche </option>
                
                    <option value="4058" data-chained="VN">
                        Can Tho </option>
                
                    <option value="3730" data-chained="TR">
                        Canakkale </option>
                
                    <option value="940" data-chained="EC">
                        Canar </option>
                
                    <option value="1015" data-chained="ES">
                        Canarias </option>
                
                    <option value="3966" data-chained="UY">
                        Canelones </option>
                
                    <option value="1" data-chained="AD">
                        Canillo </option>
                
                    <option value="3106" data-chained="PY">
                        Canindeyu </option>
                
                    <option value="3785" data-chained="TR">
                        Cankiri </option>
                
                    <option value="380" data-chained="BI">
                        Cankuzo </option>
                
                    <option value="2948" data-chained="PH">
                        Canlaon </option>
                
                    <option value="1012" data-chained="ES">
                        Cantabria </option>
                
                    <option value="4030" data-chained="VN">
                        Cao Bang </option>
                
                    <option value="2247" data-chained="MK">
                        Capari </option>
                
                    <option value="2882" data-chained="PH">
                        Capiz </option>
                
                    <option value="2563" data-chained="NA">
                        Caprivi </option>
                
                    <option value="2538" data-chained="NA">
                        Caprivi Oos </option>
                
                    <option value="712" data-chained="CO">
                        Caqueta </option>
                
                    <option value="4009" data-chained="VE">
                        Carabobo </option>
                
                    <option value="3131" data-chained="RO">
                        Caras-Severin </option>
                
                    <option value="2620" data-chained="NI">
                        Carazo </option>
                
                    <option value="941" data-chained="EC">
                        Carchi </option>
                
                    <option value="1319" data-chained="GB">
                        Cardiff </option>
                
                    <option value="2432" data-chained="MU">
                        Cargados Carajos </option>
                
                    <option value="1676" data-chained="IE">
                        Carlow </option>
                
                    <option value="1321" data-chained="GB">
                        Carmarthenshire </option>
                
                    <option value="3798" data-chained="TT">
                        Caroni </option>
                
                    <option value="1264" data-chained="GB">
                        Carrickfergus </option>
                
                    <option value="742" data-chained="CR">
                        Cartago </option>
                
                    <option value="2181" data-chained="MA">
                        Casablanca </option>
                
                    <option value="734" data-chained="CO">
                        Casanare </option>
                
                    <option value="3291" data-chained="SC">
                        Cascade </option>
                
                    <option value="2248" data-chained="MK">
                        Caska </option>
                
                    <option value="3075" data-chained="PT">
                        Castelo Branco </option>
                
                    <option value="1017" data-chained="ES">
                        Castilla y Leon </option>
                
                    <option value="1016" data-chained="ES">
                        Castilla-La Mancha </option>
                
                    <option value="1265" data-chained="GB">
                        Castlereagh </option>
                
                    <option value="2049" data-chained="LC">
                        Castries </option>
                
                    <option value="458" data-chained="BS">
                        Cat Island </option>
                
                    <option value="1018" data-chained="ES">
                        Catalonia </option>
                
                    <option value="95" data-chained="AR">
                        Catamarca </option>
                
                    <option value="2883" data-chained="PH">
                        Catanduanes </option>
                
                    <option value="713" data-chained="CO">
                        Cauca </option>
                
                    <option value="1677" data-chained="IE">
                        Cavan </option>
                
                    <option value="2884" data-chained="PH">
                        Cavite </option>
                
                    <option value="2949" data-chained="PH">
                        Cavite City </option>
                
                    <option value="514" data-chained="BZ">
                        Cayo </option>
                
                    <option value="435" data-chained="BR">
                        Ceara </option>
                
                    <option value="2885" data-chained="PH">
                        Cebu </option>
                
                    <option value="2950" data-chained="PH">
                        Cebu City </option>
                
                    <option value="2249" data-chained="MK">
                        Cegrane </option>
                
                    <option value="3349" data-chained="SI">
                        Celje </option>
                
                    <option value="2250" data-chained="MK">
                        Centar </option>
                
                    <option value="2251" data-chained="MK">
                        Centar Zupa </option>
                
                    <option value="1045" data-chained="FJ">
                        Central </option>
                
                    <option value="3096" data-chained="PY">
                        Central </option>
                
                    <option value="3868" data-chained="UG">
                        Central </option>
                
                    <option value="2845" data-chained="PG">
                        Central </option>
                
                    <option value="4131" data-chained="ZM">
                        Central </option>
                
                    <option value="1097" data-chained="GB">
                        Central </option>
                
                    <option value="1915" data-chained="KE">
                        Central </option>
                
                    <option value="1410" data-chained="GH">
                        Central </option>
                
                    <option value="3276" data-chained="SB">
                        Central </option>
                
                    <option value="496" data-chained="BW">
                        Central </option>
                
                    <option value="1059" data-chained="FR">
                        Centre </option>
                
                    <option value="1600" data-chained="HT">
                        Centre </option>
                
                    <option value="673" data-chained="CM">
                        Centre </option>
                
                    <option value="1463" data-chained="GQ">
                        Centro Sur </option>
                
                    <option value="1320" data-chained="GB">
                        Ceredigion </option>
                
                    <option value="3350" data-chained="SI">
                        Cerklje na Gorenjskem </option>
                
                    <option value="3351" data-chained="SI">
                        Cerknica </option>
                
                    <option value="3352" data-chained="SI">
                        Cerkno </option>
                
                    <option value="3967" data-chained="UY">
                        Cerro Largo </option>
                
                    <option value="714" data-chained="CO">
                        Cesar </option>
                
                    <option value="2252" data-chained="MK">
                        Cesinovo </option>
                
                    <option value="1357" data-chained="GE">
                        Ch'khorotsqus Raioni </option>
                
                    <option value="1358" data-chained="GE">
                        Ch'okhatauris Raioni </option>
                
                    <option value="1986" data-chained="KR">
                        Ch'ungch'ong-bukto </option>
                
                    <option value="1995" data-chained="KR">
                        Ch'ungch'ong-namdo </option>
                
                    <option value="3650" data-chained="TH">
                        Chachoengsao </option>
                
                    <option value="3107" data-chained="PY">
                        Chaco </option>
                
                    <option value="96" data-chained="AR">
                        Chaco </option>
                
                    <option value="1971" data-chained="KP">
                        Chagang-do </option>
                
                    <option value="1763" data-chained="IR">
                        Chahar Mahall va Bakhtiari </option>
                
                    <option value="3638" data-chained="TH">
                        Chai Nat </option>
                
                    <option value="3632" data-chained="TH">
                        Chaiyaphum </option>
                
                    <option value="3542" data-chained="SV">
                        Chalatenango </option>
                
                    <option value="1060" data-chained="FR">
                        Champagne-Ardenne </option>
                
                    <option value="2029" data-chained="LA">
                        Champasak </option>
                
                    <option value="1711" data-chained="IN">
                        Chandigarh </option>
                
                    <option value="226" data-chained="BD">
                        Chandpur </option>
                
                    <option value="3654" data-chained="TH">
                        Chanthaburi </option>
                
                    <option value="2182" data-chained="MA">
                        Chaouen </option>
                
                    <option value="227" data-chained="BD">
                        Chapai Nawabganj </option>
                
                    <option value="3576" data-chained="TD">
                        Chari-Baguirmi </option>
                
                    <option value="3997" data-chained="VC">
                        Charlotte </option>
                
                    <option value="2703" data-chained="NZ">
                        Chatham Islands </option>
                
                    <option value="228" data-chained="BD">
                        Chattagram </option>
                
                    <option value="3173" data-chained="RU">
                        Chechnya </option>
                
                    <option value="1984" data-chained="KR">
                        Cheju-do </option>
                
                    <option value="3010" data-chained="PL">
                        Chelm </option>
                
                    <option value="3174" data-chained="RU">
                        Chelyabinsk </option>
                
                    <option value="3838" data-chained="UA">
                        Cherkas'ka Oblast' </option>
                
                    <option value="3839" data-chained="UA">
                        Chernihivs'ka Oblast' </option>
                
                    <option value="3840" data-chained="UA">
                        Chernivets'ka Oblast' </option>
                
                    <option value="1130" data-chained="GB">
                        Cheshire </option>
                
                    <option value="2704" data-chained="NZ">
                        Cheviot </option>
                
                    <option value="1740" data-chained="IN">
                        Chhattisgarh </option>
                
                    <option value="479" data-chained="BT">
                        Chhukha </option>
                
                    <option value="3609" data-chained="TH">
                        Chiang Mai </option>
                
                    <option value="3610" data-chained="TH">
                        Chiang Rai </option>
                
                    <option value="2484" data-chained="MX">
                        Chiapas </option>
                
                    <option value="1356" data-chained="GE">
                        Chiat'ura </option>
                
                    <option value="1871" data-chained="JP">
                        Chiba </option>
                
                    <option value="3494" data-chained="SM">
                        Chiesanuova </option>
                
                    <option value="2485" data-chained="MX">
                        Chihuahua </option>
                
                    <option value="2453" data-chained="MW">
                        Chikwawa </option>
                
                    <option value="1520" data-chained="GT">
                        Chimaltenango </option>
                
                    <option value="942" data-chained="EC">
                        Chimborazo </option>
                
                    <option value="2852" data-chained="PG">
                        Chimbu </option>
                
                    <option value="2367" data-chained="MM">
                        Chin State </option>
                
                    <option value="2621" data-chained="NI">
                        Chinandega </option>
                
                    <option value="1521" data-chained="GT">
                        Chiquimula </option>
                
                    <option value="2454" data-chained="MW">
                        Chiradzulu </option>
                
                    <option value="480" data-chained="BT">
                        Chirang </option>
                
                    <option value="2811" data-chained="PA">
                        Chiriqui </option>
                
                    <option value="2219" data-chained="MD">
                        Chisinau </option>
                
                    <option value="3175" data-chained="RU">
                        Chita </option>
                
                    <option value="2455" data-chained="MW">
                        Chitipa </option>
                
                    <option value="921" data-chained="DZ">
                        Chlef </option>
                
                    <option value="497" data-chained="BW">
                        Chobe </option>
                
                    <option value="715" data-chained="CO">
                        Choco </option>
                
                    <option value="2050" data-chained="LC">
                        Choiseul </option>
                
                    <option value="1985" data-chained="KR">
                        Cholla-bukto </option>
                
                    <option value="1994" data-chained="KR">
                        Cholla-namdo </option>
                
                    <option value="1560" data-chained="HN">
                        Choluteca </option>
                
                    <option value="3652" data-chained="TH">
                        Chon Buri </option>
                
                    <option value="707" data-chained="CN">
                        Chongqing </option>
                
                    <option value="2622" data-chained="NI">
                        Chontales </option>
                
                    <option value="204" data-chained="BB">
                        Christ Church </option>
                
                    <option value="1957" data-chained="KN">
                        Christ Church Nichola Town </option>
                
                    <option value="229" data-chained="BD">
                        Chuadanga </option>
                
                    <option value="97" data-chained="AR">
                        Chubut </option>
                
                    <option value="3176" data-chained="RU">
                        Chukot </option>
                
                    <option value="3664" data-chained="TH">
                        Chumphon </option>
                
                    <option value="421" data-chained="BO">
                        Chuquisaca </option>
                
                    <option value="1052" data-chained="FM">
                        Chuuk </option>
                
                    <option value="3177" data-chained="RU">
                        Chuvashia </option>
                
                    <option value="1924" data-chained="KG">
                        Chuy </option>
                
                    <option value="381" data-chained="BI">
                        Cibitoke </option>
                
                    <option value="3011" data-chained="PL">
                        Ciechanow </option>
                
                    <option value="753" data-chained="CU">
                        Ciego de Avila </option>
                
                    <option value="754" data-chained="CU">
                        Cienfuegos </option>
                
                    <option value="749" data-chained="CU">
                        Ciudad de la Habana </option>
                
                    <option value="1288" data-chained="GB">
                        Clackmannanshire </option>
                
                    <option value="1678" data-chained="IE">
                        Clare </option>
                
                    <option value="1846" data-chained="JM">
                        Clarendon </option>
                
                    <option value="1087" data-chained="GB">
                        Cleveland </option>
                
                    <option value="2705" data-chained="NZ">
                        Clifton </option>
                
                    <option value="3132" data-chained="RO">
                        Cluj </option>
                
                    <option value="2706" data-chained="NZ">
                        Clutha </option>
                
                    <option value="1102" data-chained="GB">
                        Clwyd </option>
                
                    <option value="2486" data-chained="MX">
                        Coahuila de Zaragoza </option>
                
                    <option value="1916" data-chained="KE">
                        Coast </option>
                
                    <option value="422" data-chained="BO">
                        Cochabamba </option>
                
                    <option value="2812" data-chained="PA">
                        Cocle </option>
                
                    <option value="3076" data-chained="PT">
                        Coimbra </option>
                
                    <option value="4010" data-chained="VE">
                        Cojedes </option>
                
                    <option value="1266" data-chained="GB">
                        Coleraine </option>
                
                    <option value="2487" data-chained="MX">
                        Colima </option>
                
                    <option value="413" data-chained="BN">
                        Collines </option>
                
                    <option value="2087" data-chained="LK">
                        Colombo </option>
                
                    <option value="1561" data-chained="HN">
                        Colon </option>
                
                    <option value="2813" data-chained="PA">
                        Colon </option>
                
                    <option value="3968" data-chained="UY">
                        Colonia </option>
                
                    <option value="3912" data-chained="US">
                        Colorado </option>
                
                    <option value="1562" data-chained="HN">
                        Comayagua </option>
                
                    <option value="217" data-chained="BD">
                        Comilla </option>
                
                    <option value="3529" data-chained="SR">
                        Commewijne </option>
                
                    <option value="1022" data-chained="ES">
                        Comunidad Valenciana </option>
                
                    <option value="1429" data-chained="GN">
                        Conakry </option>
                
                    <option value="3097" data-chained="PY">
                        Concepcion </option>
                
                    <option value="3913" data-chained="US">
                        Connecticut </option>
                
                    <option value="3133" data-chained="RO">
                        Constanta </option>
                
                    <option value="891" data-chained="DZ">
                        Constantine </option>
                
                    <option value="1322" data-chained="GB">
                        Conwy </option>
                
                    <option value="2707" data-chained="NZ">
                        Cook </option>
                
                    <option value="1267" data-chained="GB">
                        Cookstown </option>
                
                    <option value="1563" data-chained="HN">
                        Copan </option>
                
                    <option value="4137" data-chained="ZM">
                        Copperbelt </option>
                
                    <option value="660" data-chained="CL">
                        Coquimbo </option>
                
                    <option value="3098" data-chained="PY">
                        Cordillera </option>
                
                    <option value="98" data-chained="AR">
                        Cordoba </option>
                
                    <option value="716" data-chained="CO">
                        Cordoba </option>
                
                    <option value="1679" data-chained="IE">
                        Cork </option>
                
                    <option value="1131" data-chained="GB">
                        Cornwall </option>
                
                    <option value="3530" data-chained="SR">
                        Coronie </option>
                
                    <option value="515" data-chained="BZ">
                        Corozal </option>
                
                    <option value="99" data-chained="AR">
                        Corrientes </option>
                
                    <option value="1061" data-chained="FR">
                        Corse </option>
                
                    <option value="1564" data-chained="HN">
                        Cortes </option>
                
                    <option value="3731" data-chained="TR">
                        Corum </option>
                
                    <option value="2951" data-chained="PH">
                        Cotabato </option>
                
                    <option value="943" data-chained="EC">
                        Cotopaxi </option>
                
                    <option value="3134" data-chained="RO">
                        Covasna </option>
                
                    <option value="1132" data-chained="GB">
                        Coventry </option>
                
                    <option value="230" data-chained="BD">
                        Cox's Bazar </option>
                
                    <option value="1450" data-chained="GN">
                        Coyah </option>
                
                    <option value="1268" data-chained="GB">
                        Craigavon </option>
                
                    <option value="2004" data-chained="KY">
                        Creek </option>
                
                    <option value="3353" data-chained="SI">
                        Crensovci </option>
                
                    <option value="3354" data-chained="SI">
                        Crna na Koroskem </option>
                
                    <option value="3355" data-chained="SI">
                        Crnomelj </option>
                
                    <option value="2586" data-chained="NG">
                        Cross River </option>
                
                    <option value="1133" data-chained="GB">
                        Croydon </option>
                
                    <option value="1612" data-chained="HU">
                        Csongrad </option>
                
                    <option value="80" data-chained="AO">
                        Cuando Cubango </option>
                
                    <option value="81" data-chained="AO">
                        Cuanza Norte </option>
                
                    <option value="82" data-chained="AO">
                        Cuanza Sul </option>
                
                    <option value="2253" data-chained="MK">
                        Cucer-Sandevo </option>
                
                    <option value="1134" data-chained="GB">
                        Cumbria </option>
                
                    <option value="735" data-chained="CO">
                        Cundinamarca </option>
                
                    <option value="83" data-chained="AO">
                        Cunene </option>
                
                    <option value="3543" data-chained="SV">
                        Cuscatlan </option>
                
                    <option value="2827" data-chained="PE">
                        Cusco </option>
                
                    <option value="562" data-chained="CG">
                        Cuvette </option>
                
                    <option value="1550" data-chained="GY">
                        Cuyuni-Mazaruni </option>
                
                    <option value="3253" data-chained="RW">
                        Cyangugu </option>
                
                    <option value="3012" data-chained="PL">
                        Czestochowa </option>
                
                    <option value="2444" data-chained="MV">
                        Daalu </option>
                
                    <option value="598" data-chained="CI">
                        Dabakala </option>
                
                    <option value="1430" data-chained="GN">
                        Dabola </option>
                
                    <option value="646" data-chained="CI">
                        Dabou </option>
                
                    <option value="4046" data-chained="VN">
                        Dac Lac </option>
                
                    <option value="1712" data-chained="IN">
                        Dadra and Nagar Haveli </option>
                
                    <option value="481" data-chained="BT">
                        Daga </option>
                
                    <option value="3178" data-chained="RU">
                        Dagestan </option>
                
                    <option value="2952" data-chained="PH">
                        Dagupan </option>
                
                    <option value="1750" data-chained="IQ">
                        Dahuk </option>
                
                    <option value="862" data-chained="DO">
                        Dajabon </option>
                
                    <option value="3502" data-chained="SN">
                        Dakar </option>
                
                    <option value="2414" data-chained="MR">
                        Dakhlet Nouadhibou </option>
                
                    <option value="1431" data-chained="GN">
                        Dalaba </option>
                
                    <option value="3320" data-chained="SE">
                        Dalarnas Lan </option>
                
                    <option value="1796" data-chained="IS">
                        Dalasysla </option>
                
                    <option value="626" data-chained="CI">
                        Daloa </option>
                
                    <option value="1735" data-chained="IN">
                        Daman and Diu </option>
                
                    <option value="2557" data-chained="NA">
                        Damaraland </option>
                
                    <option value="3135" data-chained="RO">
                        Dambovita </option>
                
                    <option value="604" data-chained="CI">
                        Danane </option>
                
                    <option value="2953" data-chained="PH">
                        Danao </option>
                
                    <option value="2708" data-chained="NZ">
                        Dannevirke </option>
                
                    <option value="627" data-chained="CI">
                        Daoukro </option>
                
                    <option value="3592" data-chained="TG">
                        Dapaong </option>
                
                    <option value="2954" data-chained="PH">
                        Dapitan </option>
                
                    <option value="3559" data-chained="SY">
                        Dar </option>
                
                    <option value="3835" data-chained="TZ">
                        Dar es Salaam </option>
                
                    <option value="3309" data-chained="SD">
                        Darfur </option>
                
                    <option value="2384" data-chained="MN">
                        Darhan </option>
                
                    <option value="2402" data-chained="MN">
                        Darhan Uul </option>
                
                    <option value="2814" data-chained="PA">
                        Darien </option>
                
                    <option value="1135" data-chained="GB">
                        Darlington </option>
                
                    <option value="2167" data-chained="LY">
                        Darnah </option>
                
                    <option value="3686" data-chained="TM">
                        Dashoguz </option>
                
                    <option value="150" data-chained="AZ">
                        Daskasan </option>
                
                    <option value="2130" data-chained="LV">
                        Daugavpils </option>
                
                    <option value="2048" data-chained="LC">
                        Dauphin </option>
                
                    <option value="151" data-chained="AZ">
                        Davaci </option>
                
                    <option value="2888" data-chained="PH">
                        Davao </option>
                
                    <option value="2955" data-chained="PH">
                        Davao City </option>
                
                    <option value="2889" data-chained="PH">
                        Davao del Sur </option>
                
                    <option value="2890" data-chained="PH">
                        Davao Oriental </option>
                
                    <option value="3560" data-chained="SY">
                        Dayr az Zawr </option>
                
                    <option value="2254" data-chained="MK">
                        Debar </option>
                
                    <option value="1613" data-chained="HU">
                        Debrecen </option>
                
                    <option value="1359" data-chained="GE">
                        Dedop'listsqaros Raioni </option>
                
                    <option value="2457" data-chained="MW">
                        Dedza </option>
                
                    <option value="3915" data-chained="US">
                        Delaware </option>
                
                    <option value="2255" data-chained="MK">
                        Delcevo </option>
                
                    <option value="1713" data-chained="IN">
                        Delhi </option>
                
                    <option value="2256" data-chained="MK">
                        Delogozdi </option>
                
                    <option value="2598" data-chained="NG">
                        Delta </option>
                
                    <option value="4011" data-chained="VE">
                        Delta Amacuro </option>
                
                    <option value="1551" data-chained="GY">
                        Demerara-Mahaica </option>
                
                    <option value="2257" data-chained="MK">
                        Demir Hisar </option>
                
                    <option value="2258" data-chained="MK">
                        Demir Kapija </option>
                
                    <option value="1323" data-chained="GB">
                        Denbighshire </option>
                
                    <option value="2690" data-chained="NR">
                        Denigomodu </option>
                
                    <option value="3732" data-chained="TR">
                        Denizli </option>
                
                    <option value="2051" data-chained="LC">
                        Dennery </option>
                
                    <option value="4025" data-chained="VE">
                        Dependencias Federales </option>
                
                    <option value="1136" data-chained="GB">
                        Derby </option>
                
                    <option value="1137" data-chained="GB">
                        Derbyshire </option>
                
                    <option value="1275" data-chained="GB">
                        Derry </option>
                
                    <option value="1138" data-chained="GB">
                        Devon </option>
                
                    <option value="399" data-chained="BM">
                        Devonshire </option>
                
                    <option value="231" data-chained="BD">
                        Dhaka </option>
                
                    <option value="4111" data-chained="YE">
                        Dhamar </option>
                
                    <option value="2671" data-chained="NP">
                        Dhawalagiri </option>
                
                    <option value="1751" data-chained="IQ">
                        Dhi Qar </option>
                
                    <option value="1513" data-chained="GR">
                        Dhodhekanisos </option>
                
                    <option value="55" data-chained="AL">
                        Diber </option>
                
                    <option value="2123" data-chained="LU">
                        Diekirch </option>
                
                    <option value="2576" data-chained="NE">
                        Diffa </option>
                
                    <option value="830" data-chained="DJ">
                        Dikhil </option>
                
                    <option value="3566" data-chained="SY">
                        Dimashq </option>
                
                    <option value="647" data-chained="CI">
                        Dimbokro </option>
                
                    <option value="232" data-chained="BD">
                        Dinajpur </option>
                
                    <option value="1432" data-chained="GN">
                        Dinguiraye </option>
                
                    <option value="3503" data-chained="SN">
                        Diourbel </option>
                
                    <option value="2956" data-chained="PH">
                        Dipolog </option>
                
                    <option value="1034" data-chained="ET">
                        Dire Dawa </option>
                
                    <option value="3914" data-chained="US">
                        District of Columbia </option>
                
                    <option value="736" data-chained="CO">
                        Distrito Especial </option>
                
                    <option value="100" data-chained="AR">
                        Distrito Federal </option>
                
                    <option value="436" data-chained="BR">
                        Distrito Federal </option>
                
                    <option value="2488" data-chained="MX">
                        Distrito Federal </option>
                
                    <option value="4026" data-chained="VE">
                        Distrito Federal </option>
                
                    <option value="863" data-chained="DO">
                        Distrito Nacional </option>
                
                    <option value="3356" data-chained="SI">
                        Divaca </option>
                
                    <option value="605" data-chained="CI">
                        Divo </option>
                
                    <option value="1752" data-chained="IQ">
                        Diyala </option>
                
                    <option value="3733" data-chained="TR">
                        Diyarbakir </option>
                
                    <option value="904" data-chained="DZ">
                        Djelfa </option>
                
                    <option value="831" data-chained="DJ">
                        Djibouti </option>
                
                    <option value="1360" data-chained="GE">
                        Dmanisis Raioni </option>
                
                    <option value="3841" data-chained="UA">
                        Dnipropetrovs'ka Oblast' </option>
                
                    <option value="2131" data-chained="LV">
                        Dobeles </option>
                
                    <option value="3357" data-chained="SI">
                        Dobrepolje </option>
                
                    <option value="339" data-chained="BG">
                        Dobrich </option>
                
                    <option value="3456" data-chained="SI">
                        Dobrova-Horjul-Polhov Gradec </option>
                
                    <option value="2259" data-chained="MK">
                        Dobrusevo </option>
                
                    <option value="3815" data-chained="TZ">
                        Dodoma </option>
                
                    <option value="3358" data-chained="SI">
                        Dol pri Ljubljani </option>
                
                    <option value="3136" data-chained="RO">
                        Dolj </option>
                
                    <option value="2260" data-chained="MK">
                        Dolna Banjica </option>
                
                    <option value="2261" data-chained="MK">
                        Dolneni </option>
                
                    <option value="3055" data-chained="PL">
                        Dolnoslaskie </option>
                
                    <option value="3495" data-chained="SM">
                        Domagnano </option>
                
                    <option value="3457" data-chained="SI">
                        Domzale </option>
                
                    <option value="1139" data-chained="GB">
                        Doncaster </option>
                
                    <option value="1680" data-chained="IE">
                        Donegal </option>
                
                    <option value="3842" data-chained="UA">
                        Donets'ka Oblast' </option>
                
                    <option value="4047" data-chained="VN">
                        Dong Nai </option>
                
                    <option value="4048" data-chained="VN">
                        Dong Thap </option>
                
                    <option value="415" data-chained="BN">
                        Donga </option>
                
                    <option value="2262" data-chained="MK">
                        Dorce Petrov </option>
                
                    <option value="3359" data-chained="SI">
                        Dornava </option>
                
                    <option value="2385" data-chained="MN">
                        Dornod </option>
                
                    <option value="2386" data-chained="MN">
                        Dornogovi </option>
                
                    <option value="1140" data-chained="GB">
                        Dorset </option>
                
                    <option value="2577" data-chained="NE">
                        Dosso </option>
                
                    <option value="2458" data-chained="MW">
                        Dowa </option>
                
                    <option value="1269" data-chained="GB">
                        Down </option>
                
                    <option value="1470" data-chained="GR">
                        Drama </option>
                
                    <option value="3360" data-chained="SI">
                        Dravograd </option>
                
                    <option value="2635" data-chained="NL">
                        Drenthe </option>
                
                    <option value="2646" data-chained="NL">
                        Dronten </option>
                
                    <option value="2263" data-chained="MK">
                        Drugovo </option>
                
                    <option value="864" data-chained="DO">
                        Duarte </option>
                
                    <option value="10" data-chained="AE">
                        Dubai </option>
                
                    <option value="1681" data-chained="IE">
                        Dublin </option>
                
                    <option value="1451" data-chained="GN">
                        Dubreka </option>
                
                    <option value="1579" data-chained="HR">
                        Dubrovacko-Neretvanska </option>
                
                    <option value="1141" data-chained="GB">
                        Dudley </option>
                
                    <option value="628" data-chained="CI">
                        Duekoue </option>
                
                    <option value="2957" data-chained="PH">
                        Dumaguete </option>
                
                    <option value="1289" data-chained="GB">
                        Dumfries and Galloway </option>
                
                    <option value="999" data-chained="EG">
                        Dumyat </option>
                
                    <option value="1633" data-chained="HU">
                        Dunaujvaros </option>
                
                    <option value="1290" data-chained="GB">
                        Dundee City </option>
                
                    <option value="2387" data-chained="MN">
                        Dundgovi </option>
                
                    <option value="1270" data-chained="GB">
                        Dungannon </option>
                
                    <option value="3361" data-chained="SI">
                        Duplek </option>
                
                    <option value="2489" data-chained="MX">
                        Durango </option>
                
                    <option value="3969" data-chained="UY">
                        Durazno </option>
                
                    <option value="1142" data-chained="GB">
                        Durham </option>
                
                    <option value="56" data-chained="AL">
                        Durres </option>
                
                    <option value="1361" data-chained="GE">
                        Dushet'is Raioni </option>
                
                    <option value="3796" data-chained="TR">
                        Duzce </option>
                
                    <option value="1103" data-chained="GB">
                        Dyfed </option>
                
                    <option value="2388" data-chained="MN">
                        Dzavhan </option>
                
                    <option value="2264" data-chained="MK">
                        Dzepciste </option>
                
                    <option value="1143" data-chained="GB">
                        Ealing </option>
                
                    <option value="1291" data-chained="GB">
                        East Ayrshire </option>
                
                    <option value="1552" data-chained="GY">
                        East Berbice-Corentyne </option>
                
                    <option value="1292" data-chained="GB">
                        East Dunbartonshire </option>
                
                    <option value="2025" data-chained="KZ">
                        East Kazakhstan </option>
                
                    <option value="1293" data-chained="GB">
                        East Lothian </option>
                
                    <option value="2854" data-chained="PG">
                        East New Britain </option>
                
                    <option value="1294" data-chained="GB">
                        East Renfrewshire </option>
                
                    <option value="1144" data-chained="GB">
                        East Riding of Yorkshire </option>
                
                    <option value="2855" data-chained="PG">
                        East Sepik </option>
                
                    <option value="1145" data-chained="GB">
                        East Sussex </option>
                
                    <option value="1046" data-chained="FJ">
                        Eastern </option>
                
                    <option value="3869" data-chained="UG">
                        Eastern </option>
                
                    <option value="4132" data-chained="ZM">
                        Eastern </option>
                
                    <option value="1917" data-chained="KE">
                        Eastern </option>
                
                    <option value="1411" data-chained="GH">
                        Eastern </option>
                
                    <option value="3489" data-chained="SL">
                        Eastern </option>
                
                    <option value="2005" data-chained="KY">
                        Eastern </option>
                
                    <option value="4123" data-chained="ZA">
                        Eastern Cape </option>
                
                    <option value="1043" data-chained="FI">
                        Eastern Finland </option>
                
                    <option value="2853" data-chained="PG">
                        Eastern Highlands </option>
                
                    <option value="2887" data-chained="PH">
                        Eastern Samar </option>
                
                    <option value="2614" data-chained="NG">
                        Ebonyi </option>
                
                    <option value="1295" data-chained="GB">
                        Edinburgh, City of </option>
                
                    <option value="2221" data-chained="MD">
                        Edinet </option>
                
                    <option value="3734" data-chained="TR">
                        Edirne </option>
                
                    <option value="2599" data-chained="NG">
                        Edo </option>
                
                    <option value="4084" data-chained="VU">
                        Efate </option>
                
                    <option value="1634" data-chained="HU">
                        Eger </option>
                
                    <option value="2709" data-chained="NZ">
                        Egmont </option>
                
                    <option value="1872" data-chained="JP">
                        Ehime </option>
                
                    <option value="1313" data-chained="GB">
                        Eilean Siar </option>
                
                    <option value="2710" data-chained="NZ">
                        Eketahuna </option>
                
                    <option value="2615" data-chained="NG">
                        Ekiti </option>
                
                    <option value="922" data-chained="DZ">
                        El Bayadh </option>
                
                    <option value="423" data-chained="BO">
                        El Beni </option>
                
                    <option value="2183" data-chained="MA">
                        El Jadida </option>
                
                    <option value="2184" data-chained="MA">
                        El Kelaa des Srarhna </option>
                
                    <option value="944" data-chained="EC">
                        El Oro </option>
                
                    <option value="923" data-chained="DZ">
                        El Oued </option>
                
                    <option value="1565" data-chained="HN">
                        El Paraiso </option>
                
                    <option value="1522" data-chained="GT">
                        El Progreso </option>
                
                    <option value="883" data-chained="DO">
                        El Seibo </option>
                
                    <option value="924" data-chained="DZ">
                        El Tarf </option>
                
                    <option value="3735" data-chained="TR">
                        Elazig </option>
                
                    <option value="57" data-chained="AL">
                        Elbasan </option>
                
                    <option value="3013" data-chained="PL">
                        Elblag </option>
                
                    <option value="868" data-chained="DO">
                        Elias Pina </option>
                
                    <option value="2711" data-chained="NZ">
                        Ellesmere </option>
                
                    <option value="2712" data-chained="NZ">
                        Eltham </option>
                
                    <option value="1830" data-chained="IT">
                        Emilia-Romagna </option>
                
                    <option value="2" data-chained="AD">
                        Encamp </option>
                
                    <option value="1146" data-chained="GB">
                        Enfield </option>
                
                    <option value="2863" data-chained="PG">
                        Enga </option>
                
                    <option value="101" data-chained="AR">
                        Entre Rios </option>
                
                    <option value="2608" data-chained="NG">
                        Enugu </option>
                
                    <option value="4085" data-chained="VU">
                        Epi </option>
                
                    <option value="533" data-chained="CD">
                        Equateur </option>
                
                    <option value="2185" data-chained="MA">
                        Er Rachidia </option>
                
                    <option value="2401" data-chained="MN">
                        Erdenet </option>
                
                    <option value="2564" data-chained="NA">
                        Erongo </option>
                
                    <option value="3736" data-chained="TR">
                        Erzincan </option>
                
                    <option value="3737" data-chained="TR">
                        Erzurum </option>
                
                    <option value="7" data-chained="AD">
                        Escaldes-Engordany </option>
                
                    <option value="2059" data-chained="LI">
                        Eschen </option>
                
                    <option value="1523" data-chained="GT">
                        Escuintla </option>
                
                    <option value="1778" data-chained="IR">
                        Esfahan </option>
                
                    <option value="3738" data-chained="TR">
                        Eskisehir </option>
                
                    <option value="945" data-chained="EC">
                        Esmeraldas </option>
                
                    <option value="865" data-chained="DO">
                        Espaillat </option>
                
                    <option value="437" data-chained="BR">
                        Espirito Santo </option>
                
                    <option value="2186" data-chained="MA">
                        Essaouira </option>
                
                    <option value="1553" data-chained="GY">
                        Essequibo Islands-West Demerara </option>
                
                    <option value="1147" data-chained="GB">
                        Essex </option>
                
                    <option value="667" data-chained="CM">
                        Est </option>
                
                    <option value="2623" data-chained="NI">
                        Esteli </option>
                
                    <option value="1076" data-chained="GA">
                        Estuaire </option>
                
                    <option value="3179" data-chained="RU">
                        Evenk </option>
                
                    <option value="3077" data-chained="PT">
                        Evora </option>
                
                    <option value="1496" data-chained="GR">
                        Evritania </option>
                
                    <option value="1467" data-chained="GR">
                        Evros </option>
                
                    <option value="1500" data-chained="GR">
                        Evvoia </option>
                
                    <option value="2691" data-chained="NR">
                        Ewa </option>
                
                    <option value="1019" data-chained="ES">
                        Extremadura </option>
                
                    <option value="674" data-chained="CM">
                        Extreme-Nord </option>
                
                    <option value="459" data-chained="BS">
                        Exuma </option>
                
                    <option value="1797" data-chained="IS">
                        Eyjafjardarsysla </option>
                
                    <option value="2713" data-chained="NZ">
                        Eyre </option>
                
                    <option value="4097" data-chained="WS">
                        Fa </option>
                
                    <option value="2443" data-chained="MV">
                        Faafu </option>
                
                    <option value="3496" data-chained="SM">
                        Faetano </option>
                
                    <option value="4012" data-chained="VE">
                        Falcon </option>
                
                    <option value="1296" data-chained="GB">
                        Falkirk </option>
                
                    <option value="779" data-chained="CY">
                        Famagusta </option>
                
                    <option value="19" data-chained="AF">
                        Farah </option>
                
                    <option value="1433" data-chained="GN">
                        Faranah </option>
                
                    <option value="3986" data-chained="UZ">
                        Farghona </option>
                
                    <option value="233" data-chained="BD">
                        Faridpur </option>
                
                    <option value="3078" data-chained="PT">
                        Faro </option>
                
                    <option value="1766" data-chained="IR">
                        Fars </option>
                
                    <option value="20" data-chained="AF">
                        Faryab </option>
                
                    <option value="3508" data-chained="SN">
                        Fatick </option>
                
                    <option value="2714" data-chained="NZ">
                        Featherston </option>
                
                    <option value="2998" data-chained="PK">
                        Federally Administered Tribal Areas </option>
                
                    <option value="3917" data-chained="US">
                        Federated States of Micronesia </option>
                
                    <option value="202" data-chained="BA">
                        Federation of Bosnia and Herzegovina </option>
                
                    <option value="1614" data-chained="HU">
                        Fejer </option>
                
                    <option value="234" data-chained="BD">
                        Feni </option>
                
                    <option value="606" data-chained="CI">
                        Ferkessedougou </option>
                
                    <option value="1271" data-chained="GB">
                        Fermanagh </option>
                
                    <option value="2187" data-chained="MA">
                        Fes </option>
                
                    <option value="2229" data-chained="MG">
                        Fianarantsoa </option>
                
                    <option value="58" data-chained="AL">
                        Fier </option>
                
                    <option value="1297" data-chained="GB">
                        Fife </option>
                
                    <option value="2188" data-chained="MA">
                        Figuig </option>
                
                    <option value="2653" data-chained="NO">
                        Finnmark </option>
                
                    <option value="3497" data-chained="SM">
                        Fiorentino </option>
                
                    <option value="2423" data-chained="MU">
                        Flacq </option>
                
                    <option value="2649" data-chained="NL">
                        Flevoland </option>
                
                    <option value="1324" data-chained="GB">
                        Flintshire </option>
                
                    <option value="3970" data-chained="UY">
                        Flores </option>
                
                    <option value="3916" data-chained="US">
                        Florida </option>
                
                    <option value="3971" data-chained="UY">
                        Florida </option>
                
                    <option value="1474" data-chained="GR">
                        Florina </option>
                
                    <option value="1498" data-chained="GR">
                        Fokis </option>
                
                    <option value="1434" data-chained="GN">
                        Forecariah </option>
                
                    <option value="102" data-chained="AR">
                        Formosa </option>
                
                    <option value="1062" data-chained="FR">
                        Franche-Comte </option>
                
                    <option value="1566" data-chained="HN">
                        Francisco Morazan </option>
                
                    <option value="2715" data-chained="NZ">
                        Franklin </option>
                
                    <option value="836" data-chained="DK">
                        Frederiksborg </option>
                
                    <option value="4122" data-chained="ZA">
                        Free State </option>
                
                    <option value="467" data-chained="BS">
                        Freeport </option>
                
                    <option value="468" data-chained="BS">
                        Fresh Creek </option>
                
                    <option value="1435" data-chained="GN">
                        Fria </option>
                
                    <option value="576" data-chained="CH">
                        Fribourg </option>
                
                    <option value="2636" data-chained="NL">
                        Friesland </option>
                
                    <option value="1831" data-chained="IT">
                        Friuli-Venezia Giulia </option>
                
                    <option value="1495" data-chained="GR">
                        Fthiotis </option>
                
                    <option value="3809" data-chained="TW">
                        Fu-chien </option>
                
                    <option value="11" data-chained="AE">
                        Fujairah </option>
                
                    <option value="683" data-chained="CN">
                        Fujian </option>
                
                    <option value="1873" data-chained="JP">
                        Fukui </option>
                
                    <option value="1874" data-chained="JP">
                        Fukuoka </option>
                
                    <option value="1875" data-chained="JP">
                        Fukushima </option>
                
                    <option value="152" data-chained="AZ">
                        Fuzuli </option>
                
                    <option value="837" data-chained="DK">
                        Fyn </option>
                
                    <option value="2450" data-chained="MV">
                        Gaafu Aliff </option>
                
                    <option value="2451" data-chained="MV">
                        Gaafu Daalu </option>
                
                    <option value="340" data-chained="BG">
                        Gabrovo </option>
                
                    <option value="1546" data-chained="GW">
                        Gabu </option>
                
                    <option value="153" data-chained="AZ">
                        Gadabay </option>
                
                    <option value="4098" data-chained="WS">
                        Gaga </option>
                
                    <option value="4100" data-chained="WS">
                        Gagaifomauga </option>
                
                    <option value="2222" data-chained="MD">
                        Gagauzia </option>
                
                    <option value="607" data-chained="CI">
                        Gagnoa </option>
                
                    <option value="235" data-chained="BD">
                        Gaibandha </option>
                
                    <option value="937" data-chained="EC">
                        Galapagos </option>
                
                    <option value="3137" data-chained="RO">
                        Galati </option>
                
                    <option value="3516" data-chained="SO">
                        Galguduud </option>
                
                    <option value="1020" data-chained="ES">
                        Galicia </option>
                
                    <option value="2073" data-chained="LK">
                        Galle </option>
                
                    <option value="1682" data-chained="IE">
                        Galway </option>
                
                    <option value="1035" data-chained="ET">
                        Gambela Hizboch </option>
                
                    <option value="1025" data-chained="ET">
                        Gambella </option>
                
                    <option value="2088" data-chained="LK">
                        Gampaha </option>
                
                    <option value="2060" data-chained="LI">
                        Gamprin </option>
                
                    <option value="154" data-chained="AZ">
                        Ganca </option>
                
                    <option value="2672" data-chained="NP">
                        Gandaki </option>
                
                    <option value="691" data-chained="CN">
                        Gansu </option>
                
                    <option value="293" data-chained="BF">
                        Ganzourgou </option>
                
                    <option value="2364" data-chained="ML">
                        Gao </option>
                
                    <option value="1436" data-chained="GN">
                        Gaoual </option>
                
                    <option value="1362" data-chained="GE">
                        Gardabanis Raioni </option>
                
                    <option value="1148" data-chained="GB">
                        Gateshead </option>
                
                    <option value="4124" data-chained="ZA">
                        Gauteng </option>
                
                    <option value="3313" data-chained="SE">
                        Gavleborgs Lan </option>
                
                    <option value="2528" data-chained="MZ">
                        Gaza </option>
                
                    <option value="2265" data-chained="MK">
                        Gazi Baba </option>
                
                    <option value="3786" data-chained="TR">
                        Gaziantep </option>
                
                    <option value="236" data-chained="BD">
                        Gazipur </option>
                
                    <option value="3014" data-chained="PL">
                        Gdansk </option>
                
                    <option value="3517" data-chained="SO">
                        Gedo </option>
                
                    <option value="69" data-chained="AM">
                        Geghark'unik' </option>
                
                    <option value="2637" data-chained="NL">
                        Gelderland </option>
                
                    <option value="2958" data-chained="PH">
                        General Santos </option>
                
                    <option value="577" data-chained="CH">
                        Geneve </option>
                
                    <option value="3918" data-chained="US">
                        Georgia </option>
                
                    <option value="2266" data-chained="MK">
                        Gevgelija </option>
                
                    <option value="482" data-chained="BT">
                        Geylegphug </option>
                
                    <option value="2168" data-chained="LY">
                        Ghadamis </option>
                
                    <option value="498" data-chained="BW">
                        Ghanzi </option>
                
                    <option value="925" data-chained="DZ">
                        Ghardaia </option>
                
                    <option value="2169" data-chained="LY">
                        Gharyan </option>
                
                    <option value="21" data-chained="AF">
                        Ghazni </option>
                
                    <option value="22" data-chained="AF">
                        Ghowr </option>
                
                    <option value="4059" data-chained="VN">
                        Gia Lai </option>
                
                    <option value="1876" data-chained="JP">
                        Gifu </option>
                
                    <option value="3254" data-chained="RW">
                        Gikongoro </option>
                
                    <option value="1767" data-chained="IR">
                        Gilan </option>
                
                    <option value="1951" data-chained="KI">
                        Gilbert Islands </option>
                
                    <option value="2959" data-chained="PH">
                        Gingoog </option>
                
                    <option value="3739" data-chained="TR">
                        Giresun </option>
                
                    <option value="3255" data-chained="RW">
                        Gisenyi </option>
                
                    <option value="3256" data-chained="RW">
                        Gitarama </option>
                
                    <option value="382" data-chained="BI">
                        Gitega </option>
                
                    <option value="3160" data-chained="RO">
                        Giurgiu </option>
                
                    <option value="59" data-chained="AL">
                        Gjirokaster </option>
                
                    <option value="3292" data-chained="SC">
                        Glacis </option>
                
                    <option value="578" data-chained="CH">
                        Glarus </option>
                
                    <option value="1298" data-chained="GB">
                        Glasgow City </option>
                
                    <option value="1149" data-chained="GB">
                        Gloucestershire </option>
                
                    <option value="294" data-chained="BF">
                        Gnagna </option>
                
                    <option value="1736" data-chained="IN">
                        Goa </option>
                
                    <option value="2540" data-chained="NA">
                        Gobabis </option>
                
                    <option value="454" data-chained="BR">
                        Goias </option>
                
                    <option value="2716" data-chained="NZ">
                        Golden Bay </option>
                
                    <option value="1786" data-chained="IR">
                        Golestan </option>
                
                    <option value="2616" data-chained="NG">
                        Gombe </option>
                
                    <option value="237" data-chained="BD">
                        Gopalganj </option>
                
                    <option value="155" data-chained="AZ">
                        Goranboy </option>
                
                    <option value="3362" data-chained="SI">
                        Gorenja Vas-Poljane </option>
                
                    <option value="2410" data-chained="MR">
                        Gorgol </option>
                
                    <option value="1363" data-chained="GE">
                        Gori </option>
                
                    <option value="1364" data-chained="GE">
                        Goris Raioni </option>
                
                    <option value="3363" data-chained="SI">
                        Gorisnica </option>
                
                    <option value="3138" data-chained="RO">
                        Gorj </option>
                
                    <option value="3364" data-chained="SI">
                        Gornja Radgona </option>
                
                    <option value="3365" data-chained="SI">
                        Gornji Grad </option>
                
                    <option value="3366" data-chained="SI">
                        Gornji Petrovci </option>
                
                    <option value="3164" data-chained="RU">
                        Gorno-Altay </option>
                
                    <option value="1674" data-chained="ID">
                        Gorontalo </option>
                
                    <option value="3015" data-chained="PL">
                        Gorzow </option>
                
                    <option value="2267" data-chained="MK">
                        Gostivar </option>
                
                    <option value="3314" data-chained="SE">
                        Goteborgs och Bohus Lan </option>
                
                    <option value="3315" data-chained="SE">
                        Gotlands Lan </option>
                
                    <option value="307" data-chained="BF">
                        Gourma </option>
                
                    <option value="469" data-chained="BS">
                        Governor's Harbour </option>
                
                    <option value="2389" data-chained="MN">
                        Govi-Altay </option>
                
                    <option value="2403" data-chained="MN">
                        Govi-Sumber </option>
                
                    <option value="156" data-chained="AZ">
                        Goycay </option>
                
                    <option value="1567" data-chained="HN">
                        Gracias a Dios </option>
                
                    <option value="341" data-chained="BG">
                        Grad Sofiya </option>
                
                    <option value="1597" data-chained="HR">
                        Grad Zagreb </option>
                
                    <option value="2268" data-chained="MK">
                        Gradsko </option>
                
                    <option value="1098" data-chained="GB">
                        Grampian </option>
                
                    <option value="2624" data-chained="NI">
                        Granada </option>
                
                    <option value="2101" data-chained="LR">
                        Grand Bassa </option>
                
                    <option value="2095" data-chained="LR">
                        Grand Cape Mount </option>
                
                    <option value="2094" data-chained="LR">
                        Grand Jide </option>
                
                    <option value="2424" data-chained="MU">
                        Grand Port </option>
                
                    <option value="648" data-chained="CI">
                        Grand-Bassam </option>
                
                    <option value="629" data-chained="CI">
                        Grand-Lahou </option>
                
                    <option value="1601" data-chained="HT">
                        Grand' Anse </option>
                
                    <option value="3293" data-chained="SC">
                        Grand' Anse </option>
                
                    <option value="1955" data-chained="KM">
                        Grande Comore </option>
                
                    <option value="755" data-chained="CU">
                        Granma </option>
                
                    <option value="579" data-chained="CH">
                        Graubunden </option>
                
                    <option value="2717" data-chained="NZ">
                        Great Barrier Island </option>
                
                    <option value="1407" data-chained="GH">
                        Greater Accra </option>
                
                    <option value="1088" data-chained="GB">
                        Greater London </option>
                
                    <option value="1089" data-chained="GB">
                        Greater Manchester </option>
                
                    <option value="470" data-chained="BS">
                        Green Turtle Cay </option>
                
                    <option value="1150" data-chained="GB">
                        Greenwich </option>
                
                    <option value="4002" data-chained="VC">
                        Grenadines </option>
                
                    <option value="1476" data-chained="GR">
                        Grevena </option>
                
                    <option value="2124" data-chained="LU">
                        Grevenmacher </option>
                
                    <option value="2718" data-chained="NZ">
                        Grey </option>
                
                    <option value="2638" data-chained="NL">
                        Groningen </option>
                
                    <option value="2541" data-chained="NA">
                        Grootfontein </option>
                
                    <option value="2052" data-chained="LC">
                        Gros-Islet </option>
                
                    <option value="3367" data-chained="SI">
                        Grosuplje </option>
                
                    <option value="3277" data-chained="SB">
                        Guadalcanal </option>
                
                    <option value="718" data-chained="CO">
                        Guainia </option>
                
                    <option value="3099" data-chained="PY">
                        Guaira </option>
                
                    <option value="3919" data-chained="US">
                        Guam </option>
                
                    <option value="743" data-chained="CR">
                        Guanacaste </option>
                
                    <option value="2490" data-chained="MX">
                        Guanajuato </option>
                
                    <option value="704" data-chained="CN">
                        Guangdong </option>
                
                    <option value="692" data-chained="CN">
                        Guangxi </option>
                
                    <option value="756" data-chained="CU">
                        Guantanamo </option>
                
                    <option value="3080" data-chained="PT">
                        Guarda </option>
                
                    <option value="4013" data-chained="VE">
                        Guarico </option>
                
                    <option value="1524" data-chained="GT">
                        Guatemala </option>
                
                    <option value="717" data-chained="CO">
                        Guaviare </option>
                
                    <option value="946" data-chained="EC">
                        Guayas </option>
                
                    <option value="1437" data-chained="GN">
                        Gueckedou </option>
                
                    <option value="905" data-chained="DZ">
                        Guelma </option>
                
                    <option value="2205" data-chained="MA">
                        Guelmim </option>
                
                    <option value="3577" data-chained="TD">
                        Guera </option>
                
                    <option value="2491" data-chained="MX">
                        Guerrero </option>
                
                    <option value="2416" data-chained="MR">
                        Guidimaka </option>
                
                    <option value="649" data-chained="CI">
                        Guiglo </option>
                
                    <option value="693" data-chained="CN">
                        Guizhou </option>
                
                    <option value="1714" data-chained="IN">
                        Gujarat </option>
                
                    <option value="2132" data-chained="LV">
                        Gulbenes </option>
                
                    <option value="2846" data-chained="PG">
                        Gulf </option>
                
                    <option value="1798" data-chained="IS">
                        Gullbringusysla </option>
                
                    <option value="1877" data-chained="JP">
                        Gumma </option>
                
                    <option value="3772" data-chained="TR">
                        Gumushane </option>
                
                    <option value="1365" data-chained="GE">
                        Gurjaanis Raioni </option>
                
                    <option value="1104" data-chained="GB">
                        Gwent </option>
                
                    <option value="1325" data-chained="GB">
                        Gwynedd </option>
                
                    <option value="1631" data-chained="HU">
                        Gyor </option>
                
                    <option value="1615" data-chained="HU">
                        Gyor-Moson-Sopron </option>
                
                    <option value="3713" data-chained="TO">
                        Ha </option>
                
                    <option value="483" data-chained="BT">
                        Ha </option>
                
                    <option value="4031" data-chained="VN">
                        Ha Bac </option>
                
                    <option value="4060" data-chained="VN">
                        Ha Giang </option>
                
                    <option value="4053" data-chained="VN">
                        Ha Noi </option>
                
                    <option value="4061" data-chained="VN">
                        Ha Tay </option>
                
                    <option value="4062" data-chained="VN">
                        Ha Tinh </option>
                
                    <option value="3268" data-chained="SA">
                        Ha'il </option>
                
                    <option value="2439" data-chained="MV">
                        Haa Aliff </option>
                
                    <option value="2446" data-chained="MV">
                        Haa Daalu </option>
                
                    <option value="238" data-chained="BD">
                        Habiganj </option>
                
                    <option value="157" data-chained="AZ">
                        Haciqabul </option>
                
                    <option value="1151" data-chained="GB">
                        Hackney </option>
                
                    <option value="1702" data-chained="IL">
                        HaDarom </option>
                
                    <option value="4107" data-chained="YE">
                        Hadramawt </option>
                
                    <option value="1799" data-chained="IS">
                        Hafnarfjordur </option>
                
                    <option value="4032" data-chained="VN">
                        Hai Hung </option>
                
                    <option value="4033" data-chained="VN">
                        Hai Phong </option>
                
                    <option value="705" data-chained="CN">
                        Hainan </option>
                
                    <option value="281" data-chained="BE">
                        Hainaut </option>
                
                    <option value="1616" data-chained="HU">
                        Hajdu-Bihar </option>
                
                    <option value="4117" data-chained="YE">
                        Hajjah </option>
                
                    <option value="3773" data-chained="TR">
                        Hakkari </option>
                
                    <option value="3562" data-chained="SY">
                        Halab </option>
                
                    <option value="3316" data-chained="SE">
                        Hallands Lan </option>
                
                    <option value="1152" data-chained="GB">
                        Halton </option>
                
                    <option value="1768" data-chained="IR">
                        Hamadan </option>
                
                    <option value="3563" data-chained="SY">
                        Hamah </option>
                
                    <option value="2074" data-chained="LK">
                        Hambantota </option>
                
                    <option value="817" data-chained="DE">
                        Hamburg </option>
                
                    <option value="1703" data-chained="IL">
                        HaMerkaz </option>
                
                    <option value="1982" data-chained="KP">
                        Hamgyong-bukto </option>
                
                    <option value="1972" data-chained="KP">
                        Hamgyong-namdo </option>
                
                    <option value="400" data-chained="BM">
                        Hamilton </option>
                
                    <option value="1153" data-chained="GB">
                        Hammersmith and Fulham </option>
                
                    <option value="1154" data-chained="GB">
                        Hampshire </option>
                
                    <option value="1847" data-chained="JM">
                        Hanover </option>
                
                    <option value="4148" data-chained="ZW">
                        Harare </option>
                
                    <option value="464" data-chained="BS">
                        Harbour Island </option>
                
                    <option value="2565" data-chained="NA">
                        Hardap </option>
                
                    <option value="1036" data-chained="ET">
                        Hareri Hizb </option>
                
                    <option value="3139" data-chained="RO">
                        Harghita </option>
                
                    <option value="1155" data-chained="GB">
                        Haringey </option>
                
                    <option value="959" data-chained="EE">
                        Harjumaa </option>
                
                    <option value="1156" data-chained="GB">
                        Harrow </option>
                
                    <option value="1157" data-chained="GB">
                        Hartlepool </option>
                
                    <option value="1715" data-chained="IN">
                        Haryana </option>
                
                    <option value="3740" data-chained="TR">
                        Hatay </option>
                
                    <option value="884" data-chained="DO">
                        Hato Mayor </option>
                
                    <option value="2719" data-chained="NZ">
                        Hauraki Plains </option>
                
                    <option value="548" data-chained="CF">
                        Haut-Mbomou </option>
                
                    <option value="1077" data-chained="GA">
                        Haut-Ogooue </option>
                
                    <option value="546" data-chained="CF">
                        Haute-Kotto </option>
                
                    <option value="1063" data-chained="FR">
                        Haute-Normandie </option>
                
                    <option value="1158" data-chained="GB">
                        Havering </option>
                
                    <option value="3920" data-chained="US">
                        Hawaii </option>
                
                    <option value="2002" data-chained="KW">
                        Hawalli </option>
                
                    <option value="2720" data-chained="NZ">
                        Hawera </option>
                
                    <option value="2721" data-chained="NZ">
                        Hawke's Bay </option>
                
                    <option value="1704" data-chained="IL">
                        HaZafon </option>
                
                    <option value="2722" data-chained="NZ">
                        Heathcote </option>
                
                    <option value="686" data-chained="CN">
                        Hebei </option>
                
                    <option value="2654" data-chained="NO">
                        Hedmark </option>
                
                    <option value="1705" data-chained="IL">
                        Hefa </option>
                
                    <option value="684" data-chained="CN">
                        Heilongjiang </option>
                
                    <option value="23" data-chained="AF">
                        Helmand </option>
                
                    <option value="685" data-chained="CN">
                        Henan </option>
                
                    <option value="2390" data-chained="MN">
                        Hentiy </option>
                
                    <option value="24" data-chained="AF">
                        Herat </option>
                
                    <option value="744" data-chained="CR">
                        Heredia </option>
                
                    <option value="1090" data-chained="GB">
                        Hereford and Worcester </option>
                
                    <option value="1159" data-chained="GB">
                        Herefordshire </option>
                
                    <option value="2558" data-chained="NA">
                        Hereroland Oos </option>
                
                    <option value="2559" data-chained="NA">
                        Hereroland Wes </option>
                
                    <option value="2815" data-chained="PA">
                        Herrera </option>
                
                    <option value="1160" data-chained="GB">
                        Hertford </option>
                
                    <option value="818" data-chained="DE">
                        Hessen </option>
                
                    <option value="1617" data-chained="HU">
                        Heves </option>
                
                    <option value="3568" data-chained="SZ">
                        Hhohho </option>
                
                    <option value="2492" data-chained="MX">
                        Hidalgo </option>
                
                    <option value="471" data-chained="BS">
                        High Rock </option>
                
                    <option value="1299" data-chained="GB">
                        Highland </option>
                
                    <option value="3518" data-chained="SO">
                        Hiiraan </option>
                
                    <option value="960" data-chained="EE">
                        Hiiumaa </option>
                
                    <option value="2795" data-chained="NZ">
                        Hikurangi </option>
                
                    <option value="1161" data-chained="GB">
                        Hillingdon </option>
                
                    <option value="1716" data-chained="IN">
                        Himachal Pradesh </option>
                
                    <option value="3564" data-chained="SY">
                        Hims </option>
                
                    <option value="1878" data-chained="JP">
                        Hiroshima </option>
                
                    <option value="798" data-chained="CZ">
                        Hlavni Mesto Praha </option>
                
                    <option value="4054" data-chained="VN">
                        Ho Chi Minh </option>
                
                    <option value="4063" data-chained="VN">
                        Hoa Binh </option>
                
                    <option value="2723" data-chained="NZ">
                        Hobson </option>
                
                    <option value="2407" data-chained="MR">
                        Hodh Ech Chargui </option>
                
                    <option value="2408" data-chained="MR">
                        Hodh El Gharbi </option>
                
                    <option value="1635" data-chained="HU">
                        Hodmezovasarhely </option>
                
                    <option value="2724" data-chained="NZ">
                        Hokianga </option>
                
                    <option value="1879" data-chained="JP">
                        Hokkaido </option>
                
                    <option value="758" data-chained="CU">
                        Holguin </option>
                
                    <option value="507" data-chained="BY">
                        Homyel'skaya Voblasts' </option>
                
                    <option value="2655" data-chained="NO">
                        Hordaland </option>
                
                    <option value="1770" data-chained="IR">
                        Hormozgan </option>
                
                    <option value="2725" data-chained="NZ">
                        Horowhenua </option>
                
                    <option value="2030" data-chained="LA">
                        Houaphan </option>
                
                    <option value="308" data-chained="BF">
                        Houet </option>
                
                    <option value="1162" data-chained="GB">
                        Hounslow </option>
                
                    <option value="2391" data-chained="MN">
                        Hovd </option>
                
                    <option value="2392" data-chained="MN">
                        Hovsgol </option>
                
                    <option value="787" data-chained="CZ">
                        Hradec Kralove </option>
                
                    <option value="3368" data-chained="SI">
                        Hrastnik </option>
                
                    <option value="508" data-chained="BY">
                        Hrodzyenskaya Voblasts' </option>
                
                    <option value="3369" data-chained="SI">
                        Hrpelje-Kozina </option>
                
                    <option value="84" data-chained="AO">
                        Huambo </option>
                
                    <option value="2828" data-chained="PE">
                        Huancavelica </option>
                
                    <option value="2829" data-chained="PE">
                        Huanuco </option>
                
                    <option value="688" data-chained="CN">
                        Hubei </option>
                
                    <option value="1525" data-chained="GT">
                        Huehuetenango </option>
                
                    <option value="85" data-chained="AO">
                        Huila </option>
                
                    <option value="719" data-chained="CO">
                        Huila </option>
                
                    <option value="1091" data-chained="GB">
                        Humberside </option>
                
                    <option value="687" data-chained="CN">
                        Hunan </option>
                
                    <option value="3140" data-chained="RO">
                        Hunedoara </option>
                
                    <option value="2791" data-chained="NZ">
                        Hurunui </option>
                
                    <option value="1800" data-chained="IS">
                        Husavik </option>
                
                    <option value="2726" data-chained="NZ">
                        Hutt </option>
                
                    <option value="1974" data-chained="KP">
                        Hwanghae-bukto </option>
                
                    <option value="1973" data-chained="KP">
                        Hwanghae-namdo </option>
                
                    <option value="1880" data-chained="JP">
                        Hyogo </option>
                
                    <option value="3141" data-chained="RO">
                        Ialomita </option>
                
                    <option value="3142" data-chained="RO">
                        Iasi </option>
                
                    <option value="1881" data-chained="JP">
                        Ibaraki </option>
                
                    <option value="4118" data-chained="YE">
                        Ibb </option>
                
                    <option value="2830" data-chained="PE">
                        Ica </option>
                
                    <option value="3741" data-chained="TR">
                        Icel / Mersin </option>
                
                    <option value="961" data-chained="EE">
                        Ida-Virumaa </option>
                
                    <option value="3922" data-chained="US">
                        Idaho </option>
                
                    <option value="3565" data-chained="SY">
                        Idlib </option>
                
                    <option value="3370" data-chained="SI">
                        Idrija </option>
                
                    <option value="2206" data-chained="MA">
                        Ifrane </option>
                
                    <option value="2891" data-chained="PH">
                        Ifugao </option>
                
                    <option value="3371" data-chained="SI">
                        Ig </option>
                
                    <option value="3883" data-chained="UG">
                        Iganga </option>
                
                    <option value="3791" data-chained="TR">
                        Igdir </option>
                
                    <option value="2692" data-chained="NR">
                        Ijuw </option>
                
                    <option value="1769" data-chained="IR">
                        Ilam </option>
                
                    <option value="1064" data-chained="FR">
                        Ile-de-France </option>
                
                    <option value="3161" data-chained="RO">
                        Ilfov </option>
                
                    <option value="2405" data-chained="MO">
                        Ilhas </option>
                
                    <option value="1505" data-chained="GR">
                        Ilia </option>
                
                    <option value="2960" data-chained="PH">
                        Iligan </option>
                
                    <option value="2269" data-chained="MK">
                        Ilinden </option>
                
                    <option value="3372" data-chained="SI">
                        Ilirska Bistrica </option>
                
                    <option value="3923" data-chained="US">
                        Illinois </option>
                
                    <option value="926" data-chained="DZ">
                        Illizi </option>
                
                    <option value="2892" data-chained="PH">
                        Ilocos Norte </option>
                
                    <option value="2893" data-chained="PH">
                        Ilocos Sur </option>
                
                    <option value="2894" data-chained="PH">
                        Iloilo </option>
                
                    <option value="2961" data-chained="PH">
                        Iloilo City </option>
                
                    <option value="1478" data-chained="GR">
                        Imathia </option>
                
                    <option value="947" data-chained="EC">
                        Imbabura </option>
                
                    <option value="158" data-chained="AZ">
                        Imisli </option>
                
                    <option value="2592" data-chained="NG">
                        Imo </option>
                
                    <option value="460" data-chained="BS">
                        Inagua </option>
                
                    <option value="2727" data-chained="NZ">
                        Inangahua </option>
                
                    <option value="1990" data-chained="KR">
                        Inch'on-jikhalsi </option>
                
                    <option value="2418" data-chained="MR">
                        Inchiri </option>
                
                    <option value="866" data-chained="DO">
                        Independencia </option>
                
                    <option value="3924" data-chained="US">
                        Indiana </option>
                
                    <option value="2728" data-chained="NZ">
                        Inglewood </option>
                
                    <option value="3180" data-chained="RU">
                        Ingush </option>
                
                    <option value="2529" data-chained="MZ">
                        Inhambane </option>
                
                    <option value="580" data-chained="CH">
                        Inner-Rhoden </option>
                
                    <option value="1568" data-chained="HN">
                        Intibuca </option>
                
                    <option value="1300" data-chained="GB">
                        Inverclyde </option>
                
                    <option value="1483" data-chained="GR">
                        Ioannina </option>
                
                    <option value="309" data-chained="BF">
                        Ioba </option>
                
                    <option value="3921" data-chained="US">
                        Iowa </option>
                
                    <option value="1511" data-chained="GR">
                        Iraklion </option>
                
                    <option value="1866" data-chained="JO">
                        Irbid </option>
                
                    <option value="2962" data-chained="PH">
                        Iriga </option>
                
                    <option value="3816" data-chained="TZ">
                        Iringa </option>
                
                    <option value="3181" data-chained="RU">
                        Irkutsk </option>
                
                    <option value="2368" data-chained="MM">
                        Irrawaddy </option>
                
                    <option value="3278" data-chained="SB">
                        Isabel </option>
                
                    <option value="2895" data-chained="PH">
                        Isabela </option>
                
                    <option value="1801" data-chained="IS">
                        Isafjordur </option>
                
                    <option value="1882" data-chained="JP">
                        Ishikawa </option>
                
                    <option value="751" data-chained="CU">
                        Isla de la Juventud </option>
                
                    <option value="3005" data-chained="PK">
                        Islamabad </option>
                
                    <option value="1006" data-chained="ES">
                        Islas Baleares </option>
                
                    <option value="1569" data-chained="HN">
                        Islas de la Bahia </option>
                
                    <option value="1315" data-chained="GB">
                        Isle of Anglesey </option>
                
                    <option value="1163" data-chained="GB">
                        Isle of Wight </option>
                
                    <option value="1164" data-chained="GB">
                        Islington </option>
                
                    <option value="159" data-chained="AZ">
                        Ismayilli </option>
                
                    <option value="3742" data-chained="TR">
                        Isparta </option>
                
                    <option value="614" data-chained="CI">
                        Issia </option>
                
                    <option value="3743" data-chained="TR">
                        Istanbul </option>
                
                    <option value="1580" data-chained="HR">
                        Istarska </option>
                
                    <option value="3100" data-chained="PY">
                        Itapua </option>
                
                    <option value="3373" data-chained="SI">
                        Ivancna Gorica </option>
                
                    <option value="3843" data-chained="UA">
                        Ivano-Frankivs'ka Oblast' </option>
                
                    <option value="3182" data-chained="RU">
                        Ivanovo </option>
                
                    <option value="1883" data-chained="JP">
                        Iwate </option>
                
                    <option value="1526" data-chained="GT">
                        Izabal </option>
                
                    <option value="3744" data-chained="TR">
                        Izmir </option>
                
                    <option value="3374" data-chained="SI">
                        Izola-Isola </option>
                
                    <option value="2270" data-chained="MK">
                        Izvor </option>
                
                    <option value="788" data-chained="CZ">
                        Jablonec nad Nisou </option>
                
                    <option value="650" data-chained="CI">
                        Jacqueville </option>
                
                    <option value="2089" data-chained="LK">
                        Jaffna </option>
                
                    <option value="239" data-chained="BD">
                        Jaipurhat </option>
                
                    <option value="1649" data-chained="ID">
                        Jakarta Raya </option>
                
                    <option value="1925" data-chained="KG">
                        Jalal-Abad </option>
                
                    <option value="1527" data-chained="GT">
                        Jalapa </option>
                
                    <option value="2493" data-chained="MX">
                        Jalisco </option>
                
                    <option value="240" data-chained="BD">
                        Jamalpur </option>
                
                    <option value="1650" data-chained="ID">
                        Jambi </option>
                
                    <option value="1717" data-chained="IN">
                        Jammu and Kashmir </option>
                
                    <option value="3317" data-chained="SE">
                        Jamtlands Lan </option>
                
                    <option value="2673" data-chained="NP">
                        Janakpur </option>
                
                    <option value="1004" data-chained="EG">
                        Janub Sina' </option>
                
                    <option value="3118" data-chained="QA">
                        Jariyan al Batnah </option>
                
                    <option value="962" data-chained="EE">
                        Jarvamaa </option>
                
                    <option value="1626" data-chained="HU">
                        Jasz-Nagykun-Szolnok </option>
                
                    <option value="1366" data-chained="GE">
                        Javis Raioni </option>
                
                    <option value="1670" data-chained="ID">
                        Jawa Barat </option>
                
                    <option value="1651" data-chained="ID">
                        Jawa Tengah </option>
                
                    <option value="1652" data-chained="ID">
                        Jawa Timur </option>
                
                    <option value="2271" data-chained="MK">
                        Jegunovce </option>
                
                    <option value="3016" data-chained="PL">
                        Jelenia Gora </option>
                
                    <option value="2133" data-chained="LV">
                        Jelgava </option>
                
                    <option value="2134" data-chained="LV">
                        Jelgavas </option>
                
                    <option value="3458" data-chained="SI">
                        Jesenice </option>
                
                    <option value="241" data-chained="BD">
                        Jessore </option>
                
                    <option value="242" data-chained="BD">
                        Jhalakati </option>
                
                    <option value="1741" data-chained="IN">
                        Jharkhand </option>
                
                    <option value="243" data-chained="BD">
                        Jhenaidah </option>
                
                    <option value="680" data-chained="CN">
                        Jiangsu </option>
                
                    <option value="679" data-chained="CN">
                        Jiangxi </option>
                
                    <option value="368" data-chained="BH">
                        Jidd Hafs </option>
                
                    <option value="789" data-chained="CZ">
                        Jiein </option>
                
                    <option value="2600" data-chained="NG">
                        Jigawa </option>
                
                    <option value="790" data-chained="CZ">
                        Jihlava </option>
                
                    <option value="802" data-chained="CZ">
                        Jihocesky Kraj </option>
                
                    <option value="801" data-chained="CZ">
                        Jihomoravsky Kraj </option>
                
                    <option value="906" data-chained="DZ">
                        Jijel </option>
                
                    <option value="681" data-chained="CN">
                        Jilin </option>
                
                    <option value="2625" data-chained="NI">
                        Jinotega </option>
                
                    <option value="3272" data-chained="SA">
                        Jizan </option>
                
                    <option value="3987" data-chained="UZ">
                        Jizzakh </option>
                
                    <option value="963" data-chained="EE">
                        Jogevamaa </option>
                
                    <option value="2512" data-chained="MY">
                        Johor </option>
                
                    <option value="3318" data-chained="SE">
                        Jonkopings Lan </option>
                
                    <option value="42" data-chained="AF">
                        Jowzjan </option>
                
                    <option value="3519" data-chained="SO">
                        Jubbada Dhexe </option>
                
                    <option value="3520" data-chained="SO">
                        Jubbada Hoose </option>
                
                    <option value="103" data-chained="AR">
                        Jujuy </option>
                
                    <option value="3691" data-chained="TN">
                        Jundubah </option>
                
                    <option value="2831" data-chained="PE">
                        Junin </option>
                
                    <option value="596" data-chained="CH">
                        Jura </option>
                
                    <option value="2135" data-chained="LV">
                        Jurmala </option>
                
                    <option value="3375" data-chained="SI">
                        Jursinci </option>
                
                    <option value="1528" data-chained="GT">
                        Jutiapa </option>
                
                    <option value="1367" data-chained="GE">
                        K'arelis Raioni </option>
                
                    <option value="1373" data-chained="GE">
                        K'ut'aisi </option>
                
                    <option value="2449" data-chained="MV">
                        Kaafu </option>
                
                    <option value="3183" data-chained="RU">
                        Kabardin-Balkar </option>
                
                    <option value="3884" data-chained="UG">
                        Kabarole </option>
                
                    <option value="3885" data-chained="UG">
                        Kaberamaido </option>
                
                    <option value="25" data-chained="AF">
                        Kabol </option>
                
                    <option value="2369" data-chained="MM">
                        Kachin State </option>
                
                    <option value="310" data-chained="BF">
                        Kadiogo </option>
                
                    <option value="2587" data-chained="NG">
                        Kaduna </option>
                
                    <option value="1975" data-chained="KP">
                        Kaesong-si </option>
                
                    <option value="1000" data-chained="EG">
                        Kafr ash Shaykh </option>
                
                    <option value="1884" data-chained="JP">
                        Kagawa </option>
                
                    <option value="3831" data-chained="TZ">
                        Kagera </option>
                
                    <option value="1885" data-chained="JP">
                        Kagoshima </option>
                
                    <option value="3753" data-chained="TR">
                        Kahramanmaras </option>
                
                    <option value="2729" data-chained="NZ">
                        Kaikoura </option>
                
                    <option value="2730" data-chained="NZ">
                        Kairanga </option>
                
                    <option value="3629" data-chained="TH">
                        Kalasin </option>
                
                    <option value="160" data-chained="AZ">
                        Kalbacar </option>
                
                    <option value="1655" data-chained="ID">
                        Kalimantan Barat </option>
                
                    <option value="1656" data-chained="ID">
                        Kalimantan Selatan </option>
                
                    <option value="1657" data-chained="ID">
                        Kalimantan Tengah </option>
                
                    <option value="1658" data-chained="ID">
                        Kalimantan Timur </option>
                
                    <option value="2896" data-chained="PH">
                        Kalinga-Apayao </option>
                
                    <option value="3184" data-chained="RU">
                        Kaliningrad </option>
                
                    <option value="3017" data-chained="PL">
                        Kalisz </option>
                
                    <option value="3319" data-chained="SE">
                        Kalmar Lan </option>
                
                    <option value="3185" data-chained="RU">
                        Kalmyk </option>
                
                    <option value="3186" data-chained="RU">
                        Kaluga </option>
                
                    <option value="2075" data-chained="LK">
                        Kalutara </option>
                
                    <option value="3187" data-chained="RU">
                        Kamchatka </option>
                
                    <option value="2272" data-chained="MK">
                        Kamenjane </option>
                
                    <option value="3459" data-chained="SI">
                        Kamnik </option>
                
                    <option value="3875" data-chained="UG">
                        Kampala </option>
                
                    <option value="3618" data-chained="TH">
                        Kamphaeng Phet </option>
                
                    <option value="1931" data-chained="KH">
                        Kampong Cham </option>
                
                    <option value="1932" data-chained="KH">
                        Kampong Chhnang </option>
                
                    <option value="1933" data-chained="KH">
                        Kampong Spoe </option>
                
                    <option value="1934" data-chained="KH">
                        Kampong Thum </option>
                
                    <option value="1935" data-chained="KH">
                        Kampot </option>
                
                    <option value="3886" data-chained="UG">
                        Kamwenge </option>
                
                    <option value="1886" data-chained="JP">
                        Kanagawa </option>
                
                    <option value="3376" data-chained="SI">
                        Kanal </option>
                
                    <option value="3656" data-chained="TH">
                        Kanchanaburi </option>
                
                    <option value="35" data-chained="AF">
                        Kandahar </option>
                
                    <option value="1936" data-chained="KH">
                        Kandal </option>
                
                    <option value="2076" data-chained="LK">
                        Kandy </option>
                
                    <option value="3578" data-chained="TD">
                        Kanem </option>
                
                    <option value="1976" data-chained="KP">
                        Kangwon-do </option>
                
                    <option value="1987" data-chained="KR">
                        Kangwon-do </option>
                
                    <option value="1452" data-chained="GN">
                        Kankan </option>
                
                    <option value="2593" data-chained="NG">
                        Kano </option>
                
                    <option value="3925" data-chained="US">
                        Kansas </option>
                
                    <option value="3593" data-chained="TG">
                        Kante </option>
                
                    <option value="3887" data-chained="UG">
                        Kanungu </option>
                
                    <option value="3810" data-chained="TW">
                        Kao-hsiung </option>
                
                    <option value="1937" data-chained="KH">
                        Kaoh Kong </option>
                
                    <option value="2542" data-chained="NA">
                        Kaokoland </option>
                
                    <option value="3509" data-chained="SN">
                        Kaolack </option>
                
                    <option value="26" data-chained="AF">
                        Kapisa </option>
                
                    <option value="1636" data-chained="HU">
                        Kaposvar </option>
                
                    <option value="3792" data-chained="TR">
                        Karabuk </option>
                
                    <option value="3188" data-chained="RU">
                        Karachay-Cherkess </option>
                
                    <option value="3781" data-chained="TR">
                        Karaman </option>
                
                    <option value="3866" data-chained="UG">
                        Karamoja </option>
                
                    <option value="2370" data-chained="MM">
                        Karan State </option>
                
                    <option value="2566" data-chained="NA">
                        Karas </option>
                
                    <option value="2555" data-chained="NA">
                        Karasburg </option>
                
                    <option value="1754" data-chained="IQ">
                        Karbala' </option>
                
                    <option value="2273" data-chained="MK">
                        Karbinci </option>
                
                    <option value="1489" data-chained="GR">
                        Kardhitsa </option>
                
                    <option value="3189" data-chained="RU">
                        Karelia </option>
                
                    <option value="2543" data-chained="NA">
                        Karibib </option>
                
                    <option value="1581" data-chained="HR">
                        Karlovacka </option>
                
                    <option value="804" data-chained="CZ">
                        Karlovarsky Kraj </option>
                
                    <option value="2674" data-chained="NP">
                        Karnali </option>
                
                    <option value="1723" data-chained="IN">
                        Karnataka </option>
                
                    <option value="119" data-chained="AT">
                        Karnten </option>
                
                    <option value="2459" data-chained="MW">
                        Karonga </option>
                
                    <option value="2274" data-chained="MK">
                        Karpos </option>
                
                    <option value="3787" data-chained="TR">
                        Kars </option>
                
                    <option value="383" data-chained="BI">
                        Karuzi </option>
                
                    <option value="534" data-chained="CD">
                        Kasai-Occidental </option>
                
                    <option value="535" data-chained="CD">
                        Kasai-Oriental </option>
                
                    <option value="1368" data-chained="GE">
                        Kaspis Raioni </option>
                
                    <option value="3745" data-chained="TR">
                        Kastamonu </option>
                
                    <option value="1475" data-chained="GR">
                        Kastoria </option>
                
                    <option value="2460" data-chained="MW">
                        Kasungu </option>
                
                    <option value="3879" data-chained="UG">
                        Katakwi </option>
                
                    <option value="536" data-chained="CD">
                        Katanga </option>
                
                    <option value="608" data-chained="CI">
                        Katiola </option>
                
                    <option value="3018" data-chained="PL">
                        Katowice </option>
                
                    <option value="2588" data-chained="NG">
                        Katsina </option>
                
                    <option value="2114" data-chained="LT">
                        Kauno Apskritis </option>
                
                    <option value="2275" data-chained="MK">
                        Kavadarci </option>
                
                    <option value="1480" data-chained="GR">
                        Kavala </option>
                
                    <option value="2560" data-chained="NA">
                        Kavango </option>
                
                    <option value="2371" data-chained="MM">
                        Kayah State </option>
                
                    <option value="384" data-chained="BI">
                        Kayanza </option>
                
                    <option value="2358" data-chained="ML">
                        Kayes </option>
                
                    <option value="3746" data-chained="TR">
                        Kayseri </option>
                
                    <option value="3888" data-chained="UG">
                        Kayunga </option>
                
                    <option value="2601" data-chained="NG">
                        Kebbi </option>
                
                    <option value="1637" data-chained="HU">
                        Kecskemet </option>
                
                    <option value="2513" data-chained="MY">
                        Kedah </option>
                
                    <option value="2544" data-chained="NA">
                        Keetmanshoop </option>
                
                    <option value="3693" data-chained="TN">
                        Kef </option>
                
                    <option value="1493" data-chained="GR">
                        Kefallinia </option>
                
                    <option value="1802" data-chained="IS">
                        Keflavik </option>
                
                    <option value="2077" data-chained="LK">
                        Kegalla </option>
                
                    <option value="2514" data-chained="MY">
                        Kelantan </option>
                
                    <option value="3190" data-chained="RU">
                        Kemerovo </option>
                
                    <option value="549" data-chained="CF">
                        Kemo </option>
                
                    <option value="472" data-chained="BS">
                        Kemps Bay </option>
                
                    <option value="311" data-chained="BF">
                        Kenedougou </option>
                
                    <option value="2189" data-chained="MA">
                        Kenitra </option>
                
                    <option value="1165" data-chained="GB">
                        Kensington and Chelsea </option>
                
                    <option value="1166" data-chained="GB">
                        Kent </option>
                
                    <option value="3926" data-chained="US">
                        Kentucky </option>
                
                    <option value="1675" data-chained="ID">
                        Kepulauan Bangka Belitung </option>
                
                    <option value="1718" data-chained="IN">
                        Kerala </option>
                
                    <option value="1491" data-chained="GR">
                        Kerkira </option>
                
                    <option value="1779" data-chained="IR">
                        Kerman </option>
                
                    <option value="1438" data-chained="GN">
                        Kerouane </option>
                
                    <option value="1683" data-chained="IE">
                        Kerry </option>
                
                    <option value="499" data-chained="BW">
                        Kgalagadi </option>
                
                    <option value="500" data-chained="BW">
                        Kgatleng </option>
                
                    <option value="3191" data-chained="RU">
                        Khabarovsk </option>
                
                    <option value="244" data-chained="BD">
                        Khagrachari </option>
                
                    <option value="3192" data-chained="RU">
                        Khakass </option>
                
                    <option value="1481" data-chained="GR">
                        Khalkidhiki </option>
                
                    <option value="2031" data-chained="LA">
                        Khammouan </option>
                
                    <option value="4064" data-chained="VN">
                        Khanh Hoa </option>
                
                    <option value="1509" data-chained="GR">
                        Khania </option>
                
                    <option value="3193" data-chained="RU">
                        Khanty-Mansiy </option>
                
                    <option value="1369" data-chained="GE">
                        Kharagaulis Raioni </option>
                
                    <option value="3844" data-chained="UA">
                        Kharkivs'ka Oblast' </option>
                
                    <option value="1370" data-chained="GE">
                        Khashuris Raioni </option>
                
                    <option value="342" data-chained="BG">
                        Khaskovo </option>
                
                    <option value="3682" data-chained="TJ">
                        Khatlon </option>
                
                    <option value="2190" data-chained="MA">
                        Khemisset </option>
                
                    <option value="927" data-chained="DZ">
                        Khenchela </option>
                
                    <option value="2191" data-chained="MA">
                        Khenifra </option>
                
                    <option value="3845" data-chained="UA">
                        Khersons'ka Oblast' </option>
                
                    <option value="1516" data-chained="GR">
                        Khios </option>
                
                    <option value="3846" data-chained="UA">
                        Khmel'nyts'ka Oblast' </option>
                
                    <option value="1371" data-chained="GE">
                        Khobis Raioni </option>
                
                    <option value="3628" data-chained="TH">
                        Khon Kaen </option>
                
                    <option value="1372" data-chained="GE">
                        Khonis Raioni </option>
                
                    <option value="1780" data-chained="IR">
                        Khorasan </option>
                
                    <option value="3988" data-chained="UZ">
                        Khorazm </option>
                
                    <option value="2192" data-chained="MA">
                        Khouribga </option>
                
                    <option value="45" data-chained="AF">
                        Khowst </option>
                
                    <option value="245" data-chained="BD">
                        Khulna </option>
                
                    <option value="1772" data-chained="IR">
                        Khuzestan </option>
                
                    <option value="3257" data-chained="RW">
                        Kibungo </option>
                
                    <option value="3258" data-chained="RW">
                        Kibuye </option>
                
                    <option value="2276" data-chained="MK">
                        Kicevo </option>
                
                    <option value="2365" data-chained="ML">
                        Kidal </option>
                
                    <option value="3377" data-chained="SI">
                        Kidricevo </option>
                
                    <option value="1464" data-chained="GQ">
                        Kie-Ntem </option>
                
                    <option value="3019" data-chained="PL">
                        Kielce </option>
                
                    <option value="4049" data-chained="VN">
                        Kien Giang </option>
                
                    <option value="3259" data-chained="RW">
                        Kigali </option>
                
                    <option value="3817" data-chained="TZ">
                        Kigoma </option>
                
                    <option value="1515" data-chained="GR">
                        Kikladhes </option>
                
                    <option value="1684" data-chained="IE">
                        Kildare </option>
                
                    <option value="3818" data-chained="TZ">
                        Kilimanjaro </option>
                
                    <option value="3793" data-chained="TR">
                        Kilis </option>
                
                    <option value="1685" data-chained="IE">
                        Kilkenny </option>
                
                    <option value="1472" data-chained="GR">
                        Kilkis </option>
                
                    <option value="1439" data-chained="GN">
                        Kindia </option>
                
                    <option value="1859" data-chained="JM">
                        Kingston </option>
                
                    <option value="1167" data-chained="GB">
                        Kingston upon Hull, City of </option>
                
                    <option value="1168" data-chained="GB">
                        Kingston upon Thames </option>
                
                    <option value="537" data-chained="CD">
                        Kinshasa </option>
                
                    <option value="3782" data-chained="TR">
                        Kirikkale </option>
                
                    <option value="3747" data-chained="TR">
                        Kirklareli </option>
                
                    <option value="1169" data-chained="GB">
                        Kirklees </option>
                
                    <option value="3194" data-chained="RU">
                        Kirov </option>
                
                    <option value="3847" data-chained="UA">
                        Kirovohrads'ka Oblast' </option>
                
                    <option value="3748" data-chained="TR">
                        Kirsehir </option>
                
                    <option value="385" data-chained="BI">
                        Kirundo </option>
                
                    <option value="2277" data-chained="MK">
                        Kisela Voda </option>
                
                    <option value="246" data-chained="BD">
                        Kishorganj </option>
                
                    <option value="1440" data-chained="GN">
                        Kissidougou </option>
                
                    <option value="3889" data-chained="UG">
                        Kitgum </option>
                
                    <option value="538" data-chained="CD">
                        Kivu </option>
                
                    <option value="2731" data-chained="NZ">
                        Kiwitea </option>
                
                    <option value="1803" data-chained="IS">
                        Kjosarsysla </option>
                
                    <option value="2115" data-chained="LT">
                        Klaipedos Apskritis </option>
                
                    <option value="2278" data-chained="MK">
                        Klecevce </option>
                
                    <option value="3594" data-chained="TG">
                        Klouto </option>
                
                    <option value="1170" data-chained="GB">
                        Knowsley </option>
                
                    <option value="3378" data-chained="SI">
                        Kobarid </option>
                
                    <option value="838" data-chained="DK">
                        Kobenhavn </option>
                
                    <option value="3379" data-chained="SI">
                        Kobilje </option>
                
                    <option value="3749" data-chained="TR">
                        Kocaeli </option>
                
                    <option value="2279" data-chained="MK">
                        Kocani </option>
                
                    <option value="3460" data-chained="SI">
                        Kocevje </option>
                
                    <option value="1887" data-chained="JP">
                        Kochi </option>
                
                    <option value="2602" data-chained="NG">
                        Kogi </option>
                
                    <option value="1765" data-chained="IR">
                        Kohkiluyeh va Buyer Ahmadi </option>
                
                    <option value="964" data-chained="EE">
                        Kohtla-Jarve </option>
                
                    <option value="3510" data-chained="SN">
                        Kolda </option>
                
                    <option value="791" data-chained="CZ">
                        Kolin </option>
                
                    <option value="1618" data-chained="HU">
                        Komarom-Esztergom </option>
                
                    <option value="3380" data-chained="SI">
                        Komen </option>
                
                    <option value="3195" data-chained="RU">
                        Komi </option>
                
                    <option value="3196" data-chained="RU">
                        Komi-Permyak </option>
                
                    <option value="312" data-chained="BF">
                        Komoe </option>
                
                    <option value="313" data-chained="BF">
                        Komondjari </option>
                
                    <option value="314" data-chained="BF">
                        Kompienga </option>
                
                    <option value="4065" data-chained="VN">
                        Kon Tum </option>
                
                    <option value="27" data-chained="AF">
                        Konar </option>
                
                    <option value="2280" data-chained="MK">
                        Konce </option>
                
                    <option value="2281" data-chained="MK">
                        Kondovo </option>
                
                    <option value="36" data-chained="AF">
                        Kondoz </option>
                
                    <option value="3020" data-chained="PL">
                        Konin </option>
                
                    <option value="2282" data-chained="MK">
                        Konopiste </option>
                
                    <option value="3774" data-chained="TR">
                        Konya </option>
                
                    <option value="1804" data-chained="IS">
                        Kopavogur </option>
                
                    <option value="3381" data-chained="SI">
                        Koper-Capodistria </option>
                
                    <option value="1582" data-chained="HR">
                        Koprivnicko-Krizevacka </option>
                
                    <option value="60" data-chained="AL">
                        Korce </option>
                
                    <option value="1773" data-chained="IR">
                        Kordestan </option>
                
                    <option value="609" data-chained="CI">
                        Korhogo </option>
                
                    <option value="1503" data-chained="GR">
                        Korinthia </option>
                
                    <option value="3197" data-chained="RU">
                        Koryak </option>
                
                    <option value="2283" data-chained="MK">
                        Kosel </option>
                
                    <option value="2675" data-chained="NP">
                        Kosi </option>
                
                    <option value="3483" data-chained="SK">
                        Kosice </option>
                
                    <option value="1050" data-chained="FM">
                        Kosrae </option>
                
                    <option value="315" data-chained="BF">
                        Kossi </option>
                
                    <option value="3198" data-chained="RU">
                        Kostroma </option>
                
                    <option value="3021" data-chained="PL">
                        Koszalin </option>
                
                    <option value="70" data-chained="AM">
                        Kotayk' </option>
                
                    <option value="1453" data-chained="GN">
                        Koubia </option>
                
                    <option value="414" data-chained="BN">
                        Kouffo </option>
                
                    <option value="563" data-chained="CG">
                        Kouilou </option>
                
                    <option value="2362" data-chained="ML">
                        Koulikoro </option>
                
                    <option value="316" data-chained="BF">
                        Koulpelogo </option>
                
                    <option value="1441" data-chained="GN">
                        Koundara </option>
                
                    <option value="295" data-chained="BF">
                        Kouritenga </option>
                
                    <option value="1442" data-chained="GN">
                        Kouroussa </option>
                
                    <option value="317" data-chained="BF">
                        Kourweogo </option>
                
                    <option value="1477" data-chained="GR">
                        Kozani </option>
                
                    <option value="3382" data-chained="SI">
                        Kozje </option>
                
                    <option value="3600" data-chained="TG">
                        Kpagouda </option>
                
                    <option value="3669" data-chained="TH">
                        Krabi </option>
                
                    <option value="1938" data-chained="KH">
                        Kracheh </option>
                
                    <option value="3022" data-chained="PL">
                        Krakow </option>
                
                    <option value="805" data-chained="CZ">
                        Kralovehradecky Kraj </option>
                
                    <option value="3383" data-chained="SI">
                        Kranj </option>
                
                    <option value="3384" data-chained="SI">
                        Kranjska Gora </option>
                
                    <option value="1583" data-chained="HR">
                        Krapinsko-Zagorska </option>
                
                    <option value="3199" data-chained="RU">
                        Krasnodar </option>
                
                    <option value="3200" data-chained="RU">
                        Krasnoyarsk </option>
                
                    <option value="2284" data-chained="MK">
                        Kratovo </option>
                
                    <option value="3321" data-chained="SE">
                        Kristianstads Lan </option>
                
                    <option value="2285" data-chained="MK">
                        Kriva Palanka </option>
                
                    <option value="2286" data-chained="MK">
                        Krivogastani </option>
                
                    <option value="3322" data-chained="SE">
                        Kronobergs Lan </option>
                
                    <option value="3023" data-chained="PL">
                        Krosno </option>
                
                    <option value="3385" data-chained="SI">
                        Krsko </option>
                
                    <option value="3646" data-chained="TH">
                        Krung Thep </option>
                
                    <option value="2287" data-chained="MK">
                        Krusevo </option>
                
                    <option value="3848" data-chained="UA">
                        Krym </option>
                
                    <option value="3681" data-chained="TJ">
                        Kuhistoni Badakhshon </option>
                
                    <option value="3056" data-chained="PL">
                        Kujawsko-Pomorskie </option>
                
                    <option value="61" data-chained="AL">
                        Kukes </option>
                
                    <option value="2288" data-chained="MK">
                        Kuklis </option>
                
                    <option value="2289" data-chained="MK">
                        Kukurecani </option>
                
                    <option value="2136" data-chained="LV">
                        Kuldigas </option>
                
                    <option value="1888" data-chained="JP">
                        Kumamoto </option>
                
                    <option value="2290" data-chained="MK">
                        Kumanovo </option>
                
                    <option value="2567" data-chained="NA">
                        Kunene </option>
                
                    <option value="3386" data-chained="SI">
                        Kungota </option>
                
                    <option value="161" data-chained="AZ">
                        Kurdamir </option>
                
                    <option value="3310" data-chained="SD">
                        Kurdufan </option>
                
                    <option value="343" data-chained="BG">
                        Kurdzhali </option>
                
                    <option value="3201" data-chained="RU">
                        Kurgan </option>
                
                    <option value="247" data-chained="BD">
                        Kurigram </option>
                
                    <option value="3202" data-chained="RU">
                        Kursk </option>
                
                    <option value="2078" data-chained="LK">
                        Kurunegala </option>
                
                    <option value="248" data-chained="BD">
                        Kushtia </option>
                
                    <option value="3750" data-chained="TR">
                        Kutahya </option>
                
                    <option value="3461" data-chained="SI">
                        Kuzma </option>
                
                    <option value="1996" data-chained="KR">
                        Kwangju-jikhalsi </option>
                
                    <option value="2594" data-chained="NG">
                        Kwara </option>
                
                    <option value="4121" data-chained="ZA">
                        KwaZulu-Natal </option>
                
                    <option value="501" data-chained="BW">
                        Kweneng </option>
                
                    <option value="3890" data-chained="UG">
                        Kyenjojo </option>
                
                    <option value="1991" data-chained="KR">
                        Kyonggi-do </option>
                
                    <option value="1992" data-chained="KR">
                        Kyongsang-bukto </option>
                
                    <option value="1998" data-chained="KR">
                        Kyongsang-namdo </option>
                
                    <option value="1889" data-chained="JP">
                        Kyoto </option>
                
                    <option value="780" data-chained="CY">
                        Kyrenia </option>
                
                    <option value="344" data-chained="BG">
                        Kyustendil </option>
                
                    <option value="3849" data-chained="UA">
                        Kyyiv </option>
                
                    <option value="3850" data-chained="UA">
                        Kyyivs'ka Oblast' </option>
                
                    <option value="3852" data-chained="UA">
                        L'vivs'ka Oblast' </option>
                
                    <option value="867" data-chained="DO">
                        La Altagracia </option>
                
                    <option value="2963" data-chained="PH">
                        La Carlota </option>
                
                    <option value="2214" data-chained="MC">
                        La Condamine </option>
                
                    <option value="3294" data-chained="SC">
                        La Digue </option>
                
                    <option value="720" data-chained="CO">
                        La Guajira </option>
                
                    <option value="757" data-chained="CU">
                        La Habana </option>
                
                    <option value="2832" data-chained="PE">
                        La Libertad </option>
                
                    <option value="3544" data-chained="SV">
                        La Libertad </option>
                
                    <option value="3" data-chained="AD">
                        La Massana </option>
                
                    <option value="104" data-chained="AR">
                        La Pampa </option>
                
                    <option value="1570" data-chained="HN">
                        La Paz </option>
                
                    <option value="424" data-chained="BO">
                        La Paz </option>
                
                    <option value="3545" data-chained="SV">
                        La Paz </option>
                
                    <option value="105" data-chained="AR">
                        La Rioja </option>
                
                    <option value="1007" data-chained="ES">
                        La Rioja </option>
                
                    <option value="3295" data-chained="SC">
                        La Riviere Anglaise </option>
                
                    <option value="869" data-chained="DO">
                        La Romana </option>
                
                    <option value="2900" data-chained="PH">
                        La Union </option>
                
                    <option value="3546" data-chained="SV">
                        La Union </option>
                
                    <option value="885" data-chained="DO">
                        La Vega </option>
                
                    <option value="2438" data-chained="MV">
                        Laamu </option>
                
                    <option value="966" data-chained="EE">
                        Laane-Virumaa </option>
                
                    <option value="965" data-chained="EE">
                        Laanemaa </option>
                
                    <option value="2207" data-chained="MA">
                        Laayoune </option>
                
                    <option value="1454" data-chained="GN">
                        Labe </option>
                
                    <option value="2053" data-chained="LC">
                        Laborie </option>
                
                    <option value="2525" data-chained="MY">
                        Labuan </option>
                
                    <option value="2291" data-chained="MK">
                        Labunista </option>
                
                    <option value="3579" data-chained="TD">
                        Lac </option>
                
                    <option value="162" data-chained="AZ">
                        Lacin </option>
                
                    <option value="28" data-chained="AF">
                        Laghman </option>
                
                    <option value="907" data-chained="DZ">
                        Laghouat </option>
                
                    <option value="1374" data-chained="GE">
                        Lagodekhis Raioni </option>
                
                    <option value="2582" data-chained="NG">
                        Lagos </option>
                
                    <option value="2897" data-chained="PH">
                        Laguna </option>
                
                    <option value="4119" data-chained="YE">
                        Lahij </option>
                
                    <option value="4034" data-chained="VN">
                        Lai Chau </option>
                
                    <option value="2732" data-chained="NZ">
                        Lake </option>
                
                    <option value="1508" data-chained="GR">
                        Lakonia </option>
                
                    <option value="615" data-chained="CI">
                        Lakota </option>
                
                    <option value="1719" data-chained="IN">
                        Lakshadweep </option>
                
                    <option value="249" data-chained="BD">
                        Laksmipur </option>
                
                    <option value="250" data-chained="BD">
                        Lalmonirhat </option>
                
                    <option value="4035" data-chained="VN">
                        Lam Dong </option>
                
                    <option value="3595" data-chained="TG">
                        Lama-Kara </option>
                
                    <option value="2833" data-chained="PE">
                        Lambayeque </option>
                
                    <option value="1171" data-chained="GB">
                        Lambeth </option>
                
                    <option value="3613" data-chained="TH">
                        Lampang </option>
                
                    <option value="3612" data-chained="TH">
                        Lamphun </option>
                
                    <option value="1659" data-chained="ID">
                        Lampung </option>
                
                    <option value="2898" data-chained="PH">
                        Lanao del Norte </option>
                
                    <option value="2899" data-chained="PH">
                        Lanao del Sur </option>
                
                    <option value="1172" data-chained="GB">
                        Lancashire </option>
                
                    <option value="1375" data-chained="GE">
                        Lanch'khut'is Raioni </option>
                
                    <option value="4044" data-chained="VN">
                        Lang Son </option>
                
                    <option value="1065" data-chained="FR">
                        Languedoc-Roussillon </option>
                
                    <option value="163" data-chained="AZ">
                        Lankaran </option>
                
                    <option value="4066" data-chained="VN">
                        Lao Cai </option>
                
                    <option value="2964" data-chained="PH">
                        Laoag </option>
                
                    <option value="1687" data-chained="IE">
                        Laois </option>
                
                    <option value="1040" data-chained="FI">
                        Lapland </option>
                
                    <option value="2965" data-chained="PH">
                        Lapu-Lapu </option>
                
                    <option value="2223" data-chained="MD">
                        Lapusna </option>
                
                    <option value="4014" data-chained="VE">
                        Lara </option>
                
                    <option value="2213" data-chained="MA">
                        Larache </option>
                
                    <option value="1487" data-chained="GR">
                        Larisa </option>
                
                    <option value="781" data-chained="CY">
                        Larnaca </option>
                
                    <option value="1272" data-chained="GB">
                        Larne </option>
                
                    <option value="759" data-chained="CU">
                        Las Tunas </option>
                
                    <option value="1512" data-chained="GR">
                        Lasithi </option>
                
                    <option value="3387" data-chained="SI">
                        Lasko </option>
                
                    <option value="3972" data-chained="UY">
                        Lavalleja </option>
                
                    <option value="2436" data-chained="MV">
                        Laviyani </option>
                
                    <option value="1832" data-chained="IT">
                        Lazio </option>
                
                    <option value="3687" data-chained="TM">
                        Lebap </option>
                
                    <option value="1173" data-chained="GB">
                        Leeds </option>
                
                    <option value="2966" data-chained="PH">
                        Legaspi </option>
                
                    <option value="3024" data-chained="PL">
                        Legnica </option>
                
                    <option value="1174" data-chained="GB">
                        Leicester </option>
                
                    <option value="1175" data-chained="GB">
                        Leicestershire </option>
                
                    <option value="3081" data-chained="PT">
                        Leiria </option>
                
                    <option value="1686" data-chained="IE">
                        Leitrim </option>
                
                    <option value="564" data-chained="CG">
                        Lekoumou </option>
                
                    <option value="1455" data-chained="GN">
                        Lelouma </option>
                
                    <option value="2648" data-chained="NL">
                        Lelystad </option>
                
                    <option value="1571" data-chained="HN">
                        Lempira </option>
                
                    <option value="3462" data-chained="SI">
                        Lenart </option>
                
                    <option value="3203" data-chained="RU">
                        Leningrad </option>
                
                    <option value="1376" data-chained="GE">
                        Lentekhis Raioni </option>
                
                    <option value="2626" data-chained="NI">
                        Leon </option>
                
                    <option value="318" data-chained="BF">
                        Leraba </option>
                
                    <option value="2105" data-chained="LS">
                        Leribe </option>
                
                    <option value="164" data-chained="AZ">
                        Lerik </option>
                
                    <option value="1517" data-chained="GR">
                        Lesvos </option>
                
                    <option value="3025" data-chained="PL">
                        Leszno </option>
                
                    <option value="1492" data-chained="GR">
                        Levkas </option>
                
                    <option value="1176" data-chained="GB">
                        Lewisham </option>
                
                    <option value="2901" data-chained="PH">
                        Leyte </option>
                
                    <option value="62" data-chained="AL">
                        Lezhe </option>
                
                    <option value="484" data-chained="BT">
                        Lhuntshi </option>
                
                    <option value="694" data-chained="CN">
                        Liaoning </option>
                
                    <option value="2042" data-chained="LB">
                        Liban-Nord </option>
                
                    <option value="2045" data-chained="LB">
                        Liban-Sud </option>
                
                    <option value="792" data-chained="CZ">
                        Liberec </option>
                
                    <option value="806" data-chained="CZ">
                        Liberecky Kraj </option>
                
                    <option value="661" data-chained="CL">
                        Libertador General Bernardo O'Higgins </option>
                
                    <option value="1584" data-chained="HR">
                        Licko-Senjska </option>
                
                    <option value="282" data-chained="BE">
                        Liege </option>
                
                    <option value="1833" data-chained="IT">
                        Liguria </option>
                
                    <option value="2476" data-chained="MW">
                        Likoma </option>
                
                    <option value="565" data-chained="CG">
                        Likouala </option>
                
                    <option value="2461" data-chained="MW">
                        Lilongwe </option>
                
                    <option value="2834" data-chained="PE">
                        Lima </option>
                
                    <option value="783" data-chained="CY">
                        Limassol </option>
                
                    <option value="1273" data-chained="GB">
                        Limavady </option>
                
                    <option value="2137" data-chained="LV">
                        Limbazu </option>
                
                    <option value="283" data-chained="BE">
                        Limburg </option>
                
                    <option value="2639" data-chained="NL">
                        Limburg </option>
                
                    <option value="1688" data-chained="IE">
                        Limerick </option>
                
                    <option value="745" data-chained="CR">
                        Limon </option>
                
                    <option value="1066" data-chained="FR">
                        Limousin </option>
                
                    <option value="4127" data-chained="ZA">
                        Limpopo </option>
                
                    <option value="1177" data-chained="GB">
                        Lincolnshire </option>
                
                    <option value="3819" data-chained="TZ">
                        Lindi </option>
                
                    <option value="1952" data-chained="KI">
                        Line Islands </option>
                
                    <option value="2967" data-chained="PH">
                        Lipa </option>
                
                    <option value="3204" data-chained="RU">
                        Lipetsk </option>
                
                    <option value="2292" data-chained="MK">
                        Lipkovo </option>
                
                    <option value="3082" data-chained="PT">
                        Lisboa </option>
                
                    <option value="1274" data-chained="GB">
                        Lisburn </option>
                
                    <option value="3463" data-chained="SI">
                        Litija </option>
                
                    <option value="1465" data-chained="GQ">
                        Litoral </option>
                
                    <option value="668" data-chained="CM">
                        Littoral </option>
                
                    <option value="416" data-chained="BN">
                        Littoral </option>
                
                    <option value="1178" data-chained="GB">
                        Liverpool </option>
                
                    <option value="3388" data-chained="SI">
                        Ljubljana </option>
                
                    <option value="3389" data-chained="SI">
                        Ljubno </option>
                
                    <option value="3464" data-chained="SI">
                        Ljutomer </option>
                
                    <option value="550" data-chained="CF">
                        Lobaye </option>
                
                    <option value="3026" data-chained="PL">
                        Lodz </option>
                
                    <option value="3057" data-chained="PL">
                        Lodzkie </option>
                
                    <option value="3625" data-chained="TH">
                        Loei </option>
                
                    <option value="2096" data-chained="LR">
                        Lofa </option>
                
                    <option value="3390" data-chained="SI">
                        Logatec </option>
                
                    <option value="3580" data-chained="TD">
                        Logone Occidental </option>
                
                    <option value="3581" data-chained="TD">
                        Logone Oriental </option>
                
                    <option value="948" data-chained="EC">
                        Loja </option>
                
                    <option value="1456" data-chained="GN">
                        Lola </option>
                
                    <option value="1834" data-chained="IT">
                        Lombardia </option>
                
                    <option value="3596" data-chained="TG">
                        Lome </option>
                
                    <option value="3027" data-chained="PL">
                        Lomza </option>
                
                    <option value="1179" data-chained="GB">
                        London, City of </option>
                
                    <option value="4036" data-chained="VN">
                        Long An </option>
                
                    <option value="461" data-chained="BS">
                        Long Island </option>
                
                    <option value="1689" data-chained="IE">
                        Longford </option>
                
                    <option value="3640" data-chained="TH">
                        Lop Buri </option>
                
                    <option value="1775" data-chained="IR">
                        Lorestan </option>
                
                    <option value="2835" data-chained="PE">
                        Loreto </option>
                
                    <option value="319" data-chained="BF">
                        Loroum </option>
                
                    <option value="1067" data-chained="FR">
                        Lorraine </option>
                
                    <option value="71" data-chained="AM">
                        Lorri </option>
                
                    <option value="662" data-chained="CL">
                        Los Lagos </option>
                
                    <option value="949" data-chained="EC">
                        Los Rios </option>
                
                    <option value="2816" data-chained="PA">
                        Los Santos </option>
                
                    <option value="3465" data-chained="SI">
                        Loska Dolina </option>
                
                    <option value="3391" data-chained="SI">
                        Loski Potok </option>
                
                    <option value="1099" data-chained="GB">
                        Lothian </option>
                
                    <option value="2032" data-chained="LA">
                        Louang Namtha </option>
                
                    <option value="2040" data-chained="LA">
                        Louangphrabang </option>
                
                    <option value="3507" data-chained="SN">
                        Louga </option>
                
                    <option value="3927" data-chained="US">
                        Louisiana </option>
                
                    <option value="1690" data-chained="IE">
                        Louth </option>
                
                    <option value="345" data-chained="BG">
                        Lovech </option>
                
                    <option value="1421" data-chained="GM">
                        Lower River </option>
                
                    <option value="29" data-chained="AF">
                        Lowgar </option>
                
                    <option value="2293" data-chained="MK">
                        Lozovo </option>
                
                    <option value="93" data-chained="AO">
                        Luanda </option>
                
                    <option value="4133" data-chained="ZM">
                        Luapula </option>
                
                    <option value="3058" data-chained="PL">
                        Lubelskie </option>
                
                    <option value="3028" data-chained="PL">
                        Lublin </option>
                
                    <option value="3569" data-chained="SZ">
                        Lubombo </option>
                
                    <option value="3059" data-chained="PL">
                        Lubuskie </option>
                
                    <option value="3466" data-chained="SI">
                        Luce </option>
                
                    <option value="2968" data-chained="PH">
                        Lucena </option>
                
                    <option value="2545" data-chained="NA">
                        Luderitz </option>
                
                    <option value="2138" data-chained="LV">
                        Ludzas </option>
                
                    <option value="3851" data-chained="UA">
                        Luhans'ka Oblast' </option>
                
                    <option value="3392" data-chained="SI">
                        Lukovica </option>
                
                    <option value="2294" data-chained="MK">
                        Lukovo </option>
                
                    <option value="2676" data-chained="NP">
                        Lumbini </option>
                
                    <option value="90" data-chained="AO">
                        Lunda Norte </option>
                
                    <option value="91" data-chained="AO">
                        Lunda Sul </option>
                
                    <option value="4138" data-chained="ZM">
                        Lusaka </option>
                
                    <option value="1180" data-chained="GB">
                        Luton </option>
                
                    <option value="284" data-chained="BE">
                        Luxembourg </option>
                
                    <option value="2125" data-chained="LU">
                        Luxembourg </option>
                
                    <option value="581" data-chained="CH">
                        Luzern </option>
                
                    <option value="909" data-chained="DZ">
                        M'sila </option>
                
                    <option value="1861" data-chained="JO">
                        Ma </option>
                
                    <option value="4112" data-chained="YE">
                        Ma'rib </option>
                
                    <option value="2406" data-chained="MO">
                        Macau </option>
                
                    <option value="1422" data-chained="GM">
                        MacCarthy Island </option>
                
                    <option value="1443" data-chained="GN">
                        Macenta </option>
                
                    <option value="2477" data-chained="MW">
                        Machinga </option>
                
                    <option value="2733" data-chained="NZ">
                        Mackenzie </option>
                
                    <option value="2856" data-chained="PG">
                        Madang </option>
                
                    <option value="3702" data-chained="TN">
                        Madanin </option>
                
                    <option value="251" data-chained="BD">
                        Madaripur </option>
                
                    <option value="3079" data-chained="PT">
                        Madeira </option>
                
                    <option value="1738" data-chained="IN">
                        Madhya Pradesh </option>
                
                    <option value="374" data-chained="BH">
                        Madinat </option>
                
                    <option value="3115" data-chained="QA">
                        Madinat ach Shamal </option>
                
                    <option value="376" data-chained="BH">
                        Madinat Hamad </option>
                
                    <option value="2139" data-chained="LV">
                        Madonas </option>
                
                    <option value="2836" data-chained="PE">
                        Madre de Dios </option>
                
                    <option value="1008" data-chained="ES">
                        Madrid </option>
                
                    <option value="2627" data-chained="NI">
                        Madriz </option>
                
                    <option value="3608" data-chained="TH">
                        Mae Hong Son </option>
                
                    <option value="2106" data-chained="LS">
                        Mafeteng </option>
                
                    <option value="3205" data-chained="RU">
                        Magadan </option>
                
                    <option value="663" data-chained="CL">
                        Magallanes y de la Antartica Chilena </option>
                
                    <option value="740" data-chained="CO">
                        Magdalena </option>
                
                    <option value="1276" data-chained="GB">
                        Magherafelt </option>
                
                    <option value="1490" data-chained="GR">
                        Magnisia </option>
                
                    <option value="2918" data-chained="PH">
                        Maguindanao </option>
                
                    <option value="252" data-chained="BD">
                        Magura </option>
                
                    <option value="2372" data-chained="MM">
                        Magwe </option>
                
                    <option value="3630" data-chained="TH">
                        Maha Sarakham </option>
                
                    <option value="1554" data-chained="GY">
                        Mahaica-Berbice </option>
                
                    <option value="2230" data-chained="MG">
                        Mahajanga </option>
                
                    <option value="2677" data-chained="NP">
                        Mahakali </option>
                
                    <option value="1720" data-chained="IN">
                        Maharashtra </option>
                
                    <option value="511" data-chained="BY">
                        Mahilyowskaya Voblasts' </option>
                
                    <option value="3930" data-chained="US">
                        Maine </option>
                
                    <option value="765" data-chained="CV">
                        Maio </option>
                
                    <option value="3467" data-chained="SI">
                        Majsperk </option>
                
                    <option value="386" data-chained="BI">
                        Makamba </option>
                
                    <option value="2295" data-chained="MK">
                        Makedonska Kamenica </option>
                
                    <option value="2296" data-chained="MK">
                        Makedonski Brod </option>
                
                    <option value="3279" data-chained="SB">
                        Makira </option>
                
                    <option value="3269" data-chained="SA">
                        Makkah </option>
                
                    <option value="3274" data-chained="SB">
                        Malaita </option>
                
                    <option value="4086" data-chained="VU">
                        Malakula </option>
                
                    <option value="4092" data-chained="VU">
                        Malampa </option>
                
                    <option value="86" data-chained="AO">
                        Malanje </option>
                
                    <option value="3751" data-chained="TR">
                        Malatya </option>
                
                    <option value="3973" data-chained="UY">
                        Maldonado </option>
                
                    <option value="1444" data-chained="GN">
                        Mali </option>
                
                    <option value="3323" data-chained="SE">
                        Malmohus Lan </option>
                
                    <option value="3060" data-chained="PL">
                        Malopolskie </option>
                
                    <option value="2546" data-chained="NA">
                        Maltahohe </option>
                
                    <option value="1668" data-chained="ID">
                        Maluku </option>
                
                    <option value="1669" data-chained="ID">
                        Maluku Utara </option>
                
                    <option value="2734" data-chained="NZ">
                        Malvern </option>
                
                    <option value="547" data-chained="CF">
                        Mambere-Kadei </option>
                
                    <option value="1445" data-chained="GN">
                        Mamou </option>
                
                    <option value="630" data-chained="CI">
                        Man </option>
                
                    <option value="950" data-chained="EC">
                        Manabi </option>
                
                    <option value="2628" data-chained="NI">
                        Managua </option>
                
                    <option value="2796" data-chained="NZ">
                        Manaia </option>
                
                    <option value="2735" data-chained="NZ">
                        Manawatu </option>
                
                    <option value="1848" data-chained="JM">
                        Manchester </option>
                
                    <option value="1181" data-chained="GB">
                        Manchester </option>
                
                    <option value="2373" data-chained="MM">
                        Mandalay </option>
                
                    <option value="2969" data-chained="PH">
                        Mandaue </option>
                
                    <option value="1457" data-chained="GN">
                        Mandiana </option>
                
                    <option value="2019" data-chained="KZ">
                        Mangghystau </option>
                
                    <option value="3597" data-chained="TG">
                        Mango </option>
                
                    <option value="2462" data-chained="MW">
                        Mangochi </option>
                
                    <option value="2736" data-chained="NZ">
                        Mangonui </option>
                
                    <option value="2536" data-chained="MZ">
                        Manica </option>
                
                    <option value="4139" data-chained="ZW">
                        Manicaland </option>
                
                    <option value="541" data-chained="CD">
                        Maniema </option>
                
                    <option value="253" data-chained="BD">
                        Manikganj </option>
                
                    <option value="2970" data-chained="PH">
                        Manila </option>
                
                    <option value="2737" data-chained="NZ">
                        Maniototo </option>
                
                    <option value="1721" data-chained="IN">
                        Manipur </option>
                
                    <option value="3752" data-chained="TR">
                        Manisa </option>
                
                    <option value="521" data-chained="CA">
                        Manitoba </option>
                
                    <option value="616" data-chained="CI">
                        Mankono </option>
                
                    <option value="2090" data-chained="LK">
                        Mannar </option>
                
                    <option value="3712" data-chained="TN">
                        Manouba </option>
                
                    <option value="2857" data-chained="PG">
                        Manus </option>
                
                    <option value="3570" data-chained="SZ">
                        Manzini </option>
                
                    <option value="2530" data-chained="MZ">
                        Maputo </option>
                
                    <option value="3820" data-chained="TZ">
                        Mara </option>
                
                    <option value="2578" data-chained="NE">
                        Maradi </option>
                
                    <option value="3143" data-chained="RO">
                        Maramures </option>
                
                    <option value="439" data-chained="BR">
                        Maranhao </option>
                
                    <option value="2971" data-chained="PH">
                        Marawi </option>
                
                    <option value="1835" data-chained="IT">
                        Marche </option>
                
                    <option value="3775" data-chained="TR">
                        Mardin </option>
                
                    <option value="870" data-chained="DO">
                        Maria Trinidad Sanchez </option>
                
                    <option value="3468" data-chained="SI">
                        Maribor </option>
                
                    <option value="2561" data-chained="NA">
                        Mariental </option>
                
                    <option value="2116" data-chained="LT">
                        Marijampoles Apskritis </option>
                
                    <option value="2902" data-chained="PH">
                        Marinduque </option>
                
                    <option value="3206" data-chained="RU">
                        Mariy-El </option>
                
                    <option value="1783" data-chained="IR">
                        Markazi </option>
                
                    <option value="2738" data-chained="NZ">
                        Marlborough </option>
                
                    <option value="1377" data-chained="GE">
                        Marneulis Raioni </option>
                
                    <option value="3531" data-chained="SR">
                        Marowijne </option>
                
                    <option value="2193" data-chained="MA">
                        Marrakech </option>
                
                    <option value="473" data-chained="BS">
                        Marsh Harbour </option>
                
                    <option value="3931" data-chained="US">
                        Marshall Islands </option>
                
                    <option value="1378" data-chained="GE">
                        Martvilis Raioni </option>
                
                    <option value="3688" data-chained="TM">
                        Mary </option>
                
                    <option value="2097" data-chained="LR">
                        Maryland </option>
                
                    <option value="3929" data-chained="US">
                        Maryland </option>
                
                    <option value="165" data-chained="AZ">
                        Masalli </option>
                
                    <option value="2629" data-chained="NI">
                        Masaya </option>
                
                    <option value="2903" data-chained="PH">
                        Masbate </option>
                
                    <option value="908" data-chained="DZ">
                        Mascara </option>
                
                    <option value="2107" data-chained="LS">
                        Maseru </option>
                
                    <option value="4141" data-chained="ZW">
                        Mashonaland Central </option>
                
                    <option value="4142" data-chained="ZW">
                        Mashonaland East </option>
                
                    <option value="4143" data-chained="ZW">
                        Mashonaland West </option>
                
                    <option value="2807" data-chained="OM">
                        Masqat </option>
                
                    <option value="3928" data-chained="US">
                        Massachusetts </option>
                
                    <option value="2739" data-chained="NZ">
                        Masterton </option>
                
                    <option value="4146" data-chained="ZW">
                        Masvingo </option>
                
                    <option value="4144" data-chained="ZW">
                        Matabeleland North </option>
                
                    <option value="4145" data-chained="ZW">
                        Matabeleland South </option>
                
                    <option value="2630" data-chained="NI">
                        Matagalpa </option>
                
                    <option value="2079" data-chained="LK">
                        Matale </option>
                
                    <option value="2740" data-chained="NZ">
                        Matamata </option>
                
                    <option value="750" data-chained="CU">
                        Matanzas </option>
                
                    <option value="2080" data-chained="LK">
                        Matara </option>
                
                    <option value="440" data-chained="BR">
                        Mato Grosso </option>
                
                    <option value="438" data-chained="BR">
                        Mato Grosso do Sul </option>
                
                    <option value="1001" data-chained="EG">
                        Matruh </option>
                
                    <option value="664" data-chained="CL">
                        Maule </option>
                
                    <option value="2061" data-chained="LI">
                        Mauren </option>
                
                    <option value="2297" data-chained="MK">
                        Mavrovi Anovi </option>
                
                    <option value="462" data-chained="BS">
                        Mayaguana </option>
                
                    <option value="3799" data-chained="TT">
                        Mayaro </option>
                
                    <option value="1691" data-chained="IE">
                        Mayo </option>
                
                    <option value="3582" data-chained="TD">
                        Mayo-Kebbi </option>
                
                    <option value="1756" data-chained="IQ">
                        Maysan </option>
                
                    <option value="3891" data-chained="UG">
                        Mayuge </option>
                
                    <option value="1784" data-chained="IR">
                        Mazandaran </option>
                
                    <option value="3061" data-chained="PL">
                        Mazowieckie </option>
                
                    <option value="631" data-chained="CI">
                        Mbahiakro </option>
                
                    <option value="3892" data-chained="UG">
                        Mbale </option>
                
                    <option value="3821" data-chained="TZ">
                        Mbeya </option>
                
                    <option value="551" data-chained="CF">
                        Mbomou </option>
                
                    <option value="2463" data-chained="MW">
                        Mchinji </option>
                
                    <option value="1692" data-chained="IE">
                        Meath </option>
                
                    <option value="2678" data-chained="NP">
                        Mechi </option>
                
                    <option value="825" data-chained="DE">
                        Mecklenburg-Vorpommern </option>
                
                    <option value="892" data-chained="DZ">
                        Medea </option>
                
                    <option value="1585" data-chained="HR">
                        Medimurska </option>
                
                    <option value="3393" data-chained="SI">
                        Medvode </option>
                
                    <option value="1182" data-chained="GB">
                        Medway </option>
                
                    <option value="2441" data-chained="MV">
                        Meemu </option>
                
                    <option value="1722" data-chained="IN">
                        Meghalaya </option>
                
                    <option value="3144" data-chained="RO">
                        Mehedinti </option>
                
                    <option value="254" data-chained="BD">
                        Meherpur </option>
                
                    <option value="2194" data-chained="MA">
                        Meknes </option>
                
                    <option value="2515" data-chained="MY">
                        Melaka </option>
                
                    <option value="793" data-chained="CZ">
                        Melnik </option>
                
                    <option value="106" data-chained="AR">
                        Mendoza </option>
                
                    <option value="2693" data-chained="NR">
                        Meneng </option>
                
                    <option value="3394" data-chained="SI">
                        Menges </option>
                
                    <option value="4015" data-chained="VE">
                        Merida </option>
                
                    <option value="1092" data-chained="GB">
                        Merseyside </option>
                
                    <option value="1326" data-chained="GB">
                        Merthyr Tydfil </option>
                
                    <option value="1183" data-chained="GB">
                        Merton </option>
                
                    <option value="2298" data-chained="MK">
                        Meseista </option>
                
                    <option value="1506" data-chained="GR">
                        Messinia </option>
                
                    <option value="1379" data-chained="GE">
                        Mestiis Raioni </option>
                
                    <option value="721" data-chained="CO">
                        Meta </option>
                
                    <option value="3395" data-chained="SI">
                        Metlika </option>
                
                    <option value="2494" data-chained="MX">
                        Mexico </option>
                
                    <option value="3396" data-chained="SI">
                        Mezica </option>
                
                    <option value="3932" data-chained="US">
                        Michigan </option>
                
                    <option value="2495" data-chained="MX">
                        Michoacan de Ocampo </option>
                
                    <option value="2054" data-chained="LC">
                        Micoud </option>
                
                    <option value="1105" data-chained="GB">
                        Mid Glamorgan </option>
                
                    <option value="1184" data-chained="GB">
                        Middlesbrough </option>
                
                    <option value="1068" data-chained="FR">
                        Midi-Pyrenees </option>
                
                    <option value="2006" data-chained="KY">
                        Midland </option>
                
                    <option value="4140" data-chained="ZW">
                        Midlands </option>
                
                    <option value="1301" data-chained="GB">
                        Midlothian </option>
                
                    <option value="1890" data-chained="JP">
                        Mie </option>
                
                    <option value="336" data-chained="BG">
                        Mikhaylovgrad </option>
                
                    <option value="928" data-chained="DZ">
                        Mila </option>
                
                    <option value="2847" data-chained="PG">
                        Milne Bay </option>
                
                    <option value="1185" data-chained="GB">
                        Milton Keynes </option>
                
                    <option value="441" data-chained="BR">
                        Minas Gerais </option>
                
                    <option value="2904" data-chained="PH">
                        Mindoro Occidental </option>
                
                    <option value="2905" data-chained="PH">
                        Mindoro Oriental </option>
                
                    <option value="166" data-chained="AZ">
                        Mingacevir </option>
                
                    <option value="4050" data-chained="VN">
                        Minh Hai </option>
                
                    <option value="3933" data-chained="US">
                        Minnesota </option>
                
                    <option value="509" data-chained="BY">
                        Minsk </option>
                
                    <option value="510" data-chained="BY">
                        Minskaya Voblasts' </option>
                
                    <option value="371" data-chained="BH">
                        Mintaqat Juzur Hawar </option>
                
                    <option value="4016" data-chained="VE">
                        Miranda </option>
                
                    <option value="2299" data-chained="MK">
                        Miravci </option>
                
                    <option value="3469" data-chained="SI">
                        Miren-Kostanjevica </option>
                
                    <option value="2906" data-chained="PH">
                        Misamis Occidental </option>
                
                    <option value="2907" data-chained="PH">
                        Misamis Oriental </option>
                
                    <option value="3101" data-chained="PY">
                        Misiones </option>
                
                    <option value="107" data-chained="AR">
                        Misiones </option>
                
                    <option value="1619" data-chained="HU">
                        Miskolc </option>
                
                    <option value="3397" data-chained="SI">
                        Mislinja </option>
                
                    <option value="2170" data-chained="LY">
                        Misratah </option>
                
                    <option value="3936" data-chained="US">
                        Mississippi </option>
                
                    <option value="3934" data-chained="US">
                        Missouri </option>
                
                    <option value="1891" data-chained="JP">
                        Miyagi </option>
                
                    <option value="1892" data-chained="JP">
                        Miyazaki </option>
                
                    <option value="1734" data-chained="IN">
                        Mizoram </option>
                
                    <option value="794" data-chained="CZ">
                        Mlada Boleslav </option>
                
                    <option value="2300" data-chained="MK">
                        Mogila </option>
                
                    <option value="2108" data-chained="LS">
                        Mohales Hoek </option>
                
                    <option value="1956" data-chained="KM">
                        Moheli </option>
                
                    <option value="2425" data-chained="MU">
                        Moka </option>
                
                    <option value="2109" data-chained="LS">
                        Mokhotlong </option>
                
                    <option value="1836" data-chained="IT">
                        Molise </option>
                
                    <option value="2378" data-chained="MM">
                        Mon State </option>
                
                    <option value="2215" data-chained="MC">
                        Monaco </option>
                
                    <option value="4017" data-chained="VE">
                        Monagas </option>
                
                    <option value="1693" data-chained="IE">
                        Monaghan </option>
                
                    <option value="1939" data-chained="KH">
                        Mondol Kiri </option>
                
                    <option value="2081" data-chained="LK">
                        Moneragala </option>
                
                    <option value="485" data-chained="BT">
                        Mongar </option>
                
                    <option value="1327" data-chained="GB">
                        Monmouthshire </option>
                
                    <option value="396" data-chained="BJ">
                        Mono </option>
                
                    <option value="2098" data-chained="LR">
                        Monrovia </option>
                
                    <option value="886" data-chained="DO">
                        Monsenor Nouel </option>
                
                    <option value="3296" data-chained="SC">
                        Mont Buxton </option>
                
                    <option value="3297" data-chained="SC">
                        Mont Fleuri </option>
                
                    <option value="2044" data-chained="LB">
                        Mont-Liban </option>
                
                    <option value="346" data-chained="BG">
                        Montana </option>
                
                    <option value="3937" data-chained="US">
                        Montana </option>
                
                    <option value="871" data-chained="DO">
                        Monte Cristi </option>
                
                    <option value="3500" data-chained="SM">
                        Monte Giardino </option>
                
                    <option value="887" data-chained="DO">
                        Monte Plata </option>
                
                    <option value="2216" data-chained="MC">
                        Monte-Carlo </option>
                
                    <option value="3974" data-chained="UY">
                        Montevideo </option>
                
                    <option value="2102" data-chained="LR">
                        Montserrado </option>
                
                    <option value="2359" data-chained="ML">
                        Mopti </option>
                
                    <option value="2837" data-chained="PE">
                        Moquegua </option>
                
                    <option value="3398" data-chained="SI">
                        Moravce </option>
                
                    <option value="3399" data-chained="SI">
                        Moravske Toplice </option>
                
                    <option value="808" data-chained="CZ">
                        Moravskoslezsky Kraj </option>
                
                    <option value="1302" data-chained="GB">
                        Moray </option>
                
                    <option value="3547" data-chained="SV">
                        Morazan </option>
                
                    <option value="3207" data-chained="RU">
                        Mordovia </option>
                
                    <option value="2656" data-chained="NO">
                        More og Romsdal </option>
                
                    <option value="2496" data-chained="MX">
                        Morelos </option>
                
                    <option value="2858" data-chained="PG">
                        Morobe </option>
                
                    <option value="3822" data-chained="TZ">
                        Morogoro </option>
                
                    <option value="951" data-chained="EC">
                        Morona-Santiago </option>
                
                    <option value="3893" data-chained="UG">
                        Moroto </option>
                
                    <option value="3209" data-chained="RU">
                        Moscow City </option>
                
                    <option value="3208" data-chained="RU">
                        Moskva </option>
                
                    <option value="893" data-chained="DZ">
                        Mostaganem </option>
                
                    <option value="771" data-chained="CV">
                        Mosteiros </option>
                
                    <option value="320" data-chained="BF">
                        Mouhoun </option>
                
                    <option value="255" data-chained="BD">
                        Moulavibazar </option>
                
                    <option value="2741" data-chained="NZ">
                        Mount Herbert </option>
                
                    <option value="2908" data-chained="PH">
                        Mountain </option>
                
                    <option value="87" data-chained="AO">
                        Moxico </option>
                
                    <option value="3583" data-chained="TD">
                        Moyen-Chari </option>
                
                    <option value="1078" data-chained="GA">
                        Moyen-Ogooue </option>
                
                    <option value="1277" data-chained="GB">
                        Moyle </option>
                
                    <option value="3400" data-chained="SI">
                        Mozirje </option>
                
                    <option value="3894" data-chained="UG">
                        Mpigi </option>
                
                    <option value="4125" data-chained="ZA">
                        Mpumalanga </option>
                
                    <option value="1380" data-chained="GE">
                        Mts'khet'is Raioni </option>
                
                    <option value="3823" data-chained="TZ">
                        Mtwara </option>
                
                    <option value="3521" data-chained="SO">
                        Mudug </option>
                
                    <option value="3754" data-chained="TR">
                        Mugla </option>
                
                    <option value="3680" data-chained="TH">
                        Mukdahan </option>
                
                    <option value="3895" data-chained="UG">
                        Mukono </option>
                
                    <option value="2478" data-chained="MW">
                        Mulanje </option>
                
                    <option value="2091" data-chained="LK">
                        Mullaittivu </option>
                
                    <option value="256" data-chained="BD">
                        Munshiganj </option>
                
                    <option value="391" data-chained="BI">
                        Muramvya </option>
                
                    <option value="1009" data-chained="ES">
                        Murcia </option>
                
                    <option value="3145" data-chained="RO">
                        Mures </option>
                
                    <option value="3210" data-chained="RU">
                        Murmansk </option>
                
                    <option value="3401" data-chained="SI">
                        Murska Sobota </option>
                
                    <option value="2301" data-chained="MK">
                        Murtino </option>
                
                    <option value="2154" data-chained="LY">
                        Murzuq </option>
                
                    <option value="3755" data-chained="TR">
                        Mus </option>
                
                    <option value="2808" data-chained="OM">
                        Musandam </option>
                
                    <option value="3402" data-chained="SI">
                        Muta </option>
                
                    <option value="387" data-chained="BI">
                        Muyinga </option>
                
                    <option value="2474" data-chained="MW">
                        Mwanza </option>
                
                    <option value="3824" data-chained="TZ">
                        Mwanza </option>
                
                    <option value="392" data-chained="BI">
                        Mwaro </option>
                
                    <option value="3853" data-chained="UA">
                        Mykolayivs'ka Oblast' </option>
                
                    <option value="218" data-chained="BD">
                        Mymensingh </option>
                
                    <option value="1805" data-chained="IS">
                        Myrasysla </option>
                
                    <option value="2464" data-chained="MW">
                        Mzimba </option>
                
                    <option value="929" data-chained="DZ">
                        Naama </option>
                
                    <option value="2046" data-chained="LB">
                        Nabatiye </option>
                
                    <option value="3698" data-chained="TN">
                        Nabul </option>
                
                    <option value="795" data-chained="CZ">
                        Nachod </option>
                
                    <option value="2195" data-chained="MA">
                        Nador </option>
                
                    <option value="167" data-chained="AZ">
                        Naftalan </option>
                
                    <option value="2972" data-chained="PH">
                        Naga </option>
                
                    <option value="1724" data-chained="IN">
                        Nagaland </option>
                
                    <option value="1893" data-chained="JP">
                        Nagano </option>
                
                    <option value="1894" data-chained="JP">
                        Nagasaki </option>
                
                    <option value="1638" data-chained="HU">
                        Nagykanizsa </option>
                
                    <option value="1918" data-chained="KE">
                        Nairobi Area </option>
                
                    <option value="1983" data-chained="KP">
                        Najin Sonbong-si </option>
                
                    <option value="3271" data-chained="SA">
                        Najran </option>
                
                    <option value="3896" data-chained="UG">
                        Nakapiripirit </option>
                
                    <option value="3880" data-chained="UG">
                        Nakasongola </option>
                
                    <option value="3649" data-chained="TH">
                        Nakhon Nayok </option>
                
                    <option value="3659" data-chained="TH">
                        Nakhon Pathom </option>
                
                    <option value="3627" data-chained="TH">
                        Nakhon Phanom </option>
                
                    <option value="3633" data-chained="TH">
                        Nakhon Ratchasima </option>
                
                    <option value="3623" data-chained="TH">
                        Nakhon Sawan </option>
                
                    <option value="3670" data-chained="TH">
                        Nakhon Si Thammarat </option>
                
                    <option value="3403" data-chained="SI">
                        Naklo </option>
                
                    <option value="4067" data-chained="VN">
                        Nam Ha </option>
                
                    <option value="2562" data-chained="NA">
                        Namaland </option>
                
                    <option value="3989" data-chained="UZ">
                        Namangan </option>
                
                    <option value="321" data-chained="BF">
                        Namentenga </option>
                
                    <option value="1980" data-chained="KP">
                        Namp'o-si </option>
                
                    <option value="2532" data-chained="MZ">
                        Nampula </option>
                
                    <option value="285" data-chained="BE">
                        Namur </option>
                
                    <option value="3611" data-chained="TH">
                        Nan </option>
                
                    <option value="557" data-chained="CF">
                        Nana-Grebizi </option>
                
                    <option value="552" data-chained="CF">
                        Nana-Mambere </option>
                
                    <option value="30" data-chained="AF">
                        Nangarhar </option>
                
                    <option value="257" data-chained="BD">
                        Naogaon </option>
                
                    <option value="322" data-chained="BF">
                        Naouri </option>
                
                    <option value="957" data-chained="EC">
                        Napo </option>
                
                    <option value="1895" data-chained="JP">
                        Nara </option>
                
                    <option value="258" data-chained="BD">
                        Narail </option>
                
                    <option value="3637" data-chained="TH">
                        Narathiwat </option>
                
                    <option value="259" data-chained="BD">
                        Narayanganj </option>
                
                    <option value="2679" data-chained="NP">
                        Narayani </option>
                
                    <option value="722" data-chained="CO">
                        Narino </option>
                
                    <option value="3800" data-chained="TT">
                        Nariva </option>
                
                    <option value="260" data-chained="BD">
                        Narsingdi </option>
                
                    <option value="967" data-chained="EE">
                        Narva </option>
                
                    <option value="1926" data-chained="KG">
                        Naryn </option>
                
                    <option value="2617" data-chained="NG">
                        Nassarawa </option>
                
                    <option value="2864" data-chained="PG">
                        National Capital </option>
                
                    <option value="261" data-chained="BD">
                        Nator </option>
                
                    <option value="1010" data-chained="ES">
                        Navarra </option>
                
                    <option value="2452" data-chained="MV">
                        Naviyani </option>
                
                    <option value="3990" data-chained="UZ">
                        Nawoiy </option>
                
                    <option value="168" data-chained="AZ">
                        Naxcivan </option>
                
                    <option value="323" data-chained="BF">
                        Nayala </option>
                
                    <option value="2497" data-chained="MX">
                        Nayarit </option>
                
                    <option value="3404" data-chained="SI">
                        Nazarje </option>
                
                    <option value="3146" data-chained="RO">
                        Neamt </option>
                
                    <option value="1328" data-chained="GB">
                        Neath Port Talbot </option>
                
                    <option value="3940" data-chained="US">
                        Nebraska </option>
                
                    <option value="3102" data-chained="PY">
                        Neembucu </option>
                
                    <option value="169" data-chained="AZ">
                        Neftcala </option>
                
                    <option value="2516" data-chained="MY">
                        Negeri Sembilan </option>
                
                    <option value="2302" data-chained="MK">
                        Negotino </option>
                
                    <option value="2303" data-chained="MK">
                        Negotino-Polosko </option>
                
                    <option value="2997" data-chained="PH">
                        Negros Occidental </option>
                
                    <option value="2909" data-chained="PH">
                        Negros Oriental </option>
                
                    <option value="695" data-chained="CN">
                        Nei Mongol </option>
                
                    <option value="3211" data-chained="RU">
                        Nenets </option>
                
                    <option value="1806" data-chained="IS">
                        Neskaupstadur </option>
                
                    <option value="262" data-chained="BD">
                        Netrakona </option>
                
                    <option value="582" data-chained="CH">
                        Neuchatel </option>
                
                    <option value="108" data-chained="AR">
                        Neuquen </option>
                
                    <option value="3944" data-chained="US">
                        Nevada </option>
                
                    <option value="3756" data-chained="TR">
                        Nevsehir </option>
                
                    <option value="522" data-chained="CA">
                        New Brunswick </option>
                
                    <option value="3941" data-chained="US">
                        New Hampshire </option>
                
                    <option value="2859" data-chained="PG">
                        New Ireland </option>
                
                    <option value="3942" data-chained="US">
                        New Jersey </option>
                
                    <option value="3943" data-chained="US">
                        New Mexico </option>
                
                    <option value="465" data-chained="BS">
                        New Providence </option>
                
                    <option value="128" data-chained="AU">
                        New South Wales </option>
                
                    <option value="3945" data-chained="US">
                        New York </option>
                
                    <option value="1186" data-chained="GB">
                        Newcastle upon Tyne </option>
                
                    <option value="523" data-chained="CA">
                        Newfoundland and Labrador </option>
                
                    <option value="1187" data-chained="GB">
                        Newham </option>
                
                    <option value="1329" data-chained="GB">
                        Newport </option>
                
                    <option value="1278" data-chained="GB">
                        Newry and Mourne </option>
                
                    <option value="1279" data-chained="GB">
                        Newtownabbey </option>
                
                    <option value="502" data-chained="BW">
                        Ngamiland </option>
                
                    <option value="4068" data-chained="VN">
                        Nghe An </option>
                
                    <option value="1079" data-chained="GA">
                        Ngounie </option>
                
                    <option value="388" data-chained="BI">
                        Ngozi </option>
                
                    <option value="2579" data-chained="NE">
                        Niamey </option>
                
                    <option value="3598" data-chained="TG">
                        Niamtougou </option>
                
                    <option value="566" data-chained="CG">
                        Niari </option>
                
                    <option value="2533" data-chained="MZ">
                        Niassa </option>
                
                    <option value="2694" data-chained="NR">
                        Nibok </option>
                
                    <option value="474" data-chained="BS">
                        Nichollstown and Berry Islands </option>
                
                    <option value="3532" data-chained="SR">
                        Nickerie </option>
                
                    <option value="782" data-chained="CY">
                        Nicosia </option>
                
                    <option value="583" data-chained="CH">
                        Nidwalden </option>
                
                    <option value="120" data-chained="AT">
                        Niederosterreich </option>
                
                    <option value="819" data-chained="DE">
                        Niedersachsen </option>
                
                    <option value="3776" data-chained="TR">
                        Nigde </option>
                
                    <option value="2595" data-chained="NG">
                        Niger </option>
                
                    <option value="1896" data-chained="JP">
                        Niigata </option>
                
                    <option value="3870" data-chained="UG">
                        Nile </option>
                
                    <option value="263" data-chained="BD">
                        Nilphamari </option>
                
                    <option value="2099" data-chained="LR">
                        Nimba </option>
                
                    <option value="31" data-chained="AF">
                        Nimruz </option>
                
                    <option value="1757" data-chained="IQ">
                        Ninawa </option>
                
                    <option value="696" data-chained="CN">
                        Ningxia </option>
                
                    <option value="4069" data-chained="VN">
                        Ninh Binh </option>
                
                    <option value="4070" data-chained="VN">
                        Ninh Thuan </option>
                
                    <option value="1381" data-chained="GE">
                        Ninotsmindis Raioni </option>
                
                    <option value="3484" data-chained="SK">
                        Nitra </option>
                
                    <option value="3212" data-chained="RU">
                        Nizhegorod </option>
                
                    <option value="2466" data-chained="MW">
                        Nkhata Bay </option>
                
                    <option value="2467" data-chained="MW">
                        Nkhotakota </option>
                
                    <option value="219" data-chained="BD">
                        Noakhali </option>
                
                    <option value="1620" data-chained="HU">
                        Nograd </option>
                
                    <option value="3624" data-chained="TH">
                        Nong Khai </option>
                
                    <option value="3644" data-chained="TH">
                        Nonthaburi </option>
                
                    <option value="2448" data-chained="MV">
                        Noonu </option>
                
                    <option value="2640" data-chained="NL">
                        Noord-Brabant </option>
                
                    <option value="2641" data-chained="NL">
                        Noord-Holland </option>
                
                    <option value="1602" data-chained="HT">
                        Nord </option>
                
                    <option value="675" data-chained="CM">
                        Nord </option>
                
                    <option value="1603" data-chained="HT">
                        Nord-Est </option>
                
                    <option value="542" data-chained="CD">
                        Nord-Kivu </option>
                
                    <option value="1598" data-chained="HT">
                        Nord-Ouest </option>
                
                    <option value="669" data-chained="CM">
                        Nord-Ouest </option>
                
                    <option value="1069" data-chained="FR">
                        Nord-Pas-de-Calais </option>
                
                    <option value="2658" data-chained="NO">
                        Nord-Trondelag </option>
                
                    <option value="1417" data-chained="GL">
                        Nordgronland </option>
                
                    <option value="840" data-chained="DK">
                        Nordjylland </option>
                
                    <option value="2657" data-chained="NO">
                        Nordland </option>
                
                    <option value="820" data-chained="DE">
                        Nordrhein-Westfalen </option>
                
                    <option value="1807" data-chained="IS">
                        Nordur-Isafjardarsysla </option>
                
                    <option value="1808" data-chained="IS">
                        Nordur-Mulasysla </option>
                
                    <option value="1809" data-chained="IS">
                        Nordur-Tingeyjarsysla </option>
                
                    <option value="1188" data-chained="GB">
                        Norfolk </option>
                
                    <option value="3324" data-chained="SE">
                        Norrbottens Lan </option>
                
                    <option value="723" data-chained="CO">
                        Norte de Santander </option>
                
                    <option value="1303" data-chained="GB">
                        North Ayrshire </option>
                
                    <option value="1425" data-chained="GM">
                        North Bank </option>
                
                    <option value="3871" data-chained="UG">
                        North Buganda </option>
                
                    <option value="3938" data-chained="US">
                        North Carolina </option>
                
                    <option value="2919" data-chained="PH">
                        North Cotabato </option>
                
                    <option value="3939" data-chained="US">
                        North Dakota </option>
                
                    <option value="1280" data-chained="GB">
                        North Down </option>
                
                    <option value="1190" data-chained="GB">
                        North East Lincolnshire </option>
                
                    <option value="2026" data-chained="KZ">
                        North Kazakhstan </option>
                
                    <option value="1304" data-chained="GB">
                        North Lanarkshire </option>
                
                    <option value="1191" data-chained="GB">
                        North Lincolnshire </option>
                
                    <option value="3229" data-chained="RU">
                        North Ossetia </option>
                
                    <option value="2851" data-chained="PG">
                        North Solomons </option>
                
                    <option value="1192" data-chained="GB">
                        North Somerset </option>
                
                    <option value="1193" data-chained="GB">
                        North Tyneside </option>
                
                    <option value="1195" data-chained="GB">
                        North Yorkshire </option>
                
                    <option value="503" data-chained="BW">
                        North-East </option>
                
                    <option value="1919" data-chained="KE">
                        North-Eastern </option>
                
                    <option value="4128" data-chained="ZA">
                        North-West </option>
                
                    <option value="3000" data-chained="PK">
                        North-West Frontier </option>
                
                    <option value="4135" data-chained="ZM">
                        North-Western </option>
                
                    <option value="1189" data-chained="GB">
                        Northamptonshire </option>
                
                    <option value="1047" data-chained="FJ">
                        Northern </option>
                
                    <option value="2848" data-chained="PG">
                        Northern </option>
                
                    <option value="3872" data-chained="UG">
                        Northern </option>
                
                    <option value="4134" data-chained="ZM">
                        Northern </option>
                
                    <option value="1412" data-chained="GH">
                        Northern </option>
                
                    <option value="3490" data-chained="SL">
                        Northern </option>
                
                    <option value="3004" data-chained="PK">
                        Northern Areas </option>
                
                    <option value="4126" data-chained="ZA">
                        Northern Cape </option>
                
                    <option value="3935" data-chained="US">
                        Northern Mariana Islands </option>
                
                    <option value="2929" data-chained="PH">
                        Northern Samar </option>
                
                    <option value="129" data-chained="AU">
                        Northern Territory </option>
                
                    <option value="1194" data-chained="GB">
                        Northumberland </option>
                
                    <option value="530" data-chained="CA">
                        Northwest Territories </option>
                
                    <option value="3599" data-chained="TG">
                        Notse </option>
                
                    <option value="1196" data-chained="GB">
                        Nottingham </option>
                
                    <option value="1197" data-chained="GB">
                        Nottinghamshire </option>
                
                    <option value="324" data-chained="BF">
                        Noumbiel </option>
                
                    <option value="3405" data-chained="SI">
                        Nova Gorica </option>
                
                    <option value="524" data-chained="CA">
                        Nova Scotia </option>
                
                    <option value="2304" data-chained="MK">
                        Novaci </option>
                
                    <option value="3213" data-chained="RU">
                        Novgorod </option>
                
                    <option value="3470" data-chained="SI">
                        Novo Mesto </option>
                
                    <option value="2305" data-chained="MK">
                        Novo Selo </option>
                
                    <option value="3214" data-chained="RU">
                        Novosibirsk </option>
                
                    <option value="3029" data-chained="PL">
                        Nowy Sacz </option>
                
                    <option value="2468" data-chained="MW">
                        Nsanje </option>
                
                    <option value="2465" data-chained="MW">
                        Ntcheu </option>
                
                    <option value="2469" data-chained="MW">
                        Ntchisi </option>
                
                    <option value="3108" data-chained="PY">
                        Nueva Asuncion </option>
                
                    <option value="2910" data-chained="PH">
                        Nueva Ecija </option>
                
                    <option value="4018" data-chained="VE">
                        Nueva Esparta </option>
                
                    <option value="2631" data-chained="NI">
                        Nueva Segovia </option>
                
                    <option value="2911" data-chained="PH">
                        Nueva Vizcaya </option>
                
                    <option value="2498" data-chained="MX">
                        Nuevo Leon </option>
                
                    <option value="3522" data-chained="SO">
                        Nugaal </option>
                
                    <option value="531" data-chained="CA">
                        Nunavut </option>
                
                    <option value="46" data-chained="AF">
                        Nurestan </option>
                
                    <option value="1660" data-chained="ID">
                        Nusa Tenggara Barat </option>
                
                    <option value="1661" data-chained="ID">
                        Nusa Tenggara Timur </option>
                
                    <option value="2082" data-chained="LK">
                        Nuwara Eliya </option>
                
                    <option value="1080" data-chained="GA">
                        Nyanga </option>
                
                    <option value="1920" data-chained="KE">
                        Nyanza </option>
                
                    <option value="1639" data-chained="HU">
                        Nyiregyhaza </option>
                
                    <option value="796" data-chained="CZ">
                        Nymburk </option>
                
                    <option value="1458" data-chained="GN">
                        Nzerekore </option>
                
                    <option value="2499" data-chained="MX">
                        Oaxaca </option>
                
                    <option value="121" data-chained="AT">
                        Oberosterreich </option>
                
                    <option value="2306" data-chained="MK">
                        Oblesevo </option>
                
                    <option value="832" data-chained="DJ">
                        Obock </option>
                
                    <option value="584" data-chained="CH">
                        Obwalden </option>
                
                    <option value="1572" data-chained="HN">
                        Ocotepeque </option>
                
                    <option value="3854" data-chained="UA">
                        Odes'ka Oblast' </option>
                
                    <option value="610" data-chained="CI">
                        Odienne </option>
                
                    <option value="3406" data-chained="SI">
                        Odranci </option>
                
                    <option value="1694" data-chained="IE">
                        Offaly </option>
                
                    <option value="1081" data-chained="GA">
                        Ogooue-Ivindo </option>
                
                    <option value="1082" data-chained="GA">
                        Ogooue-Lolo </option>
                
                    <option value="1083" data-chained="GA">
                        Ogooue-Maritime </option>
                
                    <option value="2140" data-chained="LV">
                        Ogres </option>
                
                    <option value="2584" data-chained="NG">
                        Ogun </option>
                
                    <option value="170" data-chained="AZ">
                        Oguz </option>
                
                    <option value="2568" data-chained="NA">
                        Ohangwena </option>
                
                    <option value="2742" data-chained="NZ">
                        Ohinemuri </option>
                
                    <option value="3946" data-chained="US">
                        Ohio </option>
                
                    <option value="2307" data-chained="MK">
                        Ohrid </option>
                
                    <option value="1542" data-chained="GW">
                        Oio </option>
                
                    <option value="1897" data-chained="JP">
                        Oita </option>
                
                    <option value="2547" data-chained="NA">
                        Okahandja </option>
                
                    <option value="2569" data-chained="NA">
                        Okavango </option>
                
                    <option value="1898" data-chained="JP">
                        Okayama </option>
                
                    <option value="1914" data-chained="JP">
                        Okinawa </option>
                
                    <option value="3947" data-chained="US">
                        Oklahoma </option>
                
                    <option value="1810" data-chained="IS">
                        Olafsfjordur </option>
                
                    <option value="1573" data-chained="HN">
                        Olancho </option>
                
                    <option value="1198" data-chained="GB">
                        Oldham </option>
                
                    <option value="807" data-chained="CZ">
                        Olomoucky Kraj </option>
                
                    <option value="2973" data-chained="PH">
                        Olongapo </option>
                
                    <option value="3030" data-chained="PL">
                        Olsztyn </option>
                
                    <option value="3147" data-chained="RO">
                        Olt </option>
                
                    <option value="1281" data-chained="GB">
                        Omagh </option>
                
                    <option value="2570" data-chained="NA">
                        Omaheke </option>
                
                    <option value="2548" data-chained="NA">
                        Omaruru </option>
                
                    <option value="559" data-chained="CF">
                        Ombella-Mpoko </option>
                
                    <option value="2393" data-chained="MN">
                        Omnogovi </option>
                
                    <option value="3215" data-chained="RU">
                        Omsk </option>
                
                    <option value="2571" data-chained="NA">
                        Omusati </option>
                
                    <option value="2609" data-chained="NG">
                        Ondo </option>
                
                    <option value="1382" data-chained="GE">
                        Onis Raioni </option>
                
                    <option value="525" data-chained="CA">
                        Ontario </option>
                
                    <option value="286" data-chained="BE">
                        Oost-Vlaanderen </option>
                
                    <option value="3031" data-chained="PL">
                        Opole </option>
                
                    <option value="3062" data-chained="PL">
                        Opolskie </option>
                
                    <option value="2743" data-chained="NZ">
                        Opotiki </option>
                
                    <option value="2659" data-chained="NO">
                        Oppland </option>
                
                    <option value="894" data-chained="DZ">
                        Oran </option>
                
                    <option value="516" data-chained="BZ">
                        Orange Walk </option>
                
                    <option value="2308" data-chained="MK">
                        Orasac </option>
                
                    <option value="4" data-chained="AD">
                        Ordino </option>
                
                    <option value="3757" data-chained="TR">
                        Ordu </option>
                
                    <option value="3325" data-chained="SE">
                        Orebro Lan </option>
                
                    <option value="3948" data-chained="US">
                        Oregon </option>
                
                    <option value="3217" data-chained="RU">
                        Orel </option>
                
                    <option value="958" data-chained="EC">
                        Orellana </option>
                
                    <option value="3216" data-chained="RU">
                        Orenburg </option>
                
                    <option value="2224" data-chained="MD">
                        Orhei </option>
                
                    <option value="2404" data-chained="MN">
                        Orhon </option>
                
                    <option value="540" data-chained="CD">
                        Orientale </option>
                
                    <option value="1725" data-chained="IN">
                        Orissa </option>
                
                    <option value="2309" data-chained="MK">
                        Orizari </option>
                
                    <option value="1305" data-chained="GB">
                        Orkney </option>
                
                    <option value="2974" data-chained="PH">
                        Ormoc </option>
                
                    <option value="3407" data-chained="SI">
                        Ormoz </option>
                
                    <option value="1037" data-chained="ET">
                        Oromiya </option>
                
                    <option value="2975" data-chained="PH">
                        Oroquieta </option>
                
                    <option value="2744" data-chained="NZ">
                        Oroua </option>
                
                    <option value="425" data-chained="BO">
                        Oruro </option>
                
                    <option value="32" data-chained="AF">
                        Oruzgan </option>
                
                    <option value="1899" data-chained="JP">
                        Osaka </option>
                
                    <option value="1929" data-chained="KG">
                        Osh </option>
                
                    <option value="2572" data-chained="NA">
                        Oshana </option>
                
                    <option value="2573" data-chained="NA">
                        Oshikoto </option>
                
                    <option value="3408" data-chained="SI">
                        Osilnica </option>
                
                    <option value="1586" data-chained="HR">
                        Osjecko-Baranjska </option>
                
                    <option value="2660" data-chained="NO">
                        Oslo </option>
                
                    <option value="2310" data-chained="MK">
                        Oslomej </option>
                
                    <option value="3794" data-chained="TR">
                        Osmaniye </option>
                
                    <option value="3326" data-chained="SE">
                        Ostergotlands Lan </option>
                
                    <option value="2661" data-chained="NO">
                        Ostfold </option>
                
                    <option value="1418" data-chained="GL">
                        Ostgronland </option>
                
                    <option value="3032" data-chained="PL">
                        Ostroleka </option>
                
                    <option value="2603" data-chained="NG">
                        Osun </option>
                
                    <option value="2745" data-chained="NZ">
                        Otamatea </option>
                
                    <option value="2549" data-chained="NA">
                        Otjiwarongo </option>
                
                    <option value="2574" data-chained="NA">
                        Otjozondjupa </option>
                
                    <option value="2746" data-chained="NZ">
                        Otorohanga </option>
                
                    <option value="3584" data-chained="TD">
                        Ouaddai </option>
                
                    <option value="553" data-chained="CF">
                        Ouaka </option>
                
                    <option value="930" data-chained="DZ">
                        Ouargla </option>
                
                    <option value="2196" data-chained="MA">
                        Ouarzazate </option>
                
                    <option value="325" data-chained="BF">
                        Oubritenga </option>
                
                    <option value="296" data-chained="BF">
                        Oudalan </option>
                
                    <option value="2033" data-chained="LA">
                        Oudomxai </option>
                
                    <option value="397" data-chained="BJ">
                        Oueme </option>
                
                    <option value="418" data-chained="BN">
                        Oueme </option>
                
                    <option value="1604" data-chained="HT">
                        Ouest </option>
                
                    <option value="670" data-chained="CM">
                        Ouest </option>
                
                    <option value="554" data-chained="CF">
                        Ouham </option>
                
                    <option value="555" data-chained="CF">
                        Ouham-Pende </option>
                
                    <option value="2197" data-chained="MA">
                        Oujda </option>
                
                    <option value="1041" data-chained="FI">
                        Oulu </option>
                
                    <option value="910" data-chained="DZ">
                        Oum el Bouaghi </option>
                
                    <option value="617" data-chained="CI">
                        Oume </option>
                
                    <option value="2550" data-chained="NA">
                        Outjo </option>
                
                    <option value="2642" data-chained="NL">
                        Overijssel </option>
                
                    <option value="2394" data-chained="MN">
                        Ovorhangay </option>
                
                    <option value="2551" data-chained="NA">
                        Owambo </option>
                
                    <option value="2747" data-chained="NZ">
                        Oxford </option>
                
                    <option value="1199" data-chained="GB">
                        Oxfordshire </option>
                
                    <option value="2596" data-chained="NG">
                        Oyo </option>
                
                    <option value="2976" data-chained="PH">
                        Ozamis </option>
                
                    <option value="1383" data-chained="GE">
                        Ozurget'is Raioni </option>
                
                    <option value="1384" data-chained="GE">
                        P'ot'i </option>
                
                    <option value="1977" data-chained="KP">
                        P'yongan-bukto </option>
                
                    <option value="1981" data-chained="KP">
                        P'yongan-namdo </option>
                
                    <option value="1978" data-chained="KP">
                        P'yongyang-si </option>
                
                    <option value="4087" data-chained="VU">
                        Paama </option>
                
                    <option value="264" data-chained="BD">
                        Pabna </option>
                
                    <option value="3897" data-chained="UG">
                        Pader </option>
                
                    <option value="2977" data-chained="PH">
                        Pagadian </option>
                
                    <option value="401" data-chained="BM">
                        Paget </option>
                
                    <option value="2517" data-chained="MY">
                        Pahang </option>
                
                    <option value="2748" data-chained="NZ">
                        Pahiatua </option>
                
                    <option value="1950" data-chained="KH">
                        Pailin </option>
                
                    <option value="1021" data-chained="ES">
                        Pais Vasco </option>
                
                    <option value="33" data-chained="AF">
                        Paktia </option>
                
                    <option value="40" data-chained="AF">
                        Paktika </option>
                
                    <option value="3951" data-chained="US">
                        Palau </option>
                
                    <option value="4101" data-chained="WS">
                        Palauli </option>
                
                    <option value="2912" data-chained="PH">
                        Palawan </option>
                
                    <option value="2978" data-chained="PH">
                        Palayan </option>
                
                    <option value="2913" data-chained="PH">
                        Pampanga </option>
                
                    <option value="2426" data-chained="MU">
                        Pamplemousses </option>
                
                    <option value="2817" data-chained="PA">
                        Panama </option>
                
                    <option value="265" data-chained="BD">
                        Panchagar </option>
                
                    <option value="426" data-chained="BO">
                        Pando </option>
                
                    <option value="2117" data-chained="LT">
                        Panevezio Apskritis </option>
                
                    <option value="2914" data-chained="PH">
                        Pangasinan </option>
                
                    <option value="2749" data-chained="NZ">
                        Paparua </option>
                
                    <option value="784" data-chained="CY">
                        Paphos </option>
                
                    <option value="1653" data-chained="ID">
                        Papua </option>
                
                    <option value="442" data-chained="BR">
                        Para </option>
                
                    <option value="3533" data-chained="SR">
                        Para </option>
                
                    <option value="3103" data-chained="PY">
                        Paraguari </option>
                
                    <option value="443" data-chained="BR">
                        Paraiba </option>
                
                    <option value="3534" data-chained="SR">
                        Paramaribo </option>
                
                    <option value="444" data-chained="BR">
                        Parana </option>
                
                    <option value="266" data-chained="BD">
                        Parbattya Chattagram </option>
                
                    <option value="797" data-chained="CZ">
                        Pardubice </option>
                
                    <option value="809" data-chained="CZ">
                        Pardubicky Kraj </option>
                
                    <option value="968" data-chained="EE">
                        Parnu </option>
                
                    <option value="969" data-chained="EE">
                        Parnumaa </option>
                
                    <option value="486" data-chained="BT">
                        Paro </option>
                
                    <option value="34" data-chained="AF">
                        Parvan </option>
                
                    <option value="2979" data-chained="PH">
                        Pasay </option>
                
                    <option value="2838" data-chained="PE">
                        Pasco </option>
                
                    <option value="297" data-chained="BF">
                        Passore </option>
                
                    <option value="952" data-chained="EC">
                        Pastaza </option>
                
                    <option value="2750" data-chained="NZ">
                        Patea </option>
                
                    <option value="3645" data-chained="TH">
                        Pathum Thani </option>
                
                    <option value="3675" data-chained="TH">
                        Pattani </option>
                
                    <option value="220" data-chained="BD">
                        Patuakhali </option>
                
                    <option value="766" data-chained="CV">
                        Paul </option>
                
                    <option value="2021" data-chained="KZ">
                        Pavlodar </option>
                
                    <option value="1070" data-chained="FR">
                        Pays de la Loire </option>
                
                    <option value="3975" data-chained="UY">
                        Paysandu </option>
                
                    <option value="347" data-chained="BG">
                        Pazardzhik </option>
                
                    <option value="1621" data-chained="HU">
                        Pecs </option>
                
                    <option value="872" data-chained="DO">
                        Pedernales </option>
                
                    <option value="2374" data-chained="MM">
                        Pegu </option>
                
                    <option value="2311" data-chained="MK">
                        Pehcevo </option>
                
                    <option value="1473" data-chained="GR">
                        Pella </option>
                
                    <option value="487" data-chained="BT">
                        Pemagatsel </option>
                
                    <option value="3825" data-chained="TZ">
                        Pemba North </option>
                
                    <option value="3832" data-chained="TZ">
                        Pemba South </option>
                
                    <option value="402" data-chained="BM">
                        Pembroke </option>
                
                    <option value="1330" data-chained="GB">
                        Pembrokeshire </option>
                
                    <option value="4093" data-chained="VU">
                        Penama </option>
                
                    <option value="3949" data-chained="US">
                        Pennsylvania </option>
                
                    <option value="4088" data-chained="VU">
                        Pentecote </option>
                
                    <option value="3218" data-chained="RU">
                        Penza </option>
                
                    <option value="2518" data-chained="MY">
                        Perak </option>
                
                    <option value="873" data-chained="DO">
                        Peravia </option>
                
                    <option value="2519" data-chained="MY">
                        Perlis </option>
                
                    <option value="3219" data-chained="RU">
                        Perm' </option>
                
                    <option value="455" data-chained="BR">
                        Pernambuco </option>
                
                    <option value="348" data-chained="BG">
                        Pernik </option>
                
                    <option value="1306" data-chained="GB">
                        Perth and Kinross </option>
                
                    <option value="3409" data-chained="SI">
                        Pesnica </option>
                
                    <option value="1622" data-chained="HU">
                        Pest </option>
                
                    <option value="1529" data-chained="GT">
                        Peten </option>
                
                    <option value="1200" data-chained="GB">
                        Peterborough </option>
                
                    <option value="2312" data-chained="MK">
                        Petrovec </option>
                
                    <option value="2479" data-chained="MW">
                        Phalombe </option>
                
                    <option value="3667" data-chained="TH">
                        Phangnga </option>
                
                    <option value="3672" data-chained="TH">
                        Phatthalung </option>
                
                    <option value="3647" data-chained="TH">
                        Phayao </option>
                
                    <option value="3621" data-chained="TH">
                        Phetchabun </option>
                
                    <option value="3662" data-chained="TH">
                        Phetchaburi </option>
                
                    <option value="3620" data-chained="TH">
                        Phichit </option>
                
                    <option value="3619" data-chained="TH">
                        Phitsanulok </option>
                
                    <option value="1940" data-chained="KH">
                        Phnum Penh </option>
                
                    <option value="1953" data-chained="KI">
                        Phoenix Islands </option>
                
                    <option value="2034" data-chained="LA">
                        Phongsali </option>
                
                    <option value="3642" data-chained="TH">
                        Phra Nakhon Si Ayutthaya </option>
                
                    <option value="3614" data-chained="TH">
                        Phrae </option>
                
                    <option value="4071" data-chained="VN">
                        Phu Yen </option>
                
                    <option value="3668" data-chained="TH">
                        Phuket </option>
                
                    <option value="2751" data-chained="NZ">
                        Piako </option>
                
                    <option value="445" data-chained="BR">
                        Piaui </option>
                
                    <option value="1071" data-chained="FR">
                        Picardie </option>
                
                    <option value="953" data-chained="EC">
                        Pichincha </option>
                
                    <option value="1837" data-chained="IT">
                        Piemonte </option>
                
                    <option value="1482" data-chained="GR">
                        Pieria </option>
                
                    <option value="3033" data-chained="PL">
                        Pila </option>
                
                    <option value="748" data-chained="CU">
                        Pinar del Rio </option>
                
                    <option value="3034" data-chained="PL">
                        Piotrkow </option>
                
                    <option value="3471" data-chained="SI">
                        Piran </option>
                
                    <option value="267" data-chained="BD">
                        Pirojpur </option>
                
                    <option value="1446" data-chained="GN">
                        Pita </option>
                
                    <option value="2839" data-chained="PE">
                        Piura </option>
                
                    <option value="3410" data-chained="SI">
                        Pivka </option>
                
                    <option value="2427" data-chained="MU">
                        Plaines Wilhems </option>
                
                    <option value="3298" data-chained="SC">
                        Plaisance </option>
                
                    <option value="2062" data-chained="LI">
                        Planken </option>
                
                    <option value="2313" data-chained="MK">
                        Plasnica </option>
                
                    <option value="2610" data-chained="NG">
                        Plateau </option>
                
                    <option value="419" data-chained="BN">
                        Plateau </option>
                
                    <option value="567" data-chained="CG">
                        Plateaux </option>
                
                    <option value="349" data-chained="BG">
                        Pleven </option>
                
                    <option value="3035" data-chained="PL">
                        Plock </option>
                
                    <option value="350" data-chained="BG">
                        Plovdiv </option>
                
                    <option value="1201" data-chained="GB">
                        Plymouth </option>
                
                    <option value="810" data-chained="CZ">
                        Plzensky Kraj </option>
                
                    <option value="2314" data-chained="MK">
                        Podares </option>
                
                    <option value="3411" data-chained="SI">
                        Podcetrtek </option>
                
                    <option value="3063" data-chained="PL">
                        Podkarpackie </option>
                
                    <option value="3064" data-chained="PL">
                        Podlaskie </option>
                
                    <option value="2752" data-chained="NZ">
                        Pohangina </option>
                
                    <option value="1051" data-chained="FM">
                        Pohnpei </option>
                
                    <option value="3299" data-chained="SC">
                        Pointe La Rue </option>
                
                    <option value="1072" data-chained="FR">
                        Poitou-Charentes </option>
                
                    <option value="2083" data-chained="LK">
                        Polonnaruwa </option>
                
                    <option value="3855" data-chained="UA">
                        Poltavs'ka Oblast' </option>
                
                    <option value="970" data-chained="EE">
                        Polvamaa </option>
                
                    <option value="1555" data-chained="GY">
                        Pomeroon-Supenaam </option>
                
                    <option value="3065" data-chained="PL">
                        Pomorskie </option>
                
                    <option value="1726" data-chained="IN">
                        Pondicherry </option>
                
                    <option value="326" data-chained="BF">
                        Poni </option>
                
                    <option value="569" data-chained="CG">
                        Pool </option>
                
                    <option value="1202" data-chained="GB">
                        Poole </option>
                
                    <option value="3300" data-chained="SC">
                        Port Glaud </option>
                
                    <option value="2428" data-chained="MU">
                        Port Louis </option>
                
                    <option value="3801" data-chained="TT">
                        Port-of-Spain </option>
                
                    <option value="3083" data-chained="PT">
                        Portalegre </option>
                
                    <option value="1849" data-chained="JM">
                        Portland </option>
                
                    <option value="3084" data-chained="PT">
                        Porto </option>
                
                    <option value="1203" data-chained="GB">
                        Portsmouth </option>
                
                    <option value="4019" data-chained="VE">
                        Portuguesa </option>
                
                    <option value="3412" data-chained="SI">
                        Postojna </option>
                
                    <option value="1556" data-chained="GY">
                        Potaro-Siparuni </option>
                
                    <option value="427" data-chained="BO">
                        Potosi </option>
                
                    <option value="1941" data-chained="KH">
                        Pouthisat </option>
                
                    <option value="1331" data-chained="GB">
                        Powys </option>
                
                    <option value="1587" data-chained="HR">
                        Pozesko-Slavonska </option>
                
                    <option value="3036" data-chained="PL">
                        Poznan </option>
                
                    <option value="3651" data-chained="TH">
                        Prachin Buri </option>
                
                    <option value="3663" data-chained="TH">
                        Prachuap Khiri Khan </option>
                
                    <option value="3148" data-chained="RO">
                        Prahova </option>
                
                    <option value="772" data-chained="CV">
                        Praia </option>
                
                    <option value="2057" data-chained="LC">
                        Praslin </option>
                
                    <option value="3572" data-chained="SZ">
                        Praslin </option>
                
                    <option value="1942" data-chained="KH">
                        Preah Vihear </option>
                
                    <option value="3472" data-chained="SI">
                        Preddvor </option>
                
                    <option value="2141" data-chained="LV">
                        Preilu </option>
                
                    <option value="3104" data-chained="PY">
                        Presidente Hayes </option>
                
                    <option value="3485" data-chained="SK">
                        Presov </option>
                
                    <option value="1485" data-chained="GR">
                        Preveza </option>
                
                    <option value="1943" data-chained="KH">
                        Prey Veng </option>
                
                    <option value="2315" data-chained="MK">
                        Prilep </option>
                
                    <option value="3220" data-chained="RU">
                        Primor'ye </option>
                
                    <option value="1588" data-chained="HR">
                        Primorsko-Goranska </option>
                
                    <option value="526" data-chained="CA">
                        Prince Edward Island </option>
                
                    <option value="3538" data-chained="ST">
                        Principe </option>
                
                    <option value="2316" data-chained="MK">
                        Probistip </option>
                
                    <option value="1073" data-chained="FR">
                        Provence-Alpes-Cote d'Azur </option>
                
                    <option value="3037" data-chained="PL">
                        Przemysl </option>
                
                    <option value="3221" data-chained="RU">
                        Pskov </option>
                
                    <option value="3473" data-chained="SI">
                        Ptuj </option>
                
                    <option value="3413" data-chained="SI">
                        Puconci </option>
                
                    <option value="2500" data-chained="MX">
                        Puebla </option>
                
                    <option value="874" data-chained="DO">
                        Puerto Plata </option>
                
                    <option value="2980" data-chained="PH">
                        Puerto Princesa </option>
                
                    <option value="3950" data-chained="US">
                        Puerto Rico </option>
                
                    <option value="1838" data-chained="IT">
                        Puglia </option>
                
                    <option value="2520" data-chained="MY">
                        Pulau Pinang </option>
                
                    <option value="488" data-chained="BT">
                        Punakha </option>
                
                    <option value="3001" data-chained="PK">
                        Punjab </option>
                
                    <option value="1727" data-chained="IN">
                        Punjab </option>
                
                    <option value="2840" data-chained="PE">
                        Puno </option>
                
                    <option value="746" data-chained="CR">
                        Puntarenas </option>
                
                    <option value="1988" data-chained="KR">
                        Pusan-jikhalsi </option>
                
                    <option value="2084" data-chained="LK">
                        Puttalam </option>
                
                    <option value="724" data-chained="CO">
                        Putumayo </option>
                
                    <option value="3814" data-chained="TZ">
                        Pwani </option>
                
                    <option value="171" data-chained="AZ">
                        Qabala </option>
                
                    <option value="3703" data-chained="TN">
                        Qabis </option>
                
                    <option value="2110" data-chained="LS">
                        Qachas Nek </option>
                
                    <option value="3692" data-chained="TN">
                        Qafsah </option>
                
                    <option value="2022" data-chained="KZ">
                        Qaraghandy </option>
                
                    <option value="3991" data-chained="UZ">
                        Qashqadaryo </option>
                
                    <option value="172" data-chained="AZ">
                        Qax </option>
                
                    <option value="173" data-chained="AZ">
                        Qazax </option>
                
                    <option value="1385" data-chained="GE">
                        Qazbegis Raioni </option>
                
                    <option value="1787" data-chained="IR">
                        Qazvin </option>
                
                    <option value="3704" data-chained="TN">
                        Qibili </option>
                
                    <option value="1002" data-chained="EG">
                        Qina </option>
                
                    <option value="682" data-chained="CN">
                        Qinghai </option>
                
                    <option value="174" data-chained="AZ">
                        Qobustan </option>
                
                    <option value="1788" data-chained="IR">
                        Qom </option>
                
                    <option value="3992" data-chained="UZ">
                        Qoraqalpoghiston </option>
                
                    <option value="2023" data-chained="KZ">
                        Qostanay </option>
                
                    <option value="4072" data-chained="VN">
                        Quang Binh </option>
                
                    <option value="4037" data-chained="VN">
                        Quang Nam-Da Nang </option>
                
                    <option value="4073" data-chained="VN">
                        Quang Ngai </option>
                
                    <option value="4038" data-chained="VN">
                        Quang Ninh </option>
                
                    <option value="4074" data-chained="VN">
                        Quang Tri </option>
                
                    <option value="175" data-chained="AZ">
                        Quba </option>
                
                    <option value="176" data-chained="AZ">
                        Qubadli </option>
                
                    <option value="527" data-chained="CA">
                        Quebec </option>
                
                    <option value="130" data-chained="AU">
                        Queensland </option>
                
                    <option value="2501" data-chained="MX">
                        Queretaro de Arteaga </option>
                
                    <option value="1530" data-chained="GT">
                        Quetzaltenango </option>
                
                    <option value="2996" data-chained="PH">
                        Quezon </option>
                
                    <option value="2981" data-chained="PH">
                        Quezon City </option>
                
                    <option value="1531" data-chained="GT">
                        Quiche </option>
                
                    <option value="1541" data-chained="GW">
                        Quinara </option>
                
                    <option value="725" data-chained="CO">
                        Quindio </option>
                
                    <option value="2502" data-chained="MX">
                        Quintana Roo </option>
                
                    <option value="2930" data-chained="PH">
                        Quirino </option>
                
                    <option value="177" data-chained="AZ">
                        Qusar </option>
                
                    <option value="2111" data-chained="LS">
                        Quthing </option>
                
                    <option value="1386" data-chained="GE">
                        Qvarlis Raioni </option>
                
                    <option value="2024" data-chained="KZ">
                        Qyzylorda </option>
                
                    <option value="2442" data-chained="MV">
                        Raa </option>
                
                    <option value="2198" data-chained="MA">
                        Rabat-Sale </option>
                
                    <option value="3414" data-chained="SI">
                        Racam </option>
                
                    <option value="3415" data-chained="SI">
                        Radece </option>
                
                    <option value="3416" data-chained="SI">
                        Radenci </option>
                
                    <option value="3417" data-chained="SI">
                        Radlje ob Dravi </option>
                
                    <option value="3038" data-chained="PL">
                        Radom </option>
                
                    <option value="2317" data-chained="MK">
                        Radovis </option>
                
                    <option value="3418" data-chained="SI">
                        Radovljica </option>
                
                    <option value="463" data-chained="BS">
                        Ragged Island </option>
                
                    <option value="2753" data-chained="NZ">
                        Raglan </option>
                
                    <option value="1728" data-chained="IN">
                        Rajasthan </option>
                
                    <option value="268" data-chained="BD">
                        Rajbari </option>
                
                    <option value="269" data-chained="BD">
                        Rajshahi </option>
                
                    <option value="2366" data-chained="MM">
                        Rakhine State </option>
                
                    <option value="1811" data-chained="IS">
                        Rangarvallasysla </option>
                
                    <option value="2754" data-chained="NZ">
                        Rangiora </option>
                
                    <option value="2755" data-chained="NZ">
                        Rangitikei </option>
                
                    <option value="2379" data-chained="MM">
                        Rangoon </option>
                
                    <option value="270" data-chained="BD">
                        Rangpur </option>
                
                    <option value="2318" data-chained="MK">
                        Rankovce </option>
                
                    <option value="3665" data-chained="TH">
                        Ranong </option>
                
                    <option value="971" data-chained="EE">
                        Raplamaa </option>
                
                    <option value="2680" data-chained="NP">
                        Rapti </option>
                
                    <option value="12" data-chained="AE">
                        Ras Al Khaimah </option>
                
                    <option value="3658" data-chained="TH">
                        Ratchaburi </option>
                
                    <option value="2085" data-chained="LK">
                        Ratnapura </option>
                
                    <option value="3653" data-chained="TH">
                        Rayong </option>
                
                    <option value="351" data-chained="BG">
                        Razgrad </option>
                
                    <option value="1204" data-chained="GB">
                        Reading </option>
                
                    <option value="1205" data-chained="GB">
                        Redbridge </option>
                
                    <option value="1206" data-chained="GB">
                        Redcar and Cleveland </option>
                
                    <option value="665" data-chained="CL">
                        Region Metropolitana </option>
                
                    <option value="2552" data-chained="NA">
                        Rehoboth </option>
                
                    <option value="931" data-chained="DZ">
                        Relizane </option>
                
                    <option value="1307" data-chained="GB">
                        Renfrewshire </option>
                
                    <option value="203" data-chained="BA">
                        Republika Srpska </option>
                
                    <option value="2319" data-chained="MK">
                        Resen </option>
                
                    <option value="1532" data-chained="GT">
                        Retalhuleu </option>
                
                    <option value="1510" data-chained="GR">
                        Rethimni </option>
                
                    <option value="1812" data-chained="IS">
                        Reykjavik </option>
                
                    <option value="821" data-chained="DE">
                        Rheinland-Pfalz </option>
                
                    <option value="3952" data-chained="US">
                        Rhode Island </option>
                
                    <option value="1332" data-chained="GB">
                        Rhondda Cynon Taff </option>
                
                    <option value="1074" data-chained="FR">
                        Rhone-Alpes </option>
                
                    <option value="1662" data-chained="ID">
                        Riau </option>
                
                    <option value="841" data-chained="DK">
                        Ribe </option>
                
                    <option value="767" data-chained="CV">
                        Ribeira Grande </option>
                
                    <option value="3474" data-chained="SI">
                        Ribnica </option>
                
                    <option value="1207" data-chained="GB">
                        Richmond upon Thames </option>
                
                    <option value="3561" data-chained="SY">
                        Rif Dimashq </option>
                
                    <option value="1921" data-chained="KE">
                        Rift Valley </option>
                
                    <option value="2142" data-chained="LV">
                        Riga </option>
                
                    <option value="2143" data-chained="LV">
                        Rigas </option>
                
                    <option value="842" data-chained="DK">
                        Ringkobing </option>
                
                    <option value="446" data-chained="BR">
                        Rio de Janeiro </option>
                
                    <option value="447" data-chained="BR">
                        Rio Grande do Norte </option>
                
                    <option value="448" data-chained="BR">
                        Rio Grande do Sul </option>
                
                    <option value="109" data-chained="AR">
                        Rio Negro </option>
                
                    <option value="3976" data-chained="UY">
                        Rio Negro </option>
                
                    <option value="2632" data-chained="NI">
                        Rio San Juan </option>
                
                    <option value="726" data-chained="CO">
                        Risaralda </option>
                
                    <option value="2633" data-chained="NI">
                        Rivas </option>
                
                    <option value="3977" data-chained="UY">
                        Rivera </option>
                
                    <option value="2611" data-chained="NG">
                        Rivers </option>
                
                    <option value="2429" data-chained="MU">
                        Riviere du Rempart </option>
                
                    <option value="3856" data-chained="UA">
                        Rivnens'ka Oblast' </option>
                
                    <option value="2915" data-chained="PH">
                        Rizal </option>
                
                    <option value="3758" data-chained="TR">
                        Rize </option>
                
                    <option value="3978" data-chained="UY">
                        Rocha </option>
                
                    <option value="1208" data-chained="GB">
                        Rochdale </option>
                
                    <option value="475" data-chained="BS">
                        Rock Sound </option>
                
                    <option value="1468" data-chained="GR">
                        Rodhopi </option>
                
                    <option value="2756" data-chained="NZ">
                        Rodney </option>
                
                    <option value="2433" data-chained="MU">
                        Rodrigues </option>
                
                    <option value="2662" data-chained="NO">
                        Rogaland </option>
                
                    <option value="3420" data-chained="SI">
                        Rogaska Slatina </option>
                
                    <option value="3419" data-chained="SI">
                        Rogasovci </option>
                
                    <option value="3421" data-chained="SI">
                        Rogatec </option>
                
                    <option value="3631" data-chained="TH">
                        Roi Et </option>
                
                    <option value="2916" data-chained="PH">
                        Romblon </option>
                
                    <option value="449" data-chained="BR">
                        Rondonia </option>
                
                    <option value="450" data-chained="BR">
                        Roraima </option>
                
                    <option value="1695" data-chained="IE">
                        Roscommon </option>
                
                    <option value="843" data-chained="DK">
                        Roskilde </option>
                
                    <option value="2320" data-chained="MK">
                        Rosoman </option>
                
                    <option value="3222" data-chained="RU">
                        Rostov </option>
                
                    <option value="2321" data-chained="MK">
                        Rostusa </option>
                
                    <option value="1944" data-chained="KH">
                        Rotanokiri </option>
                
                    <option value="1209" data-chained="GB">
                        Rotherham </option>
                
                    <option value="2757" data-chained="NZ">
                        Rotorua </option>
                
                    <option value="1048" data-chained="FJ">
                        Rotuma </option>
                
                    <option value="2982" data-chained="PH">
                        Roxas </option>
                
                    <option value="2063" data-chained="LI">
                        Ruggell </option>
                
                    <option value="3260" data-chained="RW">
                        Ruhengeri </option>
                
                    <option value="3898" data-chained="UG">
                        Rukungiri </option>
                
                    <option value="3836" data-chained="TZ">
                        Rukwa </option>
                
                    <option value="2470" data-chained="MW">
                        Rumphi </option>
                
                    <option value="2797" data-chained="NZ">
                        Runanga </option>
                
                    <option value="352" data-chained="BG">
                        Ruse </option>
                
                    <option value="3475" data-chained="SI">
                        Ruse </option>
                
                    <option value="1387" data-chained="GE">
                        Rust'avi </option>
                
                    <option value="389" data-chained="BI">
                        Rutana </option>
                
                    <option value="1210" data-chained="GB">
                        Rutland </option>
                
                    <option value="3826" data-chained="TZ">
                        Ruvuma </option>
                
                    <option value="390" data-chained="BI">
                        Ruyigi </option>
                
                    <option value="3223" data-chained="RU">
                        Ryazan' </option>
                
                    <option value="3039" data-chained="PL">
                        Rzeszow </option>
                
                    <option value="4113" data-chained="YE">
                        Sa </option>
                
                    <option value="972" data-chained="EE">
                        Saaremaa </option>
                
                    <option value="822" data-chained="DE">
                        Saarland </option>
                
                    <option value="178" data-chained="AZ">
                        Saatli </option>
                
                    <option value="2526" data-chained="MY">
                        Sabah </option>
                
                    <option value="2155" data-chained="LY">
                        Sabha </option>
                
                    <option value="179" data-chained="AZ">
                        Sabirabad </option>
                
                    <option value="1533" data-chained="GT">
                        Sacatepequez </option>
                
                    <option value="1388" data-chained="GE">
                        Sach'kheris Raioni </option>
                
                    <option value="826" data-chained="DE">
                        Sachsen </option>
                
                    <option value="827" data-chained="DE">
                        Sachsen-Anhalt </option>
                
                    <option value="3705" data-chained="TN">
                        Safaqis </option>
                
                    <option value="2199" data-chained="MA">
                        Safi </option>
                
                    <option value="1900" data-chained="JP">
                        Saga </option>
                
                    <option value="2375" data-chained="MM">
                        Sagaing </option>
                
                    <option value="1389" data-chained="GE">
                        Sagarejos Raioni </option>
                
                    <option value="2681" data-chained="NP">
                        Sagarmatha </option>
                
                    <option value="895" data-chained="DZ">
                        Saida </option>
                
                    <option value="1337" data-chained="GD">
                        Saint Andrew </option>
                
                    <option value="1850" data-chained="JM">
                        Saint Andrew </option>
                
                    <option value="849" data-chained="DM">
                        Saint Andrew </option>
                
                    <option value="3998" data-chained="VC">
                        Saint Andrew </option>
                
                    <option value="205" data-chained="BB">
                        Saint Andrew </option>
                
                    <option value="3802" data-chained="TT">
                        Saint Andrew </option>
                
                    <option value="1851" data-chained="JM">
                        Saint Ann </option>
                
                    <option value="1958" data-chained="KN">
                        Saint Anne Sandy Point </option>
                
                    <option value="2419" data-chained="MS">
                        Saint Anthony </option>
                
                    <option value="1852" data-chained="JM">
                        Saint Catherine </option>
                
                    <option value="1338" data-chained="GD">
                        Saint David </option>
                
                    <option value="850" data-chained="DM">
                        Saint David </option>
                
                    <option value="3999" data-chained="VC">
                        Saint David </option>
                
                    <option value="3803" data-chained="TT">
                        Saint David </option>
                
                    <option value="1853" data-chained="JM">
                        Saint Elizabeth </option>
                
                    <option value="48" data-chained="AG">
                        Saint George </option>
                
                    <option value="1339" data-chained="GD">
                        Saint George </option>
                
                    <option value="851" data-chained="DM">
                        Saint George </option>
                
                    <option value="403" data-chained="BM">
                        Saint George </option>
                
                    <option value="4000" data-chained="VC">
                        Saint George </option>
                
                    <option value="206" data-chained="BB">
                        Saint George </option>
                
                    <option value="3804" data-chained="TT">
                        Saint George </option>
                
                    <option value="1959" data-chained="KN">
                        Saint George Basseterre </option>
                
                    <option value="1960" data-chained="KN">
                        Saint George Gingerland </option>
                
                    <option value="404" data-chained="BM">
                        Saint George's </option>
                
                    <option value="2420" data-chained="MS">
                        Saint Georges </option>
                
                    <option value="3338" data-chained="SH">
                        Saint Helena </option>
                
                    <option value="1854" data-chained="JM">
                        Saint James </option>
                
                    <option value="207" data-chained="BB">
                        Saint James </option>
                
                    <option value="1961" data-chained="KN">
                        Saint James Windward </option>
                
                    <option value="49" data-chained="AG">
                        Saint John </option>
                
                    <option value="1340" data-chained="GD">
                        Saint John </option>
                
                    <option value="852" data-chained="DM">
                        Saint John </option>
                
                    <option value="208" data-chained="BB">
                        Saint John </option>
                
                    <option value="1962" data-chained="KN">
                        Saint John Capisterre </option>
                
                    <option value="1963" data-chained="KN">
                        Saint John Figtree </option>
                
                    <option value="853" data-chained="DM">
                        Saint Joseph </option>
                
                    <option value="209" data-chained="BB">
                        Saint Joseph </option>
                
                    <option value="2798" data-chained="NZ">
                        Saint Kilda </option>
                
                    <option value="3301" data-chained="SC">
                        Saint Louis </option>
                
                    <option value="210" data-chained="BB">
                        Saint Lucy </option>
                
                    <option value="854" data-chained="DM">
                        Saint Luke </option>
                
                    <option value="1341" data-chained="GD">
                        Saint Mark </option>
                
                    <option value="855" data-chained="DM">
                        Saint Mark </option>
                
                    <option value="50" data-chained="AG">
                        Saint Mary </option>
                
                    <option value="1855" data-chained="JM">
                        Saint Mary </option>
                
                    <option value="1964" data-chained="KN">
                        Saint Mary Cayon </option>
                
                    <option value="211" data-chained="BB">
                        Saint Michael </option>
                
                    <option value="1342" data-chained="GD">
                        Saint Patrick </option>
                
                    <option value="856" data-chained="DM">
                        Saint Patrick </option>
                
                    <option value="4001" data-chained="VC">
                        Saint Patrick </option>
                
                    <option value="3805" data-chained="TT">
                        Saint Patrick </option>
                
                    <option value="51" data-chained="AG">
                        Saint Paul </option>
                
                    <option value="857" data-chained="DM">
                        Saint Paul </option>
                
                    <option value="1965" data-chained="KN">
                        Saint Paul Capisterre </option>
                
                    <option value="1966" data-chained="KN">
                        Saint Paul Charlestown </option>
                
                    <option value="52" data-chained="AG">
                        Saint Peter </option>
                
                    <option value="858" data-chained="DM">
                        Saint Peter </option>
                
                    <option value="2421" data-chained="MS">
                        Saint Peter </option>
                
                    <option value="212" data-chained="BB">
                        Saint Peter </option>
                
                    <option value="1967" data-chained="KN">
                        Saint Peter Basseterre </option>
                
                    <option value="3227" data-chained="RU">
                        Saint Petersburg City </option>
                
                    <option value="53" data-chained="AG">
                        Saint Philip </option>
                
                    <option value="213" data-chained="BB">
                        Saint Philip </option>
                
                    <option value="1856" data-chained="JM">
                        Saint Thomas </option>
                
                    <option value="214" data-chained="BB">
                        Saint Thomas </option>
                
                    <option value="1968" data-chained="KN">
                        Saint Thomas Lowland </option>
                
                    <option value="1969" data-chained="KN">
                        Saint Thomas Middle Island </option>
                
                    <option value="3504" data-chained="SN">
                        Saint-Louis </option>
                
                    <option value="1901" data-chained="JP">
                        Saitama </option>
                
                    <option value="3759" data-chained="TR">
                        Sakarya </option>
                
                    <option value="632" data-chained="CI">
                        Sakassou </option>
                
                    <option value="3224" data-chained="RU">
                        Sakha </option>
                
                    <option value="3225" data-chained="RU">
                        Sakhalin </option>
                
                    <option value="180" data-chained="AZ">
                        Saki </option>
                
                    <option value="3626" data-chained="TH">
                        Sakon Nakhon </option>
                
                    <option value="768" data-chained="CV">
                        Sal </option>
                
                    <option value="1760" data-chained="IQ">
                        Salah ad Din </option>
                
                    <option value="3149" data-chained="RO">
                        Salaj </option>
                
                    <option value="3585" data-chained="TD">
                        Salamat </option>
                
                    <option value="875" data-chained="DO">
                        Salcedo </option>
                
                    <option value="2144" data-chained="LV">
                        Saldus </option>
                
                    <option value="1211" data-chained="GB">
                        Salford </option>
                
                    <option value="2471" data-chained="MW">
                        Salima </option>
                
                    <option value="110" data-chained="AR">
                        Salta </option>
                
                    <option value="3979" data-chained="UY">
                        Salto </option>
                
                    <option value="181" data-chained="AZ">
                        Salyan </option>
                
                    <option value="122" data-chained="AT">
                        Salzburg </option>
                
                    <option value="876" data-chained="DO">
                        Samana </option>
                
                    <option value="43" data-chained="AF">
                        Samangan </option>
                
                    <option value="2917" data-chained="PH">
                        Samar </option>
                
                    <option value="3226" data-chained="RU">
                        Samara </option>
                
                    <option value="3993" data-chained="UZ">
                        Samarqand </option>
                
                    <option value="182" data-chained="AZ">
                        Samaxi </option>
                
                    <option value="489" data-chained="BT">
                        Samchi </option>
                
                    <option value="490" data-chained="BT">
                        Samdrup </option>
                
                    <option value="183" data-chained="AZ">
                        Samkir </option>
                
                    <option value="2322" data-chained="MK">
                        Samokov </option>
                
                    <option value="1514" data-chained="GR">
                        Samos </option>
                
                    <option value="3760" data-chained="TR">
                        Samsun </option>
                
                    <option value="1390" data-chained="GE">
                        Samtrediis Raioni </option>
                
                    <option value="3648" data-chained="TH">
                        Samut Prakan </option>
                
                    <option value="3661" data-chained="TH">
                        Samut Sakhon </option>
                
                    <option value="3660" data-chained="TH">
                        Samut Songkhram </option>
                
                    <option value="184" data-chained="AZ">
                        Samux </option>
                
                    <option value="4114" data-chained="YE">
                        San </option>
                
                    <option value="727" data-chained="CO">
                        San Andres y Providencia </option>
                
                    <option value="2818" data-chained="PA">
                        San Blas </option>
                
                    <option value="2983" data-chained="PH">
                        San Carlos </option>
                
                    <option value="888" data-chained="DO">
                        San Cristobal </option>
                
                    <option value="3806" data-chained="TT">
                        San Fernando </option>
                
                    <option value="3980" data-chained="UY">
                        San Jose </option>
                
                    <option value="2984" data-chained="PH">
                        San Jose </option>
                
                    <option value="747" data-chained="CR">
                        San Jose </option>
                
                    <option value="878" data-chained="DO">
                        San Juan </option>
                
                    <option value="111" data-chained="AR">
                        San Juan </option>
                
                    <option value="112" data-chained="AR">
                        San Luis </option>
                
                    <option value="2503" data-chained="MX">
                        San Luis Potosi </option>
                
                    <option value="1534" data-chained="GT">
                        San Marcos </option>
                
                    <option value="3499" data-chained="SM">
                        San Marino </option>
                
                    <option value="2841" data-chained="PE">
                        San Martin </option>
                
                    <option value="3548" data-chained="SV">
                        San Miguel </option>
                
                    <option value="2985" data-chained="PH">
                        San Pablo </option>
                
                    <option value="3105" data-chained="PY">
                        San Pedro </option>
                
                    <option value="633" data-chained="CI">
                        San Pedro </option>
                
                    <option value="879" data-chained="DO">
                        San Pedro De Macoris </option>
                
                    <option value="3549" data-chained="SV">
                        San Salvador </option>
                
                    <option value="477" data-chained="BS">
                        San Salvador and Rum Cay </option>
                
                    <option value="3551" data-chained="SV">
                        San Vicente </option>
                
                    <option value="3523" data-chained="SO">
                        Sanaag </option>
                
                    <option value="877" data-chained="DO">
                        Sanchez Ramirez </option>
                
                    <option value="760" data-chained="CU">
                        Sancti Spiritus </option>
                
                    <option value="2862" data-chained="PG">
                        Sandaun </option>
                
                    <option value="1213" data-chained="GB">
                        Sandwell </option>
                
                    <option value="476" data-chained="BS">
                        Sandy Point </option>
                
                    <option value="405" data-chained="BM">
                        Sandys </option>
                
                    <option value="568" data-chained="CG">
                        Sangha </option>
                
                    <option value="558" data-chained="CF">
                        Sangha-Mbaere </option>
                
                    <option value="298" data-chained="BF">
                        Sanguie </option>
                
                    <option value="585" data-chained="CH">
                        Sankt Gallen </option>
                
                    <option value="3767" data-chained="TR">
                        Sanliurfa </option>
                
                    <option value="4089" data-chained="VU">
                        Sanma </option>
                
                    <option value="327" data-chained="BF">
                        Sanmatenga </option>
                
                    <option value="5" data-chained="AD">
                        Sant Julia de Loria </option>
                
                    <option value="3550" data-chained="SV">
                        Santa Ana </option>
                
                    <option value="1574" data-chained="HN">
                        Santa Barbara </option>
                
                    <option value="773" data-chained="CV">
                        Santa Catarina </option>
                
                    <option value="451" data-chained="BR">
                        Santa Catarina </option>
                
                    <option value="774" data-chained="CV">
                        Santa Cruz </option>
                
                    <option value="113" data-chained="AR">
                        Santa Cruz </option>
                
                    <option value="428" data-chained="BO">
                        Santa Cruz </option>
                
                    <option value="114" data-chained="AR">
                        Santa Fe </option>
                
                    <option value="1535" data-chained="GT">
                        Santa Rosa </option>
                
                    <option value="728" data-chained="CO">
                        Santander </option>
                
                    <option value="3085" data-chained="PT">
                        Santarem </option>
                
                    <option value="880" data-chained="DO">
                        Santiago </option>
                
                    <option value="761" data-chained="CU">
                        Santiago de Cuba </option>
                
                    <option value="115" data-chained="AR">
                        Santiago del Estero </option>
                
                    <option value="881" data-chained="DO">
                        Santiago Rodriguez </option>
                
                    <option value="775" data-chained="CV">
                        Sao Domingos </option>
                
                    <option value="776" data-chained="CV">
                        Sao Filipe </option>
                
                    <option value="777" data-chained="CV">
                        Sao Miguel </option>
                
                    <option value="769" data-chained="CV">
                        Sao Nicolau </option>
                
                    <option value="452" data-chained="BR">
                        Sao Paulo </option>
                
                    <option value="3539" data-chained="ST">
                        Sao Tome </option>
                
                    <option value="770" data-chained="CV">
                        Sao Vicente </option>
                
                    <option value="44" data-chained="AF">
                        Sar-e Pol </option>
                
                    <option value="3643" data-chained="TH">
                        Saraburi </option>
                
                    <option value="2323" data-chained="MK">
                        Saraj </option>
                
                    <option value="3535" data-chained="SR">
                        Saramacca </option>
                
                    <option value="3228" data-chained="RU">
                        Saratov </option>
                
                    <option value="2035" data-chained="LA">
                        Saravan </option>
                
                    <option value="2521" data-chained="MY">
                        Sarawak </option>
                
                    <option value="1839" data-chained="IT">
                        Sardegna </option>
                
                    <option value="528" data-chained="CA">
                        Saskatchewan </option>
                
                    <option value="634" data-chained="CI">
                        Sassandra </option>
                
                    <option value="271" data-chained="BD">
                        Satkhira </option>
                
                    <option value="3150" data-chained="RO">
                        Satu Mare </option>
                
                    <option value="3673" data-chained="TH">
                        Satun </option>
                
                    <option value="4102" data-chained="WS">
                        Satupa </option>
                
                    <option value="1813" data-chained="IS">
                        Saudarkrokur </option>
                
                    <option value="2036" data-chained="LA">
                        Savannakhet </option>
                
                    <option value="2430" data-chained="MU">
                        Savanne </option>
                
                    <option value="2171" data-chained="LY">
                        Sawfajjin </option>
                
                    <option value="2064" data-chained="LI">
                        Schaan </option>
                
                    <option value="586" data-chained="CH">
                        Schaffhausen </option>
                
                    <option value="2065" data-chained="LI">
                        Schellenberg </option>
                
                    <option value="823" data-chained="DE">
                        Schleswig-Holstein </option>
                
                    <option value="587" data-chained="CH">
                        Schwyz </option>
                
                    <option value="1287" data-chained="GB">
                        Scottish Borders, The </option>
                
                    <option value="2434" data-chained="MV">
                        Seenu </option>
                
                    <option value="1214" data-chained="GB">
                        Sefton </option>
                
                    <option value="2360" data-chained="ML">
                        Segou </option>
                
                    <option value="611" data-chained="CI">
                        Seguela </option>
                
                    <option value="2522" data-chained="MY">
                        Selangor </option>
                
                    <option value="2395" data-chained="MN">
                        Selenge </option>
                
                    <option value="3881" data-chained="UG">
                        Sembabule </option>
                
                    <option value="3422" data-chained="SI">
                        Semic </option>
                
                    <option value="799" data-chained="CZ">
                        Semily </option>
                
                    <option value="1776" data-chained="IR">
                        Semnan </option>
                
                    <option value="1391" data-chained="GE">
                        Senakis Raioni </option>
                
                    <option value="3423" data-chained="SI">
                        Sencur </option>
                
                    <option value="328" data-chained="BF">
                        Seno </option>
                
                    <option value="3424" data-chained="SI">
                        Sentilj </option>
                
                    <option value="3425" data-chained="SI">
                        Sentjernej </option>
                
                    <option value="3476" data-chained="SI">
                        Sentjur pri Celju </option>
                
                    <option value="1989" data-chained="KR">
                        Seoul-t'ukpyolsi </option>
                
                    <option value="453" data-chained="BR">
                        Sergipe </option>
                
                    <option value="1471" data-chained="GR">
                        Serrai </option>
                
                    <option value="3501" data-chained="SM">
                        Serravalle </option>
                
                    <option value="2682" data-chained="NP">
                        Seti </option>
                
                    <option value="896" data-chained="DZ">
                        Setif </option>
                
                    <option value="2200" data-chained="MA">
                        Settat </option>
                
                    <option value="3086" data-chained="PT">
                        Setubal </option>
                
                    <option value="3857" data-chained="UA">
                        Sevastopol' </option>
                
                    <option value="3426" data-chained="SI">
                        Sevnica </option>
                
                    <option value="1814" data-chained="IS">
                        Seydisfjordur </option>
                
                    <option value="3427" data-chained="SI">
                        Sezana </option>
                
                    <option value="701" data-chained="CN">
                        Shaanxi </option>
                
                    <option value="3524" data-chained="SO">
                        Shabeellaha Dhexe </option>
                
                    <option value="3525" data-chained="SO">
                        Shabeellaha Hoose </option>
                
                    <option value="4108" data-chained="YE">
                        Shabwah </option>
                
                    <option value="1005" data-chained="EG">
                        Shamal Sina' </option>
                
                    <option value="2376" data-chained="MM">
                        Shan State </option>
                
                    <option value="700" data-chained="CN">
                        Shandong </option>
                
                    <option value="698" data-chained="CN">
                        Shanghai </option>
                
                    <option value="699" data-chained="CN">
                        Shanxi </option>
                
                    <option value="272" data-chained="BD">
                        Shariyatpur </option>
                
                    <option value="13" data-chained="AE">
                        Sharjah </option>
                
                    <option value="2447" data-chained="MV">
                        Shaviyani </option>
                
                    <option value="4094" data-chained="VU">
                        Shefa </option>
                
                    <option value="1215" data-chained="GB">
                        Sheffield </option>
                
                    <option value="491" data-chained="BT">
                        Shemgang </option>
                
                    <option value="4090" data-chained="VU">
                        Shepherd </option>
                
                    <option value="273" data-chained="BD">
                        Sherpur </option>
                
                    <option value="1308" data-chained="GB">
                        Shetland Islands </option>
                
                    <option value="1902" data-chained="JP">
                        Shiga </option>
                
                    <option value="1903" data-chained="JP">
                        Shimane </option>
                
                    <option value="3827" data-chained="TZ">
                        Shinyanga </option>
                
                    <option value="72" data-chained="AM">
                        Shirak </option>
                
                    <option value="3571" data-chained="SZ">
                        Shiselweni </option>
                
                    <option value="1904" data-chained="JP">
                        Shizuoka </option>
                
                    <option value="63" data-chained="AL">
                        Shkoder </option>
                
                    <option value="1212" data-chained="GB">
                        Shropshire </option>
                
                    <option value="353" data-chained="BG">
                        Shumen </option>
                
                    <option value="2118" data-chained="LT">
                        Siauliu Apskritis </option>
                
                    <option value="1589" data-chained="HR">
                        Sibensko-Kninska </option>
                
                    <option value="3151" data-chained="RO">
                        Sibiu </option>
                
                    <option value="706" data-chained="CN">
                        Sichuan </option>
                
                    <option value="1840" data-chained="IT">
                        Sicilia </option>
                
                    <option value="911" data-chained="DZ">
                        Sidi Bel Abbes </option>
                
                    <option value="3706" data-chained="TN">
                        Sidi Bu Zayd </option>
                
                    <option value="2210" data-chained="MA">
                        Sidi Kacem </option>
                
                    <option value="3040" data-chained="PL">
                        Siedlce </option>
                
                    <option value="1945" data-chained="KH">
                        Siemreab-Otdar Meanchey </option>
                
                    <option value="3041" data-chained="PL">
                        Sieradz </option>
                
                    <option value="1392" data-chained="GE">
                        Sighnaghis Raioni </option>
                
                    <option value="1815" data-chained="IS">
                        Siglufjordur </option>
                
                    <option value="1459" data-chained="GN">
                        Siguiri </option>
                
                    <option value="3777" data-chained="TR">
                        Siirt </option>
                
                    <option value="2361" data-chained="ML">
                        Sikasso </option>
                
                    <option value="1732" data-chained="IN">
                        Sikkim </option>
                
                    <option value="2986" data-chained="PH">
                        Silay </option>
                
                    <option value="354" data-chained="BG">
                        Silistra </option>
                
                    <option value="973" data-chained="EE">
                        Sillamae </option>
                
                    <option value="2792" data-chained="NZ">
                        Silverpeaks </option>
                
                    <option value="3699" data-chained="TN">
                        Silyanah </option>
                
                    <option value="2504" data-chained="MX">
                        Sinaloa </option>
                
                    <option value="3002" data-chained="PK">
                        Sindh </option>
                
                    <option value="635" data-chained="CI">
                        Sinfra </option>
                
                    <option value="3639" data-chained="TH">
                        Sing Buri </option>
                
                    <option value="3828" data-chained="TZ">
                        Singida </option>
                
                    <option value="2100" data-chained="LR">
                        Sino </option>
                
                    <option value="3761" data-chained="TR">
                        Sinop </option>
                
                    <option value="3536" data-chained="SR">
                        Sipaliwini </option>
                
                    <option value="2324" data-chained="MK">
                        Sipkovica </option>
                
                    <option value="2931" data-chained="PH">
                        Siquijor </option>
                
                    <option value="274" data-chained="BD">
                        Sirajganj </option>
                
                    <option value="3994" data-chained="UZ">
                        Sirdaryo </option>
                
                    <option value="3783" data-chained="TR">
                        Sirnak </option>
                
                    <option value="3899" data-chained="UG">
                        Sironko </option>
                
                    <option value="1590" data-chained="HR">
                        Sisacko-Moslavacka </option>
                
                    <option value="3636" data-chained="TH">
                        Sisaket </option>
                
                    <option value="329" data-chained="BF">
                        Sissili </option>
                
                    <option value="1764" data-chained="IR">
                        Sistan va Baluchestan </option>
                
                    <option value="369" data-chained="BH">
                        Sitrah </option>
                
                    <option value="3762" data-chained="TR">
                        Sivas </option>
                
                    <option value="185" data-chained="AZ">
                        Siyazan </option>
                
                    <option value="1816" data-chained="IS">
                        Skagafjardarsysla </option>
                
                    <option value="3335" data-chained="SE">
                        Skane Lan </option>
                
                    <option value="3327" data-chained="SE">
                        Skaraborgs Lan </option>
                
                    <option value="3042" data-chained="PL">
                        Skierniewice </option>
                
                    <option value="912" data-chained="DZ">
                        Skikda </option>
                
                    <option value="3428" data-chained="SI">
                        Skocjan </option>
                
                    <option value="3429" data-chained="SI">
                        Skofja Loka </option>
                
                    <option value="3430" data-chained="SI">
                        Skofljica </option>
                
                    <option value="3066" data-chained="PL">
                        Slaskie </option>
                
                    <option value="1696" data-chained="IE">
                        Sligo </option>
                
                    <option value="355" data-chained="BG">
                        Sliven </option>
                
                    <option value="1216" data-chained="GB">
                        Slough </option>
                
                    <option value="3431" data-chained="SI">
                        Slovenj Gradec </option>
                
                    <option value="3477" data-chained="SI">
                        Slovenska Bistrica </option>
                
                    <option value="3432" data-chained="SI">
                        Slovenske Konjice </option>
                
                    <option value="3043" data-chained="PL">
                        Slupsk </option>
                
                    <option value="3433" data-chained="SI">
                        Smarje pri Jelsah </option>
                
                    <option value="3434" data-chained="SI">
                        Smartno ob Paki </option>
                
                    <option value="406" data-chained="BM">
                        Smiths </option>
                
                    <option value="3230" data-chained="RU">
                        Smolensk </option>
                
                    <option value="356" data-chained="BG">
                        Smolyan </option>
                
                    <option value="1817" data-chained="IS">
                        Snafellsnes- og Hnappadalssysla </option>
                
                    <option value="4075" data-chained="VN">
                        Soc Trang </option>
                
                    <option value="3328" data-chained="SE">
                        Sodermanlands Lan </option>
                
                    <option value="2531" data-chained="MZ">
                        Sofala </option>
                
                    <option value="357" data-chained="BG">
                        Sofiya </option>
                
                    <option value="2663" data-chained="NO">
                        Sogn og Fjordane </option>
                
                    <option value="2612" data-chained="NG">
                        Sokoto </option>
                
                    <option value="1217" data-chained="GB">
                        Solihull </option>
                
                    <option value="1536" data-chained="GT">
                        Solola </option>
                
                    <option value="588" data-chained="CH">
                        Solothurn </option>
                
                    <option value="1024" data-chained="ET">
                        Somali </option>
                
                    <option value="1218" data-chained="GB">
                        Somerset </option>
                
                    <option value="1623" data-chained="HU">
                        Somogy </option>
                
                    <option value="4039" data-chained="VN">
                        Son La </option>
                
                    <option value="844" data-chained="DK">
                        Sonderjylland </option>
                
                    <option value="4051" data-chained="VN">
                        Song Be </option>
                
                    <option value="3674" data-chained="TH">
                        Songkhla </option>
                
                    <option value="2505" data-chained="MX">
                        Sonora </option>
                
                    <option value="3552" data-chained="SV">
                        Sonsonate </option>
                
                    <option value="2325" data-chained="MK">
                        Sopiste </option>
                
                    <option value="2326" data-chained="MK">
                        Sopotnica </option>
                
                    <option value="1640" data-chained="HU">
                        Sopron </option>
                
                    <option value="2664" data-chained="NO">
                        Sor-Trondelag </option>
                
                    <option value="3981" data-chained="UY">
                        Soriano </option>
                
                    <option value="2225" data-chained="MD">
                        Soroca </option>
                
                    <option value="3900" data-chained="UG">
                        Soroti </option>
                
                    <option value="2920" data-chained="PH">
                        Sorsogon </option>
                
                    <option value="3435" data-chained="SI">
                        Sostanj </option>
                
                    <option value="3602" data-chained="TG">
                        Sotouboua </option>
                
                    <option value="618" data-chained="CI">
                        Soubre </option>
                
                    <option value="2055" data-chained="LC">
                        Soufriere </option>
                
                    <option value="932" data-chained="DZ">
                        Souk Ahras </option>
                
                    <option value="299" data-chained="BF">
                        Soum </option>
                
                    <option value="330" data-chained="BF">
                        Sourou </option>
                
                    <option value="131" data-chained="AU">
                        South Australia </option>
                
                    <option value="1309" data-chained="GB">
                        South Ayrshire </option>
                
                    <option value="3867" data-chained="UG">
                        South Buganda </option>
                
                    <option value="3953" data-chained="US">
                        South Carolina </option>
                
                    <option value="2932" data-chained="PH">
                        South Cotabato </option>
                
                    <option value="3954" data-chained="US">
                        South Dakota </option>
                
                    <option value="1106" data-chained="GB">
                        South Glamorgan </option>
                
                    <option value="1221" data-chained="GB">
                        South Gloucestershire </option>
                
                    <option value="2020" data-chained="KZ">
                        South Kazakhstan </option>
                
                    <option value="1310" data-chained="GB">
                        South Lanarkshire </option>
                
                    <option value="2007" data-chained="KY">
                        South Town </option>
                
                    <option value="1222" data-chained="GB">
                        South Tyneside </option>
                
                    <option value="1093" data-chained="GB">
                        South Yorkshire </option>
                
                    <option value="504" data-chained="BW">
                        South-East </option>
                
                    <option value="407" data-chained="BM">
                        Southampton </option>
                
                    <option value="1219" data-chained="GB">
                        Southampton </option>
                
                    <option value="1220" data-chained="GB">
                        Southend-on-Sea </option>
                
                    <option value="1027" data-chained="ET">
                        Southern </option>
                
                    <option value="3873" data-chained="UG">
                        Southern </option>
                
                    <option value="4136" data-chained="ZM">
                        Southern </option>
                
                    <option value="3491" data-chained="SL">
                        Southern </option>
                
                    <option value="505" data-chained="BW">
                        Southern </option>
                
                    <option value="1042" data-chained="FI">
                        Southern Finland </option>
                
                    <option value="2849" data-chained="PG">
                        Southern Highlands </option>
                
                    <option value="2921" data-chained="PH">
                        Southern Leyte </option>
                
                    <option value="2758" data-chained="NZ">
                        Southland </option>
                
                    <option value="1223" data-chained="GB">
                        Southwark </option>
                
                    <option value="1591" data-chained="HR">
                        Splitsko-Dalmatinska </option>
                
                    <option value="2008" data-chained="KY">
                        Spot Bay </option>
                
                    <option value="2327" data-chained="MK">
                        Srbinovo </option>
                
                    <option value="1225" data-chained="GB">
                        St. Helens </option>
                
                    <option value="839" data-chained="DK">
                        Staden Kobenhavn </option>
                
                    <option value="1224" data-chained="GB">
                        Staffordshire </option>
                
                    <option value="2009" data-chained="KY">
                        Stake Bay </option>
                
                    <option value="517" data-chained="BZ">
                        Stann Creek </option>
                
                    <option value="2329" data-chained="MK">
                        Star Dojran </option>
                
                    <option value="358" data-chained="BG">
                        Stara Zagora </option>
                
                    <option value="2328" data-chained="MK">
                        Staravina </option>
                
                    <option value="2330" data-chained="MK">
                        Staro Nagoricane </option>
                
                    <option value="3436" data-chained="SI">
                        Starse </option>
                
                    <option value="3231" data-chained="RU">
                        Stavropol' </option>
                
                    <option value="123" data-chained="AT">
                        Steiermark </option>
                
                    <option value="2759" data-chained="NZ">
                        Stewart Island </option>
                
                    <option value="2220" data-chained="MD">
                        Stinga Nistrului </option>
                
                    <option value="2331" data-chained="MK">
                        Stip </option>
                
                    <option value="1311" data-chained="GB">
                        Stirling </option>
                
                    <option value="3334" data-chained="SE">
                        Stockholms Lan </option>
                
                    <option value="1226" data-chained="GB">
                        Stockport </option>
                
                    <option value="1227" data-chained="GB">
                        Stockton-on-Tees </option>
                
                    <option value="1946" data-chained="KH">
                        Stoeng Treng </option>
                
                    <option value="1228" data-chained="GB">
                        Stoke-on-Trent </option>
                
                    <option value="3437" data-chained="SI">
                        Store </option>
                
                    <option value="845" data-chained="DK">
                        Storstrom </option>
                
                    <option value="1282" data-chained="GB">
                        Strabane </option>
                
                    <option value="1818" data-chained="IS">
                        Strandasysla </option>
                
                    <option value="2760" data-chained="NZ">
                        Stratford </option>
                
                    <option value="2793" data-chained="NZ">
                        Strathallan </option>
                
                    <option value="1100" data-chained="GB">
                        Strathclyde </option>
                
                    <option value="811" data-chained="CZ">
                        Stredocesky Kraj </option>
                
                    <option value="2332" data-chained="MK">
                        Struga </option>
                
                    <option value="2333" data-chained="MK">
                        Strumica </option>
                
                    <option value="2334" data-chained="MK">
                        Studenicani </option>
                
                    <option value="3152" data-chained="RO">
                        Suceava </option>
                
                    <option value="1537" data-chained="GT">
                        Suchitepequez </option>
                
                    <option value="4020" data-chained="VE">
                        Sucre </option>
                
                    <option value="729" data-chained="CO">
                        Sucre </option>
                
                    <option value="956" data-chained="EC">
                        Sucumbios </option>
                
                    <option value="1605" data-chained="HT">
                        Sud </option>
                
                    <option value="676" data-chained="CM">
                        Sud </option>
                
                    <option value="1606" data-chained="HT">
                        Sud-Est </option>
                
                    <option value="543" data-chained="CD">
                        Sud-Kivu </option>
                
                    <option value="671" data-chained="CM">
                        Sud-Ouest </option>
                
                    <option value="1819" data-chained="IS">
                        Sudur-Mulasysla </option>
                
                    <option value="1820" data-chained="IS">
                        Sudur-Tingeyjarsysla </option>
                
                    <option value="1229" data-chained="GB">
                        Suffolk </option>
                
                    <option value="3683" data-chained="TJ">
                        Sughd </option>
                
                    <option value="1003" data-chained="EG">
                        Suhaj </option>
                
                    <option value="2396" data-chained="MN">
                        Suhbaatar </option>
                
                    <option value="3616" data-chained="TH">
                        Sukhothai </option>
                
                    <option value="1663" data-chained="ID">
                        Sulawesi Selatan </option>
                
                    <option value="1664" data-chained="ID">
                        Sulawesi Tengah </option>
                
                    <option value="1665" data-chained="ID">
                        Sulawesi Tenggara </option>
                
                    <option value="1671" data-chained="ID">
                        Sulawesi Utara </option>
                
                    <option value="2933" data-chained="PH">
                        Sultan Kudarat </option>
                
                    <option value="2922" data-chained="PH">
                        Sulu </option>
                
                    <option value="1038" data-chained="ET">
                        Sumale </option>
                
                    <option value="1666" data-chained="ID">
                        Sumatera Barat </option>
                
                    <option value="1672" data-chained="ID">
                        Sumatera Selatan </option>
                
                    <option value="1667" data-chained="ID">
                        Sumatera Utara </option>
                
                    <option value="186" data-chained="AZ">
                        Sumqayit </option>
                
                    <option value="3858" data-chained="UA">
                        Sums'ka Oblast' </option>
                
                    <option value="275" data-chained="BD">
                        Sunamganj </option>
                
                    <option value="1230" data-chained="GB">
                        Sunderland </option>
                
                    <option value="3657" data-chained="TH">
                        Suphan Buri </option>
                
                    <option value="3666" data-chained="TH">
                        Surat Thani </option>
                
                    <option value="2987" data-chained="PH">
                        Surigao </option>
                
                    <option value="2923" data-chained="PH">
                        Surigao del Norte </option>
                
                    <option value="2924" data-chained="PH">
                        Surigao del Sur </option>
                
                    <option value="3635" data-chained="TH">
                        Surin </option>
                
                    <option value="3995" data-chained="UZ">
                        Surkhondaryo </option>
                
                    <option value="1231" data-chained="GB">
                        Surrey </option>
                
                    <option value="2172" data-chained="LY">
                        Surt </option>
                
                    <option value="187" data-chained="AZ">
                        Susa </option>
                
                    <option value="3700" data-chained="TN">
                        Susah </option>
                
                    <option value="2335" data-chained="MK">
                        Suto Orizari </option>
                
                    <option value="1232" data-chained="GB">
                        Sutton </option>
                
                    <option value="3044" data-chained="PL">
                        Suwalki </option>
                
                    <option value="1947" data-chained="KH">
                        Svay Rieng </option>
                
                    <option value="3232" data-chained="RU">
                        Sverdlovsk </option>
                
                    <option value="3438" data-chained="SI">
                        Sveti Jurij </option>
                
                    <option value="2336" data-chained="MK">
                        Sveti Nikole </option>
                
                    <option value="2553" data-chained="NA">
                        Swakopmund </option>
                
                    <option value="1333" data-chained="GB">
                        Swansea </option>
                
                    <option value="3067" data-chained="PL">
                        Swietokrzyskie </option>
                
                    <option value="1233" data-chained="GB">
                        Swindon </option>
                
                    <option value="276" data-chained="BD">
                        Sylhet </option>
                
                    <option value="73" data-chained="AM">
                        Syunik' </option>
                
                    <option value="1624" data-chained="HU">
                        Szabolcs-Szatmar-Bereg </option>
                
                    <option value="3045" data-chained="PL">
                        Szczecin </option>
                
                    <option value="1625" data-chained="HU">
                        Szeged </option>
                
                    <option value="1641" data-chained="HU">
                        Szekesfehervar </option>
                
                    <option value="1642" data-chained="HU">
                        Szolnok </option>
                
                    <option value="1643" data-chained="HU">
                        Szombathely </option>
                
                    <option value="3811" data-chained="TW">
                        T'ai-pei </option>
                
                    <option value="3812" data-chained="TW">
                        T'ai-wan </option>
                
                    <option value="1393" data-chained="GE">
                        T'bilisi </option>
                
                    <option value="1394" data-chained="GE">
                        T'elavis Raioni </option>
                
                    <option value="1395" data-chained="GE">
                        T'erjolis Raioni </option>
                
                    <option value="1396" data-chained="GE">
                        T'et'ritsqaros Raioni </option>
                
                    <option value="1397" data-chained="GE">
                        T'ianet'is Raioni </option>
                
                    <option value="4120" data-chained="YE">
                        Ta </option>
                
                    <option value="2506" data-chained="MX">
                        Tabasco </option>
                
                    <option value="3603" data-chained="TG">
                        Tabligbo </option>
                
                    <option value="3829" data-chained="TZ">
                        Tabora </option>
                
                    <option value="636" data-chained="CI">
                        Tabou </option>
                
                    <option value="3273" data-chained="SA">
                        Tabuk </option>
                
                    <option value="4021" data-chained="VE">
                        Tachira </option>
                
                    <option value="2988" data-chained="PH">
                        Tacloban </option>
                
                    <option value="2842" data-chained="PE">
                        Tacna </option>
                
                    <option value="3982" data-chained="UY">
                        Tacuarembo </option>
                
                    <option value="833" data-chained="DJ">
                        Tadjoura </option>
                
                    <option value="1993" data-chained="KR">
                        Taegu-jikhalsi </option>
                
                    <option value="1997" data-chained="KR">
                        Taejon-jikhalsi </option>
                
                    <option value="4091" data-chained="VU">
                        Tafea </option>
                
                    <option value="2415" data-chained="MR">
                        Tagant </option>
                
                    <option value="2989" data-chained="PH">
                        Tagaytay </option>
                
                    <option value="2990" data-chained="PH">
                        Tagbilaran </option>
                
                    <option value="2580" data-chained="NE">
                        Tahoua </option>
                
                    <option value="3615" data-chained="TH">
                        Tak </option>
                
                    <option value="3302" data-chained="SC">
                        Takamaka </option>
                
                    <option value="1948" data-chained="KH">
                        Takev </option>
                
                    <option value="37" data-chained="AF">
                        Takhar </option>
                
                    <option value="1927" data-chained="KG">
                        Talas </option>
                
                    <option value="974" data-chained="EE">
                        Tallinn </option>
                
                    <option value="2145" data-chained="LV">
                        Talsu </option>
                
                    <option value="933" data-chained="DZ">
                        Tamanghasset </option>
                
                    <option value="2507" data-chained="MX">
                        Tamaulipas </option>
                
                    <option value="3505" data-chained="SN">
                        Tambacounda </option>
                
                    <option value="3233" data-chained="RU">
                        Tambovskaya oblast </option>
                
                    <option value="1234" data-chained="GB">
                        Tameside </option>
                
                    <option value="1729" data-chained="IN">
                        Tamil Nadu </option>
                
                    <option value="2208" data-chained="MA">
                        Tan-Tan </option>
                
                    <option value="637" data-chained="CI">
                        Tanda </option>
                
                    <option value="3586" data-chained="TD">
                        Tandjile </option>
                
                    <option value="3830" data-chained="TZ">
                        Tanga </option>
                
                    <option value="277" data-chained="BD">
                        Tangail </option>
                
                    <option value="2201" data-chained="MA">
                        Tanger </option>
                
                    <option value="2991" data-chained="PH">
                        Tangub </option>
                
                    <option value="2209" data-chained="MA">
                        Taounate </option>
                
                    <option value="300" data-chained="BF">
                        Tapoa </option>
                
                    <option value="2604" data-chained="NG">
                        Taraba </option>
                
                    <option value="2173" data-chained="LY">
                        Tarabulus </option>
                
                    <option value="2761" data-chained="NZ">
                        Taranaki </option>
                
                    <option value="666" data-chained="CL">
                        Tarapaca </option>
                
                    <option value="2156" data-chained="LY">
                        Tarhunah </option>
                
                    <option value="429" data-chained="BO">
                        Tarija </option>
                
                    <option value="2925" data-chained="PH">
                        Tarlac </option>
                
                    <option value="3046" data-chained="PL">
                        Tarnobrzeg </option>
                
                    <option value="3047" data-chained="PL">
                        Tarnow </option>
                
                    <option value="2211" data-chained="MA">
                        Taroudannt </option>
                
                    <option value="778" data-chained="CV">
                        Tarrafal </option>
                
                    <option value="188" data-chained="AZ">
                        Tartar </option>
                
                    <option value="975" data-chained="EE">
                        Tartu </option>
                
                    <option value="976" data-chained="EE">
                        Tartumaa </option>
                
                    <option value="3567" data-chained="SY">
                        Tartus </option>
                
                    <option value="492" data-chained="BT">
                        Tashigang </option>
                
                    <option value="132" data-chained="AU">
                        Tasmania </option>
                
                    <option value="2202" data-chained="MA">
                        Tata </option>
                
                    <option value="1644" data-chained="HU">
                        Tatabanya </option>
                
                    <option value="3234" data-chained="RU">
                        Tatarstan </option>
                
                    <option value="3707" data-chained="TN">
                        Tatawin </option>
                
                    <option value="2762" data-chained="NZ">
                        Taumarunui </option>
                
                    <option value="2763" data-chained="NZ">
                        Taupo </option>
                
                    <option value="2119" data-chained="LT">
                        Taurages Apskritis </option>
                
                    <option value="2764" data-chained="NZ">
                        Tauranga </option>
                
                    <option value="74" data-chained="AM">
                        Tavush </option>
                
                    <option value="2934" data-chained="PH">
                        Tawitawi </option>
                
                    <option value="3708" data-chained="TN">
                        Tawzar </option>
                
                    <option value="4040" data-chained="VN">
                        Tay Ninh </option>
                
                    <option value="3235" data-chained="RU">
                        Taymyr </option>
                
                    <option value="1101" data-chained="GB">
                        Tayside </option>
                
                    <option value="2203" data-chained="MA">
                        Taza </option>
                
                    <option value="3605" data-chained="TG">
                        Tchamba </option>
                
                    <option value="3606" data-chained="TG">
                        Tchaoudjo </option>
                
                    <option value="2337" data-chained="MK">
                        Tearce </option>
                
                    <option value="913" data-chained="DZ">
                        Tebessa </option>
                
                    <option value="1777" data-chained="IR">
                        Tehran </option>
                
                    <option value="3763" data-chained="TR">
                        Tekirdag </option>
                
                    <option value="1706" data-chained="IL">
                        Tel Aviv </option>
                
                    <option value="2665" data-chained="NO">
                        Telemark </option>
                
                    <option value="3153" data-chained="RO">
                        Teleorman </option>
                
                    <option value="1235" data-chained="GB">
                        Telford and Wrekin </option>
                
                    <option value="1447" data-chained="GN">
                        Telimele </option>
                
                    <option value="2120" data-chained="LT">
                        Telsiu Apskritis </option>
                
                    <option value="412" data-chained="BN">
                        Temburong </option>
                
                    <option value="3280" data-chained="SB">
                        Temotu </option>
                
                    <option value="2377" data-chained="MM">
                        Tenasserim </option>
                
                    <option value="3955" data-chained="US">
                        Tennessee </option>
                
                    <option value="2523" data-chained="MY">
                        Terengganu </option>
                
                    <option value="3859" data-chained="UA">
                        Ternopil's'ka Oblast' </option>
                
                    <option value="2534" data-chained="MZ">
                        Tete </option>
                
                    <option value="2212" data-chained="MA">
                        Tetouan </option>
                
                    <option value="2338" data-chained="MK">
                        Tetovo </option>
                
                    <option value="3956" data-chained="US">
                        Texas </option>
                
                    <option value="2440" data-chained="MV">
                        Thaa </option>
                
                    <option value="2112" data-chained="LS">
                        Thaba-Tseka </option>
                
                    <option value="4042" data-chained="VN">
                        Thai Binh </option>
                
                    <option value="278" data-chained="BD">
                        Thakurgaon </option>
                
                    <option value="2799" data-chained="NZ">
                        Thames-Coromandel </option>
                
                    <option value="4041" data-chained="VN">
                        Thanh Hoa </option>
                
                    <option value="1484" data-chained="GR">
                        Thesprotia </option>
                
                    <option value="1479" data-chained="GR">
                        Thessaloniki </option>
                
                    <option value="3506" data-chained="SN">
                        Thies </option>
                
                    <option value="493" data-chained="BT">
                        Thimphu </option>
                
                    <option value="4076" data-chained="VN">
                        Thua Thien </option>
                
                    <option value="589" data-chained="CH">
                        Thurgau </option>
                
                    <option value="828" data-chained="DE">
                        Thuringen </option>
                
                    <option value="1236" data-chained="GB">
                        Thurrock </option>
                
                    <option value="2456" data-chained="MW">
                        Thyolo </option>
                
                    <option value="702" data-chained="CN">
                        Tianjin </option>
                
                    <option value="897" data-chained="DZ">
                        Tiaret </option>
                
                    <option value="638" data-chained="CI">
                        Tiassale </option>
                
                    <option value="590" data-chained="CH">
                        Ticino </option>
                
                    <option value="651" data-chained="CI">
                        Tiebissou </option>
                
                    <option value="4043" data-chained="VN">
                        Tien Giang </option>
                
                    <option value="116" data-chained="AR">
                        Tierra del Fuego </option>
                
                    <option value="2226" data-chained="MD">
                        Tighina </option>
                
                    <option value="1028" data-chained="ET">
                        Tigray </option>
                
                    <option value="3154" data-chained="RO">
                        Timis </option>
                
                    <option value="934" data-chained="DZ">
                        Tindouf </option>
                
                    <option value="619" data-chained="CI">
                        Tingrela </option>
                
                    <option value="935" data-chained="DZ">
                        Tipaza </option>
                
                    <option value="1697" data-chained="IE">
                        Tipperary </option>
                
                    <option value="64" data-chained="AL">
                        Tirane </option>
                
                    <option value="2417" data-chained="MR">
                        Tiris Zemmour </option>
                
                    <option value="124" data-chained="AT">
                        Tirol </option>
                
                    <option value="936" data-chained="DZ">
                        Tissemsilt </option>
                
                    <option value="898" data-chained="DZ">
                        Tizi Ouzou </option>
                
                    <option value="2204" data-chained="MA">
                        Tiznit </option>
                
                    <option value="2508" data-chained="MX">
                        Tlaxcala </option>
                
                    <option value="899" data-chained="DZ">
                        Tlemcen </option>
                
                    <option value="2231" data-chained="MG">
                        Toamasina </option>
                
                    <option value="3807" data-chained="TT">
                        Tobago </option>
                
                    <option value="456" data-chained="BR">
                        Tocantins </option>
                
                    <option value="1905" data-chained="JP">
                        Tochigi </option>
                
                    <option value="3526" data-chained="SO">
                        Togdheer </option>
                
                    <option value="3764" data-chained="TR">
                        Tokat </option>
                
                    <option value="1906" data-chained="JP">
                        Tokushima </option>
                
                    <option value="1907" data-chained="JP">
                        Tokyo </option>
                
                    <option value="518" data-chained="BZ">
                        Toledo </option>
                
                    <option value="2992" data-chained="PH">
                        Toledo </option>
                
                    <option value="2233" data-chained="MG">
                        Toliara </option>
                
                    <option value="730" data-chained="CO">
                        Tolima </option>
                
                    <option value="3439" data-chained="SI">
                        Tolmin </option>
                
                    <option value="1627" data-chained="HU">
                        Tolna </option>
                
                    <option value="1545" data-chained="GW">
                        Tombali </option>
                
                    <option value="2363" data-chained="ML">
                        Tombouctou </option>
                
                    <option value="3236" data-chained="RU">
                        Tomsk </option>
                
                    <option value="3714" data-chained="TO">
                        Tongatapu </option>
                
                    <option value="494" data-chained="BT">
                        Tongsa </option>
                
                    <option value="2339" data-chained="MK">
                        Topolcani </option>
                
                    <option value="4083" data-chained="VU">
                        Torba </option>
                
                    <option value="1237" data-chained="GB">
                        Torbay </option>
                
                    <option value="1334" data-chained="GB">
                        Torfaen </option>
                
                    <option value="3048" data-chained="PL">
                        Torun </option>
                
                    <option value="1841" data-chained="IT">
                        Toscana </option>
                
                    <option value="3996" data-chained="UZ">
                        Toshkent </option>
                
                    <option value="1538" data-chained="GT">
                        Totonicapan </option>
                
                    <option value="1908" data-chained="JP">
                        Tottori </option>
                
                    <option value="612" data-chained="CI">
                        Touba </option>
                
                    <option value="1448" data-chained="GN">
                        Tougue </option>
                
                    <option value="652" data-chained="CI">
                        Toulepleu </option>
                
                    <option value="639" data-chained="CI">
                        Toumodi </option>
                
                    <option value="2397" data-chained="MN">
                        Tov </option>
                
                    <option value="189" data-chained="AZ">
                        Tovuz </option>
                
                    <option value="1238" data-chained="GB">
                        Tower Hamlets </option>
                
                    <option value="1909" data-chained="JP">
                        Toyama </option>
                
                    <option value="1398" data-chained="GE">
                        Tqibuli </option>
                
                    <option value="4077" data-chained="VN">
                        Tra Vinh </option>
                
                    <option value="3765" data-chained="TR">
                        Trabzon </option>
                
                    <option value="1239" data-chained="GB">
                        Trafford </option>
                
                    <option value="3671" data-chained="TH">
                        Trang </option>
                
                    <option value="2412" data-chained="MR">
                        Trarza </option>
                
                    <option value="3655" data-chained="TH">
                        Trat </option>
                
                    <option value="3440" data-chained="SI">
                        Trbovlje </option>
                
                    <option value="3441" data-chained="SI">
                        Trebnje </option>
                
                    <option value="2993" data-chained="PH">
                        Trece Martires </option>
                
                    <option value="3983" data-chained="UY">
                        Treinta y Tres </option>
                
                    <option value="1857" data-chained="JM">
                        Trelawny </option>
                
                    <option value="3486" data-chained="SK">
                        Trencin </option>
                
                    <option value="1842" data-chained="IT">
                        Trentino-Alto Adige </option>
                
                    <option value="2066" data-chained="LI">
                        Triesen </option>
                
                    <option value="2067" data-chained="LI">
                        Triesenberg </option>
                
                    <option value="1488" data-chained="GR">
                        Trikala </option>
                
                    <option value="2086" data-chained="LK">
                        Trincomalee </option>
                
                    <option value="1970" data-chained="KN">
                        Trinity Palmetto Point </option>
                
                    <option value="1730" data-chained="IN">
                        Tripura </option>
                
                    <option value="3339" data-chained="SH">
                        Tristan da Cunha </option>
                
                    <option value="3487" data-chained="SK">
                        Trnava </option>
                
                    <option value="2666" data-chained="NO">
                        Troms </option>
                
                    <option value="4022" data-chained="VE">
                        Trujillo </option>
                
                    <option value="800" data-chained="CZ">
                        Trutnov </option>
                
                    <option value="3442" data-chained="SI">
                        Trzic </option>
                
                    <option value="1399" data-chained="GE">
                        Ts'ageris Raioni </option>
                
                    <option value="1400" data-chained="GE">
                        Tsalenjikhis Raioni </option>
                
                    <option value="1401" data-chained="GE">
                        Tsalkis Raioni </option>
                
                    <option value="3604" data-chained="TG">
                        Tsevie </option>
                
                    <option value="1402" data-chained="GE">
                        Tsqaltubo </option>
                
                    <option value="2554" data-chained="NA">
                        Tsumeb </option>
                
                    <option value="4103" data-chained="WS">
                        Tuamasaga </option>
                
                    <option value="2765" data-chained="NZ">
                        Tuapeka </option>
                
                    <option value="2157" data-chained="LY">
                        Tubruq </option>
                
                    <option value="117" data-chained="AR">
                        Tucuman </option>
                
                    <option value="2146" data-chained="LV">
                        Tukuma </option>
                
                    <option value="3237" data-chained="RU">
                        Tula </option>
                
                    <option value="3155" data-chained="RO">
                        Tulcea </option>
                
                    <option value="2843" data-chained="PE">
                        Tumbes </option>
                
                    <option value="3766" data-chained="TR">
                        Tunceli </option>
                
                    <option value="954" data-chained="EC">
                        Tungurahua </option>
                
                    <option value="3709" data-chained="TN">
                        Tunis </option>
                
                    <option value="359" data-chained="BG">
                        Turgovishte </option>
                
                    <option value="3443" data-chained="SI">
                        Turnisce </option>
                
                    <option value="417" data-chained="BN">
                        Tutong </option>
                
                    <option value="3240" data-chained="RU">
                        Tuva </option>
                
                    <option value="331" data-chained="BF">
                        Tuy </option>
                
                    <option value="4078" data-chained="VN">
                        Tuyen Quang </option>
                
                    <option value="3238" data-chained="RU">
                        Tver' </option>
                
                    <option value="1094" data-chained="GB">
                        Tyne and Wear </option>
                
                    <option value="3239" data-chained="RU">
                        Tyumen' </option>
                
                    <option value="2695" data-chained="NR">
                        Uaboe </option>
                
                    <option value="3678" data-chained="TH">
                        Ubon Ratchathani </option>
                
                    <option value="190" data-chained="AZ">
                        Ucar </option>
                
                    <option value="2844" data-chained="PE">
                        Ucayali </option>
                
                    <option value="3241" data-chained="RU">
                        Udmurt </option>
                
                    <option value="3679" data-chained="TH">
                        Udon Thani </option>
                
                    <option value="88" data-chained="AO">
                        Uige </option>
                
                    <option value="3242" data-chained="RU">
                        Ul'yanovsk </option>
                
                    <option value="2399" data-chained="MN">
                        Ulaanbaatar </option>
                
                    <option value="1999" data-chained="KR">
                        Ulsan-gwangyoksi </option>
                
                    <option value="1843" data-chained="IT">
                        Umbria </option>
                
                    <option value="14" data-chained="AE">
                        Umm Al Quwain </option>
                
                    <option value="3119" data-chained="QA">
                        Umm Sa'id </option>
                
                    <option value="3116" data-chained="QA">
                        Umm Salal </option>
                
                    <option value="2227" data-chained="MD">
                        Ungheni </option>
                
                    <option value="1557" data-chained="GY">
                        Upper Demerara-Berbice </option>
                
                    <option value="1415" data-chained="GH">
                        Upper East </option>
                
                    <option value="1423" data-chained="GM">
                        Upper River </option>
                
                    <option value="1558" data-chained="GY">
                        Upper Takutu-Upper Essequibo </option>
                
                    <option value="1416" data-chained="GH">
                        Upper West </option>
                
                    <option value="3329" data-chained="SE">
                        Uppsala Lan </option>
                
                    <option value="591" data-chained="CH">
                        Uri </option>
                
                    <option value="3768" data-chained="TR">
                        Usak </option>
                
                    <option value="3243" data-chained="RU">
                        Ust-Orda Buryat </option>
                
                    <option value="812" data-chained="CZ">
                        Ustecky Kraj </option>
                
                    <option value="3553" data-chained="SV">
                        Usulutan </option>
                
                    <option value="3957" data-chained="US">
                        Utah </option>
                
                    <option value="2121" data-chained="LT">
                        Utenos Apskritis </option>
                
                    <option value="3622" data-chained="TH">
                        Uthai Thani </option>
                
                    <option value="2643" data-chained="NL">
                        Utrecht </option>
                
                    <option value="1739" data-chained="IN">
                        Uttar Pradesh </option>
                
                    <option value="3617" data-chained="TH">
                        Uttaradit </option>
                
                    <option value="1742" data-chained="IN">
                        Uttaranchal </option>
                
                    <option value="2398" data-chained="MN">
                        Uvs </option>
                
                    <option value="4099" data-chained="WS">
                        Va </option>
                
                    <option value="2068" data-chained="LI">
                        Vaduz </option>
                
                    <option value="4104" data-chained="WS">
                        Vaisigano </option>
                
                    <option value="556" data-chained="CF">
                        Vakaga </option>
                
                    <option value="592" data-chained="CH">
                        Valais </option>
                
                    <option value="2340" data-chained="MK">
                        Valandovo </option>
                
                    <option value="3157" data-chained="RO">
                        Valcea </option>
                
                    <option value="1335" data-chained="GB">
                        Vale of Glamorgan, The </option>
                
                    <option value="977" data-chained="EE">
                        Valgamaa </option>
                
                    <option value="2147" data-chained="LV">
                        Valkas </option>
                
                    <option value="1575" data-chained="HN">
                        Valle </option>
                
                    <option value="1844" data-chained="IT">
                        Valle d'Aosta </option>
                
                    <option value="731" data-chained="CO">
                        Valle del Cauca </option>
                
                    <option value="2148" data-chained="LV">
                        Valmieras </option>
                
                    <option value="654" data-chained="CL">
                        Valparaiso </option>
                
                    <option value="882" data-chained="DO">
                        Valverde </option>
                
                    <option value="3769" data-chained="TR">
                        Van </option>
                
                    <option value="1403" data-chained="GE">
                        Vanis Raioni </option>
                
                    <option value="1592" data-chained="HR">
                        Varazdinska </option>
                
                    <option value="38" data-chained="AF">
                        Vardak </option>
                
                    <option value="4027" data-chained="VE">
                        Vargas </option>
                
                    <option value="3330" data-chained="SE">
                        Varmlands Lan </option>
                
                    <option value="360" data-chained="BG">
                        Varna </option>
                
                    <option value="1628" data-chained="HU">
                        Vas </option>
                
                    <option value="2341" data-chained="MK">
                        Vasilevo </option>
                
                    <option value="3156" data-chained="RO">
                        Vaslui </option>
                
                    <option value="3331" data-chained="SE">
                        Vasterbottens Lan </option>
                
                    <option value="3332" data-chained="SE">
                        Vasternorrlands Lan </option>
                
                    <option value="3333" data-chained="SE">
                        Vastmanlands Lan </option>
                
                    <option value="3336" data-chained="SE">
                        Vastra Gotaland </option>
                
                    <option value="593" data-chained="CH">
                        Vaud </option>
                
                    <option value="732" data-chained="CO">
                        Vaupes </option>
                
                    <option value="3715" data-chained="TO">
                        Vava </option>
                
                    <option value="640" data-chained="CI">
                        Vavoua </option>
                
                    <option value="2092" data-chained="LK">
                        Vavuniya </option>
                
                    <option value="75" data-chained="AM">
                        Vayots' Dzor </option>
                
                    <option value="846" data-chained="DK">
                        Vejle </option>
                
                    <option value="3444" data-chained="SI">
                        Velenje </option>
                
                    <option value="2342" data-chained="MK">
                        Veles </option>
                
                    <option value="2343" data-chained="MK">
                        Velesta </option>
                
                    <option value="3445" data-chained="SI">
                        Velike Lasce </option>
                
                    <option value="361" data-chained="BG">
                        Veliko Turnovo </option>
                
                    <option value="1845" data-chained="IT">
                        Veneto </option>
                
                    <option value="2149" data-chained="LV">
                        Ventspils </option>
                
                    <option value="2509" data-chained="MX">
                        Veracruz-Llave </option>
                
                    <option value="2819" data-chained="PA">
                        Veraguas </option>
                
                    <option value="3960" data-chained="US">
                        Vermont </option>
                
                    <option value="2667" data-chained="NO">
                        Vest-Agder </option>
                
                    <option value="2668" data-chained="NO">
                        Vestfold </option>
                
                    <option value="1419" data-chained="GL">
                        Vestgronland </option>
                
                    <option value="1821" data-chained="IS">
                        Vestmannaeyjar </option>
                
                    <option value="847" data-chained="DK">
                        Vestsjalland </option>
                
                    <option value="1822" data-chained="IS">
                        Vestur-Bardastrandarsysla </option>
                
                    <option value="1823" data-chained="IS">
                        Vestur-Hunavatnssysla </option>
                
                    <option value="1824" data-chained="IS">
                        Vestur-Isafjardarsysla </option>
                
                    <option value="1825" data-chained="IS">
                        Vestur-Skaftafellssysla </option>
                
                    <option value="1629" data-chained="HU">
                        Veszprem </option>
                
                    <option value="2344" data-chained="MK">
                        Vevcani </option>
                
                    <option value="3087" data-chained="PT">
                        Viana do Castelo </option>
                
                    <option value="848" data-chained="DK">
                        Viborg </option>
                
                    <option value="733" data-chained="CO">
                        Vichada </option>
                
                    <option value="133" data-chained="AU">
                        Victoria </option>
                
                    <option value="3808" data-chained="TT">
                        Victoria </option>
                
                    <option value="3478" data-chained="SI">
                        Videm </option>
                
                    <option value="362" data-chained="BG">
                        Vidin </option>
                
                    <option value="2037" data-chained="LA">
                        Vientiane </option>
                
                    <option value="2056" data-chained="LC">
                        Vieux-Fort </option>
                
                    <option value="3088" data-chained="PT">
                        Vila Real </option>
                
                    <option value="978" data-chained="EE">
                        Viljandimaa </option>
                
                    <option value="762" data-chained="CU">
                        Villa Clara </option>
                
                    <option value="2122" data-chained="LT">
                        Vilniaus Apskritis </option>
                
                    <option value="2766" data-chained="NZ">
                        Vincent </option>
                
                    <option value="4079" data-chained="VN">
                        Vinh Long </option>
                
                    <option value="4052" data-chained="VN">
                        Vinh Phu </option>
                
                    <option value="2345" data-chained="MK">
                        Vinica </option>
                
                    <option value="3860" data-chained="UA">
                        Vinnyts'ka Oblast' </option>
                
                    <option value="3446" data-chained="SI">
                        Vipava </option>
                
                    <option value="3959" data-chained="US">
                        Virgin Islands </option>
                
                    <option value="3958" data-chained="US">
                        Virginia </option>
                
                    <option value="1593" data-chained="HR">
                        Viroviticko-Podravska </option>
                
                    <option value="3089" data-chained="PT">
                        Viseu </option>
                
                    <option value="3447" data-chained="SI">
                        Vitanje </option>
                
                    <option value="2346" data-chained="MK">
                        Vitoliste </option>
                
                    <option value="512" data-chained="BY">
                        Vitsyebskaya Voblasts' </option>
                
                    <option value="290" data-chained="BE">
                        Vlaams-Brabant </option>
                
                    <option value="3244" data-chained="RU">
                        Vladimir </option>
                
                    <option value="65" data-chained="AL">
                        Vlore </option>
                
                    <option value="3448" data-chained="SI">
                        Vodice </option>
                
                    <option value="3607" data-chained="TG">
                        Vogan </option>
                
                    <option value="1499" data-chained="GR">
                        Voiotia </option>
                
                    <option value="3479" data-chained="SI">
                        Vojnik </option>
                
                    <option value="3245" data-chained="RU">
                        Volgograd </option>
                
                    <option value="3246" data-chained="RU">
                        Vologda </option>
                
                    <option value="1413" data-chained="GH">
                        Volta </option>
                
                    <option value="3861" data-chained="UA">
                        Volyns'ka Oblast' </option>
                
                    <option value="125" data-chained="AT">
                        Vorarlberg </option>
                
                    <option value="3247" data-chained="RU">
                        Voronezh </option>
                
                    <option value="979" data-chained="EE">
                        Vorumaa </option>
                
                    <option value="3158" data-chained="RO">
                        Vrancea </option>
                
                    <option value="2347" data-chained="MK">
                        Vranestica </option>
                
                    <option value="2348" data-chained="MK">
                        Vrapciste </option>
                
                    <option value="2349" data-chained="MK">
                        Vratnica </option>
                
                    <option value="363" data-chained="BG">
                        Vratsa </option>
                
                    <option value="3449" data-chained="SI">
                        Vrhnika </option>
                
                    <option value="2350" data-chained="MK">
                        Vrutok </option>
                
                    <option value="1594" data-chained="HR">
                        Vukovarsko-Srijemska </option>
                
                    <option value="3450" data-chained="SI">
                        Vuzenica </option>
                
                    <option value="803" data-chained="CZ">
                        Vysocina </option>
                
                    <option value="2437" data-chained="MV">
                        Waavu </option>
                
                    <option value="2767" data-chained="NZ">
                        Waiapu </option>
                
                    <option value="2794" data-chained="NZ">
                        Waiheke </option>
                
                    <option value="2768" data-chained="NZ">
                        Waihemo </option>
                
                    <option value="2769" data-chained="NZ">
                        Waikato </option>
                
                    <option value="2770" data-chained="NZ">
                        Waikohu </option>
                
                    <option value="2771" data-chained="NZ">
                        Waimairi </option>
                
                    <option value="2772" data-chained="NZ">
                        Waimarino </option>
                
                    <option value="2773" data-chained="NZ">
                        Waimate </option>
                
                    <option value="2774" data-chained="NZ">
                        Waimate West </option>
                
                    <option value="2775" data-chained="NZ">
                        Waimea </option>
                
                    <option value="2776" data-chained="NZ">
                        Waipa </option>
                
                    <option value="2777" data-chained="NZ">
                        Waipawa </option>
                
                    <option value="2778" data-chained="NZ">
                        Waipukurau </option>
                
                    <option value="2779" data-chained="NZ">
                        Wairarapa South </option>
                
                    <option value="2780" data-chained="NZ">
                        Wairewa </option>
                
                    <option value="2781" data-chained="NZ">
                        Wairoa </option>
                
                    <option value="2785" data-chained="NZ">
                        Waitaki </option>
                
                    <option value="2786" data-chained="NZ">
                        Waitomo </option>
                
                    <option value="2787" data-chained="NZ">
                        Waitotara </option>
                
                    <option value="1910" data-chained="JP">
                        Wakayama </option>
                
                    <option value="1240" data-chained="GB">
                        Wakefield </option>
                
                    <option value="3901" data-chained="UG">
                        Wakiso </option>
                
                    <option value="3049" data-chained="PL">
                        Walbrzych </option>
                
                    <option value="2801" data-chained="NZ">
                        Wallace </option>
                
                    <option value="1241" data-chained="GB">
                        Walsall </option>
                
                    <option value="1242" data-chained="GB">
                        Waltham Forest </option>
                
                    <option value="1243" data-chained="GB">
                        Wandsworth </option>
                
                    <option value="2788" data-chained="NZ">
                        Wanganui </option>
                
                    <option value="495" data-chained="BT">
                        Wangdi Phodrang </option>
                
                    <option value="3537" data-chained="SR">
                        Wanica </option>
                
                    <option value="3068" data-chained="PL">
                        Warminsko-Mazurskie </option>
                
                    <option value="1244" data-chained="GB">
                        Warrington </option>
                
                    <option value="3050" data-chained="PL">
                        Warszawa </option>
                
                    <option value="408" data-chained="BM">
                        Warwick </option>
                
                    <option value="1245" data-chained="GB">
                        Warwickshire </option>
                
                    <option value="3961" data-chained="US">
                        Washington </option>
                
                    <option value="1758" data-chained="IQ">
                        Wasit </option>
                
                    <option value="1698" data-chained="IE">
                        Waterford </option>
                
                    <option value="2800" data-chained="NZ">
                        Waverley </option>
                
                    <option value="1466" data-chained="GQ">
                        Wele-Nzas </option>
                
                    <option value="1731" data-chained="IN">
                        West Bengal </option>
                
                    <option value="1246" data-chained="GB">
                        West Berkshire </option>
                
                    <option value="1312" data-chained="GB">
                        West Dunbartonshire </option>
                
                    <option value="2010" data-chained="KY">
                        West End </option>
                
                    <option value="1107" data-chained="GB">
                        West Glamorgan </option>
                
                    <option value="2017" data-chained="KZ">
                        West Kazakhstan </option>
                
                    <option value="1314" data-chained="GB">
                        West Lothian </option>
                
                    <option value="1095" data-chained="GB">
                        West Midlands </option>
                
                    <option value="2861" data-chained="PG">
                        West New Britain </option>
                
                    <option value="1248" data-chained="GB">
                        West Sussex </option>
                
                    <option value="3963" data-chained="US">
                        West Virginia </option>
                
                    <option value="1096" data-chained="GB">
                        West Yorkshire </option>
                
                    <option value="287" data-chained="BE">
                        West-Vlaanderen </option>
                
                    <option value="1049" data-chained="FJ">
                        Western </option>
                
                    <option value="2850" data-chained="PG">
                        Western </option>
                
                    <option value="3874" data-chained="UG">
                        Western </option>
                
                    <option value="4130" data-chained="ZM">
                        Western </option>
                
                    <option value="1922" data-chained="KE">
                        Western </option>
                
                    <option value="1414" data-chained="GH">
                        Western </option>
                
                    <option value="1424" data-chained="GM">
                        Western </option>
                
                    <option value="3275" data-chained="SB">
                        Western </option>
                
                    <option value="2011" data-chained="KY">
                        Western </option>
                
                    <option value="3492" data-chained="SL">
                        Western Area </option>
                
                    <option value="134" data-chained="AU">
                        Western Australia </option>
                
                    <option value="4129" data-chained="ZA">
                        Western Cape </option>
                
                    <option value="1044" data-chained="FI">
                        Western Finland </option>
                
                    <option value="2860" data-chained="PG">
                        Western Highlands </option>
                
                    <option value="2789" data-chained="NZ">
                        Westland </option>
                
                    <option value="1699" data-chained="IE">
                        Westmeath </option>
                
                    <option value="1247" data-chained="GB">
                        Westminster </option>
                
                    <option value="1858" data-chained="JM">
                        Westmoreland </option>
                
                    <option value="1700" data-chained="IE">
                        Wexford </option>
                
                    <option value="2790" data-chained="NZ">
                        Whakatane </option>
                
                    <option value="2782" data-chained="NZ">
                        Whangarei </option>
                
                    <option value="2783" data-chained="NZ">
                        Whangaroa </option>
                
                    <option value="1701" data-chained="IE">
                        Wicklow </option>
                
                    <option value="3069" data-chained="PL">
                        Wielkopolskie </option>
                
                    <option value="126" data-chained="AT">
                        Wien </option>
                
                    <option value="1249" data-chained="GB">
                        Wigan </option>
                
                    <option value="2524" data-chained="MY">
                        Wilayah Persekutuan </option>
                
                    <option value="1250" data-chained="GB">
                        Wiltshire </option>
                
                    <option value="2556" data-chained="NA">
                        Windhoek </option>
                
                    <option value="1251" data-chained="GB">
                        Windsor and Maidenhead </option>
                
                    <option value="1252" data-chained="GB">
                        Wirral </option>
                
                    <option value="3962" data-chained="US">
                        Wisconsin </option>
                
                    <option value="3051" data-chained="PL">
                        Wloclawek </option>
                
                    <option value="1253" data-chained="GB">
                        Wokingham </option>
                
                    <option value="1084" data-chained="GA">
                        Woleu-Ntem </option>
                
                    <option value="1254" data-chained="GB">
                        Wolverhampton </option>
                
                    <option value="2784" data-chained="NZ">
                        Woodville </option>
                
                    <option value="3527" data-chained="SO">
                        Woqooyi Galbeed </option>
                
                    <option value="1255" data-chained="GB">
                        Worcestershire </option>
                
                    <option value="1336" data-chained="GB">
                        Wrexham </option>
                
                    <option value="3052" data-chained="PL">
                        Wroclaw </option>
                
                    <option value="3964" data-chained="US">
                        Wyoming </option>
                
                    <option value="191" data-chained="AZ">
                        Xacmaz </option>
                
                    <option value="2038" data-chained="LA">
                        Xaignabouri </option>
                
                    <option value="192" data-chained="AZ">
                        Xankandi </option>
                
                    <option value="193" data-chained="AZ">
                        Xanlar </option>
                
                    <option value="1469" data-chained="GR">
                        Xanthi </option>
                
                    <option value="2039" data-chained="LA">
                        Xiangkhoang </option>
                
                    <option value="689" data-chained="CN">
                        Xinjiang </option>
                
                    <option value="690" data-chained="CN">
                        Xizang </option>
                
                    <option value="194" data-chained="AZ">
                        Xizi </option>
                
                    <option value="195" data-chained="AZ">
                        Xocali </option>
                
                    <option value="196" data-chained="AZ">
                        Xocavand </option>
                
                    <option value="2174" data-chained="LY">
                        Yafran </option>
                
                    <option value="332" data-chained="BF">
                        Yagha </option>
                
                    <option value="3676" data-chained="TH">
                        Yala </option>
                
                    <option value="3795" data-chained="TR">
                        Yalova </option>
                
                    <option value="1911" data-chained="JP">
                        Yamagata </option>
                
                    <option value="1912" data-chained="JP">
                        Yamaguchi </option>
                
                    <option value="3248" data-chained="RU">
                        Yamal-Nenets </option>
                
                    <option value="1913" data-chained="JP">
                        Yamanashi </option>
                
                    <option value="364" data-chained="BG">
                        Yambol </option>
                
                    <option value="653" data-chained="CI">
                        Yamoussoukro </option>
                
                    <option value="1979" data-chained="KP">
                        Yanggang-do </option>
                
                    <option value="2380" data-chained="MM">
                        Yangon </option>
                
                    <option value="1053" data-chained="FM">
                        Yap </option>
                
                    <option value="4023" data-chained="VE">
                        Yaracuy </option>
                
                    <option value="197" data-chained="AZ">
                        Yardimli </option>
                
                    <option value="2696" data-chained="NR">
                        Yaren </option>
                
                    <option value="3249" data-chained="RU">
                        Yaroslavl' </option>
                
                    <option value="3677" data-chained="TH">
                        Yasothon </option>
                
                    <option value="333" data-chained="BF">
                        Yatenga </option>
                
                    <option value="1781" data-chained="IR">
                        Yazd </option>
                
                    <option value="1039" data-chained="ET">
                        YeDebub Biheroch Bihereseboch na Hizboch </option>
                
                    <option value="4080" data-chained="VN">
                        Yen Bai </option>
                
                    <option value="76" data-chained="AM">
                        Yerevan </option>
                
                    <option value="1707" data-chained="IL">
                        Yerushalayim </option>
                
                    <option value="198" data-chained="AZ">
                        Yevlax </option>
                
                    <option value="3250" data-chained="RU">
                        Yevrey </option>
                
                    <option value="2605" data-chained="NG">
                        Yobe </option>
                
                    <option value="1654" data-chained="ID">
                        Yogyakarta </option>
                
                    <option value="1449" data-chained="GN">
                        Yomou </option>
                
                    <option value="1256" data-chained="GB">
                        York </option>
                
                    <option value="1576" data-chained="HN">
                        Yoro </option>
                
                    <option value="3770" data-chained="TR">
                        Yozgat </option>
                
                    <option value="1928" data-chained="KG">
                        Ysyk-Kol </option>
                
                    <option value="2510" data-chained="MX">
                        Yucatan </option>
                
                    <option value="529" data-chained="CA">
                        Yukon Territory </option>
                
                    <option value="3902" data-chained="UG">
                        Yumbe </option>
                
                    <option value="703" data-chained="CN">
                        Yunnan </option>
                
                    <option value="39" data-chained="AF">
                        Zabol </option>
                
                    <option value="1539" data-chained="GT">
                        Zacapa </option>
                
                    <option value="2511" data-chained="MX">
                        Zacatecas </option>
                
                    <option value="3070" data-chained="PL">
                        Zachodniopomorskie </option>
                
                    <option value="1595" data-chained="HR">
                        Zadarska </option>
                
                    <option value="3710" data-chained="TN">
                        Zaghwan </option>
                
                    <option value="3451" data-chained="SI">
                        Zagorje ob Savi </option>
                
                    <option value="1596" data-chained="HR">
                        Zagrebacka </option>
                
                    <option value="89" data-chained="AO">
                        Zaire </option>
                
                    <option value="2351" data-chained="MK">
                        Zajas </option>
                
                    <option value="3862" data-chained="UA">
                        Zakarpats'ka Oblast' </option>
                
                    <option value="1494" data-chained="GR">
                        Zakinthos </option>
                
                    <option value="1630" data-chained="HU">
                        Zala </option>
                
                    <option value="1645" data-chained="HU">
                        Zalaegerszeg </option>
                
                    <option value="3480" data-chained="SI">
                        Zalec </option>
                
                    <option value="2926" data-chained="PH">
                        Zambales </option>
                
                    <option value="2535" data-chained="MZ">
                        Zambezia </option>
                
                    <option value="2994" data-chained="PH">
                        Zamboanga </option>
                
                    <option value="2927" data-chained="PH">
                        Zamboanga del Norte </option>
                
                    <option value="2928" data-chained="PH">
                        Zamboanga del Sur </option>
                
                    <option value="2618" data-chained="NG">
                        Zamfara </option>
                
                    <option value="955" data-chained="EC">
                        Zamora-Chinchipe </option>
                
                    <option value="3053" data-chained="PL">
                        Zamosc </option>
                
                    <option value="199" data-chained="AZ">
                        Zangilan </option>
                
                    <option value="1785" data-chained="IR">
                        Zanjan </option>
                
                    <option value="3833" data-chained="TZ">
                        Zanzibar Central </option>
                
                    <option value="3834" data-chained="TZ">
                        Zanzibar North </option>
                
                    <option value="3837" data-chained="TZ">
                        Zanzibar Urban </option>
                
                    <option value="3863" data-chained="UA">
                        Zaporiz'ka Oblast' </option>
                
                    <option value="200" data-chained="AZ">
                        Zaqatala </option>
                
                    <option value="201" data-chained="AZ">
                        Zardab </option>
                
                    <option value="3452" data-chained="SI">
                        Zavrc </option>
                
                    <option value="2644" data-chained="NL">
                        Zeeland </option>
                
                    <option value="2634" data-chained="NI">
                        Zelaya </option>
                
                    <option value="2352" data-chained="MK">
                        Zelenikovo </option>
                
                    <option value="3453" data-chained="SI">
                        Zelezniki </option>
                
                    <option value="2353" data-chained="MK">
                        Zelino </option>
                
                    <option value="1404" data-chained="GE">
                        Zestap'onis Raioni </option>
                
                    <option value="2027" data-chained="KZ">
                        Zhambyl </option>
                
                    <option value="678" data-chained="CN">
                        Zhejiang </option>
                
                    <option value="3864" data-chained="UA">
                        Zhytomyrs'ka Oblast' </option>
                
                    <option value="3054" data-chained="PL">
                        Zielona Gora </option>
                
                    <option value="3511" data-chained="SN">
                        Ziguinchor </option>
                
                    <option value="3488" data-chained="SK">
                        Zilina </option>
                
                    <option value="2581" data-chained="NE">
                        Zinder </option>
                
                    <option value="3454" data-chained="SI">
                        Ziri </option>
                
                    <option value="334" data-chained="BF">
                        Ziro </option>
                
                    <option value="2354" data-chained="MK">
                        Zitose </option>
                
                    <option value="2355" data-chained="MK">
                        Zletovo </option>
                
                    <option value="813" data-chained="CZ">
                        Zlinsky Kraj </option>
                
                    <option value="2158" data-chained="LY">
                        Zlitan </option>
                
                    <option value="2472" data-chained="MW">
                        Zomba </option>
                
                    <option value="335" data-chained="BF">
                        Zondoma </option>
                
                    <option value="3788" data-chained="TR">
                        Zonguldak </option>
                
                    <option value="398" data-chained="BJ">
                        Zou </option>
                
                    <option value="420" data-chained="BN">
                        Zou </option>
                
                    <option value="301" data-chained="BF">
                        Zoundweogo </option>
                
                    <option value="3455" data-chained="SI">
                        Zrece </option>
                
                    <option value="2356" data-chained="MK">
                        Zrnovci </option>
                
                    <option value="620" data-chained="CI">
                        Zuenoula </option>
                
                    <option value="2809" data-chained="OM">
                        Zufar </option>
                
                    <option value="594" data-chained="CH">
                        Zug </option>
                
                    <option value="1405" data-chained="GE">
                        Zugdidi </option>
                
                    <option value="1406" data-chained="GE">
                        Zugdidis Raioni </option>
                
                    <option value="2645" data-chained="NL">
                        Zuid-Holland </option>
                
                    <option value="2647" data-chained="NL">
                        Zuidelijke IJsselmeerpolders </option>
                
                    <option value="4024" data-chained="VE">
                        Zulia </option>
                
                    <option value="595" data-chained="CH">
                        Zurich </option>
                
            </select>
        </div>

        <div class="form-group col-md-6">
            <label for="countryid">Country <span class="text-danger">*</span></label>
            <select id="countryid" class="form-control" name="countryid" data-parsley-required="" data-parsley-error-message="Country is required" onchange="filterRegions(this.value)">
                <option value="">--</option>
                
                    <option value="AF">
                      Afghanistan  </option>
                
                    <option value="AL">
                      Albania  </option>
                
                    <option value="DZ">
                      Algeria  </option>
                
                    <option value="AD">
                      Andorra  </option>
                
                    <option value="AO">
                      Angola  </option>
                
                    <option value="AG">
                      Antigua and Barbuda  </option>
                
                    <option value="AR">
                      Argentina  </option>
                
                    <option value="AM">
                      Armenia  </option>
                
                    <option value="AU">
                      Australia  </option>
                
                    <option value="AT">
                      Austria  </option>
                
                    <option value="AZ">
                      Azerbaijan  </option>
                
                    <option value="BS">
                      Bahamas  </option>
                
                    <option value="BH">
                      Bahrain  </option>
                
                    <option value="BD">
                      Bangladesh  </option>
                
                    <option value="BB">
                      Barbados  </option>
                
                    <option value="BY">
                      Belarus  </option>
                
                    <option value="BE">
                      Belgium  </option>
                
                    <option value="BZ">
                      Belize  </option>
                
                    <option value="BJ">
                      Benin  </option>
                
                    <option value="BM">
                      Bermuda  </option>
                
                    <option value="BT">
                      Bhutan  </option>
                
                    <option value="BO">
                      Bolivia  </option>
                
                    <option value="BA">
                      Bosnia and Herzegovina  </option>
                
                    <option value="BW">
                      Botswana  </option>
                
                    <option value="BR">
                      Brazil  </option>
                
                    <option value="BN">
                      Brunei Darussalam  </option>
                
                    <option value="BG">
                      Bulgaria  </option>
                
                    <option value="BF">
                      Burkina Faso  </option>
                
                    <option value="BI">
                      Burundi  </option>
                
                    <option value="KH">
                      Cambodia  </option>
                
                    <option value="CM">
                      Cameroon  </option>
                
                    <option value="CA">
                      Canada  </option>
                
                    <option value="CV">
                      Cape Verde  </option>
                
                    <option value="KY">
                      Cayman Islands  </option>
                
                    <option value="CF">
                      Central African Republic  </option>
                
                    <option value="TD">
                      Chad  </option>
                
                    <option value="CL">
                      Chile  </option>
                
                    <option value="CN">
                      China  </option>
                
                    <option value="CO">
                      Colombia  </option>
                
                    <option value="KM">
                      Comoros  </option>
                
                    <option value="CG">
                      Congo  </option>
                
                    <option value="CR">
                      Costa Rica  </option>
                
                    <option value="CI">
                      Cote D'Ivoire  </option>
                
                    <option value="HR">
                      Croatia  </option>
                
                    <option value="CU">
                      Cuba  </option>
                
                    <option value="CY">
                      Cyprus  </option>
                
                    <option value="CZ">
                      Czech Republic  </option>
                
                    <option value="CD">
                      Democratic Republic of the Congo  </option>
                
                    <option value="DK">
                      Denmark  </option>
                
                    <option value="DJ">
                      Djibouti  </option>
                
                    <option value="DM">
                      Dominica  </option>
                
                    <option value="DO">
                      Dominican Republic  </option>
                
                    <option value="EC">
                      Ecuador  </option>
                
                    <option value="EG">
                      Egypt  </option>
                
                    <option value="SV">
                      El Salvador  </option>
                
                    <option value="GQ">
                      Equatorial Guinea  </option>
                
                    <option value="EE">
                      Estonia  </option>
                
                    <option value="ET">
                      Ethiopia  </option>
                
                    <option value="FJ">
                      Fiji  </option>
                
                    <option value="FI">
                      Finland  </option>
                
                    <option value="FR">
                      France  </option>
                
                    <option value="GA">
                      Gabon  </option>
                
                    <option value="GM">
                      Gambia  </option>
                
                    <option value="GE">
                      Georgia  </option>
                
                    <option value="DE">
                      Germany  </option>
                
                    <option value="GH">
                      Ghana  </option>
                
                    <option value="GR">
                      Greece  </option>
                
                    <option value="GL">
                      Greenland  </option>
                
                    <option value="GD">
                      Grenada  </option>
                
                    <option value="GT">
                      Guatemala  </option>
                
                    <option value="GN">
                      Guinea  </option>
                
                    <option value="GW">
                      Guinea-Bissau  </option>
                
                    <option value="GY">
                      Guyana  </option>
                
                    <option value="HT">
                      Haiti  </option>
                
                    <option value="HN">
                      Honduras  </option>
                
                    <option value="HU">
                      Hungary  </option>
                
                    <option value="IS">
                      Iceland  </option>
                
                    <option value="IN">
                      India  </option>
                
                    <option value="ID">
                      Indonesia  </option>
                
                    <option value="IR">
                      Iran  </option>
                
                    <option value="IQ">
                      Iraq  </option>
                
                    <option value="IE">
                      Ireland  </option>
                
                    <option value="IL">
                      Israel  </option>
                
                    <option value="IT">
                      Italy  </option>
                
                    <option value="JM">
                      Jamaica  </option>
                
                    <option value="JP">
                      Japan  </option>
                
                    <option value="JO">
                      Jordan  </option>
                
                    <option value="KZ">
                      Kazakhstan  </option>
                
                    <option value="KE">
                      Kenya  </option>
                
                    <option value="KI">
                      Kiribati  </option>
                
                    <option value="KW">
                      Kuwait  </option>
                
                    <option value="KG">
                      Kyrgyzstan  </option>
                
                    <option value="LA">
                      Laos  </option>
                
                    <option value="LV">
                      Latvia  </option>
                
                    <option value="LB">
                      Lebanon  </option>
                
                    <option value="LS">
                      Lesotho  </option>
                
                    <option value="LR">
                      Liberia  </option>
                
                    <option value="LY">
                      Libya  </option>
                
                    <option value="LI">
                      Liechtenstein  </option>
                
                    <option value="LT">
                      Lithuania  </option>
                
                    <option value="LU">
                      Luxembourg  </option>
                
                    <option value="MO">
                      Macao  </option>
                
                    <option value="MG">
                      Madagascar  </option>
                
                    <option value="MW">
                      Malawi  </option>
                
                    <option value="MY">
                      Malaysia  </option>
                
                    <option value="MV">
                      Maldives  </option>
                
                    <option value="ML">
                      Mali  </option>
                
                    <option value="MR">
                      Mauritania  </option>
                
                    <option value="MU">
                      Mauritius  </option>
                
                    <option value="MX">
                      Mexico  </option>
                
                    <option value="FM">
                      Micronesia  </option>
                
                    <option value="MD">
                      Moldova  </option>
                
                    <option value="MC">
                      Monaco  </option>
                
                    <option value="MN">
                      Mongolia  </option>
                
                    <option value="MS">
                      Montserrat  </option>
                
                    <option value="MA">
                      Morocco  </option>
                
                    <option value="MZ">
                      Mozambique  </option>
                
                    <option value="MM">
                      Myanmar  </option>
                
                    <option value="NA">
                      Namibia  </option>
                
                    <option value="NR">
                      Nauru  </option>
                
                    <option value="NP">
                      Nepal  </option>
                
                    <option value="NL">
                      Netherlands  </option>
                
                    <option value="NZ">
                      New Zealand  </option>
                
                    <option value="NI">
                      Nicaragua  </option>
                
                    <option value="NE">
                      Niger  </option>
                
                    <option value="NG">
                      Nigeria  </option>
                
                    <option value="KP">
                      North Korea  </option>
                
                    <option value="MK">
                      North Macedonia  </option>
                
                    <option value="NO">
                      Norway  </option>
                
                    <option value="OM">
                      Oman  </option>
                
                    <option value="PK">
                      Pakistan  </option>
                
                    <option value="PA">
                      Panama  </option>
                
                    <option value="PG">
                      Papua New Guinea  </option>
                
                    <option value="PY">
                      Paraguay  </option>
                
                    <option value="PE">
                      Peru  </option>
                
                    <option value="PH">
                      Philippines  </option>
                
                    <option value="PL">
                      Poland  </option>
                
                    <option value="PT">
                      Portugal  </option>
                
                    <option value="QA">
                      Qatar  </option>
                
                    <option value="RO">
                      Romania  </option>
                
                    <option value="RU">
                      Russia  </option>
                
                    <option value="RW">
                      Rwanda  </option>
                
                    <option value="SH">
                      Saint Helena  </option>
                
                    <option value="KN">
                      Saint Kitts and Nevis  </option>
                
                    <option value="LC">
                      Saint Lucia  </option>
                
                    <option value="VC">
                      Saint Vincent and the Grenadines  </option>
                
                    <option value="WS">
                      Samoa  </option>
                
                    <option value="SM">
                      San Marino  </option>
                
                    <option value="ST">
                      Sao Tome and Principe  </option>
                
                    <option value="SA">
                      Saudi Arabia  </option>
                
                    <option value="SN">
                      Senegal  </option>
                
                    <option value="SC">
                      Seychelles  </option>
                
                    <option value="SL">
                      Sierra Leone  </option>
                
                    <option value="SK">
                      Slovakia  </option>
                
                    <option value="SI">
                      Slovenia  </option>
                
                    <option value="SB">
                      Solomon Islands  </option>
                
                    <option value="SO">
                      Somalia  </option>
                
                    <option value="ZA">
                      South Africa  </option>
                
                    <option value="KR">
                      South Korea  </option>
                
                    <option value="ES">
                      Spain  </option>
                
                    <option value="LK">
                      Sri Lanka  </option>
                
                    <option value="SD">
                      Sudan  </option>
                
                    <option value="SR">
                      Suriname  </option>
                
                    <option value="SZ">
                      Swaziland  </option>
                
                    <option value="SE">
                      Sweden  </option>
                
                    <option value="CH">
                      Switzerland  </option>
                
                    <option value="SY">
                      Syrian Arab Republic  </option>
                
                    <option value="TW">
                      Taiwan  </option>
                
                    <option value="TJ">
                      Tajikistan  </option>
                
                    <option value="TZ">
                      Tanzania  </option>
                
                    <option value="TH">
                      Thailand  </option>
                
                    <option value="TG">
                      Togo  </option>
                
                    <option value="TO">
                      Tonga  </option>
                
                    <option value="TT">
                      Trinidad and Tobago  </option>
                
                    <option value="TN">
                      Tunisia  </option>
                
                    <option value="TR">
                      Turkey  </option>
                
                    <option value="TM">
                      Turkmenistan  </option>
                
                    <option value="UG">
                      Uganda  </option>
                
                    <option value="UA">
                      Ukraine  </option>
                
                    <option value="AE">
                      United Arab Emirates  </option>
                
                    <option value="GB">
                      United Kingdom  </option>
                
                    <option value="US" selected="">
                      United States  </option>
                
                    <option value="UY">
                      Uruguay  </option>
                
                    <option value="UZ">
                      Uzbekistan  </option>
                
                    <option value="VU">
                      Vanuatu  </option>
                
                    <option value="VE">
                      Venezuela  </option>
                
                    <option value="VN">
                      Viet Nam  </option>
                
                    <option value="YE">
                      Yemen  </option>
                
                    <option value="ZM">
                      Zambia  </option>
                
                    <option value="ZW">
                      Zimbabwe  </option>
                
            </select>
        </div>
    </div> <!--- end #hiddenLocation --->

    
    <div class="row" id="hiddenSelfTape" style="display: none;">
        
            <div class="form-group col-md-12">
                <label for="new_audLocation">Platform URL (optional)</label>
                <input class="form-control" type="text" id="new_audLocation" name="new_audLocation" placeholder="Zoom link" value="">
            </div>
            <input type="hidden" name="old_audPlatformid" value="0">
        

        
        <div class="form-group col-md-12">
            <label for="audplatformid">Audition Platform</label>
            <select id="audplatformid" name="new_audplatformid" class="form-control" onchange="
                      if (this.value=='CustomPlatform'){
                        document.getElementById('CustomPlatform').style.display='block';
                        document.getElementById('CustomPlatform').required=true;
                      } else {
                        document.getElementById('CustomPlatform').style.display='none';
                        document.getElementById('CustomPlatform').required=false;
                      }
                    ">
                <option value="">--</option>
                <option value="CustomPlatform">***ADD CUSTOM</option>
                
                    <option value="80">
                      Another custom test
                    </option>
                
                    <option value="81">
                      Another custom tests
                    </option>
                
                    <option value="82">
                      Another custom testsx
                    </option>
                
                    <option value="74">
                      beee
                    </option>
                
                    <option value="31">
                      Bluejean
                    </option>
                
                    <option value="83">
                      Dork
                    </option>
                
                    <option value="29">
                      Ecocast
                    </option>
                
                    <option value="73">
                      ggggg
                    </option>
                
                    <option value="77">
                      New platform
                    </option>
                
                    <option value="79">
                      teest
                    </option>
                
                    <option value="75">
                      tesssssss
                    </option>
                
                    <option value="71">
                      test
                    </option>
                
                    <option value="84">
                      testestest
                    </option>
                
                    <option value="70">
                      uuuuuu
                    </option>
                
                    <option value="69">
                      yoo
                    </option>
                
                    <option value="30">
                      Zoom
                    </option>
                
            </select>
        </div>

        
        <div class="form-group col-md-6" id="CustomPlatforms" style="display:none;">
            <label for="CustomPlatform">Custom Platform</label>
            <input class="form-control" type="text" id="CustomPlatform" name="CustomPlatform" placeholder="Enter a Custom Platform">
        </div>
    </div> <!--- end #hiddenSelfTape --->

    
    <div class="row">
      
        <div class="form-group col-md-12">
          <div class="form-check">
            <input type="checkbox" class="form-check-input" id="workwithcoach" value="1" name="new_workwithcoach" data-parsley-multiple="new_workwithcoach">
            <label class="form-check-label" for="workwithcoach">
              Worked with Coach
            </label>
          </div>
        </div>
      
    </div>

    
    <div class="row">
      <div class="form-group col-md-12">
          <button type="submit" class="btn btn-primary btn-sm waves-effect waves-light" id="btn-save-event">
              Update
          </button>
      </div>
    </div>
</form>


<script src="/app/assets/js/jquery.chained.js?ver=13.4.0.381214213207"></script>


<script>
  $(document).ready(function() {
    $(".parsley-examples").parsley();
  });
</script>


<script>
  function handleSelectChange(element) {
    const typeValue = parseInt(element.value, 10);

    // Location (type=1 => in-person)
    const hiddenLocation = document.getElementById('hiddenLocation');
    const locationInput  = document.getElementById('eventLocation');
    if (typeValue === 1) {
      hiddenLocation.style.display = 'block';
      locationInput.setAttribute('required', 'required');
      locationInput.setAttribute('data-parsley-required', 'true');
    } else {
      hiddenLocation.style.display = 'none';
      locationInput.removeAttribute('required');
      locationInput.removeAttribute('data-parsley-required');
    }

    // Self Tape (type=2 => self-tape)
    const hiddenSelfTape = document.getElementById('hiddenSelfTape');
    if (typeValue === 2) {
      hiddenSelfTape.style.display = 'block';
    } else {
      hiddenSelfTape.style.display = 'none';
    }
  }
</script>


<script>
  function filterRegions(selectedCountryId) {
    const regionSelect = document.getElementById('region_id');
    const options = regionSelect.options;

    for (let i = 0; i < options.length; i++) {
      const option = options[i];
      const countryId = option.getAttribute('data-chained');

      // Show if matching country or empty (the "--" option)
      if (countryId === selectedCountryId || option.value === "") {
        option.style.display = "block";
      } else {
        option.style.display = "none";
      }
    }

    // Reset selection if currently invalid
    if (
      regionSelect.value &&
      regionSelect.options[regionSelect.selectedIndex].getAttribute('data-chained') !== selectedCountryId
    ) {
      regionSelect.value = "";
    }
  }

  // Filter on page load if a country is already selected
  document.addEventListener("DOMContentLoaded", function () {
    const countrySelect = document.getElementById('countryid');
    if (countrySelect) {
      const selectedCountryId = countrySelect.value;
      if (selectedCountryId) {
        filterRegions(selectedCountryId);
      }
    }
  });
</script>


<script>
  document.getElementById('populateFieldsButton')?.addEventListener('click', function() {
    // Pull in data from your CF query
    var locationDetails = {
      same_eventLocation : "",
      same_audlocadd1    : "",
      same_audlocadd2    : "",
      same_audcity       : "",
      same_region_id     : "3911",
      same_countryid     : "US",
      same_audzip        : ""
    };

    // Populate the form fields
    document.getElementById('eventLocation').value = locationDetails.same_eventLocation;
    document.getElementById('audlocadd1').value   = locationDetails.same_audlocadd1;
    document.getElementById('audlocadd2').value   = locationDetails.same_audlocadd2;
    document.getElementById('audcity').value      = locationDetails.same_audcity;
    document.getElementById('region_id').value    = locationDetails.same_region_id;
    document.getElementById('countryid').value    = locationDetails.same_countryid;
    document.getElementById('audzip').value       = locationDetails.same_audzip;
  });
</script>


<script>
  document.addEventListener("DOMContentLoaded", function () {
    const isDirect = "0";
    const hideDirectBooking = document.getElementById("hidedirectbooking");
    if (isDirect === "1" && hideDirectBooking) {
      hideDirectBooking.style.display = "none";
    }
  });
</script>
</div>
                </div>
            </div>
        </div>