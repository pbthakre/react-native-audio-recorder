import { NativeModules } from 'react-native';

const { AudioRecorderViewManager } = NativeModules;

export default {
  setDimensions (width, height) {
    return AudioRecorderViewManager.setDimensions(width, height);
  },

  setupRecorder () {
    return AudioRecorderViewManager.setupRecorder();
  },

  startRecording(startTimeInMs, fileUrl) {
    return AudioRecorderViewManager.startRecording(startTimeInMs, fileUrl);
  },

  stopRecording() {
    return AudioRecorderViewManager.stopRecording();
  }
}
