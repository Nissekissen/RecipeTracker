// Ran on probable recipe pages. Filter with opengraph.

// Chatgpt magic
const isRecipePage = () => {
  const scripts = document.querySelectorAll('script[type="application/ld+json"]');
  for (const script of scripts) {
    try {
      const data = JSON.parse(script.textContent);
      if (Array.isArray(data)) {
        if (data.some(entry => entry['@type'] === 'Recipe')) return true;
      } else if (data['@type'] === 'Recipe') {
        return true;
      }
    } catch (e) {
      // Ignore parse errors
    }
  }
  return false;
};

console.log("Is recipe page:", isRecipePage());

if (isRecipePage()) {
    console.log("Recipe page detected (filter).");
    // Optionally, send a message to the popup
    chrome.runtime.sendMessage({ type: 'RECIPE_PAGE_DETECTED' });
}