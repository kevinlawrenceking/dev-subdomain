<!---
  GET /include/master_link_preview.cfm?contactid=&masterCoContactId=&colocid=   (DIR-LNK-WO-7)
  Server-rendered link-preview modal body, GET-loaded into #masterPreviewContent (house pattern,
  cf app/contact-duplicates). Read-only: shows what linking will change; nothing is written until
  the user confirms (POST /ajax/master/link-confirm.cfm). Adaptive density: short form when nothing
  is displaced and the office choice is trivial; full diff otherwise. Name picker is intentionally
  absent (WO-7 ruling 1: names stay user-owned). Office picker degrades 1 / 2-5 / 6+.
--->
<cfsetting enablecfoutputonly="true">
<cfparam name="url.contactid"         default="0">
<cfparam name="url.masterCoContactId" default="0">
<cfparam name="url.colocid"           default="0">

<!--- S-1 AUTH / OWNERSHIP GATE (WO-7 Stage-2 review). This template is GET-loadable in the /include
      tier, which has NO central auth gate, and CSRF does not apply to GET - so the gate is enforced
      HERE, server-side: (a) no session.userid -> render nothing usable (aborts before any contact or
      master query runs); (b) ownership is the userid predicate on qCur below, verified in THIS
      include (not trusted from the caller); (c) a foreign or non-existent contactid returns the same
      neutral "Contact not found." as WO-6 - no enumeration oracle (not-yours is indistinguishable
      from does-not-exist). Master rows are shared directory data, not tenant data. --->
<cfif NOT structKeyExists(session, "userid")>
    <cfoutput><div class="p-3 text-danger">Your session has expired. Reload the page.</div></cfoutput><cfabort>
</cfif>
<!--- S-4: validate BEFORE any int()/val() coercion. A non-integer contactid aborts to the SAME
      neutral message as the ownership failure (no oracle; no thrown int() exception -> no
      ErrorService ticket noise). isValid precedes val() (short-circuit OR), so val() never coerces a
      malformed id; the int() usages downstream (qCur / qM) are fully guarded. --->
<cfif NOT isValid("integer", url.contactid) OR val(url.contactid) LTE 0>
    <cfoutput><div class="p-3 text-danger">Contact not found.</div></cfoutput><cfabort>
</cfif>
<cfif NOT isValid("integer", url.masterCoContactId) OR val(url.masterCoContactId) LTE 0>
    <cfoutput><div class="p-3 text-danger">Master record not found.</div></cfoutput><cfabort>
</cfif>

<!--- Current contact primaries (ownership-gated) --->
<cfquery name="qCur">
    SELECT contactFullName, contactPhone, contactPhone_src, contactEmail, contactEmail_src,
           contactCompany, contactCompany_src, master_co_contact_id, company_location_id
    FROM contactdetails
    WHERE contactid = <cfqueryparam value="#int(url.contactid)#" cfsqltype="CF_SQL_INTEGER">
      AND userid    = <cfqueryparam value="#session.userid#"     cfsqltype="CF_SQL_INTEGER">
      AND isdeleted = <cfqueryparam value="0" cfsqltype="CF_SQL_BIT">
</cfquery>
<cfif qCur.recordCount EQ 0>
    <cfoutput><div class="p-3 text-danger">Contact not found.</div></cfoutput><cfabort>
</cfif>

<!--- Master person + company --->
<cfquery name="qM">
    SELECT cc.id, cc.fullname, cc.jobtitle_type, cc.imdbid, cc.image_url, cc.coid, co.coName
    FROM co_contacts cc
    LEFT JOIN companies co ON co.coid = cc.coid
    WHERE cc.id = <cfqueryparam value="#int(url.masterCoContactId)#" cfsqltype="CF_SQL_INTEGER">
</cfquery>
<cfif qM.recordCount EQ 0>
    <cfoutput><div class="p-3 text-danger">Master record not found.</div></cfoutput><cfabort>
</cfif>

