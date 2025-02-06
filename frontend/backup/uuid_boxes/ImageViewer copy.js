import React from 'react';
import { StyleSheet, View } from 'react-native';
import { Image } from 'expo-image';
import { Text } from 'react-native-paper';
import MovableRectangles from '../../components/MovableRectangles';

export default function ImageViewer({
  imgSource,
  text,
  count,
  timestamp,
  clicked,
  boxes = [],
  response,
  imageDimensions,
  setBoxes,
}) {
  // Setting a fixed display size
  const displayWidth = 520; // Reduced for smaller scaling
  const displayHeight = 640; // Adjusted for a balanced ratio

  const scaledDimensions = imageDimensions?.width
    ? {
        width: displayWidth,
        height: (imageDimensions.height / imageDimensions.width) * displayWidth,
      }
    : {
        width: displayWidth,
        height: displayHeight,
      };

  return (
    <View style={styles.container}>
      <View style={styles.flex}>
        <Text variant="labelLarge" style={styles.title}>
          {text || ''}
        </Text>
        {clicked && (
          <Text variant="labelLarge" style={styles.count}>
            Total Count: {count || ''}
          </Text>
        )}
      </View>

      {response && (
        <View style={[styles.imageContainer, !imgSource && { height: 640 }]}>
          {/* Render the dynamic image if imgSource is provided */}
          {imgSource && <Image source={imgSource} style={scaledDimensions} />}

          {/* Render bounding boxes using the MovableRectangles component */}
          <MovableRectangles
            boxes={boxes}
            imageDimensions={imageDimensions}
            scaledDimensions={scaledDimensions}
            setBoxes={setBoxes} // Pass setBoxes to MovableRectangles
          />
        </View>
      )}

      {/* Text Information */}
      <Text variant="labelLarge" style={styles.timestamp}>
        {timestamp}
      </Text>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    backgroundColor: '#F4F4F5',
  },
  imageContainer: {
    position: 'relative',
    overflow: 'hidden',
    backgroundColor: '#25292e',
    width: '100%', // Ensure the container takes the full width of the parent
  },
  flex: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
  },
  title: {
    paddingBottom: 3,
    fontWeight: '700',
    fontSize: 18,
  },
  count: {
    fontSize: 16,
    fontWeight: 'bold',
  },
  timestamp: {
    fontSize: 16,
    fontWeight: 'bold',
  },
});
