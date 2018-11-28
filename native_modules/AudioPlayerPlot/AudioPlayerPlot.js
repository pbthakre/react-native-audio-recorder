import React, { Component } from 'react';
import {
  StyleSheet,
  View
} from 'react-native';

import AudioPlayerNativeView from './AudioPlayerPlotNativeView'
import AudioPlayerNativeModule from './AudioPlayerPlotNativeModule';

type Props = {};
export default class AudioPlayerPlot extends Component<Props> {
  constructor(props) {
    super(props);
  }

  renderByFile(file) {
    return AudioPlayerNativeModule.renderByFile(file);
  };

  render() {
    return (
      <View style={styles.container}>
        <AudioPlayerNativeView style={this.props.style} width={this.props.width} height={this.props.height} backgroundColor={this.props.backgroundColor} lineColor={this.props.lineColor} pixelsPerSecond={this.props.pixelsPerSecond}/>
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
