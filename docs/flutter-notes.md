# Introduction to Flutter on Mobile: Local Storage

## What is Flutter?
Flutter is an application development framework which ties together the Dart Virtual Machine (VM) and Material UI in a cross-platform ecosystem.

### Virtual Machines and Resource Management
A virtual machine (VM) is an application which is designed to emulate the hardware of another computer on the host device. They have been in use since 1964 as a way to share time on expensive servers at MIT. At their core, they are a way to share time and balance loads between applications being ran by different users on the same physical hardware. They are still being used in this way to this day.
- Control Program
- Console Monitor System

However, Virtual Machines can be adapted to various environments and use-cases. We are going to talk about Virtual Machines in the context of using them as a portable platform for application deployment.

### C
C is a general purpose programming language developed in 1972 by Dennis Ritchie at Bell Labs. C is a compiled language, requiring a compiler be written for each target device. It's syntax is prolific, and many modern languages use similar patterns to this language.

### Dart, Dart VM, and Dart SDK
Dart is a client device optimized programming language developed by Google in 2011. It follows a C-like syntax, and can compile to run on any device which can host the Dart VM or run JavaScript.

### Material UI
add info about Material UI

### Flutter
add info about flutter

## App Setup
To get started, you will neet to have an IDE, such as Visual Studio Code. You should also have Git installed. If building for Android, you will need to have the Android SDK installed. If building for iOS or MacOS, you will need to be using a Mac and have xCode tools installed.

Next, install the Flutter SDK. You can download the latest version from https://flutter.dev/docs/get-started/install. If using VS Code or a compatible IDE, you can install the Flutter extention and use the commands it provides to install and setup the SDK.

For a full tutorial on setting up a Flutter project, see https://docs.flutter.dev/learn/pathway/quick-install. Once finished, there are several tutorials available at https://dart.dev/learn/tutorial. If you have never used flutter before, consider completing a few of these before proceeding.

### Main Entrypoint
In `lib`, there should be a `main.dart` entrypoint file. Keep this file simple, we want to handle most of our initialization within the `app.dart` itself. However clients, which are pure Dart, can be configured here and passed into the app constructor before the app itself is initialized. Clients are needed by services, which the app wil initialize internally.

```
import 'package:flutter/material.dart';

import 'src/app.dart';
import 'src/clients/local_preferences_client.dart';
import 'src/models/interfaces/client_interface.dart';

void main() async {
  // Ensure Flutter binding is initialized before using async ops
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize clients
  final localPreferencesClient = LocalPreferencesClient();

  // Wrap clients in interface for dependency injection
  final clients = ClientInterface(
    preferences: localPreferencesClient,
  );

  // Run the app with injected client interface
  runApp(MyApp(clients: clients));
}
```
## App Initialization
In `lib/src`, there is another file called `app.dart` which is included in `lib/main.dart` and contains instructions for initializing the app.

### Layers
To contain the rest of the code in our application, let's create some directories for each layer of our application.

#### Model
Data models, no logic, no content. Just data shapes.

#### Utility
Class-less utilities which can be pulled in anywhere in the project for formatting, validation, or other use cases.

#### Client
Any code that interacts with the local device or a remote api.

#### Service
Business logic for processing client requests and managing them for the control layer.

#### Control
Control logic for processing completed service requests and linking the view layer to the service layer.

#### View
Top level UI layer for interacting with the user.

#### Component
Reusable components which can be embedded in the UI layer.

#### Localization
All of the copy text and localized strings should be defined here.

### Main App Widget
For the app itself, I am going to use a Stateful Widget. This allows our app to have a state which reacts to settings changes.

### References
https://www.c-language.org/about
https://dart.dev/
https://www.ibm.com/think/topics/virtual-machines
