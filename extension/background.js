chrome.runtime.onMessage.addListener((message, sender, sendResponse) => {

    console.log("Message received in background script:", message);
    if (message.action === "storeToken") {
        chrome.storage.local.set({ jwt: message.token }, () => {
            sendResponse({ status: "success" });
        })
    }

    if (message.type === "RECIPE_PAGE_DETECTED") {
        console.log("Recipe page detected.");
        chrome.storage.local.set({ recipePageDetected: true}, () => {
            sendResponse({ status: "success"});
        })
    }
})