# Installation Guide for Greek Polytonic Keyboard

This document provides detailed instructions for installing, building, and testing the Greek Polytonic Keyboard extension for iOS.

## Prerequisites

Before you begin, make sure you have the following:

- macOS 11.0 or later
- Xcode 13.0 or later
- An Apple Developer account (for device testing and App Store distribution)
- An iOS device running iOS 14.0 or later (for testing)

## Development Environment Setup

### Installing Xcode

1. Download and install Xcode from the Mac App Store or from [Apple's developer website](https://developer.apple.com/xcode/).
2. Once installed, open Xcode and agree to the license terms.
3. Install the iOS simulator if prompted.

### Cloning the Repository

1. Open Terminal on your Mac.
2. Navigate to the directory where you want to store the project.
3. Clone the repository using Git:
   ```
   git clone https://github.com/yourusername/GreekPolytonicKeyboard.git
   ```
4. Navigate to the project directory:
   ```
   cd GreekPolytonicKeyboard
   ```

## Building the Project

### Opening in Xcode

1. Open the project in Xcode:
   ```
   open GreekPolytonicKeyboard.xcodeproj
   ```
   (If this file doesn't exist, look for a `.xcworkspace` file instead)

2. Wait for Xcode to index the project files.

### Configuring the Project

1. Select the project in the Project Navigator (left sidebar).
2. In the project editor, select the "GreekPolytonicKeyboardApp" target.
3. Go to the "Signing & Capabilities" tab.
4. Choose your development team from the dropdown menu.
5. Repeat steps 2-4 for the "GreekPolytonicKeyboard" target (the keyboard extension).

### Building and Running

1. At the top of Xcode, select the scheme you want to build:
   - "GreekPolytonicKeyboardApp" to build the container app
   - "GreekPolytonicKeyboard" to build just the keyboard extension

2. Choose a device or simulator to run on from the device menu.

3. Click the "Run" button (play icon) or press Cmd+R to build and run the project.

## Testing on a Simulator

1. After building and running the container app on a simulator:
2. Navigate to the iOS Settings app on the simulator.
3. Go to General > Keyboard > Keyboards > Add New Keyboard.
4. Select "Greek Polytonic Keyboard" from the list.
5. Return to the home screen and open any app that uses the keyboard (like Notes or Messages).
6. Tap on a text field to bring up the keyboard.
7. Tap the globe icon to switch to the Greek Polytonic Keyboard.
8. Test the basic functionality and long-press on vowels to test the polytonic variations.

## Testing on a Physical Device

1. Connect your iOS device to your Mac.
2. Select your device from the device menu in Xcode.
3. Build and run the app on your device.
4. Follow the same steps as above to enable the keyboard in iOS Settings.

## Common Issues and Troubleshooting

### Keyboard Extension Not Appearing in Settings

- Make sure the container app has been launched at least once.
- Check that both targets (app and extension) have valid signing configurations.
- Verify that the Info.plist for the keyboard extension has the correct bundle identifier.

### Keyboard Not Showing When Selected

- Try restarting the device or simulator.
- Make sure the "Allow Full Access" option is enabled for the keyboard in Settings.
- Check the console logs in Xcode for any error messages.

### Building Errors

- Make sure you're using the required Xcode and iOS versions.
- Run `pod install` if the project uses CocoaPods.
- Clean the build folder (Shift+Cmd+K) and try building again.

## Distributing the App

### Creating an Archive for App Store Submission

1. Select the "GreekPolytonicKeyboardApp" scheme.
2. Set the build configuration to "Release".
3. Select "Generic iOS Device" as the destination.
4. Choose Product > Archive from the menu.
5. Once archiving is complete, the Organizer window will appear with your archive.
6. Click "Distribute App" and follow the prompts to submit to the App Store.

### Ad Hoc Distribution for Testing

1. Create an Ad Hoc provisioning profile in your Apple Developer account.
2. Configure the project to use this profile.
3. Archive the app as described above.
4. In the Organizer, select "Ad Hoc" distribution and follow the prompts.

## Additional Resources

- [Apple's Keyboard Extension Programming Guide](https://developer.apple.com/library/archive/documentation/General/Conceptual/ExtensibilityPG/CustomKeyboard.html)
- [App Store Review Guidelines](https://developer.apple.com/app-store/review/guidelines/)
- [iOS Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/ios/overview/themes/)