import React, { Component } from "react";
import {
  StyleSheet,
  View,
  Alert
} from 'react-native';

import AudioRecorderUIView from './AudioRecorderNativeView'
import AudioRecorderNative from "./AudioRecorderNativeModule";
import Permissions from "react-native-permissions";

type Props = {};
export default class AudioRecorder extends Component<Props> {
  state = {
    microphonePermission: null
  };

  constructor(props) {
    super(props);
    this.subscription = null;
  }

  triggerRecorderEvent = () => {
    AudioRecorderNative.triggerRecorderEvent();
  };

  requestPermission = () => {
    Permissions.request("microphone").then(response => {
      console.log(response);
      // Returns once the user has chosen to 'allow' or to 'not allow' access
      // Response is one of: 'authorized', 'denied', 'restricted', or 'undetermined'
      this.setState({ microphonePermission: response });
    });
  };

  showPermissionAlert = () => {
    Alert.alert(
      "Microphone Permission Request",
      "Audvise requires microphone permission to record audio",
      [
        {
          text: "Cancel",
          onPress: () => console.log("Permission denied"),
          style: "cancel"
        },
        this.state.microphonePermission === "undetermined"
          ? { text: "OK", onPress: this.requestPermission }
          : { text: "Open Settings", onPress: Permissions.openSettings }
      ]
    );
  };

  componentDidMount = async () => {
    const microphonePermission = await Permissions.check("microphone");

    this.setState({ microphonePermission }, () => {
      if (microphonePermission === "undetermined") {
        this.showPermissionAlert();
      }
    });

    const audioRecorderBridgeEmitter = AudioRecorderNative.getEmitter();
    this.subscription = audioRecorderBridgeEmitter.addListener('recorderStateChangedTo', (event) => {
        // recorderState
        // 0: notReady
        // 1: readyToRecord
        // 2: recording
        // 3: readyToPlay
        // 4: playing

        console.log('Recorder State changed to: ' + event.state);
        this.props.recorderState(event.state);
      }
    );

    AudioRecorderNative.setupRecorder();
  };

  componentWillUnmount() {
    this.subscription.remove();
  }

  render() {
    return (
      <View style={styles.container}>
        <AudioRecorderUIView style={styles.native}/>
      </View>
    );
  }
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: '#F5FCFF',
  },
  native: {
    flex: 1
  }
});