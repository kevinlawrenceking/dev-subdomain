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

<!-- Load Croppie JS with fallback -->
<script>
// Simple Croppie loading
function loadCroppie() {
    if (typeof Croppie === 'undefined') {
        console.log('Loading Croppie from alternative source...');
        const script = document.createElement('script');
        script.src = 'https://unpkg.com/croppie@2.6.5/croppie.min.js';
        script.onload = function() {
            console.log('Croppie loaded from unpkg');
        };
        script.onerror = function() {
            console.warn('Croppie failed to load from all sources');
            window.croppieUnavailable = true;
        };
        document.head.appendChild(script);
    } else {
        console.log('Croppie available from primary CDN');
    }
}
</script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/croppie/2.6.5/croppie.min.js" onload="console.log('Croppie loaded from cdnjs')" onerror="loadCroppie()"></script>

<!-- Main Upload Script -->
<script>
// Simplified Croppie detection
function checkCroppieAvailability() {
    const hasGlobalCroppie = typeof Croppie !== 'undefined';
    const hasJQueryCroppie = typeof $ !== 'undefined' && 
                           typeof $.fn !== 'undefined' && 
                           typeof $.fn.croppie !== 'undefined';
    
    console.log('Global Croppie available:', hasGlobalCroppie);
    console.log('jQuery Croppie plugin available:', hasJQueryCroppie);
    
    return hasJQueryCroppie || hasGlobalCroppie;
}

function initializeWhenReady() {
    // Check if already initialized
    if (window.uploadInterfaceInitialized) return;
    
    console.log('Checking readiness...');
    console.log('jQuery available:', typeof $ !== 'undefined');
    console.log('Document ready state:', document.readyState);
    
    // Wait for both jQuery and DOM to be ready
    if (typeof $ !== 'undefined' && (document.readyState === 'complete' || document.readyState === 'interactive')) {
        // Give Croppie more time to initialize the jQuery plugin
        setTimeout(function() {
            const croppieAvailable = checkCroppieAvailability();
            console.log('Final Croppie check result:', croppieAvailable);
            initializeUploadApp();
        }, 500); // Increased delay for proper plugin initialization
        return true;
    }
    return false;
}

// Try multiple initialization strategies
$(document).ready(function() {
    console.log('DOM ready, attempting initialization...');
    
    // Try immediate initialization
    if (initializeWhenReady()) {
        return;
    }
    
    // If not ready, check periodically
    let attempts = 0;
    const maxAttempts = 50; // 10 seconds total
    
    const checkInterval = setInterval(function() {
        attempts++;
        
        if (initializeWhenReady() || attempts >= maxAttempts) {
            clearInterval(checkInterval);
            
            if (attempts >= maxAttempts && !window.uploadInterfaceInitialized) {
                console.warn('Max attempts reached, forcing initialization...');
                initializeUploadApp();
            }
        }
    }, 200);
});

// Backup initialization on window load
$(window).on('load', function() {
    setTimeout(function() {
        if (!window.uploadInterfaceInitialized) {
            console.log('Window load backup initialization...');
            initializeUploadApp();
        }
    }, 500);
});
</script>

