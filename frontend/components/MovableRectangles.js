import React from 'react';
import { View, StyleSheet } from 'react-native';
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
}) {
  console.log('Boxes:', boxes); // Log the whole boxes array to check its structure

  // console.log('scaledDimensions:', imageDimensions);
  console.log('scaledDimensions.width:', scaledDimensions.width);
  console.log('scaledDimensions.height:', scaledDimensions.height);

  // console.log('imageDimensions:', imageDimensions);
  console.log('imageDimensions.width:', imageDimensions.width);
  console.log('imageDimensions.height:', imageDimensions.height);

  return (
    <View style={styles.container}>
      {boxes.map((box, index) => {
        // Destructure x, y, width, and height from the box
        const { x, y, width, height } = box;

        console.log(
          'bounding box x',
          box.x * (scaledDimensions.width / imageDimensions.width)
        );
        console.log(
          'bounding box y',
          box.y * (scaledDimensions.height / imageDimensions.height)
        );

        console.log(x, 'x', y, 'y', width, 'width', height, 'height'); // Check individual box properties

        // Scale the bounding box's position
        const scaledX = x * (scaledDimensions.width / imageDimensions.width);
        const scaledY = y * (scaledDimensions.height / imageDimensions.height);

        // Set initial shared values for translation
        const translateX = useSharedValue(scaledX);
        const translateY = useSharedValue(scaledY);

        // Define gesture for dragging the box
        const drag = Gesture.Pan().onUpdate((event) => {
          translateX.value = scaledX + event.translationX;
          translateY.value = scaledY + event.translationY;
        });

        // Apply animated styles for translation during drag
        const animatedStyle = useAnimatedStyle(() => ({
          transform: [
            { translateX: translateX.value - scaledX },
            { translateY: translateY.value - scaledY },
          ],
        }));

        return (
          <GestureDetector key={index} gesture={drag}>
            <Animated.View style={animatedStyle}>
              <View style={styles.svgContainer}>
                <Svg
                  height={scaledDimensions.height}
                  width={scaledDimensions.width}
                  // style={styles.svg}
                >
                  <AnimatedRect
                    x={scaledX} // Use scaled position for x
                    y={scaledY} // Use scaled position for y
                    width={
                      width * (scaledDimensions.width / imageDimensions.width)
                    } // Scale width
                    height={
                      height *
                      (scaledDimensions.height / imageDimensions.height)
                    } // Scale height
                    stroke="#00FF00"
                    fill="transparent"
                    strokeWidth="3"
                  />
                  <AnimatedText
                    fill="#122FBA"
                    fontSize="22"
                    fontWeight="bold"
                    textAnchor="middle"
                    x={
                      scaledX +
                      (width *
                        (scaledDimensions.width / imageDimensions.width)) /
                        2
                    }
                    y={
                      scaledY +
                      (height *
                        (scaledDimensions.height / imageDimensions.height)) /
                        2
                    }
                  >
                    {index + 1}
                  </AnimatedText>
                </Svg>
              </View>
            </Animated.View>
          </GestureDetector>
        );
      })}
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    position: 'relative',
    top: 0,
    left: 0,
    width: '100%',
    borderStyle: 'solid',
    borderColor: 'red',
    borderWidth: 1,
    // borderStyle: 'solid',
    // borderColor: 'red',
    // borderWidth: 1,
  },
  svgContainer: {
    // Remove absolute positioning, let it flow naturally
    width: '100%',
    height: '100%',
    borderStyle: 'solid',
    borderColor: 'red',
    borderWidth: 1,
    // borderStyle: 'solid',
    // borderColor: 'red',
    // borderWidth: 1,
  },
  svg: {
    // Ensure the SVG takes up the full container space
    width: '100%',
    height: '100%',
    borderStyle: 'solid',
    borderColor: 'red',
    borderWidth: 1,
    // borderStyle: 'solid',
    // borderColor: 'red',
    // borderWidth: 1,
  },
});
