import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_channel/io.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

String url = "https://reserveid.macrotechsolutions.us/terms.html";
String userID = "";
String username = "";
String password = "";
String firstName = "";
String lastName = "";
String confirmPassword = "";
String rfidNum = "";
var setupJSON;
var userJSON;
var queueNum = "0";
String queueNumString = "";
String estimateString = "";
String buttonText = "Join Queue";
String dateTimeString;
bool scheduled = false;
String scheduledTime = "1970-01-01 00:00";
int secondsRemaining = 1800;
bool timerActive = false;

void main() {
  runApp(MyApp());
}

class HexColor extends Color {
  static int _getColorFromHex(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF" + hexColor;
    }
    return int.parse(hexColor, radix: 16);
  }

  HexColor(final String hexColor) : super(_getColorFromHex(hexColor));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ReserveID',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      routes: {
        "/": (_) => MyHomePage(title: 'ReserveID'),
        "/queue": (_) => QueuePage(),
        "/inStore": (_) => InStorePage(),
        "/setup": (_) => SetupPage(),
        "/schedule": (_) => SchedulePage(),
        "/settings": (_) => SettingsPage(),
        "/webview": (_) => WebviewScaffold(
              url: url,
              appBar: AppBar(
                title: Text("Terms and Conditions"),
              ),
              withJavascript: true,
              withLocalStorage: true,
              withZoom: true,
            )
      },
    );
  }
}

GoogleSignIn googleSignIn = GoogleSignIn(
  scopes: [
    'email',
  ],
);

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  initState() {
    super.initState();
    webView.close();
    controller.addListener(() {
      url = controller.text;
    });
    initStateFunction();
  }

  initStateFunction() async {
    var prefs = await SharedPreferences.getInstance();
    userID = prefs.getString('userID');
    rfidNum = prefs.getString('rfid');
    if (userID != "" && userID != null) {
      userJSON = json.decode(prefs.getString('userJSON'));
      if (rfidNum != "" && rfidNum != null) {
        Navigator.pushReplacementNamed(context, "/queue");
      } else {
        Navigator.pushReplacementNamed(context, "/setup");
      }
    }
  }

  Future<String> helpContext(BuildContext context, String title, Widget body) {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
              title: Text(title),
              content: body,
              actions: <Widget>[
                MaterialButton(
                  elevation: 5.0,
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text("OK"),
                )
              ]);
        });
  }

  final webView = FlutterWebviewPlugin();
  TextEditingController controller = TextEditingController(text: url);

  @override
  void dispose() {
    webView.dispose();
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.help),
              onPressed: () async {
                helpContext(
                    context,
                    "Help",
                    Text.rich(
                      TextSpan(
                        children: <TextSpan>[
                          TextSpan(
                            text: 'Login\n',
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline),
                          ),
                          TextSpan(
                            text:
                                'Use this feature to log in to an existing shopper account.\n',
                            style: TextStyle(fontSize: 20),
                          ),
                          TextSpan(
                            text: '\nSign Up\n',
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline),
                          ),
                          TextSpan(
                            text:
                                'Use this feature to create a new shopper account.\n',
                            style: TextStyle(fontSize: 20),
                          ),
                        ],
                      ),
                    ));
              })
        ],
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Invoke "debug painting" (press "p" in the console, choose the
          // "Toggle Debug Paint" action from the Flutter Inspector in Android
          // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
          // to see the wireframe for each widget.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
                padding: const EdgeInsets.all(30.0),
                child: Image(
                  image: AssetImage('assets/reserveidlogo.png'),
                  height: 150,
                )),
            ListTile(
              title: RaisedButton(
                color: HexColor("00b2d1"),
                onPressed: () {
                  dispose() {
                    SystemChrome.setPreferredOrientations([
                      DeviceOrientation.landscapeRight,
                      DeviceOrientation.landscapeLeft,
                      DeviceOrientation.portraitUp,
                      DeviceOrientation.portraitDown,
                    ]);
                    super.dispose();
                  }
                  dispose();
                  Navigator.push(
                      context,
                      new MaterialPageRoute(
                          builder: (context) => new SignInPage()));
                },
                child: Text("Login"),
              ),
            ),
            ListTile(
                title: RaisedButton(
                    color: HexColor("ff5ded"),
                    onPressed: () {
                      dispose() {
                        SystemChrome.setPreferredOrientations([
                          DeviceOrientation.landscapeRight,
                          DeviceOrientation.landscapeLeft,
                          DeviceOrientation.portraitUp,
                          DeviceOrientation.portraitDown,
                        ]);
                        super.dispose();
                      }
                      dispose();
                      Navigator.push(
                          context,
                          new MaterialPageRoute(
                              builder: (context) => new SignUpPage()));
                    },
                    child: Text("Sign Up"))),
            ListTile(
                title: RaisedButton(
                    color: HexColor("c6c6c8"),
                    onPressed: () async {
                      Navigator.of(context).pushNamed("/webview");
                    },
                    child: Text("Terms and Conditions"))),
          ],
        ),
      ),
    );
  }
}

