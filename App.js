/**
 * Sample React Native App
 * https://github.com/facebook/react-native
 * @flow
 */

import React, { Component } from 'react';
import {
  StyleSheet,
  Text,
  View,
  Button
} from 'react-native';

import AudioBridgeNative  from './AudioBridgeNativeModule'

type Props = {};
export default class App extends Component<Props> {
  state = {
    recording: false
  };

  handlePress = () => {
    const { recording } = this.state;

    if (recording) {
      this.setState({ values: [], recording: false });
      AudioBridgeNative.exampleMethod("test")
    } else {
      this.setState({ recording: true });
    }
  };

  render() {
    const { recording } = this.state;

    return (
      <View style={styles.container}>
        <Button
          style={styles.button}
          onPress={this.handlePress}
          title={recording ? "Stop recording" : "Start recording"}
        />
      </View>
    );
  }
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: '#F5FCFF',
  }
});
