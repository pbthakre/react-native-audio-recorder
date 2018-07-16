import { NativeEventEmitter, NativeModules } from 'react-native';

const { AudioRecorderBridge } = NativeModules;

const audioRecorderBridgeEmitter = new NativeEventEmitter(AudioRecorderBridge);

export default {
  getEmitter() {
    return audioRecorderBridgeEmitter;
  },

  setupRecorder () {
    return AudioRecorderBridge.setupRecorder();
  },

  exampleMethod () {
    return AudioRecorderBridge.exampleMethod();
  }

  //EXAMPLE_CONSTANT: AudioRecorder.EXAMPLE_CONSTANT
}
