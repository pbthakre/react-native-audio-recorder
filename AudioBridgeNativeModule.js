//  Created by react-native-create-bridge

import { NativeModules } from 'react-native'

const { AudioBridge } = NativeModules;

export default {
  exampleMethod () {
    return AudioBridge.exampleMethod()
  },

  EXAMPLE_CONSTANT: AudioBridge.EXAMPLE_CONSTANT
}
