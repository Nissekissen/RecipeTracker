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

    // console.log(updateOpenBtns);
    if (updateOpenBtns != undefined) {
        
        updateOpenBtns();
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

if (toggleButton != null) {

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

}


// For editing collections
var visibilityCheckboxes = document.querySelectorAll('.visibility-checkbox');
var editButtons = document.querySelectorAll('.edit-button');
var deleteButtons = document.querySelectorAll('.delete-button');

var newCollectionButton = document.getElementById('newCollection');
var collectionsList = document.querySelector('.collections-list');

function createNewCollectionElement() {
    const collectionCard = document.createElement('div');
    collectionCard.classList.add('collection-card');

    // Collection row
    const collectionRow = document.createElement('div');
    collectionRow.classList.add('collection-row');

    // Collection name (with input field)
    const collectionName = document.createElement('div');
    collectionName.classList.add('collection-name', 'editing'); // Start in editing mode
    const collectionNameDisplay = document.createElement('span');
    collectionNameDisplay.classList.add('collection-name-display');
    collectionNameDisplay.textContent = 'Ny samling'; // Default name
    const collectionNameInput = document.createElement('input');
    collectionNameInput.classList.add('collection-name-input');
    collectionNameInput.type = 'text';
    collectionNameInput.value = 'Ny samling'; // Default name
    collectionName.appendChild(collectionNameDisplay);
    collectionName.appendChild(collectionNameInput);

    // Collection visibility (checkbox)
    const collectionVisibility = document.createElement('div');
    collectionVisibility.classList.add('collection-visibility');
    const visibilityToggle = document.createElement('label');
    visibilityToggle.classList.add('visibility-toggle');
    const visibilityCheckbox = document.createElement('input');
    visibilityCheckbox.classList.add('visibility-checkbox');
    visibilityCheckbox.type = 'checkbox';
    visibilityCheckbox.checked = true; // Default to public
    visibilityCheckbox.disabled = false; // Enabled in editing mode
    const visibilityIcon = document.createElement('span');
    visibilityIcon.classList.add('visibility-icon');
    const globeIcon = document.createElement('i');
    globeIcon.classList.add('fa-solid', 'fa-globe', 'fa-sm');
    const lockIcon = document.createElement('i');
    lockIcon.classList.add('fa-solid', 'fa-lock', 'fa-sm', 'hidden');
    const visibilityLabel = document.createElement('span');
    visibilityLabel.classList.add('visibility-label');
    visibilityLabel.textContent = 'Publik'; // Default label
    visibilityIcon.appendChild(globeIcon);
    visibilityIcon.appendChild(lockIcon);
    visibilityToggle.appendChild(visibilityCheckbox);
    visibilityToggle.appendChild(visibilityIcon);
    visibilityToggle.appendChild(visibilityLabel);
    collectionVisibility.appendChild(visibilityToggle);

    // Collection actions (edit and delete buttons)
    const collectionActions = document.createElement('div');
    collectionActions.classList.add('collection-actions');
    const editButton = document.createElement('button');
    editButton.classList.add('edit-button');
    editButton.setAttribute('aria-label', 'Save changes');
    editButton.innerHTML = '<i class="fa-regular fa-square-check"></i>'; // Checkmark for editing mode
    const deleteButton = document.createElement('button');
    deleteButton.classList.add('delete-button');
    deleteButton.setAttribute('aria-label', 'Delete collection');
    deleteButton.innerHTML = '<i class="fa-regular fa-trash-can"></i>';
    collectionActions.appendChild(editButton);
    collectionActions.appendChild(deleteButton);

    // Assemble the collection card
    collectionRow.appendChild(collectionName);
    collectionRow.appendChild(collectionVisibility);
    collectionCard.appendChild(collectionRow);
    collectionCard.appendChild(collectionActions);


    return collectionCard;
}

function saveChangesToServer(collectionId, name, isPrivate) {
    // Replace this with your actual API call
    console.log('Saving changes to server:', { collectionId, name, isPrivate });
    if (collectionId !== undefined) {
        fetch(`/api/v1/collections/${collectionId}`, {
            method: 'PUT',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify({ name, is_private: isPrivate }),
        })
            .then(response => {
                console.log('Changes saved successfully:', response);
            })
            .catch(error => {
                console.error('Error saving changes:', error);
            });
    } else {
        fetch(`/api/v1/collections`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify({ name, is_private: isPrivate }),
        })
            .then(response => response.json())
            .then(data => {
                // update the edit button with the new collection id
                // select the last edit button
                const editButton = document.querySelectorAll('.edit-button').item(document.querySelectorAll('.edit-button').length - 1);
                editButton.dataset.collection_id = data.id;
            })
            .catch(error => {
                console.error('Error saving changes:', error);
            });
    }
}

