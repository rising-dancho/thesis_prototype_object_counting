import React from 'react';
import { View, StyleSheet, Image } from 'react-native';
import DragBox from '../components/DragBox.js';

export default function MovableRectangles({
  boxes,
  imageDimensions,
  scaledDimensions,
  setBoxes,
  imageSource,
}) {
  const onBoxRemove = (id) => {
    setBoxes((prevBoxes) => prevBoxes.filter((box) => box.id !== id)); // Remove box with matching id
  };

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
            key={box.id} // ✅ Ensure key is set correctly
            id={box.id} // ✅ Pass id explicitly
            count={index}
            box={[
              box.x * (scaledDimensions.width / imageDimensions.width), // Scaled X
              box.y * (scaledDimensions.height / imageDimensions.height), // Scaled Y
              box.width * (scaledDimensions.width / imageDimensions.width), // Scaled Width
              box.height * (scaledDimensions.height / imageDimensions.height), // Scaled Height
            ]}
            index={box.id} // Use box.id as the index
            setBoxes={setBoxes}
            isDraggable={true}
            onBoxRemove={() => onBoxRemove(box.id)} // Pass the correct ID
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
