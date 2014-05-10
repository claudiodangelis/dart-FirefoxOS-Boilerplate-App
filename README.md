This is an attempt of porting the legendary Firefox OS Boilerplate App by Robert Nyman to Dart.

## Running the app

To run the app you can simply open Firefox OS's browser and go to: [https://claudiodangelis.github.io/dart-FirefoxOS-Boilerplate-App/build/web](https://claudiodangelis.github.io/dart-FirefoxOS-Boilerplate-App/build/web) -- on top-right corner there will be a "+" button to install it. Warning: install button won't work out of the box because of app's security level.

If you want to install the app from your computer, get the code (`git clone https://github.com/claudiodangelis/dart-FirefoxOS-Boilerplate-App.git`) and learn how use Firefox's [App Manager](https://developer.mozilla.org/en-US/Firefox_OS/Using_the_App_Manager).



## Compiling the app

This code repository already has the compiled-to-Javscript version of the Boilerplate, these steps are needed only if you make some changes to the Dart code.

1. Get and install Dart => [Get Dart](https://www.dartlang.org/tools/download.html)
2. If you use Dart Editor, open the app's directory, right-click on file `pubspec.yaml` then choose "Pub Build ("generates JS")"; if you have `/path/to/dart-sdk/bin` in your $PATH, then change to app's directory and run `pub build` from the command line. 


## About this porting

The Boilerplate App focuses on MozActivities and other platform-specific Web APIs,
which are not available in Dart. In order to get them working this app uses
a library for interoperating with Javascript, for example this Javascript code

```
var pick = new MozActivity({
    name: "pick",
    data: {
        type: ["image/png", "image/jpg", "image/jpeg"],
        nocrop: true
    }
});

```

in Dart becomes:

```
var pick = new JsObject(context["MozActivity"], [
    new JsObject.jsify({
        "name": "pick",
        "data": {
            "type": ["image/png", "image/jpg", "image/jpeg"],
            "nocrop": true
        }
    });
]);
```

where `context` is the JS's window object. To get more information about JS<->Dart interoperability check this article: (https://www.dartlang.org/articles/js-dart-interop/)[https://www.dartlang.org/articles/js-dart-interop/].




## Roadmap

### WebActivities

- ~~Pick image~~
- ~~Pick anything~~
- ~~Take picture~~
- ~~Dial number~~
- ~~Send SMS~~
- ~~Add contact~~
- ~~Share URL~~
- ~~Share Image~~
- ~~View URL~~
- ~~Compose mail~~
- ~~Save bookmark~~
- ~~Open video~~

### WebAPIs

- ~~Add notification~~
- ~~Orientation lock~~
- ~~Vibrate 2 sec~~
- ~~Check connection~~
- ~~Check battery~~
- ~~Geolocation~~
- ~~Ambient light~~
- ~~Proximity~~
- ~~User proximity~~
- ~~Device orientation~~
- ~~Keep screen on~~

### Privileged APIs

- ~~App visibility~~
- ~~Cross-domain XHR~~
- ~~deviceStorage - pictures~~
- ~~Get all contacts~~

### Other

- ~~l18n~~
- ~~offline capabilities~~
- ~~comments~~
- ~~instructions on how to setup the environment and run the app~~

## TODO

- Implement more Dart features (e.g. native wrapper classes for MozActivities and Web APIs)
- Port the `l10n.js` script to Dart

## Credits

- [Robert Nyman](https://twitter.com/robertnyman) is the original creator of [Firefox OS Boilerplate App](https://github.com/robnyman/Firefox-OS-Boilerplate-App).
- [Daniele Scasciafratte](https://github.com/mte90) tested this app on his phones (Keon, Alcatel One Touch Fire), made quick fixes and designed the icon

## License

  MIT

## Author(s)
- Claudio d'Angelis - [@claudiodangelis](https://github.com/claudiodangelis)
- You! - [Fork this project](https://github.com/claudiodangelis/dart_FirefoxOS_boilerplate/fork)
