import React, { useState } from 'react';
import { View, Text, Button, Image, StyleSheet } from 'react-native';
import { Svg, Rect } from 'react-native-svg'; // Import the SVG components

const BoundingBoxExample = () => {
  const [boxes, setBoxes] = useState([]); // Holds the bounding boxes
  // const [image, setImage] = useState('../assets/images/apples.jpg'); // Replace with actual image URL

  const addBox = (x, y, width, height) => {
    setBoxes([
      ...boxes,
      { x, y, width, height }, // Add new box to the array
    ]);
  };

  return (
    <View style={styles.container}>
      <Text style={styles.title}>Image with Bounding Boxes</Text>

      {/* Image to draw bounding boxes on */}
      <Image source="../assets/images/apples.jpg'" style={styles.image} />

      {/* SVG component to draw the boxes */}
      <Svg height="100%" width="100%" style={styles.svg}>
        {boxes.map((box, index) => (
          <Rect
            key={index}
            x={box.x}
            y={box.y}
            width={box.width}
            height={box.height}
            stroke="blue"
            fill="transparent"
            strokeWidth="2"
          />
        ))}
      </Svg>

      {/* Example of adding a box */}
      <Button title="Add Box" onPress={() => addBox(50, 50, 100, 100)} />
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    padding: 16,
  },
  title: {
    fontSize: 24,
    marginBottom: 10,
  },
  image: {
    width: 300,
    height: 300,
    position: 'absolute', // Make sure the image stays in place
  },
  svg: {
    position: 'absolute', // Overlay the SVG (bounding boxes) on top of the image
    top: 0,
    left: 0,
    width: '100%',
    height: '100%',
  },
});

export default BoundingBoxExample;
