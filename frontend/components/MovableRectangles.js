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
  scaledDimensions,
  imageDimensions,
}) {
  return (
    <View style={styles.container}>
      {boxes.map((box, index) => {
        // Individual shared values for each rectangle
        const translateX = useSharedValue(box.x1);
        const translateY = useSharedValue(box.y1);

        // Gesture handler for dragging each rectangle
        const drag = Gesture.Pan().onUpdate((event) => {
          translateX.value = box.x1 + event.translationX;
          translateY.value = box.y1 + event.translationY;
        });

        // Animated style for each rectangle
        const animatedStyle = useAnimatedStyle(() => ({
          transform: [
            { translateX: translateX.value - box.x1 },
            { translateY: translateY.value - box.y1 },
          ],
        }));

        return (
          <GestureDetector key={index} gesture={drag}>
            <Animated.View style={animatedStyle}>
              {imageDimensions && (
                <Svg
                  width={scaledDimensions.height}
                  height={scaledDimensions.width}
                  style={styles.svg}
                >
                  <AnimatedRect
                    x={
                      (box?.x || 0) *
                      (scaledDimensions?.width / (imageDimensions?.width || 1))
                    }
                    y={
                      (box?.y || 0) *
                      (scaledDimensions?.height /
                        (imageDimensions?.height || 1))
                    }
                    width={
                      (box?.width || 0) *
                      (scaledDimensions?.width / (imageDimensions?.width || 1))
                    }
                    height={
                      (box?.height || 0) *
                      (scaledDimensions?.height /
                        (imageDimensions?.height || 1))
                    }
                  />
                  <AnimatedText
                    x={
                      (box.x + box.width / 2) *
                      (scaledDimensions.width / imageDimensions.width)
                    }
                    y={
                      (box.y + box.height / 2) *
                      (scaledDimensions.height / imageDimensions.height)
                    }
                    fill="#122FBA"
                    fontSize="22"
                    fontWeight="bold"
                    textAnchor="middle"
                  >
                    {index + 1}
                  </AnimatedText>
                </Svg>
              )}
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
