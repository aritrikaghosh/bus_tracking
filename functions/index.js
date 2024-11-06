"use strict";

// [START all]
// [START import]

const {setGlobalOptions} = require("firebase-functions/v2");
setGlobalOptions({maxInstances: 10});

const {initializeApp, applicationDefault} = require("firebase-admin/app");

// param code
const admin = require("firebase-admin");
const functions = require("firebase-functions");

const path = "/notifications/{bus_ID}";
initializeApp({
  credential: applicationDefault(),
  projectId: "vit-bus-tracking",
});

// eslint-disable-next-line require-jsdoc
function createCondition(busNumber, stopNumber) {
  return `'${busNumber}' in topics && '${stopNumber}' in topics`;
}

exports.androidPushNotif = functions.firestore
    .document(path)
    .onUpdate(async (snapshot, context) => {
      const busNumber = snapshot.before.data().id;

      const emOriginal = snapshot.before.data().emergency;
      const emUpdated = snapshot.after.data().emergency;

      const stopOriginal = snapshot.before.data().currentStop;
      const stopUpdated = snapshot.after.data().currentStop;

      if (emOriginal == false && emUpdated == true) {
        const message = {
          notification: {
            title: "Bus Change",
            body: "A different bus is coming to pick you up",
          },
          data: {
            "category": "emergency",
          },
          android: {
            notification: {
              sound: "alert",
              channel_id: "vit_bus_tracking 2",
              color: "#FF0000",
            },
          },
          topic: busNumber,
        };

        admin
            .messaging()
            .send(message)
            .then((response) => {
              console.log("Successfully sent message:", response);
            })
            .catch((error) => {
              console.log("Error sending message:", error);
            });
      } else if (stopOriginal !== stopUpdated) {
        const currentStop = parseInt(stopUpdated);
        const nextStop = currentStop + 1;
        const condition = createCondition(busNumber, nextStop);
        console.log(condition);
        const message = {
          notification: {
            title: "Bus Arriving Soon",
            body: "Bus will arrive at your stop in 5 minutes",
          },
          data: {
            "category": "update",
          },
          android: {
            notification: {
              sound: "update",
              channel_id: "vit_bus_tracking 3",
              color: "#00FF00",
            },
          },
          condition: condition,
        };
        admin
            .messaging()
            .send(message)
            .then((response) => {
              console.log("Successfully sent message:", response);
            })
            .catch((error) => {
              console.log("Error sending message:", error);
            });
      }
    });
