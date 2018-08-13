import React, { Component } from 'react';
import {
  StyleSheet,
  View
} from 'react-native';

import AudioPlayerUIView from './AudioPlayerPlotNativeView'
import AudioPlayerNative from './AudioPlayerPlotNativeModule';

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
        <AudioPlayerUIView style={styles.native}/>
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