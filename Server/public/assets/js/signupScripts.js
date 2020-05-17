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

async function signup() {
    event.preventDefault();
    let email = document.querySelector("#emailInput").value.toLowerCase();
    let firstName = document.querySelector("#firstName").value;
    let lastName = document.querySelector("#lastName").value;
    let password = document.querySelector("#passwordInput").value;
    let passwordConfirm = document.querySelector("#passwordConfirm").value;
    let result;
    await axios({
        method: 'POST',
        url: 'https://reserveid.macrotechsolutions.us:9146/http://localhost/managerSignUp',
        headers: {
            'Content-Type': 'application/json',
            'email': email,
            'firstname': firstName,
            'lastname': lastName,
            'password': password,
            'passwordconfirm': passwordConfirm,
        }
    })
        .then(data => result = data.data)
        .catch(err => console.log(err))
    if (result.data == "Email already exists.") {
        errorBox.innerText = 'Email already exists.';
    } else if (result.data == "Please enter an email address.") {
        errorBox.innerText = 'Please enter an email address.';
    } else if (result.data == 'Invalid Name') {
        errorBox.innerText = 'Invalid Name';
    } else if (result.data == 'Invalid email address.') {
        errorBox.innerText = 'Invalid email address.';
    } else if (result.data == 'Your password needs to be at least 6 characters.') {
        errorBox.innerText = 'Your password needs to be at least 6 characters.';
    } else if (result.data == 'Your passwords don\'t match.') {
        errorBox.innerText = 'Your passwords don\'t match.';
    } else {
        sessionStorage.setItem('userKey', result.data);
        window.location.href = "landing.html";
    }
}