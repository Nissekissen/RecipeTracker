
const modal = document.getElementById('saveRecipeModal');

let openBtns = document.querySelectorAll('.save-recipe');

const recipeIdElement = document.getElementById('recipeId');

// const closeBtn = document.getElementById('closeSaveRecipeModal');



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
    return item ? item : [];
}

function getCollectionsFromLocalStorage() {

    const item = JSON.parse(localStorage.getItem('collections'));
    return item ? item : [];
}

function getCollectionsFromAPI() {
    return fetch('/api/v1/collections', { method: 'GET' })
        .then(response => response.json());
}

function updateSaveBtns(data, updateId) {
    // If collectionId is set, then we update the save button for that collection
    const collectionRows = document.querySelectorAll('.modal-row');
    collectionRows.forEach(collectionRow => {
        const saveBtn = collectionRow.querySelector('.save-btn');
        const collectionId = collectionRow.dataset.collectionId;
        // console.log("Collection id", collectionId);
        const saved = data.find(saved => saved.collection_id === parseInt(collectionId));
        if (updateId && collectionId === updateId) {
            saved.saved = !saved.saved;
        }
        saveBtn.dataset.clicked = saved.saved ? 'true' : 'false';
        if (saved.saved) {
            saveBtn.innerHTML = `<img src="/assets/svg/bookmark-fill.svg" alt="Save">`;
        } else {
            saveBtn.innerHTML = `<img src="/assets/svg/bookmark.svg" alt="Save">`;
        }
    })
}

function saveCollectionsToLocalStorage(collections) {
    localStorage.clear();
    localStorage.setItem('collections', JSON.stringify(collections));
}

function showGroups() {

    document.getElementById('newCollectionBtn').style.display = 'none';
    document.getElementById('newCollectionInput').classList.remove('show');


    const groups = getCollectionsFromLocalStorage();

    if (groups.length === 0) {
        return;
    }

    const collectionsSelect = document.querySelector('.modal-rows');
    collectionsSelect.innerHTML = '';

    groups.forEach(group => {
        const groupElement = document.createElement('button');
        groupElement.classList.add('modal-row', 'group-row');
        groupElement.appendChild(document.createTextNode(group.name));
        collectionsSelect.appendChild(groupElement);

        const arrow = document.createElement('img');
        arrow.src = '/assets/svg/arrow_right.svg';
        arrow.classList.add('modal-arrow');

        groupElement.appendChild(arrow);

        groupElement.addEventListener('click', () => {
            getSavedRecipes(recipeIdElement.value).then(updateSaveBtns);
            localStorage.setItem('showing', 'collections');
            showCollections(group.id);
        })
    });
}

function showCollections(groupId) {
    document.getElementById('newCollectionBtn').style.display = 'flex';
    document.getElementById('newCollectionInput').classList.remove('show');

    
    const groups = getCollectionsFromLocalStorage();
    
    if (groupId == "null") {
        groupId = groups[0].id;
    }

    const group = groups.find(group => group.id == groupId);


    localStorage.setItem('groupId', groupId);


    if (!group) {
        return;
    }

    const collections = group.collections;
    const collectionsSelect = document.querySelector('.modal-rows');
    collectionsSelect.innerHTML = '';

    collections.forEach(collection => {
        const collectionElement = document.createElement('div');
        collectionElement.classList.add('modal-row');
        collectionElement.appendChild(document.createTextNode(collection.name));
        collectionElement.dataset.collectionId = collection.id;


        collectionsSelect.appendChild(collectionElement);

        const saveBtn = document.createElement('button');
        saveBtn.classList.add('save-btn');
        saveBtn.innerHTML = `<img src="/assets/svg/bookmark.svg" alt="Save">`;
        
        saveBtn.addEventListener('click', () => {
            const recipeId = recipeIdElement.value;
            const url = `/api/v1/recipes/${recipeId}/save?collection_id=${collection.id}`;
            saveBtn.dataset.clicked = saveBtn.dataset.clicked === 'true' ? 'false' : 'true';
            if (saveBtn.dataset.clicked === 'true') {
                saveBtn.innerHTML = `<img src="/assets/svg/bookmark-fill.svg" alt="Save">`;
            } else {
                saveBtn.innerHTML = `<img src="/assets/svg/bookmark.svg" alt="Save">`;
            }
            fetch(url, { method: 'GET' })
                .then(response => {
                    if (response.status < 200 || response.status >= 300) {
                        console.log("Error");
                    }

                })
        });



        collectionElement.appendChild(saveBtn);
    });
}


const collections = getCollectionsFromAPI()
    .then(collections => {
        saveCollectionsToLocalStorage(collections);
    });

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

    const groupId = localStorage.getItem('groupId');

    fetch(`/api/v1/collections?name=${newCollectionName}&group_id=${groupId}`, { method: 'POST' })
        .then(response => {
            if (response.status < 200 || response.status >= 300) {
                console.log("Error");
            }
            return response.json();
        })
        .then(collection => {
            const groups = getCollectionsFromLocalStorage();
            
            let group = groups.find(group => group.id === parseInt(groupId));

            if (!group) {
                group = groups[0];
            }

            group.collections.push(collection);
            saveCollectionsToLocalStorage(groups);

            document.getElementById('newCollectionBtn').style.display = 'flex';
            document.getElementById('newCollectionInput').classList.remove('show');

            showCollections(groupId);
        })
});

function updateOpenBtns() {
    openBtns = document.querySelectorAll('.save-recipe');
    
    openBtns.forEach(openBtn => openBtn.addEventListener('click', () => {
        modal.style.display = 'block';
        recipeIdElement.value = openBtn.dataset.recipeid;
        
        // go through all save buttons and check if the recipe is saved
        
        // getSavedRecipes(recipeIdElement.value).then(updateSaveBtns);
        localStorage.setItem('showing', 'groups');
        showGroups();
        
    }))
}

function getCurrentGroup() {
    console.log('test')
    // If the current page is a group, then return the group id. If it is showing a profile page, return 'private' and otherwise return 'public'
    // Get from url
    const url = window.location.href;
    const urlParts = url.split('/');
    if (urlParts.includes('groups')) {
        return urlParts[urlParts.indexOf('groups') + 1];
    } else if (urlParts.includes('profile')) {
        return 'private';
    } else {
        return 'public';
    }
}

document.querySelectorAll('.img-wrapper a').forEach(element => {
    element.href += `?group=${getCurrentGroup()}`;
});

updateOpenBtns();