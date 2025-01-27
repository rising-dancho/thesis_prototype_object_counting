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
  const sharedValues = boxes.map((box) => {
    const { x, y } = box;
    const translateX = useSharedValue(
      x * (scaledDimensions.width / imageDimensions.width)
    );
    const translateY = useSharedValue(
      y * (scaledDimensions.height / imageDimensions.height)
    );

    return { translateX, translateY };
  });

  const animatedStyles = sharedValues.map(({ translateX, translateY }) =>
    useAnimatedStyle(() => ({
      position: 'absolute',
      left: translateX.value,
      top: translateY.value,
    }))
  );

  return (
    <View style={styles.container}>
      {/* Wrap the image and boxes inside a relative container */}
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

        {boxes.map((box, index) => {
          // Destructure x, y, width, and height from the box
          const { x, y, width, height } = box;

          // Scale the bounding box's position
          const scaledX = x * (scaledDimensions.width / imageDimensions.width);

          const scaledY =
            y * (scaledDimensions.height / imageDimensions.height);

          const scaledWidth =
            width * (scaledDimensions.width / imageDimensions.width);

          const scaledHeight =
            height * (scaledDimensions.height / imageDimensions.height);

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
            position: 'absolute', // Absolute positioning over the image
            left: translateX.value,
            top: translateY.value,
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
                    strokeWidth="3"
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
                {/* Button to remove the box */}
                <View
                  style={styles.closeButton}
                  onTouchEnd={() => onBoxRemove(index)}
                >
                  {/* <SvgText fill="#FF0000" fontSize="18" fontWeight="bold">
                    ✖
                  </SvgText> */}
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
    // borderStyle: 'solid',
    // borderColor: 'red',
    // borderWidth: 1,
  },
  boxContainer: {
    position: 'absolute', // Ensure the boxes are positioned absolutely
    // borderStyle: 'solid',
    // borderColor: 'red',
    // borderWidth: 2,
  },
  closeButton: {
    position: 'absolute',
    top: -20, // Position above the box
    right: -20, // Position to the right of the box
    backgroundColor: 'red',
    color: 'white',
    borderRadius: 2,
    // padding: 2,
    // paddingLeft: 6,
    // paddingRight: 6,
    // zIndex: 2,
  },
});
