/**
 * Sample React Native App
 * https://github.com/facebook/react-native
 * @flow
 */

import React, { Component } from 'react';
import {
  StyleSheet,
  Text,
  View,
  Button,
  Alert
} from 'react-native';

import Permissions from 'react-native-permissions';

// import AudioRecorderUIView from './AudioRecorderNativeView'
import AudioRecorderNative from './AudioRecorderNativeModule'

type Props = {};
export default class App extends Component<Props> {

  // recorderState
  // 0: notReady
  // 1: readyToRecord
  // 2: recording
  // 3: readyToPlay
  // 4: playing

  state = {
    microphonePermission: null,
    recorderState: 0
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

  renderRecorderStateText() {
    switch(this.state.recorderState) {
      case 1:
        return 'Ready for recording';
      case 2:
        return 'Recording';
      case 3:
        return 'Ready for playing';
      case 4:
        return 'Playing';
      default:
        return 'Not ready for recording';
    }
  }

  componentDidMount = async () => {
    const microphonePermission = await Permissions.check("microphone");

    this.setState({ microphonePermission }, () => {
      if (microphonePermission === "undetermined") {
        this.showPermissionAlert();
      }
    });

    const audioRecorderBridgeEmitter = AudioRecorderNative.getEmitter();
    this.subscription = audioRecorderBridgeEmitter.addListener('recorderStateChangedTo', (event) => {
        console.log('Recorder State changed to: ' + event.state);
        this.setState({ recorderState: event.state });
      }
    );

    AudioRecorderNative.setupRecorder();
  };

  componentWillUnmount() {
    this.subscription.remove();
  }

  render() {
    const { microphonePermission, recorderState, recording, playing } = this.state;

    return (
      <View style={styles.container}>
        <Text>Recorder State: {this.renderRecorderStateText()}</Text>
        {microphonePermission === "authorized" && (
          <Button
            style={styles.button}
            onPress={this.triggerRecorderEvent}
            title={recorderState == 1 ? "Start Recording" : "Stop Recording"}
            disabled={recorderState == 0 || recorderState >= 3}
          />
        )}
        {microphonePermission === "authorized" && (
          <Button
            style={styles.button}
            onPress={this.triggerRecorderEvent}
            title={recorderState == 3 ? "Start Playing" : "Stop Playing"}
            disabled={recorderState < 3}
          />
        )}
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
  custom: {
    flex: 1,
    backgroundColor: 'black',
    height: 100,
    width: 100
  }
});
