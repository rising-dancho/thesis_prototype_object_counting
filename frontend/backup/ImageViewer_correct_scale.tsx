import React from 'react';
import { StyleSheet, View } from 'react-native';
import { Image, type ImageSource } from 'expo-image';
import { Text } from 'react-native-paper';
import Svg, { Rect, Text as SvgText } from 'react-native-svg';

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
  boxes = [],
  response,
  imageDimensions,
  scaleBoxCoordinates,
}: {
  imgSource: ImageSource;
  text?: string;
  count?: any;
  timestamp?: string;
  clicked?: boolean;
  boxes: BoundingBox[];
  response?: any;
  imageDimensions?: { width: number; height: number } | null;
  scaleBoxCoordinates: (box: BoundingBox) => BoundingBox;
}) {
  // Setting a fixed display size
  const displayWidth = 300; // Reduced for smaller scaling
  const displayHeight = 400; // Adjusted for a balanced ratio

  const scaledDimensions = imageDimensions
    ? {
        width: displayWidth,
        height: (imageDimensions.height / imageDimensions.width) * displayWidth,
      }
    : { width: displayWidth, height: displayHeight };

  return (
    <View style={styles.container}>
      {response && (
        <View style={styles.imageContainer}>
          {/* Image */}
          <Image
            source={imgSource}
            style={{
              width: scaledDimensions.width,
              height: scaledDimensions.height,
              resizeMode: 'contain',
            }}
          />

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
                      x={scaledBox.x * (scaledDimensions.width / imageDimensions.width)}
                      y={scaledBox.y * (scaledDimensions.height / imageDimensions.height)}
                      width={scaledBox.width * (scaledDimensions.width / imageDimensions.width)}
                      height={scaledBox.height * (scaledDimensions.height / imageDimensions.height)}
                      stroke="#00FF00"
                      fill="transparent"
                      strokeWidth="2"
                    />
                    <SvgText
                      x={(scaledBox.x + scaledBox.width / 2) * (scaledDimensions.width / imageDimensions.width)}
                      y={(scaledBox.y + scaledBox.height / 2) * (scaledDimensions.height / imageDimensions.height)}
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
      <Text variant="labelLarge" style={styles.title}>{text || ''}</Text>
      {clicked && <Text variant="labelLarge" style={styles.count}>Total Count: {count || ''}</Text>}
      <Text variant="labelLarge" style={styles.timestamp}>{timestamp}</Text>
    </View>
  );
}

const styles = StyleSheet.create({
  container: { 
    alignItems: 'center',
    justifyContent: 'center',
    padding: 10,
  },
  imageContainer: {
    position: 'relative',
    borderWidth: 1,
    borderColor: '#ccc',
    overflow: 'hidden',
  },
  svg: {
    position: 'absolute',
    top: 0,
    left: 0,
  },
  title: {
    marginTop: 10,
    fontWeight: 'bold',
    fontSize: 16,
  },
  count: {
    marginTop: 5,
    fontSize: 14,
  },
  timestamp: {
    marginTop: 5,
    fontSize: 14,
  },
});
