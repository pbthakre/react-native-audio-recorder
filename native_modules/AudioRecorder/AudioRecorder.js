import React, { Component } from 'react';
import {
  Platform,
  StyleSheet,
  View
} from "react-native";

import AudioRecorderUIView from './AudioRecorderNativeView'
import AudioRecorderNative from './AudioRecorderNativeModule';

type Props = {};
export default class AudioRecorder extends Component<Props> {
  constructor(props) {
    super(props);
  }

  setupRecorder() {
    return AudioRecorderNative.setupRecorder();
  };

  startRecording(filePath, startTimeInMs) {
    if (!filePath) {
      return AudioRecorderNative.startRecording('', -1);
    } else {
      return AudioRecorderNative.startRecording(filePath, startTimeInMs);
    }
  };

  async stopRecording() {
    const promise = await AudioRecorderNative.stopRecording().then(params => {
      return params
    });

    return new Promise((resolve, reject) => {
      resolve(promise)
    })
  };

  render() {
    return (
      <View style={styles.container}>
        <AudioRecorderUIView style={styles.native} width={this.props.width} height={this.props.height} backgroundColor={this.props.backgroundColor} lineColor={this.props.lineColor}/>
      </View>
    );
  }
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    alignItems: 'center'
  },
  native: {
    flex: 1
  }
});
