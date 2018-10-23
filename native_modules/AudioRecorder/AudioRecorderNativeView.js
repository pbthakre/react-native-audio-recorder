import React, { Component } from 'react'
import { requireNativeComponent, Dimensions, StyleSheet, Platform } from 'react-native'

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
    if (Platform.OS === 'ios') {
      // Send the dimensions of the component to the native ui
      if (this.state.dimensions) {
        AudioRecorderNative.setDimensions(this.state.dimensions.width, this.state.dimensions.height)
      }
    }

    AudioRecorderNative.passProperties(this.props.backgroundColor, this.props.lineColor)

    return <AudioRecorderView style={styles.recorder} onLayout={this.onLayout} width={!this.props.width ? styles.recorder.width : this.props.width} height={!this.props.height ? styles.recorder.height : this.props.height}/>
  }
}

const styles = StyleSheet.create({
  recorder: {
    width: Dimensions.get('window').width,
    height: '66%',
    backgroundColor: 'transparent'
  }
});
