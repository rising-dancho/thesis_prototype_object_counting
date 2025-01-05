import { StyleSheet, View } from 'react-native';
import { Image, type ImageSource } from 'expo-image';
import { Text } from 'react-native-paper';
import React from 'react';
import Svg, { Rect } from 'react-native-svg';

interface BoundingBox {
  x: number;
  y: number;
  width: number;
  height: number;
}

export default function ImageViewer({
  imgSource,
  text,
  count,
  timestamp,
  clicked,
  boxes,
}: {
  imgSource: ImageSource;
  text: any;
  count: any;
  timestamp: any;
  clicked: any;
  boxes: BoundingBox[]; // New prop to handle the bounding boxes
}) {
  return (
    <View style={styles.container}>
      <Image source={imgSource} style={styles.image} contentFit="contain" />
      
      {/* SVG component for rendering bounding boxes */}
      <Svg style={styles.svg}>
        {boxes.map((box, index) => (
          <Rect
            key={index}
            x={box.x}
            y={box.y}
            width={box.width}
            height={box.height}
            stroke="red"
            strokeWidth="2"
            fill="transparent"
          />
        ))}
      </Svg>
      
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
  svg: {
    position: 'absolute',
    top: 0,
    left: 0,
    zIndex: 1,
  },
  text: {
    position: 'absolute',
    top: '1%', // Distance from the top of the image
    left: '1%',
    alignSelf: 'center',
    color: 'black', // Ensure text is visible against the image
    fontWeight: 'bold', // Make the text stand out
    paddingHorizontal: 10,
    paddingVertical: 5,
    borderRadius: 5,
  },
  count: {
    position: 'absolute',
    top: '1%', // Distance from the top of the image
    right: '1%',
    alignSelf: 'flex-end',
    color: 'black', // Ensure text is visible against the image
    fontWeight: 'bold', // Make the text stand out
    paddingHorizontal: 10,
    paddingVertical: 5,
    borderRadius: 5,
  },
  timestamp: {
    position: 'absolute',
    bottom: '1%', // Distance from the bottom of the image
    left: '1%',
    alignSelf: 'flex-end',
    color: 'black', // Ensure text is visible against the image
    fontWeight: 'bold', // Make the text stand out
    paddingHorizontal: 10,
    paddingVertical: 5,
    borderRadius: 5,
  },
});
