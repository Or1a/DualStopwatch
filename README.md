## DualStopwatch

DualStopwatch is a simple dual stopwatch app for macOS and iOS.
It lets you run two independent stopwatches, with support for customizable keyboard shortcuts for faster control.
It is designed for timing two tasks at the same time, such as experiments, workouts, study sessions, comparisons, gaming, or other parallel timing tasks.

<img width="1012" height="562" alt="DualStopwatch showing two independent stopwatches" src="https://github.com/user-attachments/assets/1e4bd443-166b-44b1-8dab-2816730a75a7" />

## Features

- Two independent stopwatches
- Start, pause, and reset each stopwatch separately
- Customizable keyboard shortcuts
- Clean and minimal interface
- Supports macOS, iPhone, and iPad

## Requirements

The current [Xcode project](DualStopwatch.xcodeproj/project.pbxproj) sets these minimum deployment versions:

| Platform | Minimum version |
| --- | --- |
| macOS | 14.0 |
| iOS / iPadOS | 17.0 |

To run from source, use a Mac with Xcode installed. For an iPhone or iPad simulator, also install iOS platform support in Xcode.

## Download

The macOS builds are available from the [Releases page](https://github.com/Or1a/DualStopwatch/releases/latest).

| File name ending | Choose this for |
| --- | --- |
| `_arm64.dmg` | Apple Silicon Macs |
| `_universal.dmg` | Intel Macs, or a package for both Intel and Apple Silicon Macs |

Download the appropriate `.dmg` file, open it, and drag `DualStopwatch.app` into the Applications folder. Open the app from Applications.

The current release provides macOS installers. To run the iOS / iPadOS app, build it from source with Xcode as described below.

## Run from source

### Open the project

Clone the repository and open its Xcode project:

```sh
git clone https://github.com/Or1a/DualStopwatch.git
cd DualStopwatch
open DualStopwatch.xcodeproj
```

Alternatively, select **Code → Download ZIP** on GitHub, extract the archive, and open `DualStopwatch.xcodeproj`.

Choose the `DualStopwatch` scheme in Xcode's toolbar. If it is not listed, open **Manage Schemes** from the scheme menu, click **+**, select the `DualStopwatch` target, and create a scheme named `DualStopwatch`.

### Run on macOS

Select **My Mac** as the run destination and choose **Product → Run** or press **Command-R**.

### Run in an iPhone or iPad simulator

1. Install iOS platform support if Xcode offers a **Get** button next to an iOS run destination.
2. Select an iPhone or iPad simulator with iOS / iPadOS 17.0 or later as the run destination.
3. Choose **Product → Run** or press **Command-R**. Xcode builds the app and launches it in the selected simulator.

### Run on an iPhone or iPad

1. Connect the device to your Mac and accept **Trust This Computer** on the device if prompted.
2. Sign in with your Apple Account in Xcode's settings.
3. Select the project in Xcode, then the `DualStopwatch` target. Open **Signing & Capabilities**, enable **Automatically manage signing**, and choose your own **Team**.
4. Set a unique **Bundle Identifier** for your copy, such as `com.yourname.DualStopwatch`.
5. Enable **Developer Mode** on the device when prompted and complete the device setup in Xcode.
6. Select the connected device as the run destination, then choose **Product → Run** or press **Command-R**.

For Xcode's simulator and device setup details, see Apple's [Running your app on simulated or physical devices](https://developer.apple.com/documentation/xcode/running-your-app-on-simulated-or-physical-devices).
