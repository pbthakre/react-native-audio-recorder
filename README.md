
# react-native-native-audio-recorder

A React Native module which serves with a native module for audio recording, and two native ui components - one rendering a feedback plot during recording and another rendering the waveform of the recorded file.

## Getting started

#### General
1. Create a new React Native project with:  
`$ react-native init ProjectName`
    
2. Head into the project folder:  
`$ cd ProjectName`

3. Install from NPM:  
`$ npm install react-native-native-audio-recorder --save`

4. Run the following command to add the package to your project:  
`$ npm react-native link`

#### iOS

1. Open the project in the ios folder:  
`ProjectName.xcodeproj`
    
2. Add at least one Swift file to your project, the compiler needs this to recognize the bridging   
    
3. Go to Project -> Target -> Build Settings -> Section "Search Paths" -> "Framework Search Paths" and add:  
`$(SRCROOT)/../node_modules/react-native-native-audio-recorder/ios/Frameworks`
  
4. Go to Project -> Target -> Info -> "Custom iOS Target Properties" -> hit the plus and add:  
`Privacy - Microphone Usage Description`
    
5. Optional - for better development experience: inhibit hundred of third-party warnings:  
a) add the following lines to package.json:
    ```
    "scripts": {
      "inhibit-third-party-warnings": "react-native-inhibit-warnings"
    }
    ```
    b) run `$ npm install --save-dev react-native-inhibit-warnings`  
    c) run `$ npm run inhibit-third-party-warnings`  

#### Android
1. Open the android folder with your IDE e.g. Android Studio

2. Open AndroidManifest.xml of your project and add the following permissions under the manifest section:
    ```
    <uses-permission android:name="android.permission.INTERNET" />
    <uses-permission android:name="android.permission.SYSTEM_ALERT_WINDOW"/>
    <uses-permission android:name="android.permission.RECORD_AUDIO" />
    <uses-permission android:name="android.permission.MODIFY_AUDIO_SETTINGS" />
    <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
    <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
    ```

3. Open MainActivity.java of your project and also add the permissions here:
    ```
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        FacebookSdk.sdkInitialize(getApplicationContext());
        // Request microphone permission
        if (ActivityCompat.checkSelfPermission(this, Manifest.permission.RECORD_AUDIO)
                != PackageManager.PERMISSION_GRANTED) {
    
            ActivityCompat.requestPermissions(this, new String[]{Manifest.permission.RECORD_AUDIO},
                    123);
        }
    
        // Request permission for writing external storage
        if (ActivityCompat.checkSelfPermission(this, Manifest.permission.WRITE_EXTERNAL_STORAGE)
                != PackageManager.PERMISSION_GRANTED) {
    
            ActivityCompat.requestPermissions(this, new String[]{Manifest.permission.WRITE_EXTERNAL_STORAGE},
                    123);
        }
    
        // Request permission for reading external storage
        if (ActivityCompat.checkSelfPermission(this, Manifest.permission.READ_EXTERNAL_STORAGE)
                != PackageManager.PERMISSION_GRANTED) {
    
            ActivityCompat.requestPermissions(this, new String[]{Manifest.permission.READ_EXTERNAL_STORAGE},
                    123);
        }
    }
    ```
    
## Usage
```javascript
import { AudioRecorder, AudioPlayerPlot } from 'react-native-native-audio-recorder';
```

## Example

For usage see the full-working [example project ](https://github.com/audvice/react-native-audio-recorder-example-project)