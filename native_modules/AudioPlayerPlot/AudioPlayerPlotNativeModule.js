import { NativeModules } from 'react-native';

const { AudioPlayerViewManager } = NativeModules;

export default {
  setDimensions (width, height) {
    return AudioPlayerViewManager.setDimensions(width, height);
  },

  passProperties (backgroundColor, lineColor) {
    return AudioPlayerViewManager.passProperties(backgroundColor, lineColor);
  },

  renderByFile(fileUrl) {
    return AudioPlayerViewManager.renderByFile(fileUrl);
  }
}
