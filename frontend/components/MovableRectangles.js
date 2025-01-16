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

const MovableRectangles = ({
  boxes,
  // imageDimensions,
  // scaleBoxCoordinates,
  // scaledDimensions,
}) => {
  return (
    <View style={styles.container}>
      {boxes.map(([x1, y1, width, height], index) => {
        // Individual shared values for each rectangle
        const translateX = useSharedValue(x1);
        const translateY = useSharedValue(y1);

        // Gesture handler for dragging each rectangle
        const drag = Gesture.Pan().onUpdate((event) => {
          translateX.value = x1 + event.translationX;
          translateY.value = y1 + event.translationY;
        });

        // Animated style for each rectangle
        const animatedStyle = useAnimatedStyle(() => ({
          transform: [
            { translateX: translateX.value - x1 },
            { translateY: translateY.value - y1 },
          ],
        }));

        return (
          <GestureDetector key={index} gesture={drag}>
            <Animated.View style={animatedStyle}>
              <Svg width={width} height={height}>
                <AnimatedRect
                  x={0}
                  y={0}
                  width={width}
                  height={height}
                  fill="transparent"
                  stroke="blue"
                  strokeWidth={2}
                />
                <AnimatedText
                  fill="red"
                  fontSize="20"
                  fontWeight="bold"
                  x={width / 2}
                  y={height / 2}
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

export default function App() {
  const boundingBoxes = [
    [50, 20, 157, 195],
    [87, 30, 191, 142],
    [20, 40, 101, 147],
  ];

  return <MovableRectangles boxes={boundingBoxes} />;
}
