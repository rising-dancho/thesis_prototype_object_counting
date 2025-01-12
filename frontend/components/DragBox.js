import React from 'react';
import { PanGestureHandler } from 'react-native-gesture-handler';
import Animated, {
  useSharedValue,
  useAnimatedStyle,
  withSpring,
} from 'react-native-reanimated';
import Svg, { Rect, Text as SvgText } from 'react-native-svg';
import { StyleSheet } from 'react-native';

const DragBox = ({ box, index }) => {
  const translateX = useSharedValue(box[0]);
  const translateY = useSharedValue(box[1]);

  const animatedStyle = useAnimatedStyle(() => ({
    transform: [
      { translateX: withSpring(translateX.value) },
      { translateY: withSpring(translateY.value) },
    ],
  }));

  const onGestureEvent = (event) => {
    translateX.value = event.nativeEvent.translationX + box[0];
    translateY.value = event.nativeEvent.translationY + box[1];
  };

  return (
    <PanGestureHandler onGestureEvent={onGestureEvent}>
      <Animated.View style={[animatedStyle, styles.boxContainer]}>
        <Svg height={box[3]} width={box[2]}>
          <Rect
            x={0}
            y={0}
            width={box[2]}
            height={box[3]}
            stroke="red"
            strokeWidth="3"
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
      </Animated.View>
    </PanGestureHandler>
  );
};

const styles = StyleSheet.create({
  boxContainer: {
    position: 'absolute',
  },
});

export default DragBox;
