//  Created by react-native-create-bridge

import { NativeModules } from 'react-native'

const { AudioRecorder } = NativeModules

export default {
  exampleMethod () {
    return AudioRecorder.exampleMethod()
  },

  EXAMPLE_CONSTANT: AudioRecorder.EXAMPLE_CONSTANT
}
