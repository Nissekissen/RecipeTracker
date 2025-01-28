
function createInvite() {
    var groupId = document.getElementById("groupId").value;
    var uses = document.getElementById("uses").value;

    var invite = {
        group_id: groupId,
        uses: uses
    }

    fetch('/api/v1/invites', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify(invite)
    }).then(res => {
        if (res.status == 200) {
            return res.json();
        } else {
            console.log("error");
        }
    }).then(data => {
        console.log(data);
        if (data == undefined) {
            return;
        }

        // Show the invite code row
        document.getElementById("inviteCodeRow").style.display = "block";
        document.getElementById("inviteCode").value = `http://localhost:9292/invite/${data.token}`;
    })
}

function copyCode() {
    var copyText = document.getElementById("inviteCode");
    navigator.clipboard.writeText(copeText.value)
}

document.getElementById('createInviteForm').addEventListener('submit', function (e) {
    e.preventDefault();
    createInvite();
});