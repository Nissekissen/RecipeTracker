
document.getElementById('addForm').addEventListener('submit', async (e) => {
    
    e.preventDefault();

    const submitBtn = document.getElementById('submitBtn');

    submitBtn.classList.add('btn--loading');

    submitBtn.innerHTML = 'Verifierar <img src="/loading.svg" alt="Loading" class="loading-icon" />';

    const url = document.getElementById('url').value;
    
    
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

    submitBtn.innerHTML = 'Skapar recept <img src="/loading.svg" alt="Loading" class="loading-icon" />';

    response = await fetch('/api/v1/recipes?alreadyVerified=true&url=' + encodeURIComponent(url), {
        method: 'POST'
    })

    if (response.status == 200) {
        window.location.href = '/recipes';
    } else {
        submitBtn.classList.remove('btn--loading');
        submitBtn.innerHTML = 'Lägg till recept';
        document.querySelector('.error-display').innerText = "Receptet finns redan";
        document.querySelector('.error-display').style.display = "block";
    }



});