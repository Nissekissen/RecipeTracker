var textarea = document.getElementById('notes');
var statusDisplay = document.getElementById('status-display');
let timeoutId;

// Function to handle reply button clicks
function handleReplyClick(event) {
    event.preventDefault(); // Prevent default form submission

    // Get the parent comment
    const parentComment = event.target.closest('.comment');
    const parentCommentId = parentComment.dataset.comment_id; // Use a unique ID for the parent comment

    // Check if a reply form already exists
    const existingReplyForm = parentComment.querySelector('.reply-form');
    if (existingReplyForm) {
        existingReplyForm.remove(); // Remove the existing reply form
        return; // Exit the function
    }

    // Create a reply form
    const replyForm = document.createElement('form');
    replyForm.classList.add('comment-form', 'reply-form');
    replyForm.setAttribute('action', '/comments');
    replyForm.setAttribute('method', 'post');
    replyForm.innerHTML = `
      <div class="form-row">
        <textarea name="body" placeholder="Write a reply..." required></textarea>
        <button type="submit">Post</button>
      </div>
    `;

    // Handle reply form submission
    replyForm.addEventListener('submit', (e) => {
        e.preventDefault();
        const replyText = replyForm.querySelector('textarea').value;

        // Send a POST request to the server
        fetch(`/api/v1/recipes/${getRecipeId()}/comments`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify({
                parent_id: parentCommentId,
                content: replyText,
                group_id: getCurrentGroup(),
            }),
        })
            .then(response => response.text())
            .then(data => {
                // The data object contains the new reply as HTML

                // Get the correct reply container
                let replyContainer = parentComment.querySelector('.nested-comments');

                // If the reply container doesn't exist, create it
                if (!replyContainer) {
                    replyContainer = document.createElement('div');
                    replyContainer.classList.add('nested-comments');
                    parentComment.appendChild(replyContainer);
                }

                // Append the new reply to the reply container
                replyContainer.innerHTML += data;

                // Update event listeners for reply buttons
                updateEventListeners();
            })
            .catch(error => {
                console.error('Error posting reply:', error);
            });

        // Remove the reply form after submission
        replyForm.remove();
    });

    // Append the reply form below the parent comment
    parentComment.appendChild(replyForm);
}

function handleDeleteClick(event) {

    // Get the comment
    const comment = event.target.closest('.comment');
    const commentId = comment.dataset.comment_id;

    // Send a DELETE request to the server
    fetch(`/api/v1/recipes/${getRecipeId()}/comments/${commentId}`, {
        method: 'DELETE',
    })
        .then(response => response.text())
        .then(data => {
            // The data object contains the deleted comment as HTML

            // Remove the comment from the DOM
            comment.remove();
        })
        .catch(error => {
            console.error('Error deleting comment:', error);
        });
}

function getCurrentGroup() {
    return document.querySelector('.group-select').value;
}

function getRecipeId() {
    return document.querySelector('.recipe').dataset.recipe_id;
}

function updateEventListeners() {
    // Add event listeners to all reply buttons
    const replyButtons = document.querySelectorAll('.reply-btn');
    replyButtons.forEach(button => {
        button.addEventListener('click', handleReplyClick);
    });

    // Add event listeners to all delete buttons
    const deleteButtons = document.querySelectorAll('.delete-btn');
    deleteButtons.forEach(button => {
        button.addEventListener('click', handleDeleteClick);
    });

    textarea = document.getElementById('notes');
    statusDisplay = document.getElementById('status-display');

    if (textarea == undefined) return;
    textarea.addEventListener('input', debounceSave);
}


async function changeGroup(group) {
    // Get the comments container
    const recipeId = document.querySelector('.recipe').dataset.recipe_id;
    
    const response = await fetch(`/api/v1/recipes/${recipeId}/comments?group_id=${group}`)

    if (response.status !== 200) {
        document.querySelector('.comment-list').innerHTML = '<div class="error-content"><p>Ett fel uppstod.</p></div>';
        return;
    }
    
    const data = await response.text();

    const commentsContainer = document.querySelector('.comment-list');
    commentsContainer.innerHTML = data;

    if (group === 'private') {
        // Hide add comment form
        document.querySelector('.comment-form').style.display = 'none';
    } else {
        // Show add comment form
        document.querySelector('.comment-form').style.display = 'block';
    }

    // Update the add comment form's group_id
    document.getElementById('addCommentGroupID').value = group;

    // Update event listeners for reply buttons
    updateEventListeners();
}

async function handleNoteFormSubmit(e) {
    e.preventDefault();

    const recipeId = document.querySelector('.recipe').dataset.recipe_id;
    const notes = document.getElementById('notes').value;

    const response = await fetch(`/api/v1/recipes/${recipeId}/comments`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
        },
        body: JSON.stringify({
            content: notes,
            group_id: 'private'
        }),
    });
}

function saveContent() {
    const content = textarea.value;
    const recipeId = document.querySelector('.recipe').dataset.recipe_id;

    fetch(`/api/v1/recipes/${recipeId}/comments`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
        },
        body: JSON.stringify({
            content: content,
            group_id: 'private'
        }),
    })
    .then(() => {
        statusDisplay.textContent = 'Sparat!';
        setTimeout(() => { statusDisplay.textContent = ''; }, 1000);
    })
    .catch(() => {
        statusDisplay.textContent = 'Kunde inte spara';
    });
}

function debounceSave() {
    clearTimeout(timeoutId);
    statusDisplay.textContent = 'Sparar...';
    timeoutId = setTimeout(saveContent, 1000);
}

setTimeout(async () => {
    // Get group from URL param "group" or default to "public"

    const urlParams = new URLSearchParams(window.location.search);
    const group = urlParams.get('group') || 'public';

    document.querySelector('.group-select').value = group;

    changeGroup(group);
}, 100)
