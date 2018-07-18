import React, { Component } from "react";
import {
  StyleSheet,
  View
} from 'react-native';

import AudioRecorderUIView from './AudioRecorderNativeView'
import AudioRecorderNative from "./AudioRecorderNativeModule";

type Props = {};
export default class AudioRecorder extends Component<Props> {
  constructor(props) {
    super(props);
    this.recorderStateChangedToSubscription = null;
    this.lastRecordedFileUrlChangedSubscription = null;
  }

  startRecording = () => {
    AudioRecorderNative.triggerRecorderEvent();
  };

  stopRecording = () => {
    AudioRecorderNative.triggerRecorderEvent();
  };

  startPlaying = () => {
    AudioRecorderNative.triggerRecorderEvent();
  };

  stopPlaying = () => {
    AudioRecorderNative.triggerRecorderEvent();
  };

  componentDidMount = async () => {
    const audioRecorderBridgeEmitter = AudioRecorderNative.getEmitter();
    this.recorderStateChangedToSubscription = audioRecorderBridgeEmitter.addListener('recorderStateChangedTo', (event) => {
        // recorderState
        // 0: notReady
        // 1: readyToRecord
        // 2: recording
        // 3: readyToPlay
        // 4: playing

        console.log('Recorder State changed to: ' + event.state);
        this.props.recorderState(event.state);
      }
    );

    this.lastRecordedFileUrlChangedSubscription = audioRecorderBridgeEmitter.addListener('lastRecordedFileUrlChangedTo', (event) => {
        console.log(event.fileUrl);
        this.props.lastRecordedFileUrl(event.fileUrl);
      }
    );

    AudioRecorderNative.setupRecorder();
  };

  componentWillUnmount() {
    this.recorderStateChangedToSubscription.remove();
    this.lastRecordedFileUrlChangedSubscription.remove();
  }

  render() {
    return (
      <View style={styles.container}>
        <AudioRecorderUIView style={styles.native}/>
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
  native: {
    flex: 1
  }
});