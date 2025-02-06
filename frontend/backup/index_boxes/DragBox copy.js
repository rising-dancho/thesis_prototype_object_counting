import React from 'react';
import { GestureDetector, Gesture } from 'react-native-gesture-handler';
import Animated, {
  useSharedValue,
  useAnimatedStyle,
  withSpring,
} from 'react-native-reanimated';
import Svg, { Rect, Text as SvgText } from 'react-native-svg';
import { View, StyleSheet, Pressable } from 'react-native';

const DragBox = ({ box, index, setBoxes, isDraggable }) => {
  const translateX = useSharedValue(box[0]);
  const translateY = useSharedValue(box[1]);

  const panGesture = Gesture.Pan()
    .enabled(isDraggable) // Disable gesture if `isDraggable` is false
    .onUpdate((event) => {
      if (!isDraggable) return;
      translateX.value = box[0] + event.translationX;
      translateY.value = box[1] + event.translationY;
    })
    .onEnd(() => {
      if (!isDraggable) return;
      setBoxes((prevBoxes) =>
        prevBoxes.map((b, i) =>
          i === index ? { ...b, x: translateX.value, y: translateY.value } : b
        )
      );
      translateX.value = withSpring(translateX.value);
      translateY.value = withSpring(translateY.value);
    });

  const onBoxRemove = () => {
    setBoxes((prevBoxes) => prevBoxes.filter((_, i) => i !== index));
  };

  const animatedStyle = useAnimatedStyle(() => ({
    transform: [
      { translateX: translateX.value },
      { translateY: translateY.value },
    ],
  }));

  return (
    <GestureDetector gesture={isDraggable ? panGesture : Gesture.Tap()}>
      <Animated.View style={[animatedStyle, styles.boxContainer]}>
        <Svg height={box[3]} width={box[2]}>
          <Rect
            x={0}
            y={0}
            width={box[2]}
            height={box[3]}
            stroke="#00FF00"
            strokeWidth="5"
            fill="transparent"
          />
          <SvgText
            x={box[2] / 2}
            y={box[3] / 2}
            fill="blue"
            fontSize="16"
            fontWeight="bold"
            textAnchor="middle"
          >
            {index + 1}
          </SvgText>
        </Svg>
        {/* Button to remove the box */}
        <Pressable style={styles.closeButton} onPress={onBoxRemove}>
          <SvgText fontSize="18" fontWeight="bold">
            ✖
          </SvgText>
        </Pressable>
      </Animated.View>
    </GestureDetector>
  );
};

const styles = StyleSheet.create({
  boxContainer: {
    position: 'absolute',
  },
  closeButton: {
    position: 'absolute',
    top: -20, // Position above the box
    right: -20, // Position to the right of the box
    backgroundColor: 'red',
    color: 'white',
    borderRadius: 2,
    zIndex: 10, // Ensure it is above other elements
    // padding: 2,
    // paddingLeft: 6,
    // paddingRight: 6,
  },
});

export default DragBox;
