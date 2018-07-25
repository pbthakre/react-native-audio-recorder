import React, { Component } from 'react'
import { requireNativeComponent, Dimensions, StyleSheet } from 'react-native'

const AudioRecorderView = requireNativeComponent('AudioRecorderView', AudioRecorderUIView);

export default class AudioRecorderUIView extends Component {
  render () {
    return <AudioRecorderView style={styles.recorder}/>
  }
}

const styles = StyleSheet.create({
  recorder: {
    marginTop: 100,
    width: Dimensions.get('window').width,
    height: "30%",
    backgroundColor: 'red'
  }
});