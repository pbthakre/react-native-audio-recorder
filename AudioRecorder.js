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

  async startRecording() {
    await AudioRecorderNative.startRecording()
      .then((result) => {
        console.log(result);
        return result;
      })
      .catch(error => {
        console.log(error.toString());
      })
  };

  async stopRecording() {
    await AudioRecorderNative.stopRecording()
      .then((result) => {
        console.log(result);
      })
      .catch(error => {
        console.log(error.toString());
      })
  };

  async startPlaying() {
    await AudioRecorderNative.startPlaying()
      .then((result) => {
        console.log(result);
      })
      .catch(error => {
        console.log(error.toString());
      })
  };

  async stopPlaying() {
    await AudioRecorderNative.stopPlaying()
      .then((result) => {
        console.log(result);
      })
      .catch(error => {
        console.log(error.toString());
      })
  };

  componentDidMount = async () => {
    await AudioRecorderNative.setupRecorder()
      .then((result) => {
        console.log(result);
      })
      .catch(error => {
        console.log(error.toString());
      });
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
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: '#F5FCFF',
  },
  native: {
    flex: 1
  }
});