import React, { useState } from 'react';
import {
  View,
  Text,
  Button,
  Image,
  FlatList,
  StyleSheet,
  Platform,
} from 'react-native';
import axios from 'axios';
import * as ImagePicker from 'expo-image-picker';
import { Svg, Rect } from 'react-native-svg';

const ImageUpload = () => {
  const [image, setImage] = useState(null);
  const [response, setResponse] = useState(null);
  const [error, setError] = useState(null);
  const [boxes, setBoxes] = useState([]); // Holds the bounding boxes
  const [imageDimensions, setImageDimensions] = useState(null); // Holds image dimensions

  const addBox = (x, y, width, height) => {
    setBoxes([
      ...boxes,
      { x, y, width, height }, // Add new box to the array
    ]);
  };

  const selectImage = async () => {
    try {
      let result = await ImagePicker.launchImageLibraryAsync({
        mediaTypes: ImagePicker.MediaTypeOptions.Images,
        allowsEditing: true,
        quality: 1,
      });

      if (!result.canceled) {
        const selectedAsset = result.assets[0].uri;
        const { width, height } = result.assets[0];
        setImage(selectedAsset);
        setImageDimensions({ width, height });
        setError(null);
      } else {
        setError('You did not select any image.');
      }
    } catch (err) {
      setError('Error selecting image: ' + err.message);
    }
  };

  const handleSubmit = async () => {
    if (!image) {
      setError('No image selected');
      return;
    }

    const formData = new FormData();

    if (Platform.OS === 'web') {
      const response = await fetch(image);
      const blob = await response.blob();
      formData.append('image', blob, 'uploaded-image.jpg');
    } else {
      formData.append('image', {
        uri: image,
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
      console.log(res.data.bounding_boxes); // box coordinates

      // Call addBox for each bounding box in the response
      res.data.bounding_boxes.forEach((box) => {
        setBoxes((prevBoxes) => [
          ...prevBoxes,
          { x: box[0], y: box[1], width: box[2], height: box[3] }, // Add each box
        ]);
      });

      setError(null);
    } catch (err) {
      setError('Error uploading image: ' + err.message);
      setResponse(null);
    }
  };

  // Scale the bounding box coordinates relative to the image size
  const scaleBoxCoordinates = (box) => {
    if (imageDimensions) {
      const { width: imgWidth, height: imgHeight } = imageDimensions;
      return {
        x: (box.x / imgWidth) * 100, // Scale x to percentage of image width
        y: (box.y / imgHeight) * 100, // Scale y to percentage of image height
        width: (box.width / imgWidth) * 100, // Scale width to percentage of image width
        height: (box.height / imgHeight) * 100, // Scale height to percentage of image height
      };
    }
    return box;
  };

  return (
    <View style={styles.container}>
      <Text style={styles.title}>Upload Image for Processing</Text>
      <Button title="Select Image" onPress={selectImage} />
      <Button
        title="Upload and Process"
        onPress={handleSubmit}
        disabled={!image}
      />

      {error && <Text style={styles.error}>{error}</Text>}

      {image && <Image source={{ uri: image }} style={styles.image} />}

      {response && (
        <View>
          <Text style={styles.subtitle}>Processed Image:</Text>

          <Image
            source={{
              uri: `data:image/png;base64,${response.processed_image}`,
            }}
            style={styles.processedImage}
          />
          {/* SVG component to draw the boxes */}
          {imageDimensions && (
            <Svg
              height={imageDimensions.height}
              width={imageDimensions.width}
              style={styles.svg}
            >
              {boxes.map((box, index) => {
                const scaledBox = scaleBoxCoordinates(box);
                return (
                  <Rect
                    key={index}
                    x={scaledBox.x}
                    y={scaledBox.y}
                    width={scaledBox.width}
                    height={scaledBox.height}
                    stroke="blue"
                    fill="transparent"
                    strokeWidth="2"
                  />
                );
              })}
            </Svg>
          )}

          <Text style={styles.objectCount}>
            Object Count: {response.object_count}
          </Text>
          <Text style={styles.boundingBoxTitle}>Bounding Boxes:</Text>
          <FlatList
            data={response.bounding_boxes}
            renderItem={({ item }) => (
              <Text>
                X: {item[0]}, Y: {item[1]}, Width: {item[2]}, Height: {item[3]}
              </Text>
            )}
            keyExtractor={(item, index) => index.toString()}
          />
        </View>
      )}
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    padding: 16,
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
  processedImage: {
    width: 85,
    height: 85,
    position: 'absolute',
    marginTop: 6,
    marginLeft: 6,
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
    position: 'absolute', // Overlay the SVG (bounding boxes) on top of the image
    top: 0,
    left: 0,
    zIndex: 999,
  },
});

export default ImageUpload;
