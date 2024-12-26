import { StyleSheet, View } from 'react-native';
import { Image, type ImageSource } from 'expo-image';
import { Text } from 'react-native-paper';
import React from 'react';

export default function ImageViewer({
  imgSource,
  text,
}: {
  imgSource: ImageSource;
  text: any;
}) {
  return (
    <View>
      <Image source={imgSource} style={styles.image} contentFit="contain" />
      <Text variant="labelLarge" style={styles.text}>
        {text}
      </Text>
    </View>
  );
}

const styles = StyleSheet.create({
  container: { position: 'relative' },
  image: {
    width: 520,
    height: 640,
    backgroundColor: '#fff',
  },
  text: {
    position: 'absolute',
    bottom: '10%', // Distance from the top of the image
    alignSelf: 'center',
    color: 'white', // Ensure text is visible against the image
    fontWeight: 'bold', // Make the text stand out
    backgroundColor: '#000000', // Optional background for readability
    paddingHorizontal: 10,
    paddingVertical: 5,
    borderRadius: 5,
  },
});
