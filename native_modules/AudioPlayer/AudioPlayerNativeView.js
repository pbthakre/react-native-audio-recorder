import React, { Component } from 'react'
import { requireNativeComponent, Dimensions, StyleSheet } from 'react-native'

const AudioPlayerView = requireNativeComponent('AudioPlayerView', AudioPlayerUIView);

import AudioPlayerNative from './AudioPlayerNativeModule';

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
    return <AudioPlayerView style={styles.player} onLayout={this.onLayout}/>
  }
}

const styles = StyleSheet.create({
  player: {
    marginTop: 100,
    width: Dimensions.get('window').width,
    height: '30%',
    backgroundColor: 'blue'
  }
});