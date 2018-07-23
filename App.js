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
  state = {
    recorderRef: null,
    lastRecordedFileUrl: null,
    isRecording: false,
    isPlaying: false
  };

  constructor(props) {
    super(props);
  }

  setRecorderRef = (ref) => {
    this.setState(function () {
      return { recorderRef: ref };
    });
  };

  renderRecorderStateText(isRecording, isPlaying) {
    if (!isRecording && !isPlaying) {
      return 'Ready for recording/playing';
    } else if (isRecording && !isPlaying) {
      return 'Recording';
    } else if (!isRecording && isPlaying) {
      return 'Playing';
    }
  }

  render() {
    const { recorderRef, isRecording, isPlaying } = this.state;

    return (
      <View style={styles.container}>
        <AudioRecorder ref={ this.setRecorderRef } />

        {!!recorderRef &&
          <View style={styles.innerContainer}>
            {!isRecording &&
              <Button
                style={styles.button}
                onPress={() => {
                  recorderRef.startRecording();
                  this.setState({isRecording: true});
                }}
                title={"Start Recording"}
                disabled={isPlaying}
              />
            }
            {isRecording &&
              <Button
                style={styles.button}
                onPress={() => {
                    recorderRef.stopRecording();
                    this.setState({isRecording: false});
                }}
                title={"Stop Recording"}
              />
            }
            {!isPlaying &&
              <Button
                style={styles.button}
                onPress={() => {
                  recorderRef.startPlaying();
                  this.setState({isPlaying: true});
                }}
                title={"Start Playing"}
                disabled={isRecording}
              />
            }
            {isPlaying &&
              <Button
                style={styles.button}
                onPress={() => {
                  recorderRef.stopPlaying();
                  this.setState({isPlaying: false});
                }}
                title={"Stop Playing"}
              />
            }
            <Text>Recorder State: {this.renderRecorderStateText(isRecording, isPlaying)}</Text>
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
