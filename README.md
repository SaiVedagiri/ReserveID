# ReserveID

## Inspiration

The COVID-19 pandemic has completely changed the way we live our lives. With strict restrictions on leaving the house for restaurants, entertainment facilities, etc., grocery stores have not only become a necessity for society, but also among the most likely locations for the spread of the virus. Researchers at the University of Finland conducted a simulation showing how a single cough of a COVID-19 carrier can rapidly spread the disease throughout an entire grocery store. This threat level is greatly increased as more people stay in the store, demanding the need for regulations on the number of people in the store. Currently, to enter a grocery store, you must wait in lines that often span hundreds of feet and take multiple hours to get through. This can lead to unnecessary exposure to the virus for extended amounts of time. Furthermore, strict guidelines have mandated that grocery stores operate at 50% capacity. This puts grocery stores at risk of overcrowding or under-efficiency without the correct infrastructure. By creating an integrated platform to monitor capacity at grocery stores and allow customers to wait in a queue at home, we can create a safe and efficient experience at the grocery stores that have become an essential part of our lives.

## What it does

ReserveID is a multi-platform system that can allow customers and store managers to schedule a queue that is both efficient and safe. When a user needs to go to the supermarket, they can access the mobile app and remotely schedule a time for shopping. They can also place themselves in the queue. After scanning their RFID tag with their Arduino hardware, they can be identified by the app and a timer will be displayed for the time remaining until their turn. All of this information is communicated through the server which stores the information in a firebase. The website takes the data from the firebase and displays the information for store managers to login and monitor. The website shows live timing for the queues and is all secured through the server.

## How we built it

###App

We created the app using the Flutter programming language and it allows you to connect to your RFID reader. This app will allow you to schedule your shopping time and reserve your spot on the queue all while being safe at home. It also notifies the user when it is their turn to shop and once the RFID tag is scanned, the shopping timer is displayed. All of the app communications routes through the server to enhance security.

###Hardware

The hardware component of the system is based on an Arduino Mega 2560. A short-range RFID reader is used to scan a user's tag. The ID number is cross referenced with the backend using an ESP8266 WiFi module for wireless communication and unlocks the basket when authenticated. Finally, an ultrasonic sensor is used to track if the cart is empty, which is used in conjunction with app input to alert waiting customers.

###Website

We created an HTML/CSS/JavaScript website designated for authenticated managers. It implements the Google Firebase SDK to display real time information of current, queued, and scheduled customers. When a customer checks into the store, the website auto-updates with an event listener and begins an individual timer for regulation purposes. A secure login and signup system is used to provide further security for store managers that are remotely checking in on their store’s status.

###Server

The server is the middleman for the entire project. It handles all requests coming in from the arduino, mobile app, and the website. The first process that the server handles is users logging and signing in. From there the server gets a request from the mobile app to update the queue or schedule. This information is then sent to a web socket that the phone also connects to in order to update the status of other customers through their devices. The server then stores the information in the firebase for access by the website.

## Challenges we ran into

One of the major challenges we ran into was determining how to notify the user as to when they have to enter the store for their turn. We had limited experience with the notifications through the firebase and server so it took a while to get that to work. It took a significant amount of time to finish the website with the live timer through Javascript as well. By far the hardest thing was getting the server to be able to send notifications and interact with the app properly.

## Accomplishments that we're proud of

We are most proud of how we achieved seamless Wi-Fi based server communication across the four separate platforms. Each of our team members took on a different component and worked together to integrate each piece together into a single, connected platform. With all of the user information, RFID identifiers, distances, and other data points that are passed between components as API parameters, we are proud that we created a platform that handles it all accurately and efficiently, all while working remotely. We also managed to implement server based notifications through Flutter, which is something we hadn't done before.

## What we learned

Given the remote circumstances, we had to learn how to communicate effectively and work cooperatively in order to produce the end result we wanted. As mentioned before, we learned new things regarding flutter and server-based notifications, as well as live timing through the server.

## What's next for ReserveID

Other features that can be added to further enhance the product is the option of multiple chain buildings. Currently this platform is mainly applicable for one location, but if a manager owns a chain with various sites, a way to view all of them can be applied. Also, managers may want the ability to add and remove people from the queue through an administrative tool, which will allow for more regulation of the store’s safety levels.
