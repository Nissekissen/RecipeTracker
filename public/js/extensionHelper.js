// If the user is logged in, save the JWT token in local storage.

var jwtElement = document.getElementById("jwt");

if (jwtElement) {
    var jwt = jwtElement.value;
    if (jwt) {
        localStorage.setItem("token", jwt);
        console.log("Token saved in local storage.");
    }
}