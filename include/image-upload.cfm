<!--- 
    PURPOSE: Modern avatar upload and cropping interface
    AUTHOR: Kevin King
    DATE: 2025-07-26
    FEATURES: Drag & drop, file validation, responsive design, modern UI
--->

<cfinclude template="/include/qry/FindRefPage_136_1.cfm"/>
<cfinclude template="/include/qry/FindRefcontacts_135_2.cfm"/>

<cfoutput>
  <cfset subtitle="#userFirstName# #userLastName#"/>
  <cfset image_url="#session.userAvatarUrl#"/>
  <cfset cookie.uploadDir="#session.userAvatarPath#"/>
  <cfset cookie.return_url="/app/myaccount/"/>
</cfoutput>

<!--- Set picture size based on reference page ID --->
<cfif #ref_pgid# is "9">
<cfset picsize=200/>
<cfset inputsize=200/>
<cfelse>
<cfset picsize=200/>
<cfset inputsize=300/>
</cfif>

<!-- Modern CSS and JS Dependencies -->
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/croppie/2.6.5/croppie.min.css">
<link rel="stylesheet" href="/app/assets/css/croppie.css">

<!-- Load Croppie JS with simple fallback -->
<script src="https://cdnjs.cloudflare.com/ajax/libs/croppie/2.6.5/croppie.min.js"></script>

<!-- Main Upload Script -->
<script>
// Simple approach - just check periodically if everything is ready
function checkAndInitialize() {
    if (typeof $ !== 'undefined' && document.readyState === 'complete') {
        // Wait a bit more for Croppie to be available
        setTimeout(function() {
            initializeUploadApp();
        }, 500);
        return true;
    }
    return false;
}

// Try to initialize when DOM is ready
$(document).ready(function() {
    if (!checkAndInitialize()) {
        // If not ready, keep trying
        const checkInterval = setInterval(function() {
            if (checkAndInitialize()) {
                clearInterval(checkInterval);
            }
        }, 200);
        
        // Give up after 10 seconds
        setTimeout(function() {
            clearInterval(checkInterval);
            if (!window.uploadInterfaceInitialized) {
                console.warn('Timeout reached, initializing in basic mode');
                window.croppieUnavailable = true;
                initializeUploadApp();
            }
        }, 10000);
    }
});

// Also try when window loads
$(window).on('load', function() {
    setTimeout(function() {
        if (!window.uploadInterfaceInitialized) {
            initializeUploadApp();
        }
    }, 1000);
});
</script>

