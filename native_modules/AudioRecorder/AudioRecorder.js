import React, { Component } from 'react';
import {
  Platform,
  StyleSheet,
  View
} from "react-native";

import AudioRecorderNativeView from './AudioRecorderNativeView'
import AudioRecorderNativeModule from './AudioRecorderNativeModule';

type Props = {};
export default class AudioRecorder extends Component<Props> {
  constructor(props) {
    super(props);
  }

  setupRecorder() {
    return AudioRecorderNativeModule.setupRecorder();
  };

  startRecording(file, startTimeInMs) {
    if (!file) {
      return AudioRecorderNativeModule.startRecording('', -1);
    } else {
      return AudioRecorderNativeModule.startRecording(file, startTimeInMs);
    }
  };

  async stopRecording() {
    const promise = await AudioRecorderNativeModule.stopRecording().then(params => {
      let parsedParams;
      if (Platform.OS === 'ios') {
        parsedParams = JSON.parse(params);
      } else {
        parsedParams = params;
      }

      return parsedParams
    });

    return new Promise((resolve, reject) => {
      resolve(promise)
    })
  };

  render() {
    return (
      <View style={styles.container}>
        <AudioRecorderNativeView style={styles.native} width={this.props.width} height={this.props.height} backgroundColor={this.props.backgroundColor} lineColor={this.props.lineColor}/>
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
