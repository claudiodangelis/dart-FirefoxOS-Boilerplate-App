import 'dart:html';

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
            deviceStoragePicturesDisplay = querySelector('#device-storiage-pictures-display'),
            getAllContactsDisplay = querySelector('#get-all-contacts-display');

main() {
  pickImage.onClick.listen((e) => print("It's going to work"));
}