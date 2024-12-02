
const modal = document.getElementById('saveRecipeModal');

const openBtns = document.querySelectorAll('.save-recipe');

// const closeBtn = document.getElementById('closeSaveRecipeModal');

openBtns.forEach(openBtn => openBtn.addEventListener('click', () => {
    modal.style.display = 'block';
}))

// closeBtn.addEventListener('click', () => {
//     modal.style.display = 'none';
// })

window.addEventListener('click', (e) => {
    if (e.target === modal) {
        modal.style.display = 'none';
    }
})