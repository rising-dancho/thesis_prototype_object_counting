import { StyleSheet } from 'react-native';
import { Image, type ImageSource } from 'expo-image';

export default function ImageViewer({ imgSource }: { imgSource: ImageSource }) {
  return <Image source={imgSource} style={styles.image} contentFit="contain" />;
}

const styles = StyleSheet.create({
  image: {
    width: 520,
    height: 640,
  },
});
