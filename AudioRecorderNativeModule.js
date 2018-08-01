import { NativeModules } from 'react-native';

const { AudioRecorderViewManager } = NativeModules;

export default {
  setDimensions (width, height) {
    return AudioRecorderViewManager.setDimensions(width, height);
  },

  setupRecorder () {
    return AudioRecorderViewManager.setupRecorder();
  },

  startRecording() {
    return AudioRecorderViewManager.startRecording();
  },

  stopRecording() {
    return AudioRecorderViewManager.stopRecording();
  },

  finishRecording() {
    return AudioRecorderViewManager.finishRecording();
  },

  startPlaying() {
    return AudioRecorderViewManager.startPlaying();
  },

  stopPlaying() {
    return AudioRecorderViewManager.stopPlaying();
  }
}
