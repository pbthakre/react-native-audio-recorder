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
    isSetup: false,
    isRecording: false,
    isPlaying: false
  };

  constructor(props) {
    super(props);
    this.recorderRef = React.createRef();
  }

  setRecorderRef = (ref) => {
    this.setState(function () {
      return { recorderRef: ref };
    });
  };

  renderRecorderStateText(isSetup, isRecording, isPlaying) {
    if (!isSetup) {
      return 'Not ready! Setup ...';
    } else if (!isRecording && !isPlaying) {
      return 'Ready for recording/playing';
    } else if (isRecording && !isPlaying) {
      return 'Recording';
    } else if (!isRecording && isPlaying) {
      return 'Playing';
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
    const { recorderRef, isSetup, isRecording, isPlaying } = this.state;

    return (
      <View style={styles.container}>
        <AudioRecorder ref={ (ref) => this.recorderRef = ref} />

        {!!this.recorderRef &&
          <View style={styles.innerContainer}>
            {isSetup && !isRecording &&
              <Button
                style={styles.button}
                onPress={() => {
                  recorderRef.startRecording()
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
                title={"Start Recording"}
                disabled={isPlaying}
              />
            }
            {isSetup && isRecording &&
              <Button
                style={styles.button}
                onPress={() => {
                  recorderRef.stopRecording()
                    .then((result) => {
                      const parsedResult = JSON.parse(result);

                      if (parsedResult['success']) {
                        this.setState({isRecording: false});
                      }
                    })
                    .catch(error => {
                      console.log(error.toString());
                    });
                }}
                title={"Stop Recording"}
              />
            }
            {isSetup && !isPlaying &&
              <Button
                style={styles.button}
                onPress={() => {
                  recorderRef.startPlaying()
                    .then((result) => {
                      const parsedResult = JSON.parse(result);

                      if (parsedResult['success']) {
                        this.setState({isPlaying: true});
                      }
                    })
                    .catch(error => {
                      console.log(error.toString());
                    });
                }}
                title={"Start Playing"}
                disabled={isRecording}
              />
            }
            {isSetup && isPlaying &&
              <Button
                style={styles.button}
                onPress={() => {
                  recorderRef.stopPlaying()
                    .then((result) => {
                      const parsedResult = JSON.parse(result);

                      if (parsedResult['success']) {
                        this.setState({isPlaying: false});
                      }
                    })
                    .catch(error => {
                      console.log(error.toString());
                    });
                }}
                title={"Stop Playing"}
              />
            }
            <Text>Recorder State: {this.renderRecorderStateText(isSetup, isRecording, isPlaying)}</Text>
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