<!-- Custom Styles for Modern Look -->
<style>
    .upload-card {
        border: 1px solid #dee2e6;
        background: #ffffff;
        box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        transition: all 0.3s ease;
    }
    
    .upload-card:hover {
        box-shadow: 0 4px 8px rgba(0,0,0,0.15);
    }
    
    .upload-card:hover {
        box-shadow: 0 10px 15px -3px rgba(0, 0, 0, 0.1), 0 4px 6px -2px rgba(0, 0, 0, 0.05);
    }
    
    .upload-zone {
        border: 2px dashed #406e8e;
        background: #f8f9fa;
        transition: all 0.3s ease;
        cursor: pointer;
        min-height: 200px;
        display: flex;
        align-items: center;
        justify-content: center;
    }
    
    .upload-zone:hover, .upload-zone.dragover {
        border-color: #406e8e;
        background: #e6f3ff;
    }
    
    .upload-zone.has-file {
        border-color: #28a745;
        background: #d4edda;
    }
    
    .upload-icon {
        font-size: 3rem;
        color: #406e8e;
        transition: color 0.3s ease;
    }
    
    .upload-zone:hover .upload-icon {
        color: #2d4a5f;
    }
    
    .current-avatar {
        width: 100px;
        height: 100px;
        border-radius: 50% !important;
        border: 3px solid #406e8e;
        box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        transition: all 0.3s ease;
        object-fit: cover;
        overflow: hidden;
        display: block;
        margin: 0 auto !important;
    }
    
    .avatar-center {
        display: flex;
        justify-content: center;
        align-items: center;
        width: 100%;
    }
    
    .current-avatar:hover {
        transform: scale(1.05);
        box-shadow: 0 4px 8px rgba(0,0,0,0.15);
    }
    
    .crop-container {
        background: #ffffff;
        border: 1px solid #dee2e6;
        padding: 2rem;
        margin: 1.5rem 0;
        box-shadow: 0 2px 4px rgba(0,0,0,0.1);
    }
    
    .step-indicator {
        display: flex;
        align-items: center;
        justify-content: center;
        margin-bottom: 3rem;
        padding: 1.5rem;
        background: #f8f9fa;
        border: 1px solid #dee2e6;
    }
    
    .step {
        display: flex;
        align-items: center;
        color: #6c757d;
        font-weight: 600;
        font-size: 1.1rem;
        transition: all 0.3s ease;
    }
    
    .step.active {
        color: #406e8e;
    }
    
    .step.completed {
        color: #28a745;
    }
    
    .step-number {
        width: 40px;
        height: 40px;
        border-radius: 50%;
        background: #e9ecef;
        color: #495057;
        display: flex;
        align-items: center;
        justify-content: center;
        font-weight: 700;
        margin-right: 1rem;
        font-size: 1rem;
        transition: all 0.3s ease;
        text-align: center;
        line-height: 1;
    }
    
    .step.active .step-number {
        background: #406e8e;
        color: white;
    }
    
    .step.completed .step-number {
        background: #28a745;
        color: white;
    }
    
    .step-divider {
        flex: 1;
        height: 2px;
        background: #dee2e6;
        margin: 0 1.5rem;
    }
    
    .btn-modern {
        padding: 0.75rem 1.5rem;
        font-weight: 600;
        transition: all 0.3s ease;
        border: none;
    }
    
    .btn-primary-modern {
        background: #406e8e;
        color: white;
        border: 1px solid #406e8e;
    }
    
    .btn-primary-modern:hover {
        background: #2d4a5f;
        border-color: #2d4a5f;
    }
    
    .file-info {
        background: #f8f9fa;
        border: 1px solid #dee2e6;
        padding: 1rem;
        margin: 1rem 0;
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
<!-- Header Section -->
<div class="text-center mb-4 fade-in">
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
                    <div class="avatar-center">
                        <img src="#image_url#?ver=#rand()#" alt="Current Avatar" class="current-avatar" id="current-avatar-img">
                    </div>
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
            <div class="d-flex justify-content-center gap-3">
                <cfoutput>
                    <a href="#cookie.return_url#" class="btn btn-primary-modern">
                        <i class="fe-arrow-right me-2"></i>Continue to Profile
                    </a>
                </cfoutput>
                <button type="button" class="btn btn-outline-secondary btn-modern" onclick="window.location.reload();">
                    <i class="fe-refresh-cw me-2"></i>Refresh Page
                </button>
            </div>
            <div class="mt-3">
                <small class="text-muted">
                    <i class="fe-info me-1"></i>
                    If you don't see the updated avatar immediately, try refreshing the page
                </small>
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
    
    // Enhanced Croppie detection with multiple fallbacks
    const jQueryAvailable = typeof $ !== 'undefined' && typeof $.fn !== 'undefined';
    const globalCroppieAvailable = typeof Croppie !== 'undefined';
    const jQueryCroppieAvailable = jQueryAvailable && typeof $.fn.croppie !== 'undefined';
    const croppieAvailable = globalCroppieAvailable || jQueryCroppieAvailable;
    
    console.log('jQuery available:', jQueryAvailable);
    console.log('Global Croppie available:', globalCroppieAvailable);
    console.log('jQuery Croppie plugin available:', jQueryCroppieAvailable);
    console.log('Overall Croppie available:', croppieAvailable);
    
    // Use Croppie unless explicitly disabled or unavailable
    const useCroppie = croppieAvailable && !window.croppieUnavailable;
    
    console.log('Will use Croppie:', useCroppie);
    
    if (!useCroppie) {
        console.warn('Using basic upload mode - Croppie not available');
        console.warn('Croppie unavailable flag:', window.croppieUnavailable);
        $('#crop-section h5').html('<i class="fe-image me-2"></i>Preview Your Image');
    } else {
        console.log('Croppie mode enabled - full cropping functionality available');
        $('#crop-section h5').html('<i class="fe-crop me-2"></i>Crop Your Image');
    }
    
    // Modern file validation
    const maxFileSize = 5 * 1024 * 1024; // 5MB
    const allowedTypes = ['image/jpeg', 'image/jpg', 'image/png', 'image/gif'];
    
    let $uploadCrop;
    let currentStep = 1;
    let selectedImageData = null;
    
    // Initialize croppie with enhanced error handling
    function initializeCroppie() {
        console.log('Initializing Croppie...');
        
        if (!useCroppie) {
            console.log('Using basic preview mode');
            // Basic preview mode with better error handling
            const currentAvatarUrl = '<cfoutput>#image_url#</cfoutput>?ver=<cfoutput>#rand()#</cfoutput>';
            console.log('Loading current avatar:', currentAvatarUrl);
            
            $('#upload-input').html(`
                <div id="basic-preview" style="width: <cfoutput>#picsize#</cfoutput>px; height: <cfoutput>#picsize#</cfoutput>px; 
                     border: 2px dashed ##ddd; border-radius: 50%; margin: 0 auto; 
                     display: flex; align-items: center; justify-content: center; 
                     background-size: cover; background-position: center; 
                     background-image: url('${currentAvatarUrl}'); 
                     background-color: ##f8f9fa;">
                    <span style="color: ##999; text-align: center; background: rgba(255,255,255,0.8); 
                                padding: 8px; border-radius: 4px; font-size: 12px;">Current Avatar</span>
                </div>
            `);
            
            // Test if image loads properly
            const testImg = new Image();
            testImg.onload = function() {
                console.log('Current avatar loaded successfully');
                // Remove the overlay text since image loaded
                $('#basic-preview span').hide();
            };
            testImg.onerror = function() {
                console.warn('Current avatar failed to load');
                $('#basic-preview').css({
                    'background-image': 'none',
                    'background-color': '#f8f9fa'
                }).find('span').text('No Current Avatar').show();
            };
            testImg.src = currentAvatarUrl;
            return;
        }
        
        try {
            console.log('Creating Croppie instance...');
            
            // Clean up any existing instance
            if ($uploadCrop) {
                try {
                    $uploadCrop.croppie('destroy');
                } catch (e) {
                    console.log('Note: Previous Croppie instance cleanup:', e.message);
                }
            }
            
            // Clear the container
            $('#upload-input').empty();
            
            // Create new Croppie instance
            $uploadCrop = $('#upload-input').croppie({
                enableExif: true,
                url: '<cfoutput>#image_url#</cfoutput>?ver=<cfoutput>#rand()#</cfoutput>',
                viewport: {
                    width: <cfoutput>#picsize#</cfoutput>,
                    height: <cfoutput>#picsize#</cfoutput>,
                    type: 'circle'
                },
                boundary: {
                    width: <cfoutput>#inputsize#</cfoutput>,
                    height: <cfoutput>#inputsize#</cfoutput>
                },
                showZoomer: true,
                enableOrientation: true
            });
            
            console.log('Croppie instance created successfully');
            
        } catch (error) {
            console.error('Error initializing Croppie:', error);
            showErrorMessage('Failed to initialize image cropper. Using basic preview mode.');
            
            // Fall back to basic mode
            window.croppieUnavailable = true;
            $('#crop-section h5').html('<i class="fe-image me-2"></i>Preview Your Image');
            
            // Retry in basic mode with better error handling
            const currentAvatarUrl = '<cfoutput>#image_url#</cfoutput>?ver=<cfoutput>#rand()#</cfoutput>';
            console.log('Fallback: Loading current avatar:', currentAvatarUrl);
            
            $('#upload-input').html(`
                <div id="fallback-preview" style="width: <cfoutput>#picsize#</cfoutput>px; height: <cfoutput>#picsize#</cfoutput>px; 
                     border: 2px dashed ##ddd; border-radius: 50%; margin: 0 auto; 
                     display: flex; align-items: center; justify-content: center; 
                     background-size: cover; background-position: center; 
                     background-image: url('${currentAvatarUrl}'); 
                     background-color: ##f8f9fa;">
                    <span style="color: ##999; text-align: center; background: rgba(255,255,255,0.8); 
                                padding: 8px; border-radius: 4px; font-size: 12px;">Current Avatar</span>
                </div>
            `);
            
            // Test if image loads properly
            const testImg = new Image();
            testImg.onload = function() {
                console.log('Fallback: Current avatar loaded successfully');
                $('#fallback-preview span').hide();
            };
            testImg.onerror = function() {
                console.warn('Fallback: Current avatar failed to load');
                $('#fallback-preview').css({
                    'background-image': 'none',
                    'background-color': '#f8f9fa'
                }).find('span').text('No Current Avatar').show();
            };
            testImg.src = currentAvatarUrl;
        }
    }
    
    // Step management
    function updateStep(step) {
        currentStep = step;
        $('.step').removeClass('active completed');
        
        for (let i = 1; i <= 3; i++) {
            if (i < step) {
                $(`#step${i}`).addClass('completed');
            } else if (i === step) {
                $(`#step${i}`).addClass('active');
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
        const fileName = file.name.replace(/[^\w\s.-]/gi, ''); // Remove special characters
        const fileType = file.type.split('/')[1].toUpperCase();
        
        $('#file-name').text(fileName);
        $('#file-details').text(`${sizeInMB}MB • ${fileType}`);
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
                try {
                    // Clean up any existing instance
                    if ($uploadCrop) {
                        $uploadCrop.croppie('destroy');
                    }
                    
                    // Clear the container completely
                    $('#upload-input').empty();
                    
                    // Create fresh croppie instance WITHOUT the old image URL
                    $uploadCrop = $('#upload-input').croppie({
                        enableExif: true,
                        viewport: {
                            width: <cfoutput>#picsize#</cfoutput>,
                            height: <cfoutput>#picsize#</cfoutput>,
                            type: 'circle'
                        },
                        boundary: {
                            width: <cfoutput>#inputsize#</cfoutput>,
                            height: <cfoutput>#inputsize#</cfoutput>
                        },
                        showZoomer: true,
                        enableOrientation: true
                    });
                    
                    // Bind ONLY the new image - simplified without promise handling
                    console.log('Binding new image to Croppie...');
                    $uploadCrop.croppie('bind', {
                        url: e.target.result
                    });
                    
                    console.log('New image loaded for cropping');
                    
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
    
    // Click to browse - use more specific targeting to avoid infinite loop
    $('#upload-zone').on('click', function(e) {
        // Only trigger if we're not clicking on the file input itself
        if (e.target.id !== 'upload') {
            e.preventDefault();
            e.stopPropagation();
            console.log('Upload zone clicked, opening file browser...');
            $('#upload')[0].click(); // Use native click instead of jQuery trigger
        }
    });
    
    // Prevent file input from bubbling up to parent
    $('#upload').on('click', function(e) {
        e.stopPropagation();
    });
    
    // File input change
    $('#upload').on('change', function(e) {
        console.log('File input changed...');
        if (this.files && this.files[0]) {
            handleFileSelect(this.files[0]);
        }
    });
    
    // Change file button
    $('#change-file').on('click', function(e) {
        e.preventDefault();
        e.stopPropagation();
        
        // Reset state
        $('#file-info').hide();
        $('#upload-zone').removeClass('has-file');
        $('#upload').val(''); // Clear file input
        selectedImageData = null;
        
        // Trigger file browser
        $('#upload').trigger('click');
    });
    
    // Back button
    $('#back-button').on('click', function() {
        $('#crop-section').hide();
        $('#file-info').hide();
        $('#upload-zone').removeClass('has-file');
        $('#upload').val(''); // Clear file input
        selectedImageData = null;
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
                console.log('Getting cropped result...');
                var croppieResult = $uploadCrop.croppie('result', {
                    type: 'canvas',
                    size: 'viewport',
                    quality: 0.9
                });
                
                // Handle both promise and direct return scenarios
                if (croppieResult && typeof croppieResult.then === 'function') {
                    // It's a promise
                    croppieResult.then(function(resp) {
                        console.log('Cropped result received via promise');
                        saveImageData(resp, $button, originalText);
                    }).catch(function(error) {
                        console.error('Error getting cropped result via promise:', error);
                        showErrorMessage('Failed to process cropped image. Please try again.');
                        $button.html(originalText).prop('disabled', false);
                    });
                } else {
                    // Direct return
                    console.log('Cropped result received directly');
                    saveImageData(croppieResult, $button, originalText);
                }
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
            timeout: 30000, // 30 second timeout
            success: function(data) {
                console.log('Upload successful:', data);
                
                // Reset button
                $button.html(originalText).prop('disabled', false);
                
                // Show success section
                updateStep(3);
                $('#crop-section').hide();
                $('#success-section').show();
                $('#final-avatar').attr('src', imageData);
                
                // Update current avatar with a cache-busting timestamp
                const newTimestamp = new Date().getTime();
                const currentAvatarUrl = '<cfoutput>#image_url#</cfoutput>' + '?v=' + newTimestamp;
                $('#current-avatar-img').attr('src', currentAvatarUrl);
                
                // Update the session avatar if possible by forcing a small delay
                setTimeout(function() {
                    // Try to reload the avatar from server to ensure it's updated
                    const serverAvatarUrl = '<cfoutput>#image_url#</cfoutput>' + '?v=' + (newTimestamp + 1000);
                    $('#current-avatar-img').attr('src', serverAvatarUrl);
                    $('#final-avatar').attr('src', serverAvatarUrl);
                }, 2000);
                
                // Scroll to success section
                $('html, body').animate({
                    scrollTop: $('#success-section').offset().top - 20
                }, 500);
            },
            error: function(xhr, status, error) {
                console.error('Ajax error:', xhr, status, error);
                $button.html(originalText).prop('disabled', false);
                
                if (status === 'timeout') {
                    showErrorMessage('Upload timed out. Please try again with a smaller image.');
                } else {
                    showErrorMessage('Failed to save avatar. Please try again.');
                }
            }
        });
    }
    
    // Initialize Croppie on load with debugging
    console.log('About to initialize Croppie...');
    console.log('Current useCroppie value:', useCroppie);
    
    setTimeout(function() {
        console.log('Running delayed Croppie initialization...');
        initializeCroppie();
        
        // Log the final state
        console.log('Upload interface fully initialized');
        console.log('Croppie mode active:', useCroppie && !window.croppieUnavailable);
        
        if (useCroppie && $uploadCrop) {
            console.log('Croppie instance created successfully');
        }
        
        // Add debug function to window for manual testing
        window.debugCroppie = function() {
            console.log('=== CROPPIE DEBUG INFO ===');
            console.log('typeof Croppie:', typeof Croppie);
            console.log('typeof $:', typeof $);
            console.log('typeof $.fn:', typeof $ !== 'undefined' ? typeof $.fn : 'undefined');
            console.log('typeof $.fn.croppie:', typeof $ !== 'undefined' && typeof $.fn !== 'undefined' ? typeof $.fn.croppie : 'undefined');
            console.log('window.croppieUnavailable:', window.croppieUnavailable);
            console.log('Upload interface initialized:', window.uploadInterfaceInitialized);
            console.log('Current useCroppie value:', useCroppie);
            
            // Test current avatar URL
            const avatarUrl = '<cfoutput>#image_url#</cfoutput>?ver=<cfoutput>#rand()#</cfoutput>';
            console.log('Current avatar URL:', avatarUrl);
            
            // Test image loading
            const testImg = new Image();
            testImg.onload = () => console.log('✓ Avatar image loads successfully');
            testImg.onerror = () => console.log('✗ Avatar image failed to load');
            testImg.src = avatarUrl;
            
            // Test Croppie functionality
            if (typeof $.fn.croppie !== 'undefined') {
                console.log('✓ Croppie jQuery plugin is functional');
                
                // Test creating a temporary instance
                try {
                    const $testDiv = $('<div>').css({width: '100px', height: '100px'});
                    $('body').append($testDiv);
                    $testDiv.croppie({
                        viewport: { width: 50, height: 50, type: 'circle' },
                        boundary: { width: 100, height: 100 }
                    });
                    console.log('✓ Croppie instance creation test passed');
                    $testDiv.croppie('destroy');
                    $testDiv.remove();
                } catch (e) {
                    console.log('✗ Croppie instance creation test failed:', e.message);
                }
            } else {
                console.log('✗ Croppie jQuery plugin not available');
            }
            
            console.log('=== END DEBUG INFO ===');
        };
        
        // Auto-run debug after a delay
        setTimeout(function() {
            console.log('Running automatic Croppie debug check...');
            window.debugCroppie();
        }, 2000);
    }, 100);
}
</script>
