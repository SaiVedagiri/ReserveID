const express = require('express');
const bcrypt = require('bcryptjs');
var admin = require('firebase-admin');
var serviceAccount = require("./reserveid-firebase-adminsdk-oc3t2-c896c03845.json");
var path = require('path');
var bodyParser = require('body-parser');
const WebSocket = require('ws');
const http = require('http');
const PORT = process.env.PORT || 80;

const setTZ = require('set-tz');
setTZ('America/New_York');

var app = admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  databaseURL: "https://reserveid.firebaseio.com"
});

var database = admin.database();
database.ref('/queue').orderByChild('numOfPeople').limitToLast(1).on('child_changed', function (snapshot) {
  wss.clients.forEach(function each(client) {
    if (client.readyState === WebSocket.OPEN) {
      client.send(`queueNum=${snapshot.val()}`);
    }
  });
});
const server = http.createServer(function (req, res) {
  res.writeHead(200, { 'Content-Type': 'text/plain' });
  res.write('');
  res.end();
});
const wss = new WebSocket.Server({ server });
server.listen(1319);

wss.on('connection', function connection(ws) {
  ws.on('message', function incoming(message) {
    console.log('received: %s', message);
  });
});
let unlock = false;
async function checkUser() {
  await database.ref('inStore').orderByChild('numOfPeople').limitToLast(1).on('value', snapshot => {
    if (snapshot.val().numOfPeople == 1) {
      database.ref('scheduled').on('value', snapshot => {
        snapshot.forEach(function (childSnapshot) {
          if (childSnapshot.key != 'numOfPeople') {
            let date = new Date();
            date = Date.parse(date);
            let date1 = childSnapshot.val().date
            date1 = Date.parse(date1);
            database.ref('queue').on('value', snapshots => {
              snapshots.forEach(function (childSnapshots) {
                let position = childSnapshots.val().position
                if (position == 1 && (date <= (date1 - 1800000))) {
                  let user = childSnapshots.val().user
                  database.ref(`/users/${user}`).update({
                    ready: 'true'
                  })
                  wss.clients.forEach(function each(client) {
                    if (client.readyState === WebSocket.OPEN) {
                      client.send(`${user}`);
                    }
                  });
                }
              })
            })
          }
        })
      })
    } else if (snapshot.val().numOfPeople == 0) {
      database.ref('scheduled').on('value', snapshot => {
        snapshot.forEach(function (childSnapshot) {
          if (childSnapshot.key != 'numOfPeople') {
            let date = new Date();
            date = Date.parse(date);
            let date1 = childSnapshot.val().date
            date1 = Date.parse(date1);
            database.ref('queue').on('value', snapshots => {
              snapshots.forEach(function (childSnapshots) {
                let position = childSnapshots.val().position
                if ((position == 1 || position == 2) && (date <= (date1 - 1800000))) {
                  let user = childSnapshots.val().user
                  database.ref(`/users/${user}`).update({
                    ready: 'true'
                  })
                  wss.clients.forEach(function each(client) {
                    if (client.readyState === WebSocket.OPEN) {
                      client.send(`${user}`);
                    }
                  });
                }
              })
            })
          }
        })
      })
    } else {
      console.log('No user can enter')
    }
  });
}
checkUser();
express()
  .use(express.static(path.join(__dirname, 'public')))
  .use(bodyParser.urlencoded({ extended: false }))
  .set('views', path.join(__dirname, 'views'))
  .set('view engine', 'ejs')
  .post('/managerGoogleSignIn', async function (req, res) {
    res.setHeader('Access-Control-Allow-Origin', 'https://reserveid.macrotechsolutions.us');
    res.setHeader('Access-Control-Allow-Methods', 'GET, POST, OPTIONS, PUT, PATCH, DELETE');
    let profile = req.headers;
    let email = profile.email;
    let name = profile.name;
    let myVal = await database.ref("managers").orderByChild('email').equalTo(email).once("value");
    myVal = myVal.val();
    if (!myVal) {
      database.ref("managers").push({
        email: email,
        password: "",
        name: name
      });
    }
    myVal = await database.ref("managers").orderByChild('email').equalTo(email).once("value");
    myVal = myVal.val();
    for (key in myVal) {
      userKey = key;
    }
    let returnVal = {
      userkey: userKey
    }
    res.send(returnVal);
  })
  .post('/joinQueue', async function (req, res) {
    res.setHeader('Access-Control-Allow-Origin', 'https://reserveid.macrotechsolutions.us');
    res.setHeader('Access-Control-Allow-Methods', 'GET, POST, OPTIONS, PUT, PATCH, DELETE');
    let user = req.headers.userkey;
    let myVal9 = await database.ref("scheduled").orderByChild('user').equalTo(user).once("value");
    myVal9 = myVal9.val();
    if (myVal9) {
      res.send({
        position: "Invalid"
      });
    } else {
      let myVal = await database.ref("queue/numOfPeople").once("value");
      myVal = myVal.val();
      console.log(myVal);
      myVal++;
      database.ref('queue').update({
        numOfPeople: myVal
      })
      database.ref("queue").push({
        user: user,
        position: myVal
      });
      res.send({
        position: myVal
      });
    }
  })
  .post('/checkQueueStatus', async function (req, res) {
    res.setHeader('Access-Control-Allow-Origin', 'https://reserveid.macrotechsolutions.us');
    res.setHeader('Access-Control-Allow-Methods', 'GET, POST, OPTIONS, PUT, PATCH, DELETE');
    let user = req.headers.userkey;
    let myVal = await database.ref(`users/${user}`).orderByChild('user').equalTo(user).once("value");
    myVal = myVal.val();
    for (key in myVal) {
      res.send({
        status: myVal[key].ready
      });
    }
  })
  .post('/getQueueNum', async function (req, res) {
    res.setHeader('Access-Control-Allow-Origin', 'https://reserveid.macrotechsolutions.us');
    res.setHeader('Access-Control-Allow-Methods', 'GET, POST, OPTIONS, PUT, PATCH, DELETE');
    let myVal = await database.ref("queue").once("value");
    myVal = myVal.val();
    res.send({ queuenum: myVal["numOfPeople"].toString() });
  })
  .post('/leaveQueue', async function (req, res) {
    res.setHeader('Access-Control-Allow-Origin', 'https://reserveid.macrotechsolutions.us');
    res.setHeader('Access-Control-Allow-Methods', 'GET, POST, OPTIONS, PUT, PATCH, DELETE');
    let user = req.headers.userkey;
    let myVal = await database.ref("queue").orderByChild('user').equalTo(user).once("value");
    myVal = myVal.val();
    let position;
    for (key in myVal) {
      position = myVal[key].position
    }
    let myVal2 = await database.ref("queue/numOfPeople").once("value");
    myVal2 = myVal2.val();
    if (myVal2 > position) {
      for (i = position + 1; i <= myVal2; i++) {
        console.log(`i = ${i}`);
        let myVal3 = await database.ref('queue').orderByChild('position').equalTo(i).once("value");
        myVal3 = myVal3.val();
        for (key in myVal3) {
          database.ref(`queue/${key}/position`).set((i - 1));
        }
      }
    }
    for (key in myVal) {
      database.ref(`/queue/${key}`).remove();
    }
    database.ref('queue').update({
      numOfPeople: myVal2 - 1
    });
    res.send('Completed');
  })
  .post('/setupDevice', async function (req, res) {
    res.setHeader('Access-Control-Allow-Origin', 'https://reser.macrotechsolutions.us');
    res.setHeader('Access-Control-Allow-Methods', 'GET, POST, OPTIONS, PUT, PATCH, DELETE');
    let rfid = req.headers.rfid;
    let userid = req.headers.userid;
    let returnVal;
    if (!rfid || rfid == "") {
      returnVal = {
        data: "Please enter an RFID access code."
      }
    } else {
      database.ref(`users/${userid}/rfid`).set(rfid);
      returnVal = {
        data: "Success"
      }
    }
    res.send(returnVal);
  })
  .post('/getInfo', async function (req, res) {
    res.setHeader('Access-Control-Allow-Origin', 'https://reserveid.macrotechsolutions.us');
    res.setHeader('Access-Control-Allow-Methods', 'GET, POST, OPTIONS, PUT, PATCH, DELETE');
    let user = req.headers.userkey;
    let myVal = await database.ref("queue").once("value");
    let myVal2 = await database.ref("queue").orderByChild('user').equalTo(user).once("value");
    let myVal3 = await database.ref('/scheduled').orderByChild('user').equalTo(user).once('value');
    let status;
    myVal = myVal.val();
    myVal2 = myVal2.val();
    myVal3 = myVal3.val()
    await database.ref(`users/${user}`).once('value', function(snapshot) {
      status = snapshot.val().ready
    })
    if (!myVal2) {
      if (myVal3) {
        for (key in myVal3) {
          res.send({
            queuenum: myVal["numOfPeople"].toString(),
            buttontext: "Join Queue",
            schedule: "true",
            time: myVal3[key].date,
            status: status
          });
        }
      } else {
        res.send({
          queuenum: myVal["numOfPeople"].toString(),
          buttontext: "Join Queue",
          schedule: "false",
          status: status
        });
      }
    } else {
      for (key in myVal2) {
        res.send({
          queuenum: myVal["numOfPeople"].toString(),
          buttontext: "Leave Queue",
          position: myVal2[key].position,
          status: status
        });
      }
    }
  })
  .post('/userGoogleSignIn', async function (req, res) {
    res.setHeader('Access-Control-Allow-Origin', 'https://reserveid.macrotechsolutions.us');
    res.setHeader('Access-Control-Allow-Methods', 'GET, POST, OPTIONS, PUT, PATCH, DELETE');
    let profile = req.headers;
    let email = profile.email;
    let name = profile.name;
    let myVal = await database.ref("users").orderByChild('email').equalTo(email).once("value");
    myVal = myVal.val();
    if (!myVal) {
      database.ref("users").push({
        email: email,
        password: "",
        name: name
      });
    }
    myVal = await database.ref("users").orderByChild('email').equalTo(email).once("value");
    myVal = myVal.val();
    for (key in myVal) {
      userKey = key;
    }
    let returnVal = {
      userkey: userKey,
      name: name,
      email: email
    }
    res.send(returnVal);
  })
  .post('/managerSignIn', async function (req, res) {
    res.setHeader('Access-Control-Allow-Origin', 'https://reserveid.macrotechsolutions.us');
    res.setHeader('Access-Control-Allow-Methods', 'GET, POST, OPTIONS, PUT, PATCH, DELETE');
    let info = req.headers;
    let email = info.email;
    let password = info.password;
    let returnVal;
    let myVal = await database.ref("managers").orderByChild('email').equalTo(email).once("value");
    myVal = myVal.val();
    if (!myVal) {
      returnVal = {
        data: "Incorrect email address."
      }
    } else {
      let inputPassword = password;
      let userPassword;
      for (key in myVal) {
        userPassword = myVal[key].password;
      }
      if (bcrypt.compareSync(inputPassword, userPassword)) {
        for (key in myVal) {
          returnVal = {
            data: key
          }
        }
      } else {
        returnVal = {
          data: "Incorrect Password"
        }
      }
    }
    res.send(returnVal);
  })
  .post('/removeSchedule', async function (req, res) {
    res.setHeader('Access-Control-Allow-Origin', 'https://reserveid.macrotechsolutions.us');
    res.setHeader('Access-Control-Allow-Methods', 'GET, POST, OPTIONS, PUT, PATCH, DELETE');
    let user = req.headers.userkey;
    let myVal = await database.ref('scheduled').orderByChild('user').equalTo(user).once('value');
    let myVal2 = await database.ref('/scheduled').once('value');
    myVal2 = myVal2.val();
    myVal = myVal.val();
    for (key in myVal) {
      database.ref(`/scheduled/${key}`).remove();
    }
    if (myVal2.numOfPeople != 0) {
      database.ref('/scheduled').update({
        numOfPeople: myVal2.numOfPeople - 1
      })
    }
    wss.clients.forEach(function each(client) {
      if (client.readyState === WebSocket.OPEN) {
        client.send(`schedule=${user}`);
      }
    });
    res.send({
      status: "Complete"
    });
  })
  .post('/addSchedule', async function (req, res) {
    res.setHeader('Access-Control-Allow-Origin', 'https://reserveid.macrotechsolutions.us');
    res.setHeader('Access-Control-Allow-Methods', 'GET, POST, OPTIONS, PUT, PATCH, DELETE');
    let date1 = req.headers.datetime;
    let user = req.headers.userkey;
    let myVal10 = await database.ref("queue").orderByChild('user').equalTo(user).once("value");
    myVal10 = myVal10.val();
    if (myVal10) {
      res.send({
        data: "Please leave the queue to use the schedule feature."
      });
    } else {
      var date = new Date();

      if (Date.parse(date) < Date.parse(date1)) {
        let myVal = await database.ref('scheduled').once('value');
        myVal = myVal.val();
        if (myVal.numOfPeople == 0) {
          database.ref('scheduled').push({
            date: date1,
            user: user
          });
          database.ref('/scheduled').update({
            numOfPeople: myVal.numOfPeople + 1
          })
          wss.clients.forEach(function each(client) {
            if (client.readyState === WebSocket.OPEN) {
              client.send(`schedule=${user}`);
            }
          });
          res.send({
            data: "Valid"
          });
        } else {
          let valid = true;
          let people = 0;
          for (key in myVal) {
            if (key != "numOfPeople") {
              let date2 = myVal[key].date;
              var newDate = Date.parse(date2);
              var checkDate = Date.parse(date1);
              if (newDate >= (checkDate - 1800000) && newDate <= (checkDate + 1800000)) {
                people++;
                if (people == 2) {
                  valid = false;
                }
              }
            }
          }
          if (valid) {
            database.ref('/scheduled').push({
              date: date1,
              user: user
            });
            database.ref('/scheduled').update({
              numOfPeople: myVal.numOfPeople + 1
            })
            wss.clients.forEach(function each(client) {
              if (client.readyState === WebSocket.OPEN) {
                client.send(`schedule=${user}`);
              }
            });
            res.send({
              data: "Valid"
            });
          } else {
            res.send({
              data: "This time slot is already taken. Please choose another time slot."
            });
          }
        }
      } else {
        res.send({
          data: "Please select a time in the future."
        });
      }
    }
  })
  .post('/userSignIn', async function (req, res) {
    res.setHeader('Access-Control-Allow-Origin', 'https://reserveid.macrotechsolutions.us');
    res.setHeader('Access-Control-Allow-Methods', 'GET, POST, OPTIONS, PUT, PATCH, DELETE');
    let info = req.headers;
    let email = info.email;
    let password = info.password;
    let returnVal;
    let myVal = await database.ref("users").orderByChild('email').equalTo(email).once("value");
    myVal = myVal.val();
    if (!myVal) {
      returnVal = {
        data: "Incorrect email address."
      }
    } else {
      let inputPassword = password;
      let userPassword;
      for (key in myVal) {
        userPassword = myVal[key].password;
      }
      if (bcrypt.compareSync(inputPassword, userPassword)) {
        for (key in myVal) {
          returnVal = {
            data: key,
            name: myVal[key].name,
            email: email
          }
        }
      } else {
        returnVal = {
          data: "Incorrect Password"
        }
      }
    }
    res.send(returnVal);
  })

  .post('/managerSignUp', async function (req, res) {
    let info = req.headers;
    let email = info.email;
    let firstName = info.firstname;
    let lastName = info.lastname;
    let password = info.password;
    let passwordConfirm = info.passwordconfirm;
    let returnVal;
    if (!email) {
      returnVal = {
        data: 'Please enter an email address.'
      };
      res.send(returnVal);
      return;
    }
    let myVal = await database.ref("managers").orderByChild('email').equalTo(email).once("value");
    myVal = myVal.val();
    if (myVal) {
      returnVal = {
        data: 'Email already exists.'
      };
    } else if (firstName.length == 0 || lastName.length == 0) {
      returnVal = {
        data: 'Invalid Name'
      };
    } else if (!(/^[a-zA-ZàáâäãåąčćęèéêëėįìíîïłńòóôöõøùúûüųūÿýżźñçčšžÀÁÂÄÃÅĄĆČĖĘÈÉÊËÌÍÎÏĮŁŃÒÓÔÖÕØÙÚÛÜŲŪŸÝŻŹÑßÇŒÆČŠŽ∂ð ,.'-]+$/u.test(firstName) && /^[a-zA-ZàáâäãåąčćęèéêëėįìíîïłńòóôöõøùúûüųūÿýżźñçčšžÀÁÂÄÃÅĄĆČĖĘÈÉÊËÌÍÎÏĮŁŃÒÓÔÖÕØÙÚÛÜŲŪŸÝŻŹÑßÇŒÆČŠŽ∂ð ,.'-]+$/u.test(lastName))) {
      returnVal = {
        data: 'Invalid Name'
      };
    } else if (!(/(?:[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*|"(?:[\x01-\x08\x0b\x0c\x0e-\x1f\x21\x23-\x5b\x5d-\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])*")@(?:(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\[(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?|[a-z0-9-]*[a-z0-9]:(?:[\x01-\x08\x0b\x0c\x0e-\x1f\x21-\x5a\x53-\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])+)\])/
      .test(email))) {
      returnVal = {
        data: 'Invalid email address.'
      };
    } else if (password.length < 6) {
      returnVal = {
        data: 'Your password needs to be at least 6 characters.'
      };
    } else if (password != passwordConfirm) {
      returnVal = {
        data: 'Your passwords don\'t match.'
      };
    } else {
      const value = {
        email: email,
        password: hash(password),
        name: `${firstName} ${lastName}`
      }
      database.ref("managers").push(value);
      returnVal = {
        data: key
      };
    }
    res.send(returnVal);
  })
  .post('/userSignUp', async function (req, res) {
    let info = req.headers;
    let email = info.email;
    let firstName = info.firstname;
    let lastName = info.lastname;
    let password = info.password;
    let passwordConfirm = info.passwordconfirm;
    let returnVal;
    if (!email) {
      returnVal = {
        data: 'Please enter an email address.'
      };
      res.send(returnVal);
      return;
    }
    let myVal = await database.ref("users").orderByChild('email').equalTo(email).once("value");
    myVal = myVal.val();
    if (myVal) {
      returnVal = {
        data: 'Email already exists.'
      };
    } else if (firstName.length == 0 || lastName.length == 0) {
      returnVal = {
        data: 'Invalid Name'
      };
    } else if (!(/^[a-zA-ZàáâäãåąčćęèéêëėįìíîïłńòóôöõøùúûüųūÿýżźñçčšžÀÁÂÄÃÅĄĆČĖĘÈÉÊËÌÍÎÏĮŁŃÒÓÔÖÕØÙÚÛÜŲŪŸÝŻŹÑßÇŒÆČŠŽ∂ð ,.'-]+$/u.test(firstName) && /^[a-zA-ZàáâäãåąčćęèéêëėįìíîïłńòóôöõøùúûüųūÿýżźñçčšžÀÁÂÄÃÅĄĆČĖĘÈÉÊËÌÍÎÏĮŁŃÒÓÔÖÕØÙÚÛÜŲŪŸÝŻŹÑßÇŒÆČŠŽ∂ð ,.'-]+$/u.test(lastName))) {
      returnVal = {
        data: 'Invalid Name'
      };
    } else if (!(/(?:[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*|"(?:[\x01-\x08\x0b\x0c\x0e-\x1f\x21\x23-\x5b\x5d-\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])*")@(?:(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\[(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?|[a-z0-9-]*[a-z0-9]:(?:[\x01-\x08\x0b\x0c\x0e-\x1f\x21-\x5a\x53-\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])+)\])/
      .test(email))) {
      returnVal = {
        data: 'Invalid email address.'
      };
    } else if (password.length < 6) {
      returnVal = {
        data: 'Your password needs to be at least 6 characters.'
      };
    } else if (password != passwordConfirm) {
      returnVal = {
        data: 'Your passwords don\'t match.'
      };
    } else {
      const value = {
        email: email,
        password: hash(password),
        name: `${firstName} ${lastName}`
      }
      database.ref("users").push(value);
      returnVal = {
        data: key,
        name: `${firstName} ${lastName}`,
        email: email
      };
    }
    res.send(returnVal);
  })
  .get('/getColor', async function (req, res) {
    console.log("getColor");
    res.setHeader('Access-Control-Allow-Origin', 'https://reserveid.macrotechsolutions.us');
    res.setHeader('Access-Control-Allow-Methods', 'GET, POST, OPTIONS, PUT, PATCH, DELETE');
    res.send({
      color: "yellow}"
    });
  })
  .post('/rfidRequest', async function (req, res) {
    res.setHeader('Access-Control-Allow-Origin', 'https://reserveid.macrotechsolutions.us');
    res.setHeader('Access-Control-Allow-Methods', 'GET, POST, OPTIONS, PUT, PATCH, DELETE');
    unlock = true;
    res.send({
      status: "Complete"
    });
  })
  .post('/leaveStore', async function (req, res) {
    res.setHeader('Access-Control-Allow-Origin', 'https://reserveid.macrotechsolutions.us');
    res.setHeader('Access-Control-Allow-Methods', 'GET, POST, OPTIONS, PUT, PATCH, DELETE');
    let userkey = req.headers.userid;
    let myVal = await database.ref('inStore').orderByChild('user').equalTo(userkey).once('value');
    myVal = myVal.val();
    for(key in myVal){
      database.ref(`inStore/${key}`).remove();
    }
    res.send({
      status: "Complete"
    });
  })
  .get('/hardwareConnect', async function (req, res) {
    res.setHeader('Access-Control-Allow-Origin', 'https://reserveid.macrotechsolutions.us');
    res.setHeader('Access-Control-Allow-Methods', 'GET, POST, OPTIONS, PUT, PATCH, DELETE');
    let rfid = req.headers.rfid;
    wss.clients.forEach(function each(client) {
      if (client.readyState === WebSocket.OPEN) {
        client.send(`connect${rfid}`);
      }
    });
    if (unlock) {
      res.send('y');
      let myVal = await database.ref('users').orderByChild('rfid').equalTo(rfid).once('value');
      myVal = myVal.val()
      let key;
      for (key in myVal) {
        let myVal2 = await database.ref('queue').orderByChild('user').equalTo(key).once('value');
        myVal2 = myVal2.val()
        if (myVal2) {
          for (key1 in myVal2) {
            let position = myVal2[key1].position 
            let myVal3 = await database.ref('queue').once('value');
            myVal3 = myVal3.val()
            for (key2 in myVal3) {
              let num = myVal3.numOfPeople;
              console.log(myVal3[key2].position);
              console.log(position);
              if (myVal3[key2].position > position) {
                console.log("here");
                console.log(key2);
                database.ref(`queue/${key2}`).update({
                  position: myVal3[key2].position-1
                })
                database.ref(`queue/${key1}`).remove();
                database.ref('queue').update({
                  numOfPeople: num -1
                })
              } else {  
                database.ref(`queue/${key1}`).remove()
                database.ref('queue').update({
                  numOfPeople: num -1
                })
              }
            }
          }
        }
      }
    } else {
      res.send('n');
    }
    unlock = false;
  })
  .get('/distance', async function (req, res) {
    console.log("distance");
    res.setHeader('Access-Control-Allow-Origin', 'https://reserveid.macrotechsolutions.us');
    res.setHeader('Access-Control-Allow-Methods', 'GET, POST, OPTIONS, PUT, PATCH, DELETE');
    res.send({
      color: "hello}"
    });
  })
  .listen(PORT, () => console.log(`Listening on ${PORT}`));

function hash(value) {
  let salt = bcrypt.genSaltSync(10);
  let hashVal = bcrypt.hashSync(value, salt);
  return hashVal;
}

function parseEnvList(env) {
  if (!env) {
    return [];
  }
  return env.split(',');
}

var originBlacklist = parseEnvList(process.env.CORSANYWHERE_BLACKLIST);
var originWhitelist = parseEnvList(process.env.CORSANYWHERE_WHITELIST);

// Set up rate-limiting to avoid abuse of the public CORS Anywhere server.
var checkRateLimit = require('./lib/rate-limit')(process.env.CORSANYWHERE_RATELIMIT);

var cors_proxy = require('./lib/cors-anywhere');
cors_proxy.createServer({
  originBlacklist: originBlacklist,
  originWhitelist: originWhitelist,
  requireHeader: ['origin', 'x-requested-with'],
  checkRateLimit: checkRateLimit,
  removeHeaders: [
    'cookie',
    'cookie2',
    // Strip Heroku-specific headers
    'x-heroku-queue-wait-time',
    'x-heroku-queue-depth',
    'x-heroku-dynos-in-use',
    'x-request-start',
  ],
  redirectSameOrigin: true,
  httpProxyOptions: {
    // Do not add X-Forwarded-For, etc. headers, because Heroku already adds it.
    xfwd: false,
  },
})
  .listen(4911, () => console.log(`Listening on ${4911}`))