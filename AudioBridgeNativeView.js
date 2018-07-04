//  Created by react-native-create-bridge

import React, { Component } from 'react'
import { requireNativeComponent } from 'react-native'

const AudioBridge = requireNativeComponent('AudioBridge', AudioBridgeView);

export default class AudioBridgeView extends Component {
  render () {
    return <AudioBridge {...this.props} />
  }
}

AudioBridgeView.propTypes = {
  exampleProp: React.PropTypes.any
};
