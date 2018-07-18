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
    this.isRecorderEventSuccessfullSubscription = null;
    this.lastRecordedFileUrlChangedSubscription = null;
  }

  startRecording = () => {
    AudioRecorderNative.startRecording();
  };

  stopRecording = () => {
    AudioRecorderNative.stopRecording();
  };

  componentDidMount = async () => {
    const audioRecorderBridgeEmitter = AudioRecorderNative.getEmitter();
    this.isRecorderEventSuccessfullSubscription = audioRecorderBridgeEmitter.addListener('isRecorderEventSuccessfull', (event) => {
        if (!event.success) {
          throw new Error("Something went wrong with recorder event");
        }
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
    this.isRecorderEventSuccessfullSubscription.remove();
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