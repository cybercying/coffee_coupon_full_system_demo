# System manual of "Full Flutter System Demo for Coffee Coupons"

## SDK version and testing environment
Currently this system is tested using Flutter SDK 3.7.3, which includes Dart 2.19.2.
This application has been developed and tested in:
- Windows 7 64-bit (primary development)
- Android devices (Galaxy S10+ and Galaxy Tab S6)
 
Of course, in theory, Flutter can run on a variety of platforms, including iOS, web, macOS, and Linux, etc. But let's be honest, without actually testing on those devices, no one knows for sure. In my development environment, I have used [device_preview](https://pub.dev/packages/device_preview), which is a really nice tool to test against various screen sizes quickly. So different screen sizes shouldn't be a problem. If there is, please let me know.

### What about iPhone and iPad?
I do intend to test on iPhone and iPad. But you know Apple, you can't do that without actually having an iPhone and an iPad. Also, you must have a Mac in order to do the Xcode development. Frankly, that costs a fortune if you are not an Apple user. 

It's not like that I haven't developed on Apple's platform before. In fact, I did (in my own company [Genius Vision](https://geniusvision.net/)). I did have a MacBook Pro (and a MacBook Air), an iPhone, and an iPad. The full set, if you will. I also joined the Apple Developer Program and had a developer account and everything. Let's just say doing things for Apple could cost you a lot, and not just for one-time. You need to pay Apple continuously in order to _stay on_ their platform. The devices will soon be outdated, even Mac. My primary platform is not Apple so that makes it very expensive for me to do that. 

So that brings us back to the topic of [sponsorship](https://fundrazr.com/flutter_full_demo). I really like to take care of the Apple community, as long as I have enough funding. So please consider sponsoring me so that in addition to my basic needs, it can also pay for the fund needed to buy me an iPhone, an iPad, and a development Mac, and to (re)join the Apple Developer Program.

## How to setup remote server?
The demo app runs standalone with an embedded server, which requires no setup. This is convenient for simple demos. If you need to run actual remote scenario, the server code is located under [server](server/) subdirectory, written in pure Dart.

To run the server, first use **"dart pub get"** to install necessary dependencies. Then just use **"dart bin/server.dart"** in the server directory. It default listens to **port 8080**. The database is stored in the **".hive"** subdirectory of the server.

The API endpoint is located at **"/api"**. For example, if the hostname is "localhost", then the URL of the server API endpoint would be **"http://localhost:8080/api"**. This is the URL that is supposed to be entered in the "demo settings" in the demo app.

### Demo data setup
**Important!!** Before the server can do proper demo, you need to run "/setup" page in the browser for once. It creates necessary demo data that is the same as the embedded server.

If you use the "Data Setup" function in the demo app, it will reset the demo settings to use the embedded server. The data setup function doesn't affect the remote server (nor should it). If you want to reset remote server data to demo defaults, just delete the ".hive" subdirectory and rerun the "/setup" page.
