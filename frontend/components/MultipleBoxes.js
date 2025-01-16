import React from 'react';
import { View, StyleSheet } from 'react-native';
import { GestureDetector, Gesture } from 'react-native-gesture-handler';
import Animated, {
  useSharedValue,
  useAnimatedStyle,
} from 'react-native-reanimated';
import Svg, { Rect, Text } from 'react-native-svg';

// Animated components for Rect and Text
const AnimatedRect = Animated.createAnimatedComponent(Rect);
const AnimatedText = Animated.createAnimatedComponent(Text);

const MovableRectangles = ({ rectangles }) => {
  return (
    <View style={styles.container}>
      {rectangles.map(([x1, y1, width, height], index) => {
        const translateX = useSharedValue(0);
        const translateY = useSharedValue(0);

        // Gesture handler for dragging each rectangle
        const drag = Gesture.Pan().onUpdate((event) => {
          translateX.value = event.translationX;
          translateY.value = event.translationY;
        });

        // Animated style for each rectangle
        const animatedStyle = useAnimatedStyle(() => ({
          transform: [
            { translateX: translateX.value },
            { translateY: translateY.value },
          ],
        }));

        return (
          <GestureDetector key={index} gesture={drag}>
            <Animated.View style={animatedStyle}>
              <Svg width={width} height={height}>
                {/* Rect with provided dimensions */}
                <AnimatedRect
                  x={x1}
                  y={y1}
                  width={width}
                  height={height}
                  fill="transparent"
                  stroke="blue"
                  strokeWidth={2}
                />
                {/* Centered Text */}
                <AnimatedText
                  fill="red"
                  fontSize="20"
                  fontWeight="bold"
                  x={x1 + width / 2}
                  y={y1 + height / 2}
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
    justifyContent: 'center',
    alignItems: 'center',
    flex: 1,
  },
});

export default function App() {
  const boundingBoxes = [
    [50, 20, 157, 195],
    [87, 30, 191, 142],
    [20, 40, 101, 147],
  ];

  return <MovableRectangles rectangles={boundingBoxes} />;
}