class SignInPage extends StatefulWidget {
  SignInPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  Future<String> createAlertDialog(
      BuildContext context, String title, String body) {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
              title: Text(title),
              content: Text(body),
              actions: <Widget>[
                MaterialButton(
                  elevation: 5.0,
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text("OK"),
                )
              ]);
        });
  }

  Future<String> helpContext(BuildContext context, String title, Widget body) {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
              title: Text(title),
              content: body,
              actions: <Widget>[
                MaterialButton(
                  elevation: 5.0,
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text("OK"),
                )
              ]);
        });
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    googleSignIn.signOut();
    return Scaffold(
      appBar: AppBar(
        title: Text("Login"),
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.help),
              onPressed: () async {
                helpContext(
                    context,
                    "Help",
                    Text.rich(
                      TextSpan(
                        children: <TextSpan>[
                          TextSpan(
                            text: 'Login\n',
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline),
                          ),
                          TextSpan(
                            text:
                                'Sign in to an existing ReserveID shopper account.\n',
                            style: TextStyle(fontSize: 20),
                          ),
                        ],
                      ),
                    ));
              })
        ],
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Invoke "debug painting" (press "p" in the console, choose the
          // "Toggle Debug Paint" action from the Flutter Inspector in Android
          // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
          // to see the wireframe for each widget.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(left: 30.0, right: 30.0),
              child: TextField(
                decoration: InputDecoration(hintText: "Email Address"),
                onChanged: (String str) {
                  setState(() {
                    username = str;
                  });
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 30.0, right: 30.0),
              child: TextField(
                decoration: InputDecoration(hintText: "Password"),
                obscureText: true,
                onChanged: (String str) {
                  setState(() {
                    password = str;
                  });
                },
              ),
            ),
            ListTile(
                title: RaisedButton(
                    onPressed: () async {
                      Map<String, String> headers = {
                        "Content-type": "application/json",
                        "Origin": "*",
                        "email": username,
                        "password": password
                      };
                      Response response = await post(
                          'https://reserveid.macrotechsolutions.us:9146/http://localhost/userSignIn',
                          headers: headers);
                      //createAlertDialog(context);
                      userJSON = jsonDecode(response.body);
                      if (userJSON["data"] != "Incorrect email address." &&
                          userJSON["data"] != "Incorrect Password") {
                        userID = userJSON["data"];
                        var prefs = await SharedPreferences.getInstance();
                        prefs.setString('userID', userID);
                        prefs.setString('userJSON', response.body);
                        dispose() {
                          SystemChrome.setPreferredOrientations([
                            DeviceOrientation.landscapeRight,
                            DeviceOrientation.landscapeLeft,
                            DeviceOrientation.portraitUp,
                            DeviceOrientation.portraitDown,
                          ]);
                          super.dispose();
                        }
                        dispose();
                        Navigator.pushReplacementNamed(context, "/setup");
                      } else {
                        createAlertDialog(context, "Error", userJSON["data"]);
                      }
                    },
                    child: Text("Submit"))),
            Padding(
              padding: const EdgeInsets.only(top: 30.0),
              child: Text(
                "OR",
                style: TextStyle(
                  fontSize: 20.0,
                ),
              ),
            ),
            SizedBox(height: 50),
            RaisedButton(
              onPressed: () async {
                final GoogleSignInAccount googleSignInAccount =
                    await googleSignIn.signIn();
                Map<String, String> headers = {
                  "Content-type": "application/json",
                  "Origin": "*",
                  "email": googleSignInAccount.email,
                  "name": googleSignInAccount.displayName
                };
                Response response = await post(
                    'https://reserveid.macrotechsolutions.us:9146/http://localhost/userGoogleSignIn',
                    headers: headers);
                //createAlertDialog(context);
                userJSON = jsonDecode(response.body);
                userID = userJSON["userkey"];
                var prefs = await SharedPreferences.getInstance();
                prefs.setString('userID', userID);
                prefs.setString('userJSON', response.body);
                dispose() {
                  SystemChrome.setPreferredOrientations([
                    DeviceOrientation.landscapeRight,
                    DeviceOrientation.landscapeLeft,
                    DeviceOrientation.portraitUp,
                    DeviceOrientation.portraitDown,
                  ]);
                  super.dispose();
                }
                dispose();
                Navigator.pushReplacementNamed(context, "/setup");
              },
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Image(
                        image: AssetImage("assets/google_logo.png"),
                        height: 35.0),
                    Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: Text(
                        'Sign in with Google',
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.black,
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SignUpPage extends StatefulWidget {
  SignUpPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  Future<String> createAlertDialog(
      BuildContext context, String title, String body) {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
              title: Text(title),
              content: Text(body),
              actions: <Widget>[
                MaterialButton(
                  elevation: 5.0,
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text("OK"),
                )
              ]);
        });
  }

  Future<String> helpContext(BuildContext context, String title, Widget body) {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
              title: Text(title),
              content: body,
              actions: <Widget>[
                MaterialButton(
                  elevation: 5.0,
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text("OK"),
                )
              ]);
        });
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    googleSignIn.signOut();
    return Scaffold(
      appBar: AppBar(
        title: Text("Sign Up"),
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.help),
              onPressed: () async {
                helpContext(
                    context,
                    "Help",
                    Text.rich(
                      TextSpan(
                        children: <TextSpan>[
                          TextSpan(
                            text: 'Sign Up\n',
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline),
                          ),
                          TextSpan(
                            text: 'Create a new ReserveID shopper account.\n',
                            style: TextStyle(fontSize: 20),
                          ),
                        ],
                      ),
                    ));
              })
        ],
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Invoke "debug painting" (press "p" in the console, choose the
          // "Toggle Debug Paint" action from the Flutter Inspector in Android
          // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
          // to see the wireframe for each widget.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(left: 30.0, right: 30.0),
              child: TextField(
                decoration: InputDecoration(hintText: "First Name"),
                onChanged: (String str) {
                  setState(() {
                    firstName = str;
                  });
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 30.0, right: 30.0),
              child: TextField(
                decoration: InputDecoration(hintText: "Last Name"),
                onChanged: (String str) {
                  setState(() {
                    lastName = str;
                  });
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 30.0, right: 30.0),
              child: TextField(
                decoration: InputDecoration(hintText: "Email Address"),
                onChanged: (String str) {
                  setState(() {
                    username = str;
                  });
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 30.0, right: 30.0),
              child: TextField(
                decoration: InputDecoration(hintText: "Password"),
                obscureText: true,
                onChanged: (String str) {
                  setState(() {
                    password = str;
                  });
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 30.0, right: 30.0),
              child: TextField(
                decoration: InputDecoration(hintText: "Confirm Password"),
                obscureText: true,
                onChanged: (String str) {
                  setState(() {
                    confirmPassword = str;
                  });
                },
              ),
            ),
            ListTile(
                title: RaisedButton(
                    onPressed: () async {
                      Map<String, String> headers = {
                        "Content-type": "application/json",
                        "Origin": "*",
                        "firstname": firstName,
                        "lastname": lastName,
                        "email": username,
                        "password": password,
                        "passwordconfirm": confirmPassword
                      };
                      Response response = await post(
                          'https://reserveid.macrotechsolutions.us:9146/http://localhost/userSignUp',
                          headers: headers);
                      //createAlertDialog(context);
                      userJSON = jsonDecode(response.body);
                      if (userJSON["data"] != 'Email already exists.' &&
                          userJSON["data"] != 'Invalid Name' &&
                          userJSON["data"] != 'Invalid email address.' &&
                          userJSON["data"] !=
                              'Your password needs to be at least 6 characters.' &&
                          userJSON["data"] != 'Your passwords don\'t match.') {
                        userID = userJSON["userkey"];
                        var prefs = await SharedPreferences.getInstance();
                        prefs.setString('userID', userID);
                        prefs.setString('userJSON', response.body);
                        dispose() {
                          SystemChrome.setPreferredOrientations([
                            DeviceOrientation.landscapeRight,
                            DeviceOrientation.landscapeLeft,
                            DeviceOrientation.portraitUp,
                            DeviceOrientation.portraitDown,
                          ]);
                          super.dispose();
                        }
                        dispose();
                        Navigator.pushReplacementNamed(context, "/setup");
                      } else {
                        createAlertDialog(context, "Error", userJSON["data"]);
                      }
                    },
                    child: Text("Submit"))),
            Padding(
              padding: const EdgeInsets.only(top: 30.0),
              child: Text(
                "OR",
                style: TextStyle(
                  fontSize: 20.0,
                ),
              ),
            ),
            SizedBox(height: 50),
            RaisedButton(
              onPressed: () async {
                final GoogleSignInAccount googleSignInAccount =
                    await googleSignIn.signIn();
                Map<String, String> headers = {
                  "Content-type": "application/json",
                  "Origin": "*",
                  "email": googleSignInAccount.email,
                  "name": googleSignInAccount.displayName
                };
                Response response = await post(
                    'https://reserveid.macrotechsolutions.us:9146/http://localhost/userGoogleSignIn',
                    headers: headers);
                //createAlertDialog(context);
                userJSON = jsonDecode(response.body);
                userID = userJSON["userkey"];
                var prefs = await SharedPreferences.getInstance();
                prefs.setString('userID', userID);
                prefs.setString('userJSON', response.body);
                dispose() {
                  SystemChrome.setPreferredOrientations([
                    DeviceOrientation.landscapeRight,
                    DeviceOrientation.landscapeLeft,
                    DeviceOrientation.portraitUp,
                    DeviceOrientation.portraitDown,
                  ]);
                  super.dispose();
                }
                dispose();
                Navigator.pushReplacementNamed(context, "/setup");
              },
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Image(
                        image: AssetImage("assets/google_logo.png"),
                        height: 35.0),
                    Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: Text(
                        'Sign in with Google',
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.black,
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class QueuePage extends StatefulWidget {
  QueuePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _QueuePageState createState() => _QueuePageState();
}

class _QueuePageState extends State<QueuePage> {
  @override
  initState() {
    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => initStateFunction());
  }

  initStateFunction() async {
    Map<String, String> headers = {
      "Content-type": "application/json",
      "Origin": "*",
      "userkey": userID
    };
    Response response = await post(
        'https://reserveid.macrotechsolutions.us:9146/http://localhost/getInfo',
        headers: headers);
    //createAlertDialog(context);
    var tempJSON = jsonDecode(response.body);
    print(tempJSON);
    setState(() {
      queueNum = tempJSON["queuenum"].toString();
      buttonText = tempJSON["buttontext"];
    });
    if (buttonText == "Leave Queue") {
      setState(() {
        queueNumString = "Position in Queue: ${tempJSON["position"]}";
        estimateString =
            "Estimated Time Until Shopping Window: ${tempJSON["position"] * 30 - 30} minutes";
      });
      if(tempJSON["status"] == "true"){
        showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                  title: Text("Enter Store"),
                  content: Text("It is time to visit the store. Please proceed to the store and click OK."),
                  actions: <Widget>[
                    MaterialButton(
                      elevation: 5.0,
                      onPressed: () async {
                        Navigator.of(context).pop();
                        Map<String, String> headers = {
                          "Content-type": "application/json",
                          "Origin": "*",
                          "userkey": userID
                        };
                        await post(
                            'https://reserveid.macrotechsolutions.us:9146/http://localhost/rfidRequest',
                            headers: headers);
                        Navigator.pushReplacementNamed(context, "/inStore");
                      },
                      child: Text("OK"),
                    )
                  ]);
            });
      }
    }
  }

  Future<String> createAlertDialog(
      BuildContext context, String title, String body) {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
              title: Text(title),
              content: Text(body),
              actions: <Widget>[
                MaterialButton(
                  elevation: 5.0,
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text("OK"),
                )
              ]);
        });
  }

  Future<String> helpContext(BuildContext context, String title, Widget body) {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
              title: Text(title),
              content: body,
              actions: <Widget>[
                MaterialButton(
                  elevation: 5.0,
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text("OK"),
                )
              ]);
        });
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    var channel = IOWebSocketChannel.connect(
        "wss://reserveid.macrotechsolutions.us:4211");
    channel.stream.listen((message) async {
      if(message == userID){
        showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                  title: Text("Enter Store"),
                  content: Text("It is time to visit the store. Please proceed to the store and click OK."),
                  actions: <Widget>[
                    MaterialButton(
                      elevation: 5.0,
                      onPressed: () {
                        Navigator.of(context).pop();
                        Navigator.pushReplacementNamed(context, "/inStore");
                      },
                      child: Text("OK"),
                    )
                  ]);
            });
      }
      if (message.startsWith("queueNum=")) {
        setState(() {
          queueNum = message.substring(9);
        });
        Map<String, String> headers = {
          "Content-type": "application/json",
          "Origin": "*",
          "userkey": userID
        };
        Response response = await post(
            'https://reserveid.macrotechsolutions.us:9146/http://localhost/getInfo',
            headers: headers);
        //createAlertDialog(context);
        var tempJSON = jsonDecode(response.body);
        setState(() {
          queueNum = tempJSON["queuenum"].toString();
          buttonText = tempJSON["buttontext"].toString();
        });
        if (buttonText == "Leave Queue") {
          queueNumString = "Position in Queue: ${tempJSON["position"]}";
          estimateString =
              "Estimated Time Until Shopping Window: ${tempJSON["position"] * 30 - 30} minutes";
          setState(() {
            scheduled = false;
          });
        } else {
          if (tempJSON["schedule"] == "true") {
            setState(() {
              scheduled = true;
              scheduledTime = tempJSON["time"];
            });
          } else {
            setState(() {
              scheduled = false;
            });
          }
        }
      }
    });
    return Scaffold(
      appBar: AppBar(
        title: Text("ReserveID Queue"),
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.help),
              onPressed: () async {
                helpContext(
                    context,
                    "Help",
                    Text.rich(
                      TextSpan(
                        children: <TextSpan>[
                          TextSpan(
                            text: 'ReserveID\n',
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline),
                          ),
                          TextSpan(
                            text:
                                'This screen will allow you to join the queue to be notified when you can visit the store.\n',
                            style: TextStyle(fontSize: 20),
                          ),
                        ],
                      ),
                    ));
              })
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        child: new Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            IconButton(
              icon: Icon(Icons.list),
              onPressed: () {},
            ),
            IconButton(
              icon: Icon(Icons.schedule),
              onPressed: () {
                Navigator.pushReplacementNamed(context, "/schedule");
              },
            ),
            IconButton(
              icon: Icon(Icons.settings),
              onPressed: () {
                Navigator.pushReplacementNamed(context, "/settings");
              },
            ),
          ],
        ),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text("Number of People in Queue: $queueNum",
                style: TextStyle(fontSize: 20)),
            Padding(
              padding: const EdgeInsets.only(
                  top: 10.0, bottom: 10.0, left: 30.0, right: 30.0),
            ),
            Text("Estimated Wait Time: ${int.parse(queueNum) * 30} minutes",
                style: TextStyle(fontSize: 20)),
            Padding(
              padding: const EdgeInsets.only(
                  top: 10.0, bottom: 10.0, left: 30.0, right: 30.0),
            ),
            ListTile(
                title: RaisedButton(
                    onPressed: () async {
                      if (buttonText == "Join Queue") {
                        Map<String, String> headers = {
                          "Content-type": "application/json",
                          "Origin": "*",
                          "userkey": userID
                        };
                        Response response = await post(
                            'https://reserveid.macrotechsolutions.us:9146/http://localhost/joinQueue',
                            headers: headers);
                        //createAlertDialog(context);
                        var tempJSON = jsonDecode(response.body);
                        if (tempJSON["position"] == "Invalid") {
                          createAlertDialog(context, "Queueing Error",
                              "Please remove your scheduled visit to the use the queue feature.");
                        } else {
                          setState(() {
                            queueNumString =
                                "Position in Queue: ${tempJSON["position"]}";
                            estimateString =
                                "Estimated Time Until Shopping Window: ${tempJSON["position"] * 30 - 30} minutes";
                            buttonText = "Leave Queue";
                          });
                        }
                      } else {
                        Map<String, String> headers = {
                          "Content-type": "application/json",
                          "Origin": "*",
                          "userkey": userID
                        };
                        await post(
                            'https://reserveid.macrotechsolutions.us:9146/http://localhost/leaveQueue',
                            headers: headers);
                        //createAlertDialog(context);
                        setState(() {
                          queueNumString = "";
                          estimateString = "";
                          buttonText = "Join Queue";
                        });
                      }
                    },
                    child: Text("$buttonText"))),
            Padding(
              padding: const EdgeInsets.only(
                  top: 10.0, bottom: 10.0, left: 30.0, right: 30.0),
            ),
            Text("$queueNumString", style: TextStyle(fontSize: 20)),
            Padding(
              padding: const EdgeInsets.only(
                  top: 10.0, bottom: 10.0, left: 30.0, right: 30.0),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 30.0, right: 30.0),
              child: Text("$estimateString", style: TextStyle(fontSize: 20)),
            ),
          ],
        ),
      ),
    );
  }
}

