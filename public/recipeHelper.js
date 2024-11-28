document.querySelectorAll('.recipe-brief-btn').forEach(btn => {

    // Set them to clicked if they are bookmarked
    // Get whether the recipe is bookmarked from GET /recipes/:id/bookmark

    if (btn.dataset.name === 'bookmark') {
        const recipeId = btn.dataset.recipe_id
        const url = `/recipes/${recipeId}/bookmark`

        fetch(url)
            .then(response => response.json())
            .then(data => {
                if (data.bookmarked) {
                    btn.src = '/bookmark_hover.svg'
                    btn.dataset.clicked = 'true'
                }
            })
    }

    // btn.addEventListener('mouseenter', () => {
    //     console.log('pluh')
    //     if (btn.dataset.clicked === 'true') {
    //         return;
    //     }
    //     btn.src = `/${btn.dataset.name}_hover.svg`
    // })

    // btn.addEventListener('mouseleave', () => {
    //     if (btn.dataset.clicked === 'true') {
    //         return;
    //     }
    //     btn.src = `/${btn.dataset.name}.svg`
    // })

    if (btn.dataset.name === 'bookmark') {
        btn.addEventListener('click', () => {
            const recipeId = btn.dataset.recipe_id
            const url = `/recipes/${recipeId}/bookmark`

            if (btn.dataset.clicked === 'true') {
                btn.src = '/bookmark.svg'
                btn.dataset.clicked = 'false'
                fetch(url, { method: 'DELETE' })
                    .catch(err => {
                        console.error(err)
                        btn.src = '/bookmark_hover.svg'
                        btn.dataset.clicked = 'true'
                    })
                return;
            }

            btn.src = '/bookmark_hover.svg'
            btn.dataset.clicked = 'true'
            fetch(url, { method: 'POST' })
                .catch(err => {
                    console.error(err)
                    btn.src = '/bookmark.svg'
                    btn.dataset.clicked = 'false'
                    
                })
        })
    }
})