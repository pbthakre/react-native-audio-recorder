import { NativeModules } from 'react-native';

const { AudioPlayerViewManager } = NativeModules;

export default {
  setDimensions (width, height) {
    return AudioPlayerViewManager.setDimensions(width, height);
  },

  renderByFile(fileUrl) {
    return AudioPlayerViewManager.renderByFile(fileUrl);
  }
}
