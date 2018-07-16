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
  state = {
    microphonePermission: null,
    recording: false,
    playing: false,
    recordCount: 0
  };

  handlePressRecording = () => {
    const { recording, recordCount } = this.state;

    if (recording) {
      this.setState({ values: [], recording: false });
    } else {
      this.setState({ recording: true, recordCount: recordCount + 1 });
      AudioRecorderNative.exampleMethod()
    }
  };

  handlePressPlaying = () => {
    const { playing } = this.state;

    if (playing) {
      this.setState({ values: [], playing: false });
    } else {
      this.setState({ playing: true });
      AudioRecorderNative.exampleMethod()
    }
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
      "Record audio",
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
    const subscription = audioRecorderBridgeEmitter.addListener(
      'TestEvent',
      (reminder) => console.log(reminder.name)
    );

    AudioRecorderNative.setupRecorder();
  };

  componentWillUnmount() {
    // this._eventSubscription && this._eventSubscription.remove();
  }

  render() {
    const { microphonePermission, recording, playing, recordCount } = this.state;

    return (
      <View style={styles.container}>
        {microphonePermission === "authorized" && (
          <Button
            style={styles.button}
            onPress={this.handlePressRecording}
            title={recording ? "Stop recording" : "Start recording"}
            disabled={playing}
          />
        )}
        {microphonePermission === "authorized" && (
          <Button
            style={styles.button}
            onPress={this.handlePressPlaying}
            title={playing ? "Stop playing" : "Start playing"}
            disabled={recording || recordCount == 0}
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
