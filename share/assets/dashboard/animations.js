function openAllUrls(siteurl_list) {
    const urls = siteurl_list.split(',');
    console.log(`Attempting to open ${urls.length} URLs`);
    
    let delay = 0;

    urls.forEach((url, index) => {
        const trimmedUrl = url.trim();
        console.log(`Queuing URL ${index + 1}: ${trimmedUrl}`);

        setTimeout(() => {
            console.log(`Opening URL ${index + 1}: ${trimmedUrl}`);
            try {
                const newWindow = window.open(trimmedUrl, '_blank');
                if (newWindow === null) {
                    console.warn(`Failed to open ${trimmedUrl}`);
                } else {
                    console.log(`Successfully opened ${trimmedUrl}`);
                }
            } catch (e) {
                console.error(`An error occurred while trying to open ${trimmedUrl}: ${e.message}`);
            }
        }, delay);

        // Increase delay for the next URL
        delay += 500; // 500ms delay between opening each URL
    });
}