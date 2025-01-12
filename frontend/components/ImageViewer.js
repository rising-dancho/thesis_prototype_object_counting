import React, { useEffect } from 'react';
import { StyleSheet, View } from 'react-native';
import { Image } from 'expo-image';
import { Text } from 'react-native-paper';
import Svg, { Rect, Text as SvgText, G } from 'react-native-svg';
import Animated, {
  useSharedValue,
  useAnimatedProps,
} from 'react-native-reanimated';
import {
  GestureHandlerRootView,
  GestureDetector,
  Gesture,
} from 'react-native-gesture-handler';

const AnimatedG = Animated.createAnimatedComponent(G);

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
  const translationX = useSharedValue(0);
  const translationY = useSharedValue(0);

  const animatedProps = useAnimatedProps(() => ({
    transform: [
      { translateX: translationX.value },
      { translateY: translationY.value },
    ],
  }));

  const panGesture = Gesture.Pan().onUpdate((event) => {
    translationX.value = event.translationX;
    translationY.value = event.translationY;
  });

  const displayWidth = 520;
  const displayHeight = 640;

  const scaledDimensions = imageDimensions
    ? {
        width: displayWidth,
        height: (imageDimensions.height / imageDimensions.width) * displayWidth,
      }
    : { width: displayWidth, height: displayHeight };

  return (
    <GestureHandlerRootView style={styles.container}>
      <GestureDetector gesture={panGesture}>
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
                    return (
                      <AnimatedG key={index} animatedProps={animatedProps}>
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
      </GestureDetector>
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
