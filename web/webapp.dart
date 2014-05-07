import 'dart:html';
import 'dart:js';

main() {

  /*
      WebActivities:

          configure
          costcontrol/balance
          costcontrol/data_usage
          costcontrol/telephony
          dial
          new (type: "websms/sms", "webcontacts/contact") (add-contact, compose-mail?)
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
      new JsObject.fromBrowserObject(blobCanvas).callMethod("toBlob",[toBlobCallback]);

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
        context["Notification"].callMethod("requestPermission", [requestPermissionCallback]);

      }

      if (context["Notification"]["permission"] == "granted") {
        var notificationOptions = new JsObject.jsify({
          "body":"This is a notification"
        });
        new JsObject(context["Notification"], ["See this", notificationOptions]);
      }

    } else {
      // Firefox OS 1.0
      //WARNING: not tested yet
      var notify = context["navigator"]["mozNotification"].callMethod(
          "createNotification",
          ["See this", "This is a notification"]
      );
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
    var portraitLock = context["screen"].callMethod("mozLockOrientation", ["portrait"]);
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
    String online = "<strong>Connected:</strong> " + connection["bandwidth"].toString();
    String metered = "<strong>Metered:</strong> " + connection["metered"].toString();

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
    var getCurrentPositionCallback = (position) {
      geolocationDisplay
        ..innerHtml = "<strong>Latitude:</strong> ${position["coords"]["latitude"]} "
                      "<strong>Longitude:</strong> ${position["coords"]["longitude"]}"
        ..style.display = 'block';
    };

    var getCurrentPositionFallback = () {
      geolocationDisplay
        ..innerHtml = "Failed to get your current location"
        ..style.display = 'block';
    };

    context["navigator"]["geolocation"].callMethod("getCurrentPosition",
        [getCurrentPositionCallback, getCurrentPositionFallback]);
  });

  ButtonElement ambientLight = querySelector('#ambient-light');
  ambientLight.onClick.listen((e) {
    DivElement ambientLightDisplay = querySelector('#ambient-light-display');
    ambientLightDisplay.style.display = 'block';
    print("Starting ambientLight fn");
    var onDeviceLightCallback = (event) {
      print("Callback called");
      // Read out the lux value
      print("Debug 3");
      print(event["value"]);
      print("Debug 4");
      print(event["value"].toString());
      String lux = "<strong>Ambient light: </strong>" + event.value + " lux";
      print("Lux is set");
      ambientLightDisplay.innerHtml = lux;
    };

    print("ondevicelight Event");
    context["ondevicelight"] = onDeviceLightCallback;
  });

  // Proximity
  ButtonElement proximity = querySelector('#proximity');
  proximity.onClick.listen((e) {
    DivElement proximityDisplay = querySelector('#proximity-display');
    proximityDisplay.style.display = 'block';
    var onDeviceProximityCallback = (event) {
      var prox = "<strong>Proximity: </strong>" + event["value"] + " cm<br>"
                 "<strong>Min value supported: </strong>" + event.min + " cm<br>"
                 "<strong>Max value supported: </strong>" + event.max + " cm";
    };
    context["ondeviceproximity"] = onDeviceProximityCallback;
  });

  ButtonElement userProximity = querySelector('#user-proximity');
  userProximity.onClick.listen((e) {
    DivElement userProximityDisplay = querySelector('#user-proximity-display');
    window.alert("Not implemented yet");
  });

  ButtonElement deviceOrientation = querySelector('#device-orientation');
  deviceOrientation.onClick.listen((e) {
    DivElement deviceOrientationDisplay = querySelector('#device-orientation-display');
    window.alert("Not implemented yet");
  });

  ButtonElement logVisibility = querySelector('#log-visibility');
  logVisibility.onClick.listen((e) {
    DivElement logVisibilityDisplay = querySelector('#log-visibility-display');
    window.alert("Not implemented yet");
  });

  ButtonElement crossDomainXhr = querySelector('#cross-domain-xhr');
  crossDomainXhr.onClick.listen((e) {
    DivElement crossDomainXhrDisplay = querySelector('#cross-domain-xhr-display');
    window.alert("Not implemented yet");
  });

  ButtonElement deviceStoragePictures = querySelector('#device-storage-pictures');
  deviceStoragePictures.onClick.listen((e) {
    DivElement deviceStoragePicturesDisplay = querySelector('#device-storiage-pictures-display');
    window.alert("Not implemented yet");
  });

  ButtonElement getAllContacts = querySelector('#get-all-contacts');
  getAllContacts.onClick.listen((e) {
    DivElement getAllContactsDisplay = querySelector('#get-all-contacts-display');
    window.alert("Not implemented yet");
  });

  ButtonElement keepscreen = querySelector('#keep-screen-on');
  keepscreen.onClick.listen((e) {
    window.alert("Not implemented yet");
  });

}