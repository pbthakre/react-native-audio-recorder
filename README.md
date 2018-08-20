
# react-native-native-audio-recorder

A React Native module which serves with a native module for audio recording, and two native ui components - one rendering a feedback plot during recording and another rendering the waveform of the recorded file.

## Getting started
1. Create a new React Native project with:  
`$ react-native init ProjectName`
    
2. Head into the project folder:  
`$ cd ProjectName`

3. Since we have not published this project to the NPM registry yet, you have to install the project directly from GitHub:  
`$ npm install crowdio/react-native-audio-recorder#develop --save`

4. Copy the `Podfile` from the root directory of the react-native-audio-recorder package to the `ios` folder of the created project

5. Open the package.json and add the following section:  
    ```
    "scripts": {
      "postinstall": "cd ios && pod install && cd ../node_modules/react-native-native-audio-recorder/ios && pod install"
    }
    ```
6. Run the script (installation of cocoapods) via:  
`$ npm install`

7. Head into the ios folder:  
`$ cd ios`

8. Open the project:  
`ProjectName.xcworkspace` NOT `ProjectName.xcodeproj`

9. No you can run the project, however you will get the following error:
`'RCTAnimation/RCTValueAnimatedNode.h' file not found` so replace it `#import <RCTAnimation/RCTValueAnimatedNode.h>` with `"RCTValueAnimatedNode.h"` and run the project again
    
10. Optional - for better development experience: inhibit hundred of third-party warnings:  
a) add the following lines to package.json:
    ```
    "scripts": {
      "inhibit-third-party-warnings": "react-native-inhibit-warnings"
    }
    ```
    b) run `$ npm install --save-dev react-native-inhibit-warnings`  
    c) run `$ npm run inhibit-third-party-warnings`  

    
    
## Usage
```javascript
import { AudioRecorder, AudioPlayerPlot } from 'react-native-native-audio-recorder';
```

## Example

For usage see the example project in the example folder, we have planned to add further explanations here in the readme or in the wiki anytime later. 