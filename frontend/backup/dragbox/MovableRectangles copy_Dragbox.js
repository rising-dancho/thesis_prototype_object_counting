import React from 'react';
import { View, StyleSheet, Image } from 'react-native';
import DragBox from '../../components/DragBox';

export default function MovableRectangles({
  boxes,
  imageDimensions,
  scaledDimensions,
  setBoxes,
  imageSource,
  onBoxRemove, // Function to remove a box
}) {
  return (
    <View style={styles.container}>
      <View
        style={{
          width: scaledDimensions.width,
          height: scaledDimensions.height,
        }}
      >
        {/* Background Image */}
        <Image
          source={imageSource}
          style={{
            width: scaledDimensions.width,
            height: scaledDimensions.height,
          }}
          resizeMode="contain"
        />

        {/* Render Draggable Bounding Boxes */}
        {boxes.map((box, index) => (
          <DragBox
            key={index}
            box={[
              box.x * (scaledDimensions.width / imageDimensions.width), // Scaled X
              box.y * (scaledDimensions.height / imageDimensions.height), // Scaled Y
              box.width * (scaledDimensions.width / imageDimensions.width), // Scaled Width
              box.height * (scaledDimensions.height / imageDimensions.height), // Scaled Height
            ]}
            index={index}
            setBoxes={setBoxes}
            isDraggable={true} // Change this dynamically to enable/disable dragging
          />
        ))}
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    position: 'absolute',
    justifyContent: 'center',
    alignItems: 'center',
  },
});
