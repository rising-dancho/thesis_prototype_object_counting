import React from 'react';
import { View, StyleSheet, Button } from 'react-native';
import { GestureDetector, Gesture } from 'react-native-gesture-handler';
import Animated, {
  useAnimatedProps,
  useSharedValue,
  withTiming,
  useAnimatedStyle,
} from 'react-native-reanimated';
import Svg, { Circle, Text } from 'react-native-svg';

// Animated components for Circle and Text
const AnimatedCircle = Animated.createAnimatedComponent(Circle);
const AnimatedText = Animated.createAnimatedComponent(Text);

const CircularProgress = ({
  radius = 100,
  strokeWidth = 20,
  backgroundColor = '#53D664',
}) => {
  const innerRadius = radius - strokeWidth / 2;
  const circumference = 2 * Math.PI * innerRadius;
  const translateX = useSharedValue(0);
  const translateY = useSharedValue(0);

  // Shared value for animation
  const progress = useSharedValue(0);

  // Animated props for circle stroke offset
  const animatedProps = useAnimatedProps(() => ({
    strokeDashoffset: withTiming(circumference * (1 - progress.value), {
      duration: 1000,
    }),
  }));

  const handlePress = () => {
    progress.value = progress.value === 1 ? 0 : 1;
  };

  // Gesture handler for dragging
  const drag = Gesture.Pan().onUpdate((event) => {
    translateX.value = event.translationX;
    translateY.value = event.translationY;
  });

  // Animated style to move both elements together
  const containerStyle = useAnimatedStyle(() => ({
    transform: [
      { translateX: translateX.value },
      { translateY: translateY.value },
    ],
  }));

  return (
    <View style={styles.container}>
      {/* Gesture Detector wrapping both circle and text */}
      <GestureDetector gesture={drag}>
        <Animated.View style={containerStyle}>
          {/* SVG for the circular progress */}
          <Svg width={radius * 2} height={radius * 2}>
            {/* Background Circle */}
            <Circle
              cx={radius}
              cy={radius}
              r={innerRadius}
              fill="transparent"
              stroke="#E0E0E0"
              strokeWidth={strokeWidth}
            />

            {/* Animated Circle */}
            <AnimatedCircle
              cx={radius}
              cy={radius}
              r={innerRadius}
              fill="transparent"
              stroke={backgroundColor}
              strokeWidth={strokeWidth}
              strokeDasharray={`${circumference}, ${circumference}`}
              animatedProps={animatedProps}
              strokeLinecap="round"
            />

            {/* Animated Text Centered in the Circle */}
            <AnimatedText
              fill="red"
              fontSize="20"
              fontWeight="bold"
              x={radius}
              y={radius + 6} // Adjusted for vertical centering
              textAnchor="middle"
            >
              STROKED TEXT
            </AnimatedText>
          </Svg>
        </Animated.View>
      </GestureDetector>

      {/* Button to trigger progress animation */}
      <Button title="Animate Progress" onPress={handlePress} />
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

export default CircularProgress;
