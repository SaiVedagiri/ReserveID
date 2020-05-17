errorBox = document.querySelector("#error");

async function onSuccess(googleUser) {
    let profile = googleUser.getBasicProfile();
    let userData;
    for (key in googleUser) {
        if (googleUser[key].access_token != undefined) {
            localStorage.setItem('access_token', googleUser[key].access_token);
        }
    }
    await axios({
        method: 'POST',
        url: 'https://reserveid.macrotechsolutions.us:9146/http://localhost/managerGoogleSignIn',
        headers: {
            'Content-Type': 'application/json',
            'email': profile.getEmail(),
            'name': profile.getName()
        }
    })
        .then(data => userData = data.data)
        .catch(err => console.log(err))
    sessionStorage.setItem('userKey', userData.userkey);
    gapi.auth2.getAuthInstance().signOut();
    window.location.href = "landing.html";
}

function onFailure(error) {
    console.log(error);
}

function renderButton() {
    gapi.signin2.render('my-signin2', {
        'scope': 'profile email',
        'width': 240,
        'height': 50,
        'longtitle': true,
        'theme': 'dark',
        'onsuccess': onSuccess,
        'onfailure': onFailure
    });
}

async function login() {
    event.preventDefault();
    let email = document.querySelector("#emailInput").value.toLowerCase();
    let password = document.querySelector("#passwordInput").value;
    let result;
    await axios({
        method: 'POST',
        url: 'https://reserveid.macrotechsolutions.us:9146/http://localhost/managerSignIn',
        headers: {
            'Content-Type': 'application/json',
            'email': email,
            'password': password
        }
    })
        .then(data => result = data.data)
        .catch(err => console.log(err))
    if (result.data == "Incorrect Password") {
        errorBox.innerText = "Incorrect Password";
    } else if (result.data == "Incorrect email address.") {
        errorBox.innerText = "Incorrect email address.";
    } else {
        sessionStorage.setItem('userKey', result.data);
        window.location.href = "landing.html";
    }
}