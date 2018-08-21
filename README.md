
# react-native-native-audio-recorder

A React Native module which serves with a native module for audio recording, and two native ui components - one rendering a feedback plot during recording and another rendering the waveform of the recorded file.

## Getting started
1. Create a new React Native project with:  
`$ react-native init ProjectName`
    
2. Head into the project folder:  
`$ cd ProjectName`

3. Since we have not published this project to the NPM registry yet, you have to install the project directly from GitHub:  
`$ npm install crowdio/react-native-audio-recorder#develop --save`

4. Run the following command to add the package to your project:  
`$ npm react-native link`

4. Open the project in the ios folder:  
`ProjectName.xcodeproj`
    
5. Add at least one Swift file to your project, the compiler needs this to recognize the bridging   
    
5. Go to Project -> Target -> Build Settings -> Section "Search Paths" -> "Framework Search Paths" and add:  
`$(SRCROOT)/../node_modules/react-native-native-audio-recorder/ios/Frameworks`
    
6. Optional - for better development experience: inhibit hundred of third-party warnings:  
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