import React, { Component } from 'react'
import { requireNativeComponent } from 'react-native'

const AudioRecorderUI = requireNativeComponent('AudioRecorder', null);

export default class AudioRecorderUIView extends Component {
  render () {
    return <AudioRecorderUI />
  }
}

AudioRecorderUIView.propTypes = {
  //exampleProp: React.PropTypes.any
};