function exitEditingMode(collectionCard) {
    const collectionName = collectionCard.querySelector('.collection-name');
    const collectionNameDisplay = collectionCard.querySelector('.collection-name-display');
    const collectionNameInput = collectionCard.querySelector('.collection-name-input');
    const visibilityCheckbox = collectionCard.querySelector('.visibility-checkbox');
    const editButton = collectionCard.querySelector('.edit-button');

    // Disable the checkbox and update the display text
    visibilityCheckbox.disabled = true;
    collectionNameDisplay.textContent = collectionNameInput.value;

    // Exit editing mode
    collectionName.classList.remove('editing');

    // Change the edit button icon back to the pen
    editButton.innerHTML = '<i class="fa-regular fa-pen-to-square"></i>';
    editButton.setAttribute('aria-label', 'Edit collection');

    // Prepare data for the API call
    const collectionId = editButton.dataset.collection_id;
    const updatedName = collectionNameInput.value;
    const updatedVisibility = !visibilityCheckbox.checked; // `true` if private, `false` if public

    console.log('Saving changes:', { collectionId, updatedName, updatedVisibility });

    // Call your API here
    saveChangesToServer(collectionId, updatedName, updatedVisibility);
}

function updateEventListeners() {

    var visibilityCheckboxes = document.querySelectorAll('.visibility-checkbox');
    var editButtons = document.querySelectorAll('.edit-button');
    var deleteButtons = document.querySelectorAll('.delete-button');

    var newCollectionButton = document.getElementById('newCollection');
    var collectionsList = document.querySelector('.collections-list');

    visibilityCheckboxes.forEach(checkbox => {
        checkbox.addEventListener('change', function () {
            const visibilityIcon = checkbox.closest('.visibility-toggle').querySelector('.visibility-icon');
            const globeIcon = visibilityIcon.querySelector('.fa-globe');
            const lockIcon = visibilityIcon.querySelector('.fa-lock');
            const visibilityLabel = checkbox.closest('.visibility-toggle').querySelector('.visibility-label');

            if (!checkbox.checked) {
                // Switch to private state
                globeIcon.classList.add('hidden');
                lockIcon.classList.remove('hidden');
                visibilityLabel.textContent = 'Privat';
            } else {
                // Switch to public state
                lockIcon.classList.add('hidden');
                globeIcon.classList.remove('hidden');
                visibilityLabel.textContent = 'Publik';
            }
            // Optionally, save the updated visibility state to the server here
        });
    });


    editButtons.forEach(button => {
        button.addEventListener('click', function () {
            const collectionCard = button.closest('.collection-card');
            const collectionName = collectionCard.querySelector('.collection-name');
            const collectionNameDisplay = collectionCard.querySelector('.collection-name-display');
            const collectionNameInput = collectionCard.querySelector('.collection-name-input');
            const visibilityCheckbox = collectionCard.querySelector('.visibility-checkbox');

            // Toggle editing state
            const isEditing = collectionName.classList.toggle('editing');

            if (isEditing) {
                // Enter editing mode
                visibilityCheckbox.disabled = false;
                collectionNameInput.focus();
                collectionNameInput.select();

                // Change the edit button icon to a checkmark
                button.innerHTML = '<i class="fa-regular fa-square-check"></i>';
                button.setAttribute('aria-label', 'Save changes');
            } else {
                // Exit editing mode
                exitEditingMode(collectionCard);
            }
        });
    });

    deleteButtons.forEach(button => {
        button.addEventListener('click', e => {
            const collectionCard = button.closest('.collection-card');

            const editButton = collectionCard.querySelector('.edit-button');

            // Optionally, delete the collection from the server here
            const collectionId = editButton.dataset.collection_id;
            console.log('Deleting collection:', { collectionId });
            
            // Remove the collection from the DOM
            collectionCard.remove();

            fetch(`/api/v1/collections/${collectionId}`, {
                method: 'DELETE',
            })
                .then(response => {
                    console.log('Collection deleted successfully:', response);
                })
                .catch(error => {
                    console.error('Error deleting collection:', error);
                });
        });
    })

    newCollectionButton.addEventListener('click', function () {
        // Create a new collection element
        const newCollection = createNewCollectionElement();
        // Add the new collection to the collections list
        collectionsList.appendChild(newCollection);

        updateEventListeners();


        // Focus the input field
        const newCollectionInput = newCollection.querySelector('.collection-name-input');
        newCollectionInput.focus();
        newCollectionInput.select();
    });
}

if (visibilityCheckboxes.length > 0) {

    updateEventListeners();
}