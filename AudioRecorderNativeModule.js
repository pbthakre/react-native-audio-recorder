import { NativeModules } from 'react-native';

const { AudioRecorderBridge } = NativeModules;

export default {
  setupRecorder () {
    return AudioRecorderBridge.setupRecorder();
  },

  exampleMethod () {
    return AudioRecorderBridge.exampleMethod();
  }

  //EXAMPLE_CONSTANT: AudioRecorder.EXAMPLE_CONSTANT
}
