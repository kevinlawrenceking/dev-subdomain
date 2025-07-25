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
        max-width: 600px;
        margin: 0 auto;
    }
    
    .upload-card {
        border: none;
        border-radius: 16px;
        box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1), 0 2px 4px -1px rgba(0, 0, 0, 0.06);
        transition: all 0.3s ease;
    }
    
    .upload-card:hover {
        box-shadow: 0 10px 15px -3px rgba(0, 0, 0, 0.1), 0 4px 6px -2px rgba(0, 0, 0, 0.05);
    }
    
    .upload-zone {
        border: 2px dashed ##e2e8f0;
        border-radius: 12px;
        background: ##f8fafc;
        transition: all 0.3s ease;
        cursor: pointer;
        position: relative;
        overflow: hidden;
    }
    
    .upload-zone:hover, .upload-zone.dragover {
        border-color: ##3b82f6;
        background: ##eff6ff;
    }
    
    .upload-zone.has-file {
        border-color: ##10b981;
        background: ##f0fdf4;
    }
    
    .upload-icon {
        font-size: 3rem;
        color: ##94a3b8;
        transition: color 0.3s ease;
    }
    
    .upload-zone:hover .upload-icon {
        color: ##3b82f6;
    }
    
    .current-avatar {
        width: 80px;
        height: 80px;
        border-radius: 50%;
        border: 3px solid ##e2e8f0;
        object-fit: cover;
    }
    
    .crop-container {
        background: white;
        border-radius: 12px;
        padding: 1.5rem;
        margin: 1rem 0;
    }
    
    .step-indicator {
        display: flex;
        align-items: center;
        margin-bottom: 2rem;
    }
    
    .step {
        display: flex;
        align-items: center;
        color: ##94a3b8;
        font-weight: 500;
    }
    
    .step.active {
        color: ##3b82f6;
    }
    
    .step.completed {
        color: ##10b981;
    }
    
    .step-number {
        width: 32px;
        height: 32px;
        border-radius: 50%;
        background: ##e2e8f0;
        color: ##64748b;
        display: flex;
        align-items: center;
        justify-content-center;
        font-weight: 600;
        margin-right: 0.75rem;
        font-size: 0.875rem;
    }
    
    .step.active .step-number {
        background: ##3b82f6;
        color: white;
    }
    
    .step.completed .step-number {
        background: ##10b981;
        color: white;
    }
    
    .step-divider {
        flex: 1;
        height: 2px;
        background: ##e2e8f0;
        margin: 0 1rem;
    }
    
    .btn-modern {
        border-radius: 8px;
        padding: 0.75rem 1.5rem;
        font-weight: 600;
        transition: all 0.2s ease;
        border: none;
    }
    
    .btn-primary-modern {
        background: linear-gradient(135deg, ##3b82f6 0%, ##1d4ed8 100%);
        color: white;
    }
    
    .btn-primary-modern:hover {
        transform: translateY(-2px);
        box-shadow: 0 10px 15px -3px rgba(59, 130, 246, 0.4);
    }
    
    .file-info {
        background: ##f1f5f9;
        border-radius: 8px;
        padding: 1rem;
        margin: 1rem 0;
    }
    
    .success-animation {
        animation: successPulse 0.6s ease-out;
    }
    
    @keyframes successPulse {
        0% { transform: scale(0.95); opacity: 0; }
        50% { transform: scale(1.02); }
        100% { transform: scale(1); opacity: 1; }
    }
    
    @media (max-width: 768px) {
        .avatar-upload-container {
            margin: 0 1rem;
        }
        
        .step-indicator {
            flex-direction: column;
            gap: 1rem;
        }
        
        .step-divider {
            width: 2px;
            height: 20px;
            margin: 0;
        }
    }
</style>

<!-- Modern Avatar Upload Interface -->
<div class="avatar-upload-container">
    <!-- Header Section -->
    <div class="text-center mb-4">
        <h2 class="text-dark mb-2">
            <i class="fe-user me-2"></i>Update Avatar
        </h2>
        <p class="text-muted">
            <cfoutput>Upload a new profile picture for #subtitle#</cfoutput>
        </p>
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
