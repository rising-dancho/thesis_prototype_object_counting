import React from 'react';
import { StyleSheet, View } from 'react-native';
import { Image } from 'expo-image';
import { Text } from 'react-native-paper';
import Svg, { Rect, Text as SvgText, G as Group } from 'react-native-svg';
import Animated, {
  useSharedValue,
  useAnimatedProps,
} from 'react-native-reanimated';
import {
  GestureHandlerRootView,
  GestureDetector,
  Gesture,
} from 'react-native-gesture-handler';

const AnimatedG = Animated.createAnimatedComponent(Group);

export default function ImageViewer({
  imgSource,
  text,
  count,
  timestamp,
  clicked,
  boxes = [],
  response,
  imageDimensions,
  scaleBoxCoordinates,
}) {
  const displayWidth = 520;
  const displayHeight = 640;

  const scaledDimensions = imageDimensions
    ? {
        width: displayWidth,
        height: (imageDimensions.height / imageDimensions.width) * displayWidth,
      }
    : { width: displayWidth, height: displayHeight };

  const createGestureHandlers = () => {
    return boxes.map((box, index) => {
      const translateX = useSharedValue(0);
      const translateY = useSharedValue(0);

      const panGesture = Gesture.Pan().onUpdate((event) => {
        translateX.value = event.translationX;
        translateY.value = event.translationY;
      });

      const animatedProps = useAnimatedProps(() => ({
        transform: [
          { translateX: translateX.value },
          { translateY: translateY.value },
        ],
      }));

      return { panGesture, animatedProps, translateX, translateY };
    });
  };

  const gestures = createGestureHandlers();

  return (
    <GestureHandlerRootView style={styles.container}>
      <View style={styles.container}>
        <View style={styles.flex}>
          <Text variant="labelLarge" style={styles.title}>
            {text || ''}
          </Text>
          {clicked && (
            <Text variant="labelLarge" style={styles.count}>
              Total Count: {count || ''}
            </Text>
          )}
        </View>

        {response && (
          <View
            style={[styles.imageContainer, !imgSource && { height: 640 }]}
          >
            {imgSource && (
              <Image source={imgSource} style={scaledDimensions} />
            )}

            {imageDimensions && (
              <Svg
                height={scaledDimensions.height}
                width={scaledDimensions.width}
                style={styles.svg}
              >
                {boxes.map((box, index) => {
                  const scaledBox = scaleBoxCoordinates(box);
                  const gesture = gestures[index];

                  return (
                    <GestureDetector
                      key={index}
                      gesture={gesture.panGesture}
                    >
                      <AnimatedG animatedProps={gesture.animatedProps}>
                        <Rect
                          x={
                            scaledBox.x *
                            (scaledDimensions.width / imageDimensions.width)
                          }
                          y={
                            scaledBox.y *
                            (scaledDimensions.height / imageDimensions.height)
                          }
                          width={
                            scaledBox.width *
                            (scaledDimensions.width / imageDimensions.width)
                          }
                          height={
                            scaledBox.height *
                            (scaledDimensions.height / imageDimensions.height)
                          }
                          stroke="#00FF00"
                          fill="transparent"
                          strokeWidth="3"
                        />
                        <SvgText
                          x={
                            (scaledBox.x + scaledBox.width / 2) *
                            (scaledDimensions.width / imageDimensions.width)
                          }
                          y={
                            (scaledBox.y + scaledBox.height / 2) *
                            (scaledDimensions.height / imageDimensions.height)
                          }
                          fill="#122FBA"
                          fontSize="22"
                          fontWeight="bold"
                          textAnchor="middle"
                        >
                          {index + 1}
                        </SvgText>
                      </AnimatedG>
                    </GestureDetector>
                  );
                })}
              </Svg>
            )}
          </View>
        )}

        <Text variant="labelLarge" style={styles.timestamp}>
          {timestamp}
        </Text>
      </View>
    </GestureHandlerRootView>
  );
}

const styles = StyleSheet.create({
  container: {
    backgroundColor: '#F4F4F5',
  },
  flex: {
    flexDirection: 'row',
    justifyContent: 'space-between',
  },
  imageContainer: {
    position: 'relative',
    overflow: 'hidden',
    backgroundColor: '#25292e',
    width: '100%',
  },
  svg: {
    position: 'absolute',
    top: 0,
    left: 0,
  },
  title: {
    paddingBottom: 3,
    fontWeight: '700',
    fontSize: 18,
  },
  count: {
    fontSize: 16,
    fontWeight: 'bold',
  },
  timestamp: {
    fontSize: 16,
    fontWeight: 'bold',
  },
});
