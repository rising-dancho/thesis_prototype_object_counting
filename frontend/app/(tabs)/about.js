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
  const [selectedImage, setSelectedImage] = useState(undefined);
  const [response, setResponse] = useState(null);
  const [error, setError] = useState(null);
  const [boxes, setBoxes] = useState([]);
  const [imageDimensions, setImageDimensions] = useState(null);

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
      setBoxes(res.data.bounding_boxes);
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
      console.log('Selected image:', selectedAsset);
      setSelectedImage(selectedAsset);
      setImageDimensions({ width, height });
      setError(null);
    } else {
      setError('You did not select any image.');
    }
  };
  const scaleBoxCoordinates = (box) => {
    if (!imageDimensions) return box;

    const displayedWidth = 200;
    const displayedHeight =
      (imageDimensions.height / imageDimensions.width) * displayedWidth;

    return {
      x: (box.x / imageDimensions.width) * displayedWidth,
      y: (box.y / imageDimensions.height) * displayedHeight,
      width: (box.width / imageDimensions.width) * displayedWidth,
      height: (box.height / imageDimensions.height) * displayedHeight,
    };
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
        <View>
          <Text style={styles.subtitle}>Processed Image:</Text>

          <View
            style={[
              styles.imageContainer,
              {
                width: 200,
                height:
                  (imageDimensions?.height / imageDimensions?.width) * 200,
              },
            ]}
          >
            <Image
              source={{ uri: selectedImage }}
              style={{
                width: 200,
                height:
                  (imageDimensions?.height / imageDimensions?.width) * 200,
              }}
            />
            <Svg
              height={(imageDimensions?.height / imageDimensions?.width) * 200}
              width={200}
              style={styles.svg}
            >
              {boxes.map((box, index) => {
                const scaledBox = scaleBoxCoordinates(box);
                return (
                  <Fragment key={index}>
                    <Rect
                      x={scaledBox.x}
                      y={scaledBox.y}
                      width={scaledBox.width}
                      height={scaledBox.height}
                      stroke="red"
                      fill="transparent"
                      strokeWidth="2"
                    />
                    <SvgText
                      x={scaledBox.x + scaledBox.width / 2}
                      y={scaledBox.y - 5}
                      fill="white"
                      fontSize="14"
                      fontWeight="bold"
                      textAnchor="middle"
                    >
                      {index + 1}
                    </SvgText>
                  </Fragment>
                );
              })}
            </Svg>
          </View>

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
  image: {
    width: 200,
    height: 200,
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
  boundingBoxTitle: {
    fontSize: 18,
    marginTop: 10,
  },
  subtitle: {
    fontSize: 20,
    marginTop: 20,
  },
  svg: {
    position: 'absolute',
    top: 0,
    left: 0,
    zIndex: 999,
  },
});

export default ImageUpload;
