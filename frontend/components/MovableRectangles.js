import React from 'react';
import { View, StyleSheet, Image } from 'react-native';
import { GestureDetector, Gesture } from 'react-native-gesture-handler';
import Animated, {
  useSharedValue,
  useAnimatedStyle,
} from 'react-native-reanimated';
import Svg, { Rect, Text as SvgText } from 'react-native-svg';

// Animated components for Rect and Text
const AnimatedRect = Animated.createAnimatedComponent(Rect);
const AnimatedText = Animated.createAnimatedComponent(SvgText);

export default function MovableRectangles({
  boxes,
  imageDimensions,
  scaledDimensions,
  imageSource,
  onBoxRemove, // Function to remove a box
}) {
  // Create shared values for translation outside of the map
  const translateXValues = boxes.map((box) =>
    useSharedValue(box.x * (scaledDimensions.width / imageDimensions.width))
  );
  const translateYValues = boxes.map((box) =>
    useSharedValue(box.y * (scaledDimensions.height / imageDimensions.height))
  );

  return (
    <View style={styles.container}>
      <View
        style={{
          width: scaledDimensions.width,
          height: scaledDimensions.height,
        }}
      >
        <Image
          source={imageSource}
          style={{
            width: scaledDimensions.width,
            height: scaledDimensions.height,
          }}
          resizeMode="contain"
        />

        {boxes.map((box, index) => {
          const { width, height } = box;

          // Scale the bounding box's dimensions
          const scaledWidth =
            width * (scaledDimensions.width / imageDimensions.width);
          const scaledHeight =
            height * (scaledDimensions.height / imageDimensions.height);

          // Define gesture for dragging the box
          const drag = Gesture.Pan().onUpdate((event) => {
            // Update the position based on the initial position and the current translation
            translateXValues[index].value =
              box.x * (scaledDimensions.width / imageDimensions.width) +
              event.translationX;
            translateYValues[index].value =
              box.y * (scaledDimensions.height / imageDimensions.height) +
              event.translationY;
          });

          // Apply animated styles for translation during drag
          const animatedStyle = useAnimatedStyle(() => ({
            position: 'absolute',
            left: translateXValues[index].value,
            top: translateYValues[index].value,
          }));

          return (
            <GestureDetector key={index} gesture={drag}>
              <Animated.View style={[styles.boxContainer, animatedStyle]}>
                <Svg width={scaledWidth} height={scaledHeight}>
                  <AnimatedRect
                    x={0}
                    y={0}
                    width={scaledWidth}
                    height={scaledHeight}
                    stroke="#00FF00"
                    fill="transparent"
                    strokeWidth="6"
                  />
                  <AnimatedText
                    fill="#122FBA"
                    fontSize="22"
                    fontWeight="bold"
                    textAnchor="middle"
                    x={scaledWidth / 2}
                    y={scaledHeight / 2}
                  >
                    {index + 1}
                  </AnimatedText>
                </Svg>
                <View
                  style={styles.closeButton}
                  onTouchEnd={() => onBoxRemove(index)}
                >
                  {/* Close button logic */}
                </View>
              </Animated.View>
            </GestureDetector>
          );
        })}
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
  boxContainer: {
    position: 'absolute',
  },
  closeButton: {
    position: 'absolute',
    top: -20,
    right: -20,
    backgroundColor: 'red',
    color: 'white',
    borderRadius: 2,
  },
});