<cfset masterName = trim(qM.fullname)>
<cfset masterRole = trim(qM.jobtitle_type)>
<cfset masterCo   = trim(qM.coName)>
<cfset masterImdb = (len(trim(qM.imdbid)) AND left(trim(qM.imdbid),2) EQ "nm") ? trim(qM.imdbid) : "">
<cfset masterImg  = (len(trim(qM.image_url)) AND left(trim(qM.image_url),8) EQ "https://") ? trim(qM.image_url) : "">
<cfset isRelink   = (len(trim(qCur.master_co_contact_id)) AND val(qCur.master_co_contact_id) NEQ int(url.masterCoContactId))>

<!--- Offices (widened getLocations; ordered default-first) --->
<cfset offices = (val(qM.coid) GT 0) ? request.svc("MasterDirectoryService").getLocations(int(qM.coid)) : []>
<cfset nOffices = arrayLen(offices)>

<!--- Selected office: requested colocid if it is one of this company's offices, else the default
      (first, since getLocations orders address1-non-blank then MIN(colocid)). R-A: for 6+ offices we
      do NOT preselect - the user must choose and confirm stays disabled until they do. --->
<cfset selIdx = 0>
<cfif nOffices GT 0>
    <cfif val(url.colocid) GT 0>
        <cfloop from="1" to="#nOffices#" index="oi">
            <cfif val(offices[oi].colocid) EQ val(url.colocid)><cfset selIdx = oi><cfbreak></cfif>
        </cfloop>
    </cfif>
    <cfif selIdx EQ 0 AND nOffices LTE 5><cfset selIdx = 1></cfif>
</cfif>
<cfset selColoc = (selIdx GT 0) ? val(offices[selIdx].colocid) : 0>
<cfset selPhone = (selIdx GT 0) ? trim(offices[selIdx].phone) : "">
<cfset selEmail = (selIdx GT 0) ? trim(offices[selIdx].email) : "">

<!--- Displaced-value test (adaptive density + preservation preview): a USER-sourced primary that is
      non-blank and differs (trim + case-insensitive, no digit-normalize - L-3) from the incoming
      master value moves to Additional information. --->
<cfset dispCompany = ( qCur.contactCompany_src EQ "user" AND len(trim(qCur.contactCompany)) AND compareNoCase(trim(qCur.contactCompany), masterCo)  NEQ 0 )>
<cfset dispEmail   = ( qCur.contactEmail_src   EQ "user" AND len(trim(qCur.contactEmail))   AND compareNoCase(trim(qCur.contactEmail),   selEmail) NEQ 0 )>
<cfset dispPhone   = ( qCur.contactPhone_src   EQ "user" AND len(trim(qCur.contactPhone))   AND compareNoCase(trim(qCur.contactPhone),   selPhone) NEQ 0 )>
<cfset nDisplaced  = (dispCompany ? 1 : 0) + (dispEmail ? 1 : 0) + (dispPhone ? 1 : 0)>
<cfset needsChoice = (nOffices GT 1) OR len(masterImg)>
<cfset shortForm   = (nDisplaced EQ 0) AND (nOffices LTE 1) AND (NOT len(masterImg))>
<cfset userAvatar  = session.userContactsUrl & "/" & int(url.contactid) & "/avatar.jpg">

