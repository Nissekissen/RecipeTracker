chrome.runtime.onMessage.addListener((message, sender, sendResponse) => {
    
    console.log("Message received in background script:", message);
    if (message.type === "PAGE_LOADED") {
        console.log("set to false")
        chrome.storage.local.set({ recipePageDetected: false});
    }

    if (message.action === "storeToken") {
        chrome.storage.local.set({ jwt: message.token }, () => {
            sendResponse({ status: "success" });
        })
    }

    if (message.type === "RECIPE_PAGE_DETECTED") {
        console.log("set to true");
        chrome.storage.local.set({ recipePageDetected: true})
    }
})