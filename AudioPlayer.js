import React, { Component } from 'react';
import {
  StyleSheet,
  View
} from 'react-native';

import AudioPlayerUIView from './AudioPlayerNativeView'
import AudioPlayerNative from './AudioPlayerNativeModule';

type Props = {};
export default class AudioPlayer extends Component<Props> {
  constructor(props) {
    super(props);
  }

  render() {
    return (
      <View style={styles.container}>
        <AudioPlayerUIView style={styles.native}/>
      </View>
    );
  }
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    alignItems: 'center',
    backgroundColor: '#F5FCFF',
  },
  native: {
    flex: 1
  }
});