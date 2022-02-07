# BiteTracker - SimpleDataCollector
A group of watchOS and macOS apps to collect motion data and record instances
of eating and drinking throughout the day. SimpleDataCollector is an independent
watchOS app that collects raw motion data from the apple watch. This data is then
exported to a macOS app for viewing via cloudKit. The watch app will track x,y,z
acceleration, gyroscope motion, and user-driven timestamps.

## Features
- Record motion data in background on independent watchOS app
- GUI to record user-entered timestamp of eating events (button)
- Export motion and time data to cloud (possibly implement another button)
- Create macOS app to gather and sort data from cloud

> This is a Clemson ECE research project led by [Dr. Adam Hoover] as part of his
> Eating Detection research.
> Coded by John Lawler (Graduate CpE) and Cameron Burroughs (Undergraduate CpE).
> More information can be found here: http://cecas.clemson.edu/~ahoover/eat-detect/

## Technology
BiteTracker uses mostly apple technologies to record, export, and import data.
- Xcode Version 13.2.1 - Text-editor, compiler, and simulator.
- cloudKit - container to hold data
- Objective-C - primary programming language
- Swift - secondary programming language
- GitHub - repository for collaboration

## Creating Independent watchOS app in Xcode
1. open Xcode
2. File -> New -> Project
3. In project template window, select watchOS -> Watch App
4. Bundle identifier: com.hoover.[ProductName]
5. Interface: Storyboard
6. Language: Objective-C (or Swift)

## Compilation/ Simulation
To build project:
- Product -> Build For -> Testing
- Shortcut: shift + ⌘ + U

To build & run:
- Product -> Build For -> Running
- Shortcut: shift + ⌘ + R
- Or click the arrow on the top bar, far left

To select Simulator or Device:
- Go to top bar, next to "[ProductName] WatchKit App", select the simulator symbol
- if you want to run on a physical device: select from top "devices" section
- if you want to simulate, scroll down to "IOS simulators" section, choose

End run/simulation by clicking "stop" square button on the top bar, far left

> NOTE: no need to select target for build on idenpendent watchOS app
> it will automatically build for the watch app target.

## App Hierarchy:
Project Name:
- DataCollector

Targets:
- WatchKit App
- WatchKit Extension

> NOTE: Will possibly add another top level "Workspace" that will contain macOS project
and its corresponding targets.

## Dataflow Options:
- *Independent watchOS app -> cloudKit server -> macOS app
- watchOS app -> companion IOS app -> dropBox Server -> macOS app
- watchOS app -> companion IOS app -> download container to computer -> macOS app

*We are currently proceeding with this dataflow path

### File System Diagrams
![The App Sandbox](https://developer.apple.com/library/archive/documentation/FileManagement/Conceptual/FileSystemProgrammingGuide/art/ios_app_layout_2x.png)

## CloudKit Research
- Access to CloudKit data based on Apple ID, do not need in-app sign in
- Uses URLSession, makes request over Wifi or cellular connection
- [CloudKit Console] to accesss cloud container
- [CloudKit Development] (container structure, environments, permissions, connectivity etc.)

## Adding  CLoudKit Capabilities
- In XCode Project Navigator, select project and project target
- "Signing and Capabilities", click "Automatically manage signing"
- Click "+ Capability" -> "iCloud", verify it shows in capabilities page

## Important Resrouces
 Videos, Apple Developer Documentation, and other resources we referenced
 frequently while creating this project.
 - [File System Programming Guide] | Apple Developers
 - [Intro to NSFileManager] | Ray Wenderlich
 - [CloudKit Development] | Apple Developers
 - [iCloud Design Guide] | Apple Developers



[//]: # (These are reference links used in the body of this note and get stripped out when the markdown processor does its job. There is no need to format nicely because it shouldn't be seen.)

[Dr. Adam Hoover]: <http://cecas.clemson.edu/~ahoover/>
[File System Programming Guide]: <https://developer.apple.com/library/archive/documentation/FileManagement/Conceptual/FileSystemProgrammingGuide/Introduction/Introduction.html#//apple_ref/doc/uid/TP40010672-CH1-SW1>
[Intro to NSFileManager]: <https://www.youtube.com/watch?v=eC7_cddT6wM>
[CLoudKit Development]: <https://developer.apple.com/icloud/cloudkit/designing/>
[CloudKit Console]: <https://icloud.developer.apple.com/>
[iCloud Design Guide]: <https://developer.apple.com/library/archive/documentation/General/Conceptual/iCloudDesignGuide/Chapters/DesigningForDocumentsIniCloud.html#//apple_ref/doc/uid/TP40012094-CH2>
[iCloud File Management]: <https://developer.apple.com/library/archive/documentation/FileManagement/Conceptual/FileSystemProgrammingGuide/iCloud/iCloud.html#//apple_ref/doc/uid/TP40010672-CH12-SW1>


