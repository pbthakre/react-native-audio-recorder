import React, { Component } from 'react'
import { requireNativeComponent, Dimensions, StyleSheet } from 'react-native'

const AudioRecorderView = requireNativeComponent('AudioRecorderView', AudioRecorderUIView);

import AudioRecorderNative from './AudioRecorderNativeModule';

export default class AudioRecorderUIView extends Component {
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
      AudioRecorderNative.setDimensions(this.state.dimensions.width, this.state.dimensions.height)
    }
    return <AudioRecorderView style={styles.recorder} onLayout={this.onLayout}/>
  }
}

const styles = StyleSheet.create({
  recorder: {
    marginTop: 100,
    width: Dimensions.get('window').width,
    height: '30%',
    backgroundColor: 'red'
  }
});