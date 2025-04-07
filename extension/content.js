(() => {
    const token = localStorage.getItem("token");
    if (token) {
        chrome.runtime.sendMessage({ action: "storeToken", token: token});
    }
})()