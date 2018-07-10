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
    recording: false
  };

  handlePress = () => {
    const { recording } = this.state;

    if (recording) {
      this.setState({ values: [], recording: false });
    } else {
      this.setState({ recording: true });
      //Console.log(AudioRecorderNative);
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
        this.state.microphonePermission == "undetermined"
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
  };

  render() {
    const { microphonePermission, recording } = this.state;

    return (
      <View style={styles.container}>
        {microphonePermission === "authorized" && (
          <Button
            style={styles.button}
            onPress={this.handlePress}
            title={recording ? "Stop recording" : "Start recording"}
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
