document.getElementById('addForm')?.addEventListener('submit', async (e) => {
    
    e.preventDefault();

    const submitBtn = document.getElementById('submitBtn');

    submitBtn.classList.add('btn--loading');

    submitBtn.innerHTML = 'Verifierar <img src="/assets/svg/loading.svg" alt="Loading" class="loading-icon" />';

    const url = document.getElementById('url').value;
    const collection = document.getElementById('collection').value;
    
    let response = await fetch('/api/v1/recipes/check?url=' + encodeURIComponent(url), {
        method: 'GET'
    });
    
    const data = await response.json();

    console.log(data);

    
    if (!data.valid) {
        console.log("not valid");
        submitBtn.classList.remove('btn--loading');
        submitBtn.innerHTML = 'Lägg till recept';
        document.querySelector('.error-display').innerText = "Ogiltig URL";
        document.querySelector('.error-display').style.display = "block";
        return;
    }

    submitBtn.innerHTML = 'Skapar recept <img src="/assets/svg/loading.svg" alt="Loading" class="loading-icon" />';

    response = await fetch('/api/v1/recipes?alreadyVerified=true&url=' + encodeURIComponent(url) + '&collection=' + collection, {
        method: 'POST'
    })

    if (response.status == 200) {
        window.location.href = '/recipes';
    } else {
        submitBtn.classList.remove('btn--loading');
        submitBtn.innerHTML = 'Lägg till recept';
        document.querySelector('.error-display').style.display = "block";

        switch (response.status) {
            case 400:
                document.querySelector('.error-display').innerText = "Felaktig begäran: URL krävs eller receptet finns redan";
                break;
            case 401:
                document.querySelector('.error-display').innerText = "Du måste vara inloggad för att spara ett recept";
                break;
            case 403:
                document.querySelector('.error-display').innerText = "Du har inte behörighet att utföra denna åtgärd";
                break;
            case 404:
                document.querySelector('.error-display').innerText = "Receptet hittades inte";
                break;
            default:
                document.querySelector('.error-display').innerText = "Ett okänt fel inträffade";
        }
    }
});