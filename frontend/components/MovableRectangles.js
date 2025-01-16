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

const MovableRectangles = ({ boxes, imageDimensions, scaleBoxCoordinates, scaledDimensions }) => {
  return (
    <View style={styles.container}>
      {boxes.map((box, index) => {
        const scaledBox = scaleBoxCoordinates(box);

        // Shared values for dragging
        const translateX = useSharedValue(scaledBox.x);
        const translateY = useSharedValue(scaledBox.y);

        // Gesture handler for dragging each rectangle
        const drag = Gesture.Pan()
          .onUpdate((event) => {
            translateX.value = scaledBox.x + event.translationX;
            translateY.value = scaledBox.y + event.translationY;
          });

        // Animated style for each rectangle
        const animatedStyle = useAnimatedStyle(() => ({
          transform: [
            { translateX: translateX.value - scaledBox.x },
            { translateY: translateY.value - scaledBox.y },
          ],
        }));

        return (
          <GestureDetector key={index} gesture={drag}>
            <Animated.View style={animatedStyle}>
              <Svg
                height={scaledDimensions.height}
                width={scaledDimensions.width}
                style={styles.svg}
              >
                <AnimatedRect
                  x={translateX.value}
                  y={translateY.value}
                  width={scaledBox.width}
                  height={scaledBox.height}
                  stroke="#00FF00"
                  fill="transparent"
                  strokeWidth="3"
                />
                <AnimatedText
                  x={translateX.value + scaledBox.width / 2}
                  y={translateY.value + scaledBox.height / 2}
                  fill="#122FBA"
                  fontSize="22"
                  fontWeight="bold"
                  textAnchor="middle"
                >
                  {index + 1}
                </AnimatedText>
              </Svg>
            </Animated.View>
          </GestureDetector>
        );
      })}
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    position: 'absolute',
    top: 0,
    left: 0,
    width: '100%',
    height: '100%',
  },
  svg: {
    position: 'absolute',
    top: 0,
    left: 0,
  },
});

export default MovableRectangles;
