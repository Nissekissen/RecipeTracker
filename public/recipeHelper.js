
const modal = document.getElementById('saveRecipeModal');

const openBtns = document.querySelectorAll('.save-recipe');

const recipeIdElement = document.getElementById('recipeId');

// const closeBtn = document.getElementById('closeSaveRecipeModal');

openBtns.forEach(openBtn => openBtn.addEventListener('click', () => {
    modal.style.display = 'block';
    recipeIdElement.value = openBtn.dataset.recipeid;

    // go through all save buttons and check if the recipe is saved

    getSavedRecipes(recipeIdElement.value).then(savedData => {
        const collectionRows = document.querySelectorAll('.modal-row');
        collectionRows.forEach(collectionRow => {
            const saveBtn = collectionRow.querySelector('.save-btn');
            const collectionId = collectionRow.dataset.collectionId;
            console.log(savedData);
            const saved = savedData.find(saved => saved.collection_id === parseInt(collectionId));
            console.log(saved.saved);
            saveBtn.dataset.clicked = saved.saved ? 'true' : 'false';
            if (saved.saved) {
                saveBtn.innerHTML = `<img src="/bookmark-fill.svg" alt="Save">`;
            } else {
                saveBtn.innerHTML = `<img src="/bookmark.svg" alt="Save">`;
            }
        })
    })


    // const saveBtns = document.querySelectorAll('.save-btn');
    // saveBtns.forEach(saveBtn => {
    //     getSavedRecipes(recipeIdElement.value).then(saved => {
    //         saved.forEach(collection => {
    //             if (collection.collection_id === saveBtn.dataset.collectionId)
    //         }
    //         console.log("Recipe: " + recipeIdElement.value + ", saved: " + saved)
    //         saveBtn.dataset.clicked = saved ? 'true' : 'false';
    //         if (saved) {
    //             saveBtn.innerHTML = `<img src="/bookmark-fill.svg" alt="Save">`;
    //         } else {
    //             saveBtn.innerHTML = `<img src="/bookmark.svg" alt="Save">`;
    //         }
    //     })
    // });

}))

// closeBtn.addEventListener('click', () => {
//     modal.style.display = 'none';
// })

window.addEventListener('click', (e) => {
    if (e.target === modal) {
        modal.style.display = 'none';
    }
})


async function getSavedRecipes(recipeId) {
    return fetch(`/api/v1/recipes/${recipeId}/saved`, { method: 'GET' })
        .then(response => response.json())
}

function getCollectionsFromInput() {
    const item = JSON.parse(document.getElementById('collections').value);
    console.log("Getting from input: ");
    console.log(item);
    return item ? item : [];
}

function getCollectionsFromLocalStorage() {

    const item = JSON.parse(localStorage.getItem('collections'));
    console.log("Getting from local storage: ");
    console.log(item);
    return item ? item : [];
}

function updateSaveBtns(collectionId) {
    // Collection id is the id of the collection that was saved
    // clear all save buttons and update the one that was saved
    const collectionRows = document.querySelectorAll('.modal-row');
    collectionRows.forEach(collectionRow => {
        const saveBtn = collectionRow.querySelector('.save-btn');
        if (collectionRow.dataset.collectionId == collectionId) {
            saveBtn.dataset.clicked = 'true';
            saveBtn.innerHTML = `<img src="/bookmark-fill.svg" alt="Save">`;
        } else {
            saveBtn.dataset.clicked = 'false';
            saveBtn.innerHTML = `<img src="/bookmark.svg" alt="Save">`;
        }
    })
}

function saveCollectionsToLocalStorage(collections) {
    console.log("Saving to local storage: ");
    console.log(collections);
    localStorage.clear();
    localStorage.setItem('collections', JSON.stringify(collections));
}

function updateCollections(collections) {
    const collectionsSelect = document.querySelector('.modal-rows');
    collectionsSelect.innerHTML = '';
    collections.forEach(collection => {
        const option = document.createElement('div');
        option.classList.add('modal-row');
        option.dataset.collectionId = collection.id
        option.appendChild(document.createTextNode(collection.name));

        const saveBtn = document.createElement('button');
        saveBtn.classList.add('save-btn');
        saveBtn.innerHTML = `<img src="/bookmark.svg" alt="Save">`;

        saveBtn.addEventListener('click', () => {
            const recipeId = recipeIdElement.value;
            const url = `/api/v1/recipes/${recipeId}/save?collection_id=${collection.id}`;
            saveBtn.dataset.clicked = saveBtn.dataset.clicked === 'true' ? 'false' : 'true';
            if (saveBtn.dataset.clicked === 'true') {
                updateSaveBtns(collection.id);
            } else {
                updateSaveBtns(null);
            }
            fetch(url, { method: 'GET' })
                .then(response => {
                    if (response.status < 200 || response.status >= 300) {
                        console.log("Error");
                        // if (saveBtn.dataset.clicked === 'true') {
                        //     saveBtn.innerHTML = `<img src="/bookmark-fill.svg" alt="Save">`;
                        // } else {
                        //     saveBtn.innerHTML = `<img src="/bookmark.svg" alt="Save">`;
                        // }
                    }
                })



        });
        option.appendChild(saveBtn);

        collectionsSelect.appendChild(option);
    })
}

const collections = getCollectionsFromInput();
saveCollectionsToLocalStorage(collections);
updateCollections(collections);

document.getElementById('newCollectionBtn').addEventListener('click', () => {
    // Hide new collection button and show input field

    document.getElementById('newCollectionBtn').style.display = 'none';
    document.getElementById('newCollectionInput').classList.add('show');
});

document.getElementById('addCollectionBtn').addEventListener('click', () => {
    // Hide input field and show new collection button

    const newCollectionInput = document.getElementById('collectionName');
    const newCollectionName = newCollectionInput.value;
    if (newCollectionName === '') {
        return;
    }

    fetch(`/api/v1/collections?name=${newCollectionName}`, { method: 'POST' })
        .then(response => {
            if (response.status < 200 || response.status >= 300) {
                console.log("Error");
            }
            return response.json();
        })
        .then(collection => {
            const collections = getCollectionsFromLocalStorage();
            collections.push(collection);
            saveCollectionsToLocalStorage(collections);
            updateCollections(collections);

            document.getElementById('newCollectionBtn').style.display = 'flex';
            document.getElementById('newCollectionInput').classList.remove('show');
        })
});