<!-- Custom Styles for Modern Look -->
<style>
    .avatar-upload-container {
        max-width: 900px;
        margin: 2rem auto;
        padding: 3rem;
        background: linear-gradient(135deg, #fff 0%, #f8f9fa 100%);
        border-radius: 20px;
        box-shadow: 0 10px 40px rgba(0,0,0,0.12);
        border: 1px solid rgba(0,0,0,0.05);
        position: relative;
        overflow: hidden;
    }
    
    .avatar-upload-container::before {
        content: '';
        position: absolute;
        top: 0;
        left: 0;
        right: 0;
        height: 4px;
        background: linear-gradient(90deg, #007bff, #6f42c1, #e83e8c);
    }
    
    .upload-card {
        border: none;
        border-radius: 20px;
        box-shadow: 0 8px 30px rgba(0, 0, 0, 0.1);
        background: linear-gradient(135deg, #ffffff 0%, #f8f9fa 100%);
        overflow: hidden;
        transition: all 0.3s ease;
        border: 2px solid rgba(0,123,255,0.1);
    }
    
    .upload-card:hover {
        transform: translateY(-2px);
        box-shadow: 0 12px 40px rgba(0, 0, 0, 0.15);
        border-color: rgba(0,123,255,0.2);
    }
    
    .upload-card:hover {
        box-shadow: 0 10px 15px -3px rgba(0, 0, 0, 0.1), 0 4px 6px -2px rgba(0, 0, 0, 0.05);
    }
    
    .upload-zone {
        border: 3px dashed rgba(0,123,255,0.3);
        border-radius: 20px;
        background: linear-gradient(135deg, #f8fafc 0%, #e2e8f0 100%);
        transition: all 0.4s cubic-bezier(0.4, 0, 0.2, 1);
        cursor: pointer;
        position: relative;
        overflow: hidden;
        min-height: 200px;
        display: flex;
        align-items: center;
        justify-content: center;
    }
    
    .upload-zone::before {
        content: '';
        position: absolute;
        top: 0;
        left: 0;
        right: 0;
        bottom: 0;
        background: linear-gradient(45deg, transparent 30%, rgba(0,123,255,0.05) 50%, transparent 70%);
        opacity: 0;
        transition: opacity 0.3s ease;
    }
    
    .upload-zone:hover::before {
        opacity: 1;
    }
    
    .upload-zone:hover, .upload-zone.dragover {
        border-color: #007bff;
        background: linear-gradient(135deg, #e3f2fd 0%, #bbdefb 100%);
        transform: scale(1.02);
        box-shadow: 0 8px 25px rgba(0,123,255,0.2);
    }
    
    .upload-zone.has-file {
        border-color: #28a745;
        background: linear-gradient(135deg, #e8f5e8 0%, #d4edda 100%);
        transform: scale(1.02);
        box-shadow: 0 8px 25px rgba(40,167,69,0.2);
    }
    
    .upload-icon {
        font-size: 4rem;
        color: rgba(0,123,255,0.6);
        transition: all 0.4s cubic-bezier(0.4, 0, 0.2, 1);
        text-shadow: 0 2px 4px rgba(0,0,0,0.1);
    }
    
    .upload-zone:hover .upload-icon {
        color: #007bff;
        transform: scale(1.1) translateY(-5px);
        text-shadow: 0 4px 8px rgba(0,123,255,0.3);
    }
    
    .current-avatar {
        width: 100px;
        height: 100px;
        border-radius: 50%;
        border: 4px solid rgba(0,123,255,0.2);
        box-shadow: 0 8px 20px rgba(0,0,0,0.15);
        transition: all 0.3s ease;
        object-fit: cover;
    }
    
    .current-avatar:hover {
        transform: scale(1.05);
        border-color: #007bff;
        box-shadow: 0 12px 30px rgba(0,123,255,0.3);
    }
    
    .crop-container {
        background: linear-gradient(135deg, #ffffff 0%, #f8f9fa 100%);
        border-radius: 20px;
        padding: 2.5rem;
        margin: 2rem 0;
        border: 2px solid rgba(0,123,255,0.1);
        box-shadow: 0 8px 30px rgba(0,0,0,0.1);
        transition: all 0.3s ease;
    }
    
    .crop-container:hover {
        transform: translateY(-2px);
        box-shadow: 0 12px 40px rgba(0,0,0,0.15);
    }
    
    .step-indicator {
        display: flex;
        align-items: center;
        justify-content: center;
        margin-bottom: 3rem;
        padding: 1.5rem;
        background: linear-gradient(135deg, #f8f9fa 0%, #e9ecef 100%);
        border-radius: 15px;
        border: 1px solid rgba(0,0,0,0.05);
    }
    
    .step {
        display: flex;
        align-items: center;
        color: #6c757d;
        font-weight: 600;
        font-size: 1.1rem;
        transition: all 0.3s ease;
        position: relative;
    }
    
    .step.active {
        color: #007bff;
        transform: scale(1.05);
    }
    
    .step.completed {
        color: #28a745;
    }
    
    .step-number {
        width: 40px;
        height: 40px;
        border-radius: 50%;
        background: linear-gradient(135deg, #e9ecef 0%, #dee2e6 100%);
        color: #495057;
        display: flex;
        align-items: center;
        justify-content-center;
        font-weight: 700;
        margin-right: 1rem;
        font-size: 1rem;
        border: 2px solid transparent;
        transition: all 0.3s ease;
        box-shadow: 0 2px 8px rgba(0,0,0,0.1);
    }
    
    .step.active .step-number {
        background: linear-gradient(135deg, #007bff 0%, #0056b3 100%);
        color: white;
        border-color: rgba(0,123,255,0.3);
        transform: scale(1.1);
        box-shadow: 0 4px 15px rgba(0,123,255,0.4);
    }
    
    .step.completed .step-number {
        background: linear-gradient(135deg, #28a745 0%, #1e7e34 100%);
        color: white;
        border-color: rgba(40,167,69,0.3);
        box-shadow: 0 4px 15px rgba(40,167,69,0.4);
    }
    
    .step-divider {
        flex: 1;
        height: 3px;
        background: linear-gradient(90deg, #dee2e6 0%, #adb5bd 50%, #dee2e6 100%);
        margin: 0 1.5rem;
        border-radius: 2px;
        position: relative;
        overflow: hidden;
    }
    
    .step-divider::before {
        content: '';
        position: absolute;
        top: 0;
        left: -100%;
        width: 100%;
        height: 100%;
        background: linear-gradient(90deg, transparent 0%, rgba(0,123,255,0.6) 50%, transparent 100%);
        transition: left 0.5s ease;
    }
    
    .step.completed + .step-divider::before {
        left: 0;
    }
    
    .btn-modern {
        border-radius: 12px;
        padding: 1rem 2rem;
        font-weight: 700;
        font-size: 1.1rem;
        transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
        border: none;
        position: relative;
        overflow: hidden;
        text-transform: uppercase;
        letter-spacing: 0.5px;
    }
    
    .btn-modern::before {
        content: '';
        position: absolute;
        top: 0;
        left: -100%;
        width: 100%;
        height: 100%;
        background: linear-gradient(90deg, transparent, rgba(255,255,255,0.2), transparent);
        transition: left 0.5s ease;
    }
    
    .btn-modern:hover::before {
        left: 100%;
    }
    
    .btn-primary-modern {
        background: linear-gradient(135deg, #007bff 0%, #0056b3 100%);
        color: white;
        box-shadow: 0 4px 15px rgba(0,123,255,0.3);
    }
    
    .btn-primary-modern:hover {
        transform: translateY(-3px);
        box-shadow: 0 15px 25px rgba(0,123,255,0.4);
        background: linear-gradient(135deg, #0056b3 0%, #004085 100%);
    }
    
    .file-info {
        background: linear-gradient(135deg, #f8f9fa 0%, #e9ecef 100%);
        border-radius: 15px;
        padding: 1.5rem;
        margin: 1.5rem 0;
        border: 2px solid rgba(0,123,255,0.1);
        box-shadow: 0 4px 15px rgba(0,0,0,0.1);
        transition: all 0.3s ease;
    }
    
    .file-info:hover {
        transform: translateY(-2px);
        box-shadow: 0 8px 25px rgba(0,0,0,0.15);
    }
    
    .success-animation {
        animation: successPulse 0.8s cubic-bezier(0.4, 0, 0.2, 1);
    }
    
    @keyframes successPulse {
        0% { 
            transform: scale(0.9) rotate(-5deg); 
            opacity: 0; 
            filter: blur(2px);
        }
        30% { 
            transform: scale(1.05) rotate(2deg); 
            filter: blur(0px);
        }
        60% { 
            transform: scale(0.98) rotate(-1deg); 
        }
        100% { 
            transform: scale(1) rotate(0deg); 
            opacity: 1; 
        }
    }
    
    @media (max-width: 768px) {
        .avatar-upload-container {
            margin: 1rem;
            padding: 2rem;
        }
        
        .step-indicator {
            flex-direction: column;
            gap: 1rem;
            padding: 1rem;
        }
        
        .step-divider {
            width: 3px;
            height: 25px;
            margin: 0;
        }
        
        .upload-zone {
            min-height: 150px;
        }
        
        .btn-modern {
            padding: 0.8rem 1.5rem;
            font-size: 1rem;
        }
    }
    
    /* Additional Modern Utilities */
    .fade-in {
        animation: fadeIn 0.5s ease-in;
    }
    
    @keyframes fadeIn {
        from { opacity: 0; transform: translateY(20px); }
        to { opacity: 1; transform: translateY(0); }
    }
    
    .loading-spinner {
        width: 24px;
        height: 24px;
        border: 2px solid rgba(255,255,255,0.3);
        border-radius: 50%;
        border-top-color: #fff;
        animation: spin 1s ease-in-out infinite;
    }
    
    @keyframes spin {
        to { transform: rotate(360deg); }
    }
    
    .text-gradient {
        background: linear-gradient(135deg, #007bff, #6f42c1);
        -webkit-background-clip: text;
        -webkit-text-fill-color: transparent;
        background-clip: text;
    }
</style>

<!-- Modern Avatar Upload Interface -->
<div class="avatar-upload-container">
    <!-- Header Section -->
    <div class="text-center mb-5 fade-in">
        <h2 class="text-gradient mb-3 fw-bold" style="font-size: 2.5rem;">
            <i class="fe-user me-3"></i>Update Avatar
        </h2>
        <p class="text-muted fs-5 mb-0">
            <cfoutput>Upload a new profile picture for <strong>#subtitle#</strong></cfoutput>
        </p>
        <div class="mt-3">
            <small class="text-muted">
                <i class="fe-info me-1"></i>
                Supported formats: JPG, PNG, GIF (Max 5MB)
            </small>
        </div>
    </div>

    <!-- Step Indicator -->
    <div class="step-indicator">
        <div class="step active" id="step1">
            <div class="step-number">1</div>
            <span>Select Image</span>
        </div>
        <div class="step-divider"></div>
        <div class="step" id="step2">
            <div class="step-number">2</div>
            <span>Crop & Adjust</span>
        </div>
        <div class="step-divider"></div>
        <div class="step" id="step3">
            <div class="step-number">3</div>
            <span>Save Changes</span>
        </div>
    </div>

    <!-- Main Upload Card -->
    <div class="card upload-card" id="upload-section">
        <div class="card-body p-4">
            <!-- Current Avatar Display -->
            <div class="text-center mb-4">
                <h5 class="card-title mb-3">Current Avatar</h5>
                <cfoutput>
                    <img src="#image_url#?ver=#rand()#" alt="Current Avatar" class="current-avatar" id="current-avatar-img">
                </cfoutput>
            </div>

            <!-- Upload Zone -->
            <div class="upload-zone text-center p-5" id="upload-zone">
                <div class="upload-content">
                    <i class="fe-upload upload-icon"></i>
                    <h4 class="mt-3 mb-2">Choose a New Image</h4>
                    <p class="text-muted mb-3">
                        Drag and drop an image here, or click to browse
                    </p>
                    <div class="mb-3">
                        <span class="badge bg-light text-dark me-2">JPG</span>
                        <span class="badge bg-light text-dark me-2">PNG</span>
                        <span class="badge bg-light text-dark">GIF</span>
                    </div>
                    <p class="small text-muted">
                        Maximum file size: 5MB<br>
                        Recommended: Square images work best
                    </p>
                </div>
                <input type="file" id="upload" accept="image/*" style="display: none;" />
            </div>

            <!-- File Info Display -->
            <div class="file-info" id="file-info" style="display: none;">
                <div class="d-flex align-items-center">
                    <i class="fe-image text-success me-3"></i>
                    <div class="flex-grow-1">
                        <div class="fw-semibold" id="file-name"></div>
                        <div class="small text-muted" id="file-details"></div>
                    </div>
                    <button type="button" class="btn btn-sm btn-outline-secondary" id="change-file">
                        Change
                    </button>
                </div>
            </div>
        </div>
    </div>

    <!-- Cropping Section -->
    <div class="card upload-card mt-4" id="crop-section" style="display: none;">
        <div class="card-body p-4">
            <h5 class="card-title text-center mb-4">
                <i class="fe-crop me-2"></i>Crop Your Image
            </h5>
            <div class="text-center">
                <div class="crop-container">
                    <div id="upload-input" style="width:<cfoutput>#inputsize#</cfoutput>px; height: <cfoutput>#inputsize#</cfoutput>px; margin: 0 auto;"></div>
                </div>
                <div class="mt-4">
                    <button type="button" class="btn btn-outline-secondary btn-modern me-3" id="back-button">
                        <i class="fe-arrow-left me-2"></i>Back
                    </button>
                    <button type="button" class="btn btn-primary-modern" id="crop-save-button">
                        <i class="fe-check me-2"></i>Save Avatar
                    </button>
                </div>
            </div>
        </div>
    </div>

    <!-- Success Section -->
    <div class="card upload-card mt-4 success-animation" id="success-section" style="display: none;">
        <div class="card-body p-4 text-center">
            <div class="mb-4">
                <i class="fe-check-circle text-success" style="font-size: 4rem;"></i>
            </div>
            <h3 class="text-success mb-3">Avatar Updated Successfully!</h3>
            <p class="text-muted mb-4">Your profile picture has been updated and is now visible across the platform.</p>
            <div class="mb-4">
                <img id="final-avatar" src="" alt="New Avatar" class="current-avatar">
            </div>
            <cfoutput>
                <a href="#cookie.return_url#" class="btn btn-primary-modern">
                    <i class="fe-arrow-right me-2"></i>Continue to Profile
                </a>
            </cfoutput>
        </div>
    </div>
</div>

<input type="hidden" name="picturebase" id="picturebase" value="" />

<!-- Enhanced JavaScript with Modern Features -->
<script>
// Main initialization function
function initializeUploadApp() {
    // Prevent multiple initializations
    if (window.uploadInterfaceInitialized) return;
    window.uploadInterfaceInitialized = true;
    
    console.log('Initializing upload interface...');
    
    // Check if Croppie is available
    const useCroppie = typeof $ !== 'undefined' && 
                      typeof $.fn !== 'undefined' && 
                      typeof $.fn.croppie !== 'undefined' && 
                      !window.croppieUnavailable;
    
    console.log('Croppie available:', useCroppie);
    
    if (!useCroppie) {
        console.warn('Using basic upload mode');
        $('#crop-section h5').html('<i class="fe-image me-2"></i>Preview Your Image');
    }
    
    // Modern file validation
    const maxFileSize = 5 * 1024 * 1024; // 5MB
    const allowedTypes = ['image/jpeg', 'image/jpg', 'image/png', 'image/gif'];
    
    let $uploadCrop;
    let currentStep = 1;
    let selectedImageData = null;
    
    // Initialize croppie with error handling
    function initializeCroppie() {
        if (!useCroppie) {
            // Basic preview mode
            $('#upload-input').html(`
                <div style="width: <cfoutput>#picsize#</cfoutput>px; height: <cfoutput>#picsize#</cfoutput>px; 
                     border: 2px dashed ##ddd; border-radius: 50%; margin: 0 auto; 
                     display: flex; align-items: center; justify-content: center; 
                     background-size: cover; background-position: center; 
                     background-image: url('<cfoutput>#image_url#</cfoutput>?ver=<cfoutput>#rand()#</cfoutput>');">
                    <span style="color: ##999; text-align: center;">Current Avatar</span>
                </div>
            `);
            return;
        }
        
        try {
            if ($uploadCrop) {
                $uploadCrop.croppie('destroy');
            }
            
            $uploadCrop = $('#upload-input').croppie({
                enableExif: true,
                url: '<cfoutput>#image_url#</cfoutput>?ver=<cfoutput>#rand()#</cfoutput>',
                viewport: {
                    width: <cfoutput>#picsize#</cfoutput>,
                    height: <cfoutput>#picsize#</cfoutput>,
                    type: 'circle'
                },
                boundary: {
                    width: <cfoutput>#picsize#</cfoutput>,
                    height: <cfoutput>#picsize#</cfoutput>
                },
                showZoomer: true,
                enableOrientation: true
            });
        } catch (error) {
            console.error('Error initializing Croppie:', error);
            showErrorMessage('Failed to initialize image cropper. Using basic preview mode.');
            window.croppieUnavailable = true;
            // Retry in basic mode by updating the flag and calling again
            useCroppie = false;
            initializeCroppie();
        }
    }
    
    // Step management
    function updateStep(step) {
        currentStep = step;
        $('.step').removeClass('active completed');
        
        for (let i = 1; i <= 3; i++) {
            if (i < step) {
                $(`##step${i}`).addClass('completed');
            } else if (i === step) {
                $(`##step${i}`).addClass('active');
            }
        }
    }
    
    // File validation
    function validateFile(file) {
        const errors = [];
        
        if (!allowedTypes.includes(file.type)) {
            errors.push('Please select a valid image file (JPG, PNG, or GIF)');
        }
        
        if (file.size > maxFileSize) {
            errors.push('File size must be less than 5MB');
        }
        
        return errors;
    }
    
    // Show file information
    function showFileInfo(file) {
        const sizeInMB = (file.size / (1024 * 1024)).toFixed(2);
        $('#file-name').text(file.name);
        $('#file-details').text(`${sizeInMB}MB • ${file.type.split('/')[1].toUpperCase()}`);
        $('#file-info').show();
        $('#upload-zone').addClass('has-file');
    }
    
    // Handle file selection
    function handleFileSelect(file) {
        const errors = validateFile(file);
        
        if (errors.length > 0) {
            showErrorMessage(errors.join('<br>'));
            return;
        }
        
        showFileInfo(file);
        
        const reader = new FileReader();
        reader.onload = function (e) {
            selectedImageData = e.target.result;
            
            // Show cropping section
            $('#crop-section').show();
            updateStep(2);
            
            // Scroll to crop section
            $('html, body').animate({
                scrollTop: $('#crop-section').offset().top - 20
            }, 500);
            
            if (useCroppie) {
                // Initialize croppie with new image
                if ($uploadCrop) {
                    try {
                        $uploadCrop.croppie('destroy');
                    } catch (error) {
                        console.warn('Error destroying previous croppie instance:', error);
                    }
                }
                
                try {
                    initializeCroppie();
                    
                    $uploadCrop.croppie('bind', {
                        url: e.target.result
                    }).then(function () {
                        console.log('Image loaded for cropping');
                    }).catch(function(error) {
                        console.error('Error binding image to croppie:', error);
                        showErrorMessage('Failed to load image for cropping. Please try a different image.');
                    });
                } catch (error) {
                    console.error('Error initializing croppie for new image:', error);
                    showErrorMessage('Failed to prepare image for cropping. Please try again.');
                }
            } else {
                // Basic preview mode
                $('#upload-input').html(`
                    <div style="width: <cfoutput>#picsize#</cfoutput>px; height: <cfoutput>#picsize#</cfoutput>px; 
                         border: 2px solid ##007bff; border-radius: 50%; margin: 0 auto; 
                         background-size: cover; background-position: center; 
                         background-image: url('${e.target.result}');">
                    </div>
                    <p class="mt-3 text-muted">Preview of your new avatar</p>
                `);
            }
        };
        reader.readAsDataURL(file);
    }
    
    // Show error message
    function showErrorMessage(message) {
        // Create toast notification or simple alert if Bootstrap toast isn't available
        if (typeof bootstrap !== 'undefined' && bootstrap.Toast) {
            const toast = `
                <div class="toast align-items-center text-bg-danger border-0 position-fixed" 
                     style="top: 20px; right: 20px; z-index: 9999;" role="alert">
                    <div class="d-flex">
                        <div class="toast-body">
                            <i class="fe-alert-triangle me-2"></i>${message}
                        </div>
                        <button type="button" class="btn-close btn-close-white me-2 m-auto" 
                                data-bs-dismiss="toast"></button>
                    </div>
                </div>
            `;
            
            $('body').append(toast);
            $('.toast').toast('show');
            
            // Remove after 5 seconds
            setTimeout(() => $('.toast').remove(), 5000);
        } else {
            // Fallback to alert
            alert(message);
        }
    }
    
    // Drag and drop functionality
    $('#upload-zone').on('dragover', function(e) {
        e.preventDefault();
        $(this).addClass('dragover');
    });
    
    $('#upload-zone').on('dragleave', function(e) {
        e.preventDefault();
        $(this).removeClass('dragover');
    });
    
    $('#upload-zone').on('drop', function(e) {
        e.preventDefault();
        $(this).removeClass('dragover');
        
        const files = e.originalEvent.dataTransfer.files;
        if (files.length > 0) {
            handleFileSelect(files[0]);
        }
    });
    
    // Click to browse
    $('#upload-zone').on('click', function() {
        $('#upload').click();
    });
    
    // File input change
    $('#upload').on('change', function() {
        if (this.files && this.files[0]) {
            handleFileSelect(this.files[0]);
        }
    });
    
    // Change file button
    $('#change-file').on('click', function() {
        $('#upload').click();
    });
    
    // Back button
    $('#back-button').on('click', function() {
        $('#crop-section').hide();
        updateStep(1);
        
        $('html, body').animate({
            scrollTop: $('#upload-section').offset().top - 20
        }, 500);
    });
    
    // Save cropped image
    $('#crop-save-button').on('click', function() {
        const $button = $(this);
        const originalText = $button.html();
        
        // Show loading state
        $button.html('<i class="spinner-border spinner-border-sm me-2"></i>Saving...').prop('disabled', true);
        
        if (useCroppie && $uploadCrop) {
            // Use Croppie to get cropped result
            try {
                $uploadCrop.croppie('result', {
                    type: 'canvas',
                    size: 'viewport',
                    quality: 0.9
                }).then(function(resp) {
                    saveImageData(resp, $button, originalText);
                }).catch(function(error) {
                    console.error('Error getting cropped result:', error);
                    showErrorMessage('Failed to process cropped image. Please try again.');
                    $button.html(originalText).prop('disabled', false);
                });
            } catch (error) {
                console.error('Error in crop save process:', error);
                showErrorMessage('Failed to save cropped image. Please try again.');
                $button.html(originalText).prop('disabled', false);
            }
        } else if (selectedImageData) {
            // Use original image data in basic mode
            saveImageData(selectedImageData, $button, originalText);
        } else {
            showErrorMessage('No image selected. Please choose an image first.');
            $button.html(originalText).prop('disabled', false);
        }
    });
    
    // Function to save image data
    function saveImageData(imageData, $button, originalText) {
        $.ajax({
            url: "/include/image_upload2.cfm",
            type: "POST",
            data: {
                "picturebase": imageData
            },
            success: function(data) {
                // Show success section
                updateStep(3);
                $('#crop-section').hide();
                $('#success-section').show();
                $('#final-avatar').attr('src', imageData);
                
                // Update current avatar in header if it exists
                $('#current-avatar-img').attr('src', imageData);
                
                // Scroll to success section
                $('html, body').animate({
                    scrollTop: $('#success-section').offset().top - 20
                }, 500);
            },
            error: function(xhr, status, error) {
                console.error('Ajax error:', xhr, status, error);
                showErrorMessage('Failed to save avatar. Please try again.');
                $button.html(originalText).prop('disabled', false);
            }
        });
    }
    
    // Initialize on load
    setTimeout(function() {
        initializeCroppie();
    }, 100);
}
</script>
