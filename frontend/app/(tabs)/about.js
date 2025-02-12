import React, { useState, Fragment } from 'react';
import {
  View,
  Text,
  Button,
  Image,
  StyleSheet,
  Platform,
  ScrollView,
} from 'react-native';
import axios from 'axios';
import * as ImagePicker from 'expo-image-picker';
import Svg, { Rect, Text as SvgText } from 'react-native-svg';

const ImageUpload = () => {
  const [selectedImage, setSelectedImage] = useState(null);
  const [response, setResponse] = useState(null);
  const [error, setError] = useState(null);
  const [boxes, setBoxes] = useState([]);
  const [imageDimensions, setImageDimensions] = useState(null);
  const [displayedSize, setDisplayedSize] = useState(null);

  const handleSubmit = async () => {
    if (!selectedImage) {
      setError('No image selected');
      return;
    }

    const formData = new FormData();

    if (Platform.OS === 'web') {
      const res = await fetch(selectedImage);
      const blob = await res.blob();
      formData.append('image', blob, 'uploaded-image.jpg');
    } else {
      formData.append('image', {
        uri: selectedImage,
        type: 'image/jpeg',
        name: 'uploaded-image.jpg',
      });
    }

    try {
      const res = await axios.post(
        'http://localhost:5000/image-processing',
        formData,
        {
          headers: { 'Content-Type': 'multipart/form-data' },
        }
      );
      setResponse(res.data);
      setBoxes(
        res.data.bounding_boxes.map((box) => ({
          x: box[0],
          y: box[1],
          width: box[2],
          height: box[3],
        }))
      );
      setError(null);
    } catch (err) {
      setError('Error uploading image: ' + err.message);
      setResponse(null);
    }
  };

  const selectImage = async () => {
    const permission = await ImagePicker.requestMediaLibraryPermissionsAsync();
    if (!permission.granted) {
      setError('Permission to access gallery is required.');
      return;
    }

    let result = await ImagePicker.launchImageLibraryAsync({
      mediaTypes: ImagePicker.MediaTypeOptions.Images,
      allowsEditing: true,
      quality: 1,
    });

    if (!result.canceled) {
      const selectedAsset = result.assets[0].uri;
      const { width, height } = result.assets[0];
      setSelectedImage(selectedAsset);
      setImageDimensions({ width, height });
      setError(null);
    } else {
      setError('You did not select any image.');
    }
  };

  const onImageLayout = (event) => {
    const { width, height } = event.nativeEvent.layout;
    setDisplayedSize({ width, height });
  };

  return (
    <ScrollView contentContainerStyle={styles.container}>
      <Text style={styles.title}>Upload Image for Processing</Text>
      <Button title="Select Image" onPress={selectImage} />
      <Button
        title="Upload and Process"
        onPress={handleSubmit}
        disabled={!selectedImage}
      />
      {error && <Text style={styles.error}>{error}</Text>}

      {response && (
        <View style={styles.imageContainer}>
          <Image
            source={{ uri: selectedImage }}
            style={{
              width: displayedSize?.width || 300,
              height: displayedSize?.height || 300,
              resizeMode: 'contain',
            }}
            onLayout={onImageLayout}
          />
          <Svg
            height={displayedSize?.height}
            width={displayedSize?.width}
            style={{ position: 'absolute', top: 0, left: 0 }}
          >
            {boxes.map((box, index) => {
              const scaleX = displayedSize?.width / imageDimensions?.width;
              const scaleY = displayedSize?.height / imageDimensions?.height;

              return (
                <Fragment key={index}>
                  <Rect
                    x={box.x * scaleX}
                    y={box.y * scaleY}
                    width={box.width * scaleX}
                    height={box.height * scaleY}
                    stroke="green"
                    fill="transparent"
                    strokeWidth="2"
                  />
                  <SvgText
                    x={(box.x + box.width / 2) * scaleX}
                    y={(box.y + box.height / 2) * scaleY}
                    fill="white"
                    fontSize="18"
                    fontWeight="bold"
                    textAnchor="middle"
                    alignmentBaseline="central"
                  >
                    {index + 1}
                  </SvgText>
                </Fragment>
              );
            })}
          </Svg>
          <Text style={styles.objectCount}>
            Object Count: {response.object_count}
          </Text>
        </View>
      )}
    </ScrollView>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    marginTop: '20%',
    marginBottom: '20%',
  },
  title: {
    fontSize: 24,
    fontWeight: 'bold',
    marginBottom: 20,
  },
  error: {
    color: 'red',
    marginTop: 10,
  },
  imageContainer: {
    position: 'relative',
    marginTop: 20,
  },
  objectCount: {
    fontSize: 18,
    marginTop: 10,
  },
});

export default ImageUpload;
