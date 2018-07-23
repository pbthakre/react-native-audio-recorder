import { NativeModules } from 'react-native';

const { AudioRecorderController } = NativeModules;

export default {
  setupRecorder () {
    return AudioRecorderController.setupRecorder();
  },

  startRecording() {
    return AudioRecorderController.startRecording();
  },

  stopRecording() {
    return AudioRecorderController.stopRecording();
  },

  startPlaying() {
    return AudioRecorderController.startPlaying();
  },

  stopPlaying() {
    return AudioRecorderController.stopPlaying();
  }
}