<cfoutput>
<style>
  ##mlp{--slate:##3D6A8C;--ink:##3f4a54;--muted:##8b959e;--faint:##b9c1c8;--border:##e3e7ea;--band:##f4f7f9;
       --gold:##a8862f;--gold-bg:##f0e6c0;--gold-border:##dccd94;--gold-ink:##7a6a2f;--amber-bg:##faf5e2;
       --amber-border:##eadfb6;--amber-ink:##9a7b2d;--ok:##4f8a5b;--link:##3d7ea6;--pick-bg:##f3f8fb;--pick-border:##9ec3da;color:var(--ink);}
  ##mlp *{box-sizing:border-box;}
  ##mlp .mlp-hdr{background:var(--slate);color:##fff;padding:13px 20px;display:flex;align-items:center;gap:10px;}
  ##mlp .mlp-hdr h2{font-size:1rem;font-weight:600;margin:0;flex:1;}
  ##mlp .mlp-match{background:var(--band);border-bottom:1px solid var(--border);padding:14px 20px;display:flex;align-items:center;gap:13px;}
  ##mlp .mlp-ava{width:44px;height:44px;border-radius:50%;object-fit:cover;background:linear-gradient(135deg,##c9d4da,##aebbc4);flex:0 0 44px;}
  ##mlp .mlp-nm{font-size:1rem;font-weight:600;}
  ##mlp .mlp-co{font-size:.82rem;color:var(--muted);}
  ##mlp .mlp-co a{color:var(--link);text-decoration:none;margin-left:8px;font-size:.75rem;}
  ##mlp .mlp-sec{padding:12px 20px 2px;}
  ##mlp .mlp-lab{font-size:.67rem;letter-spacing:.09em;text-transform:uppercase;color:var(--muted);font-weight:600;margin-bottom:8px;}
  ##mlp .mlp-picks{display:flex;gap:9px;flex-wrap:wrap;}
  ##mlp .mlp-pick{border:1.5px solid var(--border);border-radius:7px;padding:8px 12px;cursor:pointer;min-width:200px;background:##fff;}
  ##mlp .mlp-pick.sel{border-color:var(--pick-border);background:var(--pick-bg);}
  ##mlp .mlp-pick .t{font-size:.85rem;font-weight:600;}
  ##mlp .mlp-pick .s{font-size:.73rem;color:var(--muted);margin-top:3px;line-height:1.35;}
  ##mlp select.mlp-officesel{max-width:100%;}
  ##mlp .mlp-diff{padding:12px 20px 4px;}
  ##mlp .mlp-row{display:flex;align-items:flex-start;gap:12px;padding:10px 0;border-top:1px solid ##f0f2f4;}
  ##mlp .mlp-row:first-of-type{border-top:0;}
  ##mlp .mlp-dlab{width:74px;flex:0 0 74px;font-size:.73rem;color:var(--muted);margin-top:2px;}
  ##mlp .mlp-vals{flex:1;display:flex;align-items:flex-start;gap:10px;}
  ##mlp .mlp-cell{flex:1;min-width:0;}
  ##mlp .mlp-v{font-size:.88rem;line-height:1.35;word-break:break-word;}
  ##mlp .mlp-v.old{color:var(--muted);}
  ##mlp .mlp-v.none{color:var(--faint);font-style:italic;}
  ##mlp .mlp-v.new{font-weight:600;}
  ##mlp .mlp-sub{font-size:.72rem;color:var(--muted);margin-top:2px;}
  ##mlp .mlp-arrow{flex:0 0 18px;color:var(--faint);text-align:center;margin-top:2px;}
  ##mlp .mlp-tag{display:inline-block;font-size:.64rem;border-radius:3px;padding:1px 6px;margin-top:4px;border:1px solid;}
  ##mlp .mlp-tag.book{background:var(--gold-bg);border-color:var(--gold-border);color:var(--gold-ink);}
  ##mlp .mlp-tag.moves{background:##eef1f3;border-color:##d5dade;color:##6b7680;}
  ##mlp .mlp-tag.gain{background:##eef6ef;border-color:##cfe3d3;color:var(--ok);}
  ##mlp .mlp-tag.warn{background:var(--amber-bg);border-color:var(--amber-border);color:var(--amber-ink);}
  ##mlp .mlp-ftr{border-top:1px solid var(--border);background:##fafbfc;padding:13px 20px;display:flex;align-items:center;gap:14px;}
  ##mlp .mlp-sum{flex:1;font-size:.76rem;color:var(--muted);line-height:1.5;}
  ##mlp .mlp-sum b{color:var(--ink);}
  ##mlp .mlp-btn{border:0;border-radius:7px;padding:8px 16px;font-size:.85rem;font-weight:600;cursor:pointer;}
  ##mlp .mlp-btn.ghost{background:transparent;color:var(--muted);}
  ##mlp .mlp-btn.primary{background:var(--slate);color:##fff;}
  ##mlp .mlp-btn.primary:disabled{opacity:.5;cursor:not-allowed;}
  ##mlp .mlp-warnline{color:var(--amber-ink);font-size:.75rem;padding:6px 20px 0;}
</style>

