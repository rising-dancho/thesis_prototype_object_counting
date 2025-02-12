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
        <ScrollView horizontal>
          <ScrollView>
            <View style={styles.imageContainer}>
              <Image
                source={{ uri: selectedImage }}
                style={{
                  width: imageDimensions?.width,
                  height: imageDimensions?.height,
                }}
              />
              <Svg
                height={imageDimensions?.height}
                width={imageDimensions?.width}
                style={{ position: 'absolute', top: 0, left: 0 }}
              >
                {boxes.map((box, index) => (
                  <Fragment key={index}>
                    <Rect
                      x={box.x}
                      y={box.y}
                      width={box.width}
                      height={box.height}
                      stroke="green"
                      fill="transparent"
                      strokeWidth="8"
                    />
                    <SvgText
                      x={box.x + box.width / 2}
                      y={box.y + box.height / 2}
                      fill="black"
                      fontSize="24"
                      fontWeight="bold"
                      textAnchor="middle"
                      alignmentBaseline="middle"
                    >
                      {index + 1}
                    </SvgText>
                  </Fragment>
                ))}
              </Svg>
              <Text style={styles.objectCount}>
                Object Count: {response.object_count}
              </Text>
            </View>
          </ScrollView>
        </ScrollView>
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
});

export default ImageUpload;