class SchedulePage extends StatefulWidget {
  SchedulePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _SchedulePageState createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  @override
  initState() {
    super.initState();
    initStateFunction();
  }

  initStateFunction() async {
    Map<String, String> headers = {
      "Content-type": "application/json",
      "Origin": "*",
      "userkey": userID
    };
    Response response = await post(
        'https://reserveid.macrotechsolutions.us:9146/http://localhost/getInfo',
        headers: headers);
    //createAlertDialog(context);
    var tempJSON = jsonDecode(response.body);
    if (tempJSON["buttontext"] != "Leave Queue") {
      if (tempJSON["schedule"] == "true") {
        setState(() {
          scheduled = true;
          scheduledTime = tempJSON["time"];
        });
      } else {
        setState(() {
          scheduled = false;
        });
      }
    } else {
      setState(() {
        scheduled = false;
      });
    }
  }

  Future<String> createAlertDialog(
      BuildContext context, String title, String body) {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
              title: Text(title),
              content: Text(body),
              actions: <Widget>[
                MaterialButton(
                  elevation: 5.0,
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text("OK"),
                )
              ]);
        });
  }

  Future<String> helpContext(BuildContext context, String title, Widget body) {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
              title: Text(title),
              content: body,
              actions: <Widget>[
                MaterialButton(
                  elevation: 5.0,
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text("OK"),
                )
              ]);
        });
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    var channel = IOWebSocketChannel.connect(
        "wss://reserveid.macrotechsolutions.us:4211");

    channel.stream.listen((message) async {
      print(message);
      if(message == userID){
        showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                  title: Text("Enter Store"),
                  content: Text("It is time to visit the store. Please proceed to the store and click OK."),
                  actions: <Widget>[
                    MaterialButton(
                      elevation: 5.0,
                      onPressed: () {
                        Navigator.of(context).pop();
                        Navigator.pushReplacementNamed(context, "/inStore");
                      },
                      child: Text("OK"),
                    )
                  ]);
            });
      }else if (message.startsWith("schedule$userID")) {
        Map<String, String> headers = {
          "Content-type": "application/json",
          "Origin": "*",
          "userkey": userID
        };
        Response response = await post(
            'https://reserveid.macrotechsolutions.us:9146/http://localhost/getInfo',
            headers: headers);
        //createAlertDialog(context);
        var tempJSON = jsonDecode(response.body);
        print(tempJSON);
        if (tempJSON["buttontext"] != "Leave Queue") {
          if (tempJSON["schedule"] == "true") {
            setState(() {
              scheduled = true;
              scheduledTime = tempJSON["time"];
            });
          } else {
            setState(() {
              scheduled = false;
            });
          }
        } else {
          setState(() {
            scheduled = false;
          });
        }
      }
    });
    return Scaffold(
        appBar: AppBar(
          title: Text("Schedule Visit"),
          actions: <Widget>[
            IconButton(
                icon: Icon(Icons.help),
                onPressed: () async {
                  helpContext(
                      context,
                      "Help",
                      Text.rich(
                        TextSpan(
                          children: <TextSpan>[
                            TextSpan(
                              text: 'ReserveID\n',
                              style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.underline),
                            ),
                            TextSpan(
                              text:
                                  'This screen will allow you to schedule your 30-minute visit to the store.\n',
                              style: TextStyle(fontSize: 20),
                            ),
                          ],
                        ),
                      ));
                })
          ],
        ),
        bottomNavigationBar: BottomAppBar(
          child: new Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              IconButton(
                icon: Icon(Icons.list),
                onPressed: () {
                  Navigator.pushReplacementNamed(context, "/queue");
                },
              ),
              IconButton(
                icon: Icon(Icons.schedule),
                onPressed: () {},
              ),
              IconButton(
                icon: Icon(Icons.settings),
                onPressed: () {
                  Navigator.pushReplacementNamed(context, "/settings");
                },
              ),
            ],
          ),
        ),
        body: Center(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
              Visibility(
                visible: !scheduled,
                child: Padding(
                  padding: const EdgeInsets.only(
                      top: 10.0, bottom: 10.0, left: 30.0, right: 30.0),
                  child:
                      Text("Schedule a Visit:", style: TextStyle(fontSize: 20)),
                ),
              ),
              Visibility(
                  visible: !scheduled,
                  child: Padding(
                    padding: const EdgeInsets.only(
                        top: 10.0, bottom: 10.0, left: 30.0, right: 30.0),
                    child: Form(
                      child: DateTimeField(
                        format: DateFormat('EEEE, MMMM dd, y @ HH:mm '),
                        onShowPicker: (context, currentValue) async {
                          DateTime now = DateTime.now();
                          String year = DateFormat('yyyy').format(now);
                          final date = await showDatePicker(
                              context: context,
                              firstDate: DateTime(int.parse(year)),
                              initialDate: currentValue ?? DateTime.now(),
                              lastDate: DateTime(int.parse(year) + 10));
                          if (date != null) {
                            final time = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay.fromDateTime(
                                  currentValue ?? DateTime.now()),
                            );
                            dateTimeString = DateFormat("yyyy-MM-dd HH:mm")
                                .format(DateTimeField.combine(date, time))
                                .toString();
                            setState(() {
                              scheduledTime =
                                  DateTimeField.combine(date, time).toString();
                            });
                            return DateTimeField.combine(date, time);
                          } else {
                            return currentValue;
                          }
                        },
                        initialValue: DateTime.now(),
                      ),
                    ),
                  )),
              Visibility(
                visible: scheduled,
                child: Padding(
                    padding: const EdgeInsets.only(
                        top: 10.0, bottom: 10.0, left: 30.0, right: 30.0),
                    child: Text(
                        "Currently Scheduled for ${DateFormat('EEEE, MMMM dd, y @ HH:mm').format(DateTime.parse(scheduledTime)).toString()}",
                        style: TextStyle(fontSize: 20))),
              ),
              Visibility(
                visible: !scheduled,
                child: ListTile(
                    title: RaisedButton(
                        onPressed: () async {
                          print(dateTimeString);
                          Map<String, String> headers = {
                            "Content-type": "application/json",
                            "Origin": "*",
                            "userkey": userID,
                            "datetime": dateTimeString
                          };
                          Response response = await post(
                              'https://reserveid.macrotechsolutions.us:9146/http://localhost/addSchedule',
                              headers: headers);
                          //createAlertDialog(context);
                          var tempJSON = jsonDecode(response.body);
                          if (tempJSON["data"] != "Valid") {
                            createAlertDialog(
                                context, "Scheduling Error", tempJSON["data"]);
                          } else {
                            setState(() {
                              scheduled = true;
                            });
                          }
                        },
                        child: Text("Add to Schedule"))),
              ),
              Visibility(
                visible: scheduled,
                child: ListTile(
                    title: RaisedButton(
                        onPressed: () async {
                          Map<String, String> headers = {
                            "Content-type": "application/json",
                            "Origin": "*",
                            "userkey": userID
                          };
                          Response response = await post(
                              'https://reserveid.macrotechsolutions.us:9146/http://localhost/removeSchedule',
                              headers: headers);
                          //createAlertDialog(context);
                          var tempJSON = jsonDecode(response.body);
                          print(tempJSON);
                          setState(() {
                            scheduled = false;
                          });
                        },
                        child: Text("Remove from Schedule"))),
              ),
            ])));
  }
}

