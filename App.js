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
    fileUrl: '',
    numberOfRecords: 0
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
    const { isSetup, isRecording, numberOfRecords } = this.state;

    return (
      <View style={styles.container}>
        <AudioRecorder ref={ (ref) => this.recorderRef = ref} />

        {!!this.recorderRef &&
          <View style={styles.innerContainer}>
            {isSetup && !isRecording &&
              <Button
                style={styles.button}
                onPress={() => {
                  this.recorderRef.startRecording()
                    .then((result) => {
                      const parsedResult = JSON.parse(result);

                      if (parsedResult['success']) {
                        this.setState({isRecording: true});
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
                        this.setState({numberOfRecords: this.state.numberOfRecords + 1})
                      }
                    })
                    .catch(error => {
                      console.log(error.toString());
                    });
                }}
                title={'Stop Recording'}
              />
            }
            {isSetup &&
            <Button
              style={styles.button}
              onPress={() => {
                this.recorderRef.finishRecording()
                  .then((result) => {
                    const parsedResult = JSON.parse(result);

                    if (parsedResult['success']) {
                      parsedResult['fileUrl']
                      this.setState({numberOfRecords: 0})
                    }
                  })
                  .catch(error => {
                    console.log(error.toString());
                  });
              }}
              title={'Finish Recording'}
              disabled={isRecording || numberOfRecords < 1}
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
