import { NativeModules } from 'react-native';

const { AudioPlayerViewManager } = NativeModules;

export default {
  setDimensions (width, height) {
    return AudioPlayerViewManager.setDimensions(width, height);
  },

  passProperties (backgroundColor, lineColor, pixelsPerSecond) {
    return AudioPlayerViewManager.passProperties(backgroundColor, lineColor, pixelsPerSecond);
  },

  renderByFile(fileName) {
    return AudioPlayerViewManager.renderByFile(fileName);
  }
}
