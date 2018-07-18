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
    recorderState: 0,
    lastRecordedFileUrl: null
  };

  constructor(props) {
    super(props);
  }

  changeRecorderState(state) {
    this.setState({
      recorderState: state
    });
  }

  changeLastRecordedFileUrl(fileUrl) {
    this.setState({
      lastRecordedFileUrl: fileUrl
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
        <AudioRecorder
          ref={ this.setRecorderRef }
          recorderState={this.changeRecorderState.bind(this)}
          lastRecordedFileUrl={this.changeLastRecordedFileUrl.bind(this)}
        />

        {!!recorderRef &&
          <View style={styles.innerContainer}>
            {recorderState === 1 &&
              <Button
                style={styles.button}
                onPress={recorderRef.startRecording}
                title={"Start Recording"}
              />
            }
            {recorderState === 2 &&
              <Button
                style={styles.button}
                onPress={recorderRef.stopRecording}
                title={"Stop Recording"}
              />
            }
            {recorderState === 3 &&
              <Button
                style={styles.button}
                onPress={recorderRef.startPlaying}
                title={"Start Playing"}
              />
            }
            {recorderState === 4 &&
              <Button
                style={styles.button}
                onPress={recorderRef.stopPlaying}
                title={"Stop Playing"}
              />
            }

            <Text>Recorder State: {recorderState} -> {this.renderRecorderStateText(recorderState)}</Text>
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
    backgroundColor: '#F5FCFF'
  },
  innerContainer: {
    position: 'absolute'
  }
});
