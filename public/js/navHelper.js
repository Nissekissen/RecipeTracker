
setTimeout(() => {

    var activeDisplay = document.getElementById("activeDisplay");

    var currentTab = document.querySelector("a.active");

    activeDisplay.style.width = currentTab.offsetWidth + "px";
    activeDisplay.style.left = currentTab.offsetLeft + "px";
    // activeDisplay.style.left = (currentTab.offsetLeft == 0 ? 0 : 10 * 16 + document.querySelectorAll('a.profile-content-nav-item')[0].clientWidth) + "px";

}, 100);