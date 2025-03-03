const addBtn = document.getElementById("addIngredient");
const ingredientList = document.querySelector('.add-ingredient-list');

function removeIngredient(button) {
    button.parentElement.remove();
}

addBtn.addEventListener("click", () => {
    const ingredientDiv = document.createElement('div');
    ingredientDiv.className = 'add-ingredient';
    ingredientDiv.innerHTML = `
        <input type="text" name="ingredient[]" placeholder="Ingrediens" required>
        <button type="button" class="btn btn--secondary" onclick="removeIngredient(this)">Ta bort</button>
    `;

    ingredientList.appendChild(ingredientDiv);
});