class SettingsPage extends StatefulWidget {
  SettingsPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  Future<String> createAlertDialog(
      BuildContext context, String title, String body) {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
              title: Text(title),
              content: Text(body),
              actions: <Widget>[
                MaterialButton(
                  elevation: 5.0,
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text("OK"),
                )
              ]);
        });
  }

  Future<String> helpContext(BuildContext context, String title, Widget body) {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
              title: Text(title),
              content: body,
              actions: <Widget>[
                MaterialButton(
                  elevation: 5.0,
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text("OK"),
                )
              ]);
        });
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return Scaffold(
      appBar: AppBar(
        title: Text("ReserveID Settings"),
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.help),
              onPressed: () async {
                helpContext(
                    context,
                    "Help",
                    Text.rich(
                      TextSpan(
                        children: <TextSpan>[
                          TextSpan(
                            text: 'ReserveID Settings\n',
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline),
                          ),
                          TextSpan(
                            text:
                                'This screen will allow you to edit the settings of this app.\n',
                            style: TextStyle(fontSize: 20),
                          ),
                        ],
                      ),
                    ));
              })
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        child: new Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            IconButton(
              icon: Icon(Icons.list),
              onPressed: () {
                Navigator.pushReplacementNamed(context, "/queue");
              },
            ),
            IconButton(
              icon: Icon(Icons.schedule),
              onPressed: () {
                Navigator.pushReplacementNamed(context, "/schedule");
              },
            ),
            IconButton(
              icon: Icon(Icons.settings),
              onPressed: () {},
            ),
          ],
        ),
      ),
      body: ListView(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(
                top: 10.0, bottom: 10.0, left: 30.0, right: 30.0),
            child: Text("Email Address: ${userJSON["email"]}",
                style: TextStyle(fontSize: 20)),
          ),
          Padding(
            padding: const EdgeInsets.only(
                top: 10.0, bottom: 10.0, left: 30.0, right: 30.0),
            child: Text(
              "Name: ${userJSON["name"]}",
              style: TextStyle(fontSize: 20),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
                top: 10.0, bottom: 10.0, left: 30.0, right: 30.0),
            child: Row(
              children: <Widget>[
                Padding(
                    padding: const EdgeInsets.only(
                        top: 10.0, bottom: 10.0, right: 15.0),
                    child: Text("Not you?", style: TextStyle(fontSize: 20))),
                RaisedButton(
                    onPressed: () async {
                      SharedPreferences prefs =
                          await SharedPreferences.getInstance();
                      await prefs.clear();
                      Navigator.pushReplacementNamed(context, "/");
                    },
                    child: Text("Sign out")),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 30.0, right: 30.0),
            child: TextField(
              decoration: InputDecoration(
                  labelText: 'RFID Access Code', hintText: "RFID Access Code"),
              keyboardType: TextInputType.number,
              onChanged: (String str) {
                setState(() {
                  rfidNum = str;
                });
              },
            ),
          ),
          ListTile(
              title: RaisedButton(
                  onPressed: () async {
                    Map<String, String> headers = {
                      "Content-type": "application/json",
                      "Origin": "*",
                      "userid": userID,
                      "rfid": rfidNum
                    };
                    Response response = await post(
                        'https://reserveid.macrotechsolutions.us:9146/http://localhost/setupDevice',
                        headers: headers);
                    //createAlertDialog(context);
                    setupJSON = jsonDecode(response.body);
                    if (setupJSON["data"] == "Success") {
                      var prefs = await SharedPreferences.getInstance();
                      prefs.setString('rfid', rfidNum);
                      createAlertDialog(context, "Success",
                          "Updated RFID and Reader access keys.");
                    } else {
                      createAlertDialog(context, "Error", setupJSON["data"]);
                    }
                  },
                  child: Text("Update RFID Tag"))),
        ],
      ),
    );
  }
}