<div id="mlp"
     data-contactid="#int(url.contactid)#"
     data-master="#int(url.masterCoContactId)#"
     data-coloc="#selColoc#"
     data-noffices="#nOffices#"
     data-hasimg="#(len(masterImg) ? 1 : 0)#"
     data-shortform="#(shortForm ? 1 : 0)#"
     data-selphone="#encodeForHTMLAttribute(selPhone)#"
     data-selemail="#encodeForHTMLAttribute(selEmail)#"
     data-seladdr="#encodeForHTMLAttribute(selIdx GT 0 ? trim(offices[selIdx].address1) : '')#"
     data-seladdr2="#encodeForHTMLAttribute(selIdx GT 0 ? trim(offices[selIdx].address2) : '')#"
     data-selcsz="#encodeForHTMLAttribute(selIdx GT 0 ? trim(trim(offices[selIdx].city) & ' ' & trim(offices[selIdx].state) & ' ' & trim(offices[selIdx].zip)) : '')#"
     data-curphone="#encodeForHTMLAttribute(trim(qCur.contactPhone))#"
     data-phoneuser="#((qCur.contactPhone_src EQ 'user' AND len(trim(qCur.contactPhone))) ? 1 : 0)#"
     data-curemail="#encodeForHTMLAttribute(trim(qCur.contactEmail))#"
     data-emailuser="#((qCur.contactEmail_src EQ 'user' AND len(trim(qCur.contactEmail))) ? 1 : 0)#"
     data-companymoves="#(dispCompany ? 1 : 0)#"
     data-hascompany="#(len(masterCo) ? 1 : 0)#">

  <div class="mlp-hdr">
    <h2><cfif isRelink>Move this contact in the Book<cfelse>Add this contact to the Book</cfif></h2>
  </div>

  <div class="mlp-match">
    <cfif len(masterImg)><img class="mlp-ava" src="#encodeForHTMLAttribute(masterImg)#" alt="" onerror="this.style.display='none'"><cfelse><span class="mlp-ava"></span></cfif>
    <div style="flex:1;">
      <div class="mlp-nm">#encodeForHTML(masterName)#</div>
      <div class="mlp-co">#encodeForHTML(masterCo)#<cfif len(masterRole)> &middot; #encodeForHTML(masterRole)#</cfif><cfif len(masterImdb)><a href="https://www.imdb.com/name/#encodeForHTMLAttribute(masterImdb)#/" target="_blank" rel="noopener">IMDB</a></cfif></div>
    </div>
    <div style="font-size:.75rem;"><a href="javascript:;" id="mlpNotRight" style="color:var(--link);text-decoration:none;">Not the right person?</a></div>
  </div>

  <!--- OFFICE PICKER (1 collapsed / 2-5 cards / 6+ searchable list). R-A applies to 6+. --->
  <cfif nOffices GT 1>
    <div class="mlp-sec">
      <div class="mlp-lab">Which office?</div>
      <cfif nOffices LTE 5>
        <div class="mlp-picks" id="mlpOffices">
          <cfloop from="1" to="#nOffices#" index="oi">
            <cfset o = offices[oi]>
            <div class="mlp-pick mlp-office<cfif oi EQ selIdx> sel</cfif>"
                 data-coloc="#val(o.colocid)#" data-phone="#encodeForHTMLAttribute(trim(o.phone))#" data-email="#encodeForHTMLAttribute(trim(o.email))#"
                 data-addr="#encodeForHTMLAttribute(trim(o.address1))#" data-addr2="#encodeForHTMLAttribute(trim(o.address2))#"
                 data-csz="#encodeForHTMLAttribute(trim(trim(o.city) & ' ' & trim(o.state) & ' ' & trim(o.zip)))#">
              <div class="t"><cfif len(trim(o.location))>#encodeForHTML(trim(o.location))#<cfelseif len(trim(o.city))>#encodeForHTML(trim(o.city))#<cfelse>Office #val(o.colocid)#</cfif></div>
              <div class="s">#encodeForHTML(trim(o.address1))#<cfif len(trim(o.city))><br>#encodeForHTML(trim(trim(o.city) & ', ' & trim(o.state) & ' ' & trim(o.zip)))#</cfif><cfif len(trim(o.phone))><br>#encodeForHTML(trim(o.phone))#</cfif></div>
            </div>
          </cfloop>
        </div>
      <cfelse>
        <select class="form-control form-control-sm mlp-officesel" id="mlpOfficeSel">
          <option value="">Choose an office (#nOffices# offices)...</option>
          <cfloop from="1" to="#nOffices#" index="oi">
            <cfset o = offices[oi]>
            <option value="#val(o.colocid)#"
                    data-phone="#encodeForHTMLAttribute(trim(o.phone))#" data-email="#encodeForHTMLAttribute(trim(o.email))#"
                    data-addr="#encodeForHTMLAttribute(trim(o.address1))#" data-addr2="#encodeForHTMLAttribute(trim(o.address2))#"
                    data-csz="#encodeForHTMLAttribute(trim(trim(o.city) & ' ' & trim(o.state) & ' ' & trim(o.zip)))#">#encodeForHTML(trim(trim(o.location) & ' ' & trim(o.address1) & ' ' & trim(o.city)))#</option>
          </cfloop>
        </select>
      </cfif>
    </div>
  </cfif>

  <cfif shortForm>
    <!--- SHORT FORM: nothing displaced, no office choice, no photo choice. --->
    <div class="mlp-sec" style="padding-bottom:10px;">
      <div class="mlp-lab">You'll get</div>
      <div class="mlp-v new">#encodeForHTML(masterCo)#</div>
      <div class="mlp-sub">Company, email, phone and address will be kept current by the Book. Nothing you entered is deleted.</div>
    </div>
  <cfelse>
    <!--- FULL DIFF --->
    <div class="mlp-diff" id="mlpDiff">
      <!--- COMPANY --->
      <div class="mlp-row">
        <div class="mlp-dlab">Company</div>
        <div class="mlp-vals">
          <div class="mlp-cell"><cfif len(trim(qCur.contactCompany))><div class="mlp-v old">#encodeForHTML(trim(qCur.contactCompany))#</div><cfif dispCompany><span class="mlp-tag moves">moves to Additional info</span></cfif><cfelse><div class="mlp-v none">none</div></cfif></div>
          <div class="mlp-arrow">&rarr;</div>
          <div class="mlp-cell"><cfif len(masterCo)><div class="mlp-v new">#encodeForHTML(masterCo)#</div><span class="mlp-tag book">managed by the Book</span><cfelse><div class="mlp-v none">The Book has no company on file</div><span class="mlp-tag warn">check this one</span></cfif></div>
        </div>
      </div>
      <!--- EMAIL --->
      <div class="mlp-row">
        <div class="mlp-dlab">Email</div>
        <div class="mlp-vals">
          <div class="mlp-cell"><cfif len(trim(qCur.contactEmail))><div class="mlp-v old">#encodeForHTML(trim(qCur.contactEmail))#</div><span class="mlp-tag moves" id="mlpEmailMoves" style="#dispEmail ? '' : 'display:none;'#">moves to Additional info</span><cfelse><div class="mlp-v none">none</div></cfif></div>
          <div class="mlp-arrow">&rarr;</div>
          <div class="mlp-cell" id="mlpEmailNew"></div>
        </div>
      </div>
      <!--- PHONE --->
      <div class="mlp-row">
        <div class="mlp-dlab">Phone</div>
        <div class="mlp-vals">
          <div class="mlp-cell"><cfif len(trim(qCur.contactPhone))><div class="mlp-v old">#encodeForHTML(trim(qCur.contactPhone))#</div><span class="mlp-tag moves" id="mlpPhoneMoves" style="#dispPhone ? '' : 'display:none;'#">moves to Additional info</span><cfelse><div class="mlp-v none">none</div></cfif></div>
          <div class="mlp-arrow">&rarr;</div>
          <div class="mlp-cell" id="mlpPhoneNew"></div>
        </div>
      </div>
      <!--- ADDRESS --->
      <div class="mlp-row">
        <div class="mlp-dlab">Address</div>
        <div class="mlp-vals">
          <div class="mlp-cell"><div class="mlp-v none">none</div></div>
          <div class="mlp-arrow">&rarr;</div>
          <div class="mlp-cell" id="mlpAddrNew"></div>
        </div>
      </div>
      <!--- IMDB --->
      <cfif len(masterImdb)>
      <div class="mlp-row">
        <div class="mlp-dlab">IMDB</div>
        <div class="mlp-vals">
          <div class="mlp-cell"><div class="mlp-v none">none</div></div>
          <div class="mlp-arrow">&rarr;</div>
          <div class="mlp-cell"><div class="mlp-v new">#encodeForHTML(masterImdb)#</div><span class="mlp-tag gain">new</span></div>
        </div>
      </div>
      </cfif>

      <!--- PHOTO PICKER (name picker intentionally absent - WO-7 ruling 1). --->
      <cfif len(masterImg)>
      <div class="mlp-sec" style="padding-left:0;padding-right:0;">
        <div class="mlp-lab">Photo &mdash; keep yours, or use the Book's?</div>
        <div class="mlp-picks" id="mlpPhoto">
          <div class="mlp-pick mlp-photo sel" data-photo="user"><div class="t">Your upload</div><div class="s">what you have now</div></div>
          <div class="mlp-pick mlp-photo" data-photo="master"><div class="t">From the Book</div><div class="s">the Book's headshot</div></div>
        </div>
      </div>
      </cfif>
    </div>
  </cfif>

  <div class="mlp-warnline" id="mlpWarn" style="display:none;"></div>

  <div class="mlp-ftr">
    <div class="mlp-sum" id="mlpSum"></div>
    <button type="button" class="mlp-btn ghost" id="mlpCancel">Cancel</button>
    <button type="button" class="mlp-btn primary" id="mlpConfirm"><cfif isRelink>Move in the Book<cfelse>Add to the Book</cfif></button>
  </div>
</div>

</cfoutput>
<cfsetting enablecfoutputonly="false">

<!--- Script is OUTSIDE cfoutput (literal # in jQuery selectors must not be CF-interpolated). All
      server values are read from #mlp data-* attributes; nothing is CF-interpolated in here. --->
<script>
(function(){
  var root = document.getElementById('mlp'); if(!root) return;
  var $r = $(root);
  var st = {
    contactid: $r.data('contactid'), master: $r.data('master'),
    coloc: parseInt($r.data('coloc'),10) || 0,
    noffices: parseInt($r.data('noffices'),10) || 0,
    photo: 'user',
    curphone: String($r.data('curphone') == null ? '' : $r.data('curphone')),
    curemail: String($r.data('curemail') == null ? '' : $r.data('curemail')),
    phoneUser: parseInt($r.data('phoneuser'),10) === 1,
    emailUser: parseInt($r.data('emailuser'),10) === 1,
    companyMoves: parseInt($r.data('companymoves'),10) === 1,
    hasCompany: parseInt($r.data('hascompany'),10) === 1
  };
  function esc(s){ return $('<div>').text(s==null?'':s).html(); }
  function ci(a,b){ return String(a==null?'':a).trim().toLowerCase() === String(b==null?'':b).trim().toLowerCase(); }
  function renderMasterCell(id, val, kind){
    var el = $('#'+id); if(!el.length) return;
    if(val && String(val).length){ el.html('<div class="mlp-v new">'+esc(val)+'</div><span class="mlp-tag book">managed by the Book</span>'); }
    else { el.html('<div class="mlp-v none">This office has no '+kind+' on file</div><div class="mlp-sub">The field stays blank while linked; your value is kept in Additional information.</div><span class="mlp-tag warn">check this one</span>'); }
  }
  function applyOffice(d){
    st.coloc = parseInt(d.coloc,10) || 0;
    var email = d.email == null ? '' : String(d.email);
    var phone = d.phone == null ? '' : String(d.phone);
    renderMasterCell('mlpEmailNew', email, 'email');
    renderMasterCell('mlpPhoneNew', phone, 'phone');
    var addr = $('#mlpAddrNew'), hasAddr = false;
    if(addr.length){
      var lines = [];
      if(d.addr) lines.push(esc(d.addr));
      if(d.addr2) lines.push(esc(d.addr2));
      if(d.csz && String(d.csz).replace(/\s/g,'').length) lines.push(esc(d.csz));
      if(lines.length){ addr.html('<div class="mlp-v new">'+lines.join('<br>')+'</div><span class="mlp-tag gain">new</span>'); hasAddr = true; }
      else { addr.html('<div class="mlp-v none">This office has no address on file</div><span class="mlp-tag warn">check this one</span>'); }
    }
    // S-3: recompute the displacement disclosure for the newly chosen office. Email/phone are
    // office-dependent (company is not). A field moves to Additional info only when the user's own
    // value is present AND differs (trim + case-insensitive) from the new office value. Server-side
    // preservation remains authoritative at confirm; this only keeps the disclosure honest.
    var dispEmail = st.emailUser && !ci(st.curemail, email);
    var dispPhone = st.phoneUser && !ci(st.curphone, phone);
    $('#mlpEmailMoves').toggle(dispEmail);
    $('#mlpPhoneMoves').toggle(dispPhone);
    var moved = (st.companyMoves?1:0) + (dispEmail?1:0) + (dispPhone?1:0);
    var kept  = (st.hasCompany?1:0) + (email.length?1:0) + (phone.length?1:0) + (hasAddr?1:0);
    updateConfirm(moved, kept);
  }
  function updateConfirm(moved, kept){
    var must = (st.noffices >= 6);          // R-A: 6+ requires an explicit office choice
    var ready = !must || st.coloc > 0;
    $('#mlpConfirm').prop('disabled', !ready);
    var warn = $('#mlpWarn');
    if(must && st.coloc <= 0){ warn.text('Choose an office to continue.').show(); } else { warn.hide(); }
    if(moved == null){ moved = (st.companyMoves?1:0); }
    if(kept == null){ kept = (st.hasCompany?1:0); }
    $('#mlpSum').html('<b>'+kept+' field'+(kept===1?'':'s')+'</b> kept current by the Book &middot; <b>'+moved+' of your value'+(moved===1?'':'s')+'</b> move to Additional information &middot; nothing is deleted. You can unlink at any time.');
  }
  $r.on('click', '.mlp-office', function(){
    $('.mlp-office', $r).removeClass('sel'); $(this).addClass('sel'); applyOffice($(this).data());
  });
  $r.on('change', '#mlpOfficeSel', function(){
    var $o = $(this.options[this.selectedIndex]);
    applyOffice({ coloc: this.value, phone: $o.data('phone'), email: $o.data('email'), addr: $o.data('addr'), addr2: $o.data('addr2'), csz: $o.data('csz') });
  });
  $r.on('click', '.mlp-photo', function(){
    $('.mlp-photo', $r).removeClass('sel'); $(this).addClass('sel'); st.photo = $(this).data('photo');
  });
  $('#mlpCancel', $r).on('click', function(){ $('#masterPreviewModal').modal('hide'); });
  $('#mlpNotRight', $r).on('click', function(){ $('#masterPreviewModal').modal('hide'); });
  $('#mlpConfirm', $r).on('click', function(){
    var btn = $(this), orig = btn.text(); btn.prop('disabled', true).text('Saving...');
    $.ajax({
      url: '/ajax/master/link-confirm.cfm', method: 'POST', dataType: 'json',
      data: { contactid: st.contactid, masterCoContactId: st.master, colocid: st.coloc || 0, photoChoice: st.photo },
      success: function(d){
        if(d && d.success){ window.location.reload(); }
        else { $('#mlpWarn').text((d && d.message) ? d.message : 'Could not link.').show(); btn.prop('disabled', false).text(orig); }
      },
      error: function(){ $('#mlpWarn').text('Could not link. Try again.').show(); btn.prop('disabled', false).text(orig); }
    });
  });
  if(parseInt($r.data('shortform'),10) === 1){ updateConfirm(); }
  else { applyOffice({ coloc: st.coloc, phone: $r.data('selphone'), email: $r.data('selemail'), addr: $r.data('seladdr'), addr2: $r.data('seladdr2'), csz: $r.data('selcsz') }); }
})();
</script>
