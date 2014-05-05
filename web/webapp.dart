import 'dart:html';
import 'dart:js';

// Top-level DOM elements
ButtonElement pickImage       = querySelector('#pick-image'),
              pickAnything    = querySelector('#pick-anything'),
              record          = querySelector('#record'),
              dial            = querySelector('#dial'),
              sendSms         = querySelector('#send-sms'),
              addContact      = querySelector('#add-contact'),
              share           = querySelector('#share'),
              shareImage      = querySelector('#share-image'),
              viewUrl         = querySelector('#view-url'),
              composeEmail    = querySelector('#compose-email'),
              saveBookmark    = querySelector('#save-bookmark'),
              openVideo       = querySelector('#open-video'),
              addNotification = querySelector('#add-notification'),
              lockOrientation = querySelector('#lock-orientation'),
              vibrate         = querySelector('#vibrate'),
              checkConnection = querySelector('#check-connection'),
              checkBattery    = querySelector('#check-battery'),
              geolocation     = querySelector('#geolocation'),
              ambientLight    = querySelector('#ambient-light'),
              proximity       = querySelector('#proximity'),
              userProximity   = querySelector('#user-proximity'),
              deviceOrientation = querySelector('#device-orientation'),
              logVisibility   = querySelector('#log-visibility'),
              crossDomainXhr  = querySelector('#cross-domain-xhr'),
              deviceStoragePictures = querySelector('#device-storage-pictures'),
              getAllContacts  = querySelector('#get-all-contacts'),
              keepscreen      = querySelector('#keep-screen-on');

ImageElement imgToShare = querySelector('#image-to-share');

DivElement  connectionDisplay     = querySelector('#connection-display'),
            batteryDisplay        = querySelector('#battery-display'),
            geolocationDisplay    = querySelector('#geolocation-display'),
            ambientLightDisplay   = querySelector('#ambient-light-display'),
            proximityDisplay      = querySelector('#proximity-display'),
            userProximityDisplay  = querySelector('#user-proximity-display'),
            deviceOrientationDisplay = querySelector('#device-orientation-display'),
            logVisibilityDisplay  = querySelector('#log-visibility-display'),
            crossDomainXhrDisplay = querySelector('#cross-domain-xhr-display'),
            deviceStoragePicturesDisplay = querySelector('#device-storiage-pictures-display'),
            getAllContactsDisplay = querySelector('#get-all-contacts-display');

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
  pickImage.onClick.listen((e) {
    // For a more readable code, we separate declare options outside the
    // MozActivity constructor
    JsObject pickOptions = new JsObject.jsify({
      "name": "pick",
      "data": {
        "type": ["image/png", "image/jpg", "image/jpeg"],
        // In FxOS 1.3 and before the user is allowed to crop the
        // image by default, but this can cause out-of-memory issues
        // so we explicitly disable it.
        "nocrop": true // don't allow the user to crop the image
      }
    });
    JsObject pick = new JsObject(context["MozActivity"], [pickOptions]);
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

  pickAnything.onClick.listen((e) {
    JsObject pickAnyOptions = new JsObject.jsify({"name":"pick"});
    JsObject pickAny = new JsObject(context["MozActivity"], [pickAnyOptions]);
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

  record.onClick.listen((e) {
    JsObject recOptions = new JsObject.jsify({
      "name":"record", // Possibly capture in future versions
      "data": {"type":["photos"]}
    });
    JsObject rec = new JsObject(context["MozActivity"], [recOptions]);
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

  dial.onClick.listen((e) {
    JsObject dialOptions = new JsObject.jsify({
      "name": "dial",
      "data": {
        "number": "+46777888999"
      }
    });
    new JsObject(context["MozActivity"], [dialOptions]);
  });

  sendSms.onClick.listen((e) {
    JsObject sendSmsOptions = new JsObject.jsify({
      "name": "new", // Possible compose-sms in future versions
      "data": {
        "type":"websms/sms",
        "number":"+46777888999"
      }
    });

    new JsObject(context["MozActivity"], [sendSmsOptions]);
  });

  addContact.onClick.listen((e) {
    JsObject addContactOptions = new JsObject.jsify({
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

  share.onClick.listen((e) {
    JsObject sOptions = new JsObject.jsify({
      "name": "share",
      "data": {
        //type: "url", // Possibly text/html in future versions
        "number": 1,
        "url": "http://robertnyman"
      }
    });

    new JsObject(context["MozActivity"], [sOptions]);
  });

  shareImage.onClick.listen((e) {
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
        JsObject sOptions = new JsObject.jsify({
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

  viewUrl.onClick.listen((e) {
    JsObject viewOptions = new JsObject.jsify({
      "name": "view",
      "data": {
        "type": "url",  // Possibly text/html in future versions
        "url": "http://robertnyman.com"
      }
    });
    new JsObject(context["MozActivity"], [viewOptions]);
  });

  composeEmail.onClick.listen((e) {
    JsObject composeEmailOptions = new JsObject.jsify({
      "name": "new",  // Possibly compose-mail in future versions
      "data": {
        "type": "mail",
        "url": "mailto:example@example.org"
      }
    });
    new JsObject(context["MozActivity"], [composeEmailOptions]);
  });

  saveBookmark.onClick.listen((e) {
    JsObject saveBookmarkOptions = new JsObject.jsify({
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

  openVideo.onClick.listen((e) {
    JsObject openVideoOptions = new JsObject.jsify({
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
        JsObject notificationOptions = new JsObject.jsify({
          "body":"This is a notification"
        });
        new JsObject(context["Notification"], ["See this", notificationOptions]);
      }

    } else {
      // Firefox OS 1.0
      //WARNING: not tested yet
      JsObject notify = context["navigator"]["mozNotification"].callMethod(
          "createNotification",
          ["See this", "This is a notification"]
      );
      notify.callMethod("show");
    }
  });

  lockOrientation.onClick.listen((e) {
    print("Not implemented yet");
  });

  vibrate.onClick.listen((e) {
    print("Not implemented yet");
  });

  checkConnection.onClick.listen((e) {
    print("Not implemented yet");
  });

  checkBattery.onClick.listen((e) {
    print("Not implemented yet");
  });

  geolocation.onClick.listen((e) {
    print("Not implemented yet");
  });

  ambientLight.onClick.listen((e) {
    print("Not implemented yet");
  });

  proximity.onClick.listen((e) {
    print("Not implemented yet");
  });

  userProximity.onClick.listen((e) {
    print("Not implemented yet");
  });

  deviceOrientation.onClick.listen((e) {
    print("Not implemented yet");
  });

  logVisibility.onClick.listen((e) {
    print("Not implemented yet");
  });

  crossDomainXhr.onClick.listen((e) {
    print("Not implemented yet");
  });

  deviceStoragePictures.onClick.listen((e) {
    print("Not implemented yet");
  });

  getAllContacts.onClick.listen((e) {
    print("Not implemented yet");
  });

  keepscreen.onClick.listen((e) {
    print("Not implemented yet");
  });

}