class SetupPage extends StatefulWidget {
  SetupPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _SetupPageState createState() => _SetupPageState();
}

class _SetupPageState extends State<SetupPage> {
  Future<String> createAlertDialog(
      BuildContext context, String title, String body) {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
              title: Text(title),
              content: Text(body),
              actions: <Widget>[
                MaterialButton(
                  elevation: 5.0,
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text("OK"),
                )
              ]);
        });
  }

  Future<String> helpContext(BuildContext context, String title, Widget body) {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
              title: Text(title),
              content: body,
              actions: <Widget>[
                MaterialButton(
                  elevation: 5.0,
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text("OK"),
                )
              ]);
        });
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return Scaffold(
      appBar: AppBar(
        title: Text("Setup ReserveID"),
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.help),
              onPressed: () async {
                helpContext(
                    context,
                    "Help",
                    Text.rich(
                      TextSpan(
                        children: <TextSpan>[
                          TextSpan(
                            text: 'Setup\n',
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline),
                          ),
                          TextSpan(
                            text:
                                'This screen will allow you to enter the hardware information necessary to communicate with the app.\n',
                            style: TextStyle(fontSize: 20),
                          ),
                        ],
                      ),
                    ));
              })
        ],
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(left: 30.0, right: 30.0),
              child: TextField(
                decoration: InputDecoration(hintText: "RFID Access Code"),
                keyboardType: TextInputType.number,
                onChanged: (String str) {
                  setState(() {
                    rfidNum = str;
                  });
                },
              ),
            ),
            ListTile(
                title: RaisedButton(
                    onPressed: () async {
                      print(userID);
                      print(rfidNum);
                      Map<String, String> headers = {
                        "Content-type": "application/json",
                        "Origin": "*",
                        "userid": userID,
                        "rfid": rfidNum
                      };
                      Response response = await post(
                          'https://reserveid.macrotechsolutions.us:9146/http://localhost/setupDevice',
                          headers: headers);
                      //createAlertDialog(context);
                      setupJSON = jsonDecode(response.body);
                      if (setupJSON["data"] == "Success") {
                        var prefs = await SharedPreferences.getInstance();
                        prefs.setString('rfid', rfidNum);
                        dispose() {
                          SystemChrome.setPreferredOrientations([
                            DeviceOrientation.landscapeRight,
                            DeviceOrientation.landscapeLeft,
                            DeviceOrientation.portraitUp,
                            DeviceOrientation.portraitDown,
                          ]);
                          super.dispose();
                        }
                        dispose();
                        Navigator.pushReplacementNamed(context, "/queue");
                      } else {
                        createAlertDialog(context, "Error", setupJSON["data"]);
                      }
                    },
                    child: Text("Submit"))),
          ],
        ),
      ),
    );
  }
}

