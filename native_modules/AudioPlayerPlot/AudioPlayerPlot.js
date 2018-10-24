import React, { Component } from 'react';
import {
  StyleSheet,
  View
} from 'react-native';

import AudioPlayerUIView from './AudioPlayerPlotNativeView'
import AudioPlayerNative from './AudioPlayerPlotNativeModule';
import AudioRecorderUIView
  from "react-native-native-audio-recorder/native_modules/AudioRecorder/AudioRecorderNativeView";

type Props = {};
export default class AudioPlayerPlot extends Component<Props> {
  constructor(props) {
    super(props);
  }

  renderByFile(fileUrl) {
    return AudioPlayerNative.renderByFile(fileUrl);
  };

  render() {
    return (
      <View style={styles.container}>
        <AudioPlayerUIView style={this.props.style} width={this.props.width} height={this.props.height} backgroundColor={this.props.backgroundColor} lineColor={this.props.lineColor} pixelsPerSecond={this.props.pixelsPerSecond}/>
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
