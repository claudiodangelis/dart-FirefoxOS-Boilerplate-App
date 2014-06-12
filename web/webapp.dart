// Built-in libraries import:
//
// dart:html => classes and functions to interact with the browser and the DOM
// dart:js => support for interoperating with Javascript
import 'dart:html';
import 'dart:js' show context, JsObject;
import 'dart:convert' show JSON;

// `main()' is the entry point of a Dart app
main() {
  // Appcache
  var appCache = window.applicationCache;

  if (appCache != null) {
    appCache.onUpdateReady.listen((e) {
      if (window.confirm("The app has been updated.Do you want to download the"
        "latest files? \nOtherwise they will be updated at the next reload.")) {
          window.location.reload();
      }
    });

    DivElement displayStatus = querySelector('#online-status');
    appCache.onError.listen((e) {
      displayStatus.className = 'offline';
      displayStatus.title = 'Offline';
    });
  }

  /*
      WebActivities:

          configure
          costcontrol/balance
          costcontrol/data_usage
          costcontrol/telephony
          dial
          new (type: "websms/sms", "webcontacts/contact") (add-contact,
            compose-mail?)
          open
          pick (type: "image/png" etc)
          record (capture?)
          save-bookmark
          share
          test
          view (type: "url" etc. "text/html"?)
  */

  // WebActivities
  ButtonElement pickImage = querySelector('#pick-image');
  pickImage.onClick.listen((e) {
    // For a more readable code, we separate declare options outside the
    // MozActivity constructor
    var pickOptions = new JsObject.jsify({
      "name": "pick",
      "data": {
        "type": ["image/png", "image/jpg", "image/jpeg"],
        // In FxOS 1.3 and before the user is allowed to crop the
        // image by default, but this can cause out-of-memory issues
        // so we explicitly disable it.
        "nocrop": true // don't allow the user to crop the image
      }
    });
    var pick = new JsObject(context["MozActivity"], [pickOptions]);
    pick["onsuccess"] = (_) {
      ImageElement img = new ImageElement();
      img.src = Url.createObjectUrlFromBlob(pick["result"]["blob"]);
      DivElement imagePresenter = querySelector('#image-presenter');
      // `..' is the cascade operator. `imagePresenter' is the receiver for both
      // methods
      imagePresenter
        ..append(img)
        ..style.display = 'block';
    };

    pick["onerror"] = (_) {
      print("Can't view the image");
    };
  });

  ButtonElement pickAnything = querySelector('#pick-anything');
  pickAnything.onClick.listen((e) {
    var pickAnyOptions = new JsObject.jsify({"name":"pick"});
    var pickAny = new JsObject(context["MozActivity"], [pickAnyOptions]);
    pickAny["onsuccess"] = (_){
      ImageElement img = new ImageElement();
      if (pickAny["result"]["type"].startsWith("image/")) {
        img.src = Url.createObjectUrlFromBlob(pickAny["result"]["blob"]);
        DivElement imagePresenter = querySelector('#image-presenter');
        imagePresenter
          ..append(img)
          ..style.display = 'block';
      }
    };
    pickAny["onerror"] = (_) {
      print("An error occurred");
    };
  });

  ButtonElement record = querySelector('#record');
  record.onClick.listen((e) {
    var recOptions = new JsObject.jsify({
      "name":"record", // Possibly capture in future versions
      "data": {"type":["photos"]}
    });
    var rec = new JsObject(context["MozActivity"], [recOptions]);
    rec["onsuccess"] = (_) {
      ImageElement img = new ImageElement();
      img.src = Url.createObjectUrlFromBlob(rec["result"]["blob"]);
      DivElement imagePresenter = querySelector('#image-presenter');
      imagePresenter
        ..append(img)
        ..style.display = 'block';
    };

    rec["onerror"] = (_) {
      window.alert("No taken picture returned");
    };
  });

  ButtonElement dial = querySelector('#dial');
  dial.onClick.listen((e) {
    var dialOptions = new JsObject.jsify({
      "name": "dial",
      "data": {
        "number": "+46777888999"
      }
    });
    new JsObject(context["MozActivity"], [dialOptions]);
  });

  ButtonElement sendSms = querySelector('#send-sms');
  sendSms.onClick.listen((e) {
    var sendSmsOptions = new JsObject.jsify({
      "name": "new", // Possible compose-sms in future versions
      "data": {
        "type":"websms/sms",
        "number":"+46777888999"
      }
    });

    new JsObject(context["MozActivity"], [sendSmsOptions]);
  });

  ButtonElement addContact = querySelector('#add-contact');
  addContact.onClick.listen((e) {
    var addContactOptions = new JsObject.jsify({
      "name": "new", // Possibly add-contact in future versions
      "data": {
        "type": "webcontacts/contact",
        "params": { // Will possibly move to be direct properties under "data"
          "givenName": "Robert",
          "lastName": "Nyman",
          "tel": "+44789",
          "email": "robert@mozilla.com",
          "address": "San Francisco",
          "note": "This is a note",
          "company": "Mozilla"
        }
      }
    });
    new JsObject(context["MozActivity"], [addContactOptions]);
  });

  ButtonElement share = querySelector('#share');
  share.onClick.listen((e) {
    var sOptions = new JsObject.jsify({
      "name": "share",
      "data": {
        //type: "url", // Possibly text/html in future versions
        "number": 1,
        "url": "http://robertnyman"
      }
    });

    new JsObject(context["MozActivity"], [sOptions]);
  });

  ButtonElement shareImage = querySelector('#share-image');
  shareImage.onClick.listen((e) {
    ImageElement imgToShare = querySelector('#image-to-share');
    if (imgToShare.naturalWidth > 0) {
      // Create dummy canvas
      CanvasElement blobCanvas = new CanvasElement();
      blobCanvas.width = imgToShare.width;
      blobCanvas.height = imgToShare.height;

      // Get context and draw image
      CanvasRenderingContext2D blobCanvasContext = blobCanvas.getContext('2d');
      blobCanvasContext.drawImage(imgToShare, 0, 0);

      // Export to blob and share through a Web Activity
      //
      // Note: `toBlob()' method is not available in Dart API, we'using the one
      // from Javascript with a little workaround

      var toBlobCallback = (Blob blob) {
        var sOptions = new JsObject.jsify({
          "name": "share",
          "data": {
            "type": "image/*",
            "number": 1,
            "blobs": [blob]
          }
        });
        new JsObject(context["MozActivity"], [sOptions]);
      };
      new JsObject.fromBrowserObject(blobCanvas).callMethod("toBlob",
          [toBlobCallback]);

    } else {
      window.alert("Image failed to load, can't be shared");
    }
  });

  ButtonElement viewUrl = querySelector('#view-url');
  viewUrl.onClick.listen((e) {
    var viewOptions = new JsObject.jsify({
      "name": "view",
      "data": {
        "type": "url",  // Possibly text/html in future versions
        "url": "http://robertnyman.com"
      }
    });
    new JsObject(context["MozActivity"], [viewOptions]);
  });

  ButtonElement composeEmail = querySelector('#compose-email');
  composeEmail.onClick.listen((e) {
    var composeEmailOptions = new JsObject.jsify({
      "name": "new",  // Possibly compose-mail in future versions
      "data": {
        "type": "mail",
        "url": "mailto:example@example.org"
      }
    });
    new JsObject(context["MozActivity"], [composeEmailOptions]);
  });

  ButtonElement saveBookmark = querySelector('#save-bookmark');
  saveBookmark.onClick.listen((e) {
    var saveBookmarkOptions = new JsObject.jsify({
      "name": "save-bookmark",
      "data": {
        "type": "url",
        "url": "http://robertnyman.com",
        "name": "Robert's talk",
        "icon": "http://robertnyman.com/favicon.png"
      }
    });
    new JsObject(context["MozActivity"], [saveBookmarkOptions]);
  });

  ButtonElement openVideo = querySelector('#open-video');
  openVideo.onClick.listen((e) {
    var openVideoOptions = new JsObject.jsify({
      "name": "open",
      "data": {
        "type": [
          "video/webm",
          "video/mp4",
          "video/3gpp",
          "video/youtube"
        ],
        "url": "http://v2v.cc/~j/theora_testsuite/320x240.ogg"
      }
    });
    new JsObject(context["MozActivity"], [openVideoOptions]);
  });

  // Open settings
  ButtonElement openSettings = querySelector("#open-settings");
  openSettings.onClick.listen((e) {
    new JsObject(context["MozActivity"], [new JsObject.jsify({
      "name": "configure",
      "target": "device"
    })]);
  });

  // Notifications
  ButtonElement addNotification = querySelector('#add-notification');
  addNotification.onClick.listen((e) {
    //Note: Dart's Notification API seems not to be working fine when compiled
    // to Javascript right now, we will use the Javascript implementation here
    if (context.hasProperty("Notification")) {
      // Firefox OS 1.1 and higher
      if (context["Notification"]["permission"] != "denied") {
        var requestPermissionCallback = (permission) {
          if (!context["Notification"].hasProperty("permission")) {
            context["Notification"]["permission"] = permission;
          }
        };
        context["Notification"].callMethod("requestPermission",
            [requestPermissionCallback]);
      }

      if (context["Notification"]["permission"] == "granted") {
        var notificationOptions = new JsObject.jsify({
          "body":"This is a notification"
        });
        new JsObject(context["Notification"], ["See this",
                                               notificationOptions]);
      }

    } else {
      // Firefox OS 1.0
      // WARNING: not tested yet
      var notify = context["navigator"]["mozNotification"].callMethod(
          "createNotification", ["See this", "This is a notification"]);
      notify.callMethod("show");
    }
  });

  // Lock orientation
  ButtonElement lockOrientation = querySelector('#lock-orientation');
  lockOrientation.onClick.listen((e) {
    /*
        Possible values:
            "landscape",
            "portrait"
            "landscape-primary"
            "landscape-secondary"
            "portrait-primary"
            "portrait-secondary"
    */
    var portraitLock = context["screen"].callMethod("mozLockOrientation",
        ["portrait"]);
    if (portraitLock != null) { // In Dart only `true' is `true'
      window.alert("Orientation locked to potrait");
    }
  });

  // Vibration
  ButtonElement vibrate = querySelector('#vibrate');
  vibrate.onClick.listen((e) {
    context["navigator"].callMethod("vibrate", [2000]);
    /*
        Possible values:
        On/off pattern:
        navigator.vibrate([200, 100, 200, 100]);

        Turn off vibration
        navigator.vibrate(0);
    */
  });

  // Check connection
  ButtonElement checkConnection = querySelector('#check-connection');
  checkConnection.onClick.listen((e) {
    DivElement connectionDisplay = querySelector('#connection-display');
    var connection = context["navigator"]["mozConnection"];
    //FIXME
    String online = "<strong>Connected:</strong> " +
        connection["bandwidth"].toString();
    String metered = "<strong>Metered:</strong> " +
        connection["metered"].toString();

    connectionDisplay
      ..innerHtml = "<h4>Result from Check connection</h4>" +
                                  online + "<br/>" +
                                  metered
      ..style.display = 'block';
  });

  // Check battery
  ButtonElement checkBattery = querySelector('#check-battery');
  checkBattery.onClick.listen((e) {
    DivElement batteryDisplay = querySelector('#battery-display');
    var battery = context["navigator"]["battery"],
        batteryLevel = "${(battery["level"] * 100).round()}%",
        charghing = battery["charging"],
        chargingTime = battery["chargingTime"] / 60,
        dischargingTime = battery["dischargingTime"] / 60,
        batteryInfo = "<h4>Result from Check battery</h4>" +
                      "<strong>Battery level:</strong> $batteryLevel <br/>" +
                      "<strong>Battery charging:</strong> $charghing <br/>" +
               "<strong>Battery charging time:</strong> $chargingTime <br>" +
               "<strong>Battery discharging time:</strong> $dischargingTime";

    batteryDisplay
      ..innerHtml = batteryInfo
      ..style.display = 'block';
  });

  // Geolocation
  ButtonElement geolocation = querySelector('#geolocation');
  geolocation.onClick.listen((e) {
    DivElement geolocationDisplay = querySelector('#geolocation-display');
    window.navigator.geolocation.getCurrentPosition().then((Geoposition pos) {
      geolocationDisplay
        ..innerHtml = "<strong>Latitude:</strong>"
                      "${pos.coords.latitude}"
                      "<strong>Longitude:</strong>"
                      "${pos.coords.longitude}"

        ..style.display = 'block';

    }, onError: (PositionError error) {
      geolocationDisplay
        ..innerHtml = "Failed to get your current location"
        ..style.display = 'block';
    });

//    var getCurrentPositionCallback = (position) {
//      geolocationDisplay
//        ..innerHtml = "<strong>Latitude:</strong>"
//                      "${position["coords"]["latitude"]}"
//                      "<strong>Longitude:</strong>"
//                      "${position["coords"]["longitude"]}"
//
//        ..style.display = 'block';
//    };
//
//    var getCurrentPositionFallback = () {
//      geolocationDisplay
//        ..innerHtml = "Failed to get your current location"
//        ..style.display = 'block';
//    };
//
//    context["navigator"]["geolocation"].callMethod("getCurrentPosition",
//        [getCurrentPositionCallback, getCurrentPositionFallback]);
  });

  ButtonElement ambientLight = querySelector('#ambient-light');
  ambientLight.onClick.listen((e) {
    DivElement ambientLightDisplay = querySelector('#ambient-light-display');
    ambientLightDisplay.style.display = 'block';
    var onDeviceLightCallback = (event) {
      // Read out the lux value
      String lux = "<strong>Ambient light: </strong> ${event["value"]} lux";
      ambientLightDisplay.innerHtml = lux;
    };

    context["ondevicelight"] = onDeviceLightCallback;
  });

  // Proximity
  ButtonElement proximity = querySelector('#proximity');
  proximity.onClick.listen((e) {
    DivElement proximityDisplay = querySelector('#proximity-display');
    proximityDisplay.style.display = 'block';
    var onDeviceProximityCallback = (event) {
      var prox = "<strong>Proximity: </strong> ${event["value"]} cm<br>"
                 "<strong>Min value supported: </strong> ${event["min"]} cm<br>"
                 "<strong>Max value supported: </strong> ${event["max"]} cm";
    };
    context["ondeviceproximity"] = onDeviceProximityCallback;
  });

  // User proximity
  ButtonElement userProximity = querySelector('#user-proximity');
  userProximity.onClick.listen((e) {
    DivElement userProximityDisplay = querySelector('#user-proximity-display');
    context["onuserproximity"] = (event) {
      // Check user proximity
      String userProx = "<strong>User proximity - near:</strong>"
          "${event["near"]}<br/>";

          userProximityDisplay
        ..innerHtml = userProx
        ..style.display = 'block';
    };
  });

  // Device orientation
  ButtonElement deviceOrientation = querySelector('#device-orientation');
  deviceOrientation.onClick.listen((e) {
    DivElement deviceOrientationDisplay =
        querySelector('#device-orientation-display');

    context["ondeviceorientation"] = (event) {
      String orientedTo = (event["beta"] > 45 && event["beta"] < 135) ? "top" :
        (event["beta"] < -45 && event["beta"] > -135) ? "bottom" :
          (event["gamma"] > 45) ? "right" :
            (event["gamma"] < -45) ? "left" :
              "flat";

      String orientation = "<strong>Absolute: </strong>${event["absolute"]}<br>"
                           "<strong>Alpha: </strong>  ${event["alpha"]}<br>"
                           "<strong>Beta: </strong> ${event["beta"]}<br>"
                           "<strong>Gamma: </strong> ${event["gamma"]}<br>"
                           "<strong>Device orientation: </strong> $orientedTo";

      deviceOrientationDisplay.innerHtml = orientation;
    };
  });

  // Log visibility of the app
  ButtonElement logVisibility = querySelector('#log-visibility');
  logVisibility.onClick.listen((e) {
    DivElement logVisibilityDisplay = querySelector('#log-visibility-display');
    logVisibilityDisplay
      ..innerHtml = 'I have focus!<br/>'
      ..style.display = 'block';
    document.onVisibilityChange.listen((e) {
      // NOTE: Dart implementation of `document.hidden` is experimental and only
      // supported on Chrome and Safari at time of writing, using
      // `visiblityState' as a workaround.
      //
      // See API docs: http://goo.gl/nY7d3x
      switch(document.visibilityState) {
        case "visible":
          print("Firefox OS Boilerplate App has focus");
          logVisibilityDisplay.appendHtml("I have focus!<br/>");
          break;
        case "hidden":
          print("Firefox OS Boilerplate App is hidden");
          logVisibilityDisplay.appendHtml("Now I'm in the background<br/>");
          break;
      }
    });
  });

  ButtonElement crossDomainXhr = querySelector('#cross-domain-xhr');
  crossDomainXhr.onClick.listen((e) {
    var crossDomainXhrDisplay = querySelector('#cross-domain-xhr-display');
    // NOTE: We can not pass the constructor of HttpRequest (Dart implementation
    //  of `XMLHttpRequest' the parameter {mozSystem: true}, required by FFOS
    //  for cross-domains requests, so we'll use JS's XMLHttpRequest instead
    var xhr = new JsObject(context["XMLHttpRequest"],
        [new JsObject.jsify({"mozSystem":true})]);

    xhr.callMethod("open",
        ["GET",
         "http://robnyman.github.io/Firefox-OS-Boilerplate-App/README.md",
         true]);

    xhr["onreadystatechange"] = (_) {
      if (xhr["status"] == 200 && xhr["readyState"] == 4) {
        crossDomainXhrDisplay
          ..innerHtml = "<h4>Result from Cross-domain XHR</h4>"
                        "${xhr["response"]}"
          ..style.display = 'block';
      }
    };

    xhr["onerror"] = () {
      crossDomainXhrDisplay
        ..innerHtml = "<h4>Result from Cross-domain XHR</h4>"
                      "<p>Cross-domain XHR failed</p>"
        ..style.display = 'block';
    };

    xhr.callMethod("send");
  });

  // deviceStorage, pictures
  var deviceStoragePictures =querySelector('#device-storage-pictures');
  deviceStoragePictures.onClick.listen((e) {
    var deviceStoragePicturesDisplay =
        querySelector('#device-storage-pictures-display');

    var deviceStorage = context["navigator"].callMethod("getDeviceStorage",
        ["pictures"]);

    var cursor = deviceStorage.callMethod("enumerate");
    deviceStoragePicturesDisplay.innerHtml = "<h4>Result from deviceStorage"
        "- pictures</h4>";

    cursor["onsuccess"] = (_) {

      if (cursor["result"] == null) {
        deviceStoragePicturesDisplay.innerHtml = 'No files';
      }

      JsObject file = new JsObject.fromBrowserObject(cursor["result"]);
      String filePresentation;
      // FIXME: Use native Dart elements instead of mixing html and data
      String fileSrcUrl = context["URL"].callMethod("createObjectURL", [file]);
      filePresentation = "<strong> ${file["name"]}: </strong>"
                         "${file["size"] / 1024} kb<br>"
                         "<p><img src='$fileSrcUrl' alt=''></p>";

      deviceStoragePicturesDisplay
        ..appendHtml(filePresentation)
        ..style.display = 'block';
    };

    cursor["onerror"] = () {
      print("Error");
      deviceStoragePicturesDisplay
        ..innerHtml = "<h4>Result from deviceStorage - pictures</h4>"
                      "<p>deviceStorage failed</p>"
        ..style.display = 'block';
    };

  });

  // List contacts
  ButtonElement getAllContacts = querySelector('#get-all-contacts');
  getAllContacts.onClick.listen((e) {
    var getAllContactsDisplay = querySelector('#get-all-contacts-display');
    var getContacts = context["navigator"]["mozContacts"].callMethod("getAll",
        [new JsObject.jsify({})]);

    getAllContactsDisplay.style.display = 'block';

    getContacts["onsuccess"] = (_) {
      var result = getContacts["result"];
      if (result != null) {
        // FIXME: results should not look like [givenName] [familyName]
        getAllContactsDisplay.appendHtml("${result["givenName"]}"
                                         "${result["familyName"]}");
        getContacts.callMethod("continue");
      }
    };

    getContacts["onerror"] = () {
      getAllContactsDisplay.appendHtml('Error');
    };

  });

  // Keep screen on
  ButtonElement keepscreen = querySelector('#keep-screen-on');
  var lock = null;
  keepscreen.onClick.listen((e) {
    if (lock == null) {
      lock = context["navigator"].callMethod("requestWakeLock", ["screen"]);
      keepscreen.innerHtml = 'Remove the lock';

    } else {
      lock.callMethod("unlock");
      lock = null;
      keepscreen.innerHtml = 'Keep screen on';
    }
  });

  // Alarm API
  // Aug 31, 2014 15:20:00
  DateTime alarmDate = new DateTime(2014, 8, 31, 15, 20);
  ButtonElement addAlarm = querySelector("#add-alarm");
  DivElement alarmDisplay = querySelector('#alarm-display');

  addAlarm.onClick.listen((e) {
    var alarm = context["navigator"]["mozAlarms"].callMethod("add", [
      "honorTimezone", new JsObject.jsify({"optionalData" : "I am data"})
      ]);

    alarm["onsuccess"] = (_) {
      alarmDisplay.innerHtml = 'Alarm shceduled for ' + alarmDate.toString();
    };

    alarm["onerror"] = ([_]) {
      alarmDisplay.innerHtml = 'Failed to set the alarm<br/>' +
          alarm["error"]["name"].toString();
    };

    var getAllAlarms = context["navigator"]["mozAlarms"].callMethod("getAll");

    getAllAlarms["onsuccess"] = (_) {
      alarmDisplay.innerHtml = '<h4>All alarms</h4>';
      getAllAlarms["result"].callmethod("forEach", [(alarm) {
        alarmDisplay.innerHtml += "<p><strong>Id:</strong> " + alarm["id"].toString() +

                    ", <strong>date:</strong> " + alarm["date"].toString() +

                    ", <strong>respectTimezone:</strong> " + alarm["respectTimezone"].toString() +

                    ", <strong>data:</strong> " + JSON.decode(alarm["data"]).toString() + "</p>";
      }]);
    };

    getAllAlarms["onerror"] = ([_]) {
      alarmDisplay.innerHtml = '<p>Failed to get all alarms</p>' + getAllAlarms["error"]["name"].toString();
    };

  });


}