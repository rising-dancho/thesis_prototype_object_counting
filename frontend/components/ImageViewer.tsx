import React from 'react';
import { StyleSheet, View } from 'react-native';
import { Image } from 'expo-image';
import { Text } from 'react-native-paper';
import Svg, { Rect, Text as SvgText } from 'react-native-svg';

interface BoundingBox {
  x: number;
  y: number;
  width: number;
  height: number;
}
type ImageSource = string | undefined;
interface ImageViewerProps {
  imgSource?: ImageSource;
  text?: any;
  count?: any;
  timestamp?: any;
  clicked?: any;
  boxes: BoundingBox[];
  response?: any;
  imageDimensions?: { width: number; height: number } | null;
  scaleBoxCoordinates: (box: BoundingBox) => BoundingBox;
}

const PlaceholderImage = require('@/assets/images/background-image.png');

export default function ImageViewer({
  imgSource,
  text,
  count,
  timestamp,
  clicked,
  boxes = [],
  response,
  imageDimensions,
  scaleBoxCoordinates,
}: ImageViewerProps) {
  // Setting a fixed display size
  const displayWidth = 520; // Reduced for smaller scaling
  const displayHeight = 640; // Adjusted for a balanced ratio

  const scaledDimensions: { width: number; height: number } = imageDimensions
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
        <View
          style={[
            styles.imageContainer,
            !imgSource && { height: 640 }, // Conditionally set height
          ]}
        >
          {/* Render PlaceholderImage independently if imgSource is not provided */}
          {!imgSource && (
            <Image source={PlaceholderImage} style={styles.placeholderImage} />
          )}

          {/* Render the dynamic image if imgSource is provided */}
          {imgSource && <Image source={imgSource} style={scaledDimensions} />}

          {/* SVG Overlay for Bounding Boxes */}
          {imageDimensions && (
            <Svg
              height={scaledDimensions.height}
              width={scaledDimensions.width}
              style={styles.svg}
            >
              {boxes.map((box, index) => {
                const scaledBox = scaleBoxCoordinates(box);
                return (
                  <React.Fragment key={index}>
                    <Rect
                      x={
                        scaledBox.x *
                        (scaledDimensions.width / imageDimensions.width)
                      }
                      y={
                        scaledBox.y *
                        (scaledDimensions.height / imageDimensions.height)
                      }
                      width={
                        scaledBox.width *
                        (scaledDimensions.width / imageDimensions.width)
                      }
                      height={
                        scaledBox.height *
                        (scaledDimensions.height / imageDimensions.height)
                      }
                      stroke="#00FF00"
                      fill="transparent"
                      strokeWidth="2"
                    />
                    <SvgText
                      x={
                        (scaledBox.x + scaledBox.width / 2) *
                        (scaledDimensions.width / imageDimensions.width)
                      }
                      y={
                        (scaledBox.y + scaledBox.height / 2) *
                        (scaledDimensions.height / imageDimensions.height)
                      }
                      fill="#122FBA"
                      fontSize="16"
                      fontWeight="bold"
                      textAnchor="middle"
                    >
                      {index + 1}
                    </SvgText>
                  </React.Fragment>
                );
              })}
            </Svg>
          )}
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
    justifyContent: 'center',
    padding: 3,
    backgroundColor: '#F4F4F5',
    // borderStyle: 'solid',
    // borderColor: 'red',
    // borderWidth: 1,
  },
  placeholderImage: {
    width: '100%', // Full width of the parent
    height: '100%', // Full height of the parent
    resizeMode: 'contain', // Maintain aspect ratio
  },
  image: {
    flex: 1, // Stretches to fill the container
    width: '100%', // Full width of the parent
    height: '100%', // Full height of the parent
    resizeMode: 'cover', // Covers the entire space while maintaining aspect ratio
  },
  flex: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
  },
  imageContainer: {
    position: 'relative',
    overflow: 'hidden',
    backgroundColor: '#F4F4F5',
    width: '100%', // Ensure the container takes the full width of the parent
    // height: 640, // Add a height for the placeholder to render properly
    // borderStyle: 'solid',
    // borderColor: 'red',
    // borderWidth: 1,
  },
  svg: {
    position: 'absolute',
    top: 0,
    left: 0,
  },
  title: {
    paddingBottom: 3,
    fontWeight: '700',
    fontSize: 18,
    // borderStyle: 'solid',
    // borderColor: 'red',
    // borderWidth: 1,
  },
  count: {
    fontSize: 16,
    fontWeight: 'bold',
    // borderStyle: 'solid',
    // borderColor: 'red',
    // borderWidth: 1,
  },
  timestamp: {
    fontSize: 16,
    fontWeight: 'bold',
    // borderStyle: 'solid',
    // borderColor: 'red',
    // borderWidth: 1,
  },
});
