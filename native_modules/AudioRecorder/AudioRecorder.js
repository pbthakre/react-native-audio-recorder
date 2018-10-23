import React, { Component } from 'react';
import {
  StyleSheet,
  View
} from 'react-native';

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

  startRecording(startTimeInMs = -1, filePath = '') {
    return AudioRecorderNative.startRecording(startTimeInMs, filePath);
  };

  stopRecording() {
    return AudioRecorderNative.stopRecording();
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
