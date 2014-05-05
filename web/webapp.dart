import 'dart:html';
import 'dart:js';

// Top-level DOM elements
ButtonElement pickImage = querySelector('#pick-image'),
              pickAnything = querySelector('#pick-anything'),
              record = querySelector('#record'),
              dial = querySelector('#dial'),
              sendSms = querySelector('#send-sms'),
              addContact = querySelector('#add-contact'),
              share = querySelector('#share'),
              shareImage = querySelector('#share-image'),
              viewUrl = querySelector('#view-url'),
              composeEmail = querySelector('#compose-email'),
              saveBookmark = querySelector('#save-bookmark'),
              openVideo = querySelector('#open-video'),
              addNotification = querySelector('#add-notification'),
              lockOrientation = querySelector('#lock-orientation'),
              vibrate = querySelector('#vibrate'),
              checkConnection = querySelector('#cehck-connection'),
              checkBattery = querySelector('#check-battery'),
              geolocation = querySelector('#geolocation'),
              ambientLight = querySelector('#ambient-light'),
              proximity = querySelector('#proximity'),
              userProximity = querySelector('#user-proximity'),
              deviceOrientation = querySelector('#device-orientation'),
              logVisibility = querySelector('#log-visibility'),
              crossDomainXhr = querySelector('#cross-domain-xhr'),
              deviceStoragePictures = querySelector('#device-storage-pictures'),
              getAllContacts = querySelector('#get-all-contacts'),
              keepscreen = querySelector('#keep-screen-on');

ImageElement imgToShare = querySelector('#image-to-share');

DivElement  connectionDisplay = querySelector('#connection-display'),
            batteryDisplay = querySelector('#battery-display'),
            geolocationDisplay = querySelector('#geolocation-display'),
            ambientLightDisplay = querySelector('#ambient-light-display'),
            proximityDisplay = querySelector('#proximity-display'),
            userProximityDisplay = querySelector('#user-proximity-display'),
            deviceOrientationDisplay = querySelector('#device-orientation-display'),
            logVisibilityDisplay =  querySelector('#log-visibility-display'),
            crossDomainXhrDisplay = querySelector('#cross-domain-xhr-display'),
            deviceStoragePicturesDisplay =querySelector('#device-storiage-pictures-display'),
            getAllContactsDisplay = querySelector('#get-all-contacts-display');

main() {
  // WebActivities
  pickImage.onClick.listen((e) {
    // For a more readable code, we separate declare options outside the
    // MozActivity constructor
    JsObject pickOptions = new JsObject.jsify({
      "name": "pick",
      "data": {
        "type": ["image/png", "image/jpg", "image/jpeg"],
        "nocrop": true
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
  
  
}