const dropdown = document.querySelector('.collections-dropdown');
const toggleButton = document.querySelector('.collections-dropdown-toggle');
const menu = document.querySelector('.collections-dropdown-menu');

async function getFilteredRecipes(checkboxes) {
    let checked = Array.from(checkboxes)
        .filter(checkbox => checkbox.checked)
        .map((checkbox) => checkbox.name);
    
    if (checked.length == 0) {
        // select all collections
        checked = Array.from(checkboxes).map((checkbox) => checkbox.name);
    };

    // if the current path contains /groups, we need to add it to the fetch url
    if (window.location.pathname.includes('/groups')) {
        // filter the id from the url. format: /groups/id
        var groupId = window.location.pathname.split('/').pop();
        
    }
    
    const response = await fetch('/api/v1/recipes/filter' + (groupId === undefined ? '' : `?group_id=${groupId}`), {
        method: 'POST',
        body: JSON.stringify({ collections: checked })
    })

    // fetch will return .recipe-list
    const data = await response.text();

    const recipeList = document.querySelector('.recipe-list');
    if (recipeList) {
        const tempDiv = document.createElement('div');
        tempDiv.innerHTML = data;
        const newRecipeList = tempDiv.querySelector('.recipe-list');
        if (newRecipeList) {
            recipeList.replaceWith(newRecipeList);
        }
    }
}

const checkboxes = document.querySelectorAll('.collections-dropdown-menu input[type="checkbox"]');
function updateText() {
    const checked = Array.from(checkboxes)
        .filter((checkbox) => checkbox.checked)
        .map((checkbox) => checkbox.value)
        .join(', ');

    toggleButton.textContent = checked || 'Välj samlingar';

    // Filter the recipes based on the selected collections
    getFilteredRecipes(checkboxes);
}

toggleButton.addEventListener('click', () => {
    dropdown.classList.toggle('open');
});

document.addEventListener('click', (e) => {
    if (!dropdown.contains(e.target)) {
        dropdown.classList.remove('open');

        updateText();
    }
});

toggleButton.addEventListener('click', () => {
    updateText();
});
