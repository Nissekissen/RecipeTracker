var activeDisplay = document.getElementById("activeDisplay");

var currentTab = document.querySelector("a.active");

console.log(currentTab.innerHTML)

activeDisplay.style.width = currentTab.offsetWidth + "px";
activeDisplay.style.left = (currentTab.offsetLeft == 0 ? 0 : 10 * 16 + 69) + "px";
