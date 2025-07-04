

$uploadCrop = $('#upload-input').croppie({
    enableExif: true,
    url: <Cfoutput>'#image_url#</cfoutput>?ver=<Cfoutput>#rand()#</cfoutput>',
    viewport: {
        width: <cfoutput>#picsize#</cfoutput>,
        height: <cfoutput>#picsize#</cfoutput>,
        type: 'circle'
    },
    boundary: {
        width: <cfoutput>#picsize#</cfoutput>,
        height: <cfoutput>#picsize#</cfoutput>
    }
});

$('#upload').on('change', function () { 
	var reader = new FileReader();
    reader.onload = function (e) {
    	$uploadCrop.croppie('bind', {
    		url: e.target.result
    	}).then(function(){
    		console.log('jQuery bind complete');
    	});
    	
    }
    reader.readAsDataURL(this.files[0]);
});

$('.upload-result').on('click', function (ev) {
	$uploadCrop.croppie('result', {
		type: 'canvas',
		size: 'viewport'
	}).then(function (resp) {
		$.ajax({
			url: "/include/store_img_ajax.php",
			type: "POST",
			data: {"image":resp},
			success: function (data) {
				html = '<img style="margin: 20px;" src="' + resp + '" /><BR><center><A HREF="<Cfoutput>#cookie.return_url#</cfoutput>"><button type="button" class="btn btn-xs btn-primary waves-effect mb-2 waves-light" style="background-color: #406e8e; border: #406e8e">Continue</button></a></center>';
				$("#upload-input").html(html);
			}
		});
	});
});
