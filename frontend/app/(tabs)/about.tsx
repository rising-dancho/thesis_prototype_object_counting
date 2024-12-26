import React from 'react';
import { View, StyleSheet } from 'react-native';
import { Text } from 'react-native-paper';

export default function AboutScreen() {
  return (
    <View style={styles.container}>
      <Text variant="titleLarge" >About the Application</Text>
      <Text variant="bodyMedium">
        This application is a cross-platform Image Processing and Object
        Detection App designed with React Native and Expo for the frontend and
        Flask for the backend. It provides users with an intuitive interface for
        uploading images, processing them to detect objects, and saving the
        processed images.
      </Text>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#FEFBFE',
    alignItems: 'center',
    justifyContent: 'center',
    padding: '15%',
    paddingLeft: '25%',
    paddingRight: '25%',
    gap: 10,
    color: '#25292e',
  },
});
