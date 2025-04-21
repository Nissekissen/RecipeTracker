// Helps choosing image for user and groups

function chooseImage() {
    var imageUrl = document.getElementById("image").value;
    var image = document.getElementById("imagePreview");
    var imageInput = document.getElementById("imageInput");

    var nextBtn = document.getElementById("nextBtn");

    checkurl(imageUrl).then((isImage) => {
        console.log("is image", isImage);
        if (!isImage) {
            image.src = "/gray.png"
            imageInput.value = ""
            nextBtn.classList.remove('btn--primary');
            nextBtn.classList.add('btn--secondary');
            nextBtn.value = "Hoppa över"
        } else {
            image.src = imageUrl;
            imageInput.value = imageUrl;
            nextBtn.classList.remove('btn--secondary');
            nextBtn.classList.add('btn--primary');
            nextBtn.value = "Nästa"
        }

    });
}

async function checkImage(url) {

    let res, buff;

    try {

        res = await fetch(url, { mode: 'no-cors' });
        buff = await res.blob();
    } catch (error) {
        return false;
    }

    return buff.type.startsWith('image/')

}

const checkurl = async (url) => {
    return new Promise((resolve, reject) => {
        if (url.trim() == "") {
            resolve(false)
        }
        fetch(url, { mode: 'no-cors' }).then(res => {
            const img = new Image();
            img.src = url;
            img.onload = () => {
                console.log(res.status, img.width)
                if ((res.status == 200 || res.status == 0) && !(img.width == 0)) {
                    resolve(true)
                } else {
                    resolve(false)
                }
            }
        })
            .catch(e => {
                resolve(false)
            })
    })
}