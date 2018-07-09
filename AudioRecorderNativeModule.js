import { NativeModules } from 'react-native';

const { AudioRecorderBridge } = NativeModules;

export default {
  exampleMethod () {
    return AudioRecorderBridge.exampleMethod();
  }

  //EXAMPLE_CONSTANT: AudioRecorder.EXAMPLE_CONSTANT
}
