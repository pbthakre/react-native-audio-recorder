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

import AudioRecorderUIView from './AudioRecorderNativeView'

type Props = {};
export default class App extends Component<Props> {
  state = {
    recording: false
  };

  handlePress = () => {
    const { recording } = this.state;

    if (recording) {
      this.setState({ values: [], recording: false });
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
        <AudioRecorderUIView style={styles.custom}/>
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
  },
  custom: {
    flex: 1,
    backgroundColor: 'black',
    height: 100,
    width: 100
  }
});
