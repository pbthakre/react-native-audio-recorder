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
    this.lastRecordedFileUrlChangedSubscription = null;
  }

  async startRecording() {
    await AudioRecorderNative.startRecording()
      .then((result) => {
        console.log(result); // "Stuff worked!"
      })
      .catch(error => {
        console.log(error.toString());
      })
  };

  stopRecording = () => {
    AudioRecorderNative.stopRecording();
  };

  componentDidMount = async () => {
    AudioRecorderNative.setupRecorder();
  };

  componentWillUnmount() {
    // this.lastRecordedFileUrlChangedSubscription.remove();
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