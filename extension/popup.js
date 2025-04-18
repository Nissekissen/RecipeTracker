
const notLoggedInDiv = document.getElementById('notLoggedIn');
const loggedInDiv = document.getElementById('loggedIn');
const canBeSavedDiv = document.getElementById('canBeSaved');
const canNotBeSavedDiv = document.getElementById('canNotBeSaved');
const saveButton = document.getElementById('saveRecipe');
const logInButton = document.getElementById('logIn');

var loggedIn = false;
var user = null;

(async () => {

    
    // Get user from the API
    
    loggedInDiv.style.display = 'none';
    notLoggedInDiv.style.display = 'none';
    canBeSavedDiv.style.display = 'none';
    canNotBeSavedDiv.style.display = 'none';
    
    let response;
    try {
        response = await fetch('http://localhost:9292/api/v1/get-user', {
            method: 'GET'
        });
    } catch (error) {
        console.error('Error fetching user:', error);
        notLoggedInDiv.style.display = 'flex';
        loggedInDiv.style.display = 'none';
        canBeSavedDiv.style.display = 'none';
        canNotBeSavedDiv.style.display = 'none';
        loggedIn = false;
        return;
    }
    
    if (response.status !== 200) {
        notLoggedInDiv.style.display = 'flex';
        loggedInDiv.style.display = 'none';
        canBeSavedDiv.style.display = 'none';
        canNotBeSavedDiv.style.display = 'none';
        loggedIn = false;
        return;
    }
    user = await response.json();
    console.log("Popup script loaded");
    
    // Save user to local storage
    localStorage.setItem('user', JSON.stringify(user));

    notLoggedInDiv.style.display = 'none';
    loggedInDiv.style.display = 'flex';
    canBeSavedDiv.style.display = 'none';
    canNotBeSavedDiv.style.display = 'flex';
    loggedIn = true;
})()

setInterval(async () => {
    if (!loggedIn) {
        return;
    }
    const { recipePageDetected } = await chrome.storage.local.get('recipePageDetected');
    console.log('recipePageDetected', recipePageDetected);
    if (recipePageDetected === undefined) {
        console.log('recipePageDetected is undefined');
        return;
    }
    if (recipePageDetected === null) {
        console.log('recipePageDetected is null');
        return;
    }
    if (recipePageDetected) {
        canBeSavedDiv.style.display = 'flex';
        canNotBeSavedDiv.style.display = 'none';
    } else {
        canBeSavedDiv.style.display = 'none';
        canNotBeSavedDiv.style.display = 'flex';
    }
}, 1000);

logInButton.addEventListener('click', () => {
    chrome.tabs.create({ url: 'http://localhost:9292/auth/sign-in' });
});

saveButton.addEventListener('click', async () => {
});