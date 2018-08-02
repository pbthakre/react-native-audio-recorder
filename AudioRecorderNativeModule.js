import { NativeModules } from 'react-native';

const { AudioRecorderViewManager } = NativeModules;

export default {
  setDimensions (width, height) {
    return AudioRecorderViewManager.setDimensions(width, height);
  },

  setupRecorder () {
    return AudioRecorderViewManager.setupRecorder();
  },

  startRecording(startTimeInMs) {
    return AudioRecorderViewManager.startRecording(startTimeInMs);
  },

  stopRecording() {
    return AudioRecorderViewManager.stopRecording();
  }
}
