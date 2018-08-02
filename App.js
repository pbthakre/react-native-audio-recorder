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
    isSetup: false,
    isRecording: false,
    fileUrl: ''
  };

  constructor(props) {
    super(props);
    this.recorderRef = React.createRef();
  }

  renderRecorderStateText(isSetup, isRecording) {
    if (!isSetup) {
      return 'Not ready! Setup ...';
    } else if (!isRecording) {
      return 'Ready for recording';
    } else if (isRecording) {
      return 'Recording';
    }
  }

  componentDidMount = () => {
    this.recorderRef.setupRecorder()
      .then((result) => {
        const parsedResult = JSON.parse(result);

        if (parsedResult['success']) {
          this.setState({isSetup: true});
        }
      })
      .catch(error => {
        console.log(error.toString());
      });
  };

  render() {
    const { isSetup, isRecording } = this.state;

    return (
      <View style={styles.container}>
        <AudioRecorder ref={ (ref) => this.recorderRef = ref} />

        {!!this.recorderRef &&
          <View style={styles.innerContainer}>
            {isSetup && !isRecording &&
              <Button
                style={styles.button}
                onPress={() => {
                  this.recorderRef.startRecording(2000)
                    .then((result) => {
                      const parsedResult = JSON.parse(result);

                      if (parsedResult['success']) {
                        this.setState({isRecording: true});
                        console.log('INFO: Recording started.')
                      }
                    })
                    .catch(error => {
                      console.log(error.toString());
                    })
                }}
                title={'Start Recording'}
              />
            }
            {isSetup && isRecording &&
              <Button
                style={styles.button}
                onPress={() => {
                  this.recorderRef.stopRecording()
                    .then((result) => {
                      const parsedResult = JSON.parse(result);

                      if (parsedResult['success']) {
                        this.setState({isRecording: false});
                        console.log('INFO: Recording stopped.')
                        console.log(parsedResult['value']['fileUrl']);
                      }
                    })
                    .catch(error => {
                      console.log(error.toString());
                    });
                }}
                title={'Stop Recording'}
              />
            }
            <Text>Recorder State: {this.renderRecorderStateText(isSetup, isRecording)}</Text>
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
