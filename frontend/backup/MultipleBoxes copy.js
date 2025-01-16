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
      {rectangles.map((rectangle, index) => {
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
              <Svg width={rectangle.width * 2} height={rectangle.width * 2}>
                {/* Rect with stroke */}
                <AnimatedRect
                  x={rectangle.width / 2 - 35} // Centered horizontally
                  y={rectangle.width / 2 - 35} // Centered vertically
                  width="70"
                  height="70"
                  fill="transparent"
                  stroke={rectangle.backgroundColor}
                  strokeWidth={rectangle.strokeWidth}
                />
                {/* Centered Text */}
                <AnimatedText
                  fill="red"
                  fontSize="20"
                  fontWeight="bold"
                  x={rectangle.width / 2}
                  y={rectangle.width / 2 + 6}
                  textAnchor="middle"
                >
                  {rectangle.text}
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
  const rectanglesData = [
    { width: 80, strokeWidth: 10, backgroundColor: '#FF6347', text: '1' },
    { width: 100, strokeWidth: 15, backgroundColor: '#53D664', text: '2' },
    { width: 120, strokeWidth: 8, backgroundColor: '#1E90FF', text: '3' },
  ];

  return <MovableRectangles rectangles={rectanglesData} />;
}
