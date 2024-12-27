import { StyleSheet, View } from 'react-native';
import { Image, type ImageSource } from 'expo-image';
import { Text } from 'react-native-paper';
import React from 'react';

export default function ImageViewer({
  imgSource,
  text,
  count,
  timestamp,
  clicked,
}: {
  imgSource: ImageSource;
  text: any;
  count: any;
  timestamp: any;
  clicked: any;
}) {
  return (
    <View>
      <Image source={imgSource} style={styles.image} contentFit="contain" />
      <Text variant="labelLarge" style={styles.text}>
        {text || ''}
      </Text>
      <Text variant="labelLarge" style={styles.count}>
        {clicked && `Total Count: ${count}`}
      </Text>
      <Text variant="labelLarge" style={styles.timestamp}>
        {timestamp}
      </Text>
    </View>
  );
}

const styles = StyleSheet.create({
  container: { position: 'relative' },
  image: {
    width: 520,
    height: 640,
    backgroundColor: '#F4F4F5',
    padding: '20%',
  },
  text: {
    position: 'absolute',
    top: '2%', // Distance from the top of the image
    left: '2%',
    alignSelf: 'center',
    color: 'black', // Ensure text is visible against the image
    fontWeight: 'bold', // Make the text stand out
    // backgroundColor: '#000000', // Optional background for readability
    paddingHorizontal: 10,
    paddingVertical: 5,
    borderRadius: 5,
  },
  count: {
    position: 'absolute',
    top: '2%', // Distance from the top of the image
    right: '2%',
    alignSelf: 'flex-end',
    color: 'black', // Ensure text is visible against the image
    fontWeight: 'bold', // Make the text stand out
    // backgroundColor: '#000000', // Optional background for readability
    paddingHorizontal: 10,
    paddingVertical: 5,
    borderRadius: 5,
  },
  timestamp: {
    position: 'absolute',
    bottom: '2%', // Distance from the top of the image
    right: '2%',
    alignSelf: 'flex-end',
    color: 'black', // Ensure text is visible against the image
    fontWeight: 'bold', // Make the text stand out
    // backgroundColor: '#000000', // Optional background for readability
    paddingHorizontal: 10,
    paddingVertical: 5,
    borderRadius: 5,
  },
});
