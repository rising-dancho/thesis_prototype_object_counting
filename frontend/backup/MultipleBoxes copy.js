import React from 'react';
import { View, StyleSheet, Button } from 'react-native';
import Animated, {
  useAnimatedProps,
  useSharedValue,
  withTiming,
} from 'react-native-reanimated';
import Svg, { Circle } from 'react-native-svg';

// Animated Circle component
const AnimatedCircle = Animated.createAnimatedComponent(Circle);

const CircularProgress = ({
  radius = 100,
  strokeWidth = 20,
  backgroundColor = 'purple',
}) => {
  const innerRadius = radius - strokeWidth / 2;
  const circumference = 2 * Math.PI * innerRadius;

  // Shared value for animation
  const progress = useSharedValue(0); // Start from 0% progress

  // Animated props for circle stroke offset
  const animatedProps = useAnimatedProps(() => ({
    strokeDashoffset: withTiming(
      circumference * (1 - progress.value),
      { duration: 1000 }
    ),
  }));

  const handlePress = () => {
    progress.value = progress.value === 1 ? 0 : 1; // Toggle animation
  };

  return (
    <View style={styles.container}>
      <Svg width={radius * 2} height={radius * 2}>
        {/* Background Circle */}
        <Circle
          cx={radius}
          cy={radius}
          r={innerRadius}
          stroke="lightgray"
          strokeWidth={strokeWidth}
          fill="transparent"
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
      </Svg>

      {/* Button to trigger animation */}
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
