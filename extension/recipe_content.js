// Ran on confirmed recipe pages.
console.log("Recipe page detected (no filter)");
chrome.runtime.sendMessage({ type: "RECIPE_PAGE_DETECTED" });