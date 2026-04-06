<!--- /include/setup.cfm
     User-facing setup welcome page. Rendered inside core_nomenu.cfm card.
     Available vars: userfirstname, userlastname, userEmail, userid --->

<cfoutput>
<div class="text-center mb-4">
    <div style="width:80px; height:80px; border-radius:50%; background:##406E8E; display:inline-flex; align-items:center; justify-content:center; margin-bottom:16px;">
        <svg width="40" height="40" viewBox="0 0 24 24" fill="none" stroke="##ffffff" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
            <path d="M20 6L9 17l-5-5"/>
        </svg>
    </div>
    <h3 style="color:##1B3A4B; font-weight:600; margin-bottom:8px;">Welcome to The Actor's Office</h3>
    <p style="color:##6B7280; font-size:15px;">Your account is ready. Let's get you started.</p>
</div>

<div style="background:##F9FAFB; border:1px solid ##E5E7EB; border-radius:8px; padding:20px; margin-bottom:24px;">
    <table style="width:100%; font-size:14px; color:##374151;">
        <tr>
            <td style="padding:6px 0; font-weight:600; width:100px;">Name:</td>
            <td style="padding:6px 0;">#encodeForHtml(userfirstname)# #encodeForHtml(userlastname)#</td>
        </tr>
        <tr>
            <td style="padding:6px 0; font-weight:600;">Email:</td>
            <td style="padding:6px 0;">#encodeForHtml(userEmail)#</td>
        </tr>
    </table>
</div>

<div style="background:##EFF6FF; border:1px solid ##BFDBFE; border-radius:8px; padding:16px 20px; margin-bottom:24px;">
    <p style="color:##1E40AF; font-size:14px; margin:0 0 8px 0; font-weight:600;">What happens next:</p>
    <ul style="color:##374151; font-size:14px; margin:0; padding-left:20px; line-height:1.8;">
        <li>Your dashboard, contacts, and calendar will be ready to use</li>
        <li>You can update your profile and preferences anytime from Settings</li>
        <li>Add contacts and start building your relationships</li>
    </ul>
</div>

<div class="text-center">
    <button type="button" id="btnCompleteSetup" onclick="completeSetup()"
            style="display:inline-block; padding:12px 40px; font-size:15px; font-weight:600;
                   color:##fff; background:linear-gradient(135deg, ##406E8E 0%, ##1B3A4B 100%);
                   border:none; border-radius:8px; cursor:pointer; letter-spacing:0.3px;
                   transition: transform 0.15s ease, box-shadow 0.2s ease;">
        Go to My Dashboard
    </button>
    <p id="setupError" style="color:##DC2626; font-size:13px; margin-top:12px; display:none;"></p>
</div>

<script>
function completeSetup() {
    var btn = document.getElementById('btnCompleteSetup');
    var errEl = document.getElementById('setupError');
    btn.disabled = true;
    btn.textContent = 'Setting up...';
    errEl.style.display = 'none';

    var xhr = new XMLHttpRequest();
    xhr.open('POST', '/app/setup/ajax/complete.cfm', true);
    xhr.setRequestHeader('Content-Type', 'application/json');

    var csrfMeta = document.querySelector('meta[name="csrf-token"]');
    if (csrfMeta) {
        xhr.setRequestHeader('X-CSRF-Token', csrfMeta.getAttribute('content'));
    }

    xhr.onreadystatechange = function() {
        if (xhr.readyState === 4) {
            if (xhr.status === 200) {
                try {
                    var resp = JSON.parse(xhr.responseText);
                    if (resp.success) {
                        window.location.href = resp.redirect || '/app/dashboard';
                    } else {
                        errEl.textContent = resp.message || 'Something went wrong.';
                        errEl.style.display = 'block';
                        btn.disabled = false;
                        btn.textContent = 'Go to My Dashboard';
                    }
                } catch(e) {
                    window.location.href = '/app/dashboard';
                }
            } else {
                errEl.textContent = 'Unable to complete setup. Please try again.';
                errEl.style.display = 'block';
                btn.disabled = false;
                btn.textContent = 'Go to My Dashboard';
            }
        }
    };
    xhr.send('{}');
}
</script>
</cfoutput>
