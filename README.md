# BiteTracker - SimpleDataCollector
<p>
A group of watchOS and macOS apps to collect motion data and record instances
of eating and drinking throughout the day. SimpleDataCollector is an independent
watchOS app that collects raw motion data from the apple watch. This data is then
exported to a macOS app for viewing via cloudKit. The watch app will track x,y,z
acceleration, gyroscope motion, and user-driven timestamps.
</p>

## Features
- Record motion data in background on independent watchOS app
- GUI to record user-entered timestamp of eating events (button)
- Export motion and time data to cloud (possibly implement another button)
- Create macOS app to gather and sort data from cloud

> This is a Clemson ECE research project led by [Dr. Adam Hoover] as part of his
> Eating Detection research.
> Coded by John Lawler (Graduate CpE) and Cameron Burroughs (Undergraduate Cpe).
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
Workspace: Data Logger
- Project: watchLog
  * Target: watchLog WatchKit App
  * Target: watchLog WatchKit Extension

- Project: dataFetch
  * Target: TBD

## Dataflow Options:
- *Independent watchOS app -> cloudKit server -> macOS app
- watchOS app -> companion IOS app -> dropBox Server -> macOS app
- watchOS app -> companion IOS app -> download container to computer -> macOS app

*** We are currently proceeding with this dataflow path
 Second and third dataflow options have a companion app, which would require watchkit connectivity to send data between apps. The second option would require user to download container, which is too complicated on the user side. Third option would require API calls to dropbox. First option provides the simpliest path from watch to macOS app with only CloudKit capabilities needed.

## CloudKit Steps:
- setup container with CKContainer.defaultContainer
- create recordID, using date string for recordID
- create record with custom type
  * recordType kind of like struct, each has different fields
  * recordType: Motion
    * Fields: Time (String) [NOTE: will eventually be CKAsset type, string used to initially test upload works correctly]
  * if each ID is date first, could sort/categorize them in macOS app by date
- each CKAssest is a file containing motion data for the day
  * may not need time field if we can extract time/date from record ID
- currently setup using public Database, may want to switch to private or shared later.

## CloudKit Databases
Public:
- everyone using the app can read this data.

Private: 
- unique to the app and the user, the user's unique app data
- user must be signed into icloud to access

Shared: 
- most advanced/complicated
- user still must be signed into iCloud Account to access
- multiple icloud users in a specified group can read this data

> NOTE: Can use a combination of public and private

### File System Diagrams
![The App Sandbox](https://developer.apple.com/library/archive/documentation/FileManagement/Conceptual/FileSystemProgrammingGuide/art/ios_app_layout_2x.png)
- Data Container holds data for app and user
- app can request access to additional containers (iCloud) during runtime
- apps are typically prohibited from creating/accessing files outside container directories

## CloudKit Research
- Access to CloudKit data based on Apple ID, do not need in-app sign in
- Uses URLSession, makes request over Wifi or cellular connection
- [CloudKit Console] to accesss cloud container
- [CloudKit Development] (container structure, environments, permissions, connectivity etc.)
- [iCloud File Management] storing/searching/moving documents in iCloud, responsible use

## Adding  CLoudKit Capabilities
- In XCode Project Navigator, select project and project target
- "Signing and Capabilities", click "Automatically manage signing"
- Click "+ Capability" -> "iCloud", verify it shows in capabilities page

### iCloud Document Storage Process   
1. app must request entitlements to access iCloud container directory [requesting access]
2. apps use iCloud storage APIs to configure/access iCloud directories and manage files
3. apps must use [file coordination] to read/write contents of file

## Important Resources
 Videos, Apple Developer Documentation, and other resources we referenced
 frequently while creating this project.
 - [File System Programming Guide] | Apple Developers
 - [Intro to NSFileManager] | Ray Wenderlich
 - [CloudKit Development] | Apple Developers
 - [iCloud Design Guide] | Apple Developers
 - [WatchKit Framework] | Apple Developers



[//]: # (These are reference links used in the body of this note and get stripped out when the markdown processor does its job. There is no need to format nicely because it shouldn't be seen.)

[Dr. Adam Hoover]: <http://cecas.clemson.edu/~ahoover/>
[File System Programming Guide]: <https://developer.apple.com/library/archive/documentation/FileManagement/Conceptual/FileSystemProgrammingGuide/Introduction/Introduction.html#//apple_ref/doc/uid/TP40010672-CH1-SW1>
[Intro to NSFileManager]: <https://www.youtube.com/watch?v=eC7_cddT6wM>
[CLoudKit Development]: <https://developer.apple.com/icloud/cloudkit/designing/>
[CloudKit Console]: <https://icloud.developer.apple.com/>
[iCloud Design Guide]: <https://developer.apple.com/library/archive/documentation/General/Conceptual/iCloudDesignGuide/Chapters/DesigningForDocumentsIniCloud.html#//apple_ref/doc/uid/TP40012094-CH2>
[iCloud File Management]: <https://developer.apple.com/library/archive/documentation/FileManagement/Conceptual/FileSystemProgrammingGuide/iCloud/iCloud.html#//apple_ref/doc/uid/TP40010672-CH12-SW1>
[WatchKit Framework]: <https://developer.apple.com/documentation/watchkit>
[requesting access]: <https://developer.apple.com/library/archive/documentation/General/Conceptual/iCloudDesignGuide/Chapters/iCloudFundametals.html#//apple_ref/doc/uid/TP40012094-CH6-SW13>
[file coordination]: <https://developer.apple.com/library/archive/documentation/General/Conceptual/iCloudDesignGuide/Chapters/DesigningForDocumentsIniCloud.html#//apple_ref/doc/uid/TP40012094-CH2-SW17>



