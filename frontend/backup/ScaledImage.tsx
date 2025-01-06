import { Image, StyleSheet, View } from 'react-native';

const ScaledImage = ({ imgSource }: { imgSource: string }) => {
  return (
    <View style={styles.container}>
      <Image
        source={{ uri: imgSource }}
        style={styles.image}
        resizeMode="contain" // Scales the image while preserving aspect ratio
      />
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
  },
  image: {
    width: '100%',
    height: '100%',
  },
});

export default ScaledImage;
