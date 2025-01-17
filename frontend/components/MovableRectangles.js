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

export default function MovableRectangles({ boxes }) {
  console.log('Boxes:', boxes); // Log the whole boxes array to check its structure

  return (
    <View style={styles.container}>
      {boxes.map((box, index) => {
        // Directly destructure x, y, width, and height from the box
        const { x, y, width, height } = box;

        console.log(x, 'x', y, 'y', width, 'width', height, 'height'); // Check individual box properties

        const translateX = useSharedValue(x);
        const translateY = useSharedValue(y);

        const drag = Gesture.Pan().onUpdate((event) => {
          translateX.value = x + event.translationX;
          translateY.value = y + event.translationY;
        });

        const animatedStyle = useAnimatedStyle(() => ({
          transform: [
            { translateX: translateX.value - x },
            { translateY: translateY.value - y },
          ],
        }));

        return (
          <GestureDetector key={index} gesture={drag}>
            <Animated.View style={animatedStyle}>
              <Svg width={width} height={height}>
                <AnimatedRect
                  x={0} // Adjusted to avoid double offset
                  y={0}
                  width={width}
                  height={height}
                  stroke="#00FF00"
                  fill="transparent"
                  strokeWidth="3"
                />
                <AnimatedText
                  fill="#122FBA"
                  fontSize="22"
                  fontWeight="bold"
                  textAnchor="middle"
                  x={width / 2}
                  y={height / 2}
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
}
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

// export default function App() {
//   const boundingBoxes = [
//     [50, 20, 157, 195],
//     [87, 30, 191, 142],
//     [20, 40, 101, 147],
//   ];

//   return <MovableRectangles boxes={boundingBoxes} />;
// }
