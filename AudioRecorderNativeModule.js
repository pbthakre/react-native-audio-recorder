import { NativeModules } from 'react-native';

const { AudioRecorderViewManager } = NativeModules;

export default {
  setupRecorder () {
    return AudioRecorderViewManager.setupRecorder();
  },

  startRecording() {
    return AudioRecorderViewManager.startRecording();
  },

  stopRecording() {
    return AudioRecorderViewManager.stopRecording();
  },

  startPlaying() {
    return AudioRecorderViewManager.startPlaying();
  },

  stopPlaying() {
    return AudioRecorderViewManager.stopPlaying();
  }
}
