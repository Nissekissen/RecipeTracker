// Ran on confirmed recipe pages.
chrome.runtime.sendMessage({ action: "RECIPE_PAGE_DETECTED" }, (response) => {
    if (response.status === "success") {
        console.log("Recipe page detected and stored.");
    } else {
        console.error("Failed to store recipe page detection.");
    }
});