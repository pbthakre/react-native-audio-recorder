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
    isRecording: false
  };

  constructor(props) {
    super(props);
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

  renderRecorderStateText(isRecording) {
    if (!isRecording) {
      return 'Ready for recording';
    } else {
      return 'Recording';
    }
  }

  render() {
    const { recorderRef, isRecording } = this.state;

    return (
      <View style={styles.container}>
        <AudioRecorder
          ref={ this.setRecorderRef }
          lastRecordedFileUrl={this.changeLastRecordedFileUrl.bind(this)}
        />

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
            <Text>Recorder State: {this.renderRecorderStateText(isRecording)}</Text>
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
