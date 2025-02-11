# ZmanIQ - Garmin App

Connect IQ app for Garmin wearables for convenient Zmanim lookup & reminders.

# Development

## Prerequisites

- [Connect IQ SDK](https://developer.garmin.com/connect-iq/sdk/)
- Java RE 8 (v1.8.0 or higher)
- VSCode Extensions:
  - [Monkey C](https://marketplace.visualstudio.com/items?itemName=Garmin.monkey-c)
  - [Prettier Monkey C](https://marketplace.visualstudio.com/items?itemName=markw65.prettier-extension-monkeyc)
- Generate a Garmin Developer Key: [Garmin Docs - Generating a Developer Key](https://developer.garmin.com/connect-iq/programmers-guide/getting-started/)

## Running app in simulator

0. Connect your watch to your computer
1. Open the project in VSCode and open one of the `.mc` files
2. Run simulator: `Ctrl+Shift+P` -> `Connect IQ: Run`

## Running app on device

#### Adapted from: [Garmin Docs - Side Loading an App](https://developer.garmin.com/connect-iq/connect-iq-basics/your-first-app/)

The wizard below will create an executable (PRG) of the project for that watch.

0. Plug your device into your computer
1. Use Ctrl + Shift + P to open the command palette
2. In the command palette type "Build for Device" and select `Monkey C: Build for Device`
3. Select the product you wish to build for. I've got the Forerunner 245 Music. If you are unable to choose a device for which to build (the menu appears empty), it means that the device wasn't particularly supported, but it should still work if you add it.
4. Choose a directory for the output and click Select Folder
5. In your file manager, go to the directory selected above
6. Copy the generated `PRG` files to your device's `GARMIN/APPS` directory
