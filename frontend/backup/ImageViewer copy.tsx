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

  const scaledDimensions = imageDimensions
    ? {
        width: displayWidth,
        height: (imageDimensions.height / imageDimensions.width) * displayWidth,
      }
    : styles.image; // Uses default dimensions directly if not provided

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
        <View style={styles.imageContainer}>
          {/* Image */}
          <Image source={imgSource} style={scaledDimensions} />

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
    padding: 3,
    backgroundColor: '#F4F4F5',
    borderStyle: 'solid',
    borderColor: 'red',
    borderWidth: 1,
  },
  image: {
    width: 520, // Default width
    height: 640, // Default height
    resizeMode: 'contain',
    // borderColor: 'red',
    // borderWidth: 1,
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
    borderStyle: 'solid',
    borderColor: 'red',
    borderWidth: 1,
  },
  svg: {
    position: 'absolute',
    top: 0,
    left: 0,
  },
  title: {
    marginTop: 10,
    fontWeight: '700',
    fontSize: 18,
    borderStyle: 'solid',
    borderColor: 'red',
    borderWidth: 1,
  },
  count: {
    marginTop: 5,
    fontSize: 16,
    fontWeight: 'bold',
    borderStyle: 'solid',
    borderColor: 'red',
    borderWidth: 1,
  },
  timestamp: {
    marginTop: 5,
    fontSize: 16,
    fontWeight: 'bold',
    borderStyle: 'solid',
    borderColor: 'red',
    borderWidth: 1,
  },
});
