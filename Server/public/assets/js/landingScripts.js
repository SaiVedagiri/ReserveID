let Qpositions = [];
let Qusers = [];
let Qnames = [];
let Qtimes = [];
let Qemails = [];
let Ctimestamp = [];
let Cusers = [];
let Cnames = [];
let Ctimes = [];
let Cemails = [];
let Susers = [];
let Snames = [];
let Semails = [];
let Stimestamps = [];
let deadlines = [];

firebase.database().ref("queue").orderByChild("position").on("child_added", function (snapshot, prevChildKey) {
    var newPost = snapshot.val();
    if (newPost.position != undefined) {
        Qpositions.push(newPost.position);
        Qusers.push(newPost.user);
        PopulateQueue();
    }
});

firebase.database().ref("inStore").orderByChild("user").on("child_added", function (snapshot, prevChildKey) {
    var newPost = snapshot.val();
    if (newPost.user != undefined) {
        Cusers.push(newPost.user);
        Ctimestamp.push(newPost.time)
        PopulateCurrentShoppers();
    }
});
firebase.database().ref("scheduled").orderByChild("user").on("child_added", function (snapshot, prevChildKey) {
    var newPost = snapshot.val();
    if (newPost.user != undefined) {
        Susers.push(newPost.user);
        Stimestamps.push(newPost.date);
        PopulateSchedule();
    }
});


async function getUsers() {
    Qnames = [];
    Qemails = [];
    for (var x = 0; x < Qusers.length; x++) {
        let myVal3 = await firebase.database().ref(`users/${Qusers[x]}`).once("value");
        myVal3 = myVal3.val();
        Qnames.push(myVal3.name)
        Qemails.push(myVal3.email)
    }
}

async function getShoppers() {
    Cnames = [];
    Cemails = [];

    for (var x = 0; x < Cusers.length; x++) {
        let myVal3 = await firebase.database().ref(`users/${Cusers[x]}`).once("value");
        myVal3 = myVal3.val();
        if (myVal3 != null) {
            console.log(myVal3.name);
            Cnames.push(myVal3.name)
            Cemails.push(myVal3.email)
        } else {
            console.log(myVal3)
        }

    }
}

async function getSchedules() {
    Snames = [];
    Semails = [];
    for (var x = 0; x < Susers.length; x++) {
        let myVal3 = await firebase.database().ref(`users/${Susers[x]}`).once("value");
        myVal3 = myVal3.val();
        Snames.push(myVal3.name)
        Semails.push(myVal3.email)
    }
}

async function PopulateQueue() {
    await getUsers();

    $("#queue tr").remove();

    var tablestring = "";
    tablestring += "<tr> <th>Position</th><th>Customer Name</th><th>Customer Email</th>"
    console.log(Qnames);
    for (var x = 0; x < Qpositions.length; x++) {
        tablestring += "<tr>" + "<td>" + Qpositions[x] + "</td>" + "<td>" + Qnames[5 * x] + "</td>" + "<td>" + Qemails[5 * x] + "</td>"
    }
    $("#queue tbody").append(
        tablestring
    );
}

async function PopulateCurrentShoppers() {
    await getShoppers();

    $("#current tr").remove();

    var tablestring = "";
    tablestring += "<tr> <th>Customer Name</th><th>Customer Email</th><th>Date/Time Entered</th><th>Time Left</th>"

    for (var c = 0; c < Ctimestamp.length; c++) {
        //console.log(Cnames);
        tablestring += "<tr>" + "<td>" + Cnames[4 * c] + "</td>" + "<td>" + Cemails[4 * c] + "</td>" + "<td>" + Ctimestamp[c] + "</td>" + `<td id=time${c}>` + "</td>";
        var deadline = new Date(Ctimestamp[c]).getTime();
        deadlines.push(deadline);
    }
    setInterval(function () {
        for (num = 0; num < Ctimestamp.length; num++) {
            var now = new Date().getTime();
            var t = deadlines[num] - now;
            var days = Math.floor(t / (1000 * 60 * 60 * 24));
            var hours = Math.floor((t % (1000 * 60 * 60 * 24)) / (1000 * 60 * 60));
            var minutes = Math.floor((t % (1000 * 60 * 60)) / (1000 * 60));
            var seconds = Math.floor((t % (1000 * 60)) / 1000);
            seconds = 60 - Math.abs(seconds);

            if (days == -1 && hours == -1) {
                document.getElementById(`time${num}`).innerHTML = minutes + 30 + "m " + seconds + "s ";
            }
            if (minutes + 30 < 0 || days < -1 || hours < -1) {
                //clearInterval(num);
                document.getElementById(`time${num}`).innerHTML = "EXPIRED";
            } else if (minutes + 30 >= 30 || days > -1 || hours > -1) {
                //clearInterval(num);
                document.getElementById(`time${num}`).innerHTML = "INVALID";
            }
        }
    }, 1000);
    $("#current tbody").append(
        tablestring
    );
}

async function PopulateSchedule() {
    await getSchedules();

    $("#schedule tr").remove();

    var tablestring = "";
    tablestring += "<tr> <th>Customer Name</th><th>Customer Email</th><th>Scheduled Date/Time</th>"

    for (var x = 0; x < Snames.length; x++) {
        tablestring += "<tr>" + "<td>" + Snames[x] + "</td>" + "<td>" + Semails[x] + "</td>" + "<td>" + Stimestamps[x] + "</td>"
    }
    $("#schedule tbody").append(
        tablestring
    );
}