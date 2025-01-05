import { StyleSheet, View } from 'react-native';
import { Image, type ImageSource } from 'expo-image';
import { Text } from 'react-native-paper';
import React, { Fragment } from 'react';
import Svg, { Rect, Text as SvgText } from 'react-native-svg';

interface BoundingBox {
  x: number;
  y: number;
  width: number;
  height: number;
}

export default function ImageViewer({
  text,
  count,
  timestamp,
  clicked,
  boxes,
  response,
  imageDimensions,
  scaleBoxCoordinates,
}: {
  imgSource: ImageSource;
  text: any;
  count: any;
  timestamp: any;
  clicked: any;
  boxes: BoundingBox[]; // New prop to handle the bounding boxes
  response: any;
  imageDimensions: any;
  scaleBoxCoordinates: any;
}) {
  return (
    <View style={styles.container}>
      {response && (
        <View>
          <View style={styles.imageContainer}>
            <Image
              source={{
                uri: `data:image/png;base64,${response.processed_image}`,
              }}
              style={{
                width: imageDimensions?.width,
                height: imageDimensions?.height,
                resizeMode: 'contain', // Ensures image is contained within bounds
              }}
            />
            {/* SVG component to draw the boxes */}
            {imageDimensions && (
              <Svg
                height={imageDimensions.height}
                width={imageDimensions.width}
                style={styles.svg}
              >
                {boxes.map((box, index) => {
                  const scaledBox = scaleBoxCoordinates(box);
                  return (
                    <Fragment key={index}>
                      {/* Bounding Box */}
                      <Rect
                        x={scaledBox.x}
                        y={scaledBox.y}
                        width={scaledBox.width}
                        height={scaledBox.height}
                        stroke="#00FF00"
                        fill="transparent"
                        strokeWidth="3"
                      />
                      {/* Object Number */}
                      <SvgText
                        x={scaledBox.x + scaledBox.width / 2}
                        y={scaledBox.y + scaledBox.height / 2}
                        fill="#122FBA"
                        fontSize="32"
                        fontWeight="bold"
                        textAnchor="middle"
                      >
                        {index + 1}
                      </SvgText>
                    </Fragment>
                  );
                })}
              </Svg>
            )}
          </View>
        </View>
      )}

      <Text variant="labelLarge" style={styles.text}>
        {text || ''}
      </Text>
      <Text variant="labelLarge" style={styles.count}>
        {clicked && `Total Count: ${response.object_count}`}
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
  subtitle: {
    fontSize: 20,
    marginTop: 20,
  },
  imageContainer: {
    position: 'relative',
    marginTop: 20,
  },
  objectCount: {
    fontSize: 18,
    marginTop: 10,
  },
});