class InStorePage extends StatefulWidget {
  InStorePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _InStorePageState createState() => _InStorePageState();
}

class _InStorePageState extends State<InStorePage> {

  @override
  initState() {
    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => initStateFunction());
  }

  initStateFunction() {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return AlertDialog(
              title: Text("Enter Store"),
              content: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text("Please walk into the store and scan into your cart.", style: TextStyle(fontSize: 20)),
                    Padding(
                      padding: EdgeInsets.all(30.0)
                    ),
                    SpinKitWave(
                      color: Colors.black,
                      size: 50.0,
                    )
                  ]),
              );
        });
  }

  static const duration = const Duration(seconds: 1);

  Timer timer;

  void handleTick() {
      setState(() {
        secondsRemaining = secondsRemaining - 1;
      });
  }
  Future<String> createAlertDialog(
      BuildContext context, String title, String body) {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
              title: Text(title),
              content: Text(body),
              actions: <Widget>[
                MaterialButton(
                  elevation: 5.0,
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text("OK"),
                )
              ]);
        });
  }

  Future<String> helpContext(BuildContext context, String title, Widget body) {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
              title: Text(title),
              content: body,
              actions: <Widget>[
                MaterialButton(
                  elevation: 5.0,
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text("OK"),
                )
              ]);
        });
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    var channel = IOWebSocketChannel.connect(
        "wss://reserveid.macrotechsolutions.us:4211");
    channel.stream.listen((message) async {
      print(message);
      if (message.startsWith("connect$rfidNum")) {
        Navigator.of(context).pop();
        timerActive = true;
      }});
    if (timer == null) {
      timer = Timer.periodic(duration, (Timer t) {
        if(timerActive && secondsRemaining != 0){
          handleTick();
        } if(secondsRemaining == 0){
          showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                    title: Text("Time Expired"),
                    content: Text("Please head to the checkout. Your time slot has expired."),
                    actions: <Widget>[
                      MaterialButton(
                        elevation: 5.0,
                        onPressed: () async {
                          Map<String, String> headers = {
                            "Content-type": "application/json",
                            "Origin": "*",
                            "userid": userID
                          };
                          await post(
                              'https://reserveid.macrotechsolutions.us:9146/http://localhost/leaveStore',
                              headers: headers);
                          Navigator.of(context).pop();
                          Navigator.pushReplacementNamed(context, "/queue");
                        },
                        child: Text("OK"),
                      )
                    ]);
              });
        }
      });
    }
    int seconds = secondsRemaining % 60;
    int minutes = secondsRemaining ~/ 60;
