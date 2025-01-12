import React from 'react';
import Animated, {
  useSharedValue,
  useAnimatedStyle,
} from 'react-native-reanimated';
import {
  Gesture,
  GestureDetector,
  GestureHandlerRootView,
} from 'react-native-gesture-handler';
import { StyleSheet, Dimensions } from 'react-native';

function clamp(val, min, max) {
  return Math.min(Math.max(val, min), max);
}

const { width, height } = Dimensions.get('screen');

export default function App() {
  const boxes = [
    { id: 1, translationX: useSharedValue(0), translationY: useSharedValue(0) },
    { id: 2, translationX: useSharedValue(0), translationY: useSharedValue(0) },
    { id: 3, translationX: useSharedValue(0), translationY: useSharedValue(0) },
  ];

  const animatedStyles = (translationX, translationY) =>
    useAnimatedStyle(() => ({
      transform: [
        { translateX: translationX.value },
        { translateY: translationY.value },
      ],
    }));

  const createPanGesture = (translationX, translationY) =>
    Gesture.Pan()
      .minDistance(1)
      .onStart(() => {
        translationX.prev = translationX.value;
        translationY.prev = translationY.value;
      })
      .onUpdate((event) => {
        const maxTranslateX = width / 2 - 50;
        const maxTranslateY = height / 2 - 50;

        translationX.value = clamp(
          translationX.prev + event.translationX,
          -maxTranslateX,
          maxTranslateX
        );
        translationY.value = clamp(
          translationY.prev + event.translationY,
          -maxTranslateY,
          maxTranslateY
        );
      })
      .runOnJS(true);

  return (
    <GestureHandlerRootView style={styles.container}>
      {boxes.map((box) => (
        <GestureDetector key={box.id} gesture={createPanGesture(box.translationX, box.translationY)}>
          <Animated.View style={[animatedStyles(box.translationX, box.translationY), styles.box]} />
        </GestureDetector>
      ))}
    </GestureHandlerRootView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
  },
  box: {
    width: 100,
    height: 100,
    backgroundColor: '#b58df1',
    borderRadius: 20,
    margin: 10,
  },
});
