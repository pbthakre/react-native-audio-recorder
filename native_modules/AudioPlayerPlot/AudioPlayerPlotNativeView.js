import React, { Component } from 'react'
import { requireNativeComponent, Dimensions, StyleSheet } from 'react-native'

const AudioPlayerView = requireNativeComponent('AudioPlayerView', AudioPlayerUIView);

import AudioPlayerNative from './AudioPlayerPlotNativeModule';

export default class AudioPlayerUIView extends Component {
  constructor (props) {
    super(props);
    this.state = {dimensions: undefined}
  }

  onLayout = event => {
    if (this.state.dimensions) return; // layout was already called
    let {width, height} = event.nativeEvent.layout;
    this.setState({dimensions: {width, height}})
  };

  render () {
    // Send the dimensions of the component to the native ui
    if (this.state.dimensions) {
      AudioPlayerNative.setDimensions(this.state.dimensions.width, this.state.dimensions.height)
    }
    return <AudioPlayerView style={styles.default} onLayout={this.onLayout} width={!this.props.width ? styles.default.width : this.props.width} height={!this.props.height ? styles.default.height : this.props.height}/>
  }
}

const styles = StyleSheet.create({
  default: {
    marginTop: 100,
    width: Dimensions.get('window').width,
    height: '66%',
    backgroundColor: 'white'
  }
});