//    initStateFunction();
    return Scaffold(
      appBar: AppBar(
        title: Text("In Store"),
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.help),
              onPressed: () async {
                helpContext(
                    context,
                    "Help",
                    Text.rich(
                      TextSpan(
                        children: <TextSpan>[
                          TextSpan(
                            text: 'Setup\n',
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline),
                          ),
                          TextSpan(
                            text:
                            'This screen will show you the time you have left in the store.\n',
                            style: TextStyle(fontSize: 20),
                          ),
                        ],
                      ),
                    ));
              })
        ],
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(left: 30.0, right: 30.0),
              child: CircularPercentIndicator(
                radius: 300.0,
                lineWidth: 20.0,
                percent: (minutes + seconds/60)/30,
                center: Text.rich(
                  TextSpan(
                    children: <TextSpan>[
                      TextSpan(
                        text: '    ${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}\n',
                        style: TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.bold),
                      ),
                      TextSpan(
                        text:
                        'remaining\n',
                        style: TextStyle(fontSize: 40),
                      ),
                    ],
                  ),
                ),
                progressColor: Colors.green,
              )
              ),
            ListTile(
                title: RaisedButton(
                    onPressed: () async {
                      showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                                title: Text("Leave Store"),
                                content: Text("Are you sure you want to leave the store?"),
                                actions: <Widget>[
                                  MaterialButton(
                                    elevation: 5.0,
                                    onPressed: () async {
                                      Map<String, String> headers = {
                                        "Content-type": "application/json",
                                        "Origin": "*",
                                        "userid": userID
                                      };
                                      await post(
                                          'https://reserveid.macrotechsolutions.us:9146/http://localhost/leaveStore',
                                          headers: headers);
                                      Navigator.of(context).pop();
                                      Navigator.pushReplacementNamed(context, "/queue");
                                    },
                                    child: Text("Yes"),
                                  ),
                                MaterialButton(
                                  elevation: 5.0,
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: Text("No"),
                                  )
                                ]);
                          });
                    },
                    child: Text("Leave Store"))),
          ],
        ),
      ),
    );
  }
}