import React, { Component } from "react";
import {
  StyleSheet,
  View
} from 'react-native';

import AudioRecorderUIView from './AudioRecorderNativeView'
import AudioRecorderNative from "./AudioRecorderNativeModule";

type Props = {};
export default class AudioRecorder extends Component<Props> {
  constructor(props) {
    super(props);
  }

  setupRecorder() {
    return AudioRecorderNative.setupRecorder();
  };

  startRecording() {
    return AudioRecorderNative.startRecording();
  };

  stopRecording() {
    return AudioRecorderNative.stopRecording();
  };

  finishRecording() {
    return AudioRecorderNative.finishRecording();
  };

  startPlaying() {
    return AudioRecorderNative.startPlaying();
  };

  stopPlaying() {
    return AudioRecorderNative.stopPlaying();
  };

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
    alignItems: 'center',
    backgroundColor: '#F5FCFF',
  },
  native: {
    flex: 1
  }
});