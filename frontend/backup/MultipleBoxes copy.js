import React from 'react';
import { View, StyleSheet } from 'react-native';
import { GestureDetector, Gesture } from 'react-native-gesture-handler';
import Animated, {
  useSharedValue,
  useAnimatedStyle,
} from 'react-native-reanimated';
import Svg, { Circle, Text } from 'react-native-svg';

// Animated components for Circle and Text
const AnimatedCircle = Animated.createAnimatedComponent(Circle);
const AnimatedText = Animated.createAnimatedComponent(Text);

const MovableCircles = ({ circles }) => {
  return (
    <View style={styles.container}>
      {circles.map((circle, index) => {
        const translateX = useSharedValue(0);
        const translateY = useSharedValue(0);

        // Gesture handler for dragging each circle
        const drag = Gesture.Pan().onUpdate((event) => {
          translateX.value = event.translationX;
          translateY.value = event.translationY;
        });

        // Animated style for each circle
        const animatedStyle = useAnimatedStyle(() => ({
          transform: [
            { translateX: translateX.value },
            { translateY: translateY.value },
          ],
        }));

        return (
          <GestureDetector key={index} gesture={drag}>
            <Animated.View style={animatedStyle}>
              <Svg width={circle.radius * 2} height={circle.radius * 2}>
                {/* Circle with stroke */}
                <AnimatedCircle
                  cx={circle.radius}
                  cy={circle.radius}
                  r={circle.radius - circle.strokeWidth / 2}
                  fill="transparent"
                  stroke={circle.backgroundColor}
                  strokeWidth={circle.strokeWidth}
                />
                {/* Centered Text */}
                <AnimatedText
                  fill="red"
                  fontSize="20"
                  fontWeight="bold"
                  x={circle.radius}
                  y={circle.radius + 6} 
                  textAnchor="middle"
                >
                  {circle.text}
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
  const circlesData = [
    { radius: 80, strokeWidth: 10, backgroundColor: '#FF6347', text: 'A' },
    { radius: 100, strokeWidth: 15, backgroundColor: '#53D664', text: 'B' },
    { radius: 60, strokeWidth: 8, backgroundColor: '#1E90FF', text: 'C' },
  ];

  return <MovableCircles circles={circlesData} />;
}
