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

import AudioRecorder from './AudioRecorder';

type Props = {};
export default class App extends Component<Props> {
  // recorderState
  // 0: notReady
  // 1: readyToRecord
  // 2: recording
  // 3: readyToPlay
  // 4: playing

  state = {
    recorderRef: null,
    recorderState: 0
  };

  constructor(props) {
    super(props);
  }

  changeRecorderState(state) {
    this.setState({
      recorderState: state
    });
  }

  setRecorderRef = (ref) => {
    this.setState(function () {
      return { recorderRef: ref };
    });
  };

  renderRecorderStateText(recorderState) {
    switch(recorderState) {
      case 1:
        return 'Ready for recording';
      case 2:
        return 'Recording';
      case 3:
        return 'Ready for playing';
      case 4:
        return 'Playing';
      default:
        return 'Not ready for recording';
    }
  }

  render() {
    const { recorderRef, recorderState } = this.state;

    return (
      <View style={styles.container}>
        <AudioRecorder ref={ this.setRecorderRef } recorderState={this.changeRecorderState.bind(this)}/>
        {!!recorderRef &&
          <View>
            <Text>Recorder State: {recorderState} -> {this.renderRecorderStateText(recorderState)}</Text>

            <Button
              style={styles.button}
              onPress={recorderRef.triggerRecorderEvent}
              title={recorderState === 1 ? "Start Recording" : "Stop Recording"}
              disabled={recorderState === 0 || recorderState >= 3}
            />
            <Button
              style={styles.button}
              onPress={recorderRef.triggerRecorderEvent}
              title={recorderState === 3 ? "Start Playing" : "Stop Playing"}
              disabled={recorderState < 3}
            />
          </View>
        }
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
